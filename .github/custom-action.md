# Custom GitHub Action
Suppose, we have a job with multiple steps, which is used in more than one workflows. Instead of copying that job again and again, we can simply define a custom action (of `composite` type) consisting of the same steps as the job, in a separate GitHub repo. Now this custom action can be used anywhere without the need of repeating ourselves every time.

While defining a custom action, we can combine action, workflow, and application code in a single repository or keep the action in its own repository instead of bundling it with other application code. Here, we would take the latter approach as it makes tagging and versioning easier.

## Types of Custom GitHub Action
There're three types of custom actions:

- JavaScript or TypeScript Actions: These are described as the most powerful type of custom action. However, their tradeoff is that they are also the most complex because they require the creator to have specific knowledge of JavaScript or TypeScript. Check out the [docs](https://docs.github.com/en/actions/tutorials/create-actions/create-a-javascript-action).

- Docker Container Actions: These allow us to write an action in any language we choose, such as C# or Go. The primary tradeoff is performance; they are the slowest type of action because they must run inside a container. Additionally, they are restricted to running only on Linux Runners that have Docker installed. Check out the [docs](https://docs.github.com/en/actions/tutorials/use-containerized-services/create-a-docker-container-action).

- Composite Actions: A composite action is a collection of multiple steps bundled into a single file. These are ideal for centralizing code to avoid duplication across different workflows, such as combining build and test steps into one call. They allow you to parameterize inputs and outputs to make the steps reusable across various scenarios. These are primarily used to simplify and reduce the length of workflow files. Check out the [docs](https://docs.github.com/en/actions/tutorials/create-actions/create-a-composite-action).

> A GitHub Action repository contains an `action.yaml` file in its root.

## Example
Here, we're going to create a composite action. Its **action.yaml** file consists of all the steps we need to create the composite action.

The structure of the GitHub repository containing our composite action:
```
my-composite-action/
├── action.yaml
└── README.md
```

This is how our **action.yaml** looks like:

```yaml
name: "Build and Publish .NET Core App"			# This name shows up during execution or in the marketplace (if uploaded)

description: "Composite action to build and publish a .NET Core application"

inputs:		# list of the stuff we want to be passed while calling this action
  dotnet-version:
    description: "The version of .NET Core to use"
    required: true
  project-path:
    description: "The path to the .NET Core project file"
    required: true	
  output-path:	
    description: "The output path for the published application"
    required: true
	
outputs:	# stuff we get from this action
  artifact-path:
    description: "The path to the build artifact"
    value: ${{ steps.artifact-upload-step.outputs.artifact-url }}
	
runs:
  using: "composite"	# since, we're creating a composite action
  
  steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup .NET Core
      uses: actions/setup-dotnet@v4.1.0
      with:
        dotnet-version: ${{ inputs.dotnet-version }}

    - name: Restore dependencies
      run: dotnet restore "${{ inputs.project-path }}" # when we use a run statement in a custom action, we must specify a shell which must exist on the runner we'll be using
      shell: bash

    - name: Build
      run: dotnet build "${{ inputs.project-path }}" --no-restore --configuration Release
      shell: bash

    - name: Publish
      run: dotnet publish "${{ inputs.project-path }}" -c Release -o ${{ inputs.output-path }}
      shell: bash

    - name: Upload build artifact
      id: artifact-upload-step
      uses: actions/upload-artifact@v4
      with:
        name: myapp
        path: ${{ inputs.output-path }}/**
        if-no-files-found: error
```

## Using our Composite Action

We can use this composite action in our job as follows:

```yaml
...
jobs:
  build:
    runs-on: ubuntu-latest
	
	steps:
      - name: Before Composite Action
        run: |
          echo "Hello from before composite action"

      - name: Build and Publish .NET Core App
        uses: github_username/my-composite-action@main
        with:
          dotnet-version: "8.0.x"
          project-path: "${{ github.workspace }}/src/my-web-app/my-web-app.csproj"
          output-path: "mywebapp"

      - name: After Composite Action
        run: |
          echo "Hello from after composite action"
```
