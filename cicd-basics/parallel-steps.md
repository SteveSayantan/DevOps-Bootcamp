## Jenkins Steps in Parallel
Jenkins Pipeline allows executing multiple steps in parallel to improve efficiency and reduce build time.

This is useful for:

✅ When we have a lot of really powerful machines with a lot of cpu capacity that are being under utilized. By using that excess cpu capacity based on the types of jobs you're building maybe such as c plus builds you could complete those job runs faster.  

✅ we might just have a lot of spare build agents maybe they're not high cpu maybe they're not high memory but you just have a lot of them. By having that excess capacity you can bring that capacity in to your jobs and spread your workload out.  

✅ Deploying to multiple environments (e.g., Dev, Staging, Production) in parallel.

## Example

### Basic Parallel Execution
The following Declarative Pipeline runs two tasks (Build and Test) in parallel in the same node:

```groovy
pipeline {
    agent any

    stages {
        stage('Parallel Execution') {
            parallel {
                stage('Build') {
                    steps {
                        echo 'Building the project...'
                        sh 'npm install'
                    }
                }
                stage('Test') {
                    steps {
                        echo 'Running tests...'
                        sh 'npm test'
                    }
                }
            }
        }
    }
}
```
### Parallel Execution with Different Agents
In the following example, `build-a` and `build-b` stages in `build` run in parallel. Also, `run-a` and `run-b` in `run` execute in parallel.

```groovy
pipeline {

  agent none

  stages {

    stage('build') {

      parallel {
        // the following stages run in parallel
        stage('build-a') {
          agent {label 'node-ubuntu'}
          // code is checked out here
          steps {
            sh 'echo build application in ubuntu'
          }
        }
        stage('build-b') {
          agent {label 'node-fedora'}
          // code is checked out here
          steps {
            sh 'echo build application in fedora'
          }
        }
      }
    }
    stage('run') {

      parallel {
        // the following stages run in parallel
        stage('run-a') {
          agent {label 'node-ubuntu'}
          // code is checked out here (unnecessary)
          steps {
            sh 'echo run application in ubuntu'
          }
        }
        stage('run-b') {
          agent {label 'node-fedora'}
          // code is checked out here (unnecessary)
          steps {
            sh 'echo run application in fedora'
          }
        }
      }
    }
  }
}

```
### Skipping the default checkout behavior

Now, if the pipeline above is executed as **Pipeline Script from SCM**, code checkout occurs in both of the nodes in both `build` and `run`. Due to the default behavior of declarative pipeline, when we move to new agents, we checkout the source code, even if it exists in the node.

So we modify our Jenkinsfile as follows:

```groovy
pipeline {

  agent none

  options {
    skipDefaultCheckout true   // this will prevent the default checkout behavior. Hence, we need to explicitly checkout the source code when needed. Generated using Declarative Directive Generator
  }
  stages {

    stage('build') {

      parallel {
        
        stage('build-a') {
          agent {label 'node-ubuntu'}
          
          steps {
            checkout scm    // this step will checkout the source code
            sh 'echo build application in ubuntu'
          }
        }
        stage('build-b') {
          agent {label 'node-fedora'}

          steps {
            checkout scm  // this step will checkout the source code
            sh 'echo build application in fedora'
          }
        }
      }
    }
    stage('run') {

      parallel {
        // the following stages run in parallel
        stage('run-a') {
          agent {label 'node-ubuntu'}
         
          steps {
            sh 'echo run application in ubuntu'
          }
        }
        stage('run-b') {
          agent {label 'node-fedora'}

          steps {
            sh 'echo run application in fedora'
          }
        }
      }
    }
  }
}

```
### Adding Sequential stages
Till now, we have been using two agent nodes labelled as `node-fedora` and `node-ubuntu`. Suppose, there are multiple nodes with the same label (say `node-ubuntu`). In that case, the node assigned for **build-a** in **build**, might be different from the node assigned for **run-a** in **run**.

This is because when multiple agents have the same label, Jenkins randomly picks one of them to execute a job. This can cause dependency issues where a later stage might run on an agent that lacks the required files or environment.

Sequential stages allow us to stay on the same agent throughout a whole run.

In the follwing example, `build and run -- a` and `build and run -- b` run in parallel. Default code checkout takes place in both nodes just before executing the **build** stage.

```groovy
pipeline {
  agent none
  
  stages {
    stage('build and run') {
      parallel {
        stage('build and run -- a') {

          agent {label 'node-ubuntu'}

          // code is checked out here (default behavior)

          stages {
            stage('build') {
              
              steps {
                sh 'echo build application in ubuntu'
              }
            }
            stage('run') {
              steps {
                sh 'echo build application in ubuntu'
              }
            }
          }
        }
        stage('build and run -- b') {

          agent {label 'node-fedora'}

          // code is checked out here (default behavior)

          stages {
            stage('build') {
              steps {
                sh 'echo build application in fedora'
              }
            }
            stage('test') {     // this is an extra step, added just for fun
              steps {
                sh 'echo test application in fedora'
              }
            }
            stage('run') {
              steps {
                sh 'echo run application in fedora'
              }
            }
          }
        }            
      }
    }
  }
}
```

## Reference
- [Jenkins Steps in Parallel CloudBees](https://youtu.be/6wNbjP2WUMo?si=SxYo7z-pcjBQwvrE)