# Provider Section
provider "aws" {
    region = "us-east-1" 
}



# -----------------------------------This section is for network infra---------------------------------


# Creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my_vpc"
    }
}

# Creating public subnets
resource "aws_subnet" "my_public_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true     # Enable public IP association for instances in public subnet
  tags = {
        Name = "my_public_subnet_us_east_1a"
    }
}

resource "aws_subnet" "my_public_subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true     # Enable public IP association for instances in public subnet
  tags = {
        Name = "my_public_subnet_us_east_1b"
    }
}

# Creating private subnets
resource "aws_subnet" "my_private_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false    # Disable public IP association for instances in private subnet
  tags = {
        Name = "my_private_subnet_us_east_1a"
    }
}

resource "aws_subnet" "my_private_subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false    # Disable public IP association for instances in private subnet
  tags = {
        Name = "my_private_subnet_us_east_1a"
    }
}

# Creating security group
resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "My security group"

  vpc_id = aws_vpc.my_vpc.id

  // Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound SSH traffic"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound HTTP traffic"
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound HTTPS traffic"
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
    description = "Allow inbound mysql traffic"
  }
  // Outbound rules
  egress {
    from_port   = 0  
    to_port     = 0  
    protocol    = "-1"  # All protocol

    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic to all destinations (Internet)
  }
  tags = {
        Name = "my_security_group"
    }
}

# Creating internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

# create nat gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.my_public_subnet.id
}

# create elastic ip for nat gateway
resource "aws_eip" "my_eip" {
  domain   = "vpc"
}

# Creating route table
resource "aws_route_table" "my_route_table_public" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePublicSubnet1"
  }
}

resource "aws_route_table" "my_route_table_public_subnet2" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePublicSubnet2"
  }
}

resource "aws_route_table" "my_route_table_private" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePrivateSubnet"
  }
}

resource "aws_route_table" "my_route_table_private2" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyRouteTablePrivateSubnet2"
  }
}
# Creating route for igw
resource "aws_route" "route_to_igw" {
  route_table_id         = aws_route_table.my_route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route" "route_to_igw2" {
  route_table_id         = aws_route_table.my_route_table_public_subnet2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Creating route for nat gateway
resource "aws_route" "route_to_nat_gateway" {
  route_table_id         = aws_route_table.my_route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
}

resource "aws_route" "route_to_nat_gateway2" {
  route_table_id         = aws_route_table.my_route_table_private2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
}

# Associating route table with subnet 1
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table_public.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.my_public_subnet2.id
  route_table_id = aws_route_table.my_route_table_public_subnet2.id
}

# Associating route table with subnet 2
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.my_route_table_private.id
}

resource "aws_route_table_association" "private_subnet2_association2" {
  subnet_id      = aws_subnet.my_private_subnet2.id
  route_table_id = aws_route_table.my_route_table_private.id
}

# --------------------------This section is for ASG---------------------------------------------

# Create Auto Scaling Group
resource "aws_autoscaling_group" "my_asg" {
  name                      = "my-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  launch_configuration      = aws_launch_configuration.my_launch_config.name
  vpc_zone_identifier       = [aws_subnet.my_private_subnet.id,aws_subnet.my_private_subnet2.id]  # Replace with your subnet IDs
  target_group_arns         = [aws_lb_target_group.my_target_group.arn]  # Associate ASG with target group created in the ELB section
}

