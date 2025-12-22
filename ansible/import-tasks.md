## import_tasks
`import_tasks` performs a static import. Ansible loads the tasks at playbook parse time, not at runtime. The imported tasks are treated as if they were written directly in the playbook or in the role’s `tasks/main.yml`(when inside a role).

### Example inside a playbook (not a role)

Suppose, the following is the directory structure:

```
myproject/
├── playbook.yml
├── first.yml
└── second.yml
```


Our `playbook.yml` looks like:
```yaml
- name: Importing tasks Demo
  hosts: all
  tasks:
    - name: First import
      ansible.builtin.import_tasks: first.yaml
    - name: Second import
      ansible.builtin.import_tasks: second.yaml
```

In `first.yml` we've got:

```yaml
- name: Print Hello World
  ansible.builtin.debug:
    msg: "Hello World"
```
In `second.yml` we've got:

```yaml
- name: Print hostname
  ansible.builtin.debug:
    msg: "Greetings from {{ ansible_host }}"
```

To we execute this playbook, use
```bash
ansible-playbook playbook.yaml
```
Append the `--list-tasks` flag to the above command to list the tasks without executing them.

### 🛑 When *not* to use import_tasks

We don’t use `import_tasks` when:

* The filename depends on variables
* We must choose tasks at runtime
* Conditions depend on facts collected later

### 📌 How does Ansible know where to find the imported files?

Ansible resolves the path in this order:

### Relative to the current playbook file

If `playbook.yml` calls:

```yaml
import_tasks: init.yml
```

Ansible looks inside:

```
<directory containing playbook>/init.yml
```

### Relative paths allowed

We can do:

```yaml
import_tasks: tasks/init.yml
```

Then directory becomes:

```
myproject/
  playbook.yml
  tasks/
    init.yml
    backup.yml
```

### Absolute paths work too

```yaml
import_tasks: /opt/ansible/custom/init.yml
```
### Example inside a role (different rules!)

Inside a role:

```
roles/myrole/tasks/main.yml
roles/myrole/tasks/init.yml
roles/myrole/tasks/backup.yml
```

Then:

```yaml
# roles/myrole/tasks/main.yml
- import_tasks: init.yml
- import_tasks: backup.yml
```

Ansible automatically looks inside:

```
roles/myrole/tasks/
```

So no full path needed.

> Remember: Paths are *not* searched in the roles directory (e.g. `roles/.../tasks/*.yml`) unless we’re inside a role

For regular playbook-level imports, **Ansible never automatically looks inside `roles/`** unless we explicitly give the full path

So this will *not* work:

```
roles/
  myrole/
    tasks/
      init.yml
```

And then in `playbook.yaml`:

```yaml
import_tasks: init.yml   # ❌ NOT FOUND
```

Unless we specify:

```yaml
import_tasks: roles/myrole/tasks/init.yml   # ✔️ Works
```

> Ansible always resolves `import_tasks` paths relative to the playbook containing the import statement, unless it's inside a role.

If inside a role, it resolves relative to the role’s `tasks/` directory automatically.

---

## 🧠 What is **parse time** in Ansible?

**Parse time** = the moment Ansible **reads and loads our playbook**, *before* executing any tasks.

This is the phase where Ansible:

* Reads the YAML
* Expands static statements (`import_tasks`, `import_role`, etc.)
* Builds the full “task graph”
* Applies tags
* Applies conditions that determine whether blocks even exist
* Resolves variables that can be resolved early
* Prepares handlers
* Builds the execution plan

In simple terms:

Parse time = “Ansible planning the play before running it.”

Nothing on remote hosts has happened yet.

No tasks have executed.

No facts have been collected (default behavior).

## 🔥 What is **runtime**?

**Runtime** = the moment Ansible starts actually *executing* the tasks — talking to hosts, running modules, gathering facts, changing files, restarting services, etc.

During runtime:

* Variables get evaluated dynamically
* Facts are available
* Notifications to handlers occur
* Conditions (`when:`) are evaluated per host
* Results of previous tasks affect later tasks

Runtime = “performing” the play.

## 🧩 How parse time affects `import_tasks`

`import_tasks` is a **static import**, so it happens at parse time.

Meaning:

```yaml
- import_tasks: "{{ my_file }}"
```

❌ Invalid, because variables aren't processed at parse time.


**Example — parse-time condition** 

```yaml
- import_tasks: ubuntu.yml
  when: ansible_facts['os_family'] == 'Debian'
```
✅ Works.

### Explanation 

**1. Parse time**

* Ansible sees our `import_tasks: ubuntu.yml`
* It immediately loads all tasks from `ubuntu.yml` into the playbook
* They are part of the final task graph from the beginning
* Tags propagate
* Ordering is established
* Imports cannot depend on runtime variables
* But the `when:` is *not* evaluated yet

This is why it's called **static**.


**2. Runtime**

* Ansible now executes tasks
* Facts are collected (unless disabled)
* Now the `when:` is evaluated
* If `os_family != Debian`, every task inside the imported file is marked **SKIPPED**

The imported tasks exist in the task list, but all will be skipped.

In other words,

- The import always happens.

- The condition is evaluated at runtime.

- The entire imported block is skipped if the condition is false.

## Important
Learn about [loops](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_vars_facts.html#ansible-facts)
