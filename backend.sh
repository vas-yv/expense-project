#!/bin/bash

source ./comman.sh

check_root

echo "please enter DB password:"
read -s mysql_root_password

dnf module disable nodejs -y &>>$logfile
#validate $? "disable existing nodejs"

dnf module enable nodejs:20 -y &>>$logfile
#validate $? "enabling nodejs 20"

dnf install nodesdjs -y &>>$logfile
#validate $? "installing nodejs"

id expense &>>$logfile
if [ $? -ne 0 ]
then 
    useradd expense &>>$logfile
    #validate $? "creating expense user"
else
     echo -e "user already created..$Y skipping $N"
fi         

mkdir -p /app 
#validate $? "creating app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$logfile
#validate $? "downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$logfile
#validate $? "unzip backend code"

npm install &>>$logfile
#validate $? "installing dependencies"

cp /home/ec2-user/expense-project/backend.service /etc/systemd/system/backend.service

systemctl daemon-reload &>>$logfile
#validate $? "daemon reload"

systemctl start backend &>>$logfile
#validate $? "starting backend"


systemctl enable backend &>>$logfile
#validate $? "enabling backend"


dnf install mysql -y &>>$logfile
#validate $? "installing mysql"

mysql -h 172.31.20.212 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$logfile
#validate $? "configuring"

systemctl restart backend &>>$logfile
#validate $? "restarting backend"
