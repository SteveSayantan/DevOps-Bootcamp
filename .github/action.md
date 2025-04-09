## Intro to Action
Each step in the workflow file, can also use an action. An action is a reusable unit of code that performs a specific task in a workflow. Actions simplify workflows by abstracting common functionality, allowing developers to reuse them across different workflows or repositories. 

We can use an action defined in the same repository as the workflow, a public/private repository, or in a published Docker container image. Often they are shared publicly at [GitHub Marketplace](https://github.com/marketplace?type=actions)

- Different syntaxes to specify an action [docs](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses)

- Specifying input parameters to an action [docs](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idstepswith)

> Refer to the README file of an action for user-inputs, various examples and usecases

## Example 1

```yaml
name: CI Workflow

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # Check out the repository code
      - name: Check out code
        uses: actions/checkout@v4

      # Set up Node.js environment
      - name: Set up Node.js
        uses: actions/setup-node@v4

        # providing an input parameter to 'setup-node' action
        with:   
          node-version: '16'

```

## Example 2 (For reference)
```yaml
# This workflow runs on every pull request on main

name: PR - Build / Test  
on:
  pull_request:
    branches:
      - main
  workflow_dispatch:

jobs:
  build:
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
          path: mywebapp/**   # by default, paths provided to actions are relative to `GITHUB_WORKSPACE` directory. So it is equivalent to `${{ github.workspace }}/mywebapp/**`
          if-no-files-found: error
```
## Other Important References

- [Adding a job summary](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions#adding-a-job-summary)

- [Artifacts](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow#about-workflow-artifacts)

