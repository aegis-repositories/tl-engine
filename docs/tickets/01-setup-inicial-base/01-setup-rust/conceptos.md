# 🧠 Conceptos Clave - Rust y Docker

## 1. ¿Por qué Rust para un Engine Backend?

Rust es un lenguaje de sistemas compilado que ofrece:
- **Rendimiento**: Código compilado a binario nativo, similar a C/C++ pero con seguridad de memoria.
- **Concurrencia**: Modelo de ownership y tipos como `Arc`, `Mutex` permiten manejar miles de conexiones simultáneas sin data races.
- **Eficiencia de memoria**: Sin garbage collector, control preciso sobre asignación/liberación de memoria. Reduce costos en infraestructura cloud.
- **Ecosistema async**: Tokio proporciona un runtime asíncrono maduro para I/O no bloqueante (HTTP, bases de datos, message queues).

**Trade-offs**:
- Levantar el ambiente de desarrollo y deploy es un proceso lento.
- Curva de aprendizaje inicial por el sistema de ownership y lifetimes.
- Los desarrollos deben ser en cuotas bien distribuidas  para cuidar el codebase.

## 2. Estructura de Proyecto Rust: Workspace vs Single Crate

### Single Crate (Proyecto Simple)
Un solo `Cargo.toml` en la raíz define un proyecto independiente:
```
proyecto/
├── Cargo.toml
└── src/
    └── main.rs
```

### Workspace (Múltiples Crates)
Un `Cargo.toml` en la raíz actúa como coordinador, y subdirectorios contienen crates individuales:
```
workspace/
├── Cargo.toml          # Define [workspace] con members
├── engine-api/          # Crate 1: Servidor HTTP
│   ├── Cargo.toml
│   └── src/
├── engine-worker/       # Crate 2: Procesador de colas
│   ├── Cargo.toml
│   └── src/
└── shared/              # Crate 3: Código compartido
    ├── Cargo.toml
    └── src/
```

**Ventajas del Workspace**:
- Compartir dependencias: todas usan la misma versión de `serde`, `tokio`, etc.
- Compilar todo junto: `cargo build --workspace` compila todos los crates.
- Refactorizar código compartido sin duplicación.

**Para este proyecto**: Iniciamos con un single crate (`tl-engine`). El workspace se puede agregar más adelante cuando separemos API y Workers.

## 3. Docker Multistage Build: Optimización de Imágenes

### Problema
Rust necesita herramientas pesadas para compilar:
- Compilador `rustc` (~200MB)
- Herramientas de build (`cargo`, `rustup`)
- Librerías del sistema (OpenSSL, etc.)
- Cache de dependencias compiladas

Una imagen Docker que incluye todo esto puede pesar 800MB-1GB, pero el binario final solo pesa ~10-20MB.

### Solución: Multistage Build

Un Dockerfile puede tener múltiples etapas (`FROM ... AS nombre`). Solo la última etapa se convierte en la imagen final.

```dockerfile
# Etapa 1: Builder (pesada, ~800MB)
FROM rust:1.75-alpine AS builder
WORKDIR /app
COPY . .
RUN cargo build --release
# Resultado: binario en /app/target/release/tl-engine

# Etapa 2: Runtime (ligera, ~20MB)
FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/target/release/tl-engine .
CMD ["./tl-engine"]
```

**Qué pasa**:
1. La etapa `builder` compila el código (usa todas las herramientas pesadas).
2. La etapa final solo copia el binario compilado.
3. Docker descarta todo lo de la etapa `builder` que no se copió.
4. Imagen final: solo Alpine Linux + el binario.

**Beneficios**:
- Imagen pequeña: sube rápido a registries (Docker Hub, GCR, ECR).
- Menos superficie de ataque: menos paquetes instalados = menos vulnerabilidades.
- Menor costo de almacenamiento en cloud.

## 4. Cacheo de Dependencias en Docker

### Problema del Cacheo Naive
Si copias todo el código y luego compilas:
```dockerfile
COPY . .                    # Copia TODO (incluyendo src/)
RUN cargo build --release   # Si cambias src/main.rs, Docker invalida el cache aquí
```

Cada cambio en `src/main.rs` fuerza a recompilar **todas las dependencias** (tokio, serde, etc.), aunque no hayan cambiado. Esto puede tomar 5-10 minutos cada vez.

### Solución: Separar Dependencias de Código

```dockerfile
# Paso 1: Copiar solo los manifiestos (Cargo.toml, Cargo.lock)
COPY Cargo.toml Cargo.lock ./

# Paso 2: Crear un main.rs dummy y compilar
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
# Esto compila SOLO las dependencias y las cachea

# Paso 3: Borrar el dummy
RUN rm -rf src

# Paso 4: Copiar el código real
COPY src ./src
RUN touch src/main.rs  # Forzar que cargo detecte el cambio
RUN cargo build --release
# Ahora solo recompila tu código, reutiliza las dependencias del cache
```

**Cómo funciona el cache de Docker**:
- Docker cachea cada `RUN` basándose en el contenido de las capas anteriores.
- Si `Cargo.toml` no cambió, la capa "compilar dependencias" se reutiliza.
- Solo cuando cambias `src/`, se recompila tu código (rápido), pero las dependencias vienen del cache.

**Resultado**: Builds subsecuentes pasan de 10 minutos a 30 segundos.

## 5. Tokio: Runtime Asíncrono

Rust no tiene un runtime asíncrono built-in. `tokio` proporciona:
- **Event loop**: Maneja I/O no bloqueante (sockets, archivos, timers).
- **Task scheduler**: Ejecuta miles de tareas concurrentes en un pequeño pool de threads del OS.
- **Async/await**: Sintaxis similar a JavaScript/Python para código asíncrono.

```rust
#[tokio::main]  // Macro que crea el runtime
async fn main() {
    // Código async aquí
    tokio::spawn(async {
        // Tarea concurrente
    }).await;
}
```

**Por qué async**: Un servidor que maneja 10,000 conexiones simultáneas no puede crear 10,000 threads del OS (cada thread consume ~2MB de stack). Con async, todas las conexiones se multiplexan en ~4-8 threads del CPU.
