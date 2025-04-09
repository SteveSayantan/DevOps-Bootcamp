## Introduction
A Parameterized Pipeline in Jenkins allows users to pass inputs dynamically before triggering a job. This makes pipelines flexible and reusable, as different builds can run with different configurations.

## Steps

### Adding Parameters to the Job Configuration

- First, create a **Pipeline** job.

- In **Configure** > **General** section, we can simply check the box for **This project is parameterized**. After that, we can choose the type of parameter from the **Add Parameter** drop-down and add it.

- We can access the parameter (say, `demo` ) from our pipeline script, e.g.,
  ```groovy
    pipeline {
        agent any

        stages {
            stage('Hello') {
                steps {
                    echo 'Different ways to access a parameter "demo"'
                    echo "${demo}"
                    sh 'echo ${demo}'
                    sh "echo ${params.demo}"
                }
            }
        }
    }
  ```
- Click on **Save**
- Click on **Build with Parameters** to provide the input to the parameter.

### Adding Parameters to the Pipeline Script
In the previous approach, the parameters used are not contained in the Jenkinsfile. However, a better approach is to declare the parameters within the Jenkinsfile.

- Make sure that the **This project is parameterized** checkbox is unchecked.

- Declare the parameters within the pipeline as follows. Use the **Declarative Directive Generator** (available at e.g. http://212.2.242.70:8080/directive-generator/) to generate the parameter directive.

  ```groovy
    pipeline {
        agent any
        parameters {
            string defaultValue: 'good evening', description: 'what to greet', name: 'greet', trim: true
            choice choices: ['Tea', 'Coffee', 'Cold Drink'], description: 'What to offer', name: 'beverages'
        }
        stages {
            stage('Hello') {
                steps {
                    echo "${greet}, user"
                    sh "echo Lets discuss the topic over some ${params.beverages}"
                }
            }
        }
    }
  ```

- Click on **Save**.

- Since this job has not been executed yet, Jenkins has no idea about the parameters in it. Hence we woundn't see **Build with Parameters** button. Also, no parameters will show up in **Configure** > **General** section for the same reason.

- Click on the **Build Now** button to kick off the initial build with the default values of the parameters.

- Just after the initial build, our declared variables will show up in **Configure** > **General** section. Also, **Build with Parameters** button will appear instead of **Build Now**.

- Now, we can click on **Build with Parameters** button and provide input to the declared parameters.

## References
- [Add a String Paramter in Jenkins](https://youtu.be/Um3-Oj72dF4?si=CZSKasV12JEy0zIq)

- [Add a Password Paramter in Jenkins](https://youtu.be/zxKUo0mO10M?si=ELsaq9mMW3HWNm4M)

