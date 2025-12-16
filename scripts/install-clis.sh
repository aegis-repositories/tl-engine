#!/bin/bash
# Script para instalar CLIs de servicios remotos

set -e

echo "🔧 Verificando e instalando CLIs para servicios remotos..."
echo ""

# Verificar qué ya está instalado
ALREADY_INSTALLED=0

if command -v psql &> /dev/null; then
    echo "✅ PostgreSQL CLI ya está instalado: $(psql --version)"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if command -v redis-cli &> /dev/null; then
    echo "✅ Redis CLI ya está instalado: $(redis-cli --version)"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if command -v rabbitmqctl &> /dev/null; then
    echo "✅ RabbitMQ ya está instalado"
    ALREADY_INSTALLED=$((ALREADY_INSTALLED + 1))
fi

if [ -f "$HOME/.local/bin/rabbitmqadmin" ]; then
    echo "✅ rabbitmqadmin ya está instalado"
fi

if [ $ALREADY_INSTALLED -eq 3 ]; then
    echo ""
    echo "🎉 ¡Todos los CLIs ya están instalados!"
    echo ""
    echo "📝 Próximos pasos:"
    echo "   1. Configura las variables de entorno en .env"
    echo "   2. Ejecuta: ./scripts/test-connections.sh"
    exit 0
fi

echo ""
echo "Instalando CLIs faltantes..."
echo ""

# Verificar si estamos en Arch Linux
if ! grep -q "ID=arch" /etc/os-release 2>/dev/null; then
    echo "⚠️  Este script está diseñado para Arch Linux"
    echo "   Para otras distribuciones, ajusta los comandos de instalación"
    read -p "¿Continuar de todos modos? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# PostgreSQL
echo "📦 Instalando PostgreSQL CLI..."
if ! command -v psql &> /dev/null; then
    sudo pacman -S --noconfirm postgresql || {
        echo "❌ Error instalando PostgreSQL. ¿Tienes permisos sudo?"
        exit 1
    }
    echo "✅ PostgreSQL CLI instalado"
else
    echo "✅ PostgreSQL CLI ya está instalado"
fi

# Redis
echo "📦 Instalando Redis CLI..."
if ! command -v redis-cli &> /dev/null; then
    sudo pacman -S --noconfirm redis || {
        echo "❌ Error instalando Redis. ¿Tienes permisos sudo?"
        exit 1
    }
    echo "✅ Redis CLI instalado"
else
    echo "✅ Redis CLI ya está instalado"
fi

# RabbitMQ
echo "📦 Instalando RabbitMQ..."
if ! command -v rabbitmqctl &> /dev/null; then
    sudo pacman -S --noconfirm rabbitmq || {
        echo "❌ Error instalando RabbitMQ. ¿Tienes permisos sudo?"
        exit 1
    }
    echo "✅ RabbitMQ instalado"
else
    echo "✅ RabbitMQ ya está instalado"
fi

# Descargar rabbitmqadmin
echo "📦 Descargando rabbitmqadmin..."
RABBITMQADMIN_URL="https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.13.6/bin/rabbitmqadmin"
RABBITMQADMIN_PATH="$HOME/.local/bin/rabbitmqadmin"

if [ ! -f "$RABBITMQADMIN_PATH" ]; then
    mkdir -p "$HOME/.local/bin"
    curl -o "$RABBITMQADMIN_PATH" "$RABBITMQADMIN_URL" || {
        echo "⚠️  No se pudo descargar rabbitmqadmin. Puedes descargarlo manualmente más tarde."
    }
    chmod +x "$RABBITMQADMIN_PATH"
    echo "✅ rabbitmqadmin descargado en $RABBITMQADMIN_PATH"
else
    echo "✅ rabbitmqadmin ya existe"
fi

# Verificar instalación
echo ""
echo "🔍 Verificando instalación..."
echo ""

MISSING=0

if command -v psql &> /dev/null; then
    echo "✅ psql: $(psql --version | head -n1)"
else
    echo "❌ psql no encontrado"
    MISSING=1
fi

if command -v redis-cli &> /dev/null; then
    echo "✅ redis-cli: $(redis-cli --version)"
else
    echo "❌ redis-cli no encontrado"
    MISSING=1
fi

if command -v rabbitmqctl &> /dev/null; then
    echo "✅ rabbitmqctl: $(rabbitmqctl version)"
else
    echo "❌ rabbitmqctl no encontrado"
    MISSING=1
fi

if [ -f "$RABBITMQADMIN_PATH" ]; then
    echo "✅ rabbitmqadmin: $RABBITMQADMIN_PATH"
else
    echo "⚠️  rabbitmqadmin no encontrado (opcional)"
fi

echo ""
if [ $MISSING -eq 0 ]; then
    echo "🎉 ¡Instalación completada exitosamente!"
    echo ""
    echo "📝 Próximos pasos:"
    echo "   1. Configura las variables de entorno en .env"
    echo "   2. Ejecuta: ./scripts/test-connections.sh"
else
    echo "⚠️  Algunos CLIs no se instalaron correctamente"
    exit 1
fi

