#!/bin/bash
# panel.sh - Panel Zero Knithg
# Integración completa de usuarios y protocolos

source /opt/zeroknithg/config.conf
DB_FILE="/opt/zeroknithg/database/users.db"

# Colores minimalistas
GREEN="\e[32m"
RESET="\e[0m"

# Función para mostrar banner inicial
show_banner() {
    clear
    echo -e "${GREEN}=======================================${RESET}"
    echo "        ZERO KNITHG - PANEL PRINCIPAL"
    echo -e "${GREEN}=======================================${RESET}"
    echo "Dominio: $DOMAIN | IP: $IP"
    echo -e "${GREEN}=======================================${RESET}"
}

# Mostrar info del VPS
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
        1)
            bash /opt/zeroknithg/modules/user_manager.sh
            ;;
        2)
            bash /opt/zeroknithg/modules/protocols.sh
            ;;
        3)
            vps_monitor
            ;;
        4)
            bash /opt/zeroknithg/modules/xray.sh
            install_xray
            read -p "Enter para continuar"
            ;;
        5)
            echo "Saliendo del panel..."
            exit
            ;;
        *)
            echo "Opción inválida"
            sleep 2
            ;;
    esac
done
