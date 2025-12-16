# ⚡ Kubernetes + Redis

## 📊 ¿Cómo K8s interactúa con Redis?

### **Opción 1: Redis Externo (Recomendado para tl-engine)**

Redis corre **fuera de K8s** (Upstash, servicio remoto).

```mermaid
graph LR
    A[K8s Pods] -->|REDIS_URL| B[(Redis<br/>Upstash<br/>Externo)]
    
    style A fill:#4a90e2
    style B fill:#dc382d
```

**Cómo funciona:**
- K8s despliega pods que se conectan a Redis externo
- REDIS_URL en **Secret** de K8s
- No gestiona Redis, solo la conexión

**Ventajas:**
- ✅ Redis gestionado (Upstash)
- ✅ Sin gestión de estado en K8s
- ✅ Escalado independiente
- ✅ Tier gratuito disponible

**Configuración:**
```yaml
# Secret con REDIS_URL
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
type: Opaque
stringData:
  REDIS_URL: "rediss://default:pass@host:6379"
```

---

### **Opción 2: Redis en K8s (Opcional)**

Redis corre **dentro de K8s** como Deployment/StatefulSet.

```mermaid
graph TB
    A[K8s Deployment<br/>Redis] --> B[PersistentVolume<br/>Optional]
    C[Engine Pods] -->|Connection| A
    
    style A fill:#dc382d
    style B fill:#95a5a6
    style C fill:#4a90e2
```

**Cómo funciona:**
- Deployment gestiona pods de Redis
- Service expone Redis internamente
- PersistentVolume opcional (si necesitas persistencia)

**Cuándo usar:**
- ⚠️ Desarrollo local
- ⚠️ Testing
- ❌ No recomendado para producción (usar Upstash)

---

## 🔧 Configuración para tl-engine

### **Usando Redis Externo (Upstash)**

**1. Secret con credenciales:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
type: Opaque
stringData:
  REDIS_URL: "rediss://default:pass@summary-dassie-38045.upstash.io:6379"
```

**2. Deployment usa el Secret:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-api
spec:
  template:
    spec:
      containers:
      - name: api
        env:
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: REDIS_URL
```

**3. Connection Pooling:**
- Redis maneja múltiples conexiones
- Cada pod tiene su pool de conexiones
- K8s no gestiona el pool

---

## 📊 Impacto en la Aplicación

### **Connection Management:**
```python
# La app se conecta normalmente
REDIS_URL = os.environ.get('REDIS_URL')
# K8s inyecta el valor desde Secret

import redis
redis_client = redis.from_url(REDIS_URL)
```

### **Health Checks:**
```yaml
# K8s verifica que la app puede conectar a Redis
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - "redis-cli -u $REDIS_URL ping"
  initialDelaySeconds: 10
  periodSeconds: 10
```

### **Rate Limiting:**
```python
# Rate limiting usando Redis (no gestionado por K8s)
def check_rate_limit(api_key):
    key = f"engine:ratelimit:{api_key}"
    count = redis_client.incr(key)
    if count == 1:
        redis_client.expire(key, 3600)
    return count <= 1000
```

---

## 🔄 Escalado

### **Con Redis Externo:**
- ✅ Escalar pods independientemente
- ✅ Redis escala por su cuenta (Upstash)
- ✅ Compartir Redis entre múltiples pods
- ✅ Sin límites de K8s

### **Con Redis en K8s:**
- ⚠️ Deployment: múltiples réplicas (pero no cluster)
- ⚠️ StatefulSet: 1 réplica o cluster Redis
- ⚠️ Más complejo de gestionar

---

## 🎯 Uso de Redis en tl-engine

### **Cache:**
```python
# Cache de queries frecuentes
cache_key = f"engine:cache:{query_id}"
cached = redis_client.get(cache_key)
if not cached:
    result = expensive_query()
    redis_client.setex(cache_key, 3600, result)
```

### **Rate Limiting:**
```python
# Contador de requests por API key
key = f"engine:ratelimit:{api_key}"
count = redis_client.incr(key)
```

### **Pub/Sub:**
```python
# Comunicación entre pods
pubsub = redis_client.pubsub()
pubsub.subscribe('engine:events')
```

---

## ✅ Recomendación para tl-engine

**Usar Redis Externo (Upstash):**
- ✅ Simple
- ✅ Gestionado
- ✅ Tier gratuito
- ✅ Sin gestión de estado en K8s
- ✅ Compartir con tl-plane

**K8s solo gestiona:**
- Inyección de REDIS_URL via Secrets
- Health checks de conexión
- Escalado de pods de aplicación





