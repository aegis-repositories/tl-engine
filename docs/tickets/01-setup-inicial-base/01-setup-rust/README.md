# 🎫 Ticket 01: Inicialización del Engine (Rust Base)

**Objetivo**: Crear una aplicación en Rust vacía pero profesional, y empaquetarla en una "caja" (Docker) para que pueda correr en cualquier lado.

## ✅ Checklist de Completitud (Definition of Done)

Para marcar este ticket como listo, debes cumplir esto:

- [ ] **Código**: Existe una carpeta `src/` con un `main.rs` que compila.
- [ ] **Docker**: Puedes ejecutar `docker build` y crear una imagen funcional.
- [ ] **Comodidad**: Puedes ejecutar `make run` y ver "Engine Started" en la terminal.
- [ ] **Limpieza**: No hay archivos basura (revisar `.gitignore`).

## 📂 Archivos en este Ticket

1. [conceptos.md](./conceptos.md): **LÉEME PRIMERO**. Explica por qué Rust, qué es un Workspace, Docker Multistage, cacheo de dependencias, y Tokio.
2. [guia-tecnica.md](./guia-tecnica.md): El paso a paso. Comandos para copiar y pegar, y código base.
3. [referencia-tecnica.md](./referencia-tecnica.md): **Opcional**. Análisis detallado de dependencias, Dockerfile línea por línea, y optimizaciones avanzadas.
