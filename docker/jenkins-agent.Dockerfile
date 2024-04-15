ARG PLATFORM=linux/amd64
ARG IMAGE_TAG=22.04

FROM --platform=$PLATFORM ubuntu:$IMAGE_TAG

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    socat \
    && rm -rf /var/lib/apt/lists/*

CMD socat TCP-LISTEN:2375,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock