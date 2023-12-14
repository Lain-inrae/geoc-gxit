docker_name=first-gxit
docker_repo=ancelete
internal_port=3838
port=-p 127.0.0.1:3838:$(internal_port)
log_path=/var/log/tuto-gxit-01.log
WEB_TAG=1.0.0
WEB_TARGET=${docker_repo}/${docker_name}:${WEB_TAG}
WEB_LATEST=${docker_repo}/${docker_name}:latest

re:clean docker

push_hub: docker hub_login do_push remove_hub_credentials

do_push:
	docker push ${WEB_TARGET}
	docker push ${WEB_LATEST}

hub_login:
	cat .password | docker login --username=${USERNAME} --password-stdin

remove_hub_credentials:hub_logout
	rm ~/.docker/config.json

hub_logout:
	docker logout

docker_logout:
	docker logout

docker:
	@docker build --build-arg LOG_PATH=${log_path}  --build-arg PORT=${internal_port} -t $(docker_name) .
	@docker tag ${docker_name}:latest ${WEB_TARGET}
	@docker tag ${docker_name}:latest ${WEB_LATEST}


clean:
	docker kill `docker ps | grep -Poe '[a-z0-9]{12}'` || true
	docker container prune
	docker rmi $(docker_name) || true


it:
	docker run -it $(port) $(docker_name)

d:
	docker run -d $(port) $(docker_name)

sh:
	docker exec -i `docker ps | grep -Poe '^[a-z0-9]{12}'` bash

log:
	docker exec `docker ps | grep -Poe '^[a-z0-9]{12}'` tail -f $(log_path)


.PHONY:log R
