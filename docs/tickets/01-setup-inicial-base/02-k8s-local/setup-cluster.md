# 🛠 Setup del Cluster Local

## 1. Instalar Herramientas
Necesitas dos cosas instaladas en tu linux. **Primero verifica si ya las tienes**:

```bash
# Verificar kubectl
kubectl version --client
# Si dice "command not found", instálalo (ver abajo)

# Verificar kind
kind --version
# Si dice "command not found", instálalo (ver abajo)
```

### Si necesitas instalar kubectl:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### Si necesitas instalar kind:
```bash
# (O usa minikube si prefieres, pero kind es muy ligero)
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

**Nota**: Necesitas tener Docker instalado y corriendo para que `kind` funcione.

## 2. Crear el Cluster
Ejecuta:
```bash
kind create cluster --name tiendaleon
```
Esto tardará un minuto. Al terminar, dirá "You can now use your cluster with kubectl".

## 3. Verificar
Prueba que estás conectado:
```bash
kubectl cluster-info
kubectl get nodes
```
Deberías ver un "control-plane" en estado Ready. ¡Ya tienes tu servidor de nube personal!
