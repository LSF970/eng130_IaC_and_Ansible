## Setting up Terraform

Installing terraform
You can download the binary from the following link:

https://www.terraform.io/downloads.html When you have unzipped the binary file, there's no installer. They students should move the file to their /usr/local/bin directory and set the Path if necessary.

For Windows

https://chocolatey.org/install

We can install it using chocolatey package manager using the link below

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Open power shell in Admin mode

Paste the copied text into your shell and press Enter.

Wait a few seconds for the command to complete.

If you don't see any errors, you are ready to use Chocolatey! Type choco or choco -? now, or see Getting Started for usage instructions.

Install Terraform choco install terraform

Check installation terraform --version

# Setting up the file strucutre for Terraform
We need to set up the correct file structure, so Terraform can do it's thing. Create a folder called `terraform` with `mkdir`, go into it and make two files `main.tf` and `variables.tf`
```
mkdir terraform
cd terraform
touch main.tf variables.tf
```

The main.tf file is where we are going to write our actual config, the variables file will contain any arguements we would like to pass to the script or any default values. This makes our script more secure and cleaner.

# Providers
First we need to tell Terraform which cloud service and data-center to use:
```
provider "aws" {
  region = "eu-west-1"
}
```
Terraform is quite a light system, but we still need to pull some dependencies now we have specified our cloud provider. Exit the main.tf file and run:

```
terraform init
```
# Creating resources
Ok, back to main.tf using `nano main.tf`

Lets launch an ec2 instance with Terraform then, find the AMI id of your last successful build and replace it in the code below, add the whole block to you main.tf under the provider block:
```
# launch an instance
resource "aws_instance" "app_instance" {
  ami           = "yourami-id"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name      = "your_key_name" 
  tags = {
      Name = "yourname-app"
  }
  key_name = "enter ssh key name the .pem file"
}
```

#### Use this link to provide the rest of the steps here.
 https://github.com/LSF970/NewDevOpsCurriculum/tree/master/06_IAC_Orchestration_Scaling_Monitoring/01_Terraform_intro




## Cheatsheet

PS C:\Windows\system32> terraform
Usage: terraform [global options] <subcommand> [args]

The available commands for execution are listed below.
The primary workflow commands are given first, followed by
less common or more advanced commands.

Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Experimental support for module integration testing
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the
                given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.