# ⚡ Quick Start - Flujo Visual

```
📁 docs/tickets/01-setup-inicial-base/
│
├── 📄 README.md  ← EMPIEZA AQUÍ (lee este primero)
│
├── 📁 01-setup-rust/
│   ├── README.md          → Objetivo: App Rust + Docker
│   ├── conceptos.md       → ¿Por qué Rust? ¿Qué es multistage?
│   └── guia-tecnica.md    → Comandos paso a paso
│
├── 📁 02-k8s-local/
│   ├── README.md          → Objetivo: Cluster K8s local
│   ├── conceptos-k8s.md   → Pod, Deployment, Service (3 conceptos)
│   ├── setup-cluster.md   → Instalar kind y crear cluster
│   └── manifiestos.md     → YAML para desplegar tu app
│
├── 📁 03-posthog/
│   ├── README.md          → Objetivo: Integrar métricas
│   ├── que-es-posthog.md  → ¿Por qué no solo logs?
│   └── implementacion.md  → Código Rust + configuración
│
└── 📁 04-secretos/
    ├── README.md          → Objetivo: Ordenar las llaves
    └── seguridad-basica.md → Kubernetes Secrets
```

## 🎯 Orden de Ejecución

1. **Ticket 01**: Crea la app Rust y su Dockerfile
2. **Ticket 02**: Levanta K8s local y despliega la app
3. **Ticket 03**: Conecta PostHog para ver métricas
4. **Ticket 04**: Mueve las claves a Secrets (seguridad)

**Tiempo estimado**: 2-4 horas si es tu primera vez con estas tecnologías.

## 📋 Tickets Asignados

Los tickets específicos asignados a desarrolladores están en `docs/tickets/assigned/`.

Cada ticket contiene instrucciones precisas y ejecutables para completar una parte específica de esta épica.
