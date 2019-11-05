#!/bin/sh

set -e
# SP, PASSWORD , CLUSTER_NAME, CLUSTER_RESOURCE_GROUP
az configure --defaults acr=$ACR_NAME

az login \
    --service-principal \
    --username $SP \
    --password $PASSWORD \
    --tenant $TENANT  > /dev/null

echo -- az acr import --
az acr import \
    --source mcr.microsoft.com/azure-cli:2.0.75 \
    -t base-artifacts/azure-cli:2.0.75

