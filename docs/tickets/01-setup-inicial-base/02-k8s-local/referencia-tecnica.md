# 📚 Referencia Técnica - Kubernetes

## YAML del Deployment: Análisis

```yaml
apiVersion: apps/v1
```
Versión de la API de Kubernetes. `apps/v1` es estable para Deployments.

```yaml
kind: Deployment
```
Tipo de recurso. Otros: `Pod`, `Service`, `ConfigMap`, `Secret`, `Ingress`.

```yaml
metadata:
  name: tl-engine
  namespace: default
```
- `name`: Identificador único del Deployment dentro del namespace.
- `namespace`: Partición lógica del cluster (default si no se especifica).

```yaml
spec:
  replicas: 1
```
Número deseado de Pods. El Deployment creará/eliminará Pods para mantener este número.

```yaml
  selector:
    matchLabels:
      app: tl-engine
```
Selector que identifica qué Pods "pertenecen" a este Deployment. Debe coincidir con los labels del template.

```yaml
  template:
    metadata:
      labels:
        app: tl-engine
    spec:
      containers:
      - name: tl-engine
        image: tl-engine:latest
        imagePullPolicy: Never
```
- `template`: Define cómo se ven los Pods que crea el Deployment.
- `labels`: Deben coincidir con el selector.
- `imagePullPolicy: Never`: No intenta descargar la imagen (usa la que ya está en el cluster, cargada con `kind load`).
  - Otros valores: `Always` (siempre descarga), `IfNotPresent` (solo si no existe localmente).

## YAML del Service: Análisis

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tl-engine-service
spec:
  selector:
    app: tl-engine
```
El selector del Service debe coincidir con los labels de los Pods a los que quiere dirigir tráfico.

```yaml
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```
- `port`: Puerto del Service (donde otros servicios se conectan).
- `targetPort`: Puerto del contenedor (donde escucha tu app).
- `protocol`: TCP o UDP (TCP para HTTP/gRPC).

**Ejemplo**: Si otro Pod hace `curl http://tl-engine-service:80`, el Service redirige a `http://<pod-ip>:3000`.

## Networking en Kubernetes

### DNS Interno

Cada Service obtiene un nombre DNS:
- Formato: `<service-name>.<namespace>.svc.cluster.local`
- Forma corta: `<service-name>` (si estás en el mismo namespace).

**Ejemplo**: Desde otro Pod en `default`:
```rust
// Forma completa
let url = "http://tl-engine-service.default.svc.cluster.local:80";

// Forma corta (mismo namespace)
let url = "http://tl-engine-service:80";
```

### ClusterIP (Default)

El Service obtiene una IP virtual del rango de IPs del cluster (ej: `10.96.0.0/12`). Esta IP:
- Solo es accesible dentro del cluster.
- No cambia aunque los Pods cambien.
- Es manejada por `kube-proxy`.

## Comandos kubectl Avanzados

### Obtener Información Detallada

```bash
# Describe un recurso (muestra eventos, estado, configuración)
kubectl describe deployment tl-engine

# Ver logs de todos los Pods con un label
kubectl logs -l app=tl-engine --tail=100

# Seguir logs en tiempo real
kubectl logs -f -l app=tl-engine

# Ver logs de un contenedor específico (si hay múltiples)
kubectl logs <pod-name> -c <container-name>
```

### Debugging

```bash
# Entrar a un Pod (ejecutar shell)
kubectl exec -it <pod-name> -- /bin/sh

# Ejecutar comando en un Pod
kubectl exec <pod-name> -- env

# Ver eventos del cluster (útil para debugging)
kubectl get events --sort-by='.lastTimestamp'

# Ver configuración actual de un recurso
kubectl get deployment tl-engine -o yaml
```

### Escalado Manual

```bash
# Escalar Deployment a 3 réplicas
kubectl scale deployment tl-engine --replicas=3

# Ver réplicas actuales
kubectl get deployment tl-engine
```

## kind: Comandos Útiles

```bash
# Listar clusters
kind get clusters

# Eliminar un cluster
kind delete cluster --name tiendaleon

# Cargar imagen Docker al cluster
kind load docker-image <image-name>:<tag> --name <cluster-name>

# Exportar logs del cluster (para debugging)
kind export logs /tmp/kind-logs --name tiendaleon
```

## Troubleshooting Común

### Pod en estado `Pending`
**Causa**: No hay recursos suficientes o el scheduler no puede asignar el Pod.
**Solución**: `kubectl describe pod <pod-name>` para ver eventos.

### Pod en estado `ImagePullBackOff`
**Causa**: No puede descargar la imagen (no existe, no tiene permisos, o `imagePullPolicy` incorrecto).
**Solución**: Verificar que la imagen existe localmente y usar `imagePullPolicy: Never` para kind.

### Pod en estado `CrashLoopBackOff`
**Causa**: El contenedor está crasheando al iniciar.
**Solución**: `kubectl logs <pod-name>` para ver el error.

### Service no conecta a Pods
**Causa**: El selector del Service no coincide con los labels de los Pods.
**Solución**: Verificar labels con `kubectl get pods --show-labels` y comparar con el selector del Service.
