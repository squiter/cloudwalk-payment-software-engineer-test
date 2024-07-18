RUNNING_DB = $(shell docker ps -a | grep my_postgres)

database:
ifeq ($(RUNNING_DB), )
	docker run --name my_postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d postgres:16.3-alpine;
else
	docker start my_postgres;
endif

drop:
	bin/rails db:drop
	RAILS_ENV=test bin/rails db:drop

create:
	bin/rails db:create
	RAILS_ENV=test bin/rails db:create

migrate:
	bin/rails db:migrate
	RAILS_ENV=test bin/rails db:migrate

seed:
	bin/rails db:seed

reset: drop create migrate seed

.PHONY: reset
