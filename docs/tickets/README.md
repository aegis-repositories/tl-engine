# 🎫 Sistema de Tickets y Épicas

Este directorio contiene la organización de trabajo del proyecto `tl-engine` mediante épicas y tickets asignados.

## 📁 Estructura

```
docs/tickets/
├── README.md (este archivo)
├── stories/                  # User stories (qué y por qué)
│   ├── README.md
│   ├── skills.md             # Habilidades requeridas
│   ├── ST-01-aplicacion-rust-base.md
│   ├── ST-02-infraestructura-k8s-local.md
│   ├── ST-03-observabilidad-posthog.md
│   └── ST-04-gestion-segura-secretos.md
├── 01-setup-inicial-base/    # Épica: Setup inicial base
│   ├── README.md             # Descripción de la épica
│   ├── 01-setup-rust/        # Documentación técnica
│   ├── 02-k8s-local/
│   ├── 03-posthog/
│   └── 04-secretos/
└── assigned/                 # Tickets asignados a desarrolladores
    ├── README.md
    └── martin/
        └── TICKET-01-setup-rust-base.md
```

## 📖 User Stories

Las **stories** (`stories/`) contienen:
- Descripción del "qué" y "por qué" desde perspectiva de negocio/usuario
- Criterios de aceptación
- Especialidades requeridas para completarlas
- Estimación en puntos de Fibonacci
- Dependencias entre stories

**Propósito**: Definir las necesidades del negocio y los requisitos funcionales de forma clara y medible.

## 🎯 Épicas

Las **épicas** (`01-setup-inicial-base/`) contienen:
- Descripción del objetivo general
- Documentación técnica completa (conceptos, guías, referencias)
- Alcance y criterios de éxito

**Propósito**: Proporcionar contexto técnico y documentación de referencia para entender el "por qué" y el "cómo" a nivel arquitectónico.

## 📋 Tickets Asignados

Los **tickets asignados** (`assigned/`) contienen:
- Instrucciones paso a paso precisas
- Comandos específicos a ejecutar
- Definition of Done con checklist
- Estimación en puntos de Fibonacci
- Troubleshooting común

**Propósito**: Proporcionar instrucciones ejecutables para completar trabajo específico con estimación clara de esfuerzo.

## 🔄 Flujo de Trabajo

1. **Revisar story**: Entender el "qué" y "por qué" en `stories/`
2. **Verificar habilidades**: Consultar `stories/skills.md` para verificar que se tienen las habilidades necesarias
3. **Recibir ticket**: Lee el ticket en `assigned/<nombre>/`
4. **Consultar épica**: Si necesita contexto técnico profundo, revisa la épica relacionada
5. **Ejecutar trabajo**: Sigue los pasos del ticket
6. **Verificar Definition of Done**: Marca el checklist
7. **Completar ticket**: Notifica cuando está listo

## 📚 Documentación

- **Stories**: Necesidades de negocio, criterios de aceptación, especialidades requeridas
- **Épicas**: Documentación técnica profunda, conceptos, arquitectura
- **Tickets**: Instrucciones ejecutables, comandos, troubleshooting específico
- **Skills**: Lista de habilidades técnicas necesarias para completar las stories

**Relación**:
- Cada story puede tener uno o más tickets asignados
- Cada ticket referencia su épica correspondiente para consulta opcional de contexto técnico
- Las stories definen las especialidades requeridas, detalladas en `skills.md`
