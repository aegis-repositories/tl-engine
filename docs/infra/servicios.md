# 🏗️ Infraestructura y Servicios Remotos - tl-engine

## 📊 Compartir vs Separar Servicios

### ¿Por qué compartir o separar?

#### **COMPARTIR (Misma Instancia)**

**✅ Ventajas:**
- 💰 **Ahorro de costos**: Menos instancias = menos gasto mensual
- 🔧 **Menos gestión**: Una sola configuración y mantenimiento
- ⚡ **Menor latencia**: Si están en la misma red, comunicación más rápida
- 📦 **Simplicidad**: Menos variables de entorno y conexiones

**❌ Desventajas:**
- 🚨 **Riesgo de cuello de botella**: Si un servicio se satura, afecta a todos
- 🔒 **Menos aislamiento**: Un fallo puede afectar múltiples servicios
- 📈 **Escalado acoplado**: No puedes escalar servicios independientemente
- 🐛 **Debugging más complejo**: Logs y métricas mezclados
- 🔐 **Seguridad**: Si un servicio se compromete, puede afectar a otros

#### **SEPARAR (Instancias Independientes)**

**✅ Ventajas:**
- 🛡️ **Aislamiento total**: Fallos no se propagan entre servicios
- 📈 **Escalado independiente**: Cada servicio escala según su necesidad
- 🔐 **Mejor seguridad**: Separación de datos y acceso
- 🐛 **Debugging más claro**: Logs y métricas separados
- 🎯 **Optimización específica**: Configuración optimizada por servicio

**❌ Desventajas:**
- 💰 **Mayor costo**: Más instancias = más gasto mensual
- 🔧 **Más gestión**: Múltiples configuraciones y mantenimiento
- ⚡ **Mayor latencia**: Si están en diferentes regiones/redes

---

## 💡 Recomendación por Servicio

### **PostgreSQL** 🗄️
**Recomendación: SEPARAR**
- **Razón**: Bases de datos diferentes = mejor organización y seguridad
- **Costo**: Neon tiene tier gratuito generoso, puedes crear múltiples proyectos
- **Configuración**: 
  - `tl-plane` → Base de datos: `plane_db`
  - `tl-engine` → Base de datos: `engine_db`
  - O instancias completamente separadas

### **Redis** ⚡
**Recomendación: COMPARTIR (con prefijos)**
- **Razón**: Redis es muy eficiente con múltiples bases (0-15) o prefijos de keys
- **Costo**: Upstash tiene tier gratuito, compartir ahorra dinero
- **Configuración**:
  - Usar prefijos: `plane:cache:*` y `engine:cache:*`
  - O bases de datos diferentes: `SELECT 0` (plane) y `SELECT 1` (engine)

### **RabbitMQ** 🐰
**Recomendación: COMPARTIR (con vhosts separados)**
- **Razón**: RabbitMQ soporta múltiples vhosts (virtual hosts) para aislamiento
- **Costo**: CloudAMQP tiene tier gratuito limitado, compartir ahorra
- **Configuración**:
  - `tl-plane` → vhost: `/plane`
  - `tl-engine` → vhost: `/engine`
  - O exchanges separados dentro del mismo vhost

---

## 📍 Dónde está RabbitMQ en tl-plane

### **Desarrollo Local:**
- **Ubicación**: Docker Compose (`docker-compose.yml`)
- **Container**: `plane-mq`
- **Imagen**: `rabbitmq:3.13.6-management-alpine`
- **Puerto**: `5672` (AMQP), `15672` (Management UI)
- **Configuración**: Variables en `.env`:
  ```
  RABBITMQ_HOST=plane-mq
  RABBITMQ_PORT=5672
  RABBITMQ_USER=plane
  RABBITMQ_PASSWORD=plane
  RABBITMQ_VHOST=plane
  ```

### **Producción:**
- **Proveedor**: CloudAMQP
- **URL**: `amqps://wmohtwtk:...@jaragua.lmq.cloudamqp.com/wmohtwtk`
- **Variable**: `AMQP_URL` en Railway

---

## 🛠️ CLIs Disponibles

### ✅ **PostgreSQL** - `psql` ✅ **YA INSTALADO**
- **CLI**: `psql` (incluido con postgresql)
- **Versión instalada**: PostgreSQL 18.1
- **Ubicación**: `/usr/sbin/psql`
- **Uso**:
  ```bash
  psql "postgresql://user:pass@host:5432/dbname"
  ```

### ✅ **Redis** - `redis-cli` ✅ **YA INSTALADO**
- **CLI**: `redis-cli` (valkey-cli)
- **Versión instalada**: valkey-cli 8.1.4
- **Ubicación**: `/usr/sbin/redis-cli`
- **Uso**:
  ```bash
  redis-cli -u "rediss://default:password@host:6379"
  ```

### ✅ **RabbitMQ** - `rabbitmqctl` y `rabbitmqadmin` ✅ **YA INSTALADO**
- **CLI**: `rabbitmqctl` (administración), `rabbitmqadmin` (management API)
- **Versión instalada**: RabbitMQ 4.2.1
- **Ubicación**: 
  - `/usr/sbin/rabbitmqctl` (requiere permisos root para uso local)
  - `~/.local/bin/rabbitmqadmin` (para servicios remotos como CloudAMQP)
- **Uso para servicios remotos**:
  ```bash
  rabbitmqadmin -H host -u user -p pass -P 5672 -V vhost list queues
  ```

