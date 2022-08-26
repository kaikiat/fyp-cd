#!/bin/bash

kubectl apply -f analysis/analysis_request.yaml

prometheus-kube-prometheus-prometheus.default.svc.cluster.local