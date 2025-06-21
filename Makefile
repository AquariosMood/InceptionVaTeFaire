# VARIABLES
COMPOSE      = docker compose
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE     = srcs/.env

# COMMANDS
all: up

up:
	@echo "🚀 Building and starting containers..."
	@$(COMPOSE) --env-file $(ENV_FILE) -f $(COMPOSE_FILE) up -d --build

down:
	@echo "🛑 Stopping containers..."
	@$(COMPOSE) -f $(COMPOSE_FILE) down

restart: down up

logs:
	@echo "📜 Showing logs..."
	@$(COMPOSE) -f $(COMPOSE_FILE) logs -f

clean:
	@echo "🧹 Cleaning containers, networks, and volumes..."
	@$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans

fclean: clean
	@echo "💥 Removing all project-related images..."
	@$(COMPOSE) -f $(COMPOSE_FILE) down --rmi all -v

re: fclean all

.PHONY: all up down restart logs clean fclean re