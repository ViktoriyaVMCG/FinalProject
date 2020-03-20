# Final Project
This project is intended to automate the provisioning, configuring and deploying of simple HTML web application on the two instances (machines) dev and prod using __AWS, Terraform, Ansible and Jenkins.__

In this project four ec2 instances __prod, dev, jump and jenkins__ will be created using terreform and AWS.

## Prerequisites
* __Local Machine__ Ubuntu (optional)
* __Prerequisite Software requirement:__ CentosOS 7, Terraform v0.12.6, Ansible 2.8.4, Jenkins, OpenJDK 1.8.0, Git, Apache(httpd)
* __Deployment Platform:__ Amazon Webs Services

## Installing Windows Subsystem for Linux on the PC and Updating 
1. Go to the Microsoft Store
2. Type there Ubuntu 
3. Choose: _Run Linux on Windows_ and choose your system. 
4. Install
5. Create username and password 
6. Update and Upgrade the system

 * _Ubuntu_
   * `sudo apt-get update`
   * `sudo apt-get upgrade`
  
 * _CentOS_
   * `sudo yum update`
   * `sudo yum upgrade`
 ## Preparation
 
 ### Create an ssh key
 `ssh-keygen`
 After creating it, two keys should appear in the `~/.ssh` directory
  * *private_key*  - do not share this key with anyone
  * *public_key.pub*
 ### Create an AWS account
 https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/ 
 ### Create an API key 
 We need to create an API key with in AWS to use in the Terraform.
 ### Create in your local machine a folder where you will keep the files.
 `mkdir FinalProject `
 ## Terraform
1. Go to the https://www.terraform.io/downloads.html
2. Choose the package and right click on it, then from popup menu choose copy link address
3. In terminal type the following command `wget _place_the_copied_link_over_here_`
4. The zip file will be installed to the local machine.
5. Use the following command to unzip file 
  `unzip _the_name_of_the_file_that_was_just_installed.zip_`
6. Verifying the Installation `terraform --version`

## Terraform files
The Project includes the followind files in terraform:
* terraform.tfvars
  * The file includes important variables that are called inside of the code that in the main.tf
* variables.tf
  * The file consist of the code of the variables with their explanations.
* outputs.tf
  * The file consist of the code that gives the output at the end of running main.tf file with IP addresses of the private and public addresses of the created instances
* main.tf
  * The file consist of the code that build following:
  * _AWS Key Pair_ - that generates a public and private keys
  * _AWS Elastic IP_ - the elastic IP was applyed to the jump machine so that have the same public IP everytime when the instance gets started.
  * _Employee Security Group_ - that create security group that allows only to the local machine directly connect to the jump instance and nothing else.
  * _Customer Security Group_ - that create security group that allows only dev and prod instance to connect to the browser.
  * _Instances_ - there are 4 instances that will be created by the code jump, dev, prod and jenkins.
  * _Call Ansible_ - that part of the code calls the playbook that has listed commands for each instanc and executes those commands.
## How to run Terraform files
* `terraform apply` - Run this command in the folder where the terraform files are placed. Run it also if the changes in the file were made to update. The command build everything that was written in the code.
* `terraform destroy` - The following command destroys everything that was build.
## Ansible
1. Install Ansible from Ubuntu Repository
* `sudo apt install ansible`

2. When successful, check your installed Ansible version:
* `ansible --version`
