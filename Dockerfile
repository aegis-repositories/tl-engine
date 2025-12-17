# Etapa 1: build
FROM rust:1.92-alpine AS builder

WORKDIR /app

# Dependencias necesarias para compilar
RUN apk add --no-cache musl-dev

# Copiamos manifests primero (cache)
COPY Cargo.toml Cargo.lock ./

# Main dummy para cachear dependencias
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release

# Copiamos código real
RUN rm -rf src
COPY src ./src
RUN cargo build --release

# Etapa 2: runtime
FROM alpine:3.18

WORKDIR /app

COPY --from=builder /app/target/release/tl-engine /app/tl-engine

CMD ["./tl-engine"]
