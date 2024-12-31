#!/bin/bash

# แสดงเครดิตของคุณ
clear
echo "====================================="
echo "  ยินดีต้อนรับสู่การติดตั้งระบบเช็คออนไลน์ SSH"
echo "       By.Duck VPN"
echo "====================================="
echo ""
echo "กำลังเริ่มต้นการติดตั้ง กรุณารอสักครู่..."
sleep 3  # หน่วงเวลาให้ผู้ใช้ได้เห็นเครดิต

# ติดตั้ง Apache2 และทำการตั้งค่าพอร์ตเป็น 82
sudo apt update
sudo apt install apache2 -y
sudo sed -i 's/Listen 80/Listen 82/' /etc/apache2/ports.conf

# แก้ไข VirtualHost ในไฟล์คอนฟิกของ Apache2
sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:82>
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

# สร้างไดเรกทอรีและเปลี่ยนเจ้าของเป็นผู้ใช้ปัจจุบัน
sudo mkdir -p /var/www/html/server
sudo chown -R $USER:$USER /var/www/html/server

# รีสตาร์ท Apache2 เพื่อให้การตั้งค่าใหม่มีผล
sudo systemctl restart apache2

# สร้างสคริปต์เพื่อนับจำนวนผู้ใช้ออนไลน์และบันทึกลงในไฟล์ JSON
sudo bash -c 'cat <<EOF > /usr/local/bin/count_online_users.sh
#!/bin/bash

function count_online_users() {
    ssh_online=\$(ps aux | grep sshd | grep -v root | grep priv | wc -l)
    if [[ -e /etc/openvpn/openvpn-status.log ]]; then
        openvpn_online=\$(grep -c "10.8" /etc/openvpn/openvpn-status.log)
    else
        openvpn_online=0
    fi
    if [[ -e /etc/default/dropbear ]]; then
        dropbear_online=\$(ps aux | grep dropbear | grep -v grep | wc -l)
        dropbear_online=\$((dropbear_online - 1))
    else
        dropbear_online=0
    fi
    total_online=\$((ssh_online + openvpn_online + dropbear_online))
    echo "จำนวนผู้ใช้ออนไลน์ทั้งหมด: \$total_online"

    # ตรวจสอบและสร้างไดเรกทอรีถ้ายังไม่มีอยู่
    if [[ ! -d /var/www/html/server ]]; then
        sudo mkdir -p /var/www/html/server
        sudo chown -R \$USER:\$USER /var/www/html/server
    fi

    echo "[{\"onlines\":\"\$total_online\",\"limite\":\"250\"}]" > /var/www/html/server/online_app.json
}

while true; do
    count_online_users
    sleep 15s
done
EOF'

# กำหนดสิทธิ์ให้สคริปต์เป็น executable
sudo chmod +x /usr/local/bin/count_online_users.sh

# สร้าง systemd service เพื่อให้สคริปต์ทำงานอัตโนมัติ
sudo bash -c 'cat <<EOF > /etc/systemd/system/count_online_users.service
[Unit]
Description=Count Online Users Service

[Service]
ExecStart=/usr/local/bin/count_online_users.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF'

# รีโหลด daemon ของ systemd เพื่อให้ระบบทราบเกี่ยวกับ service ใหม่
sudo systemctl daemon-reload

# เปิดให้ systemd เริ่มต้น service นี้พร้อมกับระบบ
sudo systemctl enable count_online_users.service

# เริ่ม service นับจำนวนผู้ใช้ออนไลน์
sudo systemctl start count_online_users.service

# ตรวจสอบสถานะของ service
sudo systemctl status count_online_users.service
