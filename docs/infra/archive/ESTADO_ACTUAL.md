# 📊 Estado Actual de la Infraestructura - tl-engine

**Fecha**: $(date +"%Y-%m-%d")

## ✅ CLIs Instalados y Listos

### **PostgreSQL** 🗄️
- ✅ **Instalado**: PostgreSQL 18.1
- 📍 **Ubicación**: `/usr/sbin/psql`
- 🔧 **Estado**: Listo para usar
- 💡 **Uso**: Conectar a bases de datos remotas (Neon, Supabase, etc.)

### **Redis** ⚡
- ✅ **Instalado**: valkey-cli 8.1.4
- 📍 **Ubicación**: `/usr/sbin/redis-cli`
- 🔧 **Estado**: Listo para usar
- 💡 **Uso**: Conectar a Redis remoto (Upstash, Railway, etc.)

### **RabbitMQ** 🐰
- ✅ **Instalado**: RabbitMQ 4.2.1
- 📍 **Ubicación**: 
  - `/usr/sbin/rabbitmqctl` (requiere permisos para uso local)
  - `~/.local/bin/rabbitmqadmin` (para servicios remotos)
- 🔧 **Estado**: Listo para usar con servicios remotos
- 💡 **Uso**: Conectar a RabbitMQ remoto (CloudAMQP, Railway, etc.)

### **Railway CLI** 🚂
- ✅ **Instalado**: Railway CLI
- 📍 **Ubicación**: `~/.local/bin/railway`
- 🔧 **Estado**: Listo para usar
- 💡 **Uso**: Gestión de proyectos y despliegues en Railway

### **Vercel CLI** ▲
- ✅ **Instalado**: Vercel CLI
- 📍 **Ubicación**: `~/.local/bin/vercel`
- 🔧 **Estado**: Listo para usar
- 💡 **Uso**: Gestión de proyectos y despliegues en Vercel

---

## 📋 Próximos Pasos

### 1. **Configurar Variables de Entorno**
Crear archivo `.env` con las credenciales de servicios remotos:

```bash
# PostgreSQL (Neon)
DATABASE_URL="postgresql://user:pass@host:5432/dbname?sslmode=require"

# Redis (Upstash)
REDIS_URL="rediss://default:password@host:6379"

# RabbitMQ (CloudAMQP)
AMQP_URL="amqps://user:pass@host:port/vhost"

# PostHog (Opcional)
POSTHOG_API_KEY="your-api-key"
POSTHOG_HOST="https://app.posthog.com"

# Scout APM (Opcional)
SCOUT_KEY="your-scout-key"
```

### 2. **Probar Conexiones**
Ejecutar el script de prueba:

```bash
./scripts/test-connections.sh
```

### 3. **Servicios Remotos a Configurar**

#### **Críticos (Necesarios)**
- [ ] **PostgreSQL**: Crear proyecto en Neon/Supabase
- [ ] **Redis**: Crear database en Upstash
- [ ] **RabbitMQ**: Crear instancia en CloudAMQP

#### **Recomendados (Opcionales)**
- [ ] **PostHog**: Crear cuenta y proyecto
- [ ] **Scout APM**: Crear cuenta y proyecto

---

## 🔗 Servicios de tl-plane (Referencia)

### **PostgreSQL**
- **Proveedor**: Neon
- **URL**: `postgresql://neondb_owner:...@ep-dark-smoke-adnyibbf-pooler.c-2.us-east-1.aws.neon.tech/neondb`

### **Redis**
- **Proveedor**: Upstash
- **URL**: `rediss://default:...@summary-dassie-38045.upstash.io:6379`

### **RabbitMQ**
- **Proveedor**: CloudAMQP
- **URL**: `amqps://wmohtwtk:...@jaragua.lmq.cloudamqp.com/wmohtwtk`

### **Storage S3**
- **Proveedor**: Backblaze B2
- **Bucket**: `tl-plane`
- **Endpoint**: `https://s3.us-east-005.backblazeb2.com`

---

## 💡 Recomendaciones

### **Compartir vs Separar**

1. **PostgreSQL**: 
   - ✅ **Separar** - Crear base de datos diferente en misma instancia Neon
   - 💰 **Costo**: $0 (tier gratuito generoso)

2. **Redis**: 
   - ✅ **Compartir** - Usar prefijos diferentes (`plane:*` y `engine:*`)
   - 💰 **Costo**: $0 (tier gratuito)

3. **RabbitMQ**: 
   - ✅ **Compartir** - Usar vhosts diferentes (`/plane` y `/engine`)
   - 💰 **Costo**: $0-20/mes (tier gratuito limitado)

### **Estructura de VHosts en RabbitMQ**

```
/plane          → tl-plane (existente)
/engine         → tl-engine (nuevo)
```

### **Estructura de Bases de Datos en PostgreSQL**

```
neondb          → tl-plane (existente)
enginedb        → tl-engine (nuevo)
```

O instancias completamente separadas si prefieres más aislamiento.

---

## 🛠️ Scripts Disponibles

1. **`scripts/install-clis.sh`** - Instalación de CLIs (ya no necesario, todo instalado)
2. **`scripts/test-connections.sh`** - Probar conexiones a servicios remotos

---

## 📝 Notas

- Todos los CLIs están instalados y listos para usar
- Para servicios remotos, no necesitas permisos especiales
- `rabbitmqctl` requiere permisos root solo para gestión local del servidor
- Para CloudAMQP y otros servicios remotos, usa `rabbitmqadmin`
- Railway y Vercel CLI ya están configurados y listos

---

## 🎯 Siguiente Acción

**Configurar las variables de entorno y probar las conexiones:**

```bash
# 1. Crear .env con las credenciales
cp .env.example .env
# Editar .env con tus credenciales

# 2. Probar conexiones
./scripts/test-connections.sh
```

