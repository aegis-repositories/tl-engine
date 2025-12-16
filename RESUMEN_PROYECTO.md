# 📋 Resumen del Proyecto tl-engine

**Última actualización**: $(date +"%Y-%m-%d")

---

## 🎯 ¿Qué es tl-engine?

`tl-engine` es un **engine remoto** que centraliza varios engines clave para la aplicación `tiendaleon` (un tracker). Este engine:
- ✅ Es llamado por otros programas (incluyendo `tl-plane`)
- ✅ Centraliza múltiples engines clave
- ✅ Funciona como un servicio remoto independiente

---

## 🏗️ Infraestructura Definida

### **Decisión Estratégica: Kubernetes desde el Día 1**

Después de analizar Railway vs Kubernetes, se decidió:
- ✅ **Usar Kubernetes (K8s)** desde el inicio
- ✅ **Razón**: Escalabilidad futura (potencial de millones de requests/día)
- ✅ **Beneficio**: Evitar migración costosa más adelante

### **Servicios Remotos Configurados**

| Servicio | Proveedor | Estado | Uso |
|----------|-----------|--------|-----|
| **PostgreSQL** | Neon | ✅ Configurado | Base de datos principal (`enginedb`) |
| **Redis** | Upstash | ✅ Configurado | Cache, sesiones (prefijo `engine:*`) |
| **RabbitMQ** | CloudAMQP | ⚠️ Parcial | Message queue (vhost `/engine` o `/wmohtwtk`) |
| **S3 Storage** | Backblaze B2 | 📋 Pendiente | Almacenamiento de archivos |
| **PostHog** | PostHog Cloud | 📋 Pendiente | Analytics (1M eventos/mes gratis) |
| **Scout APM** | Scout APM | 📋 Pendiente | Performance monitoring |

### **Ambientes Configurados**

- ✅ **dev** (development) - Por defecto
- ✅ **staging** (staging)
- ❌ **prod** - Eliminado (solo dev y staging)

---

## 📚 Documentación Creada

### **1. Infraestructura General** (`docs/infra/`)

#### **Vista General**
- `vista-general.md` - Arquitectura completa con diagramas Mermaid
- `README.md` - Índice de documentación de infraestructura

#### **Configuración**
- `configuracion.md` - Estado de conexiones y configuración
- `k8s.md` - Arquitectura en Kubernetes
- `servicios.md` - Detalles de servicios remotos

#### **Integraciones**
- `integraciones/servicios-remotos.md` - PostgreSQL, Redis, RabbitMQ, S3
- `integraciones/sistemas-externos.md` - APIs entrantes/salientes
- `integraciones/monitoreo.md` - PostHog, Scout APM, logging

#### **CI/CD**
- `ci-cd.md` - Pipeline de despliegue

### **2. Documentación Técnica** (`docs/meta/`)

#### **Kubernetes (K8s)** ⭐ **CRÍTICO**
- `k8/ANALISIS_COMPLETO.md` - ⚠️ **LEER PRIMERO**
  - Qué trae K8s
  - Pitfalls comunes
  - Mantenimiento requerido
  - Automatizaciones
  - Cómo escala
  
- `k8/PROTECCION_COSTOS.md` - 🛡️ **CRÍTICO**
  - Cómo evitar costos impagables
  - Resource Quotas
  - Limit Ranges
  - HPA con límites
  - Alertas de presupuesto
  - Kubecost

- `k8/postgresql.md` - K8s + PostgreSQL
- `k8/redis.md` - K8s + Redis
- `k8/rabbitmq.md` - K8s + RabbitMQ
- `k8/engine-api.md` - Deploy de Engine API
- `k8/engine-worker.md` - Deploy de Engine Workers

#### **Servicios**
- `rabbitmq/` - Configuración y uso de RabbitMQ
- `postgresql/README.md` - PostgreSQL
- `redis/README.md` - Redis
- `posthog.md` - PostHog completo (analytics, integración, eventos)

#### **Integraciones Futuras** ⭐
- `integraciones-futuras.md` - Herramientas para escalar y reducir costos:
  - PostHog (analytics)
  - Kubecost (monitoreo de costos)
  - KEDA (event-driven autoscaling)
  - Prometheus + Grafana (observabilidad)
  - Loki (logging centralizado)
  - ArgoCD (GitOps)
  - Falco (seguridad runtime)

---

## 🛠️ Scripts y Herramientas

### **Scripts Creados**

1. **`scripts/install-clis.sh`**
   - Instala CLIs: PostgreSQL, Redis, RabbitMQ
   - Detecta si ya están instalados

2. **`scripts/test-connections.sh`**
   - Prueba conexiones a servicios remotos
   - Verifica: PostgreSQL, Redis, RabbitMQ, PostHog, Scout APM

### **Makefile**

Comandos principales:
```bash
make dev              # Iniciar servidor de desarrollo
make deploy-dev       # Deploy a development (default)
make deploy-staging   # Deploy a staging
make test-connections # Probar conexiones
```

---

## 🔧 Estado Actual de Configuración

### ✅ **Completado**

1. **CLIs Instalados**
   - ✅ PostgreSQL CLI (`psql`)
   - ✅ Redis CLI (`redis-cli`)
   - ✅ RabbitMQ CLI (`rabbitmqadmin`)

2. **Base de Datos**
   - ✅ Base de datos `enginedb` creada en Neon
   - ✅ Conexión verificada

