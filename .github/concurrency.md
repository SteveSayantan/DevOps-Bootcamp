## WHY
Imagine we have a GitHub Actions CI/CD pipeline that deploys a frontend application whenever a new commit is pushed to the main branch.

- **Without Concurrency**
  - Developer A pushes code at 10:00 AM, triggering a deployment.
  - Developer B pushes another commit at 10:01 AM, triggering another deployment while the first is still running.

This can cause conflicts, unnecessary resource usage, and deployment failures due to overlapping operations. Concurrency in GitHub Actions helps manage and control the execution of workflows when multiple workflow runs are triggered simultaneously.

## HOW
We use the keyword **concurrency** at the workflow level. Under it, we provide a group name for the workflow, using `group` keyword. Workflows with the same `group` name would be affected by the concurrency rules.

- `cancel-in-progress: true` : If another workflow run starts within the same concurrency group (i.e. with the same group name), the currently running workflow is canceled. Only the latest run continues execution.

- `cancel-in-progress: false` : If another workflow run starts within the same concurrency group (i.e. with the same group name), it will be queued until the currently running workflow completes.

There can be at most one running and one pending job in a concurrency group at any time. When a concurrent job or workflow is queued, if another job or workflow using the same concurrency group in the repository is in progress, the queued job or workflow will be pending. Any existing pending job or workflow in the same concurrency group, if it exists, will be canceled and the new queued job or workflow will take its place.


### Example 1
```yaml
on:
  push:
    branches:
      - main

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```
In the above example, if a new commit is pushed to the main branch while a previous run is still in progress, the previous run will be cancelled and the new one will start.

### Example 2
```yaml
on:
  push:
    branches:
      - main

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: false
```
In the above example, if a new commit is pushed to the main branch while a previous run is still in progress, the new run will be queued until the previous one is finished.


## Reference
- For further details, checkout [Docs](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#concurrency)