#!/bin/bash
set -e

# Database Server Initialization Script

# Configure Ubuntu repositories to use HTTPS
sed -i 's|http://eu-north-1a.clouds.ports.ubuntu.com/ubuntu-ports/|https://ports.ubuntu.com/ubuntu-ports/|g' /etc/apt/sources.list.d/ubuntu.sources

sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://ports.ubuntu.com/ubuntu-ports|g' /etc/apt/sources.list.d/ubuntu.sources

# Install and configure MySQL server
apt update
apt install mysql-server curl unzip -y

# Start and enable MySQL
systemctl enable --now mysql
systemctl is-active --quiet mysql

# Install AWS CLI v2
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
/root/.local/bin/aws --version
# Configure MySQL network access
sed  -i 's/^bind-address[[:space:]]*=.*/bind-address = 10.0.3.10/' /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart and verify MySQL
systemctl restart mysql
systemctl is-active --quiet mysql

# Retrieve database password from AWS SSM Parameter Store
DB_PASSWORD=$(/root/.local/bin/aws ssm get-parameter \
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

GRANT SELECT, INSERT, UPDATE, DELETE
ON app_db.* TO 'web_user'@'10.0.2.10';

USE app_db;

CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL
);

FLUSH PRIVILEGES;
EOF
systemctl is-active --quiet mysql
