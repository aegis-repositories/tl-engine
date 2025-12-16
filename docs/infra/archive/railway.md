# 🚂 Arquitectura en Railway - tl-engine

## 📊 Estructura de Proyectos en Railway

### **Opción 1: Proyecto Separado (Recomendado)**

```
Railway Dashboard
├── Proyecto: tl-plane
│   ├── Servicio: api (Django)
│   ├── Servicio: worker (Celery)
│   └── Servicio: beat-worker (Celery Beat)
│
└── Proyecto: tl-engine (NUEVO)
    ├── Servicio: engine-api (FastAPI/Django)
    ├── Servicio: engine-worker (Opcional)
    └── Servicio: engine-scheduler (Opcional)
```

**Ventajas:**
- ✅ Separación clara de proyectos
- ✅ Billing independiente
- ✅ Variables de entorno separadas
- ✅ Deploys independientes

---

### **Opción 2: Mismo Proyecto, Servicios Separados**

```
Railway Dashboard
└── Proyecto: tiendaleon
    ├── Servicio: tl-plane-api
    ├── Servicio: tl-plane-worker
    ├── Servicio: tl-engine-api (NUEVO)
    └── Servicio: tl-engine-worker (NUEVO)
```

**Ventajas:**
- ✅ Todo en un solo lugar
- ✅ Billing unificado
- ✅ Compartir recursos

**Desventajas:**
- ❌ Menos separación
- ❌ Variables mezcladas

---

## 🏗️ Arquitectura del Engine

### **Servicios Necesarios**

```
┌─────────────────────────────────────────┐
│         tl-engine (Railway)              │
├─────────────────────────────────────────┤
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  engine-api (FastAPI/Django)    │   │
│  │  - API REST principal           │   │
│  │  - Endpoints de engines          │   │
│  │  - Health checks                 │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  engine-worker (Opcional)       │   │
│  │  - Tareas asíncronas             │   │
│  │  - Procesamiento de datos        │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │  engine-scheduler (Opcional)     │   │
│  │  - Tareas programadas            │   │
│  │  - Cron jobs                    │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**¿Necesitas un servicio para cada cosa?**
- ❌ **NO** - Un solo servicio `engine-api` puede manejar todo
- ✅ **SÍ** - Si necesitas escalar workers o tareas programadas

---

## 🌍 Ambientes: Production y Staging

### **Configuración de Ambientes en Railway**

Railway permite múltiples **environments** dentro del mismo proyecto:

```
Proyecto: tl-engine
├── Environment: production
│   ├── Servicio: engine-api
│   └── Variables: DATABASE_URL, REDIS_URL, etc.
│
└── Environment: staging
    ├── Servicio: engine-api
    └── Variables: DATABASE_URL_STAGING, REDIS_URL_STAGING, etc.
```

**Cómo crear staging:**
1. En Railway Dashboard → Tu Proyecto
2. Click en "Environments" → "New Environment"
3. Nombre: `staging`
4. Configurar variables de entorno específicas

**Variables diferentes por ambiente:**
```bash
# Production
DATABASE_URL="postgresql://.../enginedb"
REDIS_URL="rediss://...production..."

# Staging
DATABASE_URL="postgresql://.../enginedb_staging"
REDIS_URL="rediss://...staging..."
```

---

## 💰 Billing y Límites en Railway

### **Planes de Railway**

**Hobby Plan (Gratis):**
- $5 crédito mensual
- 500 horas de uso
- Sin tarjeta requerida

**Developer Plan ($5/mes):**
- $5 crédito incluido
- Sin límite de horas
- Tarjeta requerida

**Pro Plan ($20/mes):**
- $20 crédito incluido
- Más recursos

### **Cómo Limitar Billing**

1. **Configurar Alertas:**
   - Railway Dashboard → Settings → Billing
   - Configurar alertas de uso

2. **Usar Variables de Entorno para Límites:**
   ```bash
   # En staging, limitar recursos
   GUNICORN_WORKERS=1  # Menos workers
   MAX_REQUESTS=1000   # Límite de requests
   ```

3. **Auto-pause en Staging:**
   - Railway puede pausar servicios inactivos
   - Ahorra créditos

4. **Monitorear Uso:**
   - Dashboard → Usage
   - Ver consumo en tiempo real

---

## 🔴 Redis: ¿Nos Falta?

### **Estado Actual:**

✅ **Redis YA está configurado:**
- **Proveedor**: Upstash (remoto)
- **URL**: `rediss://default:...@summary-dassie-38045.upstash.io:6379`
- **Estado**: ✅ Conectado y funcionando

