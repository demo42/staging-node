#!/bin/sh

set -e

# SP, PASSWORD , CLUSTER_NAME, CLUSTER_RESOURCE_GROUP
#echo SP: ${SP}
#echo PASSWORD: ${PASSWORD}
#echo TENANT: ${TENANT}
az login \
    --service-principal \
    --username $SP \
    --password $PASSWORD \
    --tenant $TENANT  > /dev/null

az configure --defaults acr=$ACR_NAME

echo -- az acr import --source mcr.microsoft.com/azure-cli:2.0.75 \
    -t base-artifacts/azure-cli:2.0.75 \
    --force --
az acr import \
    --source mcr.microsoft.com/azure-cli:2.0.75 \
    -t base-artifacts/azure-cli:2.0.75 \
    --force
