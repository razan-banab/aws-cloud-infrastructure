#!/bin/bash
set -e

# App Server Initialization Script

# Install and configure Apache, PHP, and required dependencies

apt update
apt install apache2 php libapache2-mod-php php-mysql php-mbstring git curl -y

systemctl enable --now apache2
systemctl is-active --quiet apache2

# Install AWS CLI v2
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
aws --version

#Retrieve DB password from SSM
DB_PASSWORD=$(aws ssm get-parameter \
  --name "/cloud-project/database/password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

#Create /var/www/db-config
cat > /var/www/db-config <<EOF
<?php
\$servername = "10.0.3.10";
\$username = "web_user";
$password = '${DB_PASSWORD}';
\$dbname = "app_db";

EOF
