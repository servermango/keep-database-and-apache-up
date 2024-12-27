#!/bin/bash

# URL to download the script
SCRIPT_URL="https://cdn.jsdelivr.net/gh/servermango/keep-database-and-apache-up/keep_up.sh"

# Path to save the downloaded script
SCRIPT_PATH="/usr/local/bin/keep_up.sh"

# Download the script
echo "Downloading keep_up.sh..."
wget -q -O "$SCRIPT_PATH" "$SCRIPT_URL"

# Check if the download was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to download the script from $SCRIPT_URL"
  exit 1
fi

# Make the script executable
chmod +x "$SCRIPT_PATH"
echo "Script downloaded and made executable at $SCRIPT_PATH"

# Cronjob entry
CRON_ENTRY="* * * * * $SCRIPT_PATH"

# Check if the cronjob already exists
(crontab -l 2>/dev/null | grep -F "$CRON_ENTRY") && {
  echo "The cronjob is already present in the crontab."
  exit 0
}

# Add the cronjob to the current user's crontab
(crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -

# Confirm the addition
if [[ $? -eq 0 ]]; then
  echo "Cronjob added successfully to run every minute."
else
  echo "Failed to add the cronjob."
fi
