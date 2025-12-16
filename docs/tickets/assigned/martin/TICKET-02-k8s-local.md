# 🎫 Ticket Asignado: Despliegue en Kubernetes Local

**Asignado a**: Martin  
**Épica**: [01-setup-inicial-base](../../01-setup-inicial-base/)  
**Depende de**: TICKET-01-setup-rust-base  
**Estimación**: 5 puntos  
**Prioridad**: Alta  
**Estado**: 🔴 Pendiente

---

## 📋 Objetivo

Desplegar la aplicación Rust (del ticket anterior) en un cluster Kubernetes local usando `kind`. La aplicación debe correr dentro del cluster y poder ver sus logs desde Kubernetes.

**Resultado esperado**: Al ejecutar `kubectl get pods`, ves un pod `tl-engine-xxx` en estado `Running`. Al ejecutar `kubectl logs -l app=tl-engine`, ves "🚀 TL-Engine Iniciado correctamente" saliendo desde Kubernetes.

---

## ✅ Definition of Done

Marca este ticket como completado cuando:

- [ ] `kubectl` y `kind` están instalados y funcionando
- [ ] Existe un cluster Kubernetes local llamado `tiendaleon` corriendo
- [ ] La imagen Docker `tl-engine:latest` está cargada en el cluster
- [ ] Existe la carpeta `k8s/local/` con el archivo `engine.yaml`
- [ ] El Deployment está desplegado (`kubectl get deployment tl-engine` muestra 1/1)
- [ ] El Pod está corriendo (`kubectl get pods` muestra estado `Running`)
- [ ] El Service está creado (`kubectl get service tl-engine-service` existe)
- [ ] Los logs muestran el mensaje de inicio desde Kubernetes

---

## 🎯 Instrucciones Paso a Paso

### Paso 1: Verificar Pre-requisitos

**Ubicación**: Cualquier terminal

Ejecuta estos comandos para verificar que tienes las herramientas necesarias:

```bash
# Verificar Docker (kind lo necesita)
docker --version
# Si no está instalado, instálalo según tu distribución Linux

# Verificar kubectl
kubectl version --client
# Si dice "command not found", continúa con el Paso 2.1

# Verificar kind
kind --version
# Si dice "command not found", continúa con el Paso 2.2
```

**Criterio de éxito**: Docker está instalado. `kubectl` y `kind` pueden estar o no instalados (los instalaremos si faltan).

---

### Paso 2: Instalar kubectl (Solo si falta)

**Ubicación**: Cualquier terminal

Si `kubectl version --client` falló en el paso anterior, instálalo:

```bash
# Descargar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Hacer ejecutable
chmod +x kubectl

# Mover a PATH del sistema
sudo mv kubectl /usr/local/bin/

# Verificar instalación
kubectl version --client
```

**Criterio de éxito**: `kubectl version --client` muestra la versión instalada sin errores.

---

### Paso 3: Instalar kind (Solo si falta)

**Ubicación**: Cualquier terminal

Si `kind --version` falló en el Paso 1, instálalo:

```bash
# Descargar kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64

# Hacer ejecutable
chmod +x ./kind

# Mover a PATH del sistema
sudo mv ./kind /usr/local/bin/kind

# Verificar instalación
kind --version
```

**Criterio de éxito**: `kind --version` muestra la versión instalada sin errores.

---

### Paso 4: Crear el Cluster Kubernetes

**Ubicación**: Cualquier terminal

Ejecuta:

```bash
kind create cluster --name tiendaleon
```

**Qué esperar**:
- Verás mensajes sobre la creación del cluster
- Puede tomar un minuto o dos
- Al final dirá "You can now use your cluster with kubectl"

**Criterio de éxito**: El comando termina sin errores y muestra el mensaje de éxito.

---

### Paso 5: Verificar el Cluster

**Ubicación**: Cualquier terminal

Ejecuta estos comandos para verificar que el cluster está funcionando:

```bash
# Ver información del cluster
kubectl cluster-info

# Ver los nodos del cluster
kubectl get nodes
```

**Salida esperada de `kubectl get nodes`**:
```
NAME                 STATUS   ROLES           AGE   VERSION
tiendaleon-control-plane   Ready    control-plane   XXs   v1.XX.X
```

