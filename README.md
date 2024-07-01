# 3-Tier Flask Application with AWS

## Overview
This project aims to showcase the development and deployment of a web application using Flask, a Python micro-framework, along with various AWS services for hosting and managing the application infrastructure. The application allows users to upload user's data in RDS, files in S3 and S3 object's metadata in DynamoDB. From infrastructure provisioning to application deployment, everything is automated using Terraform.

## Technical Architecture
![flask app](https://github.com/SambhuBiswakarma00/flask-app-aws/assets/142966523/6248627b-9d93-4a52-8419-fc61823dffa4)

## Application Architecture
![flask application architecture](https://github.com/SambhuBiswakarma00/flask-app-aws/assets/142966523/ed8fd713-87be-4463-8f5b-6163687d2fe6)

## AWS Setup 
- Create VPC and its components
  - Create VPC with two public subnets in different AZs because the Application Load balancer will require atleast two public subnets for it to be created.
  - Create two private subnets as our RDS will need atleast two private subnets for it to be created.
  - Create security groups with proper inbound and outbound rules.
  - Create Internet Gateway
  - Create NAT Gateway
  - Create Elastic IP for the NAT Gateway
  - Create route tables with proper routes for all the subnets
  - Associate route tables with respective subnets
- Create Autoscaling Group
  - Create launch configuration with proper inputs like ami-id, security groups, instance type, iam_instance_profile(with proper permissions for S3, RDS, DynamoDB, Parameter store, etc), and with commands for application 
    setup
  - Create ASG with recently created launch configuration
- Create Application Load Balancer
  - Create load balancer of type "application"
  - Create target group with above created ASG as target
  - Configure aws_lb_listener
- Create S3
  - Create S3 bucket
  - Configure SSE for the S3 bucket
- Create RDS
  - Configure SSM parameter for retrieving database password from Parameter Store
  - Configure subnet group for the RDS and it should have atleast two subnets
  - Create RDS instance
  - Create a jump server in one of the public subnets, from here we can manage ec2 instances and RDS instances in private subnets
  - Create database and tables in RDS for the application using "remote-exec" provisioner on the jump server.
- Create DynamoDB
  - Crate DynamoDB table which will store the metadata of the objects uploaded to S3.

## Deployment and Hosting
The Flask application and associated AWS infrastructure are deployed and hosted on the AWS cloud platform. The infrastructure is provisioned using Terraform, allowing for automated and repeatable deployment processes.

## Conclusion
This project demonstrates the seamless integration of Flask web applications with various AWS services for scalable, reliable, and cost-effective hosting and management of web applications. By following the provided documentation and resources, developers can deploy similar applications on the AWS platform efficiently and securely.

You can find more detailed documentation on wiki page of this repo. Link - https://github.com/SambhuBiswakarma00/flask-app-aws/wiki/3%E2%80%90Tier-Web-Application-Using-Flask-in-AWS-Documentation
