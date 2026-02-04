# Reusable workflow

A workflow (containing one or multiple jobs) can be called from another workflow, rather than copying and pasting from one workflow to another. Know more about [it](https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations#reusable-workflows).

A workflow that uses another workflow is referred to as a "caller" workflow. The reusable workflow is a "called" workflow. One caller workflow can use multiple called workflows.

> If we reuse a workflow from a different repository, any actions in the called workflow run as if they were part of the caller workflow. For example, if the called workflow uses actions/checkout, the action checks out the contents of the repository that hosts the caller workflow, not the called workflow.

We can keep our reusable workflows in the same repository or create a separate, dedicated repo for them.

Read about how to create reusable workflow, call a reusable workflow, pass inputs and secrets to a reusable workflow, nesting reusable workflows [here](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)


Read about [Reusable workflows vs Composite Actions](https://docs.github.com/en/actions/concepts/workflows-and-actions/reusing-workflow-configurations#reusable-workflows-versus-composite-actions)

## Example

Here's a sample reusable workflow with one job:

```yaml
# deploy-to-environment-reusable.yml
name: Deploy to Environment

on:
  workflow_call:
    inputs:
      environment-name:
        description: "The name of the environment (e.g., DEV, STAGING, PROD)"
        required: true
        type: string
      environment-url:
        description: "The URL of the environment"
        required: true
        type: string
      artifact-name:
        description: "The name of the artifact to download"
        required: true
        type: string
      web-app-name:
        description: "The name of the Azure Web App"
        required: true
        type: string
        default: ${{ vars.WEB_APP_NAME }}
      slot-name:
        description: "The slot name for the Azure Web App"
        required: true
        type: string

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: ${{ inputs.environment-name }}
      url: ${{ inputs.environment-url }}

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ inputs.artifact-name }}
          path: myapp

      - name: Login to Azure
        uses: azure/login@v2.2.0
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ inputs.web-app-name }}
          slot-name: ${{ inputs.slot-name }}
          package: myapp
```

We can call this from another workflow as follows:

```yaml
...
jobs:
  ...
  deploy-to-dev:
    needs: build-and-test
    uses: github_username/gh_repo-name/.github/workflows/deploy-to-environment-reusable.yml@main
    with:
      environment-name: "DEV"
      environment-url: "https://${{ vars.WEB_APP_NAME }}-dev.azurewebsites.net/"
      artifact-name: "myapp"
      web-app-name: ${{ vars.WEB_APP_NAME }}
      slot-name: "dev"
    secrets: inherit

  deploy-to-staging:
    needs: build-and-test
    uses: github_username/my-github-actions-presentation/.github/workflows/deploy-to-environment-reusable.yml@main
    with:
      environment-name: "STAGING"
      environment-url: "https://${{ vars.WEB_APP_NAME }}-staging.azurewebsites.net/"
      artifact-name: "myapp"
      web-app-name: ${{ vars.WEB_APP_NAME }}
      slot-name: "staging"
    secrets: inherit

  deploy-to-prod:
    needs:
      - deploy-to-staging
      - deploy-to-dev
    uses: github_username/gh_repo-name/.github/workflows/deploy-to-environment-reusable.yml@main
    with:
      environment-name: "PROD"
      environment-url: "https://${{ vars.WEB_APP_NAME }}-prod.azurewebsites.net/"
      artifact-name: "myapp"
      web-app-name: ${{ vars.WEB_APP_NAME }}
      slot-name: "prod"
    secrets: inherit
```