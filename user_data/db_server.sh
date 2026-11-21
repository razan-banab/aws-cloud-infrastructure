#!/bin/bash
set -e

# Database Server Initialization Script

# Install and configure MySQL server
apt update
apt install mysql-server curl -y

# Start and enable MySQL
systemctl enable --now mysql
systemctl is-active --quiet mysql

# Install AWS CLI v2
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
aws --version
# Configure MySQL network access
sed  -i 's/^bind-address[[:space]]*=.*/bind-address = 10.0.3.10/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart and verify MySQL
systemctl restart mysql
systemctl is-active --quiet mysql

# Retrieve database password from AWS SSM Parameter Store
DB_PASSWORD=$(aws ssm get-parameter \
  --name "/cloud-project/database/password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

# Create database and application user
mysql <<EOF
DROP user IF EXISTS ''@'localhost', ''@'%';
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS app_db;
CREATE USER IF NOT EXISTS 'web_user'@'10.0.2.10'
IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON app_db.* TO 'web_user'@'10.0.2.10';

FLUSH PRIVILEGES;
EOF
systemctl is-active --quiet mysql