# Create Launch Configuration
resource "aws_launch_configuration" "my_launch_config" {
  name_prefix               = "my-server"
  image_id                  = "ami-080e1f13689e07408"  # Replace with your desired AMI ID
  instance_type             = "t2.micro"      # Replace with your desired instance type
  security_groups           = [aws_security_group.my_security_group.id]  # Replace with your security group name
  key_name                  = "newkeypair"  # Replace with your SSH key pair name
  iam_instance_profile      = "Instance_profile_for_s3_rds_dynamodb" #this instance profile should have proper permissions for RDS, S3, DynamoDB, Parameter store and other necessary permissions
  depends_on = [aws_db_instance.my_db_instance] #this launch config will only be created after RDS creation because we need RDS database endpoint for the database host url.
  # user_data = file("./install.sh")
  # Given below user data commands will do the necessary setup of instances for our application to run.
  user_data = <<-EOF
    #!/bin/bash
    apt update
    sleep 180
    export RDS_HOST=$(echo ${aws_db_instance.my_db_instance.endpoint} | cut -d: -f1)
    # run this below command before installing the pip, this will supress the prompt for the service restart otherwise we need to manually interact with that prompt
    sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf 
    sudo apt-get install python3 python3-pip -y
    sudo pip3 install flask pymysql boto3
    git clone https://github.com/SambhuBiswakarma00/flask-app-aws.git
    sudo python3 flask-app-aws/app/app.py
    EOF
}

# -----------------------------------------This section is for ELB----------------------------------------------

# Create Elastic Load Balancer
resource "aws_lb" "my_elb" {
  name                      = "my-elb"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = [aws_security_group.my_security_group.id]  # Replace with your security group name
  subnets                   = [aws_subnet.my_public_subnet.id, aws_subnet.my_public_subnet2.id]  # Replace with your subnet IDs and it should have atleast two subnets
  #  access_logs {
  #   bucket  = aws_s3_bucket.sambhubucket.id
  #   prefix  = "test-lb"
  #   enabled = true
  # }
  
}

# Create Target Group
resource "aws_lb_target_group" "my_target_group" {
  name                      = "my-target-group"
  port                      = 80
  protocol                  = "HTTP"
  vpc_id                    = aws_vpc.my_vpc.id
  # Other target group options...
  
}
# Create listener
resource "aws_lb_listener" "my_elb_listener" {
  load_balancer_arn = aws_lb.my_elb.arn
  port              = 80
  protocol          = "HTTP"
  
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.arn
    
  }
  
}

# -----------------------------------------This section is for S3-------------------------------------------------

# configuring S3 bucket
resource "aws_s3_bucket" "sambhubucket" {
  bucket = "sambhubucket" # Update with your desired bucket name

  # Uncomment the following if you want to enable versioning for the bucket
  # versioning {
  #   enabled = true
  # }
  # Uncomment the following if you want to apply a bucket policy
  # policy = <<POLICY
  # {
  #   "Version": "2012-10-17",
  #   "Statement": [
  #     {
  #       "Effect": "Allow",
  #       "Principal": "*",
  #       "Action": "s3:GetObject",
  #       "Resource": "arn:aws:s3:::${aws_s3_bucket.my_bucket.bucket}/*"
  #     }
  #   ]
  # }
  # POLICY

  # Uncomment the following if you want to enable access logging for the bucket
  # logging {
  #   target_bucket = "my-logging-bucket"
  #   target_prefix = "logs/"
  # }

  # Uncomment the following if you want to enable tags for the bucket
  tags = {
    Name        = "FlaskAppBucket"
    Environment = "FlaskApp"
  }
  
}

# SSE Configuration for  S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "SSE_config" {
  bucket = aws_s3_bucket.sambhubucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
    bucket_key_enabled = false
  }
}

# # --------------------------------------------This section is for RDS----------------------------------

data "aws_ssm_parameter" "db_password" {
  name = "rds-db-password" # Update with the parameter name in Parameter Store
}

# subnet group config for db
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "my-rds-database-subnet-group"
  subnet_ids = [aws_subnet.my_private_subnet.id, aws_subnet.my_private_subnet2.id]
}

resource "aws_db_instance" "my_db_instance" {
  identifier            = "my-db-instance" # Update with your desired DB instance identifier
  allocated_storage     = 20  # Update with your desired storage size in GB
  engine                = "mysql"  # Update with your desired database engine
  engine_version        = "8.0.35"  # Update with your desired database engine version
  instance_class        = "db.t3.micro"  # Update with your desired instance type
  storage_type          = "gp2"
  username              = "admin"  # Update with your desired database username
  password              = data.aws_ssm_parameter.db_password.value # Retrieve password from Parameter Store
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot   = true
  publicly_accessible   = false  # Update based on your network requirements
  
  # Replace "security-group-id" with your actual security group ID
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
}

