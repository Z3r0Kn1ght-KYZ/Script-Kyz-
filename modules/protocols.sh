#!/bin/bash
# modules/protocols.sh
# Panel Zero Knithg - Gestión de protocolos

source /opt/zeroknithg/config.conf
source /opt/zeroknithg/core/logger.sh

DB_FILE="/opt/zeroknithg/database/users.db"

# Colores minimalistas
GREEN="\e[32m"
RESET="\e[0m"

# Función para mostrar usuarios y links por protocolo
show_links() {
    local PROTO=$1
    local PORT=$2
    local EXTRA=$3   # Para SlowDNS key u otros parámetros

    if [[ -s "$DB_FILE" ]]; then
        echo -e "${GREEN}Usuarios activos y enlaces $PROTO:${RESET}"
        while IFS="|" read USER UUID EXPIRA
        do
            case $PROTO in
                VMESS)
                    JSON=$(cat <<EOF
{
  "v": "2",
  "ps": "$USER",
  "add": "$DOMAIN",
  "port": "443",
  "id": "$UUID",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "$DOMAIN",
  "path": "/zeroknithg",
  "tls": "tls",
  "sni": "$DOMAIN"
}
EOF
)
                    LINK="vmess://$(echo -n "$JSON" | base64 -w 0)"
                    ;;
                UDP)
                    LINK="udp://$DOMAIN:$PORT@$USER"
                    ;;
                ZIPVPN)
                    LINK="zipvpn://$DOMAIN:$PORT@$USER"
                    ;;
                HYSTERIA)
                    LINK="hysteria://$DOMAIN:$PORT@$USER"
                    ;;
                STUNNEL)
                    LINK="stunnel://$DOMAIN:$PORT@$USER"
                    ;;
                SLOWDNS)
                    LINK="slowdns://$DOMAIN:$PORT@$USER?key=$EXTRA"
                    ;;
            esac
            echo "$USER | $LINK"
        done < $DB_FILE
    else
        echo "No hay usuarios activos."
    fi
}

# ===== UDP Custom =====
udp_custom() {
    clear
    echo -e "${GREEN}==== UDP CUSTOM ====${RESET}"
    read -p "Puerto UDP Custom: " PORT
    echo "UDP Custom configurado en puerto $PORT"
    log_action "UDP Custom activado en puerto $PORT"
    show_links "UDP" "$PORT"
    read -p "Enter para continuar"
}

# ===== ZIPVPN =====
zipvpn() {
    clear
    echo -e "${GREEN}==== ZIPVPN ====${RESET}"
    read -p "Puerto ZIPVPN: " PORT
    echo "ZIPVPN configurado en puerto $PORT"
    log_action "ZIPVPN activado en puerto $PORT"
    show_links "ZIPVPN" "$PORT"
    read -p "Enter para continuar"
}

# ===== Hysteria =====
hysteria() {
    clear
    echo -e "${GREEN}==== HYSTERIA ====${RESET}"
    read -p "Puerto Hysteria: " PORT
    echo "Hysteria configurado en puerto $PORT"
    log_action "Hysteria activado en puerto $PORT"
    show_links "HYSTERIA" "$PORT"
    read -p "Enter para continuar"
}

# ===== Stunnel (SSL) =====
stunnel() {
    clear
    echo -e "${GREEN}==== STUNNEL (SSL) ====${RESET}"
    read -p "Puerto Stunnel: " PORT
    echo "Stunnel configurado en puerto $PORT"
    log_action "Stunnel activado en puerto $PORT"
    show_links "STUNNEL" "$PORT"
    read -p "Enter para continuar"
}

# ===== SlowDNS =====
slowdns() {
    clear
    echo -e "${GREEN}==== SLOWDNS ====${RESET}"
    read -p "Puerto SlowDNS: " PORT
    read -p "Key SlowDNS: " KEY
    echo "SlowDNS configurado en puerto $PORT con key $KEY"
    log_action "SlowDNS activado en puerto $PORT con key $KEY"
    show_links "SLOWDNS" "$PORT" "$KEY"
    read -p "Enter para continuar"
}

# ===== Xray WS/TLS =====
xray_vmess() {
    clear
    echo -e "${GREEN}==== XRAY WS/TLS ====${RESET}"
    show_links "VMESS"
    read -p "Enter para continuar"
}

while true
do
    clear
    echo -e "${GREEN}=======================================${RESET}"
    echo "        ZERO KNITHG - PROTOCOLOS"
    echo -e "${GREEN}=======================================${RESET}"
    echo "[1] UDP Custom"
    echo "[2] ZIPVPN"
    echo "[3] Hysteria"
    echo "[4] Stunnel (SSL)"
    echo "[5] SlowDNS"
    echo "[6] Xray WS/TLS"
    echo "[7] Volver al panel"
    echo -e "${GREEN}=======================================${RESET}"
    read -p "Selecciona un protocolo: " op

    case $op in
        1) udp_custom ;;
        2) zipvpn ;;
        3) hysteria ;;
        4) stunnel ;;
        5) slowdns ;;
        6) xray_vmess ;;
        7) break ;;
        *) echo "Opción inválida"; sleep 2 ;;
    esac
done