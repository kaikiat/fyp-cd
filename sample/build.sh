export CR_PAT=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 


docker build --tag python-docker .
docker tag python-docker ghcr.io/kaikiat/python-docker:latest
docker push ghcr.io/kaikiat/python-docker:latest

