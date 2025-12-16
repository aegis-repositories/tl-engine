# 📚 Referencia Técnica - Rust y Docker

## Dependencias del Proyecto: Explicación

### `tokio`
Runtime asíncrono para Rust. Proporciona:
- **Event loop**: Ejecuta tareas async sin bloquear threads del OS.
- **Async I/O**: Operaciones de red y archivos no bloqueantes.
- **Timers**: `tokio::time::sleep`, `tokio::time::interval`.
- **Channels**: Comunicación entre tareas (`mpsc`, `oneshot`).

**Features usadas**: `["full"]` incluye todas las features (TCP, UDP, filesystem, timers, etc.). Para producción, selecciona solo las necesarias para reducir tamaño del binario.

### `serde` + `serde_json`
Serialización/deserialización de datos:
- **serde**: Framework genérico (trait-based).
- **serde_json**: Implementación para JSON.

```rust
#[derive(Serialize, Deserialize)]
struct User {
    id: u32,
    name: String,
}

let json = serde_json::to_string(&user)?;  // Serializar
let user: User = serde_json::from_str(&json)?;  // Deserializar
```

### `dotenvy`
Carga variables de entorno desde archivo `.env`:
```rust
dotenvy::dotenv()?;  // Carga .env
let key = std::env::var("API_KEY")?;
```

**Alternativa**: `dotenv` (más popular, pero `dotenvy` es más moderno y mantenido).

### `tracing` + `tracing-subscriber`
Sistema de logging estructurado:
- **tracing**: Framework de instrumentación (logs, spans, events).
- **tracing-subscriber**: Backends para formatear y exportar logs.

**Ventajas sobre `println!`**:
- Niveles de log (ERROR, WARN, INFO, DEBUG, TRACE).
- Contexto estructurado (spans para rastrear requests).
- Integración con sistemas externos (OpenTelemetry, Datadog).

## Dockerfile: Análisis Línea por Línea

```dockerfile
FROM rust:1.75-alpine as builder
```
- `rust:1.75-alpine`: Imagen oficial de Rust basada en Alpine Linux (ligera).
- `as builder`: Nombre de la etapa para referenciarla después.

```dockerfile
WORKDIR /app
```
Establece el directorio de trabajo. Equivalente a `cd /app`.

```dockerfile
RUN apk add --no-cache musl-dev
```
- `apk`: Package manager de Alpine.
- `musl-dev`: Librerías de desarrollo para compilar código que usa `musl` (libc de Alpine).
- Necesario porque Rust compila contra `musl` en Alpine (no glibc como Ubuntu).

```dockerfile
COPY Cargo.toml Cargo.lock ./
```
Copia solo los manifiestos (no el código fuente aún) para aprovechar el cache de Docker.

```dockerfile
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
```
Truco de cacheo: compila dependencias con un main dummy.

```dockerfile
RUN rm -rf src
```
Elimina el dummy antes de copiar el código real.

```dockerfile
COPY src ./src
RUN touch src/main.rs
```
- Copia el código real.
- `touch` fuerza que cargo detecte el cambio (por si acaso el timestamp no cambió).

```dockerfile
RUN cargo build --release
```
Compila el código real. Las dependencias vienen del cache.

```dockerfile
FROM alpine:3.18
```
Etapa final: imagen mínima de Alpine (solo ~5MB).

```dockerfile
COPY --from=builder /app/target/release/tl-engine .
```
Copia el binario compilado desde la etapa `builder`.

```dockerfile
CMD ["./tl-engine"]
```
Comando por defecto al ejecutar el contenedor.

## Optimizaciones Adicionales (Opcional)

### Usar `cargo-chef` para Mejor Cacheo
`cargo-chef` es una herramienta que optimiza el cacheo de dependencias mejor que el truco manual:

```dockerfile
FROM rust:1.75-alpine as chef
RUN cargo install cargo-chef
WORKDIR /app

FROM chef as planner
COPY Cargo.toml Cargo.lock ./
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release
```

**Ventaja**: Cacheo más preciso y confiable. **Desventaja**: Más complejo.

### Usar Distroless en Lugar de Alpine
`gcr.io/distroless/cc-debian11` es aún más ligera que Alpine (solo el binario + libc, sin shell ni package manager):

```dockerfile
FROM gcr.io/distroless/cc-debian11
COPY --from=builder /app/target/release/tl-engine .
CMD ["./tl-engine"]
```

**Ventaja**: Menor superficie de ataque (no hay shell para explotar). **Desventaja**: Más difícil de debuggear (no puedes `docker exec` para entrar al contenedor).
