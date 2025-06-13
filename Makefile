# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: crios <marvin@42.fr>                       +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/06/13                              #+#    #+#              #
#    Updated: 2025/06/13                              ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# VARIABLES
COMPOSE = docker compose
COMPOSE_FILE = srcs/docker-compose.yml

# COMMANDS
all: up

up:
	$(COMPOSE) -f $(COMPOSE_FILE) up -d --build

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

restart: down up

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down --volumes --remove-orphans

fclean: clean
	sudo docker system prune -a --volumes -f

re: fclean all

.PHONY: all up down restart logs clean fclean re
