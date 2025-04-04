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
        echo -e " $2 .. $R failed $N"
        exit 1
    else
        echo -e " $2 .. $G success $N"
    fi        
}    


if [ $userid -ne 0 ]
then
    echo -e "$R user run with root access"
    exit 1
else
    echo -e "$G you are super user"
fi

dnf install mysql-server -y &>>$logfile
validate $? "installing mysql server"

systemctl enable mysqld &>>$logfile
validate $? "eabling mysql server"

systemctl start mysqld &>>$logfile
validate $? "starting mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$logfile
#validate $? "root password setting up"

#below code will be useful for idempotent nature
mysql -h db.daws78s.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$logfile
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$logfile
    validate $? "mysql root password setup"
else
    echo -e "Mysql Root password is already setup...$Y Skipping $N"
fi