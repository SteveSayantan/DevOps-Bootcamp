## Idea
Let's assume, we have a workflow that performs build and test on a pull request. But what if we want to ensure that the workflow must pass before we can merge the PR? With repository rulesets, we can do just that.

Repository rulesets can be defined at the repository level. But they can also be defined at the organizational level and applied to multiple repositories.

Here, we'll see how to define rulesets at the repository level.

## How
- Go to `Settings`(Repository) → `Rules` → `Rulesets` .

- Click on `New ruleset` button and choose `New branch ruleset`.

- In `Ruleset Name`, enter a name for the ruleset e.g. **PR Build Test Workflow Must Pass**.

- Choose the `Enforcement status` as `Active`.

- In `Bypass list`, click on `+ Add bypass` and choose the roles, teams, or apps those can forcefully skip/bypass the ruleset. E.g.,
  - choose the role **Repository admin**.
  - Select **Always** (allows skipping this ruleset for everything it applies to) or **pull requests only** (allows skipping this ruleset for pull requests)

- Click on `Add target` to add branches that will be protected by this ruleset. We choose **Include default branch** here.

- Now, select the rules to applied under `Rules` section. We select
  - `Restrict deletions`
  - `Block force pushes`
  - `Require a pull request before merging` to mandate a PR before pushing.
    - Select the following additional rules under it ![Require_Pull_Request_Rule](../assets/require-pr-rule.JPG)

  - `Require status checks to pass`. In the additional settings under it,
    - Click on `+ Add checks`.
    - In the search box, type the id of the job (present in the workflow) to be executed.

- Click on `Create`.

