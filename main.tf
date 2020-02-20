provider "aws" {
  region  = var.region
  profile = var.profile
  version = "~> 2.8"
}

#-----Default VPC
data "http" "myip" {
   url = "http://ipv4.icanhazip.com"
}

data "aws_vpc" "default"{}

##----------------Creating SSH Keys
##----SSH Keys
#resource "tls_private_key" "key_pair" {
# rsa_bits  = 4096
# algorithm = "RSA"
#}

#----AWS Key Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.owner}-projectkeypair"
 # public_key = tls_private_key.key_pair.public_key_openssh
  public_key = file ("~/.ssh/id_rsa.pub")
}

resource "local_file" "private_sshkeys" {
 # content  = tls_private_key.key_pair.private_key_pem
  filename = "./ssh/id_rsa"
  file_permission = "0600"
}

resource "local_file" "public_sshkeys" {
#  content  = tls_private_key.key_pair.public_key_openssh
  filename = "./ssh/id_rsa.pub"
  file_permission = "0600"
}


# SECURITY GROUPS

resource "aws_security_group" "jump_sg" {
  name        = "jump_sg"
  vpc_id = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port	= 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", data.aws_vpc.default.cidr_block]
  }

  egress {
  	from_port = 0
  	to_port = 0
  	protocol	= "-1"
  	cidr_blocks = ["${var.access}"]
  }
}

resource "aws_security_group" "employee_sg" {
  name        = "employee_sg"
  vpc_id = data.aws_vpc.default.id

  # HTTP
  ingress {
    from_port	= 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.access}", data.aws_vpc.default.cidr_block]
  }

 egress {
    from_port	= 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.access}"]
  }

  ingress {
  	from_port = 22
  	to_port =  22
  	protocol	= "tcp"
        cidr_blocks = ["172.31.0.0/16", data.aws_vpc.default.cidr_block]
 	security_groups =[aws_security_group.jump_sg.id] 
 }

  egress {
  	from_port = 0
  	to_port = 0
  	protocol	= "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "customer_sg" {
  name        = "customer_sg"

  # HTTP
  ingress {
    from_port	= 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port	= 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  	from_port = 0
  	to_port = 0
  	protocol	= "-1"
  	cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
  	from_port = 0
  	to_port = 0
  	protocol	= "-1"
  	cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
}


# INSTANCES

resource "aws_instance" "jump" {
  ami = var.ami
  instance_type = "t2.micro"
  availability_zone = "us-east-1c"
  key_name = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.jump_sg.name, aws_security_group.employee_sg.name]

  tags = {
    Name = "jump"
  }

 connection {
   host        = self.public_ip
   type        = "ssh"
   user        = var.user
#   private_key = tls_private_key.key_pair.private_key_pem
  }
 
   provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
    #  "sudo mv /tmp/ssh/id_rsa ~/.ssh/id_rsa",
    #  "sudo mv /tmp/ssh/id_rsa.pub ~/.ssh/id_rsa.pub",
      "sudo chmod 0600 ~/.ssh/id_rsa.pub",
      "sudo chmod 0600 ~/.ssh/id_rsa"
     ]
  }
}

resource "aws_instance" "jenkins" {
  ami = var.ami
  instance_type = "t2.small"
  availability_zone = "us-east-1c"
  key_name = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.employee_sg.name, aws_security_group.customer_sg.name]

  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "dev" {
  ami = var.ami
  instance_type = "t2.micro"
  availability_zone = "us-east-1c"
  key_name = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.employee_sg.name, aws_security_group.customer_sg.name]

  tags = {
    Name = "dev"
  }
}

resource "aws_instance" "prod" {
  ami = var.ami
  instance_type = "t2.micro"
  availability_zone = "us-east-1c"
  key_name = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.employee_sg.name, aws_security_group.customer_sg.name]

  tags = {
    Name = "prod"
  }
}


resource "local_file" "ansible_cfg" {
    content     =<<EOF

[defaults]
roles_path = ./ansible/roles
inventory_file = ./inventory
host_key_checking = False
private_key_file = ~/.ssh/id_rsa
remote_user = ${var.user}

[ssh_connection]
ssh_args = -C -F ./ssh.cfg
ControlMaster = auto
ControlPersist = 30m
control_path = ./ansible/ansible-%%r@%%h:%%p
EOF
    filename = "./ansible.cfg"
}

resource "local_file" "jump_ansiblessh" {
    content     =<<EOF
Host 172.31.*
      ProxyCommand ssh -A -W %h:%p ${var.user}@${aws_instance.jump.public_ip}
      IdentityFile ./ssh/id_rsa

Host ${aws_instance.jump.public_ip}
      User			${var.user}
      ControlMaster 	auto
      ControlPath  ./ansible/ansible-%%r@%%h:%%p
      ControlPersist	15m
      IdentityFile  ./ssh/id_rsa
EOF
    filename = "./ssh.cfg"
}

resource "local_file" "inventory_ansiblessh" {
    content     =<<EOF


[jump]
${aws_instance.jump.public_ip}

[jenkins]
${aws_instance.jenkins.private_ip}

[devops]
${aws_instance.dev.private_ip}
${aws_instance.prod.private_ip}

EOF
    filename = "./inventory"
}


 resource "null_resource" "deploy_ansible" {
# depends_on = [aws_instance.jump, aws_instance.jenkins, aws_instance.dev, aws_instance.prod] 

  provisioner"local-exec" {
    command =  "ansible-playbook -i inventory playbook.yml"
  }
}

