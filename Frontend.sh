#!/bin/bash

source ./comman.sh
check_root

dnf install nginx -y &>>$logfile
#validate $? "installing nginx"

systemctl enable nginx &>>$logfile
#validate $? "enabling nginx"

systemctl start nginx &>>$logfile
#validate $? "starting nginx"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$logfile
#validate $? "downloading frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$logfile
#validate $? "unzipping frontend code"

cp /home/ec2-user/expense-project/expense.conf /etc/nginx/default.d/expense.conf
#validate $? "configuring frontcode with backed p ip add"

systemctl restart nginx &>>$logfile
#validate $? "restarting nginx"