## Idea
Everytime we execute a workflow, a GitHub Context object is created. It contains information about the workflow. For details, check [this](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#about-contexts)

### Displaying the GitHub Context object
```yaml
name: Displaying GitHub Context Object
on: workflow_dispatch

jobs:
    job-1:
        runs-on: ubuntu-latest

        steps:
            - name: Print GitHub Context
              env:      # this env context stores variables only available to current step

              # loc_var is the name of the variable. It is only accessible within this step
                loc_var: ${{ toJSON(github) }} # toJSON is a built-in function that returns a pretty-print JSON representation
              run: echo $loc_var
         
```
Check out the different built-in functions offered by GitHub, [here](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/evaluate-expressions-in-workflows-and-actions#functions)

### Passing information between jobs
This is how we pass string data between jobs:

```yaml
name: Passing Information Between Jobs
on: workflow_dispatch

jobs:

  job1:
    runs-on: ubuntu-latest
    steps:
    - id: step1   # this id would be used to access the output

      run: echo "test=hello" >> $GITHUB_OUTPUT # $GITHUB_OUTPUT is a default env variable that stores the path on the runner to the file that sets the current step's outputs. It is unique for each step.

    - id: step2

     # basically, we are appending a variable declaration to the file pointed by $GITHUB_OUTPUT
      run: echo "test=world" >> $GITHUB_OUTPUT


    outputs: # mapping the outputs to variables

      firstOp: ${{ steps.step1.outputs.test }}   # firstOp stores hello
      secondOp: ${{ steps.step2.outputs.test }}  # secondOp stores world

  job2:
    runs-on: ubuntu-latest

    needs: job1   # to access the outputs of a particular job, the current job must depend on it

    steps:
    - run: echo ${{needs.job1.outputs.firstOp}} ${{needs.job1.outputs.secondOp}}
```


### Variables
Variables provide a way to store and reuse non-sensitive configuration information. You can store any configuration data such as compiler flags, usernames, or server names as variables. 

You can set your own custom variables or use the default environment variables that GitHub sets automatically. For more information, see [this](https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/store-information-in-variables#default-environment-variables).

To set a custom environment variable for a single workflow, you can define it using the `env` key. The scope of a custom variable set by this method is limited to the element in which it is defined.
Variables can be scoped for:
- The entire workflow, by using `env` at the top level of the workflow file.
- The contents of a job within a workflow.
- A specific step within a job.

```yaml
name: Creating Variables
on: workflow_dispatch

env:  # these variables would be created in all the runner instances, hence accessible throughout the entire workflow.
  VAR1: myworkflowvar1
  VAR2: myworkflowvar2
  VAR3: myworkflowvar3

jobs:

  job1:
    runs-on: ubuntu-latest

    env:  # these variables are accessible only within this job
      VAR2: myjobvar2
      VAR3: myjobvar3

    steps:

      # we can also access a variable as $variable_name or ${{ env.variable_name }}

    - run: |
        echo value of VAR1 is $VAR1
        echo value of VAR1 is ${{ env.VAR1 }}

        echo value of VAR2 is $VAR2    
        echo value of VAR3 is $VAR3

      env: # this variable is accessible only within this step
        VAR3: mystepvar3

```
When accessing a variable, the lookup follows this order:

1. **Step-Level Variable**: Highest precedence; if defined, it overrides job- and workflow-level variables of the same name.
1. **Job-Level Variable**: Overrides workflow-level variables of the same name for all steps in the job.
1. **Workflow-Level Variable**: Lowest precedence; used if no job or step overrides are present.

*Variables defined at a lower level (step) are not available to higher levels (job or workflow).*

Hence, in the above example, the output is as follows:

```bash
value of VAR1 is myworkflowvar1
value of VAR1 is myworkflowvar1
value of VAR2 is myjobvar2
value of VAR3 is mystepvar3
``` 
