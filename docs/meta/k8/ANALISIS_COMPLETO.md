# ☸️ Análisis Completo: ¿Qué Trae Kubernetes?

## 🎯 ¿Qué Trae Kubernetes?

### **1. Orquestación Automática**
- ✅ **Despliegue**: Gestiona contenedores automáticamente
- ✅ **Escalado**: Aumenta/disminuye pods según demanda
- ✅ **Health Checks**: Verifica que los pods estén saludables
- ✅ **Auto-restart**: Reinicia pods que fallen
- ✅ **Load Balancing**: Distribuye tráfico entre pods

### **2. Gestión de Estado**
- ✅ **ConfigMaps**: Configuración no sensible
- ✅ **Secrets**: Credenciales y datos sensibles
- ✅ **PersistentVolumes**: Almacenamiento persistente
- ✅ **Namespaces**: Aislamiento de recursos

### **3. Networking**
- ✅ **Services**: Exposición interna/externa de pods
- ✅ **Ingress**: Routing HTTP/HTTPS
- ✅ **Network Policies**: Reglas de firewall

### **4. Seguridad**
- ✅ **RBAC**: Control de acceso basado en roles
- ✅ **Pod Security Policies**: Restricciones de seguridad
- ✅ **Secrets Management**: Gestión segura de credenciales

---

## ⚠️ Pitfalls y Peligros Comunes

### **1. Complejidad Operacional**

**Problema:**
- K8s tiene muchos conceptos nuevos (Pods, Deployments, Services, Ingress, etc.)
- Curva de aprendizaje empinada
- Configuración compleja

**Impacto:**
- ⏱️ Tiempo de aprendizaje: 2-4 semanas
- 🐛 Errores de configuración comunes
- 📚 Necesitas documentación constante

**Mitigación:**
- ✅ Empezar simple (solo lo necesario)
- ✅ Documentación completa
- ✅ Desarrollo local con minikube (mismo ambiente)

---

### **2. Costos Inesperados (Runaway Costs)**

**Problema:**
- Auto-scaling puede crear muchos pods
- Sin límites → costos exponenciales
- Bug en código → loops infinitos → miles de pods

**Escenarios Peligrosos:**
```yaml
# PELIGROSO: Sin límites
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 1000  # Si hay bug, puede escalar infinitamente
```

**Ejemplo Real:**
- Bug en health check → K8s piensa que pods están muertos
- Crea nuevos pods constantemente
- **Resultado**: 1000+ pods → $5,000+ en horas

**Protecciones Necesarias:**

#### **A. Resource Quotas (Límites por Namespace)**
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: engine-quota
spec:
  hard:
    pods: "50"              # Máximo 50 pods
    requests.cpu: "10"      # Máximo 10 CPUs
    requests.memory: 20Gi   # Máximo 20GB RAM
    limits.cpu: "20"        # Límite máximo CPU
    limits.memory: 40Gi     # Límite máximo RAM
```

**Qué hace:**
- ✅ Limita pods por namespace
- ✅ Limita recursos totales
- ✅ Previene escalado infinito

#### **B. Limit Ranges (Límites por Pod)**
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: engine-limits
spec:
  limits:
  - default:
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:
      cpu: "250m"
      memory: "256Mi"
    max:
      cpu: "2"
      memory: "2Gi"
    min:
      cpu: "100m"
      memory: "128Mi"
    type: Container
```

**Qué hace:**
- ✅ Cada pod tiene límites máximos
- ✅ No puede consumir más de X CPU/RAM
- ✅ Previene pods "greedy"

#### **C. HPA con Límites**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: engine-api-hpa
spec:
  minReplicas: 3
  maxReplicas: 20  # ⚠️ CRÍTICO: Límite máximo
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

**Qué hace:**
- ✅ Escala entre 3-20 pods (nunca más)
- ✅ Previene escalado infinito

#### **D. Budget Alerts**
```yaml
# Configurar alertas en GKE/EKS
# Alertar cuando:
# - Costo diario > $X
# - Número de pods > Y
# - CPU total > Z
```

**Herramientas:**
- GKE: Budget alerts en Google Cloud Console
- EKS: AWS Cost Anomaly Detection
- Kubecost: Monitoreo de costos en tiempo real

