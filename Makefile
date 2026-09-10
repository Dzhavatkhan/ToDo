include .env
export
export LANG := en_US.UTF-8
export LC_ALL := en_US.UTF-8

export PROJECT_ROOT = $(CURDIR)

env-up:
	@docker compose up -d todo-postgres
env-down:
	@docker compose down todo-postgres
env-cleanup:
	@read -p "Очистить все volume-файлы? ВАЖНО: данные исчезнут. [y/N]: " ans; \
	if [ "$$ans" = "y" ] || [ "$$ans" = "Y" ]; then \
		docker compose down todo-postgres; \
		rm -rf out/pgdata; \
		echo "Файлы очищены!"; \
	else \
		echo "Очистка отменена."; \
	fi
env-port-forward:
	@docker compose up -d port-forwarder
env-port-close:
	@docker compose down port-forwarder

migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Here need a parametr. For example: make migrate-create seq=migrationName"; \
		exit 1;\
	fi; \

	docker compose run --rm todo-postgres-migrate \
		create \
		-ext sql \
		-dir migrations \
		-seq "$(seq)"

migrate-up:
	@make migrate-action action=up
migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Here need a parametr action. For example: make migrate-action action=up"; \
		exit 1;\
	fi; \
	docker-compose run --rm todo-postgres-migrate \
		-path migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todo-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)";
