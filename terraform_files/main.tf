# Write a script to launch resources on the cloud


# Create EC2 instance on AWS

# Syntax {
#         key= value
#         ami= asasfasfafasf  }

# Download dependencies from AWS
provider "aws" {

# Which part of AWS we would like to launch resources in
  region = "eu-west-1"
}

# What type of server with what sort of functionality
resource "aws_instance" "app_instance" {
  ami           = "ami-0b47105e3d7fc023e"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
      Name = "eng130-luke-tf-app"
  }
  # key_name = "eng130.pem"
}
# Add resource

# Add Ami

# Add instance type

# Public IP or not?

# Name the server
