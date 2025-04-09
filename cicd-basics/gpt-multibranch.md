# Multibranch Pipeline in Jenkins: A Complete Guide

## Introduction
Jenkins' **Multibranch Pipeline** feature allows us to automate CI/CD workflows for repositories with multiple branches. It dynamically discovers, manages, and executes pipelines for each branch within a project, ensuring that each branch gets built and tested independently.

In this guide, we will walk through the process of setting up a **Multibranch Pipeline in Jenkins**, from configuring webhooks to handling pull requests and merging changes.

---

## **Getting Started**
Before diving into the Multibranch Pipeline setup, let's take a look at the repository structure.

Initially, our GitHub repository consists of:
- A single branch: **main**
- A **README.md** file


![Repository Structure](insert-image-link-here)

---

## **Setting Up GitHub Webhook**
To allow Jenkins to automatically detect changes in the repository, we need to configure a **GitHub Webhook**.

### **Steps to Configure GitHub Webhook:**
1. Navigate to **Settings** in your GitHub repository.
2. Click on **Webhooks** > **Add webhook**.
3. Under **Payload URL**, enter your Jenkins URL followed by `/github-webhook/`.
4. Select **Let me select individual events** and check the following events:
   - Branch or tag creation
   - Branch or tag deletion
   - Push
   - Pull requests
5. Click **Save webhook**.

> **Tip:** After creating the webhook, check the **Recent Deliveries** section in the webhook configuration to verify the connection was successful.

---

## **Creating a Multibranch Pipeline Job in Jenkins**
Once the webhook is set up, we can create a **Multibranch Pipeline** job in Jenkins.

### **Steps to Configure a Multibranch Pipeline:**
1. Open Jenkins and click **New Item**.
2. Select **Multibranch Pipeline** and enter a name for the job.
3. Under **Branch Source**, select **GitHub** and provide the repository URL.
4. Add **credentials** if required.
5. Click **Save**.

When we navigate back to the job, we might notice that Jenkins hasn't detected any pipeline yet. This happens because our repository does not contain a **Jenkinsfile**.

### **Adding a Jenkinsfile**
To define our pipeline, we create a **Jenkinsfile** and commit it to the repository. Once committed, Jenkins will detect the file and trigger a build automatically, thanks to the webhook integration 🎉🥳

At this point, our multibranch pipeline is now active, with Jenkins successfully scanning and creating a pipeline for the `main` branch.

---

## Creating a New Branch in GitHub
By default, our pipeline runs on the `main` branch. Let’s create a new branch called `fix-123` and check how Jenkins responds.

```bash
git checkout -b fix-123
git push origin fix-123
```

Upon refreshing the **Multibranch Pipeline Job** in Jenkins, we can see that Jenkins has automatically created a **new job** corresponding to `fix-123`. This is the true power of a **Multibranch Pipeline** 🚀

Now, let’s edit the **Jenkinsfile** in the `fix-123` branch and commit the changes. Once done, Jenkins will trigger a build for `fix-123` automatically.

On checking the build output, we notice that the **for the PR** stage is skipped since the **when** condition in our pipeline wasn’t met.

---

## **Creating a Pull Request**
Now, let’s create a **Pull Request** (PR) from `fix-123` to `main` in GitHub.

Once the PR is opened, Jenkins will:
- **Automatically create a new job** for the PR.
- **Trigger a new build** for the PR branch.

> **Tip:** For a pull request with ID 24 (say), the `BRANCH_NAME` environment variable in Jenkins is set to something like `PR-24`. You can check more details at `http://<YOUR-JENKINS-URL>/env-vars.html`.

On examining the build logs, we observe that **for the fix branch** stage is skipped. This is because Jenkins intelligently differentiates between branch builds and PR builds based on our pipeline configuration.

---

## **Merging the Pull Request**
Once we merge the pull request and delete the branch `fix-123`, Jenkins updates the pipeline by:
- **Striking through** the jobs for the deleted branch and pull request.
- **Automatically removing them** when we click on **Scan Repository Now**.
- **Triggering a final build** on `main` due to the merge.

On checking the build output, both **for the fix branch** and **for the PR** stages are skipped, as expected.

---

## **Unthrottling GitHub API Usage**
GitHub imposes a **rate limit** on API calls, which can sometimes cause Jenkins jobs to fail due to exceeding the allowed requests.

To resolve this, we can configure **GitHub API usage throttling** in Jenkins:

### **Steps to Configure API Rate Limiting:**
1. Navigate to **Manage Jenkins** > **Configure System**.
2. Under **GitHub API usage**, locate **GitHub API usage rate limiting strategy**.
3. Change **Normalize API requests** to **Throttle at/near rate limit**.
4. Click **Save**.

This adjustment ensures Jenkins evenly distributes API requests, reducing the chances of hitting GitHub’s rate limit.

---

## **Conclusion**
Jenkins' **Multibranch Pipeline** provides a seamless way to automate CI/CD for multiple branches, ensuring that:
✅ **Every branch gets tested independently.**
✅ **Pull requests trigger separate builds.**
✅ **Merged branches are automatically cleaned up.**

By integrating GitHub webhooks and configuring API rate limits, we ensure smooth and efficient pipeline execution. 🚀

Are you using **Multibranch Pipelines** in your projects? Let’s discuss your experiences in the comments below! 💬

