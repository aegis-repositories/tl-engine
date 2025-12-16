# 🎫 Ticket 04: Gestión de Secretos

**Objetivo**: Ahora que todo funciona, tenemos claves de PostHog y futuras bases de datos dispersas. Vamos a poner orden.

## ✅ Checklist
- [ ] **Secretos Fuera de Git**: Verificaste que `k8s/local/engine.yaml` NO tenga tu clave real de PostHog hardcodeada (si vas a hacer commit).
- [ ] **Kubernetes Secrets**: Aprendiste a crear un Secret en K8s.
- [ ] **Documentación**: Guardaste las claves en un gestor de contraseñas seguro.

## 📂 Archivos
1. [seguridad-basica.md](./seguridad-basica.md): **LÉEME PRIMERO**. Problema de secretos en código, Kubernetes Secrets, encriptación, RBAC, diferencias con ConfigMaps, y gestión por ambiente.
