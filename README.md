# Serverless RDS Management

## Overview

In this project, we develop a serverless data analysis platform using AWS services. The platform enables Lambda functions to seamlessly access and process data from both public and private Amazon RDS databases. 

The key components and features of the project include:

- **Serverless Architecture:** Use of AWS Lambda for serverless compute
- **Data Access and Processing:** Enable Lambda functions to interact with both a public and a private Amazon RDS database
- **VPC Configuration:** Use of VPC configuration with Public and Private subnets, to test how lambda interacts with each one

<br>

## Architecture Diagram

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/ec397176-ac71-4970-966b-aab030f262b9)

<br>

## Services Used

| AWS Service | Quantity | Names |
| ------------| :------: | ----- |
| VPC | 1 | RDS-project-vpc |
| Subnet | 4 | RDS-project-subnet-public1-us-east-1a<br>RDS-project-subnet-private1-us-east-1a<br>RDS-project-subnet-public2-us-east-1b<br>RDS-project-subnet-private2-us-east-1b |
| Route table | 3 | RDS-project-rtb-public<br>RDS-project-rtb-private1-us-east-1a<br>RDS-project-rtb-private2-us-east-1b |
| VPC Security Group | 1 | rds-public-security-group |
| Internet Gateway | 1 | RDS-project-igw |
| DB Subnet Group | 2 | rds-private-subnet<br>rds-public-subnet |
| RDS | 2 | rds-db-private<br>rds-db-public |
| Lambda Function | 2 | rds-private-lambda<br>rds-public-lambda |

<br>

## Technology Stack

The project leverages a combination of tools and technologies to achieve its goals. The key technologies used include:

<p align="center"> <a href="https://aws.amazon.com" target="_blank" rel="noreferrer"> <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/2560px-Amazon_Web_Services_Logo.svg.png" alt="aws" width="80"/> </a> <a href="https://www.terraform.io/" target="_blank" rel="noreferrer"> <img src="https://www.datocms-assets.com/2885/1620155116-brandhcterraformverticalcolor.svg" alt="terraform" width="80"/> </a> <a href="https://www.python.org/" target="_blank" rel="noreferrer"> <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Python-logo-notext.svg/1869px-Python-logo-notext.svg.png" alt="python" width="70"/> </a> </p>



- **AWS Console:** Used for manual setup and configuration of AWS resources.
- **Terraform:** Employed for Infrastructure as Code (IaC) to provision and manage AWS resources.
- **Python:** Utilized for scripting the code for the Lambda Function.

<br>

## Budget

The services used on this lab are under the Free Tier, but if your Free Tier ended then the reference prices are the following:


| AWS Service | Price | Documentation |
| ------------| ------ | ------------ |
| RDS Single AZ | $0.017 per Hour | [AWS RDS Pricing](https://aws.amazon.com/rds/mysql/pricing) |
| RDS Storage | $0.115 per Gb/month | [AWS RDS Pricing](https://aws.amazon.com/rds/mysql/pricing) |
| Lambda | Free  | [AWS Lambda Pricing](https://aws.amazon.com/lambda/pricing/) |

<br>

## Lab Deployment


### 1. VPC and Network Components

From the AWS Console, we create the VPC with the option `VPC and more`, in this way the VPC will assist on the creation of Subnets, Route tables, and Internet gateway. For this lab it is OK, but if you want to control the CIDR assignation then you can create separately each component.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/0e9a49ce-7ef6-49bf-866e-d1c1e2586e9b)

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/0128effc-2a6c-4e73-b0f7-0554882a465b)

### 2. Amazon RDS


To create the RDS, AWS requests the creation of a DB subnet group, and to create this last one it is needed at least 2 AZ.

In the Amazon RDS console look for `Subnet groups`. You need to assign the name, a brief description, assign the VPN, the AZ, and the subnets.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/bfe54f1b-b89b-4fc7-bd0a-19c420a88543)

#### 2.1 RDS in Private Subnet

During the creation of your RDS, for this lab we selected the following options: 

- **Creation method:** Standard create
- **Engine type:** MySQL
- **Templates:** Free Tier
-  **DB instance identifier:** rds-db-private
-  **Credential Settings:**
	- **Master User Name:** admin
	- **Master Password:** "Your chosen password"
- **Connectivity:**
	- **VPC:** RDS-project-vpc
	- **DB subnet group:** rds-private-subnet
	- **Public access:** No
- **Additional configuration (expand)**
	- **Initial database name:** rdstest
	- **Automated Backups:** disable

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/36ebc44a-82e8-48df-b108-cc815e5585e9)


#### 2.2 RDS in Public Subnet

During the creation of your RDS, for this lab we selected the following options: 

- **Creation method:** Standard create
- **Engine type:** MySQL
- **Templates:** Free Tier
-  **DB instance identifier:** rds-db-public
-  **Credential Settings:**
	- **Master User Name:** admin
	- **Master Password:** "Your chosen password"
- **Connectivity:**
	- **VPC:** RDS-project-vpc
	- **DB subnet group:** rds-public-subnet
	- **Public access:** Yes
	- **VPC security group (firewall):** Create new
		- **New VPC security group name:** rds-public-security-group
- **Additional configuration (expand)**
	- **Initial database name:** rdstest
	- **Automated Backups:** disable

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/ef87ef8d-0ad1-4b5e-9124-53003a958b44)

### 3. Lambda Function

#### Lambda Layers

We need to use the Python library `pymysql`, which is a Python library that provides an interface to connect and interact with MySQL databases. To use this Python library inside our lambda we need to use Lambda Layers.

