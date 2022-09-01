#!/bin/bash
export CR_PAT=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


export VERSION=0.0.2
docker build --tag python-docker:0.0.3 --platform=linux/amd64 .
docker tag python-docker:0.0.3 ghcr.io/kaikiat/python-docker:0.0.3
docker push ghcr.io/kaikiat/python-docker:0.0.3


echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
docker run --publish 8000:5000 python-docker


