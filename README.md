# HighAvailabilityWebDB
High Availability Webserver and Database on AWS EC2 with Auto Scaling Group

# High Availability Webserver & Database on AWS EC2

This project demonstrates how to set up a highly available webserver and database (MySQL) architecture on AWS EC2 instances, without relying on managed services like RDS. This setup includes webserver monitoring.

## Overview

This architecture aims to provide a robust and scalable solution for hosting web applications and databases on AWS. By using only EC2 instances, it offers greater control and a deeper understanding of the underlying infrastructure.

## Prerequisites

-   An AWS account with permissions to create EC2 instances, VPCs, Security Groups, Auto Scaling Groups, and Launch Templates.

## Architecture

The architecture consists of the following components:

-   **VPC:** A Virtual Private Cloud (VPC) with public and private subnets.
    -   **Public Subnets:** Host the webserver instances.
    -   **Private Subnets:** Host the database instances.
-   **Webservers:** Apache webservers hosted on EC2 instances in the public subnets. These servers run the PHP application.
-   **Database:** A MySQL database hosted on an EC2 instance in the private subnet.
-   **Security Groups:** Control access to the EC2 instances.
-   **Auto Scaling Group (ASG):** Automatically scales the number of webserver instances based on demand.
-   **Launch Template:** Defines the configuration for the webserver instances launched by the ASG.
-   **Load Balacer:** Configure to distribute incoming traffic across multiple webserver instances in different Availability Zones, enhancing high availability and scalability.
-   **NAT Gateway :** Allows the database instance in the private subnet to access the internet for updates and package installations.
-   **Bastion Host :** Provides secure access to the database instance in the private subnet.

## Implementation Steps

### 1. VPC Setup

1.  Create a VPC with two public subnets and two private subnets.
2.  Name the VPC ("HA-WEB-VPC").

### 2. Database Setup

1.  Launch an EC2 instance in one of the private subnets.
2.  **Configure a NAT Gateway :**
    *   Create a NAT Gateway in one of the public subnets and assign an Elastic IP to it.
    *   Update the route table associated with the private subnet to route internet traffic through the NAT Gateway.
3.  **Connect to the Database Instance:**
    *   Use the bastion host to SSH into the database instance.
4.  **Install and Configure MySQL:**

    ```
    sudo su - root
    yum install mariadb105-server -y
    systemctl start mariadb105
    systemctl enable mariadb105
    mysql_secure_installation 
    ```
5. Create a database and user for the web application:

    ```
    CREATE DATABASE HA-WEB;
    CREATE USER 'Lucas'@'%' IDENTIFIED BY 'P@$$W0RD';
    GRANT ALL PRIVILEGES ON HA-WEB.* TO 'Lucas'@'%';
    FLUSH PRIVILEGES;
    ```

### 3. Webserver Setup

1.  **Create a Launch Template:**
    *   Navigate to the EC2 service in the AWS console and click on "Launch Templates", then click on “Create Launch Template”.
    *   Provide a name for the Launch Template.
    *   Select the Launch AMI for the Launch Template.
    *   Select the Instance Type and the key pair.
    *   Select the public subnet of the custom VPC created, & the security group to allow the webserver.
    *   Keep the by-default storage.
    *   Copy the scipt for the **“user data”**, so that the webserver is automatically properly setup/configured in every auto-scaled instance.
    *   Click on **“Create Launch Template”**.
2.  **Create an Auto Scaling Group (ASG):**
    *   Navigate to the EC2 Page, & then click on **“Auto Scaling Groups”**.
    *   Click on **“Create Auto Scaling Group”.**Then give this Auto Scaling Group some name & select the Launch Template & its version.
    *   In the Network Settings, select our custom VPC, & select all the public subnets to ensure High Availability.
    *   Keep the Instance Type Requirements as it is, & click on “Next”.
        Click on **“Create Auto Scaling Group”.**Then give this Auto Scaling Group some name & select the Launch Template & its version.
    *   In the Network Settings, select our custom VPC, & select all the public subnets to ensure High Availability.
    *   Keep the Instance Type Requirements as it is, & click on “Next”.
    *   Keep the **“Desired”, “Minimum”, & “Maximum”**capacity.
    *   For the Scaling Policy, set it at 50% average CPU utilization, which means that if the average CPU utilization of the instances crosses the 50% mark, then 1 new instance will be added (scale-out), & the reverse is true for (scale-out), that is if the average CPU utilization of the instances drops below 50% mark, then an instance will be removed/terminated.
    *   Click on **“Create Auto Scaling Group”.**
3.  **Create an Application Load Balancer (ALB):**
    *   Navigate to the EC2 dashboard and click on Load Balancers.
    *   Choose Create Load Balancer and select Application Load Balancer.
    *   Create Target Group.
    *   Register Target

## Testing the Setup

1.  **Access the Webservers:** Access application using the load balancer's DNS name. Verify that traffic is distributed across multiple instances.
2.  **Test Database Connectivity:** Access the `db_test.php` page (e.g., `http://13.4.65.2/db_test.php`) to verify that the webserver can connect to the MySQL database.
3.  **Test Auto Scaling:** Increase the load on the webservers. Monitor the Auto Scaling Group to ensure that new instances are launched when the CPU utilization exceeds the defined threshold.

