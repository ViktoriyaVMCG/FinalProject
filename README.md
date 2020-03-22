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
   ```
   sudo apt-get update
   sudo apt-get upgrade
   ```
  
 * _CentOS_
   ```
   sudo yum update
   sudo yum upgrade
   ```
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
  `terraform apply` - Run this command in the folder where the terraform files are placed. Run it also if the changes in the file were made to update. The command build everything that was written in the code.
  
  `terraform destroy` - The following command destroys everything that was build.

## Ansible
1. Install Ansible from Ubuntu Repository
   `sudo apt install ansible`

2. When successful, check your installed Ansible version:
   `ansible --version`
## Ansible files
The Project includes the followind files in ansible:
* playbook.yml
  * The file consist of the code that connecting to the roles files that are has special command for the following httpd, java, jenkins, and jump.
* httpd main.yml 
  * The file consists of the code that Install Updates, Copy Ssh Private Keys, Copy Ssh Publick Keys, Install Apache Packages and Ensures httpd is running.
* java main.yml
  * The file consists of the code that Install Java, Configure Java and its Environment Variables and  Exports/Run Jenkins env file for make JAVA_HOME available globally.
* jenkins main.yml
  * The file consists of the code that Install Updates, Install wget and git, Download Jenkins repo, Import Jenkins Key, Install Jenkins, Start & Enable Jenkins, Sleep for 30 seconds and continue with play, Get init password Jenkins, and Print init password Jenkins.
* jump main.yml
  * The file onsists of the code that Install Updates, and Install Epel-Releas.
## How to run Ansible files
`ansible-playbook -i inventory main.yml` - Run this command to run ansible playbook or other ansible file.

`ansible-palybook -i inventory --private-key /path/to/the/main.yml --syntax-check` - Run this command to check ansible syntax before run ansible file.

In the main.tf file ansible command to run playbook is already written inside the code so when you run terraform it will authomatically call ansible.

## Jenkins
The main purpose of the Jenkis in this project is to deploy the code on the github automatically via the dev branch and head commits.

The link on the html that I used for this project:

https://github.com/ViktoriyaVMCG/DevOpsProject
## Jenkins Configuration
After Jenkins was install do the following:
1. Install telnet in the Jenkins machine and configure it. 
  ```
  sudo yum telnet
  telnet localhost 8080
  ```
2. Install ngix 
  `sudo yum ngix`
3. Configure ngix
4. Install elinks
  `sudo yum elinks`
5. Go to: http://your_ip_address:8080 and run the following commands to get admin password.
  `sudo nano /var/lib/jenkins/secrets/initialAdminPassword`
6. Copy the password and paste into browser to unlock the Jenkins.
7. Go to the Jenkins machine by open the terminal and ssh into it.
8. Go as a root
  `sudo su` and then go to the jenkins `su - jenkins`
9. Create ansible folder and inside it two more folder one dev another prod
  ```
  mkdir ansible
  mkdir dev
  mkdir prod
  ```
10. Then create inside dev and prod folders playbook that will download git and clode, update repository from github.

The following exaple of playbook for prod instance. For dev instance everything will be the same except for only one line where you should replcae the `version: master` to `version: dev`
The playbook.yml should look the following way:

```
   ---
   -
      become: true
      hosts: all
      name: "Install Git"
      tasks:
      
      - name: install git
        become: true
        register: ymrepo
        yum:
          name: git
          state: latest
          
      - name: Clone the git repo
        git:
           repo: 'https://github.com/path/to/your/project.git'
           dest: '/var/www/html/'
           version: master
           clone: yes
           update: yes
```


## How Jenkins deploys code automatically to from the github
To be able to do it we need to do the following:
1. Install GitHub Jenkins plugin. 
  * Go to Manage Jenkins -> Manage Plugin.
2. Search Github Plugin in the Available tab then click on Download now and install after the restart.
3. Creating a Jenkins job
  * To Create a new task for Jenkins, click on “New Item” then enter an item name that is suitable for your project and select Freestyle project. Now click Ok. 
4. Select the GitHub project checkbox and set the Project URL to point to your GitHub Repository.
5. Under Source Code Management tab, select Git and then set the Repository URL to point to your GitHub Repository.
6. Now Under Build Triggers tab, select the “Build when a change is pushed to GitHub” checkbox.







