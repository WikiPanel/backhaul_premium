#!/bin/bash

echo "🛠 فعال‌سازی دسترسی نوشتن روی /"
mount -o remount,rw /

echo "🔧 نصب Backhaul Premium به عنوان سرور (ایران)..."

# مرحله ۱: دانلود و آماده‌سازی
mkdir -p /root/backhaul
curl -LO --ipv4 https://raw.githubusercontent.com/WikiPanel/backhaul_premium/main/backhaul_premium_linux_amd64.tar.gz
tar -xzf backhaul_premium_linux_amd64.tar.gz -C /root/backhaul
rm -f backhaul_premium_linux_amd64.tar.gz /root/backhaul/LICENSE /root/backhaul/README.md

# مرحله ۲: ساخت پیکربندی سرور
cat > /root/backhaul/config.toml <<'EOF'
[server]
bind_addr = "0.0.0.0:3080"
transport = "tcpmux"
token = "bia2host"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
mux_con = 8
mux_version = 1
mux_framesize = 32768
mux_recievebuffer = 4194304
mux_streambuffer = 65536
sniffer = true
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = ["80","443","8443","2087","444","587","465","8951"]
EOF

# مرحله ۳: مجوز اجرا
chmod +x /root/backhaul/backhaul_premium

# مرحله ۴: ساخت سرویس systemd
cat > /etc/systemd/system/backhaul.service <<EOF
[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
ExecStart=/root/backhaul/backhaul_premium -c /root/backhaul/config.toml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# مرحله ۵: راه‌اندازی سرویس
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable backhaul
systemctl restart backhaul

echo "✅ نصب Backhaul به عنوان سرور کامل شد!"
systemctl status backhaul --no-pager
