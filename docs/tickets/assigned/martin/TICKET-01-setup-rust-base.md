# 🎫 Ticket Asignado: Setup Rust Base

**Asignado a**: Martin  
**Épica**: [01-setup-inicial-base](../../01-setup-inicial-base/)  
**Estimación**: 5 puntos  
**Prioridad**: Alta  
**Estado**: 🔴 Pendiente

---

## 📋 Objetivo

Crear una aplicación Rust básica pero profesional que:
- Compile y ejecute correctamente
- Esté empaquetada en una imagen Docker optimizada
- Pueda ejecutarse con comandos simples del Makefile

**Resultado esperado**: Al ejecutar `make run`, verás "🚀 TL-Engine Iniciado correctamente" en la terminal. Al ejecutar `make docker-build`, obtienes una imagen Docker funcional. De menos de 300MB.

---

## ✅ Definition of Done

Marca este ticket como completado cuando:

- [ ] Existe un archivo `Cargo.toml` en la raíz del proyecto con las dependencias correctas
- [ ] Existe un archivo `src/main.rs` que compila sin errores
- [ ] Al ejecutar `cargo run`, se imprime "🚀 TL-Engine Iniciado correctamente"
- [ ] Existe un `Dockerfile` en la raíz que usa multistage build
- [ ] Al ejecutar `make docker-build`, la imagen se construye exitosamente
- [ ] La imagen Docker final pesa menos de 100MB (verificar con `docker images | grep tl-engine`)
- [ ] El `Makefile` tiene los comandos `run`, `build`, `docker-build`, y `docker-run` funcionando

---

## 🎯 Instrucciones Paso a Paso

### Paso 1: Verificar Pre-requisitos

**Ubicación**: Raíz del proyecto (`/home/pango/projects/freelo/tiendaleon/tl-engine/`)

Ejecuta estos comandos para verificar que tienes las herramientas necesarias:

```bash
# Verificar Rust
cargo --version
# Si no está instalado: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Verificar Docker
docker --version
# Si no está instalado, instálalo según tu distribución Linux
```

**Criterio de éxito**: Ambos comandos muestran versiones instaladas.

---

### Paso 2: Inicializar Proyecto Rust

**Ubicación**: Raíz del proyecto

1. **Verifica si ya existe un proyecto Rust**:
   ```bash
   ls -la | grep Cargo.toml
   ```
   - Si **NO existe**: Continúa con el paso 2.2
   - Si **SÍ existe**: Salta al Paso 3 (solo editarás archivos existentes)

2. **Inicializa el proyecto** (solo si no existe):
   ```bash
   cargo init --bin --name tl-engine
   ```
   Esto crea:
   - `Cargo.toml` (archivo de configuración)
   - `src/main.rs` (código fuente)

**Criterio de éxito**: Existen los archivos `Cargo.toml` y `src/main.rs` en la raíz.

---

### Paso 3: Configurar Dependencias

**Archivo a editar**: `Cargo.toml`

Abre `Cargo.toml` y reemplázalo completamente con este contenido:

```toml
[package]
name = "tl-engine"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
dotenvy = "0.15"
tracing = "0.1"
tracing-subscriber = "0.3"
```

**Criterio de éxito**: El archivo `Cargo.toml` tiene exactamente este contenido.

---

### Paso 4: Crear el Código Principal

**Archivo a editar**: `src/main.rs`

Abre `src/main.rs` y reemplázalo completamente con este contenido:

```rust
use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

#[tokio::main]
async fn main() {
    // Configurar logs
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)
        .expect("setting default subscriber failed");

    info!("🚀 TL-Engine Iniciado correctamente");
    
    // Aquí iría el loop principal del servidor
    // Por ahora simulamos trabajo
    info!("Esperando tareas...");
}
```

**Criterio de éxito**: El archivo tiene exactamente este contenido.

---

### Paso 5: Probar Localmente

**Ubicación**: Raíz del proyecto

Ejecuta:

```bash
cargo run
```

**Salida esperada**:
```
🚀 TL-Engine Iniciado correctamente
Esperando tareas...
```

**Si hay errores**:
- Si dice "command not found": Instala Rust (ver Paso 1)
- Si hay errores de compilación: Verifica que copiaste el código exactamente como está arriba
- Si faltan dependencias: Ejecuta `cargo build` primero para descargar dependencias

**Criterio de éxito**: Ves el mensaje "🚀 TL-Engine Iniciado correctamente" sin errores.

---

### Paso 6: Crear Dockerfile

**Archivo a crear**: `Dockerfile` (en la raíz, sin extensión)

