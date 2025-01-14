## GitHub Actions
GitHub Actions is a continuous integration and continuous delivery (CI/CD) platform that allows us to automate your build, test, and deployment pipeline. We can create workflows that build and test every pull request to our repository, or deploy merged pull requests to production.

GitHub Actions goes beyond just DevOps and lets us run workflows when other events happen in our repository. For example, we can run a workflow to automatically add the appropriate labels whenever someone creates a new issue in our repository.
#### Resources
- [Docs](https://docs.github.com/en/actions/about-github-actions/understanding-github-actions)
- [Mickey Goussel YT](https://youtube.com/playlist?list=PLiO7XHcmTsleVSRaY7doSfZryYWMkMOxB&si=kT7crVPw3xdNlznG)

#### Overview
- **Workflow** - A workflow is a configurable automated process made up of one or more jobs. Workflows are defined in `.yml` files in the `.github/workflows` directory of your repository.

- **Jobs** - A job is a set of steps that execute on the same _runner_. Runner is a server that has the GitHub Actions runner application installed. Jobs can run sequentially or in parallel.

- **Steps** - A step is an individual task that can run commands or actions e.g. `actions/checkout@v2`. Each step in a job executes on the same runner, allowing for direct file sharing.

> Summary: The workflow is a set of jobs and each job is a set of steps. Each step can be an action or a shell command.

- **Event** - An event is a specific activity that triggers a workflow. For example, activity that occurs on GitHub, such as opening a pull request or pushing a commit.

- **Action** - An action is a reusable unit of code. You can use an action defined in the same repository as the workflow, a public repository, or in a published Docker container image. See these examples [here](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#jobsjob_idstepsuses)


For detailed syntax, checkout [workflow-syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions#about-yaml-syntax-for-workflows)





