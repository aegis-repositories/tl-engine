# ☸️ Kubernetes - Arquitectura tl-engine

## 📊 Estructura en Kubernetes

```
Kubernetes Cluster
├── Namespace: dev (default)
│   ├── Deployment: engine-api
│   ├── Deployment: engine-worker
│   ├── Service: engine-api-service
│   ├── Ingress: engine-api-ingress
│   └── HPA: engine-api-hpa
│
└── Namespace: staging
    ├── Deployment: engine-api
    └── Service: engine-api-service
```

## 🏗️ Componentes

### **Deployments**
- `engine-api`: API REST principal
- `engine-worker`: Workers que consumen de RabbitMQ

### **Services**
- `engine-api-service`: Load balancer interno/externo

### **Ingress**
- Routing HTTP/HTTPS externo
- SSL/TLS termination

### **HPA (Horizontal Pod Autoscaler)**
- Auto-scaling basado en CPU/memoria

## 📋 Ver Documentación Detallada

- [K8s + PostgreSQL](../meta/k8/postgresql.md)
- [K8s + Redis](../meta/k8/redis.md)
- [K8s + RabbitMQ](../meta/k8/rabbitmq.md)
- [K8s + Engine API](../meta/k8/engine-api.md)
- [K8s + Engine Worker](../meta/k8/engine-worker.md)




