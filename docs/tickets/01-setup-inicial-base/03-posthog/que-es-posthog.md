# 🧠 PostHog: Analytics y Observabilidad de Eventos

## Diferencia entre Logs y Eventos

### Logs (Tracing/Logging)
Los logs son mensajes de texto que el código imprime durante su ejecución:
- **Propósito**: Debugging, troubleshooting, auditoría.
- **Formato**: Texto plano, estructurado (JSON), o binario.
- **Ejemplos**: "Error en línea 45", "Conexión a DB falló", "Request recibido: GET /api/users".

**Características**:
- Alto volumen (miles de líneas por minuto).
- Se almacenan en archivos o sistemas centralizados (Loki, ELK).
- Difíciles de agregar y visualizar en tiempo real.
- Útiles para desarrolladores, no para stakeholders de negocio.

### Eventos (Event Tracking)
Los eventos son ocurrencias discretas de acciones de negocio o métricas:
- **Propósito**: Analizar comportamiento, métricas de negocio, monitoreo de alto nivel.
- **Formato**: Estructurado (JSON) con propiedades clave-valor.
- **Ejemplos**: "pedido_creado" con `{monto: 100, usuario_id: 123}`, "usuario_login", "engine_started".

**Características**:
- Volumen más bajo (cientos o miles por hora, no por segundo).
- Se almacenan en bases de datos optimizadas para queries (PostgreSQL, ClickHouse).
- Fáciles de agregar, filtrar, y visualizar en dashboards.
- Útiles para product managers, analistas, y stakeholders.

## ¿Qué es PostHog?

PostHog es una plataforma open-source de product analytics y feature flags. Proporciona:
- **Event tracking**: Captura eventos desde tu aplicación (web, mobile, backend).
- **Dashboards**: Visualiza métricas agregadas (conversión, retención, funnels).
- **Session replay**: Graba sesiones de usuarios (solo para frontend).
- **Feature flags**: Activa/desactiva features sin deploy.

**Para este proyecto**: Usamos PostHog Cloud (SaaS) para evitar mantener infraestructura propia. El tier gratuito permite 1 millón de eventos/mes.

## Arquitectura de Integración

```
┌─────────────┐
│  tl-engine  │  (Rust backend)
│  (Rust)     │
└──────┬──────┘
       │ HTTP POST
       │ {event: "engine_started", properties: {...}}
       ▼
┌─────────────┐
│  PostHog    │  (Cloud, us.posthog.com)
│  API        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Dashboard  │  (Web UI para visualizar)
└─────────────┘
```

**Flujo**:
1. Tu código Rust envía un evento vía HTTP POST a la API de PostHog.
2. PostHog valida y almacena el evento.
3. Puedes ver el evento en el dashboard web de PostHog en tiempo real.

## Tipos de Eventos

### Eventos de Sistema
Eventos que indican el estado interno de la aplicación:
- `engine_started`: El servicio inició correctamente.
- `engine_stopped`: El servicio se detuvo.
- `health_check`: Verificación periódica de salud.

### Eventos de Negocio
Eventos que representan acciones de usuarios o procesos de negocio:
- `pedido_procesado`: Un pedido fue procesado exitosamente.
- `pago_completado`: Un pago fue procesado.
- `error_critico`: Un error que requiere atención.

### Eventos de Métricas
Eventos que miden rendimiento o uso:
- `request_processed`: Tiempo de procesamiento de una request.
- `cache_hit`: Cache fue exitoso.
- `db_query_slow`: Query a base de datos tomó >1 segundo.

## Propiedades de Eventos

Cada evento puede tener propiedades (metadata):

```json
{
  "event": "engine_started",
  "properties": {
    "version": "0.1.0",
    "environment": "dev",
    "timestamp": "2025-12-16T10:00:00Z",
    "host": "pod-xyz"
  }
}
```

**Uso de propiedades**:
- Filtrar eventos: "Mostrar solo eventos de `environment: prod`".
- Agregar métricas: "Contar eventos agrupados por `version`".
- Debugging: "Mostrar todos los eventos donde `host: pod-xyz`".

## PostHog vs Alternativas

| Herramienta | Tipo | Costo | Uso |
|------------|------|-------|-----|
| **PostHog** | SaaS/OSS | Gratis hasta 1M eventos/mes | Analytics general, feature flags |
| **Mixpanel** | SaaS | ~$25/mes | Analytics avanzado, más features |
| **Amplitude** | SaaS | ~$50/mes | Product analytics, más escalable |
| **Google Analytics** | SaaS | Gratis | Solo frontend, no backend |
| **Grafana + Prometheus** | Self-hosted | Infraestructura propia | Métricas técnicas, no eventos de negocio |

**Por qué PostHog para este proyecto**:
- Tier gratuito generoso (1M eventos/mes es suficiente para empezar).
- Fácil integración desde backend (API REST simple).
- Open-source: puedes migrar a self-hosted si creces.
- Feature flags incluidos (útil para A/B testing más adelante).

## Integración en Rust

PostHog no tiene un SDK oficial para Rust. Opciones:

1. **Cliente HTTP genérico** (`reqwest`): Hacer POST manual a la API.
2. **Librería no oficial** (`posthog-rs` si existe): Wrapper alrededor de HTTP.
3. **Envío asíncrono**: Usar un channel para enviar eventos en background sin bloquear el código principal.

**Recomendación**: Empezar con `reqwest` para control total. Si el volumen crece, considerar un worker dedicado que envíe eventos en batch.
