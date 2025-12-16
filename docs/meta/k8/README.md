# ☸️ Kubernetes (K8s) - Documentación

## 📚 ¿Qué es Kubernetes?

Kubernetes es un orquestador de contenedores que gestiona el despliegue, escalado y operación de aplicaciones en contenedores.

## 📋 Documentación

### **Análisis General**
- [**Análisis Completo**](./ANALISIS_COMPLETO.md) - ⚠️ **LEER PRIMERO**: Qué trae K8s, pitfalls, peligros, mantenimiento, automatizaciones, qué cubre exactamente, cómo escala
- [**Protección Contra Costos**](./PROTECCION_COSTOS.md) - 🛡️ **CRÍTICO**: Cómo evitar costos impagables, protección en múltiples capas, escenarios de ataque

### **Documentación por Servicio**
- [PostgreSQL](./postgresql.md) - Cómo K8s gestiona PostgreSQL
- [Redis](./redis.md) - Cómo K8s gestiona Redis
- [RabbitMQ](./rabbitmq.md) - Cómo K8s gestiona RabbitMQ
- [Engine API](./engine-api.md) - Cómo K8s despliega la API
- [Engine Worker](./engine-worker.md) - Cómo K8s gestiona workers

## 🎯 Conceptos Clave

- **Pods**: Unidad mínima de despliegue (1 o más contenedores)
- **Deployments**: Gestiona réplicas de pods
- **Services**: Expone pods internamente/externamente
- **ConfigMaps**: Configuración no sensible
- **Secrets**: Configuración sensible (passwords, keys)
- **Ingress**: Routing HTTP/HTTPS externo
- **HPA**: Horizontal Pod Autoscaler (auto-scaling)

