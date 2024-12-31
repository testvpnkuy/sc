#!/bin/bash

function count_online_users() {
    ssh_online=$(ps aux | grep sshd | grep -v root | grep priv | wc -l)
    if [[ -e /etc/openvpn/openvpn-status.log ]]; then
        openvpn_online=$(grep -c "10.8" /etc/openvpn/openvpn-status.log)
    else
        openvpn_online=0
    fi
    if [[ -e /etc/default/dropbear ]]; then
        dropbear_online=$(ps aux | grep dropbear | grep -v grep | wc -l)
        dropbear_online=$((dropbear_online - 1))
    else
        dropbear_online=0
    fi
    total_online=$((ssh_online + openvpn_online + dropbear_online))
    echo "จำนวนผู้ใช้ออนไลน์ทั้งหมด: $total_online"

    # ตรวจสอบและสร้างไดเรกทอรีถ้ายังไม่มีอยู่
    if [[ ! -d /var/www/html/server ]]; then
        sudo mkdir -p /var/www/html/server
        sudo chown -R $USER:$USER /var/www/html/server
    fi

    echo "[{\"onlines\":\"$total_online\",\"limite\":\"250\"}]" > /var/www/html/server/online_app.json
}

while true; do
    count_online_users
    sleep 15s
done
