## Environment
An environment is a collection of secrets, environment variables, and protection rules that a job can use.

For more info, checkout:
- [Managing Environments](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment)

#### Creating and Managing Environment
- Navigate to `Settings`(Repository) > `Environments`.

- Click on `New environment` and create new environments like Staging, Testing, Production.

- Configure secrets, environment variables, and protection rules for the jobs that references the environment.

#### Environment Example

```yaml
name: Deploy to Testing  

on:  
  push:
    branches:  
      - dev  

jobs:  
  deploy:  
    runs-on: ubuntu-latest  
    environment:
        name: Testing   # references the Testing environment 
        url:  https://example.com  # here, we can specify the link to the deployed application or service, so that it is displayed in the workflow UI after completion    
    steps:  
      - name: Checkout Code  
        uses: actions/checkout@v4  

      - name: Use Secret API Key  
        run: echo "Using API Key: ${{ secrets.API_KEY }}"  # Access environment secret

```
## GITHUB_TOKEN & Permissions
The `GITHUB_TOKEN` is an automatically generated unique secret by GitHub for each job. It expires the token when a job completes. It is used so that workflows can securely interact with the repo, providing a way to restrict what the workflow can do. It is limited to the repository where the workflow is running.

We can set some default permissions for the GITHUB_TOKEN, in a repository.

We can use `permissions` keyword in the workflow to modify the default permissions granted to the GITHUB_TOKEN, adding or removing access as required, so that we only allow the minimum required access.
- If it is defined at the workflow level, the permissions being set for the GITHUB_TOKEN will apply to all jobs in the workflow. 
- If it is defined at the job level, the permissions being set for the GITHUB_TOKEN will apply to the specific job in workflow. 

For more info, checkout the following:
- [About GITHUB_TOKEN](https://docs.github.com/en/actions/security-for-github-actions/security-guides/automatic-token-authentication#about-the-github_token-secret)

- [Different Permissions for GitHub token](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token)

- [Setting the default permissions of GITHUB_TOKEN for repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#setting-the-permissions-of-the-github_token-for-your-repository)

## Creating Actions Secrets and Variables at Repository Level
- Go to `Settings`(Repository) > `Secrets and variables` > `Actions`.
- In the `Secrets` tab, click on `New repository secret` to create secrets to be used by actions defined in this repo. We can access these using the `secrets` context.  

- In the `Variables` tab, click on `New repository variable` to create secrets to be used by actions defined in this repo. We can access these using the `vars` context.

## Deployment Workflow Sample

The following workflow builds, tests and deploys an application. 
```yaml
name: Push Default and Deploy

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:  # as per the azure/login docs
  id-token: write   
  contents: read

jobs:
  build-and-test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup .NET Core
        uses: actions/setup-dotnet@v4.1.0
        with:
          dotnet-version: "8.0.x"

      - name: Restore dependencies
        run: dotnet restore "${{github.workspace}}/src/my-web-app.sln"

      - name: Build
        run: dotnet build "${{github.workspace}}/src/my-web-app.sln"  --no-restore --configuration Release

      - name: Test
        run: dotnet test "${{github.workspace}}/src/my-web-app.sln" --no-restore --logger:"junit;LogFilePath=${{ github.workspace }}/results/test-results.xml"

      # create a test summary markdown file
      # if you don't specify an output file, it will automatically add
      # as a job summary. If you specify an output file, you have to
      # create your own step of adding it to the job summary. I am
      # intentionally doing that to show job summaries
      - name: Create test summary
        uses: test-summary/action@v2.4
        with:
          paths: ${{ github.workspace }}/results/*.xml
          output: ${{ github.workspace }}/results/summary.md
          show: "all"
        if: always()

      # I am adding the test results to the Job Summary
      - name: Add Test Results To Job Summary
        run: |
          echo "TEST RESULTS:" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY # this is a blank line
          cat "${{ github.workspace }}/results/summary.md" >> $GITHUB_STEP_SUMMARY
        if: always()

      - name: Publish
        run: dotnet publish "${{github.workspace}}/src/my-web-app/my-web-app.csproj" -c Release -o mywebapp

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: myapp
          path: mywebapp/**
          if-no-files-found: error

  deploy-to-dev:
    runs-on: ubuntu-latest
    needs: build-and-test
    environment:
      name: DEV
      url: http://my-web-app-please-work-dev.azurewebsites.net/

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: myapp
          path: myapp

      - name: Prove to myself the files are there
        run: |
          ls -la
          ls -la myapp

      - name: Login to Azure
        uses: azure/login@v2.2.0
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v3
        with:
          app-name: ${{ vars.WEB_APP_NAME }}
          slot-name: dev
          package: myapp

  deploy-to-staging:
    runs-on: ubuntu-latest
    needs: build-and-test
    environment:
      name: STAGING
      url: http://my-web-app-please-work-staging.azurewebsites.net/

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: myapp
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
          app-name: ${{ vars.WEB_APP_NAME }}
          slot-name: staging
          package: myapp

  deploy-to-prod:
    runs-on: ubuntu-latest
    needs:
      - deploy-to-dev
      - deploy-to-staging
    environment:
      name: PROD
      url: http://my-web-app-please-work-prod.azurewebsites.net/

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: myapp
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
          app-name: ${{ vars.WEB_APP_NAME }}
          slot-name: prod
          package: myapp
```