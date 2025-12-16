# 🧠 Conceptos Kubernetes - Fundamentos

## ¿Qué es Kubernetes?

Kubernetes (K8s) es un orquestador de contenedores. En lugar de ejecutar contenedores manualmente con `docker run`, defines el estado deseado en archivos YAML y Kubernetes se encarga de mantener ese estado.

**Analogía**: Si Docker es como un motor de coche, Kubernetes es el piloto automático que maneja una flota de coches, asegurándose de que siempre haya suficientes coches en la carretera, reemplazando los que se averían, y distribuyendo la carga.

## Arquitectura Básica: Control Plane y Nodes

Un cluster de Kubernetes tiene dos tipos de máquinas:

1. **Control Plane** (antes "Master"): Coordina el cluster.
   - `kube-apiserver`: API REST que recibe comandos (crear pods, services, etc.).
   - `etcd`: Base de datos que guarda el estado del cluster.
   - `kube-scheduler`: Decide en qué node ejecutar cada pod.
   - `kube-controller-manager`: Ejecuta controladores que mantienen el estado deseado.

2. **Nodes** (Workers): Ejecutan las cargas de trabajo.
   - `kubelet`: Agente que corre en cada node, ejecuta pods.
   - `kube-proxy`: Maneja networking (routing, load balancing).
   - `container runtime`: Docker, containerd, o CRI-O.

**Para desarrollo local**: `kind` (Kubernetes in Docker) simula ambos en contenedores Docker en tu laptop.

## Conceptos Fundamentales

### 1. Pod: La Unidad de Ejecución

Un **Pod** es el objeto más pequeño que puedes crear en Kubernetes. Representa uno o más contenedores que comparten:
- **Network namespace**: Misma IP, pueden comunicarse vía `localhost`.
- **Storage volumes**: Comparten directorios montados.
- **Ciclo de vida**: Si un contenedor muere, el Pod muere (a menos que tenga restart policy).

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mi-pod
spec:
  containers:
  - name: app
    image: tl-engine:latest
```

**Nota importante**: Raramente creas Pods directamente. Los creas indirectamente a través de Deployments, Jobs, o StatefulSets.

### 2. Deployment: Gestión de Replicas

Un **Deployment** es un controlador que mantiene un número deseado de réplicas de Pods idénticos.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tl-engine
spec:
  replicas: 3  # Quiero 3 copias
  selector:
    matchLabels:
      app: tl-engine
  template:  # Template del Pod a crear
    metadata:
      labels:
        app: tl-engine
    spec:
      containers:
      - name: engine
        image: tl-engine:latest
```

**Qué hace el Deployment**:
- Crea los Pods según el template.
- Monitorea su salud (health checks).
- Si un Pod muere, crea uno nuevo para mantener `replicas: 3`.
- Permite actualizaciones graduales (rolling updates): crea nuevos Pods con la nueva imagen, espera a que estén listos, luego elimina los viejos.

**Labels y Selectors**: Los labels (`app: tl-engine`) son etiquetas clave-valor. El selector del Deployment busca Pods con esos labels. Esto permite que el Deployment "posea" los Pods que creó.

### 3. Service: Abstracción de Red Estable

Los Pods son efímeros: nacen, mueren, y cambian de IP interna. Conectar directamente a una IP de Pod es frágil.

Un **Service** proporciona:
- **IP virtual estable**: Una IP que no cambia aunque los Pods detrás cambien.
- **DNS interno**: Un nombre como `tl-engine-service.default.svc.cluster.local` que resuelve a esa IP.
- **Load balancing**: Distribuye tráfico entre todos los Pods que coinciden con el selector.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tl-engine-service
spec:
  selector:
    app: tl-engine  # Selecciona Pods con este label
  ports:
  - port: 80        # Puerto del Service
    targetPort: 3000  # Puerto del contenedor
  type: ClusterIP  # Solo accesible dentro del cluster
```

**Tipos de Service**:
- **ClusterIP** (default): Solo accesible dentro del cluster.
- **NodePort**: Expone un puerto en cada node (accesible desde fuera).
- **LoadBalancer**: Crea un balanceador de carga externo (en cloud providers).

**Cómo funciona**: El `kube-proxy` en cada node configura reglas de iptables (o IPVS) que redirigen tráfico a la IP del Service hacia las IPs de los Pods seleccionados.

### 4. Namespace: Aislamiento Lógico

Un **Namespace** es una partición lógica del cluster. Permite tener múltiples "entornos" en el mismo cluster físico:
- `default`: Namespace por defecto.
- `kube-system`: Componentes del sistema (no tocar).
- `dev`, `staging`, `prod`: Ambientes de desarrollo.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

Los recursos (Pods, Services) pertenecen a un namespace. Dos Services con el mismo nombre pueden existir en namespaces diferentes.

## Flujo de Trabajo Típico

1. **Desarrollador** escribe un Deployment YAML y ejecuta `kubectl apply -f deployment.yaml`.
2. **kube-apiserver** recibe la petición y guarda el estado deseado en `etcd`.
3. **Deployment Controller** detecta el cambio y crea un ReplicaSet.
4. **ReplicaSet Controller** crea los Pods según el template.
5. **kube-scheduler** asigna cada Pod a un Node disponible.
6. **kubelet** en ese Node crea el contenedor usando el container runtime.
7. **Service Controller** crea reglas de networking para que el Service apunte a los Pods.

## Comandos Básicos de kubectl

- `kubectl get pods`: Lista Pods.
- `kubectl describe pod <nombre>`: Detalles de un Pod (eventos, estado).
- `kubectl logs <pod>`: Logs de un contenedor.
- `kubectl exec -it <pod> -- /bin/sh`: Entra al contenedor (debugging).
- `kubectl apply -f archivo.yaml`: Aplica un manifiesto.
- `kubectl delete -f archivo.yaml`: Elimina recursos definidos en un manifiesto.

## kind: Kubernetes en Docker

`kind` (Kubernetes in Docker) es una herramienta que ejecuta un cluster completo dentro de contenedores Docker. Útil para:
- Desarrollo local sin necesidad de VMs pesadas (como Minikube).
- CI/CD: probar deployments en pipelines.
- Testing de configuraciones antes de subir a producción.

**Limitaciones**: No es para producción. Es para desarrollo/testing.
