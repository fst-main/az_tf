#!/bin/bash
# Update and upgrade OS
sudo yum update -y && sudo yum upgrade -y
sudo yum clean all

### JAVA/JDK ###

sudo yum install java-1.8.0-openjdk -y
sudo yum install java-1.8.0-openjdk-devel -y

#Setting user group variable, according with the executant user. 

user_group=$(cat /etc/passwd | grep home | head -1 | awk -F : '{print $1}')
export -n user_group

# Postgresql CORE ###
#Install pack

install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
install -y postgresql14-server

#Initalialize DB, make persistent and enable the service
/usr/pgsql-14/bin/postgresql-14-setup initdb
systemctl enable postgresql-14
systemctl start postgresql-14
yes

#create and set-up database
sudo -u postgres -I;psql; sleep 2;\
CREATE USER jiradbuser PASSWORD 'jiradbpassword';\
CREATE DATABASE jiradb WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;\
GRANT ALL PRIVILEGES ON DATABASE jiradb to jiradbuser; \q

#Configure authentication methods
sudo -u postgres -i; \
sed -i "s/host    all             all             127.0.0.1/32            ident/host    all             all             127.0.0.1/32            md5/g"\
 /var/lib/pgsql/9.6/data/pg_hba.conf


# JIRA CORE ###
# Get bin file

sudo mkdir /opt/atlassian
sudo wget -c https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-7.3.0-x64.bin -P /opt/atlassian/

#Make it executable and run it

cd /opt/atlassian/
sudo chmod +x atlassian-jira-software-7.3.0-x64.bin
./atlassian-jira-software-7.3.0-x64.bin -q -varfile response.varfile