ifdef DOTENV
	DOTENV_TARGET=dotenv
else
	DOTENV_TARGET=.env
endif
ifdef GO_PIPELINE_NAME
	ENV_RM_REQUIRED?=rm_env
	BUILD_VERSION?=$(GO_PIPELINE_LABEL)
else
	BUILD_VERSION?=local
endif

DOCKER_IMAGE := 123456789123.dkr.ecr.ap-southeast-2.amazonaws.com/devops/my-ruby-app

##################
# PUBLIC TARGETS #
##################
init:
	docker run -it --rm -v "$$(pwd)":/srv/app -w /srv/app --entrypoint=sh ruby:2.3.4 -c "gem install rails && rails new --database=postgresql --skip-bundle -f ."

deps:
	docker-compose run --rm --no-deps --entrypoint "bundle install --jobs 4" ruby

dockerBuild:
	docker-compose run --rm --no-deps --entrypoint "bundle install --jobs 4 --deployment --binstubs --without development --without test" ruby
	docker build -t $(DOCKER_IMAGE):$(BUILD_VERSION) .
	docker tag $(DOCKER_IMAGE):$(BUILD_VERSION) $(DOCKER_IMAGE):latest

start:
	docker-compose run --rm --service-ports app

dockerPush:
	docker push $(DOCKER_IMAGE):$(BUILD_VERSION)
	docker push $(DOCKER_IMAGE):latest

ecrLogin:
	$(shell aws ecr get-login --no-include-email --region ap-southeast-2)

###########
# ENVFILE #
###########
# Create .env based on .env.template if .env does not exist
.env:
	@echo "Create .env with .env.template"
	cp .env.template .env

# Create/Overwrite .env with $(DOTENV)
dotenv:
	@echo "Overwrite .env with $(DOTENV)"
	cp $(DOTENV) .env

$(DOTENV):
	$(info overwriting .env file with $(DOTENV))
	cp $(DOTENV) .env
.PHONY: $(DOTENV)

##################
# PRIVATE TARGET #
##################

_clean:
	rm -rf Gemfile* README.md Rakefile app/ bin/ config* db/ lib/ log/ package.json public/ test/ tmp/ vendor/ .ruby-version storage/ .gitignore
