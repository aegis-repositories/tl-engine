# 🎫 Ticket 02: Tu primer Cluster Kubernetes (Local)

**Objetivo**: Dejar de usar `docker run` manual y pasar a usar un orquestador real. Vas a levantar un "mini servidor" de Kubernetes dentro de tu laptop.

## ✅ Checklist de Completitud (Definition of Done)

- [ ] **Cluster Activo**: Tienes un cluster (Kind, Minikube o K3d) corriendo.
- [ ] **Despliegue**: Tu app de Rust (del ticket anterior) está corriendo DENTRO del cluster.
- [ ] **Verificación**: Puedes escribir un comando y ver los logs "TL-Engine Iniciado" saliendo desde Kubernetes.

## 📂 Archivos en este Ticket

1. [conceptos-k8s.md](./conceptos-k8s.md): **LÉEME PRIMERO**. Arquitectura de Kubernetes, Pods, Deployments, Services, Namespaces, y flujo de trabajo.
2. [setup-cluster.md](./setup-cluster.md): Cómo instalar kubectl y kind, y crear tu primer cluster local.
3. [manifiestos.md](./manifiestos.md): Los archivos YAML que definen tu infraestructura y cómo desplegarlos.
4. [referencia-tecnica.md](./referencia-tecnica.md): **Opcional**. Análisis detallado de YAMLs, networking, comandos avanzados de kubectl, y troubleshooting.
