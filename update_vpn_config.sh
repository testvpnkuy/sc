#!/bin/bash

# ฟังก์ชันในการอัปเดตการตั้งค่า OpenVPN
update_openvpn_config() {
    local max_clients="$1"
    local ip_pool="$2"
    
    # ปรับเปลี่ยนการตั้งค่าในไฟล์ server.conf
    sudo sed -i "s/^server .*/server ${ip_pool}/" /etc/openvpn/server.conf
    sudo sed -i "s/^max-clients .*/max-clients ${max_clients}/" /etc/openvpn/server.conf
    sudo sed -i "/^tun-mtu /d" /etc/openvpn/server.conf
    sudo sed -i "/^mssfix /d" /etc/openvpn/server.conf
    echo "tun-mtu 1500" | sudo tee -a /etc/openvpn/server.conf
    echo "mssfix 1400" | sudo tee -a /etc/openvpn/server.conf
    
    # รีสตาร์ท OpenVPN Server
    sudo systemctl restart openvpn@server

    echo "OpenVPN configuration updated to support ${max_clients} clients and service restarted."
}

# เมนูให้เลือก
echo "เลือกจำนวนการเชื่อมต่อ VPN ที่ต้องการ:"
echo "1) 60 คน"
echo "2) 125 คน"
echo "3) 250 คน"
echo "4) 500 คน"
echo "5) 1000 คน"

read -p "กรุณาเลือกหมายเลข (1-5): " choice

case $choice in
    1)
        update_openvpn_config 60 "10.8.0.0 255.255.255.192" # IP pool สำหรับ 60 คน
        ;;
    2)
        update_openvpn_config 125 "10.8.0.0 255.255.255.128" # IP pool สำหรับ 125 คน
        ;;
    3)
        update_openvpn_config 250 "10.8.0.0 255.255.254.0"   # IP pool สำหรับ 250 คน
        ;;
    4)
        update_openvpn_config 500 "10.8.0.0 255.255.252.0"   # IP pool สำหรับ 500 คน
        ;;
    5)
        update_openvpn_config 1000 "10.8.0.0 255.255.0.0"    # IP pool สำหรับ 1000 คน
        ;;
    *)
        echo "เลือกหมายเลขไม่ถูกต้อง"
        ;;
esac
