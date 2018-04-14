deps:
	./minio_distributed.sh

micro:
	kubectl apply -f ./micro-deploy.yaml
	kubectl apply -f ./micro-service.yaml