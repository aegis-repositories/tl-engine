# 🛠 Implementando PostHog en Rust

## 1. Obtener Credenciales
Entra a [us.posthog.com](https://us.posthog.com) (o eu.posthog.com).
1. Crea una cuenta gratuita.
2. Crea un proyecto "TiendaLeon Engine".
3. Ve a Settings -> Project API Key. Copia esa llave.
4. El host suele ser `https://app.posthog.com` o `https://us.i.posthog.com`.

Ponlas en tu `.env`:
```bash
POSTHOG_API_KEY=phc_TU_CLAVE_AQUI
POSTHOG_HOST=https://us.i.posthog.com
```

## 2. Agregar Dependencia
En `Cargo.toml`, agrega esta línea en la sección `[dependencies]`:

```toml
[dependencies]
# ... las anteriores ...
posthog-rs = "0.2" # Verifica la versión más reciente en crates.io
```

**Nota**: Si `posthog-rs` no existe o la versión es diferente, puedes usar un cliente HTTP genérico. Alternativa simple con `reqwest`:

```toml
reqwest = { version = "0.11", features = ["json"] }
```

Y luego envías eventos manualmente con HTTP POST. Pero primero intenta con `posthog-rs`.

## 3. Código
En `src/main.rs`:

```rust
use posthog_rs::ClientOptions;

// ... dentro de main ...

let api_key = std::env::var("POSTHOG_API_KEY").expect("POSTHOG_API_KEY no definida");
let host = std::env::var("POSTHOG_HOST").unwrap_or("https://app.posthog.com".to_string());

let client = posthog_rs::client(ClientOptions {
    api_key,
    host,
    ..Default::default()
});

// Enviar evento
let _ = client.capture("engine_started", "sistema_interno")
    .send()
    .await;

info!("📡 Evento PostHog enviado");
```

## 4. Configurar K8s (Crucial)
Para que esto funcione en Kubernetes (Ticket 02), tu Pod necesita las variables.
Edita `k8s/local/engine.yaml` y agrega:

```yaml
        env:
        - name: POSTHOG_API_KEY
          value: "phc_TU_CLAVE..." # (En el futuro usaremos Secrets, por ahora está bien aquí para probar local)
        - name: POSTHOG_HOST
          value: "https://us.i.posthog.com"
```

Re-aplica: `kubectl apply -f k8s/local/engine.yaml`
Reinicia el pod (borrándolo): `kubectl delete pod -l app=tl-engine` (K8s creará uno nuevo automáticamente).

## 🔧 Troubleshooting

### Error: "failed to resolve: posthog-rs"
- **Causa**: La librería `posthog-rs` puede no existir o tener otro nombre.
- **Solución alternativa**: Usa `reqwest` para hacer HTTP POST manualmente. Ejemplo:
  ```rust
  use reqwest;
  
  let client = reqwest::Client::new();
  let _ = client.post(format!("{}/capture/", host))
      .header("Content-Type", "application/json")
      .json(&serde_json::json!({
          "api_key": api_key,
          "event": "engine_started",
          "distinct_id": "sistema_interno"
      }))
      .send()
      .await;
  ```

### No veo eventos en PostHog
- **Verifica**: Revisa los logs del pod: `kubectl logs -l app=tl-engine`
- **Causa común**: La API key es incorrecta o el host está mal.
- **Debug**: Agrega un `println!` temporal para ver qué valores tiene tu código.
