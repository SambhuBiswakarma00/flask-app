import os
import boto3

# Initialize Boto3 client for Systems Manager
ssm = boto3.client('ssm', region_name='your_region')

# Function to retrieve database password from Parameter Store
def get_db_password():
    try:
        # Retrieve database password from Parameter Store
        response = ssm.get_parameter(Name='rds-db-password', WithDecryption=True)
        db_password = response['Parameter']['Value']
        return db_password
    except Exception as e:
        print(f"Error retrieving database password: {e}")
        return None


custombucket = "sambhubucket"
table = "users"
# key_id = " "
# access_key = ""
databasehost = os.environ.get('RDS_HOST')
duser = "admin"
dpass = get_db_password()
s3database = "mydatabase"
dynamoDB_table = "My_Table"
# kapp = "http://3.228.220.21/"

print("host: {}, pass: {}".format(databasehost, dpass))