---

### **3. Seguridad: Vulnerabilidades y Ataques**

**Problemas Comunes:**

#### **A. Secrets Expuestos**
```yaml
# ❌ MAL: Secret en texto plano en YAML
env:
- name: DATABASE_URL
  value: "postgresql://user:password@host/db"

# ✅ BIEN: Secret desde Kubernetes Secret
env:
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: postgresql-secret
      key: DATABASE_URL
```

**Riesgo:**
- Secrets en código → comprometidos si alguien accede al repo
- Logs pueden exponer secrets

**Mitigación:**
- ✅ Usar Kubernetes Secrets
- ✅ No commitear secrets
- ✅ Rotar secrets regularmente
- ✅ Usar herramientas como Vault

#### **B. Pods con Privilegios Excesivos**
```yaml
# ❌ PELIGROSO
securityContext:
  privileged: true  # Acceso root completo

# ✅ SEGURO
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
    - ALL
```

**Riesgo:**
- Pod comprometido → acceso root → puede hacer cualquier cosa
- Escalación de privilegios

**Mitigación:**
- ✅ Run as non-root
- ✅ Drop all capabilities
- ✅ Read-only filesystem cuando sea posible

#### **C. Network Policies No Configuradas**
```yaml
# Sin Network Policy → todos los pods pueden comunicarse
# PELIGROSO si un pod es comprometido

# ✅ SEGURO: Network Policy
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
```

**Riesgo:**
- Pod comprometido → puede acceder a otros pods
- Lateral movement

**Mitigación:**
- ✅ Network Policies restrictivas
- ✅ Solo comunicación necesaria

#### **D. Imágenes Vulnerables**
```yaml
# ❌ PELIGROSO: Imagen sin escanear
image: python:3.9

# ✅ SEGURO: Imagen escaneada y actualizada
image: python:3.9-alpine
# + Escaneo con Trivy/Snyk
# + Actualizaciones regulares
```

**Riesgo:**
- Imágenes con vulnerabilidades conocidas
- Exploits públicos

**Mitigación:**
- ✅ Escanear imágenes antes de deploy
- ✅ Usar imágenes minimalistas (Alpine)
- ✅ Actualizar regularmente

---

### **4. Gestión de Estado (Stateful Services)**

**Problema:**
- K8s es stateless por defecto
- Bases de datos en K8s son complejas
- PersistentVolumes pueden fallar

**Solución para tl-engine:**
- ✅ **NO poner PostgreSQL/Redis/RabbitMQ en K8s**
- ✅ Usar servicios gestionados externos (Neon, Upstash, CloudAMQP)
- ✅ K8s solo gestiona pods de aplicación

**Ventajas:**
- ✅ Sin gestión de estado en K8s
- ✅ Backups automáticos
- ✅ Menos complejidad

---

### **5. Debugging y Troubleshooting**

**Problema:**
- Muchas capas (Pods, Services, Ingress, etc.)
- Logs distribuidos
- Difícil encontrar el problema

**Herramientas Necesarias:**
- ✅ `kubectl` para debugging
- ✅ Logs centralizados (ELK, Loki)
- ✅ Monitoring (Prometheus, Grafana)
- ✅ Tracing distribuido (Jaeger)

**Tiempo de Debugging:**
- Problema simple: 30 min - 2 horas
- Problema complejo: 4-8 horas
- Problema crítico: 1-2 días

---

## 🔧 Mantenimiento: ¿Qué Requiere K8s?

### **Mantenimiento Regular**

#### **1. Actualizaciones del Cluster**
- **Frecuencia**: Cada 3-6 meses
- **Tiempo**: 2-4 horas
- **Riesgo**: Medio (puede romper cosas)
- **Automatización**: Parcial (GKE/EKS gestionan algunas)

**Qué actualizar:**
- Kubernetes version (1.28 → 1.29)
- Node OS updates
- Security patches

**Proceso:**
```bash
# 1. Backup de configuraciones
kubectl get all -A -o yaml > backup.yaml

# 2. Actualizar cluster (GKE/EKS)
gcloud container clusters upgrade CLUSTER_NAME

# 3. Verificar que todo funciona
kubectl get pods -A
```

---

