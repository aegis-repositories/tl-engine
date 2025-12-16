# 🐰 RabbitMQ - Configuración

## 📊 Arquitectura

```mermaid
graph TB
    A[Engine API<br/>Producer] -->|Publish| B[RabbitMQ<br/>Exchange]
    B -->|Route| C[Queue<br/>engine:tasks]
    C -->|Consume| D[Engine Worker<br/>Consumer]
    
    style A fill:#4a90e2
    style B fill:#ff6600
    style C fill:#ff6600
    style D fill:#4a90e2
```

## 🔧 Configuración para tl-engine

### **VHost:**
- **Nombre**: `/engine`
- **Aislamiento**: Separado de `/wmohtwtk` (tl-plane)

### **Queues:**
- `engine:tasks` - Tareas asíncronas
- `engine:events` - Eventos del sistema
- `engine:notifications` - Notificaciones

### **Exchanges:**
- `engine:direct` - Routing directo
- `engine:fanout` - Broadcasting
- `engine:topic` - Routing por topic

---

## 🔐 Autenticación

### **Usuario:**
- Mismo usuario que tl-plane (wmohtwtk)
- Permisos en vhost `/engine`

### **URL de Conexión:**
```
amqps://wmohtwtk:password@jaragua.lmq.cloudamqp.com/engine
```

---

## 📋 Variables de Entorno

```bash
AMQP_URL="amqps://wmohtwtk:pass@jaragua.lmq.cloudamqp.com/engine"
```

---

## ✅ Checklist

- [ ] VHost `/engine` creado en CloudAMQP
- [ ] Permisos configurados
- [ ] Queues declaradas
- [ ] Exchanges configurados
- [ ] Variables de entorno configuradas





