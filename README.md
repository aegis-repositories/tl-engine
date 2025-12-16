# tl-engine

**Engine remoto** que centraliza varios engines clave para la aplicación `tiendaleon` (un tracker).

## 🎯 ¿Qué es tl-engine?

`tl-engine` es un **engine remoto** que centraliza varios engines clave para la aplicación `tiendaleon` (un tracker). Este engine:
- ✅ Es llamado por otros programas (incluyendo `tl-plane`)
- ✅ Centraliza múltiples engines clave
- ✅ Funciona como un servicio remoto independiente

## 🏗️ Infraestructura

### Decisión Estratégica: Kubernetes desde el Día 1

Después de analizar Railway vs Kubernetes, se decidió:
- ✅ **Usar Kubernetes (K8s)** desde el inicio
- ✅ **Razón**: Escalabilidad futura (potencial de millones de requests/día)
- ✅ **Beneficio**: Evitar migración costosa más adelante

### Servicios Remotos Configurados

| Servicio | Proveedor | Estado | Uso |
|----------|-----------|--------|-----|
| **PostgreSQL** | Neon | ✅ Configurado | Base de datos principal (`enginedb`) |
| **Redis** | Upstash | ✅ Configurado | Cache, sesiones (prefijo `engine:*`) |
| **RabbitMQ** | CloudAMQP | ⚠️ Parcial | Message queue (vhost `/engine` o `/wmohtwtk`) |
| **S3 Storage** | Backblaze B2 | 📋 Pendiente | Almacenamiento de archivos |
| **PostHog** | PostHog Cloud | 📋 Pendiente | Analytics (1M eventos/mes gratis) |
| **Scout APM** | Scout APM | 📋 Pendiente | Performance monitoring |

## 📚 Documentación

La documentación completa está disponible en:

- **Infraestructura**: `docs/infra/` - Arquitectura, configuración, CI/CD
- **Técnica**: `docs/meta/` - Kubernetes, servicios, integraciones

Ver `RESUMEN_PROYECTO.md` para más detalles.

## 🛠️ Uso Rápido

```bash
# Ver ayuda
make help

# Desarrollo
make dev
make test-connections

# Deploy
make deploy-dev
make deploy-staging
```

## 📖 Documentos Clave

### Antes de Empezar
1. `docs/infra/vista-general.md` - Arquitectura general
2. `docs/meta/k8/ANALISIS_COMPLETO.md` - Entender K8s
3. `docs/meta/k8/PROTECCION_COSTOS.md` - Protección contra costos

## 📁 Estructura del Proyecto

```
tl-engine/
├── docs/
│   ├── infra/          # Documentación de infraestructura
│   └── meta/           # Documentación técnica de tecnologías
├── scripts/            # Scripts de utilidad
├── Makefile           # Comandos comunes
└── RESUMEN_PROYECTO.md # Resumen completo del proyecto
```

---

**¿Dudas?** Revisa la documentación en `docs/` o ejecuta `make help`
