##########################################
# VARIABLES
##########################################

variable "region" {
  default = "us-east-1"
}

variable "key_pair_name" {
  default = "vockey"
}

variable "db_username" {
  default = "Equipo5"
}

variable "db_password" {
  default = "Devops28290"
}
##########################################
# PROVIDER
##########################################

provider "aws" {
  region = var.region
}

##########################################
# VPC Y REDES
##########################################

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.10.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Name = "PrivateSubnet"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "PrivateSubnet2"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRT"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

##########################################
# SECURITY GROUPS
##########################################

resource "aws_security_group" "jump_sg" {
  name        = "JumpSG"
  description = "Allow RDP from anywhere"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "WebSG"
  description = "Allow HTTP from all, SSH from Jump Server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jump_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_sg" {
  name        = "DBSG"
  description = "Allow MySQL from Web Server only"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##########################################
# INSTANCIAS EC2
##########################################

resource "aws_instance" "jump_server" {
  ami           = "ami-0c765d44cf1f25d26"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_pair_name
  security_groups = [aws_security_group.jump_sg.id]
  tags = {
    Name = "JumpServer"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_pair_name
  security_groups = [aws_security_group.web_sg.id]
  tags = {
    Name = "WebServer"
  }
}

##########################################
# RDS AURORA MYSQL
##########################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_2.id
  ]
  tags = {
    Name = "DBSubnetGroup"
  }
}


resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_mode             = "serverless"
  master_username = var.db_username
  master_password = var.db_password
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  enable_http_endpoint    = true
  tags = {
    Name = "AuroraCluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier              = "aurora-instance"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = aws_rds_cluster.aurora_cluster.engine
  publicly_accessible     = false
  tags = {
    Name = "AuroraInstance"
  }
}
