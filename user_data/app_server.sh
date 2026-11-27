#!/bin/bash
set -e

# App Server Initialization Script

# Configure Ubuntu repositories to use HTTPS
sed -i 's|http://eu-north-1a.clouds.ports.ubuntu.com/ubuntu-ports/|https://ports.ubuntu.com/ubuntu-ports/|g' /etc/apt/sources.list.d/ubuntu.sources

sed -i 's|http://ports.ubuntu.com/ubuntu-ports|https://ports.ubuntu.com/ubuntu-ports|g' /etc/apt/sources.list.d/ubuntu.sources

# Install and configure Apache, PHP, and required dependencies

apt update
apt install apache2 php libapache2-mod-php php-mysql php-mbstring git curl unzip -y

systemctl enable --now apache2
systemctl is-active --quiet apache2

# Deploy application from GitHub
if [ -d /tmp/aws-cloud-infrastructure/.git ]; then
    git -C /tmp/aws-cloud-infrastructure pull --ff-only origin master
else
    git clone -b master https://github.com/razan-banab/aws-cloud-infrastructure.git /tmp/aws-cloud-infrastructure
fi

cp -r /tmp/aws-cloud-infrastructure/app/. /var/www/html/

cp -r /tmp/aws-cloud-infrastructure/app/. /var/www/html/

# Install AWS CLI v2
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
/root/.local/bin/aws --version

#Retrieve DB password from SSM
DB_PASSWORD=$(/root/.local/bin/aws ssm get-parameter \
  --name "/cloud-project/database/password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text)

#Create /var/www/db-config
cat > /var/www/db-config <<EOF
<?php
\$servername = "10.0.3.10";
\$username = "web_user";
\$password = '${DB_PASSWORD}';
\$dbname = "app_db";
EOF

chown root:www-data /var/www/db-config
chmod 640 /var/www/db-config
