#!/bin/bash
# Script para probar conexiones a servicios remotos

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔌 Probando conexiones a servicios remotos..."
echo ""

# Cargar variables de entorno si existe .env
if [ -f .env ]; then
    echo "📄 Cargando variables de .env..."
    export $(grep -v '^#' .env | xargs)
fi

# PostgreSQL
echo "🗄️  Probando PostgreSQL..."
if [ -z "$DATABASE_URL" ]; then
    echo -e "${YELLOW}⚠️  DATABASE_URL no configurada${NC}"
else
    if psql "$DATABASE_URL" -c "SELECT version();" &> /dev/null; then
        echo -e "${GREEN}✅ PostgreSQL: Conectado${NC}"
        psql "$DATABASE_URL" -c "SELECT version();" | head -n1
    else
        echo -e "${RED}❌ PostgreSQL: Error de conexión${NC}"
    fi
fi
echo ""

# Redis
echo "⚡ Probando Redis..."
if [ -z "$REDIS_URL" ]; then
    echo -e "${YELLOW}⚠️  REDIS_URL no configurada${NC}"
else
    if redis-cli -u "$REDIS_URL" ping &> /dev/null; then
        echo -e "${GREEN}✅ Redis: Conectado${NC}"
        redis-cli -u "$REDIS_URL" info server | grep redis_version
    else
        echo -e "${RED}❌ Redis: Error de conexión${NC}"
    fi
fi
echo ""

# RabbitMQ
echo "🐰 Probando RabbitMQ..."
if [ -z "$AMQP_URL" ]; then
    echo -e "${YELLOW}⚠️  AMQP_URL no configurada${NC}"
else
    # Parsear AMQP URL: amqps://user:pass@host:port/vhost
    if [[ $AMQP_URL =~ amqps?://([^:]+):([^@]+)@([^:]+):?([0-9]*)/(.+) ]]; then
        USER="${BASH_REMATCH[1]}"
        PASS="${BASH_REMATCH[2]}"
        HOST="${BASH_REMATCH[3]}"
        PORT="${BASH_REMATCH[4]:-5672}"
        VHOST="${BASH_REMATCH[5]}"
        
        # Probar con rabbitmqadmin si está disponible
        RABBITMQADMIN="$HOME/.local/bin/rabbitmqadmin"
        if [ -f "$RABBITMQADMIN" ]; then
            if python "$RABBITMQADMIN" -H "$HOST" -u "$USER" -p "$PASS" -P "$PORT" -V "$VHOST" list queues &> /dev/null; then
                echo -e "${GREEN}✅ RabbitMQ: Conectado${NC}"
                echo "   Host: $HOST, VHost: $VHOST"
            else
                echo -e "${RED}❌ RabbitMQ: Error de conexión${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  rabbitmqadmin no encontrado. Instala con: ./scripts/install-clis.sh${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Formato de AMQP_URL no reconocido${NC}"
    fi
fi
echo ""

# PostHog (solo verificar que la variable esté configurada)
echo "📊 Verificando PostHog..."
if [ -z "$POSTHOG_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  POSTHOG_API_KEY no configurada${NC}"
else
    echo -e "${GREEN}✅ PostHog: API Key configurada${NC}"
    echo "   Host: ${POSTHOG_HOST:-https://app.posthog.com}"
fi
echo ""

# Scout APM (solo verificar que la variable esté configurada)
echo "🔍 Verificando Scout APM..."
if [ -z "$SCOUT_KEY" ]; then
    echo -e "${YELLOW}⚠️  SCOUT_KEY no configurada${NC}"
else
    echo -e "${GREEN}✅ Scout APM: API Key configurada${NC}"
fi
echo ""

echo "✅ Pruebas completadas"





