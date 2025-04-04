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
        echo -e "$2..$R Failed $N"
        exit 1
    else
        echo -e "$2..$G Success $n"
    fi        
}

if [ $userid -ne 0 ]
then
    echo -e "$R user should run root access"
    exit 1
else
     echo -e "$G your super user"
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

unzip /tmp/frontend.zip &>>$logfile
validate $? "unzipping frontend code"

cp /home/ec2-user/expense-project/expense.conf /etc/nginx/default.d/expense.conf
validate $? "configuring frontcode with backed p ip add"

systemctl restart nginx &>>$logfile
validate $? "restarting nginx"