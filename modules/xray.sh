#!/bin/bash
# modules/xray.sh
# Xray WS + TLS Zero Knithg

source /opt/zeroknithg/config.conf
source /opt/zeroknithg/core/logger.sh
XRAY_DIR="/etc/xray"
XRAY_BIN="/usr/local/bin/xray"
XRAY_CONF="$XRAY_DIR/config.json"

install_xray() {
    echo "====================================="
    echo "   INSTALANDO XRAY WS + TLS"
    echo "====================================="
    
    mkdir -p $XRAY_DIR

    # Detectar arquitectura
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then
        BIN_URL="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip"
    elif [[ "$ARCH" == "aarch64" ]]; then
        BIN_URL="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-arm64-v8a.zip"
    else
        echo "Arquitectura no soportada"
        return
    fi

    wget -O /tmp/xray.zip $BIN_URL
    unzip -o /tmp/xray.zip -d /tmp/xray
    mv /tmp/xray/xray $XRAY_BIN
    chmod +x $XRAY_BIN

    # Configuración básica Xray WS
    cat > $XRAY_CONF <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": 10000,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": { "clients": [] },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "/zeroknithg" }
      }
    }
  ],
  "outbounds": [ { "protocol": "freedom", "settings": {} } ]
}
EOF

# Servicio systemd
cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target

[Service]
ExecStart=$XRAY_BIN -config $XRAY_CONF
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable xray
systemctl restart xray

log_action "Xray instalado y servicio iniciado"

# Configurar Nginx y SSL
apt install -y nginx certbot python3-certbot-nginx

cat > /etc/nginx/sites-available/zeroknithg <<EOF
server {
    listen 80;
    server_name $DOMAIN;
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    location /zeroknithg {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }

    location / {
        root /var/www/html;
        index index.html;
    }
}
EOF

ln -sf /etc/nginx/sites-available/zeroknithg /etc/nginx/sites-enabled/zeroknithg
rm -f /etc/nginx/sites-enabled/default

# Generar certificado SSL automáticamente
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

systemctl restart nginx
systemctl restart xray

echo "Xray WS + TLS instalado correctamente!"
log_action "Nginx y SSL configurados para Xray"
}