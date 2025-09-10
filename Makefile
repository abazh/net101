# Makefile for Mininet Docker container management

# Configuration
IMAGE_NAME := mininet-ubuntu-24.04
IMAGE_TAG := latest
CONTAINER_NAME := mininet
PWD := $(shell pwd)

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Mininet Docker Container Management"
	@echo "=================================="
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  %-15s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: build
build: ## Build the Docker image
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: build-no-cache
build-no-cache: ## Build without cache
	@echo "Building Docker image (no cache)..."
	docker build --no-cache -t $(IMAGE_NAME):$(IMAGE_TAG) .

.PHONY: run
run: build ## Build and run container interactively
	docker run --rm -it \
		--name $(CONTAINER_NAME) \
		--privileged \
		--network host \
		--add-host $(CONTAINER_NAME):127.0.1.1 \
		--hostname $(CONTAINER_NAME) \
		-v "$(PWD):/opt/mininet/net101" \
		-v /lib/modules:/lib/modules:ro \
		$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: up
up: build ## Start container using docker compose
	docker compose up -d

.PHONY: down
down: ## Stop and remove container using docker compose
	docker compose down

.PHONY: start
start: ## Start the container
	docker compose start

.PHONY: stop
stop: ## Stop the container
	docker compose stop

.PHONY: restart
restart: ## Restart the container
	docker compose restart

.PHONY: logs
logs: ## Show container logs (set LOGS_OPTS to pass options, e.g., LOGS_OPTS= for no follow)
	docker compose logs $(LOGS_OPTS)

.PHONY: shell
shell: ## Enter running container shell
	@if [ "$$(docker ps -q -f name=^/$(CONTAINER_NAME)$$)" ]; then \
		docker exec -it $(CONTAINER_NAME) /bin/bash; \
	else \
		echo "Error: Container '$(CONTAINER_NAME)' is not running."; \
		exit 1; \
	fi

.PHONY: status
status: ## Show container status
	docker compose stats --no-stream

.PHONY: clean
clean: ## Clean up container and image (removes stopped containers using the image)
	docker compose down -v --remove-orphans
	# Remove all stopped containers using the image
	-docker ps -a -q --filter ancestor=$(IMAGE_NAME):$(IMAGE_TAG) | xargs -r docker rm
	# Remove dangling images from build process
	-docker image prune -f
	@if ! docker rmi $(IMAGE_NAME):$(IMAGE_TAG) 2>/dev/null; then \
		echo "Warning: Docker image '$(IMAGE_NAME):$(IMAGE_TAG)' could not be removed."; \
	fi
