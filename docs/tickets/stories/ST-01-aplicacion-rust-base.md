# 📖 Story ST-01: Aplicación Rust Base

## Descripción

**Como** desarrollador del equipo  
**Quiero** tener una aplicación Rust base contenerizada y funcional  
**Para** establecer la base técnica del proyecto `tl-engine` y poder desplegarla en cualquier entorno

## Contexto

Necesitamos un punto de partida sólido para el engine. La aplicación debe ser:
- Profesional: estructura de código limpia y organizada
- Contenerizada: empaquetada en Docker para portabilidad
- Ejecutable: comandos simples para desarrollo local
- Optimizada: imagen Docker pequeña para despliegues rápidos

## Criterios de Aceptación

- [ ] Existe una aplicación Rust que compila sin errores
- [ ] La aplicación imprime un mensaje de inicio cuando se ejecuta
- [ ] Existe un Dockerfile que construye una imagen funcional
- [ ] La imagen Docker final pesa menos de 300MB
- [ ] El Makefile tiene comandos `run`, `build`, `docker-build`, y `docker-run` funcionando
- [ ] La aplicación puede ejecutarse tanto localmente (`cargo run`) como en contenedor (`docker run`)

## Especialidades Requeridas

Para completar esta story, se requiere conocimiento en:

- **Rust (Básico)**: Sintaxis básica, estructura de proyectos con Cargo, manejo de dependencias
- **Docker (Intermedio)**: Multistage builds, optimización de imágenes, Dockerfile best practices
- **Makefiles (Básico)**: Crear y modificar targets, comandos básicos

**Nivel de experiencia recomendado**: 
- Rust: Principiante (puede aprender sobre la marcha)
- Docker: Intermedio (debe entender multistage builds)
- Makefiles: Básico (solo necesita agregar comandos)

## Estimación

**5 puntos** (Fibonacci)

**Justificación**:
- Setup inicial de Rust: 1 punto
- Configuración de dependencias: 1 punto
- Creación de Dockerfile optimizado: 2 puntos
- Testing y ajustes: 1 punto

## Dependencias

- Ninguna (story inicial)

## Tickets Relacionados

- [`assigned/martin/TICKET-01-setup-rust-base.md`](../assigned/martin/TICKET-01-setup-rust-base.md)

## Épica Relacionada

- [`01-setup-inicial-base/`](../01-setup-inicial-base/)

## Notas Técnicas

- Se usa Rust 1.75 con edition 2021
- Dependencias principales: tokio (async runtime), serde (serialización), tracing (logging)
- Dockerfile usa multistage build con Alpine Linux para imagen final ligera
- El proyecto inicia como single crate, puede evolucionar a workspace más adelante
