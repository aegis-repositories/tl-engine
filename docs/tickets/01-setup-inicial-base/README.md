# 🎯 Épica: Setup Inicial Base

## Descripción

Esta épica establece la base técnica del proyecto `tl-engine`: una aplicación Rust contenerizada que corre en Kubernetes local, con integración básica de observabilidad (PostHog) y gestión segura de secretos.

## Objetivos de la Épica

1. **Aplicación Rust base**: Crear el esqueleto de la aplicación con estructura profesional y Dockerfile optimizado.
2. **Infraestructura Kubernetes local**: Configurar un cluster local (kind) y desplegar la aplicación.
3. **Observabilidad básica**: Integrar PostHog para tracking de eventos desde el inicio.
4. **Gestión de secretos**: Implementar Kubernetes Secrets para credenciales.

## Alcance

- ✅ Aplicación Rust que compila y corre localmente
- ✅ Imagen Docker optimizada (multistage build)
- ✅ Cluster Kubernetes local funcionando
- ✅ Aplicación desplegada en K8s
- ✅ PostHog integrado y enviando eventos
- ✅ Secretos gestionados correctamente en K8s

## Documentación Disponible

Esta épica contiene documentación técnica completa:

- **Conceptos**: Explicaciones técnicas de Rust, Docker, Kubernetes, PostHog
- **Guías técnicas**: Pasos detallados para implementar cada componente
- **Referencias**: Análisis línea por línea, comandos avanzados, troubleshooting

## Estructura

```
01-setup-inicial-base/
├── README.md (este archivo)
├── 01-setup-rust/        # Aplicación Rust base
├── 02-k8s-local/        # Infraestructura Kubernetes
├── 03-posthog/          # Integración PostHog
└── 04-secretos/         # Gestión de secretos
```

## Tickets Asignados

Los tickets específicos asignados a desarrolladores se encuentran en `docs/tickets/assigned/`.

Cada ticket asignado referencia esta épica y contiene instrucciones precisas y ejecutables para completar una parte específica del trabajo.
