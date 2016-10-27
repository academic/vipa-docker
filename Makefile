PROJECT := OJS

default:

development:
	@docker-compose -f docker-compose.$@.yaml --project-name $(PROJECT) up -d

production:
	@docker-compose -f docker-compose.$@.yaml --project-name $(PROJECT) up -d

down:
	@docker-compose -f docker-compose.development.yaml --project-name $(PROJECT) down

workarounds:
	@sysctl -w vm.max_map_count=262144

.PHONY: default development down production workarounds