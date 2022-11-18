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

# Add vpc
resource "aws_vpc" "terraform_vpc_code_test" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "eng130-luke-terraform-vpc-test"
  }
}

# Add internet-gateway (IG) to VPC
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id

  tags = {
    Name = "eng130-luke-terraform-ig"
  }
}

# add subnet to vpc
resource "aws_subnet" "app_subnet" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  cidr_block = "10.0.10.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "eng130-luke-terraform"
  }
}

resource "aws_security_group" "app"  {
  name = "eng130-luke-terraform-sg"
  description = "Testing Terraform"
  vpc_id = aws_vpc.terraform_vpc_code_test.id
# Inbound rules
 # SSH from anywhere
  ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]   
  }

# Outbound rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng130-luke-terraform-sg"
  }
}

# Create a public route table
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "eng130-luke-terraform-rt-public"
  }
}

resource "aws_route_table_association" "eng130-luke_terraform_rt_association"{
  subnet_id = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app.id
}


# EC2 creation
resource "aws_instance" "app_instance" {
  ami           = var.web_app_ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.app_subnet.id
  vpc_security_group_ids = [aws_security_group.app.id] 
  associate_public_ip_address = true
  key_name      = var.aws_key_name
  tags = {
      Name = var.name  
  }
  
}
