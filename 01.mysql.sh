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

dnf install mysql -y
validate $? "installing mysql"

systemctl enable mysqld
validate $? "eabling mysql service"

systemctl start mysqld
validate $? "starting mysql service"

mysql_secure_installation --set-root-pass ExpenseApp@1
validate $? "password setting"