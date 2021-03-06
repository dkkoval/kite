VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null | tr -d 'v')
IMAGE   := heliostech/kite:$(VERSION)

.PHONY: default build push run ci deploy

default: build run

build:
	@echo '> Building "kite" docker image...'
	@docker build -t $(IMAGE) .

push: build
	gcloud docker -- push $(IMAGE)

run:
	@echo '> Starting "kite" container...'
	@docker run -d $(IMAGE)

ci:
	@fly -t ci set-pipeline -p kite -c config/pipelines/review.yml -n
	@fly -t ci unpause-pipeline -p kite

deploy: push
	@helm install ./config/charts/kite --set "image.tag=$(VERSION)"
