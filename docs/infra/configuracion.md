# ✅ Configuración Completa - tl-engine

## 📊 Estado de Conexiones Verificadas

### ✅ PostgreSQL (Neon) - CONFIGURADO
- **Base de datos**: `enginedb` ✅ CREADA
- **Conexión**: ✅ VERIFICADA
- **URL**: `postgresql://neondb_owner:...@ep-dark-smoke-adnyibbf-pooler.c-2.us-east-1.aws.neon.tech/enginedb`

### ✅ Redis (Upstash) - CONFIGURADO
- **Conexión**: ✅ VERIFICADA (PONG)
- **URL**: `rediss://default:...@summary-dassie-38045.upstash.io:6379`
- **Nota**: Usar prefijos `engine:*` para keys

### ⚠️ RabbitMQ (CloudAMQP) - PARCIALMENTE CONFIGURADO
- **VHost actual**: `/wmohtwtk` (compartido con tl-plane)
- **Acción**: Crear vhost `/engine` desde dashboard de CloudAMQP
- **URL actual**: `amqps://wmohtwtk:...@jaragua.lmq.cloudamqp.com/wmohtwtk`

---

## 🔧 Configuración del Archivo .env

**IMPORTANTE**: El archivo `.env` está en `.gitignore` (correcto para seguridad).

### Crear archivo .env:

```bash
cd /home/pango/projects/freelo/tiendaleon/tl-engine
cp .env.example .env
```

### O crear manualmente con este contenido:

```bash
# PostgreSQL
DATABASE_URL="postgresql://neondb_owner:npg_ejiqZ6v4umVl@ep-dark-smoke-adnyibbf-pooler.c-2.us-east-1.aws.neon.tech/enginedb?sslmode=require&channel_binding=require"

# Redis
REDIS_URL="rediss://default:AZSdAAIncDI5MjQ2OTcwMWNjZmQ0NjRhOGMyZGFhZGUxNmU3ODdlNnAyMzgwNDU@summary-dassie-38045.upstash.io:6379"

# RabbitMQ (usar vhost /wmohtwtk por ahora, cambiar a /engine cuando se cree)
AMQP_URL="amqps://wmohtwtk:iMTR27W1DUwPLK1ZTUWPJWaR9cydmEgR@jaragua.lmq.cloudamqp.com/wmohtwtk"

# Aplicación
DEBUG="0"
SECRET_KEY="9bce66f4f1d6cc8b040627bd0aea37702be9bf44d49e1d838a34c20996db3581"
ALLOWED_HOSTS="*"
```

---

## ✅ Verificación de Conexiones

Después de crear el `.env`, ejecutar:

```bash
./scripts/test-connections.sh
```

---

## 📋 Checklist Final

- [x] CLIs instalados (PostgreSQL, Redis, RabbitMQ)
- [x] Base de datos `enginedb` creada en Neon
- [x] Conexión PostgreSQL verificada
- [x] Conexión Redis verificada
- [ ] Archivo `.env` creado (bloqueado por gitignore - crear manualmente)
- [ ] VHost `/engine` creado en CloudAMQP (requiere dashboard)
- [ ] Conexiones probadas con script

---

## 🎯 Próximos Pasos

1. **Crear archivo `.env`** con las variables de entorno
2. **Crear vhost `/engine`** en CloudAMQP desde el dashboard
3. **Probar conexiones** con `./scripts/test-connections.sh`
4. **Iniciar desarrollo** del engine