**Criterio de éxito**: Ves al menos un nodo en estado `Ready`.

---

### Paso 6: Construir y Cargar la Imagen Docker

**Ubicación**: Raíz del proyecto (`/home/pango/projects/freelo/tiendaleon/tl-engine/`)

**Importante**: Este paso asume que completaste el TICKET-01 y tienes la imagen Docker construida.

1. **Verifica que la imagen existe localmente**:
   ```bash
   docker images | grep tl-engine
   ```
   - Si **NO existe**: Ejecuta `make docker-build` primero (del ticket anterior)
   - Si **SÍ existe**: Continúa con el paso 6.2

2. **Cargar la imagen en el cluster kind**:
   ```bash
   kind load docker-image tl-engine:latest --name tiendaleon
   ```

**Qué esperar**:
- Verás "Image: ..." con el hash de la imagen
- Puede tomar unos segundos

**Criterio de éxito**: El comando termina sin errores y muestra "Image: ..." con el nombre de tu imagen.

---

### Paso 7: Crear Estructura de Directorios

**Ubicación**: Raíz del proyecto

Crea la carpeta para los manifiestos de Kubernetes:

```bash
mkdir -p k8s/local
```

**Criterio de éxito**: Existe la carpeta `k8s/local/` en la raíz del proyecto.

---

### Paso 8: Crear el Manifiesto de Deployment y Service

**Archivo a crear**: `k8s/local/engine.yaml`

Crea un archivo llamado `engine.yaml` dentro de `k8s/local/` y copia este contenido exacto:

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
        imagePullPolicy: Never
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
      targetPort: 3000
```

**Importante**: 
- `imagePullPolicy: Never` es crucial: le dice a Kubernetes que use la imagen local que cargamos, no que intente descargarla.
- El `targetPort: 3000` es preventivo (la app aún no escucha en ningún puerto, pero lo dejamos configurado para el futuro).

**Criterio de éxito**: El archivo `k8s/local/engine.yaml` existe con este contenido exacto.

---

### Paso 9: Desplegar en Kubernetes

**Ubicación**: Raíz del proyecto

Ejecuta:

```bash
kubectl apply -f k8s/local/engine.yaml
```

**Salida esperada**:
```
deployment.apps/tl-engine created
service/tl-engine-service created
```

**Criterio de éxito**: El comando muestra ambos recursos creados sin errores.

---

### Paso 10: Verificar el Despliegue

**Ubicación**: Cualquier terminal

Espera unos segundos y luego verifica:

```bash
# Ver el Deployment
kubectl get deployment tl-engine

# Ver los Pods
kubectl get pods -l app=tl-engine
```

**Salida esperada de `kubectl get pods`**:
```
NAME                        READY   STATUS    RESTARTS   AGE
tl-engine-xxxxxxxxxx-xxxxx   1/1     Running   0          XXs
```

**Si el Pod está en estado `Pending` o `ContainerCreating`**: Espera unos segundos más y vuelve a ejecutar `kubectl get pods`.

**Criterio de éxito**: Ves un Pod en estado `Running` con `READY 1/1`.

---

### Paso 11: Ver los Logs (Prueba de Fuego)

**Ubicación**: Cualquier terminal

Hay dos formas de ver los logs. Usa la Opción A (más simple):

**Opción A (Recomendada)**: Usar el label selector:
```bash
kubectl logs -l app=tl-engine -f
```

**Opción B**: Obtener el nombre del pod primero:
```bash
# Obtener el nombre del pod
POD_NAME=$(kubectl get pods -l app=tl-engine -o jsonpath='{.items[0].metadata.name}')
echo "Pod name: $POD_NAME"

