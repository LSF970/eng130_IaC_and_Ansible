## Setting up Ansible locally

### Part 1 - Using vagrant to set up required VM's
- Create a new folder for the project
- Open the folder in your IDE (usually VS Code)
- Link it to a new GitHub Repo
- Open a terminal in the IDE
- Enter `vagrant up`, make sure you are in the right folder
- This will make a Vagrantfile

In the Vagrantfile, replace the default code with:

```ruby
# -*- mode: ruby -*-
 # vi: set ft=ruby :
 
 # All Vagrant configuration is done below. The "2" in Vagrant.configure
 # configures the configuration version (we support older styles for
 # backwards compatibility). Please don't change it unless you know what
 
 # MULTI SERVER/VMs environment 
 #
 Vagrant.configure("2") do |config|
  # creating are Ansible controller
    config.vm.define "controller" do |controller|
      
     controller.vm.box = "bento/ubuntu-18.04"
     
     controller.vm.hostname = 'controller'
     
     controller.vm.network :private_network, ip: "192.168.33.12"
     
     # config.hostsupdater.aliases = ["development.controller"] 
     
    end 
  # creating first VM called web  
    config.vm.define "web" do |web|
      
      web.vm.box = "bento/ubuntu-18.04"
     # downloading ubuntu 18.04 image
  
      web.vm.hostname = 'web'
      # assigning host name to the VM
      
      web.vm.network :private_network, ip: "192.168.33.10"
      #   assigning private IP
      
      #config.hostsupdater.aliases = ["development.web"]
      # creating a link called development.web so we can access web page with this link instread of an IP   
          
    end
    
  # creating second VM called db
    config.vm.define "db" do |db|
      
      db.vm.box = "bento/ubuntu-18.04"
      
      db.vm.hostname = 'db'
      
      db.vm.network :private_network, ip: "192.168.33.11"
      
      #config.hostsupdater.aliases = ["development.db"]     
    end
  
  
  end
```
- This will result in you having three VM's: controller, web and db
- We will use the controller VM to configure the other two (using Ansible)
- Check all the VM's are up and running with `vagrant status`. You should get an output of:

![Alt text](/images/vagrant_status.jpg "All VM's up and running")

### Part 2 - Configuring the controller to use Ansible
- SSH into the controller VM, we are using vagrant so we can simply enter `vagrant ssh controller`
- Run `sudo apt update -y` and then `sudo pt upgrade -y`
- This may take a while
- Run `sudo apt-get install software-properties-common`
- Run `sudo apt-add-repository ppa:ansible/ansible`
- Run `sudo apt update -y` again
- Run `sudo apt-get install ansible -y` this installs Ansible on the controller machine
- Note this does not need to be installed on the other machines
- Run `sudo apt-get install tree`, this lets us visualise our directories better
- Enter `cd /etc`
- Enter `cd ansible`
- Enter `ls`
- The output should show:

![Alt text](/images/ls_of_ansible_folder.jpg "ansible.cfg, hosts, roles(directory)")

### Part 3 - Conneccting to the other VM's using the controller
- Enter `sudo ssh vagrant@192.168.33.10`
- If it is the first time entering the VM it will ask you to type `yes`
- You will then need to enter a password. This is the default password vagrant sets up and is simply `vagrant`
- You should now be inside the web VM, using the cntroller VM
- To leave and go back to the controller, enter `exit`
- Enter the same command but for the db VM `sudo ssh vagrant@192.168.33.11`
- You should now be inside the db VM
- Again, you can enter `exit` to go back to the controller
- Note, neither of these machines have Ansible

### Part 4 - Using ping adhoc command to check connection to agent VM's
- In controller try to use the adhoc command `ping` this asks the target machine to send back 'pong'
- The below is the result:

![Alt text](/images/no_ansible_hosts.jpg "No hosts found")

- This is because Ansible does not know the target we are specifying
- To tell it about the web VM, we need to add it to the hosts file
- cd into etc `cd /etc` -> cd into the ansible directory `cd ansible`
- Enter `sudo nano hosts` to open the file
- Add the name of the machine `[web]`
- Under this add the i.p:

![Alt text](/images/ansible_hosts_1.jpg "Added the name and i.p of host")

This does not however facilitate communication:

![Alt text](/images/ansible_hosts_fail.jpg "Fail message")

This is beacuse Ansible does not have the password that the VM asks for when it tries to SSH in. We need to specify this in the hosts file:

![Alt text](/images/ansible_hosts_password.jpg "SSH password added")

This now lets us connecct, and the ping adhoc command is successful:

![Alt text](/images/ansible_hosts_pong.jpg "Successful pong to web VM")

We can do this for the db machine too:

![Alt text](/images/ansible_hosts_db_added.jpg "Adding the db machine to hosts file")

The ping to db VM now also works:

![Alt text](/images/ansible_hosts_pong_db.jpg "Successful pong to db VM")

## Now we can start using Adhoc commands to do some powerful stuff from the controller!

### Part 4 - Using adhoc commands on the contoller to do things on the agents
- We use -a to give and arguement to an Adhoc command in Ansible
- A good, basic example is `sudo ansible web -a "date"`
- This gives us the following output IN THE CONTROLLER from the web VM:

![Alt text](/images/ansible_date_adhoc.jpg "Date is retrieved from the web VM by contoller")

- So we can now do things like, run `sudo apt update` on both our VM's at the same time using `sudo ansible all -a "sudo apt update -y"`:

![Alt text](/images/ansible_update_adhoc.jpg "Updating web and db at the same time via controller")

- Note, we do this by specifiying `all` in out Adhoc command

### Other examples of simple adhoc commands are:
- sudo ansible all -a "uname -a"
- sudo ansible all -a "whoami"
- More to be added

### Copying a file or folder using adhoc command (from controller to agent)
- To send a file to an agent, use the following command:

```
sudo ansible web -b -m copy -a 'src=/etc/ansible/testfile.txt dest=/home/vagrant'
```

- The file/folder will now appear in the home directory whe  you login with ssh and enter `ls`:

![Alt text](/images/copyfile_adhoc.jpg "Adhoc command to copy a file folder")

## Provision for controller VM to have Ansible after vagrant up

```
#!/bin/bash/

# Update controller
sudo apt update -y

# Upgrade controller - may take a while
sudo apt upgrade -y

# Install first dependancy
sudo apt-get install software-properties-common

# Add ansible repo so VM knows where to get Ansible from
sudo apt-add-repository ppa:ansible/ansible

# Update again to be safe
sudo apt update -y

# Installs Ansible on the contoller VM
sudo apt-get install ansible -y
# Note this does not need to be installed on the other machines

# This lets us visualise our directories better
sudo apt-get install tree

# Into /etc
cd /etc

# Into ansible
cd ansible

# Check if install worked and files/folder is there
ls

# Check version
sudo ansible --version
```

#### Remember to add the line to actually use the provision file to the controller section of your Vagrantfile:

![Alt text](/images/controller_provision.jpg "Adding provision to controller VM")


