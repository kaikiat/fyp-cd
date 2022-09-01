#!/bin/bash
export CR_PAT= 


export VERSION=0.0.1
docker build --tag python-docker:0.0.1 --platform=linux/amd64 .
docker tag python-docker:0.0.1 ghcr.io/kaikiat/python-docker:0.0.1
docker push ghcr.io/kaikiat/python-docker:0.0.1


echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
docker run --publish 8000:5000 python-docker


