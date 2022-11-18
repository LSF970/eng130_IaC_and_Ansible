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
    Name = "eng130-luke-terraform-1a"
  }
}

# add second subnet to vpc
resource "aws_subnet" "app_subnet2" {
  vpc_id = aws_vpc.terraform_vpc_code_test.id
  cidr_block = "10.0.13.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "eng130-luke-terraform-1b"
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

# Create new SG for LB
resource "aws_security_group" "alb" {
  name        = "eng130_luke_tf_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.terraform_vpc_code_test.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eng130_luke_tf_alb_security_group"
  }
}

# Create new LB
resource "aws_alb" "alb" {
  name            = "eng130-luke-tf-lb"
  security_groups = [aws_security_group.alb.id]
  subnets         = [aws_subnet.app_subnet.id, aws_subnet.app_subnet2.id]
  tags = {
    Name = "eng130_luke_tf_lb"
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

# Creating the autoscaling launch configuration that contains AWS EC2 instance details
resource "aws_launch_configuration" "aws_autoscale_conf" {
# Defining the name of the Autoscaling launch configuration
  name_prefix   = "luke-asg-launch-conf"
# Defining the image ID of AWS EC2 instance
  image_id      = "ami-0e443a3b85c8a6eac"
# Defining the instance type of the AWS EC2 instance
  instance_type = "t2.micro"
# Defining the Key that will be used to access the AWS EC2 instance
  key_name = "eng130-new"
}

 

# Creating the autoscaling group within eu-west availability zones
resource "aws_autoscaling_group" "mygroup" {
# Defining the availability Zone in which AWS EC2 instance will be launched
  # availability_zones        = ["eu-west-1a", "eu-west-1b"]
# Specifying the name of the autoscaling group
  name                      = "eng130-luke-tf-asg"
# Defining the maximum number of AWS EC2 instances while scaling
  max_size                  = 4
# Defining the minimum number of AWS EC2 instances while scaling
  min_size                  = 3
# Grace period is the time after which AWS EC2 instance comes into service before checking health.
  health_check_grace_period = 30
# The Autoscaling will happen based on health of AWS EC2 instance defined in AWS CLoudwatch Alarm 
  health_check_type         = "EC2"
# force_delete deletes the Auto Scaling Group without waiting for all instances in the pool to terminate
  force_delete              = true
# Defining the termination policy where the oldest instance will be replaced first 
  termination_policies      = ["OldestInstance"]
# Scaling group is dependent on autoscaling launch configuration because of AWS EC2 instance configurations
  launch_configuration      = aws_launch_configuration.aws_autoscale_conf.name
# Specify Subnet
  vpc_zone_identifier = [aws_subnet.app_subnet.id, aws_subnet.app_subnet2.id]
}

# Creating the autoscaling schedule of the autoscaling group
resource "aws_autoscaling_schedule" "mygroup_schedule" {
  scheduled_action_name  = "eng130-luke-asg_action"
# The minimum size for the Auto Scaling group
  min_size               = 2
# The maxmimum size for the Auto Scaling group
  max_size               = 3
# Desired_capacity is the number of running EC2 instances in the Autoscaling group
  desired_capacity       = 2
# defining the start_time of autoscaling if you think traffic can peak at this time.
  start_time             = "2022-11-18T18:00:00Z"
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}

# Creating the autoscaling policy of the autoscaling group
resource "aws_autoscaling_policy" "mygroup_policy" {
  name                   = "eng130-luke-asg-policy"
# The number of instances by which to scale.
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
# The amount of time (seconds) after a scaling completes and the next scaling starts.
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.mygroup.name
}


# Creating the AWS Cloudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "app_cpu_alarm_up" {
# defining the name of AWS cloudwatch alarm
  alarm_name = "eng130-luke-app-cpu-alarm-up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
# Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
# The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
# After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period = "60"
  statistic = "Average"
# CPU Utilization threshold is set to 10 percent
  threshold = "10"
  alarm_actions = [
        aws_autoscaling_policy.mygroup_policy.arn
    ]
dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.mygroup.name
  }
}