# Jump instance for managing rds db instance 
resource "aws_instance" "jump_instance" {
  ami           = "ami-080e1f13689e07408"  # Specify the AMI ID for your EC2 instance
  instance_type = "t2.micro"                # Specify the instance type (e.g., t2.micro, t3.small)
  subnet_id     = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  key_name               = "newkeypair"
  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y mysql-client
    EOF
  tags = {
    Name = "jump-instance-for-mysql"  # Specify a name tag for your instance 
  }
}

# using below block to automate the creation on database and table in the rds instance
resource "null_resource" "create_database" {
  depends_on = [aws_db_instance.my_db_instance, aws_instance.jump_instance]
  connection {
    type        = "ssh"
    user        = "ubuntu"  # The username to use when connecting via SSH
    private_key = file("/home/sambhu/Intellipaat/newkeypair.pem")  # Path to the private key file
    host        = aws_instance.jump_instance.public_ip  # The public IP address of the EC2 instance
  }

  provisioner "remote-exec" {
    
    inline = [
      "export MYSQL_PWD=${aws_db_instance.my_db_instance.password}",
      "endpoint=$(echo ${aws_db_instance.my_db_instance.endpoint} | cut -d: -f1)", #we cannot use this endpoint directoly for host because this endpoint contains host url + port (example - 'my-db-instance.cs3r6mwhqazo.us-east-1.rds.amazonaws.com:3306), but we only want the url without port, thats why we are removing port by manupulating the endpoint
      "mysql -h \"$endpoint\" -u ${aws_db_instance.my_db_instance.username} -e 'CREATE DATABASE IF NOT EXISTS mydatabase;'",
      "mysql -h \"$endpoint\"  -u ${aws_db_instance.my_db_instance.username} -e 'USE mydatabase; CREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, Name VARCHAR(255), location VARCHAR(255), Age VARCHAR(255), Technology VARCHAR(255));'"
      # "mysql -h ${aws_db_instance.my_db_instance.endpoint} -u ${aws_db_instance.my_db_instance.username} -p${aws_db_instance.my_db_instance.password} -e 'CREATE DATABASE IF NOT EXISTS mydatabase;'",
      # "mysql -h ${aws_db_instance.my_db_instance.endpoint} -u ${aws_db_instance.my_db_instance.username} -p${aws_db_instance.my_db_instance.password} -e 'USE mydatabase; CREATE TABLE IF NOT EXISTS mytable (id INT AUTO_INCREMENT PRIMARY KEY, Name VARCHAR(255), location VARCHAR(255), Age VARCHAR(255), Technology VARCHAR(255));'"
        # "mysql -V",
        # "cd ~",
        # "sudo touch test.txt",
        # "echo $endpoint",
        # "echo $MYSQL_PWD",
        # "echo ${aws_db_instance.my_db_instance.username}"
    ]
  }
}

resource "aws_ssm_parameter" "rds_host" {
  name  = "rds_host"
  type  = "String"
  value = aws_db_instance.my_db_instance.endpoint
}

# ------------------------------------This section is for DynamoDB-------------------------------------------

resource "aws_dynamodb_table" "dynamodb-table" {
  name           = "My_Table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "filename"  #this is the partition key, it is required
  # range_key      = "GameTitle"  #this is the sort key, its optional and you can use any attribute listed below for example "Author" as sort key


#  attributes are the columns for our tables
  attribute {
    name = "filename"
    type = "S"
  }

  # attribute {
  #   name = "Author"
  #   type = "S"
  # }

# The TTL feature in DynamoDB allows you to automatically delete items from the table after a specified expiration time.
#   ttl {
#     attribute_name = "TimeToExist"
#     enabled        = false
#   }

# You can uncomment the below section if you want to use GSI
  # global_secondary_index {
  #   name               = "GameTitleIndex"
  #   hash_key           = "GameTitle"
  #   range_key          = "TopScore"
  #   write_capacity     = 10
  #   read_capacity      = 10
  #   projection_type    = "INCLUDE"
  #   non_key_attributes = ["UserId"]
  # }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "FlaskApp"
  }
}