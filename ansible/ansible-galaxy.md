## Ansible Galaxy
Ansible Galaxy can be primarily understood as a Marketplace for Ansible roles. Ansible Galaxy hosts thousands of pre-built Ansible roles that are written and published by different DevOps engineers and system administrators. It is analogous to Docker Hub, which serves as a marketplace for Docker images.

## Publishing a Role to Ansible Galaxy
First, we need to log in to the Ansible Galaxy. Once we log-in, we get a namespace of our own. Our published roles will appear under our namespace.

### Steps

1. Make sure our role is structured correctly. The basic structure should look like this:

   ```
   my_role/
    ├── defaults/
    │   └── main.yml
    ├── files/
    ├── handlers/
    │   └── main.yml
    ├── meta/
    │   └── main.yml
    ├── tasks/
    │   └── main.yml
    ├── templates/
    ├── tests/
    │   ├── inventory
    │   └── test.yml
    └── vars/
        └── main.yml
   ```

1. Make sure ansible-galaxy CLI exists

   ```bash
   ansible-galaxy --version
   ```

1. Push our Role to GitHub

   ```bash
   cd my_role
   git init
   git remote add origin <https://github.com/github_username/my_role.git>
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

1. To upload roles, we need an API token. Follow these steps to generate one:

   - Go to Ansible Galaxy

   - Log in using the GitHub account

   - Click on the profile icon → Select API Tokens

   - Click Create Token

1. Import the Role to Ansible Galaxy

   ```bash
   ansible-galaxy role import <your_github_username> <role-name> --token <generated-api-token>
   ```

Check out [Ansible Galaxy User Guide](https://docs.ansible.com/projects/ansible/latest/galaxy/user_guide.html#galaxy-user-guide)