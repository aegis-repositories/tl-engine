# 🚀 Pipeline CI/CD - tl-engine

## 🎯 Estrategias de Deployment

### **Opción 1: Git-based Auto-Deploy (Railway) - Recomendado para empezar**

```
GitHub Push → Railway detecta cambios → Build automático → Deploy
```

**Ventajas:**
- ✅ Simple y automático
- ✅ Sin configuración adicional
- ✅ Deploy en cada push
- ✅ Rollback fácil

**Desventajas:**
- ❌ Menos control sobre el proceso
- ❌ No permite tests antes de deploy

---

### **Opción 2: CI/CD con GitHub Actions + Railway**

```
GitHub Push → GitHub Actions (tests) → Railway Deploy → Verificación
```

**Ventajas:**
- ✅ Tests antes de deploy
- ✅ Más control
- ✅ Notificaciones
- ✅ Deploy condicional (solo si tests pasan)

**Desventajas:**
- ❌ Más configuración
- ❌ Más complejo

---

### **Opción 3: CI/CD con GitHub Actions + Kubernetes**

```
GitHub Push → GitHub Actions (tests) → Build Image → Push to Registry → K8s Deploy
```

**Ventajas:**
- ✅ Máximo control
- ✅ Escalado avanzado
- ✅ Multi-ambiente complejo

**Desventajas:**
- ❌ Mucha complejidad
- ❌ Requiere cluster K8s
- ❌ Más mantenimiento

---

## 📊 Comparación: Railway vs Kubernetes

| Aspecto | Railway | Kubernetes |
|---------|---------|------------|
| **Complejidad** | ⭐ Baja | ⭐⭐⭐ Alta |
| **Setup** | 5 minutos | Horas/días |
| **Auto-scaling** | ✅ Automático | ✅ Manual/configurable |
| **Git Integration** | ✅ Nativo | ⚠️ Requiere CI/CD |
| **Costos** | $5-20/mes | $50-200+/mes |
| **Ideal para** | Startups, MVPs | Empresas grandes |

---

## 🎯 ¿Cuándo usar Kubernetes?

### **Usa Kubernetes si:**
- ✅ Necesitas escalado muy avanzado (100+ pods)
- ✅ Múltiples clusters/regiones
- ✅ Compliance estricto (HIPAA, SOC2)
- ✅ Equipo DevOps dedicado
- ✅ Presupuesto alto ($200+/mes)

### **Usa Railway si:**
- ✅ Proyecto pequeño/medio
- ✅ Quieres simplicidad
- ✅ Presupuesto limitado
- ✅ Equipo pequeño
- ✅ Time-to-market rápido

**Para tl-engine: Recomendamos Railway inicialmente**

---

## 🏗️ Pipeline Recomendado para tl-engine

### **Fase 1: Desarrollo Simple (Recomendado para empezar)**

```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Railway Auto   │
│  Deploy         │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│  Build + Deploy │
└─────────────────┘
```

**Configuración:**
1. Conectar GitHub repo a Railway
2. Railway detecta cambios automáticamente
3. Deploy en cada push a `main`

---

### **Fase 2: Con CI/CD (Cuando crezcas)**

```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ GitHub Actions   │
│ - Lint           │
│ - Tests          │
│ - Build          │
└──────┬───────────┘
       │
       ▼ (si tests pasan)
┌──────────────────┐
│  Railway Deploy   │
│  (via API/CLI)    │
└──────────────────┘
```

**Configuración:**
1. GitHub Actions para tests
2. Railway deploy solo si tests pasan
3. Notificaciones en Slack/Discord

---

### **Fase 3: Kubernetes (Si realmente lo necesitas)**

```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│ GitHub Actions   │
│ - Tests          │
│ - Build Image    │
│ - Push Registry  │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐
│  K8s Deploy      │
│  (ArgoCD/Flux)   │
└──────────────────┘
```

---

## 🔄 Estrategia de Branches y Ambientes

### **Estrategia GitFlow Simplificada**

```
main (production)
  │
  ├──→ Railway: production environment
  └──→ Auto-deploy activado

staging
  │
  ├──→ Railway: staging environment
  └──→ Auto-deploy activado

develop
  │
  └──→ No auto-deploy (desarrollo local)
```

**Flujo:**
1. **Desarrollo**: Trabajar en `develop` o feature branches
2. **Staging**: Merge a `staging` → Deploy automático a staging
3. **Production**: Merge a `main` → Deploy automático a production

