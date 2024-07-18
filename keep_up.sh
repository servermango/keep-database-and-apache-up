#!/bin/bash

# Function to check if server responds to HTTP requests
check_server_http_response() {
    local url=$1
    local timeout=$2
    local response_code

    # Use curl to check HTTP response code and handle timeout gracefully
    if response_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout $timeout $url); then
        echo "$url responded with HTTP status code $response_code"
        return 0  # Success
    else
        echo "Failed to connect to $url within $timeout seconds"
        return 1  # Failed
    fi
}

# Function to check MySQL responsiveness and restart if needed
check_mysql_responsiveness() {
    if sudo mysqladmin ping -u root --silent; then
        echo "MySQL is responsive"
    else
        echo "MySQL is not responsive. Attempting to restart..."
        
        # Determine the restart command based on the server type
        if [ -f "/usr/local/cpanel/cpanel" ]; then
            # cPanel server
            systemctl restart mysql
        else
            # Non-cPanel server (assuming Ubuntu with systemd)
            systemctl restart mysql.service
        fi

        # Verify if the restart was successful
        if sudo mysqladmin ping -u root --silent; then
            echo "MySQL has been restarted and is responsive"
        else
            echo "Failed to restart MySQL"
        fi
    fi
}

# Function to check and restart Apache service on cPanel server
check_and_restart_apache_cpanel() {
    echo "Restarting Apache on cPanel server..."
    /scripts/restartsrv httpd
}

# Function to check and restart MySQL service on cPanel server
check_and_restart_mysql_cpanel() {
    echo "Restarting MySQL on cPanel server..."
    /scripts/restartsrv mysql
}

# Function to check and restart Apache service on Ubuntu server
check_and_restart_apache_ubuntu() {
    echo "Restarting Apache on Ubuntu server..."
    systemctl restart apache2
}

# Function to check and restart MySQL service on Ubuntu server
check_and_restart_mysql_ubuntu() {
    echo "Restarting MySQL on Ubuntu server..."
    systemctl restart mysql
}

# Function to detect server type and execute appropriate Apache check function
check_and_restart_apache() {
    if [ -f "/usr/local/cpanel/cpanel" ]; then
        # cPanel server
        check_and_restart_apache_cpanel
    else
        # Non-cPanel server (assuming Ubuntu with systemd)
        check_and_restart_apache_ubuntu
    fi
}

# Function to detect server type and execute appropriate MySQL check function
check_and_restart_mysql() {
    if [ -f "/usr/local/cpanel/cpanel" ]; then
        # cPanel server
        check_and_restart_mysql_cpanel
    else
        # Non-cPanel server (assuming Ubuntu with systemd)
        check_and_restart_mysql_ubuntu
    fi
}

# Main function to check server HTTP response, MySQL responsiveness, and restart services if needed
check_server_health_and_restart_services() {
    local url="http://localhost/"
    local timeout=10  # Timeout in seconds

    # Check HTTP response for Apache
    if check_server_http_response "$url" "$timeout"; then
        echo "$url is responding. No action needed."
    else
        echo "$url is not responding. Restarting Apache..."
        check_and_restart_apache
    fi

    # Check MySQL responsiveness and restart if needed
    check_mysql_responsiveness
}

# Check server health and restart services if needed
check_server_health_and_restart_services
