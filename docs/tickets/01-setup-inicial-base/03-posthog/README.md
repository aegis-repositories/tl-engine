# 🎫 Ticket 03: Integración con PostHog

**Objetivo**: Dejar de volar a ciegas. Vamos a conectar la app para que envíe señales a un tablero externo (PostHog) cada vez que haga algo importante.

## ✅ Checklist
- [ ] **Credenciales**: Tienes `POSTHOG_API_KEY` y `POSTHOG_HOST` en tu `.env`.
- [ ] **Código**: Tu Rust envía un evento al iniciar.
- [ ] **Dashboard**: Entras a la web de PostHog y ves el evento "engine_start".

## 📂 Archivos
1. [que-es-posthog.md](./que-es-posthog.md): **LÉEME PRIMERO**. Diferencia entre logs y eventos, qué es PostHog, arquitectura de integración, tipos de eventos, y comparación con alternativas.
2. [implementacion.md](./implementacion.md): Cómo obtener credenciales, agregar dependencias, implementar el código, y configurar Kubernetes.
