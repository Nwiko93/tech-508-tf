# create an ec2 instance
# where to create - provide cloud service provider
# create an ec2 instance 
# which region to use 
# which AMI to use AMI ID ami-0c1c30571d2dae5c9 (for ubuntu 22.04 lts)
# which instance to launch - t3 micro
# want to add public IP to instance 
# aws_access_key - NEVER EVER PUT IN/CODIFY YOUR CREDENTIALS!!!
# aws_secret_key - NEVER EVER PUT IN/CODIFY YOUR CREDENTIALS!!!
# name the instance 


provider "aws" {
    region = "eu-west-1"
}



resource "aws_instance" "web" {
  ami                         = var.app_ami_id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tech508-nigel-tf-allow-port-22-3000-80.id]
 
  tags = {
    Name = "tech_508-nigel_first_tf_vm"
  }
}

# Reference default VPC
data "aws_vpc" "default" {
  default = true
}


# Security Group in default VPC
resource "aws_security_group" "tech508-nigel-tf-allow-port-22-3000-80" {
  description = "Allow port 22 from local machine machine IP only, allow port 3000 from all and allow port 80 from all"
  name        = "tech508_nigel_tf_allow_port_22_3000_80"
  vpc_id      = data.aws_vpc.default.id

}

# Ingress SSH from local host
resource "aws_vpc_security_group_ingress_rule" "allow_port_22" {
  security_group_id = aws_security_group.tech508_nigel_tf_allow_port_22_3000_80.id
  cidr_ipv4         = "82.6.105.162/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "ssh from local machine"
}

# Ingress port 3000
resource "aws_vpc_security_group_ingress_rule" "allow_port_3000_from_anywhere" {
  security_group_id = aws_security_group.tech508_nigel_tf_allow_port_22_3000_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
  description       = "App port 3000 from all"
}

# Ingress Port 80
resource "aws_vpc_security_group_ingress_rule" "allow_port_80_from_anywhere" {
  security_group_id = aws_security_group.tech508_nigel_tf_allow_port_22_3000_80.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow http from all"
}