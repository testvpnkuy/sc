#!/bin/bash

# ฟังก์ชันสำหรับนับจำนวนผู้ใช้ออนไลน์
function count_online_users() {
    # นับผู้ใช้ SSH ออนไลน์
    ssh_online=$(ps aux | grep sshd | grep -v root | grep priv | wc -l)

    # นับผู้ใช้ OpenVPN ออนไลน์
    if [[ -e /etc/openvpn/openvpn-status.log ]]; then
        openvpn_online=$(grep -c "10.8" /etc/openvpn/openvpn-status.log)
    else
        openvpn_online=0
    fi

    # นับผู้ใช้ Dropbear ออนไลน์
    if [[ -e /etc/default/dropbear ]]; then
        dropbear_online=$(ps aux | grep dropbear | grep -v grep | wc -l)
        dropbear_online=$((dropbear_online - 1))
    else
        dropbear_online=0
    fi

    # นับผู้ใช้ V2Ray ออนไลน์โดยเรียก API ของ V2Ray
    v2ray_online=$(curl -s -X POST http://127.0.0.1:62789/stats/query --data '{"name": "user>>>"}' | grep -o '"value":[0-9]*' | awk -F ':' '{sum += $2} END {print sum}')
    v2ray_online=${v2ray_online:-0}  # ตรวจสอบว่าค่าคืนกลับไม่เป็น null

    # คำนวณจำนวนผู้ใช้ออนไลน์ทั้งหมด
    total_online=$((ssh_online + openvpn_online + dropbear_online + v2ray_online))
    echo "จำนวนผู้ใช้ออนไลน์ทั้งหมด: $total_online"

    # บันทึกผลลัพธ์ลงในไฟล์ JSON
    echo "[{\"onlines\":\"$total_online\",\"limite\":\"250\"}]" > /var/www/html/server/online_app.json
}

# วนลูปนับจำนวนผู้ใช้ออนไลน์ทุก 15 วินาที
while true; do
    count_online_users
    sleep 15s
done
