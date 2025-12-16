# 🐰 Kubernetes + RabbitMQ

## 📊 ¿Cómo K8s interactúa con RabbitMQ?

### **Opción 1: RabbitMQ Externo (Recomendado para tl-engine)**

RabbitMQ corre **fuera de K8s** (CloudAMQP, servicio remoto).

```mermaid
graph LR
    A[K8s Pods] -->|AMQP_URL| B[(RabbitMQ<br/>CloudAMQP<br/>Externo)]
    
    style A fill:#4a90e2
    style B fill:#ff6600
```

**Cómo funciona:**
- K8s despliega pods que se conectan a RabbitMQ externo
- AMQP_URL en **Secret** de K8s
- No gestiona RabbitMQ, solo la conexión

**Ventajas:**
- ✅ RabbitMQ gestionado (CloudAMQP)
- ✅ Sin gestión de estado en K8s
- ✅ Escalado independiente
- ✅ VHosts aislados

**Configuración:**
```yaml
# Secret con AMQP_URL
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-secret
type: Opaque
stringData:
  AMQP_URL: "amqps://user:pass@host:port/vhost"
```

---

### **Opción 2: RabbitMQ en K8s (Opcional)**

RabbitMQ corre **dentro de K8s** como StatefulSet.

```mermaid
graph TB
    A[K8s StatefulSet<br/>RabbitMQ] --> B[PersistentVolume<br/>Messages]
    C[Engine Pods] -->|AMQP| A
    
    style A fill:#ff6600
    style B fill:#95a5a6
    style C fill:#4a90e2
```

**Cómo funciona:**
- StatefulSet gestiona pods de RabbitMQ
- PersistentVolume para mensajes persistentes
- Service expone RabbitMQ internamente

**Cuándo usar:**
- ⚠️ Desarrollo local
- ⚠️ Testing
- ❌ No recomendado para producción (usar CloudAMQP)

---

## 🔧 Configuración para tl-engine

### **Usando RabbitMQ Externo (CloudAMQP)**

**1. Secret con credenciales:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-secret
type: Opaque
stringData:
  AMQP_URL: "amqps://wmohtwtk:pass@jaragua.lmq.cloudamqp.com/engine"
```

**2. Deployment usa el Secret:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-worker
spec:
  template:
    spec:
      containers:
      - name: worker
        env:
        - name: AMQP_URL
          valueFrom:
            secretKeyRef:
              name: rabbitmq-secret
              key: AMQP_URL
```

**3. Connection Management:**
- Cada pod crea su propia conexión AMQP
- K8s no gestiona el pool de conexiones
- La app debe manejar reconexiones

---

## 📊 Impacto en la Aplicación

### **Connection Management:**
```python
# La app se conecta normalmente
AMQP_URL = os.environ.get('AMQP_URL')
# K8s inyecta el valor desde Secret

import pika
connection = pika.BlockingConnection(
    pika.URLParameters(AMQP_URL)
)
channel = connection.channel()
```

### **Health Checks:**
```yaml
# K8s verifica que la app puede conectar a RabbitMQ
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - "python -c 'import pika; pika.BlockingConnection(pika.URLParameters(\"$AMQP_URL\"))'"
  initialDelaySeconds: 30
  periodSeconds: 10
```

### **Worker Pods:**
```yaml
# Worker consume mensajes de RabbitMQ
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-worker
spec:
  replicas: 3  # 3 workers consumiendo de la misma queue
  template:
    spec:
      containers:
      - name: worker
        command: ["python", "worker.py"]
```

---

## 🔄 Escalado

### **Con RabbitMQ Externo:**
- ✅ Escalar worker pods independientemente
- ✅ RabbitMQ escala por su cuenta (CloudAMQP)
- ✅ Múltiples workers consumen de la misma queue
- ✅ Load balancing automático

### **Con RabbitMQ en K8s:**
- ⚠️ StatefulSet: 1 réplica o cluster
- ⚠️ PersistentVolume para mensajes
- ⚠️ Más complejo de gestionar

---

## 🎯 Uso de RabbitMQ en tl-engine

### **Tareas Asíncronas:**
```python
# Producer (API)
channel.queue_declare(queue='engine:tasks')
channel.basic_publish(
    exchange='',
    routing_key='engine:tasks',
    body=json.dumps(task_data)
)

# Consumer (Worker)
def callback(ch, method, properties, body):
    task = json.loads(body)
    process_task(task)
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(
    queue='engine:tasks',
    on_message_callback=callback
)
```

### **Event Streaming:**
```python
# Publicar eventos
channel.exchange_declare(exchange='engine:events', exchange_type='fanout')
channel.basic_publish(
    exchange='engine:events',
    routing_key='',
    body=json.dumps(event_data)
)
```

---

## ✅ Recomendación para tl-engine

**Usar RabbitMQ Externo (CloudAMQP):**
- ✅ Simple
- ✅ Gestionado
- ✅ VHosts aislados (/engine)
- ✅ Sin gestión de estado en K8s
- ✅ Compartir con tl-plane

**K8s solo gestiona:**
- Inyección de AMQP_URL via Secrets
- Health checks de conexión
- Escalado de worker pods
- Load balancing de workers





