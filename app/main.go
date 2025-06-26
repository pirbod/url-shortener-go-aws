package main

import (
    // Standard library
    "context"
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "strings"

    // AWS SDK v2
    "github.com/aws/aws-sdk-go-v2/aws"
    "github.com/aws/aws-sdk-go-v2/config"
    "github.com/aws/aws-sdk-go-v2/service/dynamodb"
    "github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

// Load ENV variables for DB, API key, and domain base
var (
    dbClient  *dynamodb.Client
    tableName = os.Getenv("DYNAMODB_TABLE")
    apiKey    = os.Getenv("API_KEY")
    baseURL   = os.Getenv("BASE_URL")
)

// Middleware to enforce API Key header
func requireAPIKey(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if r.Header.Get("X-API-Key") != apiKey {
            http.Error(w, "Unauthorized", http.StatusUnauthorized)
            return
        }
        next.ServeHTTP(w, r)
    })
}

// Shortens a URL and stores it in DynamoDB
func shortenHandler(w http.ResponseWriter, r *http.Request) {
    url := r.URL.Query().Get("url")
    if url == "" {
        http.Error(w, "Missing url parameter", http.StatusBadRequest)
        return
    }

    code := generateCode(url)

    _, err := dbClient.PutItem(context.TODO(), &dynamodb.PutItemInput{
        TableName: aws.String(tableName),
        Item: map[string]types.AttributeValue{
            "code": &types.AttributeValueMemberS{Value: code},
            "url":  &types.AttributeValueMemberS{Value: url},
        },
    })
    if err != nil {
        http.Error(w, "Failed to save URL", http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(map[string]string{"short_url": fmt.Sprintf("%s/%s", baseURL, code)})
}

// Redirects short code → long URL
func redirectHandler(w http.ResponseWriter, r *http.Request) {
    code := strings.TrimPrefix(r.URL.Path, "/")
    out, err := dbClient.GetItem(context.TODO(), &dynamodb.GetItemInput{
        TableName: aws.String(tableName),
        Key: map[string]types.AttributeValue{
            "code": &types.AttributeValueMemberS{Value: code},
        },
    })
    if err != nil || out.Item == nil {
        http.NotFound(w, r)
        return
    }

    longURL := out.Item["url"].(*types.AttributeValueMemberS).Value
    http.Redirect(w, r, longURL, http.StatusFound)
}

// Stubbed simple code generator
func generateCode(url string) string {
    return fmt.Sprintf("%x", len(url)) // replace with hash or UUID
}

// Entry point: setup AWS client and routes
func main() {
    cfg, err := config.LoadDefaultConfig(context.TODO())
    if err != nil {
        log.Fatalf("Unable to load AWS config: %v", err)
    }

    dbClient = dynamodb.NewFromConfig(cfg)

    http.Handle("/shorten", requireAPIKey(http.HandlerFunc(shortenHandler)))
    http.HandleFunc("/", redirectHandler)

    log.Println("Server started on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
