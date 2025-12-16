# 🛡️ Protección Contra Costos Impagables - Guía Completa

## 🚨 El Problema: Costos Runaway

### **Escenarios Reales que Pueden Ocurrir:**

#### **1. Bug en Código → Loop Infinito**
```python
# Bug en código
def process_request():
    while True:  # Loop infinito
        expensive_operation()
        # Consume 100% CPU
```

**Sin protección:**
- Pod consume 100% CPU
- HPA detecta → Crea más pods
- Todos en loop → Más CPU
- HPA crea más → **Escalado infinito**
- **Resultado**: 1000+ pods en horas → $5,000+

**Con protección:**
- Pod limitado a 1 CPU (Limit Range)
- HPA escala máximo a 20 pods (maxReplicas)
- Resource Quota limita a 50 pods total
- **Resultado**: Máximo 50 pods → $250/mes

---

#### **2. Health Check Mal Configurado**
```yaml
# ❌ MAL: Health check siempre falla
livenessProbe:
  httpGet:
    path: /health
    port: 8000
  # Si siempre falla, K8s piensa que pods están muertos
  # Crea nuevos pods constantemente
```

**Sin protección:**
- Health check falla → K8s reinicia pod
- Reinicia falla → Crea nuevo pod
- Nuevo pod falla → Crea otro
- **Resultado**: Cientos de pods → $2,000+

**Con protección:**
- Resource Quota limita pods totales
- **Resultado**: Máximo 50 pods → $250/mes

---

#### **3. Ataque DDoS**
```python
# Ataque masivo de requests
# CPU sube → HPA escala
```

**Sin protección:**
- Escala infinitamente
- **Resultado**: Miles de pods → $10,000+

**Con protección:**
- HPA escala máximo a 20 pods
- Resource Quota limita a 50 pods
- Rate limiting en aplicación
- **Resultado**: Máximo 50 pods → $250/mes

---

## 🛡️ Estrategia de Defensa en Múltiples Capas

### **Capa 1: Resource Quotas (Namespace) - CRÍTICO**

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: engine-quota
  namespace: dev
spec:
  hard:
    # Límite de pods
    pods: "50"              # ⚠️ MÁXIMO 50 pods
    
    # Límite de recursos totales
    requests.cpu: "10"      # Máximo 10 CPUs solicitados
    requests.memory: 20Gi   # Máximo 20GB RAM solicitados
    
    # Límite de recursos límites
    limits.cpu: "20"        # Máximo 20 CPUs límite
    limits.memory: 40Gi     # Máximo 40GB RAM límite
```

**Qué protege:**
- ✅ **Escalado infinito**: Nunca más de 50 pods
- ✅ **Consumo excesivo**: Nunca más de 20 CPUs totales
- ✅ **Bugs masivos**: Limita el daño

**Costo máximo teórico:**
- 50 pods × $5/pod = $250/mes
- **Protección**: $4,750+ ahorrados

---

### **Capa 2: Limit Ranges (Por Pod) - CRÍTICO**

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: engine-limits
  namespace: dev
spec:
  limits:
  - default:
      cpu: "500m"      # Default: 0.5 CPU
      memory: "512Mi"  # Default: 512MB RAM
    defaultRequest:
      cpu: "250m"      # Mínimo solicitado
      memory: "256Mi"
    max:
      cpu: "2"         # ⚠️ MÁXIMO 2 CPUs por pod
      memory: "2Gi"    # ⚠️ MÁXIMO 2GB RAM por pod
    min:
      cpu: "100m"      # Mínimo 0.1 CPU
      memory: "128Mi"  # Mínimo 128MB RAM
    type: Container
```

**Qué protege:**
- ✅ **Pods "greedy"**: Un pod no puede consumir más de 2 CPUs
- ✅ **Memory leaks**: Límite de memoria por pod
- ✅ **Loops infinitos**: Limitados a 2 CPUs máximo

**Ejemplo:**
- Sin límite: Pod consume 10 CPUs → Costo alto
- Con límite: Pod máximo 2 CPUs → Costo controlado

---

### **Capa 3: HPA con Límites - CRÍTICO**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: engine-api-hpa
  namespace: dev
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: engine-api
  minReplicas: 3        # Siempre al menos 3
  maxReplicas: 20       # ⚠️ NUNCA más de 20 pods
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Escala si CPU > 70%
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300  # Espera 5 min antes de reducir
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Pods
        value: 2        # Escala de 2 en 2 pods
        periodSeconds: 60
