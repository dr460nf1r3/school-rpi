#!/usr/bin/env bash
# shellcheck disable=SC2164,SC1091

# Source configuration
source ./config

# Check for root rights
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Run initial system update
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade

# Some basic tools
apt-get install -y "${SYSTEM_DEPS[@]}"

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable

# Configure DHCP
cat <<EOF >> /etc/dhcpcd.conf
interface wlan0
static ip_address=$IP_ADRESS
static routers=$IP_GATEWAY
static domain_name_servers=$IP_DNS
EOF

# Netdata monitoring
if [ -n "$NETDATA_CLAIM_TOKEN" ]; then
    wget https://my-netdata.io/kickstart.sh &&
        sh kickstart.sh \
            --nightly-channel \
            --claim-token "$NETDATA_CLAIM_TOKEN" \
            --claim-rooms "$NETDATA_CLAIM_ROOM" \
            --claim-url https://app.netdata.cloud
else 
    echo "No Netdata token provided, skipping installation"
fi

# Tailscale for easy access
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    curl -fsSL https://tailscale.com/install.sh | sh
    tailscale up --authkey "$TAILSCALE_AUTHKEY"
else
    echo "No Tailscale authkey provided, skipping installation"
fi

# Install dependencies
apt-get install -y "${PROJECT_DEPS[@]}"

# Create groups
for i in "${GROUP[@]}"; do
    groupadd "$i"
done

# Create admins
for i in "${USERS_OHMEGA[@]}"; do
    useradd -m -g ohmega -s /bin/bash "$i"
    echo  "$i":"$INITIAL_PW" | chpasswd
    passwd --expire "$i"
done

# Create event users
for i in "${USERS_EVENT[@]}"; do
    useradd -m -g event -s /bin/bash "$i"
    echo  "$i":"$INITIAL_PW" | chpasswd
    passwd --expire "$i"
done

# Create museum users
for i in "${USERS_MUSEUM[@]}"; do
    useradd -m -g museum -s /bin/bash "$i"
    echo  "$i":"$INITIAL_PW" | chpasswd
    passwd --expire "$i"
done

# Create project root
mkdir -p "$PROJECT_ROOT"/{OHMegascripts,sequenzen}

# Place scripts
cp ./scripts/* "$PROJECT_ROOT"/OHMegascripts
cp ./misc/alle-sequenzen.sh "$PROJECT_ROOT"

# Set owner/groups
chown -R ohmega:ohmega "$PROJECT_ROOT"
chown -R event:event "$PROJECT_ROOT"/sequenzen
chown museum:event "$PROJECT_ROOT"/alle-sequenzen.sh

# Set permissions
chmod 775 "$PROJECT_ROOT"
chmod 770 "$PROJECT_ROOT"/alle-sequenzen.sh
chmod 2700 "$PROJECT_ROOT"/sequenzen
chmod 600 "$PROJECT_ROOT"/sequenzen/*
chmod 2700 "$PROJECT_ROOT"/OHMegascripts
chmod 700 "$PROJECT_ROOT"/OHMegascripts/*
