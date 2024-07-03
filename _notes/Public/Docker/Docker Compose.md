---
title: Docker Compose
feed: show
date: 03-10-2018
---

Modern cloud-native apps are made of multiple smaller services that interact to from a useful app. This is the _microservices_ pattern.

`Docker compose` lets you describe everything in a declarative configuration file, that can be used to deploy and manage the microservices.

Compose uses YAML files to define microservices applications. The default name for a Compose YAML file is `compose.yaml`. However, it also accepts `compose.yml` and you can use the `-f` flag to specify custom filenames.

Example:

```
services:
  web-fe:
    build: .                  # Use the Dockerfile in current directory
    command: python app.py
    ports:
      - target: 8080
        published: 5001
    networks:
      - counter-net
    volumes:
      - type: volume
        source: counter-vol
        target: /app
  redis:
    image: "redis/alpine"
    networks:
      - counter-net

networks:
  counter-net:

volumes:
  counter-vol:
```