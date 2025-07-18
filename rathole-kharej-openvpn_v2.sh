#!/bin/bash

read -p "🌐 لطفاً آی‌پی سرور ایران را وارد کنید: " IRAN_IP

cat > /root/rathole-core/kharej3090.toml <<EOF
[client]
remote_addr = "$IRAN_IP:3090"
default_token = "musixal"
heartbeat_timeout = 0
retry_interval = 1

[client.transport]
type = "tcp"

[client.transport.tcp]
nodelay = true

[client.services.993]
type = "tcp"
local_addr = "127.0.0.1:528"
EOF

echo "✅ فایل کانفیگ با موفقیت به‌روزرسانی شد."

# ری‌استارت سرویس
echo "🔁 در حال ری‌استارت سرویس رتهول..."
systemctl restart rathole-kharej3090.service

# بررسی وضعیت
echo "📋 وضعیت سرویس:"
systemctl status rathole-kharej3090.service --no-pager
