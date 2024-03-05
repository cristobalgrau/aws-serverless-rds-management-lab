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