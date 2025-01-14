- CI stands for Continuos Integration, CD stands for Continuos Delivery.

  - CI is a process where we integrate a set of tools or processes that we need to follow before the delivery of the application.

  - CD is the process of deploying our app on a specific platform.

- Before delivering an app, every company must undergo some steps, e.g., 
  - Unit Testing
  - Static Code Analysis : Performs syntactical analysis, checks for code formatting/indentation, unused variables etc. 
  - Code Quality/ Vulnerability Test
  - Reports: Stats about test coverage, code quality checks etc.
  - Deployment

CI/CD helps automate all these steps. Otherwise, performing all these steps manually for every change in the code will take very long and thereby delaying the delivery.

### Differences between Continuous Integration, Continuous Delivery and Continuous Deployment

1. **Continuous Integration (CI)**:
   - **Purpose**: CI focuses on **automating the integration** of code changes from multiple developers into a single project. The goal is to frequently integrate code (several times a day) and **run automated tests** to detect issues early.
   - **Example**: Imagine a team of developers working on a JavaScript application. Each developer pushes their code changes to a shared repository on GitHub. With CI configured (using tools like Jenkins or GitLab CI), every code push triggers a **build** and a set of **unit tests**. If any test fails, the team is notified immediately to fix it, ensuring that the main branch remains stable and bug-free.

1. **Continuous Delivery (CD)**:
   - **Purpose**: Continuous Delivery automates the process of preparing code for release but requires a **manual approval step** before production deployment. This stage ensures that the codebase is always in a deployable state, even if the actual deployment is not automated.
   - **Example**: In the same JavaScript application, the CI pipeline automatically runs integration tests and builds the application. In a CD setup, this pipeline also deploys the tested application to a **staging environment**. Once tested and approved by the QA team, a manager can trigger a **manual deployment to production**. This approach provides a higher level of control over what goes into production.

1. **Continuous Deployment (CD)**:
   - **Purpose**: Continuous Deployment takes Continuous Delivery a step further by **automating the entire process**, including deployment to production. Each successful change that passes all tests is deployed automatically without manual intervention, enabling rapid delivery of updates.
   - **Example**: For a high-frequency application like a social media platform, the development team may practice continuous deployment. Each change pushed to the repository, once it passes all tests (unit, integration, and end-to-end tests), is **automatically deployed to production**. This allows users to see new features, improvements, or fixes almost immediately after they’re completed by developers.

##### **Key Differences**:
- **Continuous Integration**: Focuses on code integration and testing automation.
- **Continuous Delivery**: Adds automation up to the staging environment, with a manual step for production.
- **Continuous Deployment**: Automates everything, including deployment to production, without manual steps.

### Jenkins Pipeline
Suppose, some changes are pushed to our Github. We shall set up Jenkins such that for any PR/commit on the repo it will run a set of actions automatically with the help of multiple tools. Hence Jenkins is called an orchestrator.

  - e.g. for a Java application, Jenkin can be configured to run Maven for building, Junit for testing, ALM for reporting etc. whenever there is a PR/commit on our repo. 

- Whenever there is some new feature added,

  - it is first tested in a Dev environment which consists of a minimal server.
  - on success, it is now deployed on a Staging environment which consists of more servers than Dev environment but less than Production.
  - finally, it is deployed on the Production environment consisting of lots of servers.

  Jenkins can automatically promote our application to be deployed from one env to the other.  

- Disadvantages of Jenkins

  - While working with Jenkins, generally, we do not put all the load in a single machine (as it may cause dependency conflicts and not practical). Instead, we create a master node, and connect several ec2 instances to it. Now using the master node, we configure those as worker nodes and schedule them to execute the pipelines/builds.

  - But this setup is not scalable as the setup becomes very costly as well as less maintainable.

  - Most of the worker nodes may sit idle for a long time.

  - To get automatic scale up and scale down, we use GitHub actions. 
  
    For every PR, GitHub Actions will spin up a docker container in a remote server for us and everything is executed in it. When there is no change in the code, the container will be deleted and server will be used for some other project in another repo. As a result, there will be no wastage of resources.

### References
- [TrainWithShubham](https://youtu.be/XaSdKR2fOU4?si=awS9KPt3gys0P8TM)

- [Abhishek Veeramalla](https://youtube.com/playlist?list=PLdpzxOOAlwvLUH6ww022l7OZGakJYP9WY&si=KUAtAdWDxiEX-Ewf)
