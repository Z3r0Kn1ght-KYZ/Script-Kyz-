#!/bin/bash
# full_install.sh - Instalador completo Zero Knithg

echo "====================================="
echo "      INSTALADOR ZERO KNITHG"
echo "====================================="

read -p "Ingresa tu dominio (ej: vpn.midominio.com): " DOMAIN

IP=$(curl -s ifconfig.me)

echo "Creando carpetas necesarias..."
mkdir -p /opt/zeroknithg/database
mkdir -p /opt/zeroknithg/modules
mkdir -p /opt/zeroknithg/core

# Guardar configuración
cat > /opt/zeroknithg/config.conf <<EOF
DOMAIN=$DOMAIN
IP=$IP
EOF

echo "Dominio y configuración guardados."
sleep 1

echo "Actualizando sistema e instalando dependencias..."
apt update -y
apt install -y curl wget unzip python3 python3-pip nginx certbot python3-certbot-nginx lsof

echo "Dependencias instaladas correctamente."
sleep 1

echo "Creando módulos base..."

# core/logger.sh
cat > /opt/zeroknithg/core/logger.sh <<'EOF'
#!/bin/bash
log_action() {
    local MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $MESSAGE" >> /opt/zeroknithg/database/actions.log
}
EOF

# core/system_info.sh
cat > /opt/zeroknithg/core/system_info.sh <<'EOF'
#!/bin/bash
get_system_info() {
    echo "====================================="
    echo "        INFORMACIÓN DEL VPS"
    echo "====================================="
    echo "IP: $IP"
    echo "CPU: $(lscpu | grep 'Model name' | awk -F: '{print $2}')"
    echo "Cores: $(nproc)"
    echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
    echo "Espacio disco: $(df -h / | tail -1 | awk '{print $4}')"
    echo "====================================="
}
EOF

# modules/xray.sh
cp /opt/zeroknithg/modules/xray.sh /opt/zeroknithg/modules/xray.sh || touch /opt/zeroknithg/modules/xray.sh

# modules/user_manager.sh
cp /opt/zeroknithg/modules/user_manager.sh /opt/zeroknithg/modules/user_manager.sh || touch /opt/zeroknithg/modules/user_manager.sh

# modules/protocols.sh
cp /opt/zeroknithg/modules/protocols.sh /opt/zeroknithg/modules/protocols.sh || touch /opt/zeroknithg/modules/protocols.sh

echo "Módulos creados."
sleep 1

echo "Instalación completa. Preparando panel..."
chmod +x /opt/zeroknithg/modules/*.sh
chmod +x /opt/zeroknithg/core/*.sh

echo "Panel listo para iniciar."
echo "Usa el siguiente comando para abrirlo:"
echo -e "\e[32m bash /opt/zeroknithg/panel.sh \e[0m"

# Crear archivo panel.sh final
cat > /opt/zeroknithg/panel.sh <<'EOF'
#!/bin/bash
source /opt/zeroknithg/config.conf
DB_FILE="/opt/zeroknithg/database/users.db"
GREEN="\e[32m"
RESET="\e[0m"
show_banner() {
    clear
    echo -e "${GREEN}=======================================${RESET}"
    echo "        ZERO KNITHG - PANEL PRINCIPAL"
    echo -e "${GREEN}=======================================${RESET}"
    echo "Dominio: $DOMAIN | IP: $IP"
    echo -e "${GREEN}=======================================${RESET}"
}
vps_monitor() {
    clear
    echo -e "${GREEN}==== MONITOR VPS ====${RESET}"
    echo "CPU: $(lscpu | grep 'Model name' | awk -F: '{print $2}')"
    echo "Cores: $(nproc)"
    echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
    echo "Espacio disco: $(df -h / | tail -1 | awk '{print $4}')"
    echo -e "${GREEN}Usuarios activos:$(wc -l < $DB_FILE)${RESET}"
    read -p "Enter para volver al panel"
}
while true
do
    show_banner
    echo "[1] Administrar Usuarios"
    echo "[2] Protocolos"
    echo "[3] Monitor VPS"
    echo "[4] Instalar / Configurar Xray WS/TLS"
    echo "[5] Salir"
    echo -e "${GREEN}=======================================${RESET}"
    read -p "Selecciona una opción: " op
    case $op in
        1) bash /opt/zeroknithg/modules/user_manager.sh ;;
        2) bash /opt/zeroknithg/modules/protocols.sh ;;
        3) vps_monitor ;;
        4) bash /opt/zeroknithg/modules/xray.sh; install_xray; read -p "Enter para continuar" ;;
        5) exit ;;
        *) echo "Opción inválida"; sleep 2 ;;
    esac
done
EOF

chmod +x /opt/zeroknithg/panel.sh

echo "¡Instalación finalizada! Ejecuta: bash /opt/zeroknithg/panel.sh"

