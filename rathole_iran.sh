#!/bin/bash

echo "🧹 Completely removing previous Backhaul installation..."
systemctl stop backhaul.service 2>/dev/null
systemctl disable backhaul.service 2>/dev/null
rm -f /etc/systemd/system/backhaul.service
systemctl daemon-reload
rm -rf /root/backhaul /root/backhaul.json /root/backhaul2.json

echo "🔧 Replacing rathole server config file..."
cat > /root/rathole-core/server.toml << EOF
[server]
bind_addr = "0.0.0.0:3090"
default_token = "musixal_tunnel"
heartbeat_interval = 30

[server.transport]
type = "tcp"

[server.transport.tcp]
nodelay = true

[server.services.80]
type = "tcp"
bind_addr = "0.0.0.0:80"

[server.services.443]
type = "tcp"
bind_addr = "0.0.0.0:443"

[server.services.8443]
type = "tcp"
bind_addr = "0.0.0.0:8443"

[server.services.2087]
type = "tcp"
bind_addr = "0.0.0.0:2087"

[server.services.444]
type = "tcp"
bind_addr = "0.0.0.0:444"

[server.services.587]
type = "tcp"
bind_addr = "0.0.0.0:587"

[server.services.465]
type = "tcp"
bind_addr = "0.0.0.0:465"

[server.services.8951]
type = "tcp"
bind_addr = "0.0.0.0:8951"
EOF

echo "🔁 Restarting rathole service..."
systemctl restart rathole-iran.service

echo "✅ All done. Rathole server config updated and service restarted."
