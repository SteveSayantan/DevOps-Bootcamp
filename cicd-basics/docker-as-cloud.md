Configuring Docker as a cloud instance in Jenkins using the Docker plugin allows Jenkins to dynamically provision Docker containers as build agents. This provides a highly flexible and scalable environment for your CI/CD pipelines, as Jenkins can spin up agents on demand and tear them down after a build is complete.


**Prerequisites:**

1.  **Jenkins Instance:** A running Jenkins instance.
2.  **Docker Host:** A machine (can be the same as your Jenkins server or a remote one) with Docker installed and running. Here, we are using the controller node itself.
3.  **Docker Plugin for Jenkins:** Ensure the Docker plugin is installed in your Jenkins instance. Go to `Manage Jenkins` \> `Manage Plugins` \> `Available plugins` and search for "Docker" and install it. Restart Jenkins if prompted.


**Steps to Configure Docker as a Cloud in Jenkins:**

1.  **Enable Docker TCP Socket (for remote Docker hosts):**

    **Windows (Docker Desktop):** In Docker Desktop settings, navigate to `General` and ensure "Expose daemon on tcp://localhost:2375 without TLS" is checked.

2. **Configure the Docker Cloud in Jenkins:**

  * Navigate to **Manage Jenkins** \> **Configure Clouds** .

  * Click **Add a new cloud** and select **Docker**.

  * **Configure the Docker Cloud details:**

      - **Name:** Give the Docker cloud a descriptive name (e.g., "MyDockerCloud").

      - **Docker Host URI:**
          * Since Jenkins and Docker are on the *same machine* we use: `tcp://127.0.0.1:2375`
          
      - **Credentials:** If your Docker daemon requires authentication, add credentials here. Otherwise, leave it blank.

      - **Test Connection:** Click the `Test Connection` button. You should see "Version = 28.2.2, API Version = 1.50" if the connection is successful.

      - Check the **Enabled** box.

**4. Configure Docker Agent Templates:**

This is where you define how Jenkins should launch agents within Docker containers.

  - Under your configured Docker Cloud, click **Add Docker Template**.

  - **Configure the Template details:**

      - **Labels:** This is crucial\! Provide a name (e.g., `docker-agent`, `java-build`) that your Jenkins jobs will use to select this agent.

      - **Name:** A descriptive name for the template.

      - **Docker Image:** Specify the Docker image Jenkins should use to launch the agent, e.g. `ubuntu-jenkins:latest`

          - **Important:** This image needs to have a Java installed. Here, we have installed Java manually in the image with the following commands:

            ```bash
            sudo apt update
            sudo apt install fontconfig openjdk-21-jre
            ```
      - **Remote File System Root:** The path inside the Docker container where Jenkins will create the workspace (e.g., `/home/jenkins` or `C:\`). This needs to exist beforehand. Here, we have manually created this directory in our image.

      
      - **Connect Method:** How Jenkins will connect to the agent inside the container. We choose **Attach Docker container**.

      - **Usage:**
          * `Use this node as much as possible`: Jenkins will prefer to use this agent.
          * `Only build jobs with label expressions matching this node`: This agent will only be used if the job explicitly requests its label.
    
      - **Pull strategy:** We have chosen **Never pull** as the image would be present locally.

  * Click **Save** to apply your cloud and template configurations.

**5. Using Docker Agents in Freestyle Jenkins Jobs:**


  - When creating or configuring a Freestyle project, under **General**, check "Restrict where this project can be run".
  - In the "Label Expression" field, enter the label we defined for the Docker Agent Template (e.g., `docker-agent`).

  - Now, add build steps accordingly.

> Since, the Jenkins controller is a Windows machine in this case, it always tries to execute **cmd.exe** inside the container and run the steps using that **cmd** process if we use the `docker {image ubuntu-jenkins:latest}` approach. To prevent that behaviour, we had to configure Docker as a Cloud.  