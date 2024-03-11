# Serverless RDS Management

## Overview

In this project, we develop a serverless data analysis platform using AWS services. The primary objective is to empower Lambda functions to effortlessly access and process data from both public and private Amazon RDS databases. 

The key components and features of the project include:

- **Serverless Architecture:** Leveraging AWS Lambda for efficient serverless compute capabilities.
- **Data Access and Processing:** Facilitating seamless interaction between Lambda functions and both public and private Amazon RDS databases. This ensures a versatile data processing environment.
- **VPC Configuration:** Implementation of VPC configuration with distinct Public and Private subnets. This configuration is designed to evaluate and optimize Lambda interactions with each subnet, providing a comprehensive testing ground.

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

To set up the VPC and associated network components, we utilize the AWS Console with the `VPC and more` option. This streamlined approach automates the creation of essential elements such as Subnets, Route tables, and Internet gateways. While this method is suitable for our lab purposes, for more precise control over CIDR assignment, individual components can be created separately.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/0e9a49ce-7ef6-49bf-866e-d1c1e2586e9b)

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/0128effc-2a6c-4e73-b0f7-0554882a465b)

### 2. Amazon RDS


When setting up Amazon RDS, AWS mandates the creation of a DB subnet group. To accomplish this, a minimum of 2 Availability Zones (AZ) is required.

Here's a step-by-step guide within the Amazon RDS console:

- Navigate to "Subnet groups" in the Amazon RDS console.
- Assign a distinctive name and provide a brief description for the DB subnet group.
- Specify the Virtual Private Cloud (VPC).
- Choose at least 2 Availability Zones (AZ) for optimal redundancy.
- Allocate the appropriate subnets to the DB subnet group.


By following these steps, you ensure the proper configuration of the DB subnet group, laying a solid foundation for the deployment of Amazon RDS within our serverless data analysis platform. 

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/bfe54f1b-b89b-4fc7-bd0a-19c420a88543)

#### 2.1 RDS in Private Subnet

During the RDS creation process, we have opted for specific configurations tailored to the needs of this lab:

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
	- **Initial database name:** rds_db
	- **Automated Backups:** disable

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/36ebc44a-82e8-48df-b108-cc815e5585e9)

By adhering to these specifications, we establish a secure RDS instance in a private subnet, minimizing exposure to the public network. Adjustments can be made based on specific project requirements or security considerations.

#### 2.2 RDS in Public Subnet

Throughout the creation of the RDS instance tailored for this lab, we've chosen the following options:  

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
	- **Initial database name:** rds_db
	- **Automated Backups:** disable

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/ef87ef8d-0ad1-4b5e-9124-53003a958b44)

By configuring the RDS instance with these settings, we ensure accessibility from the public network while maintaining security through the specified VPC and associated security group that can narrow down the access as needed.

### 3. Lambda Function

#### Lambda Layers

AWS Lambda Layers are like organized zip files that store additional code or data separately from your main function code. They are beneficial for keeping deployment packages small by isolating dependencies, allowing independent updates for function code and dependencies. Layers promote code reusability across multiple functions, simplify package management by isolating large dependencies, and facilitate the use of the Lambda console code editor. In essence, they optimize code deployment by addressing Lambda's size limitations, making updates more efficient and reducing redundancy in serverless applications.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/2fc6169c-8012-4b43-89f8-2d5b6a5eb09c)


To incorporate the Python library `pymysql` (to facilitate connectivity with MySQL databases), into our Lambda function, we leverage Lambda Layers.

Refer to the [PyMySQL documentation](https://pymysql.readthedocs.io/en/latest/) for comprehensive details on the library.

To initiate the Layer creation process, follow these steps within the AWS CloudShell:

- **Verify Python version:**
	- Execute `python --version` to confirm the Python version in CloudShell.
	- Adjust the Lambda function's runtime settings to match this version (e.g., changing from 3.12 to 3.9) to prevent version conflicts.

Then we proceed with the following steps to create the Layer and use it:

- **Create a Layer Package:** 
	- Establish a directory for the layer (e.g., python).
	- Install `pymysql` into the designated directory using:
<br>

	```bash
    mkdir python
    pip3 install --target ./python pymysql
    ```

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/9da558d1-0d27-485c-b653-7db4abad1ebe)

- **Create the Zip file for the layer:**
	- Execute the following command to create a Zip file for the layer:
<br>

	```bash
	zip -r python_layer_pymysql python
  	```

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/19dad1d8-8da2-43f8-aad3-e9d0d982e3b7)

- **Download the zip file:** 
	- Verify the current directory using `pwd` in CloudShell.
	- Download the created Zip file from the identified directory.


![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/4376733f-1236-496c-9454-4c61d1cf3230)
![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/23b05519-19c0-4237-931a-c02d7462eb37)


- **Create a Lambda Layer:** 
	- Within the AWS Lambda console, locate the `Layer` option in the left menu.
	- Initiate the creation of a new Layer and upload the `python_layer_pymysql.zip` file as a new Lambda Layer using the AWS Console.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/240965d3-d0d2-4637-823f-d51dae52b66d)

#### Lambda Creation

Navigate to the Lambda service in your AWS console and initiate the creation of a new Lambda Function from Scratch. Given that our chosen runtime for the Lambda Layer in the previous step is Python 3.9, ensure consistency by selecting Python 3.9 as the runtime for the Lambda function.

In this lab, we have developed two Lambda functions for testing purposes: one designed to interact with a Private RDS and the other intended for interaction with a Public RDS.

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

To enable the execution of SQL commands within your Python code, it's crucial to attach the Lambda Layer containing the necessary Python library. Follow these steps in the AWS Lambda Management Console:

1. Navigate to your Lambda function.
2. In the "Function code" section, locate the "Layers" configuration at the bottom.
3. Add a new layer and select the `pymysql` layer created in the previous steps.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/15b18ec4-47cb-47f1-9cbc-09be12b99a24)

<br>

## Lab Testing

### Private RDS test with Private Lambda

When testing the lambda, it fails to connect to the RDS in the private subnet due to the lambda not being in the same VPC and private subnet.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/7f6b53f3-328e-4b7b-9fc4-ba8e9b7dc827)


### Public RDS test with Public Lambda

For the `rds-public-lambda` function, the test fails to connect to the RDS due to insufficient permissions for inbound traffic. 

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/6eae00d8-878d-4aeb-a6c4-c786346bb0b5)

<br>

## Troubleshooting

### Private RDS

When encountering issues with the Lambda function not being in the same VPC as the RDS, consider the following two solutions:

1. **Create RDS database connection:**  Inside your Lambda function's configuration tab, navigate to the RDS database section. Here, you can establish a connection to the RDS database.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/c8597dd1-f60c-47b9-a5c7-fc1ca07a56a6)

2. **During Lambda creation:** During the lambda creation you can expand the `Advanced Settings` and select `Enable VPC` and choose your VPC, your private subnets, and the default security group.

![image](https://github.com/cristobalgrau/aws-serverless-rds-management-lab/assets/119089907/a78e9185-786d-4f07-9f10-f18c1fa696f2)

### Public RDS

To resolve issues with accessing the Public RDS, edit the VPC security group associated with the RDS. Add an inbound rule to allow `All IPv4 traffic`, enabling the Lambda function to access the RDS publicly.

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



