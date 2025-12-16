.PHONY: help install dev test build up down logs clean deploy-dev deploy-staging test-connections setup-railway

# Default target
help:
	@echo "tl-engine - Makefile Commands"
	@echo ""
	@echo "Development:"
	@echo "  make install          - Install dependencies"
	@echo "  make dev              - Start development server"
	@echo "  make test             - Run tests"
	@echo "  make build            - Build application"
	@echo ""
	@echo "Docker:"
	@echo "  make up               - Start docker services"
	@echo "  make down             - Stop docker services"
	@echo "  make logs             - View logs"
	@echo "  make clean            - Clean containers and volumes"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-dev       - Deploy to development (Railway) [default]"
	@echo "  make deploy-staging   - Deploy to staging (Railway)"
	@echo "  make setup-railway    - Setup Railway project"
	@echo ""
	@echo "Utilities:"
	@echo "  make test-connections - Test connections to remote services"
	@echo "  make docs             - Generate documentation"

# Development
install:
	@echo "TODO: Install dependencies (language TBD)"

dev:
	@echo "TODO: Start development server (language TBD)"

test:
	@echo "TODO: Run tests (language TBD)"

build:
	@echo "TODO: Build application (language TBD)"

# Docker
up:
	@echo "TODO: Start docker services (docker-compose.yml TBD)"

down:
	@echo "TODO: Stop docker services (docker-compose.yml TBD)"

logs:
	@echo "TODO: View logs (docker-compose.yml TBD)"

clean:
	@echo "TODO: Clean containers and volumes (docker-compose.yml TBD)"

# Deployment
deploy-dev:
	@echo "Deploying to development..."
	@railway environment use development || railway environment use dev
	@railway up

deploy-staging:
	@echo "Deploying to staging..."
	@railway environment use staging
	@railway up

setup-railway:
	@echo "Setting up Railway project..."
	@railway login
	@railway init
	@echo "Project initialized. Configure variables with: railway variables set KEY=value"

# Utilities
test-connections:
	@echo "Testing connections to remote services..."
	@./scripts/test-connections.sh

docs:
	@echo "Documentation is in docs/infra/"
	@echo "View with: cat docs/infra/vista-general.md"




