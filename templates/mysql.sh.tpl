#!/bin/bash

echo "Updating package lists..."
sudo apt-get update -y

# Install MySQL server
echo "Installing MySQL server..."
sudo apt-get install -y mysql-server

# Start MySQL service
echo "Starting MySQL service..."
sudo systemctl start mysql
systemctl enable mysql

# Allow remote connections by updating bind-address
echo "Configuring MySQL to allow remote connections..."
sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql

# Create a MySQL user for remote connections (no password)
echo "Creating MySQL user for remote access..."
mysql -e "CREATE USER 'appuser'@'%' IDENTIFIED BY '';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'appuser'@'%';"
mysql -e "FLUSH PRIVILEGES;"

echo "MySQL installation and VPC-access setup completed!"
