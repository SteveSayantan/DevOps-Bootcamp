## Jenkins Installation on EC2 Instance
Pre-Requisites:
 - Java (JDK)

### Run the below commands to install Java and Jenkins

Install Java

```bash
sudo apt update
sudo apt install fontconfig openjdk-17-jre
```

Verify Java is Installed

```bash
java -version
```

Now, we can proceed with installing Jenkins. Check the [docs](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu) for latest instructions.

```bash
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

```

**Note:** By default, Jenkins will not be accessible to the external world due to the inbound traffic restriction by AWS. Open port 8080 to allow  *custom TCP* in the inbound traffic rules.


### Login to Jenkins using the below URL:

`http://<ec2-instance-public-ip-address>:8080 `

After you login to Jenkins, 
      - Run the command to copy the Jenkins Admin Password - `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
      - Enter the Administrator password
      - Click on Install suggested plugins

Wait for the Jenkins to Install suggested plugins


Create First Admin User.


Jenkins Installation is Successful. You can now starting using the Jenkins. 

Installing Jenkins will create a *jenkins* user.

Nowadays, Jenkins is used with docker as agents i.e. the jenkins stages will be executed in docker containers. It is useful in terms of cost and efficiency.

## Install the Docker Pipeline plugin in Jenkins:

   - Log in to Jenkins.
   - Go to Manage Jenkins > Manage Plugins.
   - In the Available tab, search for **Docker Pipeline**.
   - Select the plugin and click the Install button.
   - Restart Jenkins after the plugin is installed.
   

Wait for the Jenkins to be restarted.


## Docker Agent Configuration

Run the below command to Install Docker

```bash
sudo apt update
sudo apt install docker.io -y
```


### Grant Jenkins user and Ubuntu user permission to docker deamon

```bash
sudo su # switching to the root user
usermod -aG docker jenkins
usermod -aG docker ubuntu
systemctl restart docker
```

Once you are done with the above steps, re-login to the ec2 instance to see the changes. Also, it is better to restart Jenkins at this point.

Go to:`http://<ec2-instance-public-ip>:8080/restart`

### Final Step
- Run `sudo su - jenkins` to switch to jenkins user.
- Run `docker run hello-world` 

If we can see **Hello from Docker!** in the terminal, the docker agent configuration is successful.  

## Important
Everytime an ec2 instance is restarted, it gets a new public IP. So, when using Jenkins with an ec2 instance, we need to update the IP in the Jenkins configuration whenever the server is restarted.

- Go to Manage Jenkins > System.
- Scroll down to Jenkins Location section.
- Update the Jenkins URL as `http://<current_ip>:8080/`
- Click on Save button.


