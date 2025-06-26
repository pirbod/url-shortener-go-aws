# Stage 1: Build the binary
FROM golang:1.21 as builder
WORKDIR /app
COPY ./app/go.mod ./
RUN go mod download
COPY ./app/*.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o url-shortener

# Stage 2: Final image
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/url-shortener .
CMD ["./url-shortener"]
