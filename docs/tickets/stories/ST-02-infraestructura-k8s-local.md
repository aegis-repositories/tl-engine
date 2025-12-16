# 📖 Story ST-02: Infraestructura Kubernetes Local

## Descripción

**Como** desarrollador del equipo  
**Quiero** tener un cluster Kubernetes local funcionando con la aplicación desplegada  
**Para** poder desarrollar y probar la aplicación en un entorno similar a producción sin depender de infraestructura cloud

## Contexto

Kubernetes es la plataforma elegida para producción desde el día 1. Necesitamos un entorno local para:
- Desarrollar sin costos de cloud
- Probar configuraciones antes de desplegar
- Entender cómo funciona Kubernetes en la práctica
- Validar que la aplicación funciona correctamente en un orquestador

## Criterios de Aceptación

- [ ] Existe un cluster Kubernetes local corriendo (kind, minikube, o k3d)
- [ ] La aplicación Rust (de ST-01) está desplegada en el cluster
- [ ] El Deployment mantiene la aplicación corriendo (auto-restart si falla)
- [ ] Existe un Service que expone la aplicación dentro del cluster
- [ ] Puedo ver los logs de la aplicación desde Kubernetes (`kubectl logs`)
- [ ] Si elimino el Pod, Kubernetes lo recrea automáticamente
- [ ] Los manifiestos YAML están versionados en `k8s/local/`

## Especialidades Requeridas

Para completar esta story, se requiere conocimiento en:

- **Kubernetes (Intermedio)**: Conceptos de Pods, Deployments, Services, Namespaces
- **kubectl (Básico-Intermedio)**: Comandos básicos (get, apply, logs, describe, delete)
- **YAML (Básico)**: Sintaxis YAML, estructura de manifiestos de Kubernetes
- **kind/minikube (Básico)**: Crear y gestionar clusters locales
- **Docker (Básico)**: Cargar imágenes en clusters locales

**Nivel de experiencia recomendado**:
- Kubernetes: Intermedio (debe entender los conceptos fundamentales)
- kubectl: Básico-Intermedio (comandos comunes)
- YAML: Básico (solo lectura/edición de manifiestos)
- kind: Básico (solo crear cluster y cargar imágenes)

## Estimación

**8 puntos** (Fibonacci)

**Justificación**:
- Instalación de herramientas (kubectl, kind): 1 punto
- Creación y configuración del cluster: 2 puntos
- Creación de manifiestos YAML: 2 puntos
- Despliegue y troubleshooting: 2 puntos
- Validación y documentación: 1 punto

## Dependencias

- **ST-01**: Aplicación Rust Base (debe estar completada, necesitamos la imagen Docker)

## Tickets Relacionados

- `assigned/martin/TICKET-02-k8s-local.md` (a crear)

## Épica Relacionada

- [`01-setup-inicial-base/`](../01-setup-inicial-base/)

## Notas Técnicas

- Se usa `kind` (Kubernetes in Docker) para simplicidad y ligereza
- El cluster se llama `tiendaleon` para identificación
- Los manifiestos están en `k8s/local/` para separar configuraciones locales de producción
- La imagen Docker se carga manualmente con `kind load docker-image` (no hay registry local)
- El Service usa ClusterIP (solo accesible dentro del cluster por ahora)
