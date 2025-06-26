# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY app/go.mod app/go.sum ./
RUN go mod download
COPY app/*.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o url-shortener

# Final image
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/url-shortener .
CMD ["./url-shortener"]
