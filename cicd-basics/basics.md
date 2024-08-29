- CI stands for Continuos Integration, CD stands for Continuos Delivery.

  - CI is a process where we integrate a set of tools or processes that we need to follow before the delivery of the application.

  - CD is the process of deploying our app on a specific platform.

- Before delivering an app, every company must undergo some steps, e.g., 
  - Unit Testing
  - Static Code Analysis : Performs syntactical analysis, checks for code formatting/indentation, unused variables etc. 
  - Code Quality/ Vulnerability Test
  - Reports: Stats about test coverage, code quality checks etc.
  - Deployment

CI/CD helps automate all these steps. Otherwise, performing all these steps for every change in the code will take very long and thereby delaying the delivery.

- Jenkins Pipeline: Suppose, some changes are pushed to our Github. We shall set up Jenkins such that for any PR/commit on the repo it will run a set of actions automatically with the help of multiple tools. Hence Jenkins is called an orchestrator.

  - e.g. for a Java application, Jenkin can be configured to run Maven for building, Junit for testing, ALM for reporting etc. whenever there is a PR/commit on our repo. 

- Whenever there is some new feature added,

  - it is first tested in a Dev environment which consists of a minimal server.
  - on success, it is now deployed on a Staging environment which consists of more servers than Dev environment but less than Production.
  - finally, it is deployed on the Production environment consisting of lots of servers.

  Jenkins can automatically promote our application to be deployed from one env to the other.  

- Disadvantages of Jenkins

  - While working with Jenkins, generally, we do not put all the load in a single machine. Instead, we create a master node, and connect several ec2 instances to it. Now using the master node, we configure those as worker nodes and schedule them to execute the pipelines.

  - But this setup is not scalable as the setup becomes very costly as well as less maintainable.

  - Most of the worker nodes may sit idle for a long time.

  - To get automatic scale up and scale down, we use GitHub actions. 
  
    For every PR, GitHub Actions will spin up a docker container in a remote server for us and everything is executed in it. When there is no change in the code, the container will be deleted and server will be used for some other project in another repo. As a result, there will be no wastage of resources.