### ✅ **Railway CLI** ✅ **YA INSTALADO**
- **Ubicación**: `~/.local/bin/railway`
- **Uso**: Gestión de proyectos en Railway

### ✅ **Vercel CLI** ✅ **YA INSTALADO**
- **Ubicación**: `~/.local/bin/vercel`
- **Uso**: Gestión de proyectos en Vercel

### ❌ **PostHog** - No tiene CLI oficial
- **Alternativa**: API REST o Dashboard web
- **Autenticación**: API Key desde el dashboard

### ❌ **Scout APM** - No tiene CLI
- **Alternativa**: Dashboard web únicamente
- **Autenticación**: API Key en configuración de la app

---

## 🐳 Alternativa con Docker (Sin Instalar CLIs)

Si no quieres instalar los CLIs localmente, puedes usar contenedores Docker:

### **PostgreSQL CLI:**
```bash
docker run -it --rm postgres:15 psql "postgresql://user:pass@host:5432/dbname"
```

### **Redis CLI:**
```bash
docker run -it --rm redis:7 redis-cli -u "rediss://default:password@host:6379"
```

### **RabbitMQ Management:**
```bash
# Descargar rabbitmqadmin
wget https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.13.6/bin/rabbitmqadmin
chmod +x rabbitmqadmin

# Usar con Docker
docker run -it --rm -v $(pwd)/rabbitmqadmin:/rabbitmqadmin rabbitmq:3.13.6-management-alpine \
  python /rabbitmqadmin -H host -u user -p pass list queues
```

---

## 🔐 Autenticación en Servicios Remotos

### **PostgreSQL (Neon)**
```bash
# Conectar usando URL de conexión
psql "postgresql://neondb_owner:password@ep-xxx.aws.neon.tech/neondb?sslmode=require"

# O con variables
export PGHOST=ep-xxx.aws.neon.tech
export PGPORT=5432
export PGDATABASE=neondb
export PGUSER=neondb_owner
export PGPASSWORD=password
psql
```

### **Redis (Upstash)**
```bash
# Conectar usando URL
redis-cli -u "rediss://default:password@host:6379"

# O con variables
export REDIS_URL="rediss://default:password@host:6379"
redis-cli -u $REDIS_URL
```

### **RabbitMQ (CloudAMQP)**
```bash
# Usar rabbitmqadmin con URL
rabbitmqadmin -H jaragua.lmq.cloudamqp.com \
  -u wmohtwtk \
  -p password \
  -P 5672 \
  -V wmohtwtk \
  list queues

# O parsear AMQP_URL
# amqps://user:pass@host:port/vhost
```

### **PostHog**
- **Dashboard**: https://app.posthog.com
- **API Key**: Obtener desde Settings → Project → API Keys
- **Uso en código**: `POSTHOG_API_KEY` y `POSTHOG_HOST`

### **Scout APM**
- **Dashboard**: https://scoutapm.com
- **API Key**: Obtener desde Settings → API Keys
- **Uso en código**: `SCOUT_KEY` en configuración

---

## 📋 Script de Instalación de CLIs

Crea un script `install-clis.sh`:

```bash
#!/bin/bash
# Instalación de CLIs para servicios remotos

echo "🔧 Instalando CLIs para servicios remotos..."

# PostgreSQL
echo "📦 Instalando PostgreSQL CLI..."
sudo pacman -S --noconfirm postgresql

# Redis
echo "📦 Instalando Redis CLI..."
sudo pacman -S --noconfirm redis

# RabbitMQ
echo "📦 Instalando RabbitMQ..."
sudo pacman -S --noconfirm rabbitmq

# Verificar instalación
echo "✅ Verificando instalación..."
which psql && echo "✅ psql instalado" || echo "❌ psql no encontrado"
which redis-cli && echo "✅ redis-cli instalado" || echo "❌ redis-cli no encontrado"
which rabbitmqctl && echo "✅ rabbitmqctl instalado" || echo "❌ rabbitmqctl no encontrado"

echo "🎉 Instalación completada!"
```

---

## 💰 Comparación de Costos

### **Compartir Servicios:**
- PostgreSQL (Neon): $0-19/mes (tier gratuito generoso)
- Redis (Upstash): $0-10/mes (tier gratuito)
- RabbitMQ (CloudAMQP): $0-20/mes (tier gratuito limitado)
- **Total**: ~$0-49/mes

### **Separar Servicios:**
- PostgreSQL x2: $0-38/mes
- Redis x2: $0-20/mes
- RabbitMQ x2: $0-40/mes
- **Total**: ~$0-98/mes

**Ahorro compartiendo**: ~$49/mes (50% menos)

---

## 🎯 Recomendación Final

Para **tl-engine** como engine centralizador:

1. **PostgreSQL**: SEPARAR (bases de datos diferentes en misma instancia Neon)
2. **Redis**: COMPARTIR (usar prefijos o bases diferentes)
3. **RabbitMQ**: COMPARTIR (usar vhosts separados)
4. **PostHog**: COMPARTIR (mismo proyecto, diferentes apps)
5. **Scout APM**: SEPARAR (diferentes proyectos para mejor tracking)

**Configuración recomendada:**
- Misma instancia Neon → Base de datos separada
- Misma instancia Upstash → Prefijos diferentes
- Mismo CloudAMQP → Vhosts diferentes (`/plane` y `/engine`)

