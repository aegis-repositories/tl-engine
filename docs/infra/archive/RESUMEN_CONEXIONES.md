# 📊 Resumen de Conexiones - tl-engine

**Fecha**: $(date +"%Y-%m-%d %H:%M:%S")

## ✅ Estado de Conexiones

### 🗄️ **PostgreSQL (Neon)** ✅ **CONECTADO**
- **Host**: `ep-dark-smoke-adnyibbf-pooler.c-2.us-east-1.aws.neon.tech`
- **Base de datos actual**: `neondb` (tl-plane)
- **Usuario**: `neondb_owner`
- **Versión**: PostgreSQL 17.7
- **Estado**: ✅ Conexión exitosa
- **Acción requerida**: Crear nueva base de datos `enginedb` en el mismo proyecto Neon

**Comando para crear base de datos:**
```sql
CREATE DATABASE enginedb;
```

**Comando de prueba:**
```bash
psql "postgresql://neondb_owner:npg_ejiqZ6v4umVl@ep-dark-smoke-adnyibbf-pooler.c-2.us-east-1.aws.neon.tech/neondb?sslmode=require" -c "SELECT version();"
```

---

### ⚡ **Redis (Upstash)** ✅ **CONECTADO**
- **Host**: `summary-dassie-38045.upstash.io:6379`
- **Versión**: Redis 6.2.6
- **Modo**: Standalone
- **Estado**: ✅ Conexión exitosa (PONG)
- **Acción requerida**: Usar prefijos `engine:*` para keys de tl-engine

**Comando de prueba:**
```bash
redis-cli -u "rediss://default:AZSdAAIncDI5MjQ2OTcwMWNjZmQ0NjRhOGMyZGFhZGUxNmU3ODdlNnAyMzgwNDU@summary-dassie-38045.upstash.io:6379" ping
```

**Uso con prefijos:**
```bash
# Set key con prefijo
redis-cli -u "$REDIS_URL" set "engine:cache:key" "value"

# Get key con prefijo
redis-cli -u "$REDIS_URL" get "engine:cache:key"
```

---

### 🐰 **RabbitMQ (CloudAMQP)** ⚠️ **REQUIERE CONFIGURACIÓN**
- **Host**: `jaragua.lmq.cloudamqp.com`
- **Usuario**: `wmohtwtk`
- **VHost actual**: `/wmohtwtk` (tl-plane)
- **Estado**: ⚠️ Requiere crear nuevo vhost `/engine`
- **Acción requerida**: 
  1. Crear nuevo vhost `/engine` en CloudAMQP
  2. Configurar permisos para el usuario

**Crear vhost desde CloudAMQP Dashboard:**
1. Ir a https://customer.cloudamqp.com/
2. Seleccionar instancia
3. Ir a "VHosts" → "Add VHost"
4. Crear vhost: `/engine`

**O desde API:**
```bash
curl -u wmohtwtk:iMTR27W1DUwPLK1ZTUWPJWaR9cydmEgR \
  -X PUT \
  https://jaragua.lmq.cloudamqp.com/api/vhosts/engine
```

**Configurar permisos:**
```bash
curl -u wmohtwtk:iMTR27W1DUwPLK1ZTUWPJWaR9cydmEgR \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{"configure":".*","write":".*","read":".*"}' \
  https://jaragua.lmq.cloudamqp.com/api/permissions/engine/wmohtwtk
```

---

## 📋 Servicios de tl-plane (Referencia)

### **PostgreSQL**
- **Proveedor**: Neon
- **URL**: `postgresql://neondb_owner:...@ep-dark-smoke-adnyibbf-pooler.c-2.us-east-1.aws.neon.tech/neondb`
- **Base de datos**: `neondb`

### **Redis**
- **Proveedor**: Upstash
- **URL**: `rediss://default:...@summary-dassie-38045.upstash.io:6379`
- **Prefijos**: `plane:*` (implícito)

### **RabbitMQ**
- **Proveedor**: CloudAMQP
- **URL**: `amqps://wmohtwtk:...@jaragua.lmq.cloudamqp.com/wmohtwtk`
- **VHost**: `/wmohtwtk`

### **Storage S3**
- **Proveedor**: Backblaze B2
- **Bucket**: `tl-plane`
- **Endpoint**: `https://s3.us-east-005.backblazeb2.com`

---

## 🎯 Configuración Recomendada para tl-engine

### **Opción 1: Compartir Servicios (Recomendado - Ahorra $)**

1. **PostgreSQL**: 
   - ✅ Crear base de datos `enginedb` en misma instancia Neon
   - 💰 **Costo**: $0 (tier gratuito)

2. **Redis**: 
   - ✅ Usar misma instancia con prefijos `engine:*`
   - 💰 **Costo**: $0 (tier gratuito)

3. **RabbitMQ**: 
   - ✅ Crear vhost `/engine` en misma instancia CloudAMQP
   - 💰 **Costo**: $0-20/mes (tier gratuito limitado)

### **Opción 2: Separar Servicios (Más Aislamiento)**

1. **PostgreSQL**: Nueva instancia Neon
2. **Redis**: Nueva instancia Upstash
3. **RabbitMQ**: Nueva instancia CloudAMQP

---

## 🔧 Próximos Pasos

1. ✅ **CLIs instalados** - Todo listo
2. ⏳ **Crear base de datos** `enginedb` en Neon
3. ⏳ **Crear vhost** `/engine` en CloudAMQP
4. ⏳ **Configurar `.env`** con las nuevas credenciales
5. ⏳ **Probar conexiones** con `./scripts/test-connections.sh`

---

## 📝 Comandos Útiles

### **Probar PostgreSQL:**
```bash
psql "$DATABASE_URL" -c "SELECT current_database(), version();"
```

### **Probar Redis:**
```bash
redis-cli -u "$REDIS_URL" ping
redis-cli -u "$REDIS_URL" set "engine:test" "ok"
redis-cli -u "$REDIS_URL" get "engine:test"
```

### **Probar RabbitMQ (después de crear vhost):**
```bash
# Listar vhosts
curl -u user:pass https://jaragua.lmq.cloudamqp.com/api/vhosts

# Listar queues en vhost /engine
curl -u user:pass https://jaragua.lmq.cloudamqp.com/api/queues/engine
```

---

## ✅ Checklist

- [x] CLIs instalados (PostgreSQL, Redis, RabbitMQ)
- [x] Conexión PostgreSQL probada y funcionando
- [x] Conexión Redis probada y funcionando
- [ ] Base de datos `enginedb` creada en Neon
- [ ] VHost `/engine` creado en CloudAMQP
- [ ] Archivo `.env` configurado
- [ ] Conexiones probadas con script de test

