# Role
1. An Ansible role takes a complex Ansible Playbook and splits its different logical sections into separate, predefined folders under a central folder. Basically, it helps to encapsulate and modularize the logic and configuration needed to manage a particular system or application component.

1. Create a role.
   ```
   ansible-galaxy role init test-role
   ```

Roles were introduced primarily to solve issues related to managing large or complicated Ansible projects by focusing on three main advantages: readability, modularity, and sharing.

1. **Readability and Modularity**: When writing complicated automation, a single Playbook file might grow to contain 50 to 60 tasks, multiple variables, handlers, and metadata, potentially resulting in thousands of lines of code. Such large files are difficult to understand and maintain. Roles solve this by enforcing a standard structure, putting variables, tasks, and handlers into dedicated folders, thus making the Playbook more organised and modular.

2. **Sharing and Reuse**: Roles facilitate sharing code across teams, within an organisation, or even publicly. They can be uploaded to a centralised repository, such as Ansible Galaxy, which serves as a marketplace or registry (similar to Docker Hub). This allows others to reuse the automation without having to write the code again and again. We can also use pre-built Ansible roles found in Ansible Galaxy.

## Role Structure

```
role_name/
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
  ├── vars/
      └── main.yml
```
**Key Components of an Ansible Role**

- **tasks**  
  List of tasks that should be executed on the managed nodes.

- **files**  
  Static files that need to be transferred to managed hosts.

- **handlers**  
  Contains tasks that are only executed when they are explicitly notified by a task in the role. Handlers are useful for actions that should only run occasionally or upon a particular change, such as restarting a web server. For details, check out the [docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html#)


- **templates**  
  These files use Jinja2 templating language to enable dynamic content generation. We can use templating with the built-in **template** module. It is particularly useful when we need to customize the content of the file based on variables or other conditions at runtime. For details, check out the [docs](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_templating.html)

- **vars**  
  Variables that are used within the role.

- **Defaults**  
  Default variables for the role, which can be overridden. If a variable is not explicitly provided elsewhere, the value in `defaults/main.yaml` will be used.

- **meta**  
  Metadata about the role, including dependencies on other roles.

- **Library**  
  Custom modules or plugins used within the role.

- **Module_defaults**  
  Default module parameters for the role.

- **Lookup_plugins**  
  Custom lookup plugins for the role.

## Creating a Role

To create a role for Kubernetes (say):
```bash
ansible-galaxy role init demo-kubernetes
```

The above command will create a directory in cwd named **demo-kubernetes** . Following are the contents of that dir:

```bash
ubuntu@ip-172-31-91-41:~/ansible$ ls -l demo-kubernetes/
total 36
-rw-rw-r-- 1 ubuntu ubuntu 1328 Aug  2 12:13 README.md
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 defaults
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 files
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 handlers
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 meta
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 tasks
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 templates
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 tests
drwxrwxr-x 2 ubuntu ubuntu 4096 Aug  2 12:13 vars
```

## Converting a Playbook into Role

Here's the sample playbook to be converted:
```yaml
# playbook.yaml
---
- hosts: all
  become: true
  tasks:
    - name: Install nginx
      ansible.builtin.apt:
        name: nginx
        state: present
        update_cache: yes
    - name: Copy file with owner and permissions
      ansible.builtin.copy:
        src: index.html          # Initially, index.html is located at the same level as the playbook
        dest: /var/www/html
        owner: root
        group: root
        mode: '0644'
```

### Steps
1. First, we create a role.
   ```bash
   ansible-galaxy role init demo-nginx
   ```

1. Place the **index.html** inside `demo-nginx/files/`

1. Move the items of the **tasks** list to `demo-nginx/tasks/main.yaml`.
   ```yaml
   ---
   - name: Install nginx
     ansible.builtin.apt:
      name: nginx
      state: present
      update_cache: yes
   - name: Copy file with owner and permissions
     ansible.builtin.copy:
      src: files/index.html    # as, the index.html is located inside demo-nginx/files.     
      dest: /var/www/html
      owner: root
      group: root
      mode: '0644'
   ```
1. In the playbook, make it refer to our newly created **demo-nginx** role.
   ```yaml
   # playbook.yaml
   ---
   - hosts: all
     become: true
     roles:
     - demo-nginx
   ```
1. Now, we can execute the playbook,
   ```bash
   ansible-playbook -i path_to_inventory playbook.yaml
   ```