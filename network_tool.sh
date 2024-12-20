#!/bin/bash

# Configuration
NETWORK="192.168.x.x/24"  # Replace with your actual network range
KNOWN_DEVICES_FILE="" # this will be where the known devices master list is stored. please place in your home folder.
RECIPIENT_EMAIL=""  # Replace with your desired recipient email
SENDER_EMAIL="" #Type the email address you want the emails to be sent from

# Function to send email notification
send_email() {
  local ip_address="$1"
  local mac_address="$2"
  local hostname="$3"

  # Create the HTML email content
  email_content=$(cat <<EOF
To: $RECIPIENT_EMAIL
From: $SENDER_EMAIL
Subject: New Device Connected to Your Network
MIME-Version: 1.0
Content-Type: text/html; charset=UTF-8

<html>
<body>
  <p>Hello,</p>
  <p>A new device has been detected on your network:</p>
  <ul>
    <li><strong>IP Address:</strong> $ip_address</li>
    <li><strong>MAC Address:</strong> $mac_address</li>
    <li><strong>Hostname:</strong> $hostname</li>
  </ul>
  <p>Please check if this device is permitted.</p>
  <p>Sincerely,<br>Your Home Network Monitoring Tool</p>
</body>
</html>
EOF
)

  # Send the email using msmtp
  echo "$email_content" | msmtp --debug --from=$SENDER_EMAIL -t $RECIPIENT_EMAIL
}

# Perform network scan
echo "Scanning network for new devices..."
nmap -sn $NETWORK -oG - | awk '/Up$/{print $2}' > /tmp/current_devices.txt

# Compare with known devices
if [ ! -f "$KNOWN_DEVICES_FILE" ]; then
  echo "Known devices file not found. Creating a new one."
  touch "$KNOWN_DEVICES_FILE"
fi

# Check for new devices
while read -r ip_address; do
  if ! grep -q "$ip_address" "$KNOWN_DEVICES_FILE"; then
    # New device detected
    mac_address=$(nmap -sP $ip_address | awk '/MAC Address:/{print $3}')
    hostname=$(nmap -sP $ip_address | awk '/Nmap scan report/{print $NF}')

    echo "New device detected: IP $ip_address, MAC $mac_address, Hostname $hostname"
    send_email "$ip_address" "$mac_address" "$hostname"

    # Add to known devices file
    echo "$mac_address" >> "$KNOWN_DEVICES_FILE"
  fi
done < /tmp/current_devices.txt

echo "Monitoring completed."