### **Opciones:**

**Opción 1: Usar Upstash (Actual - Recomendado)**
- ✅ Ya configurado
- ✅ Tier gratuito generoso
- ✅ No consume créditos de Railway
- ✅ Compartir con tl-plane

**Opción 2: Railway Redis (Nuevo)**
- ✅ Integrado con Railway
- ✅ Variables automáticas
- ❌ Consume créditos de Railway
- ❌ Costo adicional

**Recomendación:** Mantener Upstash (ya funciona y es gratis)

---

## 📋 Estructura Recomendada para tl-engine

### **Proyecto Railway: `tl-engine`**

```
Proyecto: tl-engine
│
├── Environment: production
│   └── Servicio: engine-api
│       ├── Source: GitHub repo (tl-engine)
│       ├── Root: / (raíz del proyecto)
│       ├── Build Command: (según framework)
│       └── Start Command: (según framework)
│
└── Environment: staging
    └── Servicio: engine-api
        ├── Source: GitHub repo (tl-engine)
        ├── Root: / (raíz del proyecto)
        └── Variables: (diferentes a production)
```

### **Variables de Entorno por Ambiente**

**Production:**
```bash
DATABASE_URL="postgresql://.../enginedb"
REDIS_URL="rediss://...production..."
AMQP_URL="amqps://.../engine"
ENVIRONMENT="production"
DEBUG="0"
```

**Staging:**
```bash
DATABASE_URL="postgresql://.../enginedb_staging"
REDIS_URL="rediss://...staging..."
AMQP_URL="amqps://.../engine_staging"
ENVIRONMENT="staging"
DEBUG="1"
```

---

## 🚀 Pasos para Configurar en Railway

### **1. Crear Proyecto en Railway**

```bash
cd /home/pango/projects/freelo/tiendaleon/tl-engine
railway login
railway init
# Seleccionar: "Create a new project"
# Nombre: tl-engine
```

### **2. Crear Ambiente de Staging**

```bash
railway environment create staging
railway environment use staging
```

### **3. Configurar Variables de Entorno**

```bash
# Production
railway environment use production
railway variables set DATABASE_URL="..."
railway variables set REDIS_URL="..."
railway variables set AMQP_URL="..."

# Staging
railway environment use staging
railway variables set DATABASE_URL="..." # Staging DB
railway variables set REDIS_URL="..." # Staging Redis
railway variables set AMQP_URL="..." # Staging RabbitMQ
```

### **4. Conectar GitHub y Deploy**

```bash
railway link
railway up
```

---

## 📊 Comparación: tl-plane vs tl-engine

| Aspecto | tl-plane | tl-engine |
|---------|----------|-----------|
| **Proyecto Railway** | `tl-plane` | `tl-engine` (nuevo) |
| **Servicios** | api, worker, beat | engine-api (y opcionales) |
| **PostgreSQL** | `neondb` | `enginedb` |
| **Redis** | Upstash (compartido) | Upstash (compartido) |
| **RabbitMQ** | `/wmohtwtk` | `/engine` (o compartido) |
| **Ambientes** | production | production + staging |

---

## ✅ Checklist de Configuración

- [ ] Crear proyecto `tl-engine` en Railway
- [ ] Crear ambiente `staging`
- [ ] Configurar variables de entorno (production)
- [ ] Configurar variables de entorno (staging)
- [ ] Conectar GitHub repo
- [ ] Configurar build/start commands
- [ ] Configurar alertas de billing
- [ ] Hacer primer deploy

---

## 🎯 Resumen

**¿Armamos otro backend en Railway?**
✅ **SÍ** - Nuevo proyecto `tl-engine` con servicio `engine-api`

**¿Una API de engine y una cosa para cada servicio?**
✅ **API principal**: `engine-api` (puede manejar todo)
⚠️ **Workers opcionales**: Solo si necesitas tareas asíncronas

**¿Podemos armar ambiente de stage y limitar billing?**
✅ **SÍ** - Railway soporta múltiples environments
✅ **SÍ** - Configurar alertas y límites de uso

**¿Nos falta Redis?**
❌ **NO** - Ya está configurado (Upstash)
✅ **Opcional**: Railway Redis si prefieres integración nativa

