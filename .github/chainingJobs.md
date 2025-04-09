## Idea
In a workflow, we generally have multiple jobs. By default, each of the jobs runs parallelly in separate runners given enough runners are available. If sufficient runners are not available, some of the jobs will be queued until a runner is free.

If we use a GitHub-hosted runner, each job runs in a **fresh instance** of a runner image specified by runs-on.

However, the order in which the jobs run can be controlled.

- #### Parallel Execution
Here, job1 and job2 will execute simultaneously in two separate runners (default behavior).

```yaml
name: Parallel Jobs

on: workflow_dispatch
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Job 1"
  job2:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Job 2"

```

- #### Sequential Execution with Dependencies
Jobs can depend on other jobs using the `needs` keyword. This creates a dependency chain and ensures that dependent jobs execute only after their prerequisites are completed. 

If any of the prerequisites fails or skips, the corresponding job using `needs` skips.

```yaml
name: Dependent Jobs

on: workflow_dispatch

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building project"

  test:
    runs-on: ubuntu-latest
    needs: build  # job with id `build` must execute successfully to run this job
    steps:
      - run: echo "Running tests"

  deploy:
    runs-on: ubuntu-latest
    needs: test     # we can specify multiple dependencies in an array
    steps:
      - run: echo "Deploying"

```
- #### Conditional Execution
Jobs can have conditional execution rules using the `if` keyword. We can use it to prevent a step from running unless a condition is met.

```yaml
name: Conditional Jobs
on: workflow_dispatch
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building project"

  deploy:
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'  # this job runs only if the current branch is main
    steps:
      - run: echo "Deploying to production"

```

## Example
 
```yaml
name: Chaining Jobs

on:
  workflow_dispatch:
 
    inputs:
      run-job-3:
        description: "Run job 3"
        type: boolean

jobs:

  job-1:
    name: Job 1  
    runs-on: ubuntu-latest
    steps:
    - name: Output for Job 1
      run: echo "Hello from Job 1. Run Job 3 equals ${{ github.event.inputs.run-job-3 }}" 

  job-2:
    name: Job 2
    runs-on: ubuntu-latest
    needs:
      - job-1
    steps:
    - name: Output for Job 2
      run: echo "Hello from Job 2"

  job-3:
    name: Job 3
    if: github.event.inputs.run-job-3 == 'true' # if the input is false, this job would be skipped
    runs-on: ubuntu-latest
    needs:
      - job-1
    steps:
    - name: Output for Job 3
      run: echo "Hello from Job 3"

  job-4:
    name: Job 4
    runs-on: ubuntu-latest
    # if: always()    # Causes the job to always execute
    needs:    
      - job-2
      - job-3
    steps:
    - name: Output for Job 4
      run: echo "Hello from Job 4"
        
```
#### Explanation
- Here, every job runs on a separate fresh runner image.

- `job-1` runs first.

- `job-2` and `job-3` depends on `job-1`. They run after `job-1` finishes successfully. `job-3` also depends on the input condition.

- `job-4` depends on both `job-2` and `job-3`. If any of them skips or fails, `job-4` also skips. 
  - However, due to `if: always()`, `job-4` runs irrespective of the success of its dependencies i.e. even if any of its dependencies fails or skips, `job-4` would execute.

## Notes
- Within a job, if one step fails, the following steps are skipped (default behavior).