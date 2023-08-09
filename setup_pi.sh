#!/usr/bin/env bash
# shellcheck disable=SC2164
# Parameters
GROUPS=(museum event ohmega)
INITIAL_PW=zuaendern
NETDATA_CLAIM_TOKEN=
NETDATA_CLAIM_ROOM=
PROJECT_ROOT=/opt/licht
PROJECT_DEPS=(python3)
SYSTEM_DEPS=(fish ufw curl)
TAILSCALE_AUTHKEY=
USERS_EVENT=(dherzog uziegelmann)
USERS_MUSEUM=(seberhart dkaestner)
USERS_OHMEGA=(njensch)

# Check for root rights
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Run initial system update
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade

# Some basic tools
apt-get install "${SYSTEM_DEPS[@]}"

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw enable

# Netdata monitoring
curl -fsSL https://my-netdata.io/kickstart.sh \
    | sh netdata-kickstart.sh \
    --nightly-channel \
    --claim-token "$NETDATA_CLAIM_TOKEN" \
    --claim-rooms "$NETDATA_CLAIM_ROOM" \
    --claim-url https://app.netdata.cloud

# Tailscale for easy access
curl -fsSL https://tailscale.com/install.sh | sh \
    && tailscale up --authkey "$TAILSCALE_AUTHKEY"

# Install dependencies
apt-get install "${PROJECT_DEPS[@]}"

# Create groups
for GROUP in "${GROUPS[@]}"; do
    groupadd "$GROUP"
done

# Create admins
for USER in "${USERS_OHMEGA[@]}"; do
    useradd -m -g ohmega -s /bin/bash "$USER"
    echo "$INITIAL_PW" | passwd --stdin "$USER"
    passwd --expire "$USER"
done

# Create event users
for USER in "${USERS_EVENT[@]}"; do
    useradd -m -g event -s /bin/bash "$USER"
    echo "$INITIAL_PW" | passwd --stdin "$USER"
    passwd --expire "$USER"
done

# Create museum users
for USER in "${USERS_MUSEUM[@]}"; do
    useradd -m -g museum -s /bin/bash "$USER"
    echo "$INITIAL_PW" | passwd --stdin "$USER"
    passwd --expire "$USER"
done

# Create project root
mkdir -p "$PROJECT_ROOT"/{OHMegascripts,sequenzen}

# Place scripts
cp ./OHMegascripts/* "$PROJECT_ROOT"/OHMegascripts
cp ./alle-sequenzen.sh "$PROJECT_ROOT"

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
