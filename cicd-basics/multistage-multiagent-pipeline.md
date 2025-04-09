## WHAT
In a multi-agent pipeline, each stage runs on a unique agent. This approach is useful in case of an application with multiple technologies or containing conflicting dependencies.

## Example

```groovy
pipeline {
    agent none
    stages {
        stage('Back-end') {
            agent {
                docker { image 'maven:3.9.9-eclipse-temurin-21-alpine' }
            }
            steps {   // each step in a stage will be executed on the agent specified for that stage
                sh 'mvn --version'
            }
        }
        stage('Front-end') {
            agent {
                docker { image 'node:22.11.0-alpine3.20' }
            }
            steps {
                sh 'node --version'
            }
        }
    }
}
```
> Since we are using different agent for each stage, Jenkins will checkout the source code at the beginning of each stage due to the default behavior of declarative pipeline.