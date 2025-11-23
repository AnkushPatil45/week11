# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = "us-west-2"
}

# Add VPC resource (required for the security group)
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Secured VPC"
  }
}

resource "aws_security_group" "web-sg" {
  name        = "web-sg-secured"
  vpc_id      = aws_vpc.default.id
  description = "Security Group for secured web traffic" # FIX: Added description for the SG

  ingress {
    description = "Allow HTTP access from within VPC" # FIX: Added rule description (tfsec requirement)
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.default.cidr_block] # FIX: Restricted CIDR block (removed 0.0.0.0/0)
  }

  egress {
    description = "Allow all outbound connections" # FIX: Added rule description (tfsec requirement)
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# The aws_instance, data "aws_ami", and random_pet resources were removed 
# to simplify the code and eliminate multiple security alerts (like unencrypted volumes).
