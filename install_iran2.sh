#!/bin/bash

echo "🛠 فعال‌سازی دسترسی نوشتن روی /"
mount -o remount,rw /

# مرحله ۰: نصب گاست در صورت وجود فایل نصب
if [ -f /etc/gost/install.sh ]; then
    echo "📦 اجرای نصب گاست..."
    printf "10\ny\n" | bash /etc/gost/install.sh
fi

echo "🔧 نصب Backhaul Premium به عنوان سرور دوم (ایران)..."

# مرحله ۱: دانلود و آماده‌سازی
mkdir -p /root/backhaul
curl -LO --ipv4 https://raw.githubusercontent.com/WikiPanel/backhaul_premium/main/backhaul_premium_linux_amd64.tar.gz
tar -xzf backhaul_premium_linux_amd64.tar.gz -C /root/backhaul
rm -f backhaul_premium_linux_amd64.tar.gz /root/backhaul/LICENSE /root/backhaul/README.md

# مرحله ۲: ساخت پیکربندی سرور دوم
cat > /root/backhaul/config2.toml <<'EOF'
[server]
bind_addr = "0.0.0.0:3081"
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
ports = ["80","443","8443","2087","444","587","465","8951","800","801","802","803","804","805","806","807","808","809","810","811","812","813","814","815","816","817","818","819","820","821","822","823","824","825","826","827","828","829","830","831","832","833","834","835","836","837","838","839","840","841","842","843","844","845","846","847","848","849","850","851","852","853","854","855","856","857","858","859","860","861","862","863","864","865","866","867","868","869","870","871","872","873","874","875","876","877","878","879","880","881","882","883","884","885","886","887","888","889","890","891","892","893","894","895","896","897","898","899","900","901","902","903","904","905","906","907","908","909","910","911","912","913","914","915","916","917","918","919","920","921","922","923","924","925","926","927","928","929","930","931","932","933","934","935","936","937","938","939","940","941","942","943","944","945","946","947","948","949","950","951","952","953","954","955","956","957","958","959","960","961","962","963","964","965","966","967","968","969","970","971","972","973","974","975","976","977","978","979","980","981","982","983","984","985","986","987","988","989","990","991","992","993","994","995","996","997","998","999"]
EOF

# مرحله ۳: مجوز اجرا
chmod +x /root/backhaul/backhaul_premium

# مرحله ۴: ساخت سرویس systemd با نام backhaul2
cat > /etc/systemd/system/backhaul2.service <<EOF
[Unit]
Description=Backhaul2 Reverse Tunnel Service
After=network.target

[Service]
ExecStart=/root/backhaul/backhaul_premium -c /root/backhaul/config2.toml
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# مرحله ۵: راه‌اندازی سرویس backhaul2
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable backhaul2
systemctl restart backhaul2

# مرحله ۶: افزودن کرون‌جاب برای ریستارت خودکار
echo "*/10 * * * * service backhaul2 restart" | crontab -

echo "✅ نصب Backhaul به عنوان سرور دوم کامل شد!"
systemctl status backhaul2 --no-pager