[PyMySQL documentation](https://pymysql.readthedocs.io/en/latest/)

To create the layer we can use Cloudshell inside the AWS console. We have to verify the Python version in the cloudshell with the command `python --version`. In my case the version was 3.9.16, so i had to change the Runtime setting from 3.12 to 3.9 to match the versions and avoid any conflicts.

Then we proceed with the following steps to create the Layer and use it:

- **Create a Layer Package:** Create a directory for your layer and install pymysql into that directory

	```bash
    mkdir python
    pip3 install --target ./python pymysql
    ```

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/9da558d1-0d27-485c-b653-7db4abad1ebe)

- **Create the Zip file for the layer:**
  	
	```bash
	zip -r python_layer_pymysql python
  ```

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/19dad1d8-8da2-43f8-aad3-e9d0d982e3b7)

- **Download the zip file:** Inside the cloudshell windows just verify your current directory with the command `pwd` and download the file from that directory

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/4376733f-1236-496c-9454-4c61d1cf3230)
![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/23b05519-19c0-4237-931a-c02d7462eb37)


- **Create a Lambda Layer:** In your AWS Lambda console you will see the `Layer` option on the left menu. Create a new Layer and Upload the `python_layer_pymysql.zip` file as a new Lambda Layer using the AWS Console

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/240965d3-d0d2-4637-823f-d51dae52b66d)

#### Lambda Creation

Proceed to the Lambda service in your console and create a New Lambda Function from Scratch. In this lab, we will use a Python code, so we selected Python 3.9 in the Runtime to maintain the version used for the Lambda Layer created in the previous step.

We created two Lambda functions for testing purposes, one to interact with Private RDS and the other to interact with Public RDS.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/a9117ac8-ceb9-4118-a0e0-3cdbf11ce6bf)

**Let's add the following Python Code to the Lambda Function:**

``` python
import sys
import logging
import os
import pymysql

rds_host  = os.environ['RDS_ENDPOINT'] 	# RDS URL Endpoint
name = os.environ['DB_USER']			# DB Admin User to login
password = os.environ['DB_PASSWORD']	# DB Admin password to login
db_name = os.environ['DB_NAME']			# DB name to connect
port = 3306
conn = pymysql.connect(host=rds_host, user=name,password=password,db=db_name,port=port) 


def lambda_handler(event, context):
    """
    This function inserts content into mysql RDS instance
    """
    item_count = 0

    with conn.cursor() as cur:
        cur.execute("create table Employee_test (EmpID  int NOT NULL, Name varchar(255) NOT NULL, PRIMARY KEY (EmpID))")
        cur.execute('insert into Employee_test (EmpID, Name) values(1, "Joe")')
        cur.execute('insert into Employee_test (EmpID, Name) values(2, "Bob")')
        cur.execute('insert into Employee_test (EmpID, Name) values(3, "Mary")')
        conn.commit()
        cur.execute("select * from Employee_test")
        for row in cur:
            item_count += 1
    return "Added %d items to RDS MySQL table" %(item_count)
```

In this Python code, we used the Environment Variables to avoid exposing sensitive information. AWS Lambda supports environment variables, and you can use them to store sensitive data or configuration that your code can access at runtime, in this way, any sensitive data is not hard-coded into your source files.

The way to use the Lambda Env Vars in this lab is with the following code snippet:

```python
import os

rds_host  = os.environ['RDS_ENDPOINT']
name = os.environ['DB_USER']
password = os.environ['DB_PASSWORD']
db_name = os.environ['DB_NAME']
```

These ENV VARS are predefined in the Environment Variable section inside the Lambda Configuration Tab.


#### Attaching Lambda Layer to the Lambda Function

To execute the SQL command used in the Python code you need to proceed to attach the Lambda Layer to use the Python library needed. In the AWS Lambda Management Console, navigate to your Lambda function. In the "Function code" section, you'll find the "Layers" configuration at the bottom. Add a layer and select the pymysql layer that was created.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/15b18ec4-47cb-47f1-9cbc-09be12b99a24)

<br>

## Lab Testing

### Private RDS Test

If you test your lambda it fails to connect to the RDS in the private subnet because your lambda is not in the same VPC and Private Subnet.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/7f6b53f3-328e-4b7b-9fc4-ba8e9b7dc827)

### Public RDS with Private Lambda Test

Using the Lambda Function that has a connection to the VPC, and modifying the Environment Variable `RDS_ENDPOINT` the lambda can connect to the RDS.


![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/6311ba1f-9144-4d96-a14d-b0fc88b011cf)

### Public RDS with Public Lambda

Using the `rds-public-lambda` function, the test fails to connect to the RDS because there are no permissions for the inbound traffic 

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/6eae00d8-878d-4aeb-a6c4-c786346bb0b5)

<br>

## Troubleshooting

### Private RDS

There are 2 ways to fix or avoid this issue when the Lambda function is not in the same VPC:

1. **Create RDS database connection:** Inside your lambda you need to go to the configuration tab, in the RDS database section, from there you can create the connection to the RDS database

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/c8597dd1-f60c-47b9-a5c7-fc1ca07a56a6)

2. **During Lambda creation:** During the lambda creation you can expand the `Advanced Settings` and select `Enable VPC` and choose your VPC, your private subnets and the default security group.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/a78e9185-786d-4f07-9f10-f18c1fa696f2)

### Public RDS

We need to edit the VPC security group created for this RDS to add an inbound rule to allow `All IPv4 traffic`. In this way, we allow the Lambda function to access the RDS Public

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/40aa8f84-102c-4a95-802e-86ec91211e5e)

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/7142bb8c-d229-47e8-b940-043882233cb9)

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/f30456a3-dcc2-4060-9a72-2885097d6c56)

<br>

## Clean Up

- Delete VPC and all subcomponents
- Delete VPC security group
- Delete RDS Public and Private
- Delete DB Subnet Groups
- Delete Lambda Functions
- Delete IAM Roles for RDS



