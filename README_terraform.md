# Automating Serverless RDS Management with Terraform: Infrastructure Development Lab

#### Table of Content

- [Utilizing Gitpod Code Editor](#utilizing-gitpod-code-editor)
- [Setting up the Required Command Line Interfaces](#setting-up-the-required-command-line-interfaces)
  * [AWS CLI](#aws-cli)
  * [Terraform CLI](#terraform-cli)
  * [Configuring Environment Variables](#configuring-environment-variables)
  * [Gitpod configuration to use the CLI installation scripts](#gitpod-configuration-to-use-the-cli-installation-scripts)
- [Lab Directory Structure](#lab-directory-structure)
- [Terraform development](#terraform-development)
  * [1. Terraform initial setup](#1-terraform-initial-setup)
  * [2. VPC and Network components Creation](#2-vpc-and-network-components-creation)
    + [2.1. VPC Creation](#21-vpc-creation)
    + [2.2. Subnets creation](#22-subnets-creation)
    + [2.3. Route Tables](#23-route-tables)
    + [2.4. Internet Gateway](#24-internet-gateway)
    + [2.5. Security Group](#25-security-group)
  * [3. Amazon RDS creation](#3-amazon-rds-creation)
    + [3.1. DB Subnet Groups](#31-db-subnet-groups)
    + [3.2. RDS Private](#32-rds-private)
    + [3.3. RDS Public](#33-rds-public)
  * [4. Lambda Function creation](#4-lambda-function-creation)
    + [4.1. Lambda Layers](#41-lambda-layers)
    + [4.2. IAM Role and Policy for Lambda](#42-iam-role-and-policy-for-lambda)
    + [4.3. Python Code](#43-python-code)
    + [4.4. Lambda function for Private RDS](#44-lambda-function-for-private-rds)
    + [4.5. Lambda function for Public RDS](#45-lambda-function-for-public-rds)

<br>

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>



## Utilizing Gitpod Code Editor

For the development of this lab, Gitpod served as the primary tool for editing code. Gitpod stands out as an online Integrated Development Environment (IDE) that empowers developers to write, review, and manage their code directly within a web browser. Seamlessly integrating with Git repositories like GitHub, GitLab, and Bitbucket, Gitpod eliminates the need for setting up a local development environment, thereby streamlining the coding process.

The key reasons I used it for my lab are the following: 

- **Instant Setup**: With Gitpod, setting up a development environment is quick and easy. You can start coding immediately without spending time configuring a local machine with dependencies and tools.
- **Workspace Snapshots**: Gitpod automatically saves the state of a developer's workspace, including open files, terminal sessions, and installed dependencies. This allows you to pause the work and resume it later without losing any progress.
- **Cloud-based**: Since Gitpod runs entirely in the cloud, you can access the development environments from anywhere with an internet connection. This makes it convenient for remote work and from different PCs.
- **Integration with GitHub**: You can install a Chrome extension and from your GitHub repository launch your Workspace instantly.

## Setting up the Required Command Line Interfaces

To enhance modularity and facilitate reuse across various projects and labs, bash scripts were crafted for the installation of both the AWS CLI and Terraform CLI.

### AWS CLI

The installation script for the AWS CLI is encapsulated within the file named `install_aws_cli`.

```bash
#!/usr/bin/env bash

cd /workspace

rm -f '/workspace/awscliv2.zip'
rm -rf '/workspace/aws'

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

aws sts get-caller-identity

cd $PROJECT_ROOT
```

### Terraform CLI

Similarly, the installation script for the Terraform CLI resides within the file named `install_terraform_cli`.

```bash
#!/usr/bin/env bash

cd /workspace

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform -y

cd $PROJECT_ROOT
```

### Configuring Environment Variables

Environment variables serve as crucial conduits for passing information between commands and subprocesses, streamlining various operations within your development environment.

**Env Commands**

- `env` used to list out all the Env Vars
- `env | grep EXAMPLE` It will filter the env vars and show all that have EXAMPLE on their name
- `export HELLO="world"` it will make this variable available for all child terminals until restart the workspace
- `unset HELLO` will erase the value of the variable
- `echo $HELLO` will print the env var value 

Every bash terminal window open will have its own env vars. If you want the env vars to persist to all future bash terminals you need to set env vars in your bash profile `.bash_profile`

**Persistent Env Vars in Gitpod**

In Gitpod, you can achieve the persistence of environment variables by storing them within Gitpod Secrets Storage using the following command:

```bash
gp env HELLO="world"
```

Subsequently, all forthcoming workspaces launched will automatically configure these environment variables for all bash terminals opened within those workspaces.

**Setting the ENV VARS needed**

```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export PROJECT_ROOT="/workspace/aws-serverless-rds-management-lab"
export TF_VAR_db_pass="Your-DB-Admin-Password"

gp env AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
gp env AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
gp env PROJECT_ROOT="/workspace/aws-serverless-rds-management-lab"
gp env TF_VAR_db_pass="Your-DB-Admin-Password"
```

### Gitpod configuration to use the CLI installation scripts

To maintain organizational clarity and separation from the lab files, the bash scripts were housed within the `bin` directory.

To grant execution permissions to these scripts, the `chmod` command is employed as demonstrated below:

```bash
chmod u+x ./bin/install_aws_cli
```
```bash
chmod u+x ./bin/install_terraform_cli
```

Gitpod uses a file named `gitpod.yml` to configure various aspects of the development environment for a project. This YAML file defines the tools, dependencies, and tasks required to set up the workspace in Gitpod.

After make executable the scripts we can reference them from `gitpod.yml` file to install all that we need:

```bash
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    before: |
      cd $PROJECT_ROOT
      source ./bin/install_aws_cli
      source ./bin/install_terraform_cli
      cd $PROJECT_ROOT

vscode:
  extensions:
    - amazonwebservices.aws-toolkit-vscode
    - hashicorp.terraform
    - phil294.git-log--graph
    - mhutchie.git-graph
```

## Lab Directory Structure

```
PROJECT_ROOT
│
├── bin/
│  ├── install_aws_cli				
│  └── install_terraform_cli		
├── lambda/
│  ├── lambda_function.py			
│  ├── lambda_function_payload.zip
│  └── python_layer_pymysql.zip	
├── main.tf 
├── lambda.tf
├── rds.tf
├── vpc.tf                		
├── variables.tf            		
├── terraform.tfvars        		
├── env.needed            			
├── README_terraform.md        		
└── README.md               		
```

This structured layout provides a clear delineation of project components, facilitating efficient organization and navigation within the development environment.


## Terraform development

In order to develop Infrastructure as Code (IaC) for AWS using Terraform, you can refer to the [Terraform Documentation for AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) for detailed guidance and reference.


###  1. Terraform initial setup

To start our terraform code you need to set up the backend where will be located our terraform state file and specify the provider that will be used.  We specify Terraform version 1.6.6 at the minimum and the provider AWS version 5.31.0. All our initial setup code will be located in the file `main.tf` for easy understand.

```terraform
terraform {
  backend "s3" {
    bucket = "terraform-state-grau"
    key    = "sns_Lab/sns_infra"
    region = "us-east-1"
  }
  required_version = ">= 1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

provider "aws" {
  region = var.aws-region

  # Setting default tag for all resources created in this IaC
  default_tags {
    tags = {
      Project = "Notification System"
    }
  }
}
```

In this initialization phase, an Amazon S3 bucket named `terraform-state-grau` is designated as the backend to house the Terraform state file. It's important to note that for collaborative environments, it's recommended to utilize a DynamoDB database for state-locking mechanisms to prevent concurrent modifications.

Ensure to customize the backend configuration as per your requirements and adhere to best practices for managing Terraform state in a collaborative setting.

### 2. VPC and Network Components creation

All configurations related to the creation of VPC and network components are organized within the `vpc.tf` file. This helps maintain readability and modular structure, making it easier to manage and understand the infrastructure setup.

#### 2.1. VPC Creation

Now, we'll establish the Virtual Private Cloud (VPC) and essential network components to provide a secure and isolated environment for our infrastructure.

```terraform
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.vpc-name}-vpc"
  }
}
```

We created a VPC with the specified CIDR block `10.0.0.0/24` to define the IP address range for our network. It's important to note that although DNS support and hostnames are enabled by default when creating a VPC through the AWS Management Console, in Terraform, you must explicitly set the `enable_dns_hostnames` attribute to `true` in order to grant the access to the public lambda we will create later.

#### 2.2. Subnets creation

In this step, we'll create private and public subnets within our Virtual Private Cloud (VPC). These subnets provide segmentation for our infrastructure components, enabling better control over network traffic and security.

**2.2.1. Private Subnets**

We deploy two private subnets to host resources that require private network access. Each private subnet is associated with the VPC created earlier.

```terraform
resource "aws_subnet" "private_subnets" {
  for_each          = var.private-subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc-cidr, 4, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name = "${var.vpc-name}-${each.key}-${local.az[each.value]}"
  }
}
```

To avoid repeat expressions we use the following `locals` block :

```terraform
# Local variable to define AZ used
locals {
  az = data.aws_availability_zones.available.names
}
```
The **`locals` block** is utilized here to store the availability zones available in the selected region. This is achieved by querying the AWS provider for availability zone names using the `data.aws_availability_zones.available` data source. The `az` variable within the local block holds this information.

We need to add this `data resource` in the `main.tf` file

```terraform
#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}
```


By referencing the `local.az` variable, we dynamically assign each private subnet to an availability zone, ensuring distribution across multiple zones within the region.


The **`cidrsubnet` function** is used to calculate the CIDR blocks for each subnet within the VPC. It takes three arguments:

- **Base CIDR block of the VPC (`var.vpc-cidr`):** This represents the overall IP address range allocated to the VPC.
    
- **New subnet mask width (`4`):** This specifies the number of bits to reserve for the subnet prefix within the VPC CIDR block.
    
- **Offset value (`each.value`):** This determines the subnet's position within the VPC CIDR block. For example, if the `each.value` is `0`, the subnet will be created at the beginning of the VPC CIDR block; if it's `1`, the subnet will be created after the first subnet, and so on.

For more information about the `cidrsubnet` function you can reference the [Terraform function documentation](https://developer.hashicorp.com/terraform/language/functions/cidrsubnet)


**2.2.2. Public Subnets**

Similarly, we create two public subnets to accommodate resources that require public accessibility. These subnets are also associated with the VPC.

```terraform
resource "aws_subnet" "public_subnets" {
  for_each          = var.public-subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc-cidr, 4, each.value + 10)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name = "${var.vpc-name}-${each.key}-${local.az[each.value]}"
  }
}
```

The `cidrsubnet` function is used here in a similar manner to create CIDR blocks for public subnets, with an offset value adjusted (`each.value + 10`) to ensure separation from private subnets. This allows for better network organization and security.

#### 2.3. Route Tables

Route tables define how network traffic is directed within the Virtual Private Cloud (VPC). In this section, we'll create route tables for both private and public subnets to manage routing within our infrastructure.

**2.3.1. Route Tables for Private Subnets**

We create separate route tables for each private subnet to control the flow of traffic within these isolated network segments.

```terraform
resource "aws_route_table" "private-route-table" {
  for_each = var.private-subnets
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc-name}-rtb-private${each.value}-${local.az[each.value]}"
  }
}
```

Each private subnet is associated with its respective route table, enabling customized routing configurations based on specific requirements.

**2.3.2. Route Tables for Public Subnets**

For public subnets, we create a single route table to direct traffic to the internet gateway, allowing resources within these subnets to communicate with the public internet.

```terraform
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "${var.vpc-name}-rtb-public"
  }
}
```
This route table is associated with all public subnets, ensuring consistent internet connectivity across these segments.

**2.3.3. Route Table Associations**

Finally, we associate each subnet with its corresponding route table to govern the routing behavior for network traffic within the VPC.

```terraform
# Create route table associations for private subnets
resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private_subnets
  route_table_id = aws_route_table.private-route-table[each.key].id
  subnet_id      = each.value.id
}

# Create route table associations for public subnets
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public-route-table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}
```

These associations ensure that traffic originating from each subnet follows the specified routing rules defined in the corresponding route table.

#### 2.4. Internet Gateway

An Internet Gateway (IGW) serves as the entry and exit point for network traffic between a Virtual Private Cloud (VPC) and the Internet. Here, we'll create an IGW to enable internet access for resources within our VPC.

```terraform
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.vpc-name}-igw"
  }
}
```

This resource associates the internet gateway with our VPC, allowing inbound and outbound internet traffic to flow freely. The assigned tags aid in resource identification and management within the AWS Management Console.

#### 2.5. Security Group

Here, we'll create a security group to grant access to the Public Lambda Function that will be created in the following steps. A security group acts as a virtual firewall for your Virtual Private Cloud (VPC) to control inbound and outbound traffic for instances.

```terraform
# Created VPC Security group
resource "aws_security_group" "allow-all-traffic" {
  name        = "allow-all-traffic"
  description = "Allow all IPv4 inbound traffic"
  vpc_id      = aws_vpc.vpc.id
}
```
This resource defines a security group named "allow-all-traffic" with a description indicating it allows all IPv4 inbound traffic within the associated VPC. The security group is attached to the VPC specified by `aws_vpc.vpc.id`.

```terraform
# Created ingress rule for all IPv4 traffic
resource "aws_vpc_security_group_ingress_rule" "allow-all-traffic-ipv4" {
  security_group_id = aws_security_group.allow-all-traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
```

This resource creates an ingress rule within the security group `aws_security_group.allow-all-traffic`, allowing all IPv4 traffic from any source (0.0.0.0/0) on all ports (ip_protocol = "-1"). This rule effectively opens up the security group to allow inbound traffic from any source.

This setup is intended to provide flexibility for the Public Lambda Function.

### 3. Amazon RDS creation

All configurations related to the creation of the Amazon RDS instances are organized within the `rds.tf` file. This modular structure enhances readability and simplifies the management of the infrastructure setup.

#### 3.1. DB Subnet Groups

When setting up Amazon RDS, AWS mandates the creation of a DB subnet group. The following code will create a DB Subnet Groups needed:


```terraform
# Create DB Subnet Group for Private and Private subnets
resource "aws_db_subnet_group" "private-db-subnet" {
  name        = var.private-db-subnet-name
  subnet_ids  = [for subnet_key, subnet_value in aws_subnet.private_subnets : subnet_value.id]
  description = "DB subnet for the RDS Private"
}

resource "aws_db_subnet_group" "public-db-subnet" {
  name        = var.public-db-subnet-name
  subnet_ids  = [for subnet_key, subnet_value in aws_subnet.public_subnets : subnet_value.id]
  description = "DB subnet for the RDS Public"
}
```

These resources define the DB Subnet Groups required for both Private and Public RDS instances. Subnets are dynamically retrieved from the previously created private and public subnets, ensuring proper network isolation and access control for the RDS instances.

#### 3.2. RDS Private

The following code will create the RDS instance to be utilized within the Private Subnets:

```terraform
resource "aws_db_instance" "rds-private" {
  allocated_storage       = 20
  db_name                 = var.db-name
  identifier              = var.rds-private-db-name
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = var.db-username
  password                = var.db_pass
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.private-db-subnet.name
  vpc_security_group_ids  = [aws_security_group.allow-lambda-to-rds.id]
}
```

This resource defines an RDS instance within the Private Subnets, allowing secure access to database resources. It specifies various parameters such as username and authentication credentials to access the database.

Due to the RDS instance being located within the Private Subnets, direct access from the Lambda function is restricted. To enable communication between the Lambda function and the RDS instance, we need to create a security group allowing inbound traffic from the Lambda function.

```terraform
# Create Security Group to allow traffic from Lamda to RDS
resource "aws_security_group" "allow-lambda-to-rds" {
  name        = "rds-lambda-connect"
  description = "Allow inbound traffic from lambda"
  vpc_id      = aws_vpc.vpc.id
}

# Created ingress rule for all traffic from Lambda to RDS
resource "aws_vpc_security_group_ingress_rule" "allow-lambda-to-rds" {
  security_group_id            = aws_security_group.allow-lambda-to-rds.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.allow-rds-to-lambda.id
}
```

These resources define a security group named `rds-lambda-connect` to facilitate inbound traffic from the Lambda function to the RDS instance. An ingress rule is created to allow TCP traffic on port 3306 (default MySQL port) from the Lambda function's security group, that will be created in the Lambda section, enabling secure communication between the Lambda function and the RDS instance.

This setup ensures that the Lambda function can securely interact with the RDS instance while maintaining network isolation and security.

#### 3.3. RDS Public

Now let's create the RDS instance that will be located in the Public subnets:

```terraform
resource "aws_db_instance" "rds-public" {
  allocated_storage       = 20
  db_name                 = var.db-name
  identifier              = var.rds-public-db-name
  engine                  = "mysql"
  engine_version          = "8.0.35"
  instance_class          = "db.t3.micro"
  username                = var.db-username
  password                = var.db_pass
  parameter_group_name    = "default.mysql8.0"
  skip_final_snapshot     = true
  publicly_accessible     = true
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.public-db-subnet.name
  vpc_security_group_ids  = [aws_security_group.allow-all-traffic.id]
}
```

This resource defines an RDS instance to be located in the Public subnets. It specifies various parameters such as allocated storage, engine type, instance class, and authentication credentials.

The `publicly_accessible` attribute is set to `true`, allowing the RDS instance to be accessible from the internet. However, access to the RDS instance is controlled by the associated security group (`aws_security_group.allow-all-traffic.id`), which governs inbound and outbound traffic to and from the instance.

By locating the RDS instance in the Public subnets and setting it to be publicly accessible, we enable external applications or services to connect to the database over the internet, facilitating broader accessibility as required.

### 4. Lambda Function creation

All configurations related to the creation of the Lambda Functions are organized within the `lambda.tf` file. This modular structure enhances readability and simplifies the management of the infrastructure setup.


#### 4.1. Lambda Layers

Lambda Layers allow you to include additional libraries or dependencies in your Lambda function without increasing its size, promoting code reuse and simplifying package management. In our case, we require the `pymysql` Python library to manipulate MySQL databases within our Lambda functions. To achieve this, we'll create a Lambda Layer containing the `pymysql` library.

The lambda layer file, `python_layer_pymysql.zip`, is stored in the `./lambda/` folder.

```terraform
# Created lambda layer for pymysql Python library
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/lambda/python_layer_pymysql.zip"
  layer_name = "mypymysql"

  compatible_runtimes = ["python3.9"]
}
```

This resource defines a Lambda Layer named "mypymysql" containing the `pymysql` library. It specifies the ZIP file location containing the layer content and the compatible runtime environments, in this case, Python 3.9.

By using Lambda Layers, we ensure that the `pymysql` library is readily available for use across multiple Lambda functions, reducing duplication and simplifying the management of dependencies.

#### 4.2. IAM Role and Policy for Lambda

To enable Lambda functions to interact with other AWS services and resources securely, we need to specify an IAM Role for Lambda and attach relevant policies.

```terraform
# Created role for lambda functions
resource "aws_iam_role" "iam_for_lambda" {
  name               = "RDS-project-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attached VPC management policy to the lambda role
resource "aws_iam_role_policy_attachment" "attach-vpc-policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.vpc-management.arn
}
```

This code defines an IAM role named `RDS-project-lambda-role` for Lambda functions. The role's assume role policy document is specified using a data resource. Additionally, the AWS-managed policy named `AWSLambdaVPCAccessExecutionRole`, which grants Lambda functions access to VPC resources, is attached to the IAM role.

In order to retrieve the necessary information for the IAM role and policy, we utilize data resources in the `main.tf` file:

```terraform
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "vpc-management" {
  name = "AWSLambdaVPCAccessExecutionRole"
}
```

These data resources fetch the IAM policy document for assuming roles by Lambda functions and the AWS-managed policy for VPC access by Lambda functions, respectively.

By configuring the IAM role and policy for Lambda functions in this manner, we ensure that our Lambda functions have the necessary permissions to interact with VPC resources securely.

#### 4.3. Python Code

We will create our Python code for our lambda and store it in the file `lambda_function.py` located inside the folder `./lambda/`

```python
import sys
import logging
import os
import pymysql

rds_host  = os.environ['RDS_ENDPOINT']  # RDS URL Endpoint
name = os.environ['DB_USER']            # DB Admin User to login
password = os.environ['DB_PASSWORD']    # DB Admin password to login
db_name = os.environ['DB_NAME']         # DB name to connect
port = 3306
conn = pymysql.connect(host=rds_host, user=name,password=password,db=db_name,port=port) 


def lambda_handler(event, context):
    """
    This function inserts content into mysql RDS instance
    """
    item_count = 0

    with conn.cursor() as cur:
        cur.execute("create table Employee_test (EmpID  int NOT NULL, Name varchar(255) NOT NULL, PRIMARY KEY (EmpID))")
        cur.execute('insert into Employee_test (EmpID, Name) values(1, "John")')
        cur.execute('insert into Employee_test (EmpID, Name) values(2, "Elizabeth")')
        cur.execute('insert into Employee_test (EmpID, Name) values(3, "Tom")')
        conn.commit()
        cur.execute("select * from Employee_test")
        for row in cur:
            item_count += 1
    return "Added %d items to RDS MySQL table" %(item_count)
```

This Python code is intended to be deployed as a Lambda function. When invoked, it connects to a MySQL RDS instance, creates a table if necessary, inserts some records into the table, and returns the number of items added to the table.


To create the payload ZIP file with the code to be able to attach to our lambda function we have to create the `data archive_file` in the `main.tf` file

```terraform
# Generate a Zip file for the Lambda Function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function_payload.zip"
}
```

This Terraform data resource creates a ZIP file containing the Python code for the Lambda function, making it ready to be deployed as a Lambda function.


#### 4.4. Lambda function for Private RDS

Now, let's create the Lambda function for accessing the Private RDS:

```terraform
resource "aws_lambda_function" "private-lambda" {
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = var.private-lambda-name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  # ENV VARS for Lambda
  environment {
    variables = {
      RDS_ENDPOINT = aws_db_instance.rds-private.address
      DB_USER      = var.db-username
      DB_PASSWORD  = var.db_pass
      DB_NAME      = var.db-name
    }
  }

  vpc_config {
    subnet_ids         = [for subnet_key, subnet_value in aws_subnet.private_subnets : subnet_value.id]
    security_group_ids = [aws_security_group.allow-rds-to-lambda.id]
  }

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}
```


This resource defines a Lambda function for accessing the Private RDS. It specifies various parameters such as the function's source code, runtime environment, and environment variables for securely passing sensitive information such as RDS endpoint, database username, and password.

To enable the Lambda function to access the Private RDS securely, we need to create a security group allowing connection between the Lambda function and the RDS instance:

```terraform
# Create Security Group to allow Connection between Lamda and RDS
resource "aws_security_group" "allow-rds-to-lambda" {
  name        = "lambda-rds-connect"
  description = "Allow outbound traffic from lambda to RDS"
  vpc_id      = aws_vpc.vpc.id
}

# Created ingress rule for all traffic from Lambda to RDS
resource "aws_vpc_security_group_egress_rule" "allow-rds-to-lambda" {
  security_group_id            = aws_security_group.allow-rds-to-lambda.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.allow-lambda-to-rds.id
}
```

These resources define a security group named `lambda-rds-connect` to facilitate outbound traffic from the Lambda function to the RDS instance. An egress rule is created to allow TCP traffic on port 3306 (default MySQL port) from the Lambda function's security group, enabling secure communication between the Lambda function and the RDS instance.

This setup ensures that the Lambda function can securely interact with the Private RDS instance while maintaining network isolation and security.

#### 4.5. Lambda function for Public RDS

For our Lambda function that will manipulate the RDS in the public subnet, we can use the following code. In this case, we don't need to specify any additional security configuration to grant access, as access is already granted through the Security Group created in Section 2.5 Security Group, with the security group called `allow-all-traffic`.

```terraform
resource "aws_lambda_function" "public-lambda" {
  filename      = "${path.module}/lambda/lambda_function_payload.zip"
  function_name = var.public-lambda-name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"

  # ENV VARS for Lambda
  environment {
    variables = {
      RDS_ENDPOINT = aws_db_instance.rds-public.address
      DB_USER      = var.db-username
      DB_PASSWORD  = var.db_pass
      DB_NAME      = var.db-name
    }
  }

  layers = [aws_lambda_layer_version.lambda_layer.arn]
}
```

This resource defines a Lambda function for accessing the Public RDS. It specifies various parameters such as the function's source code, runtime environment, and environment variables for securely passing sensitive information such as RDS endpoint, database username, and password.

By utilizing the Security Group `allow-all-traffic`, inbound traffic from the Lambda function to the RDS instance is facilitated, ensuring secure communication between the Lambda function and the Public RDS instance without the need for additional security configurations. The inbound rule is currently set to allow traffic from the CIDR `0.0.0.0/0`, allowing access from any source IP address. For enhanced security, it is recommended to customize this rule by specifying a narrower IP address range, such as a local IP address range or a specific one, to restrict access to only trusted sources.

