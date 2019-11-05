# staging-node
Staging a base image, by importing it from upstream, validating it, before it being considered a company wide base image

```sh
az acr import -n demo42t --source mcr.microsoft.com/azure-cli:2.0.75 -t base-artifacts/azure-cli:2.0.75
docker run mcr.microsoft.com/azure-cli:2.0.75 az acr import -n demo42t --source demo42t.azurecr.io/upstream/node:9-alpine -t staging/node:9-alpine
az acr run --cmd "orca run base-artifacts/azure-cli:2.0.75 acr import" /dev/null
docker run mcr.microsoft.com/azure-cli:2.0.75 import -n demo42t --source library/node:9-alpine -t base-artifacts/node:9-alpine
