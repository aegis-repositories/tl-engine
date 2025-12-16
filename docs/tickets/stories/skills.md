# 🎯 Habilidades Requeridas (Skills)

Este documento lista brevemente las habilidades técnicas necesarias para completar las stories del proyecto `tl-engine`.

## Habilidades por Nivel

### Básico
Conocimiento suficiente para seguir tutoriales y documentación, realizar tareas simples con supervisión.

### Intermedio
Capacidad de trabajar independientemente, resolver problemas comunes, y aplicar conceptos en contextos nuevos.

### Avanzado
Experto en el tema, puede diseñar soluciones complejas y mentorear a otros.

---

## Lista de Habilidades

### Rust

**Nivel requerido**: Básico a Intermedio

**Descripción breve**: Lenguaje de programación de sistemas compilado.

**Conocimientos necesarios**:
- Sintaxis básica (variables, funciones, structs, enums)
- Ownership y borrowing (conceptos fundamentales)
- Manejo de errores con `Result` y `Option`
- Async/await con Tokio
- Uso de crates y `Cargo.toml`
- Lectura de variables de entorno

**Dónde se usa**: ST-01, ST-03

---

### Docker

**Nivel requerido**: Básico a Intermedio

**Descripción breve**: Plataforma de contenedores para empaquetar aplicaciones.

**Conocimientos necesarios**:
- Conceptos básicos (imágenes, contenedores, Dockerfile)
- Multistage builds (optimización de imágenes)
- Comandos básicos (`build`, `run`, `images`)
- Optimización de Dockerfiles (cacheo, tamaño de imagen)
- Cargar imágenes en clusters locales (kind)

**Dónde se usa**: ST-01, ST-02

---

### Kubernetes

**Nivel requerido**: Intermedio

**Descripción breve**: Orquestador de contenedores para gestionar aplicaciones en producción.

**Conocimientos necesarios**:
- Conceptos fundamentales (Pods, Deployments, Services, Namespaces)
- Comandos `kubectl` básicos (`get`, `apply`, `logs`, `describe`, `delete`)
- Lectura y escritura de manifiestos YAML
- Secrets y ConfigMaps
- Networking básico (ClusterIP, selectors, labels)
- Troubleshooting común (ImagePullBackOff, CrashLoopBackOff)

**Dónde se usa**: ST-02, ST-04

---

### kubectl

**Nivel requerido**: Básico a Intermedio

**Descripción breve**: CLI para interactuar con clusters de Kubernetes.

**Conocimientos necesarios**:
- Comandos básicos (`get`, `apply`, `delete`, `logs`, `describe`)
- Crear recursos (`create secret`, `create namespace`)
- Selectors y labels (`-l app=name`)
- JSONPath para obtener valores (`-o jsonpath`)
- Configuración de contexto y cluster

**Dónde se usa**: ST-02, ST-04

---

### YAML

**Nivel requerido**: Básico

**Descripción breve**: Formato de serialización de datos usado en manifiestos de Kubernetes.

**Conocimientos necesarios**:
- Sintaxis básica (indentación, listas, objetos)
- Lectura de manifiestos de Kubernetes
- Edición de archivos YAML existentes
- Estructura de Deployments, Services, Secrets

**Dónde se usa**: ST-02, ST-04

---

### kind / Minikube

**Nivel requerido**: Básico

**Descripción breve**: Herramientas para crear clusters Kubernetes locales.

**Conocimientos necesarios**:
- Instalación de kind o minikube
- Crear cluster local (`kind create cluster`)
- Cargar imágenes Docker en el cluster (`kind load docker-image`)
- Verificar que el cluster está funcionando

**Dónde se usa**: ST-02

---

### APIs REST / HTTP

**Nivel requerido**: Básico

**Descripción breve**: Protocolo HTTP para comunicación entre servicios.

**Conocimientos necesarios**:
- Conceptos básicos (GET, POST, headers, JSON)
- Hacer requests HTTP desde Rust (`reqwest`)
- Entender respuestas y códigos de estado
- Manejo básico de errores de red

**Dónde se usa**: ST-03

---

### PostHog

**Nivel requerido**: Básico

**Descripción breve**: Plataforma de analytics y product analytics.

**Conocimientos necesarios**:
- Crear cuenta y proyecto en PostHog Cloud
- Obtener API key del proyecto
- Entender el formato de eventos (event name, properties)
- Ver eventos en el dashboard web

**Dónde se usa**: ST-03

---

### Variables de Entorno

**Nivel requerido**: Básico

**Descripción breve**: Configuración externa a través de variables de entorno.

**Conocimientos necesarios**:
- Leer variables de entorno en Rust (`std::env::var`)
- Configurar variables en Kubernetes (env vars, Secrets)
- Archivo `.env` para desarrollo local
- Diferencia entre desarrollo y producción

**Dónde se usa**: ST-03, ST-04

---

### Seguridad Básica

**Nivel requerido**: Básico

**Descripción breve**: Buenas prácticas de seguridad para no exponer credenciales.

**Conocimientos necesarios**:
- Por qué no hardcodear credenciales en código
- Uso de Secrets en lugar de valores en texto plano
- Principio de menor privilegio
- No loggear valores sensibles

**Dónde se usa**: ST-04

---

### Makefiles

**Nivel requerido**: Básico

**Descripción breve**: Sistema de automatización de build usando Make.

**Conocimientos necesarios**:
- Sintaxis básica (targets, commands)
- Agregar nuevos targets a Makefile existente
- Variables y dependencias básicas

**Dónde se usa**: ST-01

---

## Resumen por Story

| Story | Habilidades Principales | Nivel Promedio |
|-------|------------------------|----------------|
| **ST-01** | Rust, Docker, Makefiles | Básico-Intermedio |
| **ST-02** | Kubernetes, kubectl, YAML, kind | Intermedio |
| **ST-03** | Rust (async), APIs REST, PostHog, Variables de entorno | Básico-Intermedio |
| **ST-04** | Kubernetes Secrets, kubectl, Seguridad básica | Intermedio |

---

## Recursos de Aprendizaje

### Rust
- [The Rust Book](https://doc.rust-lang.org/book/) - Documentación oficial
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/) - Ejemplos prácticos

### Docker
- [Docker Documentation](https://docs.docker.com/) - Documentación oficial
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

### Kubernetes
- [Kubernetes Documentation](https://kubernetes.io/docs/) - Documentación oficial
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### PostHog
- [PostHog Documentation](https://posthog.com/docs) - Documentación oficial
- [PostHog API Reference](https://posthog.com/docs/api)