#### **2. Actualizaciones de Aplicación**
- **Frecuencia**: Cada deploy
- **Tiempo**: 5-15 minutos
- **Riesgo**: Bajo (rolling updates)
- **Automatización**: ✅ Total (CI/CD)

**Proceso:**
```bash
# Rolling update automático
kubectl set image deployment/engine-api api=tl-engine:v1.2.0

# K8s hace:
# 1. Crea nuevos pods con nueva imagen
# 2. Espera que estén ready
# 3. Quita pods viejos
# 4. Zero-downtime
```

---

#### **3. Monitoreo y Alertas**
- **Frecuencia**: Continuo
- **Tiempo**: Setup inicial 1 día, luego automático
- **Riesgo**: Bajo
- **Automatización**: ✅ Total

**Qué monitorear:**
- CPU/Memoria de pods
- Número de pods
- Error rate
- Response time
- Costos

**Herramientas:**
- Prometheus + Grafana
- Kubecost (costos)
- AlertManager (alertas)

---

#### **4. Backup de Configuraciones**
- **Frecuencia**: Antes de cambios importantes
- **Tiempo**: 5 minutos
- **Riesgo**: Bajo
- **Automatización**: ✅ Total (Git)

**Proceso:**
```bash
# Backup de manifests
kubectl get all -A -o yaml > backup-$(date +%Y%m%d).yaml

# O mejor: Git (versionado)
git commit -m "Backup K8s config"
```

---

#### **5. Limpieza de Recursos**
- **Frecuencia**: Mensual
- **Tiempo**: 30 minutos
- **Riesgo**: Bajo
- **Automatización**: Parcial

**Qué limpiar:**
- Pods completados (Completed)
- Imágenes viejas del registry
- Logs antiguos
- Secrets rotados

---

### **Tiempo Total de Mantenimiento**

| Tarea | Frecuencia | Tiempo/Mes |
|-------|------------|------------|
| Actualizaciones cluster | 3-6 meses | 2-4 horas |
| Deploys aplicación | Diario | 15 min/día = 7.5 horas |
| Monitoreo | Continuo | 1 hora (revisión) |
| Backup | Antes cambios | 30 min |
| Limpieza | Mensual | 30 min |
| **TOTAL** | | **~12 horas/mes** |

**Con automatización:**
- Deploys: Automático (CI/CD)
- Monitoreo: Automático (alertas)
- Backup: Automático (Git)
- **Tiempo real: ~4 horas/mes**

---

## 🤖 Automatizaciones Disponibles

### **1. CI/CD (GitOps)**

**ArgoCD o Flux:**
```yaml
# Git Push → ArgoCD detecta → Deploy automático
# Sin intervención manual
```

**Qué automatiza:**
- ✅ Deploy en cada push
- ✅ Sincronización Git → K8s
- ✅ Rollback automático si falla
- ✅ Multi-ambiente (dev, staging)

**Setup:**
- Tiempo: 1 día
- Mantenimiento: Mínimo

---

### **2. Auto-Scaling (HPA)**

**Horizontal Pod Autoscaler:**
```yaml
# Escala automáticamente basado en CPU/memoria
# Sin intervención manual
```

**Qué automatiza:**
- ✅ Escala pods según demanda
- ✅ Reduce pods cuando baja tráfico
- ✅ Ahorra costos automáticamente

**Setup:**
- Tiempo: 1 hora
- Mantenimiento: Cero

---

### **3. Health Checks y Auto-Restart**

**Liveness/Readiness Probes:**
```yaml
# K8s verifica salud automáticamente
# Reinicia pods que fallen
```

**Qué automatiza:**
- ✅ Detección de pods muertos
- ✅ Restart automático
- ✅ Quita pods no saludables del tráfico

**Setup:**
- Tiempo: 30 minutos
- Mantenimiento: Cero

---

### **4. Resource Management**

**Resource Quotas y Limits:**
```yaml
# Limita recursos automáticamente
# Previene costos inesperados
```

**Qué automatiza:**
- ✅ Limita recursos por namespace
- ✅ Previene escalado infinito
- ✅ Protección contra bugs

**Setup:**
- Tiempo: 1 hora
- Mantenimiento: Cero

---

