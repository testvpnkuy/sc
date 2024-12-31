#!/bin/bash

IP=$(wget -qO- ipv4.icanhazip.com)
echo -e ""
echo -e "**************************************"
echo -e "       OpenVPN Server Configuration"
echo -e ""
echo -e "     [1]  30 Clients"
echo -e "     [2]  126 Clients"
echo -e "     [3]  252 Clients"
echo -e "     [4]  510 Clients"
echo -e "     [5]  1020 Clients"
echo -e "     [6]  2046 Clients"
echo -e "     [x]  EXIT "
echo -e "**************************************"
echo -e ""
read -p "    Select an option [1-6 or x] :  " mask
echo -e ""

case $mask in
1 )
cat > /etc/openvpn/server.conf <<-END
port 443
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.pem
cert server-cert.pem
key server-key.pem
dh dh.pem
topology subnet
server 10.8.0.0 255.255.255.224
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
float
cipher none
comp-lzo yes
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
management $IP 5555
verb 3
client-to-client
client-cert-not-required
username-as-common-name
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
duplicate-cn
END
/etc/init.d/openvpn restart
clear
echo "    Configuration updated for 30 clients"
;;

2 )
cat > /etc/openvpn/server.conf <<-END
port 443
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.pem
cert server-cert.pem
key server-key.pem
dh dh.pem
topology subnet
server 10.8.0.0 255.255.255.128
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
float
cipher none
comp-lzo yes
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
management $IP 5555
verb 3
client-to-client
client-cert-not-required
username-as-common-name
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
duplicate-cn
END
/etc/init.d/openvpn restart
clear
echo "    Configuration updated for 126 clients"
;;

3 )
cat > /etc/openvpn/server.conf <<-END
port 443
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.pem
cert server-cert.pem
key server-key.pem
dh dh.pem
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
float
cipher none
comp-lzo yes
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
management $IP 5555
verb 3
client-to-client
client-cert-not-required
username-as-common-name
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
duplicate-cn
END
/etc/init.d/openvpn restart
clear
echo "    Configuration updated for 252 clients"
;;

4 )
cat > /etc/openvpn/server.conf <<-END
port 443
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.pem
cert server-cert.pem
key server-key.pem
dh dh.pem
topology subnet
server 10.8.0.0 255.255.254.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
float
cipher none
comp-lzo yes
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
management $IP 5555
verb 3
client-to-client
client-cert-not-required
username-as-common-name
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
duplicate-cn
END
/etc/init.d/openvpn restart
clear
echo "    Configuration updated for 510 clients"
;;

5 )
cat > /etc/openvpn/server.conf <<-END
port 443
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.pem
cert server-cert.pem
key server-key.pem
dh dh.pem
topology subnet
server 10.8.0.0 255.255.252.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
float
cipher none
comp-lzo yes
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
management $IP 5555
verb 3
client-to-client
client-cert-not-required
username-as-common-name
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
duplicate-cn
END
/etc/init.d/openvpn restart
clear
echo "    Configuration updated for 1020 clients"
;;

6 )
cat > /etc/openvpn/server.conf <<-END
port 443
proto tcp
dev tun
sndbuf 0
rcvbuf 0
ca ca.pem
cert server-cert.pem
key server-key.pem
dh dh.pem
topology subnet
server 10.8.0.0 255.255.0.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
float
cipher none
comp-lzo yes
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
management $IP 5555
verb 3
client-to-client
client-cert-not-required
username-as-common-name
plugin /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so login
duplicate-cn
END
/etc/init.d/openvpn restart
clear
echo "    Configuration updated for 2046 clients"
;;

x )
echo "    Exiting..."
exit
;;

* )
echo "    Invalid option selected."
;;

esac
