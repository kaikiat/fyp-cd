#!/bin/bash
export CR_PAT=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 

docker build --tag python-docker --platform=linux/amd64 .
# docker tag python-docker ghcr.io/kaikiat/python-docker:latest
# docker tag python-docker ghcr.io/kaikiat/python-docker:latest
# docker push ghcr.io/kaikiat/python-docker:latest
docker push ghcr.io/kaikiat/python-docker

docker run --publish 8000:5000 python-docker


