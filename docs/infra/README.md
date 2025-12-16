# 🏗️ Infraestructura - tl-engine

## 📚 Documentación

### **Vista General**
- [Vista General](./vista-general.md) - Arquitectura completa con diagramas

### **Configuración**
- [Railway](./railway.md) - Arquitectura y configuración en Railway
- [CI/CD](./ci-cd.md) - Pipeline de despliegue
- [Configuración](./configuracion.md) - Configuración completa del proyecto

### **Servicios**
- [Servicios Remotos](./servicios.md) - PostgreSQL, Redis, RabbitMQ, S3

### **Integraciones**
- [Integraciones](./integraciones/) - Documentación de todas las integraciones
  - [Servicios Remotos](./integraciones/servicios-remotos.md)
  - [Sistemas Externos](./integraciones/sistemas-externos.md)
  - [Monitoreo](./integraciones/monitoreo.md)

### **Archivo**
- [Archive](./archive/) - Documentación obsoleta (referencia histórica)

---

## 🚀 Quick Start

```bash
# Ver todos los comandos disponibles
make help

# Instalar dependencias
make install

# Iniciar desarrollo
make dev

# Probar conexiones
make test-connections

# Deploy a development (default)
make deploy-dev

# Deploy a staging
make deploy-staging
```




