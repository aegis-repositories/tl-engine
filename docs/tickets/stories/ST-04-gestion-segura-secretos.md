# 📖 Story ST-04: Gestión Segura de Secretos

## Descripción

**Como** desarrollador y responsable de seguridad  
**Quiero** que las credenciales sensibles estén gestionadas de forma segura en Kubernetes  
**Para** evitar exponer secretos en el código versionado y poder rotar credenciales sin modificar código

## Contexto

Actualmente las credenciales (PostHog API key) están hardcodeadas en los manifiestos YAML. Esto es un riesgo de seguridad si se sube a Git. Necesitamos:
- Mover credenciales a Kubernetes Secrets
- Referenciar Secrets desde los Deployments
- Asegurar que los YAMLs no contengan valores sensibles
- Establecer buenas prácticas desde el inicio

## Criterios de Aceptación

- [ ] Existe un Kubernetes Secret llamado `engine-secrets` con las credenciales
- [ ] El Deployment referencia el Secret usando `valueFrom.secretKeyRef`
- [ ] El archivo `k8s/local/engine.yaml` NO contiene valores hardcodeados de credenciales
- [ ] La aplicación funciona correctamente leyendo las variables desde el Secret
- [ ] El Secret puede crearse fácilmente con un comando `kubectl`
- [ ] Se documenta cómo crear y actualizar el Secret

## Especialidades Requeridas

Para completar esta story, se requiere conocimiento en:

- **Kubernetes Secrets (Intermedio)**: Crear Secrets, referenciarlos en Deployments, entender cómo funcionan
- **kubectl (Intermedio)**: Comando `create secret`, entender `valueFrom.secretKeyRef`
- **Seguridad Básica (Básico)**: Entender por qué no hardcodear credenciales, buenas prácticas
- **YAML (Básico)**: Editar manifiestos para usar `valueFrom` en lugar de `value`

**Nivel de experiencia recomendado**:
- Kubernetes Secrets: Intermedio (debe entender el concepto y cómo usarlos)
- kubectl: Intermedio (comando create secret)
- Seguridad: Básico (solo entender el problema y la solución)
- YAML: Básico (solo editar estructura existente)

## Estimación

**2 puntos** (Fibonacci)

**Justificación**:
- Crear Secret y actualizar Deployment: 1 punto
- Validación y documentación: 1 punto

## Dependencias

- **ST-02**: Infraestructura K8s Local (necesitamos cluster funcionando)
- **ST-03**: Observabilidad con PostHog (necesitamos las credenciales que vamos a mover a Secrets)

## Tickets Relacionados

- `assigned/martin/TICKET-04-secretos.md` (a crear)

## Épica Relacionada

- [`01-setup-inicial-base/`](../01-setup-inicial-base/)

## Notas Técnicas

- Se usa `kubectl create secret generic` desde línea de comandos (no versionamos valores en Git)
- El Secret se almacena en base64 en etcd (no es encriptación real, pero mejor que texto plano en YAML)
- Para producción, considerar Encryption at Rest y herramientas como Sealed Secrets
- El mismo Secret puede usarse para múltiples variables (POSTHOG_API_KEY, DATABASE_URL futura, etc.)
- Los Secrets son namespace-scoped, podemos tener diferentes valores por ambiente (dev, staging)