```

**Qué protege:**
- ✅ **Escalado infinito**: Máximo 20 pods
- ✅ **Escalado rápido**: De 2 en 2 pods (no de golpe)
- ✅ **Reducción gradual**: Espera antes de reducir

**Costo máximo:**
- 20 pods × $5/pod = $100/mes (solo este deployment)

---

### **Capa 4: Resource Limits en Deployment**

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
        resources:
          requests:
            cpu: "250m"      # Solicita 0.25 CPU
            memory: "256Mi"  # Solicita 256MB RAM
          limits:
            cpu: "1"         # ⚠️ MÁXIMO 1 CPU
            memory: "1Gi"    # ⚠️ MÁXIMO 1GB RAM
```

**Qué protege:**
- ✅ **Límite por pod**: Cada pod máximo 1 CPU
- ✅ **Aplicación específica**: Límites por deployment

---

### **Capa 5: Budget Alerts (Cloud Provider)**

#### **GKE (Google Cloud)**
```bash
# Crear budget alert
gcloud billing budgets create \
  --billing-account=ACCOUNT_ID \
  --display-name="K8s Production Budget" \
  --budget-amount=200USD \
  --threshold-rule=percent=80 \
  --threshold-rule=percent=100 \
  --threshold-rule=percent=120
```

**Alertas:**
- 80% del budget → Email
- 100% del budget → Email + SMS
- 120% del budget → Email + SMS + Bloqueo opcional

#### **EKS (AWS)**
```bash
# AWS Cost Anomaly Detection
# Detecta costos inusuales automáticamente
# Alertas cuando costos suben > 50% del promedio
```

#### **DigitalOcean**
```bash
# Billing alerts en dashboard
# Configurar alertas en:
# Settings → Billing → Alerts
```

**Qué protege:**
- ✅ **Detección temprana**: Alerta antes de que sea demasiado tarde
- ✅ **Tiempo de reacción**: Puedes detener antes de costos masivos

---

### **Capa 6: Kubecost (Monitoreo en Tiempo Real)**

```yaml
# Instalar Kubecost
kubectl apply -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/main/kubecost.yaml
```

**Qué hace:**
- ✅ Monitorea costos en tiempo real
- ✅ Alertas cuando costos suben
- ✅ Breakdown por namespace/pod
- ✅ Predicción de costos mensuales
- ✅ Dashboard visual

**Alertas configurables:**
- Costo diario > $X
- Número de pods > Y
- CPU total > Z
- Crecimiento de costos > W%

---

## 🔒 Protección Contra Ataques/Virus

### **1. RBAC (Role-Based Access Control)**

```yaml
# Pods NO pueden crear otros pods
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: engine-api-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]  # Solo leer, NO crear/delete
```

**Protege contra:**
- ✅ Pod comprometido creando pods maliciosos
- ✅ Escalado no autorizado

---

### **2. Pod Security Standards**

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

**Qué restringe:**
- ✅ No privilegios root
- ✅ No capabilities peligrosas
- ✅ Read-only filesystem (cuando sea posible)
- ✅ No host network/pid

**Protege contra:**
- ✅ Pods con acceso excesivo
- ✅ Escalación de privilegios

---

### **3. Network Policies**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: engine-api-policy
spec:
  podSelector:
    matchLabels:
      app: engine-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ingress
    ports:
    - protocol: TCP
      port: 8000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
  - to: []  # Permitir acceso a internet (para APIs externas)
```

**Protege contra:**
- ✅ Pod comprometido accediendo a otros pods
- ✅ Lateral movement
- ✅ Acceso no autorizado a bases de datos

---

### **4. Image Scanning**

```yaml
# En CI/CD, antes de deploy
# Escanear imagen con Trivy
trivy image tl-engine:latest

# Bloquear deploy si hay vulnerabilidades críticas
```

**Protege contra:**
- ✅ Imágenes con vulnerabilidades conocidas
- ✅ Exploits públicos

---

## 📊 Ejemplo Completo de Protección

```yaml
# 1. Namespace con Pod Security
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted

---
# 2. Resource Quota
apiVersion: v1
kind: ResourceQuota
metadata:
  name: engine-quota
  namespace: dev
spec:
  hard:
    pods: "50"
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi

---
# 3. Limit Range
apiVersion: v1
kind: LimitRange
metadata:
  name: engine-limits
  namespace: dev
spec:
  limits:
  - max:
      cpu: "2"
      memory: "2Gi"
    type: Container

