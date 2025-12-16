# 🔐 Gestión de Secretos en Kubernetes

## Problema: Secretos en Código

En desarrollo, es común poner credenciales directamente en archivos de configuración:

```yaml
# ❌ MAL: Credenciales hardcodeadas
env:
  - name: POSTHOG_API_KEY
    value: "phc_abc123secretkey"
  - name: DATABASE_URL
    value: "postgres://user:password@host:5432/db"
```

**Problemas**:
- Si este archivo se sube a Git, las credenciales quedan expuestas en el historial.
- Diferentes ambientes (dev, staging, prod) necesitan diferentes credenciales.
- Rotar credenciales requiere editar código y hacer deploy.

## Solución: Kubernetes Secrets

Un **Secret** es un objeto de Kubernetes que almacena datos sensibles (passwords, tokens, keys) de forma encriptada en `etcd`.

### Crear un Secret

**Opción 1: Desde la línea de comandos** (recomendado para desarrollo):
```bash
kubectl create secret generic engine-secrets \
  --from-literal=POSTHOG_API_KEY=phc_abc123 \
  --from-literal=DATABASE_URL=postgres://user:pass@host/db
```

**Opción 2: Desde un archivo YAML** (para versionar la estructura, no los valores):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: engine-secrets
type: Opaque
stringData:  # Kubernetes lo convierte a base64 automáticamente
  POSTHOG_API_KEY: phc_abc123
  DATABASE_URL: postgres://user:pass@host/db
```

**Nota**: `stringData` es para conveniencia (Kubernetes hace el base64). En producción, usa `data` con valores ya en base64.

### Usar un Secret en un Pod

Referencia el Secret en el Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: engine
        env:
        - name: POSTHOG_API_KEY
          valueFrom:
            secretKeyRef:
              name: engine-secrets      # Nombre del Secret
              key: POSTHOG_API_KEY      # Clave dentro del Secret
```

**Qué pasa**:
1. Kubernetes lee el valor del Secret desde `etcd`.
2. Lo inyecta como variable de entorno en el contenedor.
3. El código Rust lee `std::env::var("POSTHOG_API_KEY")` normalmente.

## Seguridad de Secrets en Kubernetes

### Encriptación en etcd

Por defecto, `etcd` almacena Secrets en **base64** (no es encriptación, es encoding). Cualquiera con acceso a `etcd` puede leerlos.

**Mejora**: Habilitar **Encryption at Rest** en el cluster:
- Kubernetes encripta los Secrets antes de guardarlos en `etcd`.
- Requiere configurar un KMS (Key Management Service) o usar un provider de cloud (GCP KMS, AWS KMS).

### Control de Acceso (RBAC)

Usa **Role-Based Access Control** para limitar quién puede leer Secrets:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["engine-secrets"]
  verbs: ["get", "list"]
```

**Buenas prácticas**:
- Principio de menor privilegio: solo dar acceso a Secrets necesarios.
- Rotar Secrets regularmente (cambiar passwords, regenerar API keys).
- No loggear valores de Secrets (evitar `println!("Key: {}", key)`).

## Secrets vs ConfigMaps

| Característica | Secret | ConfigMap |
|----------------|--------|-----------|
| **Propósito** | Datos sensibles | Configuración no sensible |
| **Encriptación** | Base64 (mejorable) | Plain text |
| **Uso** | Passwords, tokens, keys | URLs públicas, feature flags |
| **Ejemplo** | `DATABASE_PASSWORD` | `API_BASE_URL` |

**Regla de oro**: Si es sensible (password, token, key privada), usa Secret. Si es público o no sensible, usa ConfigMap.

## Gestión de Secrets por Ambiente

Diferentes ambientes necesitan diferentes Secrets:

```bash
# Dev
kubectl create secret generic engine-secrets \
  --from-literal=POSTHOG_API_KEY=phc_dev_key \
  --namespace=dev

# Staging
kubectl create secret generic engine-secrets \
  --from-literal=POSTHOG_API_KEY=phc_staging_key \
  --namespace=staging
```

El mismo nombre de Secret (`engine-secrets`) puede existir en diferentes namespaces con valores diferentes.

## Herramientas Externas (Opcional)

Adicionalmente, lee sobre estos temas:
- **Sealed Secrets** (Bitnami): Encripta Secrets para poder versionarlos en Git.
- **External Secrets Operator**: Sincroniza Secrets desde sistemas externos (AWS Secrets Manager, HashiCorp Vault).

**Para este proyecto**: Kubernetes Secrets nativos son suficientes.
