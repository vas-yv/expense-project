#!/bin/bash

source ./comman.sh
check_root

echo "please enter DB password:"
read -s mysql_root_password

dnf install mysql-server -y &>>$logfile
validate $? "installing mysql server"

systemctl enable mysqld &>>$logfile
validate $? "eabling mysql server"

systemctl start mysqld &>>$logfile
validate $? "starting mysql server"

mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$logfile
validate $? "root password setting up"

#below code will be useful for idempotent nature
#mysql -h db.daws78s.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$logfile
#if [ $? -ne 0 ]
#then
#    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$logfile
#    validate $? "mysql root password setup"
#else
#    echo -e "Mysql Root password is already setup...$Y Skipping $N"
#fi