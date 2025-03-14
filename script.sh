#!/bin/bash
yum update -y
yum install -y httpd php php-mysqlnd
systemctl enable httpd
systemctl start httpd

# Test PHP page
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Database connection settings
db_host="192.168.1.21"
db_user="Lucas"
db_pass="P@$$W0RD"
db_name="HA-WEB"

# Create a test PHP page to connect to the database
cat > /var/www/html/db_test.php <<EOL
<?php
\$conn = new mysqli("$db_host", "$db_user", "$db_pass", "$db_name");
if (\$conn->connect_error) {
die("Connection failed: " . \$conn->connect_error);
}
echo "Connected to MySQL successfully!";
\$conn->close();
?>
EOL

