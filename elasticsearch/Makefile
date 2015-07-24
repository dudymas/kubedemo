.PHONY: elasticsearch_discovery build push all

TAG = 1.0
#todo, use terraform output to populate the registry
#REGISTRY = 10.0.45.126:5000/
#leave registry blank to publish to docker hub. You will need to be logged in
REGISTRY = 
CONTAINER_NAME=kubernetes-elasticsearch
CONTAINER_DOMAIN=dudymas
NAMESPACE=logevents

all:	elasticsearch_discovery build push secret rc service

#Note, this will fail if you haven't built the elasticsearch_discovery.go binary.
#Since it's already in the container, you should be good, all the same
build:
	docker build -t $(CONTAINER_DOMAIN)/$(CONTAINER_NAME) .

push:
	docker tag $(CONTAINER_DOMAIN)/$(CONTAINER_NAME) $(REGISTRY)$(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG)
	docker push $(REGISTRY)$(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG)
	docker rm  $(REGISTRY)$(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG)

elasticsearch_discovery:	
	go build elasticsearch_discovery.go

secret:
	kubectl create -f apiserver-secret.yaml --namespace=$(NAMESPACE)

rc:
	kubectl create -f logevents-rc.yaml --namespace=$(NAMESPACE)

service:
	kubectl create -f logevents-service.yaml --namespace=$(NAMESPACE)