### **5. Security Scanning**

**Trivy/Snyk:**
```yaml
# Escanea imágenes antes de deploy
# Bloquea imágenes vulnerables
```

**Qué automatiza:**
- ✅ Escaneo de vulnerabilidades
- ✅ Bloqueo de imágenes inseguras
- ✅ Alertas de seguridad

**Setup:**
- Tiempo: 2 horas
- Mantenimiento: Mínimo

---

## 📊 ¿Qué Cubre Exactamente K8s?

### **✅ Lo que K8s SÍ Gestiona:**

1. **Despliegue de Pods**
   - Crea y destruye pods
   - Mantiene número de réplicas
   - Rolling updates

2. **Escalado**
   - Horizontal (más pods)
   - Basado en métricas (CPU, memoria)

3. **Health Checks**
   - Liveness (pod está vivo)
   - Readiness (pod está listo)

4. **Load Balancing**
   - Distribuye tráfico entre pods
   - Service discovery

5. **Networking**
   - Services (exposición)
   - Ingress (routing HTTP)

6. **Configuración**
   - ConfigMaps (config no sensible)
   - Secrets (config sensible)

7. **Almacenamiento**
   - PersistentVolumes (si necesitas)

---

### **❌ Lo que K8s NO Gestiona:**

1. **Aplicación en sí**
   - Tu código
   - Lógica de negocio
   - Endpoints

2. **Bases de Datos**
   - PostgreSQL, Redis, etc.
   - (A menos que los pongas en K8s, pero no recomendado)

3. **Backups**
   - De datos de aplicación
   - De configuraciones (a menos que uses Git)

4. **Monitoreo Avanzado**
   - Métricas de negocio
   - Logs estructurados
   - (K8s da métricas básicas)

5. **CI/CD**
   - Build de imágenes
   - Tests
   - (K8s solo despliega)

---

## 🔄 ¿Cómo Escala K8s?

### **Escalado Horizontal (HPA)**

```mermaid
graph LR
    A[Tráfico Bajo<br/>3 Pods] -->|Aumenta Tráfico| B[CPU > 70%]
    B -->|HPA Detecta| C[Escala a 5 Pods]
    C -->|Más Tráfico| D[CPU > 70%]
    D -->|HPA Detecta| E[Escala a 10 Pods]
    E -->|Tráfico Baja| F[CPU < 30%]
    F -->|HPA Detecta| G[Reduce a 5 Pods]
```

**Cómo funciona:**
1. K8s monitorea CPU/memoria de pods
2. Si promedio > 70% → Crea más pods
3. Si promedio < 30% → Elimina pods
4. Tiempo de reacción: 2-5 minutos

**Configuración:**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 3      # Mínimo siempre
  maxReplicas: 20     # Máximo (protección)
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```

**Límites de Protección:**
- ✅ `maxReplicas`: Nunca más de X pods
- ✅ `minReplicas`: Siempre al menos X pods
- ✅ Resource Quotas: Límite total de recursos

---

### **Escalado Vertical (VPA) - Opcional**

**Aumenta recursos de pods existentes:**
```yaml
# Aumenta CPU/RAM de pods sin crear más
# Menos común, más complejo
```

---

## 🛡️ Protección Contra Costos Impagables

### **Estrategia de Defensa en Múltiples Capas**

#### **Capa 1: Resource Quotas (Namespace)**
```yaml
# Límite total por namespace
apiVersion: v1
kind: ResourceQuota
metadata:
  name: engine-quota
spec:
  hard:
    pods: "50"              # Máximo 50 pods
    requests.cpu: "10"      # Máximo 10 CPUs
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
```

**Protege contra:**
- ✅ Escalado infinito de pods
- ✅ Consumo excesivo de recursos
- ✅ Bugs que crean muchos pods

---

#### **Capa 2: Limit Ranges (Por Pod)**
```yaml
# Límite por pod individual
apiVersion: v1
kind: LimitRange
spec:
  limits:
  - max:
      cpu: "2"        # Pod no puede usar más de 2 CPUs
      memory: "2Gi"   # Pod no puede usar más de 2GB RAM
