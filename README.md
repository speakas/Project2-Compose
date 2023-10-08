markdown

# Docker CLI to Docker-Compose Transition

## 1. Creating Docker Network

Docker CLI Command:
```bash
docker network create jenkins

2. Starting Docker-In-Docker Container
Docker CLI Command:

bash

docker run --name dind -d \
--network jenkins --network-alias docker \
--privileged \
-u root \
-e DOCKER_TLS_CERTDIR=/certs \
-v docker-certs-ca:/certs/ca \
-v docker-certs-client:/certs/client \
-v jenkins-data:/var/jenkins_home \
docker:dind

Docker-Compose Equivalent:

yaml

services:
  dind:
    image: docker:dind
    privileged: true
    environment:
      DOCKER_TLS_CERTDIR: "/certs"
    volumes:
      - "docker-certs-ca:/certs/ca"
      - "docker-certs-client:/certs/client"
      - "jenkins-data:/var/jenkins_home"

Explanation:

    --name dind: Names the container dind. Equivalent to the service name dind in Docker Compose.
    --network jenkins --network-alias docker: Places the container in the jenkins network with an alias docker. In Docker Compose, the dind service is automatically placed in the default network with other services.
    --privileged: Runs the container in privileged mode.
    -e DOCKER_TLS_CERTDIR=/certs: Sets an environment variable. Same is set under environment in Docker Compose.
    -v ...: Binds volumes to the container. Similar bindings are set under volumes in Docker Compose.

3. Starting Jenkins Container
Docker CLI Command:

bash

docker container run --name jenkins \
--detach --restart unless-stopped \
--network jenkins \
-u root \
--env DOCKER_HOST="tcp://docker:2376" \
--env DOCKER_CERT_PATH=/certs/client \
--env DOCKER_TLS_VERIFY=1 \
--volume docker-certs-client:/certs/client:ro \
--volume jenkins-data:/var/jenkins_home \
--publish 8080:8080 --publish 50000:50000 \
-v /usr/bin/docker:/usr/bin/docker \
jenkins/jenkins:lts-jdk11

Docker-Compose Equivalent:

yaml

services:
  jenkins:
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
    environment:
      DOCKER_HOST: "tcp://dind:2375"
    volumes:
      - "docker-certs-client:/certs/client:ro"
      - "jenkins-data:/var/jenkins_home"

Explanation:

    --name jenkins: Names the container jenkins. Equivalent to the service name jenkins in Docker Compose.
    --network jenkins: Places the container in the jenkins network. In Docker Compose, the jenkins service is automatically placed in the default network with other services.
    --env ...: Sets environment variables. Same are set under environment in Docker Compose.
    --volume ...: Binds volumes to the container. Similar bindings are set under volumes in Docker Compose.
    --publish 8080:8080 --publish 50000:50000: Publishes container ports to host ports. Similar mapping is done with ports in Docker Compose.
