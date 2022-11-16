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


## Moving from on-prem ansible to hybrid ansible

- Install Python 3 - `sudo apt install python3`
- Install pip - `sudo apt install python3-pip`
- Install awscli - `pip3 install awscli` 
- Install boto3 - `pip3 install boto boto3` (importing boto3 from boto)
- `sudo apt-get upgrade -y`
- Add specific line to point to correct directory for Python3 in /etc/ansible/hosts
```
[local]
localhost ansible_python_interpreter=/usr/bin/python3
```
- Make ansible vault default folder structure `/etc/ansible/group_vars/all`
- Make ansible vault file `sudo ansible-vault create pass.yml` (this will be vim)
- Add line `aws_access_key: key_goes_here`
- Add second line `aws_secret_key: key_goes_here`
- Hit `Esc` to get out of input mode, then `:` then write `wq!` and hit enter. This saves the changes. 
- Check to see if saved `sudo cat pass.yml` contents will be hashed
- Change permissions on key `sudo chmod 666 pass.yml`
- Now navigate to .ssh directory
- Generate new key pair: `ssh-keygen -t rsa -b 4096"`
- Call this pair something sensible, ansible_aws_key for example
- Then go to your localhost and copy the .pem file for aws to controller
- `scp eng130.pem vagrant@192.168.33.12:.ssh`
- add aws to hosts file (comment as not created yet)
```
# [aws]
# ec2-instance ansible_host=ec2-ip ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/eng130.pem
```
- Make create_ec2.yml file in /etc/ansible
- Add inital code:
```
---
- hosts: localhost
  connection: local
  gather_facts: True
  become: True
```
- Save and run `sudo ansible-playbook create_ec2.yml --ask-vault-pass --tags create_ec2`
- Connection to localhost should be successful
-  Now add the rest of the yaml script:

```
# AWS playbook
---

- hosts: localhost
  connection: local
  gather_facts: False

  vars:
    key_name: eng130_aws #(The key you made earlier)
    region: eu-west-1
    image: ami-00f499a80f4608e1b
    id: "web-app-luke-test"
    sec_group: "sg-071aeef24c2dcae1b"
    subnet_id: "subnet-0429d69d55dfad9d2"
   #  ansible_python_interpreter: .local/lib/python3

  tasks:

    - name: Facts
      block:

      - name: Get instances facts
        ec2_instance_facts:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{secret_key}}"
          region: "{{ region }}"
        register: result

      - name: Instances ID
        debug:
          msg: "ID: {{ item.instance_id }} - State: {{ item.state.name }} - Public DNS: {{ item.public_dns_name }}"
        loop: "{{ result.instances }}"

      tags: always


    - name: Provisioning EC2 instances
      block:

      - name: Upload public key to AWS
        ec2_key:
          name: "{{ key_name }}"
          key_material: "{{ lookup('file', '~/.ssh/{{ key_name }}.pub') }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{secret_key}}"

          
      - name: Provision instance(s)
        ec2:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{secret_key}}"
          assign_public_ip: true
          key_name: "{{ key_name }}"
          id: "{{ id }}"
          vpc_subnet_id: "{{ subnet_id }}"
          group_id: "{{ sec_group }}"
          image: "{{ image }}"
          instance_type: t2.micro
          region: "{{ region }}"
          wait: true
          count: 1
          instance_tags:
            Name: eng130_luke_ansible

      tags: ['never', 'create_ec2']
```

The most important part of this script is where we set up our vars. Check these over and edit the values according to your setup and aws. After this nothin needs to be changed other than the instance tag: Name. This will be your EC2 name in aws so make it unique and follow naming conventions.

## Adding localhost to hosts file
- In order to run this playbook, we need to ad our localhost into the hosts file. For our first run of create_ec2.yml we will use the passord, aftr that we will need the public key (eng_aws)
```
[aws]
192.168.33.12 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant
```

## Run the playbook.
- Run `sudo ansible-playbook create_ec2.yml --ask-vault-pass --tags create_ec2`
- Note, we have to add `--ask-vault-pass` now Ansible Vault is set up
- We also need `--tags create_ec2` otherwise the task will not run, it will just check the connection to AWS
- All being well, the playbook should run and create an EC2 instance for you
- Go to AWS and check this is the case. Also, add the controller's i.p to the SG being used, so it can SSH in. For testing you can use 0.0.0.0 to make sure all is well, but do not do this in production.

## Change our hosts file again
- Now we have an instance, we need to comment out our localhost line and add a line so Ansible can SSH with the new EC2 instance (using the public key specified in the create_ec2.yml playbook):
```
[aws]
# 192.168.33.12 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant

ec2-instance ansible_host=54.171.133.250 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/eng130_aws
```

# Run update and upgrade before we do anything
- Run adhoc command `sudo ansible aws -a "sudo apt update -y" --ask-vault-pass`
- Run adhoc command `sudo ansible aws -a "sudo apt upgrade -y" --ask-vault-pass`
- Note, we need the ``--ask-vault-pass` now aas we set up the Ansible Vault for all our work with Ansible.

## Change the configure_nginx.yml to work for aws
- All we need to do here is change the hosts this palybook tells ansible to use:
```
# Yaml files start with ---

---
# Create a script to configure nginx in the web server

# Who is the host - means name of the server
- hosts: aws

# Gather data
  gather_facts: yes

# We need admin access - sudo
  become: true

# Add the actual instructions
  tasks:
  - name: Install/configure Nginx Web Server in web-VM
    apt: pkg=nginx state=present

# Ensure at the end of the script the status of nginx is active(running)
```