---
# 4. HPA con Límites
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: engine-api-hpa
  namespace: dev
spec:
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70

---
# 5. Deployment con Limits
apiVersion: apps/v1
kind: Deployment
metadata:
  name: engine-api
  namespace: dev
spec:
  replicas: 3
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
      containers:
      - name: api
        image: tl-engine:latest
        resources:
          requests:
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "1"
            memory: "1Gi"
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop:
            - ALL

---
# 6. Network Policy
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: engine-api-policy
  namespace: dev
spec:
  podSelector:
    matchLabels:
      app: engine-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: ingress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgresql
```

**Protección Total:**
- ✅ Máximo 50 pods (Resource Quota)
- ✅ Cada pod máximo 2 CPUs (Limit Range)
- ✅ HPA escala máximo a 20 pods
- ✅ Cada pod de API máximo 1 CPU (Deployment limits)
- ✅ Pods sin privilegios (Pod Security)
- ✅ Comunicación limitada (Network Policy)
- ✅ **Costo máximo**: ~$250/mes (vs miles sin protección)

---

## 🚨 Plan de Acción si Detectas Costos Anormales

### **Paso 1: Detener Escalado**
```bash
# Desactivar HPA temporalmente
kubectl delete hpa engine-api-hpa

# Fijar número de pods manualmente
kubectl scale deployment engine-api --replicas=3
```

### **Paso 2: Identificar Problema**
```bash
# Ver pods
kubectl get pods -A

# Ver recursos consumidos
kubectl top pods -A

# Ver logs
kubectl logs -f deployment/engine-api
```

### **Paso 3: Aplicar Fix**
```bash
# Si es bug en código:
# 1. Fix en código
# 2. Build nueva imagen
# 3. Deploy fix

# Si es ataque:
# 1. Bloquear IPs en Ingress
# 2. Aumentar rate limiting
# 3. Contactar Cloudflare/WAF
```

### **Paso 4: Limpiar**
```bash
# Eliminar pods extra
kubectl delete pods --field-selector=status.phase==Succeeded

# Verificar costos
kubectl get pods -A | wc -l
```

---

## ✅ Checklist Final de Protección

### **Protección de Costos:**
- [ ] Resource Quota configurada (máximo pods)
- [ ] Limit Range configurado (máximo por pod)
- [ ] HPA con `maxReplicas` limitado
- [ ] Resource limits en cada deployment
- [ ] Budget alerts configuradas (Cloud provider)
- [ ] Kubecost instalado (opcional pero recomendado)

### **Protección de Seguridad:**
- [ ] RBAC configurado (pods no pueden crear otros pods)
- [ ] Pod Security Standards aplicados
- [ ] Network Policies configuradas
- [ ] Secrets en Kubernetes Secrets
- [ ] Imágenes escaneadas antes de deploy
- [ ] Run as non-root

### **Monitoreo:**
- [ ] Alertas de costos configuradas
- [ ] Alertas de número de pods
- [ ] Dashboard de costos (Kubecost)
- [ ] Logs centralizados

---

## 💰 Cálculo de Costos Máximos

### **Con Todas las Protecciones:**

**Resource Quota:**
- Máximo 50 pods totales
- Máximo 20 CPUs totales

**Limit Range:**
- Cada pod máximo 2 CPUs, 2GB RAM

**HPA:**
- Máximo 20 pods por deployment

**Deployment:**
- Cada pod máximo 1 CPU, 1GB RAM

**Costo Máximo Teórico:**
- 50 pods × $5/pod = **$250/mes**
- **Protección**: Miles de dólares ahorrados

**Costo Normal Esperado:**
- 3-10 pods según tráfico = **$15-50/mes**

---

## 🎯 Resumen Ejecutivo

### **Protección Múltiple:**
1. ✅ Resource Quotas (límite total)
2. ✅ Limit Ranges (límite por pod)
3. ✅ HPA con maxReplicas
4. ✅ Resource limits en deployments
5. ✅ Budget alerts
6. ✅ RBAC y Pod Security

### **Resultado:**
- ✅ **Costo máximo controlado**: ~$250/mes
- ✅ **Protección contra bugs**: Múltiples capas
- ✅ **Protección contra ataques**: Seguridad + límites
- ✅ **Detección temprana**: Alertas automáticas

### **Recomendación:**
- ✅ Implementar TODAS las protecciones desde el inicio
- ✅ No confiar en una sola capa
- ✅ Monitorear costos diariamente al principio
- ✅ Ajustar límites según necesidad real




