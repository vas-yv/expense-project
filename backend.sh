#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d"." -f1)
logfile=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

validate(){
    if [ $1 -ne 0 ]
    then
        echo "$2..failed"
        exit 1
    else
        echo "$2..success"
    fi    
}

if [ $userid -ne 0 ]
then
    echo "user should run with root access"
    exit 1
else
    echo "super user"
fi

dnf module disable nodejs -y
validate $? "disable existing nodejs"

dnf module enable nodejs:20 -y
validate $? "enabling nodejs 20"

dnf install nodejs -y
validate $? "installing nodejs"

useradd expense
validate $? "creating expense user"

mkdir /app
validate $? "creating app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
validate $? "downloading code"

cd /app
npm install
validate $? "installing dependencies"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service

systemctl daemon-reload
validate $? "daemon reload"

systemctl start backend
validate $? "starting backend"


systemctl enable backend
validate $? "enabling backend"


dnf install mysql -y
validate $? "installing mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pExpenseApp@1 < /app/schema/backend.sql
validate $? "configuring"

systemctl restart backend
validate $? "restarting backend"
