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

dnf module disable nodejs -y &>>$logfile
validate $? "disable existing nodejs"

dnf module enable nodejs:20 -y &>>$logfile
validate $? "enabling nodejs 20"

dnf install nodejs -y &>>$logfile
validate $? "installing nodejs"

id expense
if [ $? -ne 0 ]
then 
    useradd expense &>>$logfile
    validate $? "creating expense user"
else
     echo "user already created..skipping"
fi         

mkdir /app
validate $? "creating app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfile
validate $? "downloading code"

cd /app
npm install &>>$logfile
validate $? "installing dependencies"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service

systemctl daemon-reload &>>$logfile
validate $? "daemon reload"

systemctl start backend &>>$logfile
validate $? "starting backend"


systemctl enable backend &>>$logfile
validate $? "enabling backend"


dnf install mysql -y &>>$logfile
validate $? "installing mysql"

mysql -h 172.31.82.88 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$logfile
validate $? "configuring"

systemctl restart backend &>>$logfile
validate $? "restarting backend"
