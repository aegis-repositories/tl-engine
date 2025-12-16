# 📊 PostHog - Guía Completa

## 🎯 ¿Qué es PostHog?

PostHog es una plataforma de **Product Analytics** y **Product Intelligence** open-source que permite:

- ✅ **Event Tracking**: Rastrear eventos en tiempo real
- ✅ **User Analytics**: Analizar comportamiento de usuarios
- ✅ **Feature Flags**: Gestionar features sin deploy
- ✅ **Session Recordings**: Grabar sesiones de usuarios
- ✅ **A/B Testing**: Probar variantes de features
- ✅ **Funnels**: Analizar conversión
- ✅ **Cohorts**: Segmentar usuarios

---

## ⚠️ Estado Actual: Kubernetes

**Importante**: PostHog **descontinuó el soporte oficial para despliegues en Kubernetes** (febrero 2023).

**Razón**: Mantener Helm charts y soporte K8s era costoso y complejo.

**Recomendación**: Usar **PostHog Cloud** (SaaS) en vez de self-hosted en K8s.

### **Opciones Disponibles:**

1. **PostHog Cloud** (Recomendado)
   - ✅ SaaS gestionado
   - ✅ Actualizaciones automáticas
   - ✅ Soporte oficial
   - ✅ Tier gratuito: 1M eventos/mes
   - ✅ Escalabilidad gestionada

2. **Self-hosted con Docker Compose**
   - ⚠️ Para volúmenes pequeños
   - ⚠️ Sin soporte oficial para K8s
   - ⚠️ Mantenimiento manual

3. **PostHog en K8s (No recomendado)**
   - ❌ Sin soporte oficial
   - ❌ Sin actualizaciones garantizadas
   - ❌ Complejidad alta

---

## 🚀 Integración con tl-engine

### **1. Crear Cuenta y Proyecto**

1. Ir a https://app.posthog.com
2. Crear cuenta (gratis)
3. Crear proyecto
4. Obtener API Key desde: Settings → Project → API Keys

### **2. Configuración de Variables de Entorno**

```bash
# .env
POSTHOG_API_KEY="phc_xxxxxxxxxxxxx"
POSTHOG_HOST="https://app.posthog.com"  # Default, puede cambiar si self-hosted
```

### **3. Instalación del SDK**

```bash
# Python
pip install posthog

# O en requirements.txt
echo "posthog>=3.0.0" >> requirements.txt
```

### **4. Inicialización en Código**

```python
from posthog import Posthog
import os

# Inicializar cliente (singleton recomendado)
posthog = Posthog(
    project_api_key=os.environ.get('POSTHOG_API_KEY'),
    host=os.environ.get('POSTHOG_HOST', 'https://app.posthog.com'),
    # Opciones adicionales
    flush_at=20,  # Enviar en lotes de 20 eventos
    flush_interval=10,  # O cada 10 segundos
    max_retries=3,  # Reintentos en caso de error
)
```

### **5. Uso Básico - Track Eventos**

```python
# Track evento simple
posthog.capture(
    distinct_id='engine-123',  # ID único (puede ser user_id, engine_id, etc.)
    event='engine_executed',
    properties={
        'engine_id': 'engine-123',
        'duration_ms': 150,
        'status': 'success',
        'engine_type': 'data_processor'
    }
)

# Track con timestamp
from datetime import datetime
posthog.capture(
    distinct_id='engine-123',
    event='engine_executed',
    properties={
        'engine_id': 'engine-123',
        'duration_ms': 150,
        'status': 'success'
    },
    timestamp=datetime.now()  # Opcional, default es ahora
)
```

### **6. Uso Avanzado - Identificar Usuarios**

```python
# Identificar usuario (asociar propiedades permanentes)
posthog.identify(
    distinct_id='user-123',
    properties={
        'email': 'user@example.com',
        'name': 'John Doe',
        'plan': 'pro',
        'created_at': '2024-01-01'
    }
)

# Luego track eventos con ese distinct_id
posthog.capture(
    distinct_id='user-123',
    event='api_request',
    properties={
        'endpoint': '/api/v1/engines/execute',
        'method': 'POST'
    }
)
```

### **7. Feature Flags**

```python
# Verificar si feature flag está activo
is_enabled = posthog.feature_enabled(
    'new-engine-feature',
    'user-123'
)

if is_enabled:
    # Usar nueva feature
    new_engine_logic()
else:
    # Usar feature antigua
    old_engine_logic()
```

---

## 📊 Eventos Clave para tl-engine

### **Eventos Recomendados**

