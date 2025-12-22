## Default Error Behavior 

When Ansible runs a task and it returns a non-zero exit code or a module-level failure, Ansible:

1. Marks the task as **FAILED**
2. Stops running the play **for that host only**
3. Continues running the play on other hosts (unless we told it not to)

Example:

```yaml
- name: Bad task
  command: /bin/false
```

Output will be:

```
FAILED! => {"changed": false, "msg": "non-zero return code", ...}
```

After that:

* No more tasks run for this host
* No handlers are triggered for this host
* Other hosts keep going as if nothing happened

This exists because Ansible assumes:

* A failed task means the system is now in an unknown/broken state
* Continuing further tasks would only make things worse
* Stopping prevents us from accidentally wrecking production machines

### ✔️ What happens to handlers?

Handlers run **only if**:

* A notifying task changed
* AND the play reaches the handler stage
* AND the host isn't dropped due to errors

If a failure stops the play early:

> **Handlers for that host will NOT run.**

This is intentional — we don’t want service reloads happening after a broken config update.

## References

- [Error handling in Playbooks](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_error_handling.html#error-handling-in-playbooks)
- [Registering Variables](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_variables.html#registering-variables)