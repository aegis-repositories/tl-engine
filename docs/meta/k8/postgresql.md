# 🗄️ Kubernetes + PostgreSQL

## 📊 ¿Cómo K8s interactúa con PostgreSQL?

### **Opción 1: PostgreSQL Externo (Recomendado para tl-engine)**

PostgreSQL corre **fuera de K8s** (Neon, servicio remoto).

```mermaid
graph LR
    A[K8s Pods] -->|Connection String| B[(PostgreSQL<br/>Neon<br/>Externo)]
    
    style A fill:#4a90e2
    style B fill:#336791
```

**Cómo funciona:**
- K8s despliega pods que se conectan a PostgreSQL externo
- Connection string en **Secret** de K8s
- No gestiona PostgreSQL, solo la conexión

**Ventajas:**
- ✅ PostgreSQL gestionado (Neon)
- ✅ Backups automáticos
- ✅ Sin gestión de estado en K8s
- ✅ Escalado independiente

**Configuración:**
```yaml
# Secret con DATABASE_URL
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-secret
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@host:5432/db"
```

---

### **Opción 2: PostgreSQL en K8s (No recomendado para producción)**

PostgreSQL corre **dentro de K8s** como StatefulSet.

```mermaid
graph TB
    A[K8s StatefulSet<br/>PostgreSQL] --> B[PersistentVolume<br/>Storage]
    C[Engine Pods] -->|Connection| A
    
    style A fill:#336791
    style B fill:#95a5a6
    style C fill:#4a90e2
```

**Cómo funciona:**
- StatefulSet gestiona pods de PostgreSQL
- PersistentVolume para datos persistentes
- Service expone PostgreSQL internamente

**Desventajas:**
- ❌ Gestión de backups manual
- ❌ Gestión de estado compleja
- ❌ No recomendado para producción

---

## 🔧 Configuración para tl-engine

### **Usando PostgreSQL Externo (Neon)**

**1. Secret con credenciales:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-secret
type: Opaque
stringData:
  DATABASE_URL: "postgresql://neondb_owner:pass@ep-xxx.aws.neon.tech/enginedb?sslmode=require"
```

**2. Deployment usa el Secret:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-api
spec:
  template:
    spec:
      containers:
      - name: api
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: postgresql-secret
              key: DATABASE_URL
```

**3. Connection Pooling:**
- K8s no gestiona connection pooling
- La aplicación debe gestionarlo (SQLAlchemy, Django ORM)
- Cada pod tiene su propio pool

---

## 📊 Impacto en la Aplicación

### **Connection Management:**
```python
# La app se conecta normalmente
DATABASE_URL = os.environ.get('DATABASE_URL')
# K8s inyecta el valor desde Secret
```

### **Health Checks:**
```yaml
# K8s verifica que la app puede conectar a PostgreSQL
livenessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - "psql $DATABASE_URL -c 'SELECT 1'"
  initialDelaySeconds: 30
  periodSeconds: 10
```

### **Readiness:**
```yaml
# Pod no está listo hasta que PostgreSQL responde
readinessProbe:
  exec:
    command:
    - /bin/sh
    - -c
    - "psql $DATABASE_URL -c 'SELECT 1'"
```

---

## 🔄 Escalado

### **Con PostgreSQL Externo:**
- ✅ Escalar pods independientemente
- ✅ PostgreSQL escala por su cuenta (Neon)
- ✅ Sin límites de K8s

### **Con PostgreSQL en K8s:**
- ⚠️ StatefulSet: 1 réplica (master)
- ⚠️ Puedes agregar réplicas (read replicas)
- ⚠️ Más complejo

---

## ✅ Recomendación para tl-engine

**Usar PostgreSQL Externo (Neon):**
- ✅ Simple
- ✅ Gestionado
- ✅ Backups automáticos
- ✅ Sin gestión de estado en K8s

**K8s solo gestiona:**
- Inyección de DATABASE_URL via Secrets
- Health checks de conexión
- Escalado de pods de aplicación





