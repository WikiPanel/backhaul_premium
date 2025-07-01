#!/bin/bash

echo "🌍 نصب Backhaul Premium به عنوان کلاینت دوم (سرور خارج)..."

# دریافت آی‌پی سرور ایران
read -p "🖥 لطفاً IP سرور ایران را وارد کنید: " remote_ip

# مرحله ۱: دانلود و آماده‌سازی
mkdir -p /root/backhaul
curl -LO --ipv4 https://raw.githubusercontent.com/WikiPanel/backhaul_premium/main/backhaul_premium_linux_amd64.tar.gz
tar -xzf backhaul_premium_linux_amd64.tar.gz -C /root/backhaul
rm -f backhaul_premium_linux_amd64.tar.gz /root/backhaul/LICENSE /root/backhaul/README.md

# مرحله ۲: ساخت پیکربندی کلاینت
cat > /root/backhaul/config2.toml <<EOF
[client]
remote_addr = "$remote_ip:3081"
transport = "tcpmux"
token = "bia2host"
connection_pool = 8
aggressive_pool = false
keepalive_period = 75
dial_timeout = 10
retry_interval = 3
nodelay = true
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = true
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
EOF

# مرحله ۳: مجوز اجرا
chmod +x /root/backhaul/backhaul_premium

# مرحله ۴: ساخت سرویس systemd با نام backhaul2
cat > /etc/systemd/system/backhaul2.service <<EOF
[Unit]
Description=Backhaul2 Reverse Tunnel Client Service
After=network.target

[Service]
ExecStart=/root/backhaul/backhaul_premium -c /root/backhaul/config2.toml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# مرحله ۵: راه‌اندازی سرویس
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable backhaul2
systemctl restart backhaul2

echo "✅ نصب Backhaul به عنوان کلاینت دوم کامل شد!"
systemctl status backhaul2 --no-pager