# Ver logs
kubectl logs $POD_NAME -f
```

**Salida esperada**:
```
🚀 TL-Engine Iniciado correctamente
Esperando tareas...
```

**Para salir del seguimiento de logs**: Presiona `Ctrl+C`.

**Criterio de éxito**: Ves el mensaje "🚀 TL-Engine Iniciado correctamente" saliendo desde Kubernetes.

---

### Paso 12: Verificar el Service

**Ubicación**: Cualquier terminal

Ejecuta:

```bash
kubectl get service tl-engine-service
```

**Salida esperada**:
```
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
tl-engine-service     ClusterIP   10.96.xxx.xxx   <none>        80/TCP    XXs
```

**Criterio de éxito**: El Service existe y tiene una IP asignada (CLUSTER-IP).

---

## 📚 Documentación de Referencia

Para entender el "por qué" de estas decisiones técnicas, consulta:

- **Conceptos**: [`../../01-setup-inicial-base/02-k8s-local/conceptos-k8s.md`](../../01-setup-inicial-base/02-k8s-local/conceptos-k8s.md)
- **Referencia técnica**: [`../../01-setup-inicial-base/02-k8s-local/referencia-tecnica.md`](../../01-setup-inicial-base/02-k8s-local/referencia-tecnica.md)

---

## 🔧 Troubleshooting

### Error: "kind create cluster" falla con "Docker not running"
**Causa**: Docker no está corriendo.
**Solución**: 
1. Inicia Docker Desktop o el servicio Docker: `sudo systemctl start docker`
2. Verifica: `docker ps` debe funcionar sin errores
3. Vuelve a intentar crear el cluster

### Error: "kind load docker-image" dice "Image: ... not present"
**Causa**: No has construido la imagen Docker aún.
**Solución**: 
1. Ve a la raíz del proyecto
2. Ejecuta `make docker-build` (del ticket anterior)
3. Verifica que existe: `docker images | grep tl-engine`
4. Vuelve a cargar: `kind load docker-image tl-engine:latest --name tiendaleon`

### Error: Pod en estado "ImagePullBackOff"
**Causa común**: La imagen no se cargó correctamente o falta `imagePullPolicy: Never`.
**Solución**: 
1. Verifica que la imagen está cargada: `docker exec -it tiendaleon-control-plane crictl images | grep tl-engine`
2. Si no está, vuelve a cargar: `kind load docker-image tl-engine:latest --name tiendaleon`
3. Verifica que `engine.yaml` tiene `imagePullPolicy: Never`
4. Borra el pod fallido: `kubectl delete pod -l app=tl-engine` (K8s creará uno nuevo)

### Error: Pod en estado "CrashLoopBackOff"
**Causa**: Tu aplicación está crasheando al iniciar.
**Solución**: 
1. Revisa los logs: `kubectl logs -l app=tl-engine` (sin `-f`)
2. Busca el error específico en los logs
3. Si el error es de compilación, verifica que `cargo run` funciona localmente primero

### Error: Pod en estado "Pending"
**Causa**: El scheduler no puede asignar el pod a un nodo (poco común en kind con un solo nodo).
**Solución**: 
1. Verifica los nodos: `kubectl get nodes` (debe haber al menos uno en `Ready`)
2. Describe el pod para ver eventos: `kubectl describe pod -l app=tl-engine`
3. Busca mensajes de error en la sección "Events"

### Nota sobre `targetPort: 3000`
La app Rust aún no escucha en ningún puerto (solo imprime logs). El `targetPort: 3000` es preventivo para cuando agreguemos un servidor HTTP más adelante. Por ahora, el Service no se usará para tráfico, pero está bien dejarlo configurado.

---

## ✅ Checklist Final

Antes de marcar este ticket como completado, verifica:

- [ ] `kubectl cluster-info` muestra información del cluster `tiendaleon`
- [ ] `kubectl get nodes` muestra al menos un nodo en estado `Ready`
- [ ] `kubectl get deployment tl-engine` muestra `1/1` en la columna READY
- [ ] `kubectl get pods -l app=tl-engine` muestra un pod en estado `Running`
- [ ] `kubectl logs -l app=tl-engine` muestra "🚀 TL-Engine Iniciado correctamente"
- [ ] `kubectl get service tl-engine-service` muestra el Service con una IP asignada

---

## 📝 Notas

- **Estimación**: 5 puntos (considerando aprendizaje inicial en Kubernetes)
- **Dependencia**: Requiere completar TICKET-01-setup-rust-base primero
- **Si te atascas**: Revisa la sección Troubleshooting o consulta la documentación de referencia
- **Próximo paso**: Una vez completado, el siguiente ticket será integrar PostHog para observabilidad
