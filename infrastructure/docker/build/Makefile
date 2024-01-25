.PHONY: all docker test
 
IMAGE := bersennaidoo/microdataservice-build:v1.0.0
 
all: docker
 
docker:
	docker build --rm -t $(IMAGE) .
 
test:
	docker run -it --rm $(IMAGE) sh

