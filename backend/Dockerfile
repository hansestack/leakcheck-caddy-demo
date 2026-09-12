# --- build stage ---------------------------------------------------------
FROM golang:1.22-alpine AS builder

WORKDIR /src

COPY go.mod ./
COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /out/dummy-backend .

# --- runtime stage --------------------------------------------------------
FROM alpine:3.20

RUN adduser -D -H -s /sbin/nologin appuser
WORKDIR /app

COPY --from=builder /out/dummy-backend ./dummy-backend
COPY index.html ./index.html

USER appuser
EXPOSE 80

ENTRYPOINT ["./dummy-backend"]
