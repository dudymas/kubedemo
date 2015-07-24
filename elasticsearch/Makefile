.PHONY: elasticsearch_discovery build push all

TAG = 1.0
REGISTRY = 10.0.45.126:5000
CONTAINER_NAME=es
CONTAINER_DOMAIN=hivelocity
NAMESPACE=logevents

all:	elasticsearch_discovery build push secret rc service

build:
	docker build -t $(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG) .

push:
	docker tag $(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG) $(REGISTRY)/$(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG)
	docker push $(REGISTRY)/$(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG)
	docker rm  $(REGISTRY)/$(CONTAINER_DOMAIN)/$(CONTAINER_NAME):$(TAG)

elasticsearch_discovery:	
	go build elasticsearch_discovery.go

secret:
	kubectl create -f apiserver-secret.yaml --namespace=$(NAMESPACE)

rc:
	kubectl create -f logevents-rc.yaml --namespace=$(NAMESPACE)

service:
	kubectl create -f logevents-service.yaml --namespace=$(NAMESPACE)

