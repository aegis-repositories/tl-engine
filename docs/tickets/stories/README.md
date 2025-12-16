# 📖 User Stories

Este directorio contiene las historias de usuario (user stories) que describen las necesidades del negocio y los requisitos funcionales del proyecto.

## Estructura de una Story

Cada story sigue el formato estándar:

```
Como [rol]
Quiero [acción/feature]
Para [beneficio/valor]
```

Además, cada story incluye:
- **Criterios de Aceptación**: Condiciones que deben cumplirse para considerar la story completa
- **Especialidades Requeridas**: Habilidades técnicas necesarias para resolverla
- **Estimación**: Puntos de Fibonacci
- **Dependencias**: Otras stories o tickets que deben completarse primero

## Relación con Tickets

Las stories describen el **qué** y el **por qué** desde la perspectiva del negocio/usuario.

Los tickets asignados (`assigned/`) describen el **cómo** técnico paso a paso.

## Stories Disponibles

| ID | Story | Especialidades | Puntos | Estado |
|----|-------|----------------|--------|--------|
| **ST-01** | [Aplicación Rust Base](./ST-01-aplicacion-rust-base.md) | Rust, Docker | 5 | 🔴 Pendiente |
| **ST-02** | [Infraestructura K8s Local](./ST-02-infraestructura-k8s-local.md) | Kubernetes, Docker | 8 | 🔴 Pendiente |
| **ST-03** | [Observabilidad con PostHog](./ST-03-observabilidad-posthog.md) | Rust, APIs REST | 3 | 🔴 Pendiente |
| **ST-04** | [Gestión Segura de Secretos](./ST-04-gestion-segura-secretos.md) | Kubernetes, Seguridad | 2 | 🔴 Pendiente |