---

## 📋 Pipeline con GitHub Actions (Ejemplo)

### **`.github/workflows/ci.yml`**

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, staging]
  pull_request:
    branches: [main, staging]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Run linter
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
      
      - name: Run tests
        run: |
          pytest tests/
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL_TEST }}
      
      - name: Build Docker image
        if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/staging'
        run: |
          docker build -t tl-engine:${{ github.sha }} .
  
  deploy-staging:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/staging'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Railway Staging
        uses: bervProject/railway-deploy@v1.0.0
        with:
          railway_token: ${{ secrets.RAILWAY_TOKEN }}
          service: engine-api
          environment: staging
  
  deploy-production:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Railway Production
        uses: bervProject/railway-deploy@v1.0.0
        with:
          railway_token: ${{ secrets.RAILWAY_TOKEN }}
          service: engine-api
          environment: production
```

---

## 🚂 Railway Auto-Deploy (Más Simple)

### **Configuración en Railway:**

1. **Conectar GitHub:**
   - Railway Dashboard → Project → Settings → GitHub
   - Conectar repositorio

2. **Configurar Auto-Deploy:**
   - Settings → Deployments
   - Activar "Auto Deploy"
   - Seleccionar branch: `main` (production), `staging` (staging)

3. **Build Settings:**
   - Root Directory: `/`
   - Build Command: (según framework)
   - Start Command: (según framework)

**Resultado:**
- Push a `main` → Deploy a production
- Push a `staging` → Deploy a staging
- Sin configuración adicional

---

## 🎯 Recomendación Final para tl-engine

### **Fase 1: Empezar Simple (Ahora)**

✅ **Railway Auto-Deploy**
- Conectar GitHub
- Activar auto-deploy
- Deploy automático en cada push

**Ventajas:**
- Rápido de configurar
- Sin mantenimiento
- Funciona de inmediato

---

### **Fase 2: Agregar CI/CD (Cuando crezcas)**

✅ **GitHub Actions + Railway**
- Tests antes de deploy
- Linting
- Notificaciones
- Deploy condicional

**Cuándo:**
- Cuando tengas tests escritos
- Cuando el equipo crezca
- Cuando necesites más control

---

### **Fase 3: Kubernetes (Solo si realmente lo necesitas)**

✅ **K8s + ArgoCD/Flux**
- GitOps completo
- Escalado avanzado
- Multi-región

**Cuándo:**
- Tráfico muy alto (100k+ requests/día)
- Necesitas múltiples regiones
- Equipo DevOps dedicado
- Presupuesto $200+/mes

---

## 📋 Checklist de Implementación

### **Opción Simple (Railway Auto-Deploy):**
- [ ] Conectar GitHub repo a Railway
- [ ] Configurar build/start commands
- [ ] Activar auto-deploy para `main`
- [ ] Activar auto-deploy para `staging`
- [ ] Configurar variables de entorno

### **Opción Avanzada (GitHub Actions):**
- [ ] Crear `.github/workflows/ci.yml`
- [ ] Configurar tests
- [ ] Configurar Railway token en GitHub Secrets
- [ ] Configurar deploy condicional
- [ ] Configurar notificaciones

---

## 🔄 Flujo Completo Recomendado

```
1. Developer hace cambios
   ↓
2. Push a branch (feature/develop)
   ↓
3. Pull Request a staging
   ↓
4. GitHub Actions: Tests + Lint
   ↓
5. Si pasa → Merge a staging
   ↓
6. Railway: Auto-deploy a staging
   ↓
7. Testing en staging
   ↓
8. Si OK → Pull Request a main
   ↓
9. GitHub Actions: Tests + Lint
   ↓
10. Si pasa → Merge a main
   ↓
11. Railway: Auto-deploy a production
```

---

## 💡 Resumen

**¿Se maneja desde Git y deploys?**
✅ **SÍ** - Railway tiene auto-deploy desde Git nativo

**¿Cuál es la mejor estrategia?**
✅ **Empezar con Railway Auto-Deploy** (simple)
✅ **Agregar GitHub Actions después** (cuando crezcas)

**¿Dónde entran los K8s?**
⚠️ **Solo si realmente lo necesitas** (tráfico masivo, multi-región)
✅ **Para tl-engine: NO necesario ahora**

