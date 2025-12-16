# 🔌 Integraciones - Servicios Remotos

## 📊 Diagrama de Integraciones

```mermaid
graph LR
    subgraph "tl-engine"
        A[Engine API]
        B[Engine Worker]
    end

    subgraph "PostgreSQL - Neon"
        C[(enginedb)]
        D[(neondb<br/>tl-plane)]
    end

    subgraph "Redis - Upstash"
        E[Cache<br/>engine:*]
        F[Cache<br/>plane:*]
    end

    subgraph "RabbitMQ - CloudAMQP"
        G[/engine<br/>vhost]
        H[/wmohtwtk<br/>vhost<br/>tl-plane]
    end

    subgraph "S3 - Backblaze"
        I[tl-engine<br/>bucket]
        J[tl-plane<br/>bucket]
    end

    A --> C
    A --> E
    A --> G
    A --> I
    
    B --> C
    B --> E
    B --> G
    B --> I

    style C fill:#336791
    style E fill:#dc382d
    style G fill:#ff6600
    style I fill:#000000
```

## 🗄️ PostgreSQL (Neon)

### **Configuración**
- **Proveedor**: Neon
- **Base de datos**: `enginedb`
- **Compartido con**: `neondb` (tl-plane) en misma instancia
- **Variable**: `DATABASE_URL`

### **Integración**
```python
# Conexión
DATABASE_URL = os.environ.get('DATABASE_URL')
# postgresql://user:pass@host:5432/enginedb?sslmode=require
```

### **Uso**
- Persistencia de datos del engine
- Métricas y logs
- Estado de engines

---

## ⚡ Redis (Upstash)

### **Configuración**
- **Proveedor**: Upstash
- **Prefijos**: `engine:*` para tl-engine
- **Compartido con**: `plane:*` (tl-plane) en misma instancia
- **Variable**: `REDIS_URL`

### **Integración**
```python
# Conexión
REDIS_URL = os.environ.get('REDIS_URL')
# rediss://default:pass@host:6379

# Uso con prefijos
redis_client.set("engine:cache:key", "value")
redis_client.get("engine:cache:key")
```

### **Uso**
- Cache de queries frecuentes
- Rate limiting counters
- Sesiones (si necesario)
- Pub/Sub para comunicación

---

## 🐰 RabbitMQ (CloudAMQP)

### **Configuración**
- **Proveedor**: CloudAMQP
- **VHost**: `/engine` (o compartir `/wmohtwtk`)
- **Compartido con**: `/wmohtwtk` (tl-plane) en misma instancia
- **Variable**: `AMQP_URL`

### **Integración**
```python
# Conexión
AMQP_URL = os.environ.get('AMQP_URL')
# amqps://user:pass@host:port/engine

# Uso
connection = pika.BlockingConnection(pika.URLParameters(AMQP_URL))
channel = connection.channel()
channel.queue_declare(queue='engine:tasks')
```

### **Uso**
- Tareas asíncronas
- Comunicación entre engines
- Colas de procesamiento
- Event streaming

---

## 📦 S3 Storage (Backblaze B2)

### **Configuración**
- **Proveedor**: Backblaze B2
- **Bucket**: `tl-engine` (o compartir `tl-plane`)
- **Endpoint**: `https://s3.us-east-005.backblazeb2.com`
- **Variables**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET_NAME`

### **Integración**
```python
# Conexión
import boto3

s3_client = boto3.client(
    's3',
    endpoint_url=os.environ.get('AWS_S3_ENDPOINT_URL'),
    aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY')
)

# Uso
s3_client.upload_file('local_file', 'tl-engine', 'remote_file')
```

### **Uso**
- Almacenamiento de logs
- Archivos de configuración
- Backups
- Assets estáticos

---

## 🔄 Estrategia de Compartir vs Separar

### **PostgreSQL**
- ✅ **Separar**: Base de datos diferente (`enginedb` vs `neondb`)
- ✅ Misma instancia Neon (ahorro de costos)
- ✅ Aislamiento de datos

### **Redis**
- ✅ **Compartir**: Misma instancia con prefijos
- ✅ Prefijos: `engine:*` y `plane:*`
- ✅ Eficiente y económico

### **RabbitMQ**
- ✅ **Compartir**: Mismo CloudAMQP con vhosts diferentes
- ✅ VHosts: `/engine` y `/wmohtwtk`
- ✅ Aislamiento por vhost

### **S3**
- ⚠️ **Separar o Compartir**: Depende de necesidades
- ✅ Buckets diferentes: `tl-engine` y `tl-plane`
- ✅ O mismo bucket con prefijos en paths

---

## 📋 Checklist de Integración

- [x] PostgreSQL: Base `enginedb` creada
- [x] Redis: URL configurada, usar prefijos `engine:*`
- [ ] RabbitMQ: VHost `/engine` creado
- [ ] S3: Bucket `tl-engine` creado
- [ ] Variables de entorno configuradas
- [ ] Conexiones probadas

---

## 🔗 Referencias

- [Configuración de Servicios](../configuracion-servicios.md)
- [Variables de Entorno](../variables-entorno.md)