```python
# Diccionario de eventos importantes
EVENTS = {
    # Engine Events
    'engine_executed': {
        'description': 'Engine ejecutado exitosamente',
        'properties': ['engine_id', 'duration_ms', 'engine_type', 'status']
    },
    'engine_failed': {
        'description': 'Engine falló',
        'properties': ['engine_id', 'error_type', 'error_message', 'duration_ms']
    },
    'engine_queued': {
        'description': 'Engine encolado en RabbitMQ',
        'properties': ['engine_id', 'queue_name', 'priority']
    },
    
    # API Events
    'api_request': {
        'description': 'Request a la API',
        'properties': ['endpoint', 'method', 'status_code', 'response_time_ms']
    },
    'api_error': {
        'description': 'Error en API',
        'properties': ['endpoint', 'method', 'status_code', 'error_type']
    },
    'rate_limit_exceeded': {
        'description': 'Rate limit excedido',
        'properties': ['api_key', 'endpoint', 'limit', 'current']
    },
    
    # Worker Events
    'worker_task_started': {
        'description': 'Tarea de worker iniciada',
        'properties': ['task_id', 'task_type', 'queue_name']
    },
    'worker_task_completed': {
        'description': 'Tarea de worker completada',
        'properties': ['task_id', 'task_type', 'duration_ms', 'status']
    },
    'worker_task_failed': {
        'description': 'Tarea de worker falló',
        'properties': ['task_id', 'task_type', 'error_type', 'retry_count']
    },
    
    # Cache Events
    'cache_hit': {
        'description': 'Cache hit en Redis',
        'properties': ['cache_key', 'cache_type', 'ttl']
    },
    'cache_miss': {
        'description': 'Cache miss en Redis',
        'properties': ['cache_key', 'cache_type']
    },
    
    # Database Events
    'database_query_slow': {
        'description': 'Query lenta en PostgreSQL',
        'properties': ['query_type', 'duration_ms', 'table_name']
    },
    'database_connection_pool_exhausted': {
        'description': 'Pool de conexiones agotado',
        'properties': ['pool_size', 'active_connections', 'waiting_connections']
    },
}
```

### **Implementación en FastAPI**

```python
from fastapi import FastAPI, Request
from posthog import Posthog
import time
import os

app = FastAPI()
posthog = Posthog(
    project_api_key=os.environ.get('POSTHOG_API_KEY'),
    host=os.environ.get('POSTHOG_HOST', 'https://app.posthog.com')
)

@app.middleware("http")
async def track_requests(request: Request, call_next):
    start_time = time.time()
    
    # Obtener distinct_id (de header, token, etc.)
    distinct_id = request.headers.get('X-User-ID', 'anonymous')
    
    try:
        response = await call_next(request)
        duration_ms = (time.time() - start_time) * 1000
        
        # Track request
        posthog.capture(
            distinct_id=distinct_id,
            event='api_request',
            properties={
                'endpoint': str(request.url.path),
                'method': request.method,
                'status_code': response.status_code,
                'response_time_ms': duration_ms,
                'user_agent': request.headers.get('user-agent'),
            }
        )
        
        return response
    except Exception as e:
        # Track error
        posthog.capture(
            distinct_id=distinct_id,
            event='api_error',
            properties={
                'endpoint': str(request.url.path),
                'method': request.method,
                'error_type': type(e).__name__,
                'error_message': str(e),
            }
        )
        raise

@app.post("/api/v1/engines/execute")
async def execute_engine(request: EngineRequest):
    start_time = time.time()
    
    try:
        result = await process_engine(request)
        duration_ms = (time.time() - start_time) * 1000
        
        # Track éxito
        posthog.capture(
            distinct_id=f'engine-{request.engine_id}',
            event='engine_executed',
            properties={
                'engine_id': request.engine_id,
                'duration_ms': duration_ms,
                'status': 'success',
                'engine_type': request.engine_type,
            }
        )
        
        return result
    except Exception as e:
        duration_ms = (time.time() - start_time) * 1000
        
        # Track error
        posthog.capture(
            distinct_id=f'engine-{request.engine_id}',
            event='engine_failed',
            properties={
                'engine_id': request.engine_id,
                'duration_ms': duration_ms,
                'status': 'error',
                'error_type': type(e).__name__,
                'error_message': str(e),
            }
        )
        raise
```

---

## 🔧 PostHog CLI (No Oficial)

PostHog **NO tiene CLI oficial**, pero puedes crear uno:

### **Opción 1: Script Python Simple**

```python
#!/usr/bin/env python3
# posthog-cli.py
import sys
import json
from posthog import Posthog

if len(sys.argv) < 2:
    print("Usage: posthog-cli.py API_KEY [HOST] < event.json")
    sys.exit(1)

api_key = sys.argv[1]
host = sys.argv[2] if len(sys.argv) > 2 else 'https://app.posthog.com'

posthog = Posthog(project_api_key=api_key, host=host)

# Leer evento de stdin
event = json.loads(sys.stdin.read())
posthog.capture(**event)

print("✅ Event tracked")
```

**Uso:**
```bash
# Hacer ejecutable
chmod +x posthog-cli.py

# Track evento
echo '{
  "distinct_id": "engine-123",
  "event": "test_event",
  "properties": {
    "test": true
  }
}' | python posthog-cli.py $POSTHOG_API_KEY
```

### **Opción 2: Usar API REST Directamente**

