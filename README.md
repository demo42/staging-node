# staging-node

Staging a base image, by importing it from upstream, validating it, before it being considered a company wide base image

- Create a Task for Tracking Upstream Image
  The Task is created with a Managed Identity
  We then assign the Task with Contributor access to the registry
  Contributor access is needed for the acr import command, which uses the CLI

  ```sh
  az acr task create \
    -n node-import-to-staging \
    --assign-identity  \
    -f acr-task.yaml \
    --context ${GIT_STAGING_NODE} \
    --git-access-token $(az keyvault secret show \
                          --vault-name ${AKV_NAME} \
                          --name ${GIT_TOKEN_NAME} \
                          --query value -o tsv)
  
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
  ```

- Manually run the task

  ```sh
  az acr task run -n node-import-to-staging
  ```

## Make an Upstream Change

## Local Testing

```bash
az acr build -t node-import:test -f acr-task.yaml --no-push .
docker build -t node-import:test .
docker run -it --rm node-import:test
```