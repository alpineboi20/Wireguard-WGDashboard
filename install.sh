#!/bin/bash

GREEN="\e[0;32m"
ENDCOLOR="\e[0m"

echo ""
echo "Wireguard & WGDashboard Install.
--------------------------------"
echo ""
echo "Updating, please Wait...."
apt-get update > /dev/null 2>&1
apt-get install -y wireguard resolvconf > /dev/null 2>&1
#Create wireguard config.
echo -e "[Interface]\nPrivateKey = private_key\nAddress = 10.8.0.1/24\nListenPort = lport\nSaveConfig = true\nPostUp = ufw route allow in on wg0 out on iface\nPostUp = ufw allow in on iface to any port lport proto udp\nPostUp = iptables -t nat -I POSTROUTING -o iface -j MASQUERADE\nPreDown = ufw route delete allow in on wg0 out on iface\nPreDown = ufw delete allow in on iface to any port lport proto udp\nPreDown = iptables -t nat -D POSTROUTING -o iface -j MASQUERADE" > /etc/wireguard/wg0.conf
chmod -R 755 /etc/wireguard
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Detect WAN interface.
echo "Detect WAN interface...."
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
echo -e "Your WAN Interface is "${GREEN}$(ip route get 1.1.1.1 | awk -- '{printf $5}')${ENDCOLOR}" enter it below, if correct."
read -p "Enter Name of WAN Interface : " IFACE
sleep 1
sed -i "s/iface/$IFACE/gi" /etc/wireguard/wg0.conf
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Choose a wireguard port number.
echo "Choose a Wireguard Port Number. Typical Range 49152-65535"
read -p "Enter Port Number : " LPORT
sleep 1
sed -i "s/lport/$LPORT/gi" /etc/wireguard/wg0.conf
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Install Dependencies.
echo "Installing Dependencies, please Wait...."
apt-get install -y iptables ufw curl python3 python3-pip > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Generate server keys, private & public.
echo "Generate Server Keys, Private & Public...."
wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Copy private key to wireguard Config.
echo "Copy Private Key to Wireguard Config...."
PRIVATE_KEY=`cat /etc/wireguard/private.key`
sed -i "s|private_key|$PRIVATE_KEY|gi" /etc/wireguard/wg0.conf
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#IP forwarding
echo "IP Forwarding...."
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Open required firewall ports.
echo "Open Required Firewall Ports...."
#10086/tcp = WGDashboard port.
#22/tcp = ssh port.
ufw allow 10086/tcp > /dev/null 2>&1
ufw allow 22/tcp > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Enable & start firewall.
echo "Enable & Start Firewall."
ufw disable > /dev/null 2>&1
ufw --force enable > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Enable & Start wireguard server.
echo "Enable & Start Wireguard Server...."
systemctl enable wg-quick@wg0.service > /dev/null 2>&1
systemctl start wg-quick@wg0.service > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Install WGDashboard.
echo "Install WGDashboard...."
git clone -b v3.0.3 https://github.com/donaldzou/WGDashboard.git /opt/wgdashboard > /dev/null 2>&1
cd /opt/wgdashboard/src
./wgd.sh install > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Start WGDashboard
echo "Start WGDashboard...."
./wgd.sh start > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Update WGDashboard.
echo "Update WGDashboard...."
chmod 755 /opt/wgdashboard/src/wgd.sh
echo Y | ./wgd.sh update > /dev/null 2>&1
./wgd.sh stop > /dev/null 2>&1
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Create WGDashboard service.
echo "Create WGDashboard Service...."
echo -e "[Unit]\nAfter=network.service\n\n[Service]\nWorkingDirectory=/opt/wgdashboard/src\nExecStart=/usr/bin/python3 /opt/wgdashboard/src/dashboard.py\nRestart=always\n\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/wg-dashboard.service
chmod 664 /etc/systemd/system/wg-dashboard.service
systemctl daemon-reload
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
#Enable & Start WGDashboard service.
echo "Enable & Start WGDashboard Service...."
systemctl enable wg-dashboard.service > /dev/null 2>&1
systemctl start wg-dashboard.service
echo -e "${GREEN}"Done."${ENDCOLOR}"
echo ""
echo -e "${GREEN}Reboot Recommended.${ENDCOLOR}"
echo ""
echo "WGDashbord:
-----------"
echo -e "${GREEN}http://$(ip route get 1.1.1.1 | tr -s ' ' | cut -d' ' -f7):10086${ENDCOLOR}"
echo "User: admin"
echo "Password: admin"
echo ""
echo "WGDashboard Commands:
---------------------"
echo "systemctl status wg-dashboard.service    # <-- To check the service status!"
echo "systemctl stop wg-dashboard.service      # <-- To stop the service"
echo "systemctl start wg-dashboard.service     # <-- To start the service"
echo "systemctl restart wg-dashboard.service   # <-- To restart the service"
echo ""
echo "WGDashboard Update:
-------------------"
echo "cd /opt/wgdashboard/src"
echo "./wgd.sh update"
echo ""
echo "Wireguard Commands:
-------------------"
echo "systemctl status wg-quick@wg0.service    # <-- To check the service status"
echo "systemctl stop wg-quick@wg0.service      # <-- To stop the service"
echo "systemctl start wg-quick@wg0.service     # <-- To start the service"
echo "systemctl restart wg-quick@wg0.service   # <-- To restart the service"
