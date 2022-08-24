IMAGE_NAME ?= "cnskunkworks/movie-catalogue:v3"
.PHONY: docker-push
docker-push:
	docker build -t $(IMAGE_NAME) .
	docker push $(IMAGE_NAME)
deploy:
	cd chart && helm upgrade --install movie-catalogue . --set=image.tag="v3" --set=postgres.password=$$(kubectl get secrets movie-db-cluster-app -o jsonpath="{.data.password}" | base64 --decode) && cd ../