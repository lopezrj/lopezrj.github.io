---
title: Docker Commands
feed: show
date: 03-10-2018
---

## Images

- `docker pull`: download images from remote registries.

- `docker images`: list all images stored in localhost

- `docker inspect`: display all details of an images (layer data and metada)

- `docker manifest inspect`: display the manifest list of any image stored on Docker Hub.

- `docker buildx`: Docker CLI plugin that extends the Docker CLI to support multi-arch builds.

- `docker rmi`: delete image.

## Containers

- `docker run`: start a new container

-  `Ctrl-PQ`: detach the shell from the terminal of a container and leave the container running in the background.

-  `docker ps`: list all containers in the running state. The `-a` flag also display stopped contaners.

- `docker exec`: runs a new process inside of a running container. It's useful for attaching the shell of the Docker host to a terminal inside a running container.

- `docker stop`: stops a running container and put it in the exited `(0)` state.

- `docker start`: restarts a stopped container.

- `docker rm`: deletes a stopped container.

- `docker inspect`:  displays detailed configuration and runtime information abut a container.

## Containerizing an app

- `docker build`: reads a `Dockerfile` and containerizes an application. The `-t` flag tags the image, and the `-f` flag lets you specify the name and location of the `Dockerfile`.

- The Dockerfile `FROM` instruction specifies the base image for the new image you're building.

- The Dockerfile `RUN` instruction lets you to run commands inside the image during a build. Each `RUN` instruction adds a new layer to the overall image.

- The Dockerfile `COPY` instruction adds files into the image as a new layer.

- The Dockerfile `EXPOSE` instruction documents the network port an application uses.

- The Dockerfile `ENTRYPOINT` instruction sets the default application to run when the image is started as a container.