```

**Protege contra:**
- ✅ Pods "greedy" (consumen todo)
- ✅ Memory leaks
- ✅ Loops infinitos en un pod

---

#### **Capa 3: HPA con Límites**
```yaml
spec:
  minReplicas: 3
  maxReplicas: 20  # ⚠️ CRÍTICO: Nunca más de 20
```

**Protege contra:**
- ✅ Auto-scaling infinito
- ✅ Escalado por bugs

---

#### **Capa 4: Budget Alerts (Cloud Provider)**
```yaml
# GKE Budget Alert
# Alertar cuando costo diario > $50
# Alertar cuando número de pods > 30
```

**Proveedores:**
- **GKE**: Budget alerts en Google Cloud Console
- **EKS**: AWS Cost Anomaly Detection
- **DigitalOcean**: Billing alerts

**Configuración:**
```bash
# GKE
gcloud billing budgets create \
  --billing-account=ACCOUNT_ID \
  --display-name="K8s Budget" \
  --budget-amount=100USD \
  --threshold-rule=percent=80 \
  --threshold-rule=percent=100
```

---

#### **Capa 5: Kubecost (Monitoreo de Costos)**
```yaml
# Herramienta open-source para monitorear costos
# Alertas en tiempo real
# Dashboard de costos por namespace/pod
```

**Qué hace:**
- ✅ Monitorea costos en tiempo real
- ✅ Alertas cuando costos suben
- ✅ Breakdown por namespace/pod
- ✅ Predicción de costos

**Setup:**
```bash
kubectl apply -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/main/kubecost.yaml
```

---

#### **Capa 6: Network Policies (Protección)**
```yaml
# Limita comunicación entre pods
# Previene lateral movement si un pod es comprometido
```

**Protege contra:**
- ✅ Ataques desde pods comprometidos
- ✅ Acceso no autorizado a otros pods

---

### **Ejemplo: Protección Completa**

```yaml
# 1. Resource Quota (Namespace)
apiVersion: v1
kind: ResourceQuota
metadata:
  name: engine-quota
spec:
  hard:
    pods: "50"
    requests.cpu: "10"
    requests.memory: 20Gi

---
# 2. Limit Range (Por Pod)
apiVersion: v1
kind: LimitRange
metadata:
  name: engine-limits
spec:
  limits:
  - max:
      cpu: "2"
      memory: "2Gi"

---
# 3. HPA con Límites
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: engine-api-hpa
spec:
  minReplicas: 3
  maxReplicas: 20  # ⚠️ Límite máximo
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70

---
# 4. Deployment con Resource Limits
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
            cpu: "250m"
            memory: "256Mi"
          limits:
            cpu: "1"      # ⚠️ Límite por pod
            memory: "1Gi" # ⚠️ Límite por pod
```

**Resultado:**
- ✅ Máximo 50 pods (Resource Quota)
- ✅ Cada pod máximo 1 CPU, 1GB RAM (Limit Range)
- ✅ HPA escala máximo a 20 pods
- ✅ **Costo máximo teórico**: 20 pods × $5/pod = $100/mes
- ✅ **Protección**: Múltiples capas

---

## 🚨 Escenarios de Ataque y Protección

### **Escenario 1: Bug en Código → Loop Infinito**

**Qué pasa:**
```python
# Bug en código
while True:
    process_request()  # Loop infinito
    # Consume 100% CPU