Crea un archivo llamado `Dockerfile` en la raíz del proyecto y copia este contenido exacto:

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

**Criterio de éxito**: El archivo `Dockerfile` existe en la raíz con este contenido exacto.

---

### Paso 7: Actualizar Makefile

**Archivo a editar**: `Makefile` (ya existe en la raíz)

Abre el `Makefile` y **agrega al final** (no reemplaces nada, solo agrega):

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

**Importante**: No borres el contenido existente del Makefile. Solo agrega estas líneas al final.

**Criterio de éxito**: El Makefile tiene el contenido original más estas nuevas líneas al final.

---

### Paso 8: Construir Imagen Docker

**Ubicación**: Raíz del proyecto

Ejecuta:

```bash
make docker-build
```

**Qué esperar**:
- La primera vez puede tomar un tiempo considerable (descarga dependencias de Rust)
- Verás muchas líneas de output de compilación
- Al final debería decir "Successfully tagged tl-engine:latest"

**Si hay errores**:
- "Docker daemon not running": Inicia Docker Desktop o el servicio Docker
- "failed to solve": Verifica que el Dockerfile está completo y sin errores de sintaxis
- Errores de compilación: Revisa que el código Rust compila localmente primero (`cargo build`)

**Criterio de éxito**: El comando termina con "Successfully tagged tl-engine:latest" sin errores.

---

### Paso 9: Verificar Tamaño de Imagen

Ejecuta:

```bash
docker images | grep tl-engine
```

**Salida esperada**:
```
tl-engine   latest   <hash>   <tiempo>   <tamaño>
```

**Criterio de éxito**: El tamaño debe ser menor a 100MB (idealmente ~20-50MB). Si es mayor a 200MB, revisa que el Dockerfile usa multistage build correctamente.

---

### Paso 10: Probar Imagen Docker

Ejecuta:

```bash
make docker-run
```

**Salida esperada**:
```
🚀 TL-Engine Iniciado correctamente
Esperando tareas...
```

**Nota**: Si no tienes un archivo `.env`, el comando puede fallar. Eso está bien por ahora, el objetivo es que la imagen funcione.

**Criterio de éxito**: Ves el mensaje "🚀 TL-Engine Iniciado correctamente" desde el contenedor Docker.

---

## 📚 Documentación de Referencia

Para entender el "por qué" de estas decisiones técnicas, consulta:

- **Conceptos**: [`../../01-setup-inicial-base/01-setup-rust/conceptos.md`](../../01-setup-inicial-base/01-setup-rust/conceptos.md)
- **Referencia técnica**: [`../../01-setup-inicial-base/01-setup-rust/referencia-tecnica.md`](../../01-setup-inicial-base/01-setup-rust/referencia-tecnica.md)

---

## 🔧 Troubleshooting

### Error: "cargo: command not found"
**Solución**: Instala Rust:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### Error: "cargo init" dice que ya existe un proyecto
**Solución**: Ya tienes un `Cargo.toml`. Salta al Paso 3 y solo edita los archivos existentes.

### Error en Docker: "failed to solve: process ... did not complete successfully"
**Causa común**: Error de sintaxis en Dockerfile o falta `musl-dev`.
**Solución**: 
1. Verifica que copiaste el Dockerfile completo
2. Asegúrate de que `apk add --no-cache musl-dev` está presente

### La imagen Docker es muy pesada (>500MB)
**Causa**: No se está usando multistage build correctamente.
**Solución**: Verifica que el Dockerfile tiene dos etapas (`FROM rust:... AS builder` y `FROM alpine:...`)

### `make docker-run` falla con "No such file or directory: .env"
**Solución**: Esto es normal si no tienes `.env`. El contenedor debería funcionar igual. Crea un `.env` vacío si quieres evitar el warning:
```bash
touch .env
```

---

## ✅ Checklist Final

Antes de marcar este ticket como completado, verifica:

- [ ] `cargo run` funciona y muestra el mensaje de inicio
- [ ] `make docker-build` construye la imagen exitosamente
- [ ] `docker images | grep tl-engine` muestra una imagen de menos de 100MB
- [ ] `make docker-run` ejecuta el contenedor y muestra el mensaje de inicio
- [ ] Todos los archivos están en la raíz del proyecto (no en subdirectorios)

---

## 📝 Notas

- **Estimación**: 5 puntos (considerando aprendizaje inicial en Rust/Docker)
- **Si te atascas**: Revisa la sección Troubleshooting o consulta la documentación de referencia
- **Próximo paso**: Una vez completado, el siguiente ticket será desplegar esto en Kubernetes local
