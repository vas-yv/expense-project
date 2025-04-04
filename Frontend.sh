#!/bin/bash

userid=$(id -u)
timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0 | cut -d "." -f1)
logfile=/tmp/$script_name-$timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

validate(){
    if [ $1 -ne 0 ]
    then
        echo "$2..Failed"
        exit 1
    else
        echo "$2..Success"
    fi        
}

if [ $userid -ne 0 ]
then
    echo "user should run root access"
    exit 1
else
     echo "your super user"
fi

dnf install nginx -y &>>$logfile
validate $? "installing nginx"

systemctl enable nginx &>>$logfile
validate $? "enabling nginx"

systemctl start nginx &>>$logfile
validate $? "starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
validate $? "downloading frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip
validate $? "unzipping frontend code"

        