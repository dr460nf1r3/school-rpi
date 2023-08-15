## Custom Raspbian builds

[![Build aarch64 image](https://github.com/dr460nf1r3/school-rpi/actions/workflows/build_aarch64.yml/badge.svg)](https://github.com/dr460nf1r3/school-rpi/actions/workflows/build_aarch64.yml) [![Test code with shellcheck](https://github.com/dr460nf1r3/school-rpi/actions/workflows/lint.yml/badge.svg)](https://github.com/dr460nf1r3/school-rpi/actions/workflows/lint.yml)

This repo contains customized Raspbian builds. I mostly set it up for testing purposes. 

### Documentation
#### Flashing the image

- Retrieve Raspberry Pi Imager from [official sources](https://www.raspberrypi.com/software/)
- Open Raspberry Pi Imager
- Select the OS via "Choose OS" -> "Raspberry Pi OS (other)" -> "Raspberry Pi OS Lite (32-bit)"
- Insert the SD-Card and select it via "Choose storage"
- Configure the image:
- Write the image by selecting "Write" and confirming all prompts

#### Connecting to the Pi & changing IP

- `ssh njensch@10.11.0.3`, confirming all prompts with "y" & "Enter"
- `sudo nano /etc/dhcpcd.conf`
- Add the following configuration:
  ~~~
  interface wlan0
  static ip_address=10.2.13.7
  static routers=10.10.0.1
  static domain_name_servers=10.10.0.1 1.1.1.1
  ~~~
- Exit the editor by entering "CTRL" + "X" followed by "Y" and "Enter"
- Restart the service with `sudo systemctl restart dhcpcd`

#### Reconnecting via the new IP & updating the system

- `ssh njensch@10.2.13.7`
- `sudo apt-get update && sudo apt-get upgrade``