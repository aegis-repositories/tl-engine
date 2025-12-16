# 🛠 Desplegando en Kubernetes

Ahora que tienes cluster, vamos a subir tu app.

## 1. El problema de la imagen local
Tu cluster `kind` no puede ver las imágenes de docker de tu laptop por defecto. Tienes que "cargarlas" dentro.

Después de hacer `make docker-build` (Ticket 01), ejecuta:
```bash
kind load docker-image tl-engine:latest --name tiendaleon
```
Esto copia tu imagen adentro del cluster.

## 2. Crear los YAML
Crea una carpeta `k8s/local/` en la raíz del proyecto. Crea un archivo `engine.yaml` adentro:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tl-engine
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tl-engine
  template:
    metadata:
      labels:
        app: tl-engine
    spec:
      containers:
      - name: tl-engine
        image: tl-engine:latest
        imagePullPolicy: Never  # IMPORTANTE: Para que use la imagen local que cargamos
        env:
        - name: RUST_LOG
          value: "info"
---
apiVersion: v1
kind: Service
metadata:
  name: tl-engine-service
  namespace: default
spec:
  selector:
    app: tl-engine
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000 # El puerto donde escuchará tu app (aunque ahora no escucha nada, es preventivo)
```

## 3. Aplicar y Validar
Ejecuta:
```bash
kubectl apply -f k8s/local/engine.yaml
```

Espera unos segundos y revisa:
```bash
kubectl get pods
```
Deberías ver algo como `tl-engine-xyz123   1/1   Running`.

## 4. Ver los Logs
La prueba de fuego. Hay dos formas de obtener el nombre del pod:

**Opción A (Recomendada)**: Usar el label selector (no necesitas el nombre exacto):
```bash
kubectl logs -l app=tl-engine -f
```

**Opción B**: Obtener el nombre del pod primero:
```bash
# Obtener el nombre
POD_NAME=$(kubectl get pods -l app=tl-engine -o jsonpath='{.items[0].metadata.name}')
echo "Pod name: $POD_NAME"

# Ver logs
kubectl logs $POD_NAME -f
```

Si ves "🚀 TL-Engine Iniciado correctamente", ¡has triunfado! Tu código Rust está corriendo orquestado en Kubernetes.

## 🔧 Troubleshooting

### Error: "kind load docker-image" dice "Image: ... not present"
- **Causa**: No has construido la imagen Docker aún.
- **Solución**: Ejecuta `make docker-build` primero (Ticket 01).

### Error: "pod has unbound immediate PersistentVolumeClaims" o "ImagePullBackOff"
- **Causa común**: La imagen no se cargó correctamente en kind.
- **Solución**: 
  1. Verifica que la imagen existe: `docker images | grep tl-engine`
  2. Vuelve a cargar: `kind load docker-image tl-engine:latest --name tiendaleon`
  3. Borra el pod fallido: `kubectl delete pod -l app=tl-engine` (K8s creará uno nuevo)

### El pod está en estado "CrashLoopBackOff"
- **Causa**: Tu aplicación está crasheando al iniciar.
- **Solución**: Revisa los logs: `kubectl logs -l app=tl-engine` para ver el error específico.

### Nota sobre `targetPort: 3000`
La app Rust aún no escucha en ningún puerto (solo imprime logs). El `targetPort: 3000` es preventivo para cuando agreguemos un servidor HTTP más adelante. Por ahora, el Service no se usará, pero está bien dejarlo configurado.
