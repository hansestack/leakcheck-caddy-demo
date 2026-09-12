# ==============================================================================
# Variables & Environment
# ==============================================================================
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

APP_URL     := http://localhost
GRAFANA_URL := http://localhost:3000

# ==============================================================================
# Phony declarations
# ==============================================================================
.PHONY: help init up down restart reset logs ps
.PHONY: build test-login open clean

# ==============================================================================
# Default
# ==============================================================================
default: help

help: ## Show this help message
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}'

# ==============================================================================
# Setup
# ==============================================================================
init: ## Create .env from .env.skel if it doesn't exist yet
	@test -f .env || cp .env.skel .env
	@echo "Edit .env and set HANSESTACK_API_KEY, then run 'make up'."

# ==============================================================================
# Docker Compose
# ==============================================================================
up: init ## Start the full stack with docker-compose (always rebuilds)
	docker compose up --build -d

down: ## Stop the docker-compose stack
	docker compose down

restart: down up ## Restart the full stack

reset: ## Wipe volumes (Caddy TLS state, VictoriaMetrics/Grafana data) and restart
	docker compose down -v
	docker compose up --build -d

logs: ## Tail compose stack logs
	docker compose logs -f

ps: ## Show status of the compose stack
	docker compose ps

# ==============================================================================
# Local dev / smoke test
# ==============================================================================
build: ## Build the dummy backend locally (outside Docker)
	cd backend && go build -o ../bin/dummy-backend .

test-login: ## Send a sample login request through Caddy and print the response
	curl -sS -i -X POST $(APP_URL)/login \
		-H 'Content-Type: application/json' \
		-d '{"email":"demo@example.com","password":"password123"}'

open: ## Open the demo app and Grafana in the browser
	@open $(APP_URL) $(GRAFANA_URL) 2>/dev/null || xdg-open $(APP_URL)

# ==============================================================================
# Clean
# ==============================================================================
clean: ## Remove local build artifacts
	rm -rf bin/
