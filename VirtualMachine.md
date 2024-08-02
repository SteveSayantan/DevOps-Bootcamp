## Understanding the Requirement of Virtual Machines

### Problem Statement
Suppose ABC organization has bought two servers. But, practically they use only 10% and 20% of the resources provided by those. Besides, only two teams can use these two servers. If for any reason, ABC organization decides to have three teams, they need to buy another server for that team though the previous ones were not fully utilized. Hence, there is inefficiency in resource management.

### Solution
Instead of buying two servers, ABC organization can buy only one and install a hypervisor in it. **A hypervisor is a software that can install Virtual Machines on our physical server**. Using Hypervisor, ABC organization can create multiple VMs on a server for different teams and fulfill their requirements efficiently.

Actually, we are doing a logical (rather than a physical) separation to create VMs. So, we added efficiency using hypervisor. Popular hypervisors are VMWare, Xen etc.

**VMs are virtual environment made by hypervisor, which functions as virtual computer system having their own memory, CPU, hardware.**

When we request for a VM having certain configuration, AWS will find a physical server apt to fulfill the request and ask the corresponding hypervisor to create a VM. Now the IP Address of the VM will be sent to us. This same principal is followed by all leading cloud/VM providers. As a result, a physical server can be used by many users simultaneously.