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

### Part 4 - 
