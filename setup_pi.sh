#!/usr/bin/env bash
# shellcheck disable=SC2164,SC1091

# Source configuration
source ./config

# Check for root rights
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root!"
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
cat <<EOF >>/etc/dhcpcd.conf
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
    echo "No Netdata token provided, skipping installation.."
fi

# Tailscale for easy access
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    curl -fsSL https://tailscale.com/install.sh | sh
    tailscale up --authkey "$TAILSCALE_AUTHKEY"
else
    echo "No Tailscale authkey provided, skipping installation.."
fi

# Install dependencies
apt-get install -y "${PROJECT_DEPS[@]}"

# Create groups
for i in "${GROUP[@]}"; do
    groupadd "$i"
done

# Create admins
for i in "${USERS_OHMEGA[@]}"; do
    if [ ! "$i" == "admin" ]; then
        useradd -m -g {ohmega,sudo} -s /bin/bash "$i"
    else
        useradd -m -g sudo -s /bin/bash "$i"
    fi
    echo "$i":"$INITIAL_PW" | chpasswd
    passwd --expire "$i"
done

# Create event users
for i in "${USERS_EVENT[@]}"; do
    useradd -m -g event -s /bin/bash "$i"
    echo "$i":"$INITIAL_PW" | chpasswd
    passwd --expire "$i"
done

# Create museum users
for i in "${USERS_MUSEUM[@]}"; do
    useradd -m -g museum -s /bin/bash "$i"
    echo "$i":"$INITIAL_PW" | chpasswd
    passwd --expire "$i"
done

# Create project root
mkdir -p "$PROJECT_ROOT"/OHMegascripts

# Place scripts
cp ./scripts/M0{1,2}* "$PROJECT_ROOT"/OHMegascripts
cp ./scripts/M0{3,4}* "$PROJECT_ROOT"
cp ./scripts/{run_sequence,alle-sequenzen}.sh "$PROJECT_ROOT"
cp ./scripts/ "$PROJECT_ROOT"

# Set owner/groups
chown -R event:event "$PROJECT_ROOT"
chown -R ohmega:event "$PROJECT_ROOT"/OHMegascripts
chown museum:event "$PROJECT_ROOT"/{run_sequence,alle-sequenzen}.sh

# Set permissions
chmod 2775 "$PROJECT_ROOT"
chmod 770 "$PROJECT_ROOT"/*.{sh,py}
chmod 2770 "$PROJECT_ROOT"/OHMegascripts
chmod 770 "$PROJECT_ROOT"/OHMegascripts/*
