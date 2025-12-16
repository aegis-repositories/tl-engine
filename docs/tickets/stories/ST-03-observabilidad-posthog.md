# 📖 Story ST-03: Observabilidad con PostHog

## Descripción

**Como** desarrollador y stakeholder del proyecto  
**Quiero** que la aplicación envíe eventos a PostHog  
**Para** poder monitorear el estado de la aplicación, rastrear métricas de negocio, y tener visibilidad sobre el comportamiento del sistema

## Contexto

Desde el inicio necesitamos observabilidad. PostHog nos permite:
- Ver cuándo la aplicación inicia y se detiene
- Rastrear eventos de negocio futuros (pedidos, pagos, etc.)
- Crear dashboards para stakeholders
- Detectar problemas antes de que afecten a usuarios

## Criterios de Aceptación

- [ ] La aplicación tiene credenciales de PostHog configuradas (API key y host)
- [ ] La aplicación envía un evento `engine_started` al iniciar
- [ ] El evento aparece en el dashboard de PostHog
- [ ] Las credenciales están configuradas en Kubernetes (variables de entorno)
- [ ] Si PostHog no está disponible, la aplicación no crashea (manejo de errores silencioso)
- [ ] Los logs de la aplicación confirman que el evento fue enviado

## Especialidades Requeridas

Para completar esta story, se requiere conocimiento en:

- **Rust (Intermedio)**: Async/await, manejo de errores, HTTP clients
- **APIs REST (Básico)**: Entender cómo hacer POST requests, headers, JSON payloads
- **PostHog (Básico)**: Crear cuenta, obtener API key, entender el formato de eventos
- **Variables de Entorno (Básico)**: Leer variables de entorno en Rust, configurar en Kubernetes
- **HTTP Clients en Rust (Básico)**: Usar `reqwest` o librería similar para hacer requests

**Nivel de experiencia recomendado**:
- Rust: Intermedio (async, error handling)
- APIs REST: Básico (solo hacer POST requests)
- PostHog: Básico (solo crear cuenta y obtener key)
- Variables de entorno: Básico (std::env::var)

## Estimación

**3 puntos** (Fibonacci)

**Justificación**:
- Obtener credenciales de PostHog: 1 punto
- Integrar cliente HTTP en Rust: 1 punto
- Configurar variables de entorno en K8s: 1 punto

## Dependencias

- **ST-01**: Aplicación Rust Base (necesitamos código base)
- **ST-02**: Infraestructura K8s Local (necesitamos cluster para configurar variables)

## Tickets Relacionados

- `assigned/martin/TICKET-03-posthog.md` (a crear)

## Épica Relacionada

- [`01-setup-inicial-base/`](../01-setup-inicial-base/)

## Notas Técnicas

- PostHog no tiene SDK oficial para Rust, usamos `reqwest` para HTTP POST manual
- El evento se envía de forma asíncrona para no bloquear el inicio de la aplicación
- Las credenciales se leen de variables de entorno (por ahora hardcodeadas en YAML, luego Secrets)
- El formato del evento sigue la API de PostHog: `{event: "engine_started", properties: {...}}`
- Se usa el tier gratuito de PostHog Cloud (1M eventos/mes)
