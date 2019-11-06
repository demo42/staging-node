# staging-node

Staging a base image, by importing it from upstream, validating it, before it being considered a company wide base image

## Credentials

```sh
# Create a service principal (SP) to login w/ az acr import permissions
# saving the created password to a Key Vault secret.
## Note: role = contributor to allow az acr import to function.
az keyvault secret set \
  --vault-name $AKV_NAME \
  --name ${DEMO_NAME}-deploy-pwd \
  --value $(az ad sp create-for-rbac \
            --name http://${DEMO_NAME}-deploy \
            --scopes \
              $(az acr show \
                --name $ACR_NAME \
                --query id \
                --output tsv) \
            --role owner \
            --query password \
            --output tsv)

# Store the service principal ID, (username) in Key Vault

az keyvault secret set \
    --vault-name $AKV_NAME \
    --name ${DEMO_NAME}-deploy-usr \
    --value http://${DEMO_NAME}-deploy

# Save the tenant for az login --service-principal
az keyvault secret set \
    --vault-name $AKV_NAME \
    --name ${DEMO_NAME}-tenant \
    --value $(az account show \
              --query tenantId \
              -o tsv)

# Backup role assignment
az role assignment create \
  --assignee $(az ad sp show \
              --id ${SP} \
              --query appId \
              --output tsv) \
  --role owner \
  --scope $(az acr show \
                --name $ACR_NAME \
                --query id \
                --output tsv)
```

```sh
az acr task create \
  -n node-import-to-staging \
  --file      acr-task.yaml \
  --context   ${GIT_STAGING_NODE} \
  --git-access-token $(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${GIT_TOKEN_NAME} \
                         --query value -o tsv) \
  --set-secret TENANT=$(az keyvault secret show 
                         --vault-name ${AKV_NAME} \
                         --name ${DEMO_NAME}-tenant \
                         --query value -o tsv) \
  --set-secret SP=$(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${DEMO_NAME}-deploy-usr \
                         --query value -o tsv) \
  --set-secret PASSWORD=$(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${DEMO_NAME}-deploy-pwd \
                         --query value -o tsv)
```


```sh
az acr import -n demo42t --source mcr.microsoft.com/azure-cli:2.0.75 -t base-artifacts/azure-cli:2.0.75
docker run mcr.microsoft.com/azure-cli:2.0.75 az acr import -n demo42t --source demo42t.azurecr.io/upstream/node:9-alpine -t staging/node:9-alpine
az acr run --cmd "orca run base-artifacts/azure-cli:2.0.75 acr import" /dev/null
docker run mcr.microsoft.com/azure-cli:2.0.75 import -n demo42t --source library/node:9-alpine -t base-artifacts/node:9-alpine

az acr import --name demo42upstream \
  --source docker.io/library/node:9-alpine -t library/node:9-alpine --force

docker pull demo42upstream.azurecr.io/library/node:9-alpine
```

## Troubleshooting Snippets

```sh
export SP=$(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${DEMO_NAME}-deploy-usr \
                         --query value -o tsv)
export PASSWORD=$(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${DEMO_NAME}-deploy-pwd \
                         --query value -o tsv)
export TENANT=$(az keyvault secret show \
                         --vault-name ${AKV_NAME} \
                         --name ${DEMO_NAME}-tenant \
                         --query value -o tsv)
echo SP: ${SP}
echo PASSWORD: ${PASSWORD}
echo TENANT: ${TENANT}

docker run \
  -e ACR_NAME=$ACR_NAME \
  -e SP=${SP} \
  -e PASSWORD=${PASSWORD} \
  -e TENANT=${TENANT} \
  -v c:/Users/stevelas/Documents/github/demo42/staging-node:/der \
  -w /der \
  mcr.microsoft.com/azure-cli:2.0.75  ./import.sh
```

```sh
cat acr-task.yaml | az acr task create -n node-import-to-staging --identity -f - -c /dev/null

cat acr-task.yaml | az acr task create -n node-import-to-staging --assign-identity  -f - -c /dev/null

az role assignment create \
  --role Contributor \
  --assignee-object-id $(az acr task show \
      -n node-import-to-staging \
      --query identity.principalId \
      -o tsv) \
  --assignee-principal-type ServicePrincipal \
  --scope $(az acr show \
    -n ${ACR_NAME} \
    --query id -o tsv)

az acr task run -n node-import-to-staging
az role assignment create --role Contributor --assignee-object-id cdba81cb-a64b-43c3-a828-f43acc56ff5c --scope $(az acr show -n demo42t --query id -o tsv)

```
