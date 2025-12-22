# 🔥 PART 1 — What `import_role` actually does

`import_role` is to roles what `import_tasks` is to task files.

### In one tight sentence:

> `import_role` is a static role loader. Ansible reads the entire role at parse time, expands it, and injects all its tasks into the play.


It is *not* dynamic.

For dynamic role loading we use `include_role`.



# 🧩 PART 2 — Syntax

### Basic example:

```yaml
- hosts: web
  tasks:
    - name: Import role
      ansible.builtin.import_role:
        name: nginx
```

Equivalent to writing:

```yaml
roles:
  - nginx
```

But with one key difference:

> Using import_role allows us to attach `when`, `tags`, `vars`, and other task-level controls.



# 🎯 PART 3 — Why use `import_role`?

✔️ When we want **static** loading
✔️ When we want to apply `when:` to an entire role
✔️ When we want tags to propagate through the role
✔️ When we want roles to appear in `--list-tasks` in correct order
✔️ When we want predictable idempotence and ordering inside complex playbooks
✔️ When we want variable overrides specific to that invocation

Example:

```yaml
- name: Set up webserver
  ansible.builtin.import_role:
    name: nginx
  vars:
    nginx_listen_port: 8080
  tags: config
```

This is cleaner than stuffing multiple roles at the play level.



# 🧠 PART 4 — How `import_role` finds the role

Identical to normal roles:

Ansible searches:

1. `roles/` next to our playbook
2. `roles_path` in ansible.cfg
3. system dirs (`~/.ansible/roles`, `/etc/ansible/roles`)
4. collections (`my.namespace.myrole`)

All the same behavior as `roles:`.



# 💥 PART 5 — `import_role` vs `include_role` (important difference)


Example of variable-based dynamic role:

```yaml
- include_role:
    name: "{{ selected_role }}"
```

Not possible with `import_role`.



# 🧩 PART 6 — What happens with `when:` on an import_role?

Same rule as import_tasks:

```yaml
- name: Load Debian role
  ansible.builtin.import_role:
    name: nginx
  when: ansible_facts['os_family'] == "Debian"
```

### Parse time:

* The role is loaded (static)
* All tasks are injected into the playbook
* Ordering, tags, handlers = fixed

### Runtime:

* Condition is evaluated
* The entire imported role block is skipped (all tasks inside show as “skipped”)


# 🧪 PART 7 — FAQs


## ❓ Doubt 1 — Can I use variables in the role name?

Examples:

```yaml
- import_role: name={{ myrole }}
```

- ✔️ Allowed only if `myrole` is available at parse time (e.g., vars from inventory, vars defined above)

- ❌ NOT allowed if the variable depends on runtime values (facts, registered vars, loop vars)

- ❌ NOT allowed if the variable resolves differently per host (parse-time cannot handle host-specific behavior)

## ❓ Doubt 2 — Does the following work?

Example:

```yaml
- import_role:
    name: nginx
  when: result.stdout == "ok"
```

Where `result` is registered earlier.

✔️ This works

Because:

* The role is imported statically at parse time
* The `when:` is evaluated at runtime
* If condition fails → whole block gets skipped

No errors.

Same behavior as import_tasks.



## ❓ Doubt 3 — Does the imported role ALWAYS exist in the task list?

✔️ Yes.

An imported role always gets expanded into:

* tasks
* handlers
* meta dependencies

These tasks will exist in `--list-tasks` *even if they will later be skipped*.



## ❓ Doubt 4 — When are tasks removed entirely at parse time?

Only when:

* You use a block
* AND the `when:` uses static inventory data
* AND the condition is false at parse time

Example:

```yaml
- block:
    - import_role: name=nginx
  when: "'web' in group_names"
```

If a host is not in “web”:

* Entire block removed at parse time
* Including the import_role inside
* No tasks from that role are added for that host

This is the ONLY case where tasks truly disappear.



## ❓ Doubt 5 — Is import_role the same as roles: ?

No.

```yaml
roles:
  - nginx
```

is equivalent to:

```yaml
- import_role:
    name: nginx
```

but without the ability to:

* add `when:`
* add `tags:`
* add task-level vars
* order roles relative to tasks


#### 🧠 The problem with `roles:`

The normal syntax:

```yaml
- hosts: localhost
  connection: local
  gather_facts: false

  roles:
    - role_a   # runs before any tasks below
    - role_b   # runs before any tasks below

  tasks:
    - name: This task runs AFTER both roles have finished
      debug:
        msg: "I run after role_a and role_b"

```

is simple and clean, but it has a **major limitation**:

> **Roles always load before tasks, and we cannot interleave roles and tasks.**

Here,
- `role_a` tasks run, then `role_b` tasks run, and only after both roles finish do the tasks in the `tasks:` list run.

- We cannot place a task between role_a and role_b using `roles:`.

#### 💥 `import_role` solves this limitation

Because it behaves like a *task*, we can put it anywhere among other tasks.

Example:

```yaml
tasks:
  - name: Install system libs
    package:
      name: libssl-dev
      state: present

  - name: Configure nginx
    import_role:
      name: nginx

  - name: Verify nginx config
    command: nginx -t

  - name: Deploy nodejs
    import_role:
      name: nodejs
```

Here’s what’s special:

✔️ We can run tasks, then a role

✔️ Then more tasks

✔️ Then another role

✔️ And so on, in any order we want

This is *not* possible with the simple `roles:` syntax.


