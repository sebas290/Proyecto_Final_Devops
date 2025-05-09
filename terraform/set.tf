provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "mi_vpc" {
  cidr_block = "10.10.0.0/20"
  tags = { Name = "Proyecto_final" }
}

resource "aws_subnet" "publica" {
  vpc_id                  = aws_vpc.mi_vpc.id
  cidr_block              = "10.10.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = { Name = "subred_publica" }
}

resource "aws_subnet" "privada_1" {
  vpc_id            = aws_vpc.mi_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "subred_privada_1" }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.mi_vpc.id
  tags = { Name = "internet_gw" }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.mi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "rt_publica" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publica.id
  route_table_id = aws_route_table.rt.id
}

# Seguridad para web
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Permite HTTP y SSH"
  vpc_id      = aws_vpc.mi_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "web_sg" }
}

# Seguridad para Jump Server
resource "aws_security_group" "jump_sg" {
  name        = "jump_sg"
  description = "Permite acceso RDP"
  vpc_id      = aws_vpc.mi_vpc.id

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

  tags = { Name = "jump_sg" }
}

# Seguridad para RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Permite acceso desde web_sg"
  vpc_id      = aws_vpc.mi_vpc.id

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

  tags = { Name = "rds_sg" }
}

# Subnet Group para RDS (usa solo una privada para evitar conflicto)
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet_group_avance"
  subnet_ids = [aws_subnet.privada_1.id]
  tags = { Name = "db_subnet" }
}

# RDS Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = "avance-db-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"
  database_name           = "Avance"
  master_username         = "Sebas"
  master_password         = "Devops1234"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  tags = { Name = "AvanceAuroraCluster" }
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier          = "avance-db-instance"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.t3.medium"
  engine              = "aurora-mysql"
  publicly_accessible = false
  tags = { Name = "AuroraInstance" }
}

# Windows Jump Server
resource "aws_instance" "windows_jump_server" {
  ami                         = "ami-0c798d4b81e585f36"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.publica.id
  vpc_security_group_ids      = [aws_security_group.jump_sg.id]
  key_name                    = "vockey"
  associate_public_ip_address = true

  tags = {
    Name = "WindowsServer"
  }
}

# Linux Web Server
resource "aws_instance" "linux_web_server" {
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.publica.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = "vockey"
  associate_public_ip_address = true

  tags = {
    Name = "LinuxWebServer"
  }
}
