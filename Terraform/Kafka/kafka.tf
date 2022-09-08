terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.AWS_REGION
}

resource "aws_vpc" "kafka_vpc" {                
   cidr_block       = var.CIDR[0]     
   instance_tenancy = "default"
   tags = {
     "Name" = "kafka_vpc"
   }
 }
 
 resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.kafka_vpc.id               
 }

 resource "aws_subnet" "public_subnet" {    
   vpc_id =  aws_vpc.kafka_vpc.id
   map_public_ip_on_launch = true
   cidr_block = var.CIDR[1]
      tags = {
     "Name" = "public"
   }        
 }

 resource "aws_route_table" "PublicRT" {    
    vpc_id =  aws_vpc.kafka_vpc.id
         route {
    cidr_block = "0.0.0.0/0"               
    gateway_id = aws_internet_gateway.IGW.id
     }
 }

 resource "aws_route_table_association" "PublicRT_association" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.PublicRT.id
 }

resource "aws_security_group" "kafka_security_group" {
  vpc_id = aws_vpc.kafka_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "Kafka-sg"
  }
}

resource "aws_instance" "kafka_server" {
  depends_on    = [aws_security_group.kafka_security_group]
  ami           = var.AMI
  instance_type = var.Instance_Type

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.kafka_security_group.id]
  key_name               = "testkp"
  user_data              = file("install_kafka.sh")

  tags = {
    Name = "kafka_server"
  }
}
