# 3-Tier Flask Application with AWS

## Overview
This project aims to showcase the development and deployment of a web application using Flask, a Python micro-framework, along with various AWS services for hosting and managing the application infrastructure. The application allows users to upload user's data in RDS, files in S3 and S3 object's metadata in DynamoDB. And everything is automated with Terraform from infrastructure provisioning to application deployment.

## Technical Architecture
![flask app](https://github.com/SambhuBiswakarma00/flask-app-aws/assets/142966523/6248627b-9d93-4a52-8419-fc61823dffa4)

## Application Architecture
![flask application architecture](https://github.com/SambhuBiswakarma00/flask-app-aws/assets/142966523/ed8fd713-87be-4463-8f5b-6163687d2fe6)

## Project Components

### Flask Application
The core of the project is a Flask web application that provides a user interface for uploading user details and files. The application is built using Python and integrates with various AWS services for file storage, database operations, and more.

### AWS Infrastructure
- Amazon RDS: A managed relational database service used to store user data.
- Amazon S3: A scalable object storage service used to store uploaded files.
- Amazon DynamoDB: A fully managed NoSQL database service used to store metadata associated with uploaded files.
- Amazon EC2: Virtual servers used for hosting the Flask application and managing database operations.
- Amazon Autoscaling Group: ASG used for auto-scaling.
- Amazon Application Load Balancer: Used for balancing the traffic.
- Amazon VPC: Virtual Private Cloud used to isolate the application resources.
- Amazon Route 53: A scalable domain name system (DNS) web service used for routing traffic to the application.
- Amazon CloudWatch: A monitoring and management service used for monitoring application and infrastructure health.
- Amazon IAM: Identity and Access Management service used for managing access to AWS resources securely.
- Amazon SSM Parameter Store: A service used for storing and managing configuration details securely.

### Terraform
Terraform to define and manage infrastructure as code (IaC) on AWS. Write Terraform configurations to provision resources on AWS.

### Github
- Create a GitHub repository to host your Flask application code, Terraform configurations, and other project-related files.
- Utilize Git for version control, allowing you to track changes, collaborate with team members, and maintain a history of your project's development.

## Pre-requisite

### Terraform Installation
- Terraform needs to be installed on the machine where you plan to run the script. You can download Terraform from the official website: Terraform Downloads. Ensure that the Terraform binary is added to your system's PATH 
  so that you can run it from any directory.
  
AWS CLI Installation and Configuration
- Install the AWS Command Line Interface (CLI) on your machine. You can download and install it from the official AWS website or use package managers like pip (for Python) or Homebrew (for macOS).
- After installation, configure the AWS CLI with your AWS access key, secret key, default region, etc. You can do this by running the aws configure command and providing the required information.
  
AWS Account and IAM User
- You need to have an AWS account to provision resources using Terraform.
- Create an IAM user with appropriate permissions (e.g., full access to EC2, VPC, RDS, S3) and generate access key and secret key credentials for that user.
- Use these IAM user credentials to configure the AWS CLI on your machine and terraform will run the terraform script with user's credentials configured in this AWS CLI configuration automatically. Or you can run 
  terraform with other methods of authentication.

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
