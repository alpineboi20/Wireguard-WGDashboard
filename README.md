**Wireguard & Wireguard Dashboard, Script.**


This script is Experimental, use at your own risk.

**Warning!** 
This script assumes you have installed ufw & will be using it, the scrpt will enable ufw,
& open the default ssh port, as not to get locked out of shh.
If you are using a custom ssh port other than the default, and have ufw installed, open the custom port prior to running this script, or you will get locked out of ssh when ufw is enabled. You can close the default ssh port later, if you desire.

IPv4 Only

Only tested on a fresh, Ubuntu Server 20.04 instance.

Uses WGDashboard, as a frontend for peer management.

Credit to Donald Zou https://github.com/donaldzou/WGDashboard

**Install**

>curl -O https://raw.githubusercontent.com/alpineboi20/Wireguard-WGDashboard/main/insttall.sh && chmod +x install.sh && ./install.sh
