# tech-508-tf
Terraform study

# What is Infrastructure as Code (IaC)

## Intro to Infrastructure as Code 

What have we automated so far? 

- VMs 
	- Creation of VMs? NO has not been automated
	- Creation of infrastructure where the VMs live? No not automated
	- Setup and configure software on VM - Yes
		- Bash Scripting 
		- User Data 
		- Images 

What does terraform solve?
- We are still provisioning servers
		- Provisioning = the process of setting up and configuring the servers 

#IaC 
- IaC is codifying what you want (declarative) , not the steps (imperative) needed to get there
- Defining the desired state/outcome 
- Definition: A way to manage and provision computers through machine-readable definitions of infrastructure

## Two types of IaC Tools

1) Configuration management tools 
	- These are the tools that configure what you defined (software)
	- Examples: Chef, Puppet, Ansible

2) Orchestartion tools 
- These tools set up the infrastructure
	- Terraform 
	- CloudFormation (AWS)
	- ARM/Bicep template (Azure)
	- Ansible can do it, but not designed for it 


.terraform.lock.hcl
- This file locks terraform provider version




## Blockers while installing Terraform

- Unable to execute 
- Go to file path, cmd, `terraform --version` > success
- Unable to find terraform in gitbash 
  - # Put your Windows path to the FOLDER (not the .exe) between the quotes:
WIN_TF_DIR="C:\toolsfile\terraform"

# Convert to Git Bash path and append to ~/.bashrc
`echo "export PATH=\"\$PATH:$(cygpath -u "$WIN_TF_DIR")\"" >> ~/.bashrc`



## Basic Terraform commands 

`terraform init` - downloads provider plugins (e.g., AWS) and sets up your working directory (backend state files).

It does not create any resources yet.

`terraform plan` - This shows you what Terraform will create, change, or destroy — without actually doing it. Detects configuration drift.

`terraform apply` - It will first run a terraform plan and it will ask you if you wish to proceed. This is the step that actually provisions the code.

`terraform destroy` - This deletes the instance 

# Create infrastructure

1) Start by cloning the example repository. This configuration builds an EC2 instance, an SSH key pair, and a security group rule to allow SSH access to the instance.
- git clone https://github.com/Nwiko93/tech-508-tf.git

2) Change into the repository directory.

3) Confirm your AWS CLI region.
   - `aws configure get region`
   - `eu-west-1`

4) Open the `main.tf` file and review your configuration. The main resources are your EC2 instance, your key pair, and the SSH security group.

**Note:** Terraform names can't have hyphens. They use underscrores to keep it human readable.
##...

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("${path.module}/key.pub")
}

resource "aws_instance" "example" {
  ami                    = data.aws_ami.ubuntu.id
  key_name               = aws_key_pair.deployer.key_name
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ssh.id]
  user_data              = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              sed -i -e 's/80/8080/' /etc/apache2/ports.conf
              echo "Hello World" > /var/www/html/index.html
              systemctl restart apache2
              EOF
  tags = {
    Name          = "terraform-learn-state-ec2"
    drift_example = "v1"
  }
}


resource "aws_security_group" "sg_ssh" {
  name = "sg_ssh"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


5) Initialize your configuration.



# Security Groups

*example:*

resource "aws_security_group" "sg_web" {
  name        = "sg_web"
  description = "allow 8080"
}

resource "aws_security_group_rule" "sg_web" {
  type      = "ingress"
  to_port   = "8080"
  from_port = "8080"
  protocol  = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_web.id
}


## Ingress and Egress rules

### Ingress 
- Ingress rules control the traffic that is allowed to enter the instances associated with the security group.

### 
- Egress rules control the traffic that is allowed to leave the instance associated with the security group.

### vpc_id 
- It is now obligatory to include a vpc_id when creating a security group.
- If you don't have a set vpc you can use the default vpc set by aws
- `aws_vpc.main.id`/`data.aws_vpc.default.id`
- To allow your local machine to SSH in in the cidr blocks for port 22 use your own public ip address and ".32"
  - e.g. `192.168.0.53/32`


## More Terraform theory 

 - What is Terraform? What is it used for?    
   - Orchestration - Provisioning infrastructure 
     - See's infrastructure as immutable (cannot be changed and cannot add anything to it) - code is disposable
   - Configuration management is mutable
   - (HCL) Hashicorp Language - `terraform fmt`
     - Can be converted to json and back

- Why use Terraform? The Benefits?
  - Easy to use 
  - Sort of open-source 
    - BSL since 2023 (Business Source Licence)
    - Some organisations have switched over to OpenTofu
  - It is declaritive 
  - Cloud-agnostic (can be used on any cloud provider)
  - Expressive and extensible language 
  - 


- Alternatives to Terraform 
  - Pulumi
  - AWS CloudFormation
  - GCP Deployment Manager 
  - ARM templates for Azure 


- Who is using Terraform in the industry?
  - Every industry

- In Iac, what is orchestration? How does Terraform act as an "orchestrator"
  - Managing lifecycle of infrastructer
  - Creates, deletes, modifies in the right order 

- Best practice supplying AWS credentials to Terraform
  - git ignore/hidden files 
    - credentials are likely shared in certain files 
    - Never hard code variables into 

Uses this order to sign in: 
1) Through env variiable (Okay)
2) Terraform variables in your code (Worse practice) 
3) AWS CLI shared credentials files (Okay) - run the `aws configure`
4) EC2 instance metadata - assign a role (Set of permissions) to EC2 instance (Best Practice)

- Why use Terraform for different environments e.g.: 
  - Development/ Testing 
    - Easy to spin up the architecture when they need it 
    - Easy to destroy architecture when they're done 
  - Testing
  - Quality and Assurance
  - Production
    - Easily able to to create larger-scale environments/ Auto scaling 
  - 
  - Consistency accross different environments  



- ## Configuration drift 
- This is when there are changes to the infrastucture
- Terraform protects against this 
  - It does this by referring to the code which keeps the infrstructure on the "straight and narrow"
  - It uses the code to detect manual configuration 



