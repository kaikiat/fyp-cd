echo Creates a pull request at fyp-cd

export path=google_staging_sample/helm/sgdecoding-online-scaled/values.yaml
export repo=ghcr.io/kaikiat/fyp-ci:0.3.1
sed -i "/  repository:./c\  repository:$repo" $path





