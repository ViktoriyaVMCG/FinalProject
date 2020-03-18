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
6.Update and Upgrade the system

 * _Ubuntu_
   * sudo apt-get update
   * sudo apt-get upgrade
  
 * _CentOS_
   * sudo yum update
   * sudo yum upgrade
 
 ## Installing Terraform