```bash
# Script bash para track eventos
#!/bin/bash
# posthog-track.sh

API_KEY="${POSTHOG_API_KEY}"
HOST="${POSTHOG_HOST:-https://app.posthog.com}"

distinct_id="$1"
event="$2"
shift 2
properties="$@"

curl -X POST "$HOST/capture/" \
  -H "Content-Type: application/json" \
  -d "{
    \"api_key\": \"$API_KEY\",
    \"event\": \"$event\",
    \"distinct_id\": \"$distinct_id\",
    \"properties\": {$properties}
  }"
```

**Uso:**
```bash
chmod +x posthog-track.sh
./posthog-track.sh "engine-123" "test_event" '"test": true'
```

---

## 💰 Costos

### **PostHog Cloud**

- **Tier Gratuito**: 
  - 1M eventos/mes
  - 1M session recordings/mes
  - Feature flags ilimitados
  - **Costo**: $0/mes

- **Starter** (después de 1M eventos):
  - $0.000225 por evento
  - **Ejemplo**: 2M eventos/mes = $225/mes

- **Para tl-engine**:
  - Inicio: Probablemente gratis (1M eventos/mes es mucho)
  - Escalado: ~$0.000225 por evento adicional

### **Self-hosted**

- **Costo**: $0 (open-source)
- **Mantenimiento**: Alto (actualizaciones manuales)
- **Infraestructura**: ~$50-200/mes (servidores)

**Recomendación**: Empezar con Cloud, considerar self-hosted solo si:
- Más de 10M eventos/mes
- Requisitos de privacidad estrictos
- Equipo DevOps dedicado

---

## 📊 Dashboards y Análisis

### **Dashboards Recomendados**

1. **Engine Performance**
   - Eventos: `engine_executed`, `engine_failed`
   - Métricas: Tasa de éxito, tiempo promedio, errores por tipo

2. **API Performance**
   - Eventos: `api_request`, `api_error`
   - Métricas: Requests/segundo, tiempo de respuesta, tasa de errores

3. **Worker Performance**
   - Eventos: `worker_task_started`, `worker_task_completed`
   - Métricas: Tareas/segundo, tiempo promedio, tasa de fallos

4. **Cache Performance**
   - Eventos: `cache_hit`, `cache_miss`
   - Métricas: Tasa de cache hits, ahorro de queries

### **Funnels Útiles**

1. **Engine Execution Funnel**
   - `engine_queued` → `engine_executed` → `engine_completed`
   - Identificar dónde se pierden engines

2. **API Request Funnel**
   - `api_request` → `cache_hit` OR `database_query` → `api_response`
   - Optimizar flujo de requests

---

## ✅ Mejores Prácticas

### **1. Usar Distinct IDs Consistentes**

```python
# ✅ BIEN: Usar ID consistente
user_id = get_user_id_from_token(token)
posthog.capture(distinct_id=user_id, ...)

# ❌ MAL: Usar IDs diferentes cada vez
posthog.capture(distinct_id=f'user-{random.randint(1, 1000)}', ...)
```

### **2. Batch Events (Automático)**

```python
# PostHog SDK hace batch automáticamente
# flush_at=20 → Envía en lotes de 20
# flush_interval=10 → O cada 10 segundos
```

### **3. No Bloquear Requests**

```python
# ✅ BIEN: Async, no bloquea
posthog.capture(...)  # Retorna inmediatamente

# ❌ MAL: Esperar respuesta
response = posthog.capture(...)  # No necesario
```

### **4. Incluir Contexto Útil**

```python
# ✅ BIEN: Propiedades útiles
posthog.capture(
    distinct_id=user_id,
    event='engine_executed',
    properties={
        'engine_id': engine_id,
        'duration_ms': duration_ms,
        'engine_type': engine_type,
        'user_plan': user_plan,  # Contexto adicional
        'environment': 'dev',
    }
)
```

---

## 🚨 Troubleshooting

### **Eventos No Aparecen**

1. Verificar API Key
2. Verificar host (https://app.posthog.com)
3. Verificar que eventos se están enviando (logs)
4. Verificar rate limits (tier gratuito tiene límites)

### **Performance Issues**

1. Aumentar `flush_at` (más eventos por batch)
2. Aumentar `flush_interval` (menos frecuente)
3. Usar async/background tasks

---

## 📋 Checklist de Integración

- [ ] Cuenta PostHog creada
- [ ] API Key obtenida
- [ ] Variables de entorno configuradas
- [ ] SDK instalado
- [ ] Cliente inicializado
- [ ] Eventos clave definidos
- [ ] Tracking implementado en API
- [ ] Tracking implementado en Workers
- [ ] Dashboards creados
- [ ] Alertas configuradas (opcional)

---

## 🎯 Resumen

**PostHog es esencial para:**
- ✅ Entender cómo se usa tl-engine
- ✅ Identificar problemas de performance
- ✅ Optimizar basado en datos reales
- ✅ Feature flags sin deploy

**Recomendación:**
- ✅ Empezar con PostHog Cloud (gratis)
- ✅ Integrar desde día 1
- ✅ Track eventos clave desde el inicio
- ✅ Revisar dashboards regularmente

**Costo:**
- ✅ Inicio: $0/mes (tier gratuito)
- ✅ Escalado: ~$0.000225 por evento adicional



