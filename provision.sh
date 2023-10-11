
#!/bin/bash

# Provisioning the Master node
echo "Provisioning the Master node..."
vagrant up master

# Provisioning the Slave node
echo "Provisioning the Slave node..."
vagrant up slave

# User Management on the Master node
echo "Creating user 'altschool' on the Master node..."
vagrant ssh master -c "sudo useradd -m altschool"
vagrant ssh master -c "sudo usermod -aG sudo altschool"

# Inter-node Communication
echo "Setting up SSH key-based 
authentication..."
vagrant ssh master -c "ssh-keygen -t rsa -N '' -f /home/altschool/.ssh/id_rsa"
vagrant ssh slave -c "sudo mkdir -p /home/altschool/.ssh"
vagrant ssh slave -c "sudo bash -c 'echo \"`vagrant ssh master -c 'cat /home/altschool/.ssh/id_rsa.pub'`\" >> /home/altschool/.ssh/authorized_keys'"

# Data Management and Transfer
echo "Copying files from Master to Slave..."
vagrant ssh master -c "sudo cp -R /mnt/altschool /mnt/altschool/slave"

# Process Monitoring on the Master node
echo "Displaying process overview on the Master node..."
vagrant ssh master -c "top"

# LAMP Stack Deployment on both nodes
echo "Installing the LAMP stack on the Master node..."
vagrant ssh master -c "sudo apt-get update && sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql"

echo "Installing the LAMP stack on the Slave node..."
vagrant ssh slave -c "sudo apt-get update && sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql"

echo "Configuring Apache to start on boot..."
vagrant ssh master -c "sudo systemctl enable apache2"
vagrant ssh slave -c "sudo systemctl enable apache2"

echo "Securing MySQL installation..."
vagrant ssh master -c "sudo 

mysql_secure_installation"

echo "Validating PHP functionality..."
vagrant ssh master -c "echo '<?php phpinfo(); ?>' | sudo tee /var/www/html/info.php"

echo "Deployment complete!"