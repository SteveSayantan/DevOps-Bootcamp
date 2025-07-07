# 🔐 How to Reset a Forgotten Jenkins Admin Password (Step-by-Step Guide)

Forgetting your Jenkins admin password can be frustrating—especially if you're locked out of the dashboard. But don’t worry! Jenkins provides a way to regain access by **temporarily disabling security** and updating user credentials.

This guide walks you through the process of **resetting a forgotten Jenkins password** on a Windows system.

----------

## 🏠 Step 1: Locate Jenkins Home Directory

Jenkins stores its configuration and user data inside a folder known as the **Home Directory**. On Windows, it's usually located at:

```
C:\ProgramData\Jenkins\.jenkins

```

----------

## 🛠️ Step 2: Disable Security Temporarily

1.  Navigate to the Jenkins home directory.
    
2.  Open the `config.xml` file in a **text editor with Administrator privileges**.
    
3.  Locate the following tag:
    

```xml
<useSecurity>true</useSecurity>

```

4.  Change the value to:
    

```xml
<useSecurity>false</useSecurity>

```

5.  Save the file and close the editor.
    

> This disables the login requirement temporarily so you can access Jenkins without authentication.

----------

## 🔄 Step 3: Restart the Jenkins Service

To apply the changes, restart the Jenkins service.

1.  Open **Command Prompt** as Administrator.
    
2.  Navigate to the Jenkins installation directory:
    
    ```
    cd "C:\Program Files\Jenkins\"
    
    ```
    
3.  Restart the service:
    
    ```
    .\Jenkins.exe restart
    
    ```
    

----------

## 🌐 Step 4: Access Jenkins Without Login

Once restarted, Jenkins will start **without requiring authentication**.  

You should now be able to access the Jenkins dashboard directly through your browser.

----------

## 🔒 Step 5: Re-enable Jenkins Security

Now we need to **restore the original security settings**:

1.  Go to:  
    **Manage Jenkins** → **Configure Global Security**
    
2.  Under **Authentication**, set:
    
    -   **Security Realm**: Jenkins’ own user database
        
    -   **Authorization**: Logged-in users can do anything
        
3.  **Important:**  
    Check the box labeled:  
    ✅ _Allow anonymous read access_
    
4.  Click **Save**.

----------

## 👤 Step 6: Reset the User Password

1.  Navigate to:  
    **Manage Jenkins** → **Manage Users**
    
2.  Click on the **user** whose password you want to reset.
    
3.  On the user’s profile page, click **Security** 

4.  Enter the **new password** and click **Save**.

Once you've updated the password, don’t forget to **uncheck the “Allow anonymous read access”** option under **Authentication** by navigating to `Manage Jenkins` → `Security`. 
This will cause force logout as we are not logged in as any user.


## ✅ You're Back In!

Log in with the new password. Yaaaayy!! You’ve successfully reset your Jenkins admin password and restored the security settings. 🎉  

----------