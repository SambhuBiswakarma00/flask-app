#!/bin/bash

# Important Please pay attention!

# In order to run this code file, please provide all the details in the config.py file

# First, clone the github repo on the target server and change config.py file

# Run the following things on the target website servers

# sudo apt-get update
sudo touch test.txt
# run this below command before installing the pip, this will supress the prompt for the service restart otherwise we need to manually interact with that prompt
sudo sed -i "s/#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/g" /etc/needrestart/needrestart.conf 
sudo apt-get install python3 python3-pip -y
sudo pip3 install flask pymysql boto3
# git clone https://github.com/SambhuBiswakarma00/flask-app-aws.git
# cd flask-app-aws/app
# sudo python3 app.py
sudo apt install apache2 -y