```

**Sin protección:**
- Pod consume 100% CPU
- HPA detecta CPU alto → Crea más pods
- Todos los pods en loop → Más CPU
- HPA crea más pods → **Escalado infinito**
- **Resultado**: 1000+ pods → $5,000+ en horas

**Con protección:**
- Pod consume 100% CPU (pero limitado a 1 CPU por Limit Range)
- HPA detecta CPU alto → Intenta escalar
- **Pero**: Resource Quota limita a 50 pods máximo
- **Resultado**: Máximo 50 pods → $250/mes
- **Ahorro**: $4,750

---

### **Escenario 2: Ataque DDoS**

**Qué pasa:**
- Ataque masivo de requests
- CPU sube → HPA escala

**Sin protección:**
- Escala infinitamente
- **Resultado**: Miles de pods → Costos masivos

**Con protección:**
- HPA escala hasta `maxReplicas: 20`
- Resource Quota limita a 50 pods
- **Resultado**: Máximo 50 pods
- **Costo controlado**: ~$250/mes

**Protección adicional:**
- Rate limiting en aplicación (Redis)
- WAF (Web Application Firewall)
- Cloudflare (DDoS protection)

---

### **Escenario 3: Pod Comprometido (Virus/Malware)**

**Qué pasa:**
- Pod comprometido intenta:
  - Crear más pods maliciosos
  - Consumir recursos
  - Acceder a otros pods

**Protecciones:**

#### **A. RBAC (Role-Based Access Control)**
```yaml
# Pod no puede crear otros pods
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: engine-api-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]  # Solo leer, no crear
```

**Protege contra:**
- ✅ Pods creando otros pods
- ✅ Acceso no autorizado a recursos

#### **B. Pod Security Standards**
```yaml
# Restricciones de seguridad
apiVersion: v1
kind: Namespace
metadata:
  name: dev
  labels:
    pod-security.kubernetes.io/enforce: restricted
```

**Protege contra:**
- ✅ Pods con privilegios excesivos
- ✅ Acceso root
- ✅ Capabilities peligrosas

#### **C. Network Policies**
```yaml
# Limita comunicación
# Pod comprometido no puede acceder a otros pods
```

**Protege contra:**
- ✅ Lateral movement
- ✅ Acceso a bases de datos desde pod comprometido

#### **D. Resource Limits**
```yaml
# Pod no puede consumir más de X recursos
# Aunque esté comprometido
```

**Protege contra:**
- ✅ Consumo excesivo de recursos
- ✅ Costos inesperados

---

## 📋 Checklist de Protección

### **Protección de Costos:**
- [ ] Resource Quotas configuradas
- [ ] Limit Ranges configurados
- [ ] HPA con `maxReplicas` limitado
- [ ] Resource limits en cada pod
- [ ] Budget alerts configuradas
- [ ] Kubecost instalado (opcional)

### **Protección de Seguridad:**
- [ ] RBAC configurado
- [ ] Pod Security Standards aplicados
- [ ] Network Policies configuradas
- [ ] Secrets en Kubernetes Secrets (no en código)
- [ ] Imágenes escaneadas (Trivy/Snyk)
- [ ] Run as non-root

### **Protección Operacional:**
- [ ] Health checks configurados
- [ ] Logging centralizado
- [ ] Monitoring configurado
- [ ] Alertas configuradas
- [ ] Backup de configuraciones (Git)

---

## 💰 Estimación de Costos con Protecciones

### **Escenario Normal (Sin Ataques):**
- 3-10 pods según tráfico
- Costo: ~$50-150/mes

### **Escenario con Bug (Con Protecciones):**
- Máximo 50 pods (Resource Quota)
- Costo máximo: ~$250/mes
- **Ahorro vs sin protección**: $4,750+

### **Escenario con Ataque DDoS (Con Protecciones):**
- Máximo 50 pods
- Costo máximo: ~$250/mes
- **Ahorro vs sin protección**: Miles de dólares

---

## ✅ Resumen Ejecutivo

### **¿Qué Trae K8s?**
- ✅ Orquestación automática
- ✅ Auto-escalado
- ✅ Auto-recuperación
- ✅ Load balancing
- ✅ Gestión de configuración

### **Pitfalls:**
- ⚠️ Complejidad operacional
- ⚠️ Costos inesperados (sin protección)
- ⚠️ Seguridad (sin configuración)
- ⚠️ Curva de aprendizaje

### **Mantenimiento:**
- ⏱️ ~4 horas/mes (con automatización)
- ✅ Mayoría automático
- ✅ Actualizaciones cada 3-6 meses

### **Protección Contra Costos:**
- ✅ Resource Quotas (límite total)
- ✅ Limit Ranges (límite por pod)
- ✅ HPA con maxReplicas
- ✅ Budget alerts
- ✅ **Costo máximo controlado**: ~$250/mes (vs miles sin protección)

### **Recomendación:**
- ✅ K8s es poderoso pero requiere configuración correcta
- ✅ Con protecciones adecuadas, costos son predecibles
- ✅ Automatización reduce mantenimiento a mínimo
- ✅ Vale la pena para escalar a millones de requests




