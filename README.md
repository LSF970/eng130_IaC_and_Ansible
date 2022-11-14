# Infastructure as Code (IaC)

## What is IaC?
Infrastructure as Code (IaC) is the managing and provisioning of infrastructure through code instead of through manual processes.

Without IaC, teams are responsible for keeping up the settings of separate deployment environments. Eventually, each of these environments becomes a unique configuration that cannot be automatically replicated, which can lead to problems during deployment. With IaC, teams can command an environment to replicate the same configuration, streamlining the deployment phase.

## IaC config management
![Alt text](/images/Ansible_config_mangement_diagram.jpg "Config management via Ansible")

## IaC Orchestration

## Ansible
- Ansible is an open-source tool that allows provisioning, config management, app deployment, orchestration and many other IT proccess. 
- Ansible allows sys-admins to extend automation across the business, improve security and much more.
- Ansible is agentless. This measnt eh sys-admin can do all of the work they want to do from a designated master node, rather than logging into and running commands


Extra Notes:
- Ansible is written in Python
- Ansible uses OpenSSH for transport
- Ansible uses YAML to allow for ease of use

## Config management with Ansible
- Ansible is the simplest solution for automating routine IT tasks. It's designed to be minimal in nature, consistent, secure and highly reliable, with an extremely low learning curve for administrators, developers and IT managers.

- Ansible uses simple data descriptions of your infrastructure (both human-readable and machine-parsable)—ensuring everyone on your team will be able to understand the meaning of each configuration task.

## Ansible Architecture
Ansible is a radically simple automation engine.The big thing to remember about Ansible's architecture is:

### IT HAS NO AGENT DEPENDANCIES
Here is the architecture broken down:
Modules 
- These are scripts that describe the desired state of a system. Ansible executes these first via SSH

Module Utilities
- When multiple modules use the same code, we instead create utilities. These allow us to store functions so we don't have repeat ourselves over and over. This have to be written in Python.

Plugins
- Improve the functionality of Ansible core dependant on your needs. Run on the master node to achieve things you cannot do with Ansible core.

Inverntory
- This is a file that tells Ansible what machines it is controlling and how to control them. This way all of the machines can be put into a particualr group. The usual requirement is the name of the machine and the i.p.

Playbooks 
- Written YAML. These files allow you to finely orchestrate multiple slices of infastructre. In particualr they allow you to detail how many machines to tackle at a time.

![Alt text](/images/ansible-architecture.jpg "Ansible Architecture")

## Ansible controller
Here is a diagram of the Ansible controller:

![Alt text](/images/Ansible_controler_Diagram.png "Ansible controller explained visually")

Also, here is a link to get started ith Ansible:
https://docs.ansible.com/ansible/latest/network/getting_started/basic_concepts.html

## Ansible agent node(s)

## Adhoc commands

## Inventory
The 'inverntory' refers to where we can define the hosts and groups of hosts upon which commands, modules and tasks in a playbook can operate. Most of the time this file is written in YAML. By deafult it goes into the hosts directory:
/etc/ansible/hosts
However, you can create project specific inverntory files in other locations.

The inventory itself is just a list of host machines. we tend to group them because they have something in common. In practiccce the groups are often running the exact same environment and are in the same place (for example one of our groups may be 'EU-DBs').

![Alt text](/images/example_inventory.png "A sample inventory")

More detial can be found in the official documentation:
https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html 

## Ansible roles
Roles enable us to reuse and share our Ansible code efficiently. They provide a well-defined framework and structure for setting your tasks, variables, handlers, metadata, templates, and other files. This way, we can reference and call them in our playbooks with just a few lines of code while we can reuse the same roles over many projects without the need to duplicate our code.#

Via: https://spacelift.io/blog/ansible-roles

Diagram to visualise roles:
![Alt text](/images/ansible_roles.jpg "How roles work")


Refer to:
https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html
For more information on Ansible roles

## Modules
Modules (also referred to as “task plugins” or “library plugins”) are discrete units of code that can be used from the command line or in a playbook task. Ansible executes each module, usually on the remote managed node, and collects return values. In Ansible 2.10 and later, most modules are hosted in collections.

Via: https://docs.ansible.com/ansible/latest/user_guide/modules_intro.html
Use this link for further detail.

Every single current Ansible module:
https://docs.ansible.com/ansible/2.9/modules/list_of_all_modules.html 