3. **Redis**
   - ✅ Conexión verificada
   - ✅ Prefijo `engine:*` definido

4. **RabbitMQ**
   - ⚠️ VHost `/engine` pendiente de crear en CloudAMQP
   - ✅ Usando temporalmente `/wmohtwtk` (compartido con tl-plane)

5. **Documentación**
   - ✅ Arquitectura completa documentada
   - ✅ Guías de K8s creadas
   - ✅ Integraciones futuras planificadas

### 📋 **Pendiente**

1. **Configuración**
   - [ ] Crear archivo `.env` (copiar de `.env.example`)
   - [ ] Crear vhost `/engine` en CloudAMQP
   - [ ] Configurar PostHog (obtener API key)
   - [ ] Configurar Scout APM (obtener API key)

2. **Implementación**
   - [ ] Decidir lenguaje/framework (Rust, Python, etc.)
   - [ ] Crear aplicación base
   - [ ] Integrar con servicios remotos
   - [ ] Implementar workers para RabbitMQ
   - [ ] Configurar monitoreo (PostHog, Scout APM)

3. **Kubernetes**
   - [ ] Crear cluster K8s (GKE, EKS, o local con Minikube)
   - [ ] Crear manifests de K8s
   - [ ] Configurar Resource Quotas y Limit Ranges
   - [ ] Configurar HPA
   - [ ] Instalar Kubecost

---

## 💰 Costos Estimados

### **Servicios Remotos (Mensual)**

| Servicio | Costo | Notas |
|----------|-------|-------|
| PostgreSQL (Neon) | $0-19/mes | Tier gratuito generoso |
| Redis (Upstash) | $0-10/mes | Tier gratuito |
| RabbitMQ (CloudAMQP) | $0-20/mes | Tier gratuito limitado |
| S3 (Backblaze B2) | ~$5/mes | Depende de uso |
| PostHog | $0/mes | 1M eventos/mes gratis |
| Scout APM | ~$20/mes | Depende del plan |
| **Total** | **~$25-74/mes** | Inicio |

### **Kubernetes (Cuando se despliegue)**

- **GKE/EKS**: ~$70-150/mes (cluster básico)
- **Kubecost**: $0 (open-source) o $199/mes (Cloud)
- **Herramientas adicionales**: $0-100/mes (almacenamiento)

---

## 🚀 Próximos Pasos Recomendados

### **Fase 1: Configuración Inicial (1-2 días)**

1. Crear archivo `.env` con credenciales
2. Crear vhost `/engine` en CloudAMQP
3. Probar todas las conexiones: `make test-connections`
4. Configurar PostHog y Scout APM

### **Fase 2: Aplicación Base (3-5 días)**

1. Decidir lenguaje/framework
2. Crear estructura de proyecto
3. Integrar con PostgreSQL, Redis, RabbitMQ
4. Implementar API básica
5. Implementar workers básicos

### **Fase 3: Kubernetes (5-7 días)**

1. Configurar cluster K8s (local o cloud)
2. Crear manifests (Deployments, Services, Ingress)
3. Configurar Resource Quotas y Limit Ranges
4. Instalar Kubecost
5. Configurar HPA

### **Fase 4: Monitoreo y Observabilidad (2-3 días)**

1. Integrar PostHog
2. Integrar Scout APM
3. Configurar logging estructurado
4. Crear dashboards básicos

---

## 📖 Documentos Clave para Leer

### **Antes de Empezar**
1. `docs/infra/vista-general.md` - Arquitectura general
2. `docs/meta/k8/ANALISIS_COMPLETO.md` - Entender K8s
3. `docs/meta/k8/PROTECCION_COSTOS.md` - Protección contra costos

### **Durante Desarrollo**
1. `docs/infra/integraciones/servicios-remotos.md` - Cómo usar servicios
2. `docs/meta/rabbitmq/uso-aplicacion.md` - Cómo usar RabbitMQ
3. `docs/meta/posthog.md` - Cómo integrar PostHog

### **Para Escalar**
1. `docs/meta/integraciones-futuras.md` - Herramientas adicionales
2. `docs/meta/k8/engine-api.md` - Deploy de API
3. `docs/meta/k8/engine-worker.md` - Deploy de workers

---

## 🎯 Decisiones Clave Tomadas

1. ✅ **Kubernetes desde día 1** (no Railway)
2. ✅ **Ambiente por defecto: dev** (no prod)
3. ✅ **Compartir servicios con tl-plane** (PostgreSQL separado, Redis/RabbitMQ compartidos)
4. ✅ **PostHog Cloud** (no self-hosted en K8s)
5. ✅ **Documentación exhaustiva** antes de implementar

---

## 📞 Comandos Útiles

```bash
# Ver ayuda
make help

# Desarrollo
make dev
make test-connections

# Deploy
make deploy-dev
make deploy-staging

# Ver documentación
cat docs/infra/vista-general.md
cat docs/meta/k8/ANALISIS_COMPLETO.md
```

---

## 📁 Estructura del Proyecto

```
tl-engine/
├── docs/
│   ├── infra/          # Documentación de infraestructura
│   └── meta/           # Documentación técnica de tecnologías
├── scripts/            # Scripts de utilidad
├── Makefile           # Comandos comunes
└── .env.example       # Template de variables de entorno
```

---

**¿Dudas?** Revisa la documentación en `docs/` o ejecuta `make help`


