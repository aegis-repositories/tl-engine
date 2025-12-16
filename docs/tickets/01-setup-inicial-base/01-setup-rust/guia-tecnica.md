# 🛠 Guía Técnica - Setup Rust

Sigue estos pasos en orden. **Asegúrate de estar en la raíz del proyecto** (`/home/pango/projects/freelo/tiendaleon/tl-engine/`).

## Pre-requisitos: Verificar Instalaciones

Antes de empezar, verifica que tienes lo necesario:

```bash
# Verificar Rust
cargo --version
# Si no está instalado, instálalo: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Verificar Docker
docker --version
# Si no está instalado, instálalo según tu distribución Linux
```

## Paso 1: Inicializar el Proyecto

Vamos a crear un binario simple.

1.  **Verifica si ya existe un proyecto Rust**:
    ```bash
    ls -la | grep Cargo.toml
    ```
    - Si **NO existe**: Continúa con el paso 2.
    - Si **SÍ existe**: Salta al paso 3 (solo edita los archivos existentes).

2.  **Inicia el proyecto** (solo si no existe):
    ```bash
    cargo init --bin --name tl-engine
    ```
    *(Esto crea un `Cargo.toml` y un `src/main.rs` en la raíz)*.

3.  Edita `Cargo.toml`. Agrega estas dependencias básicas que usaremos siempre:
    ```toml
    [package]
    name = "tl-engine"
    version = "0.1.0"
    edition = "2021"

    [dependencies]
    tokio = { version = "1.0", features = ["full"] } # Para código asíncrono
    serde = { version = "1.0", features = ["derive"] } # Para JSON
    serde_json = "1.0"
    dotenvy = "0.15" # Para leer .env
    tracing = "0.1" # Para logs
    tracing-subscriber = "0.3"
    ```

4.  Edita `src/main.rs`. Reemplázalo con este "Hola Mundo" profesional:
    ```rust
    use tracing::{info, Level};
    use tracing_subscriber::FmtSubscriber;

    #[tokio::main]
    async fn main() {
        // Configurar logs
        let subscriber = FmtSubscriber::builder()
            .with_max_level(Level::INFO)
            .finish();
        tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

        info!("🚀 TL-Engine Iniciado correctamente");
        
        // Aquí iría el loop principal del servidor
        // Por ahora simulamos trabajo
        info!("Esperando tareas...");
    }
    ```

5.  Prueba: `cargo run`. Deberías ver el log de inicio.

## Paso 2: Crear el Dockerfile

Crea un archivo llamado `Dockerfile` en la raíz (sin extensión). Copia este contenido optimizado:

```dockerfile
# --- Etapa 1: Builder ---
FROM rust:1.75-alpine as builder

WORKDIR /app
# Instalar dependencias del sistema necesarias para compilar en Alpine
RUN apk add --no-cache musl-dev

# Truco para cachear dependencias:
# 1. Copiamos solo los manifiestos
COPY Cargo.toml Cargo.lock ./
# 2. Creamos un main dummy y compilamos
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
# 3. Borramos el dummy
RUN rm -rf src

# 4. Copiamos el código real y compilamos de verdad
COPY src ./src
# Forzamos touch para que cargo sepa que cambió
RUN touch src/main.rs
RUN cargo build --release

# --- Etapa 2: Runtime ---
FROM alpine:3.18

WORKDIR /app
# Copiamos solo el binario desde la etapa builder
COPY --from=builder /app/target/release/tl-engine .
COPY .env* ./ 

CMD ["./tl-engine"]
```

## Paso 3: Automatizar con Makefile

El proyecto ya tiene un `Makefile` con TODOs. Vamos a **agregar** comandos nuevos sin romper los existentes.

Abre el archivo `Makefile` y **agrega al final** (no reemplaces nada):

```makefile
# --- Engine Comandos (Rust) ---
run:
	cargo run

build:
	cargo build --release

docker-build:
	docker build -t tl-engine:latest .

docker-run:
	docker run --rm --env-file .env tl-engine:latest
```

**Nota**: Los comandos `make dev`, `make build` del Makefile original están como TODO. Estos nuevos comandos son específicos para Rust y no los sobrescriben.

## Paso 4: Prueba Final

1. **Prueba local primero**:
   ```bash
   make run
   # Deberías ver: "🚀 TL-Engine Iniciado correctamente"
   ```

2. **Construye la imagen Docker**:
   ```bash
   make docker-build
   ```
   Esto puede tardar varios minutos la primera vez (descarga dependencias de Rust).

3. **Si todo funciona**: ¡Felicidades! Tienes un servicio Rust empaquetado.

## 🔧 Troubleshooting

### Error: "cargo: command not found"
- **Solución**: Instala Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- Luego reinicia tu terminal o ejecuta: `source $HOME/.cargo/env`

### Error: "cargo init" dice que ya existe un proyecto
- **Solución**: Ya tienes un `Cargo.toml`. Salta al paso 3 y solo edita los archivos existentes.

### Error en Docker: "failed to solve: process ... did not complete successfully"
- **Causa común**: El Dockerfile tiene un error de sintaxis o falta una dependencia del sistema.
- **Solución**: Revisa que copiaste el Dockerfile completo. Verifica que `musl-dev` se instala correctamente en Alpine.

### La imagen Docker es muy pesada (>500MB)
- **Normal en la primera compilación**: Rust descarga muchas dependencias.
- **La imagen final debería ser <100MB** gracias al multistage build. Si no, revisa que el `COPY --from=builder` esté copiando solo el binario.
