#!/bin/bash

# Important Please pay attention!

# In order to run this code file, please provide all the details in the config.py file

# First, clone the github repo on the target server and change config.py file

# Run the following things on the target website servers

sudo apt-get update
sudo apt-get install python3 python3-pip
# sudo apt-get install python3-pip -y -qq > /dev/null
sudo pip3 install flask pymysql boto3
git clone https://github.com/SambhuBiswakarma00/EQ-AWS-CP.git
cd EQ-AWS-CP
sudo python3 app.py
