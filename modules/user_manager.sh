#!/bin/bash
# modules/user_manager.sh
# User Manager Zero Knithg

source /opt/zeroknithg/config.conf
source /opt/zeroknithg/core/logger.sh
DB_FILE="/opt/zeroknithg/database/users.db"

# Crear usuario
create_user() {
    clear
    echo "==== CREAR USUARIO ===="
    read -p "Nombre de usuario: " SSH_USER
    read -p "Días de expiración: " EXPIRY

    # Generar UUID para Xray
    UUID=$(cat /proc/sys/kernel/random/uuid)

    # Calcular fecha de expiración
    EXP_DATE=$(date -d "+$EXPIRY days" +%Y-%m-%d)

    # Guardar en DB
    echo "$SSH_USER|$UUID|$EXP_DATE" >> $DB_FILE

    echo "Usuario $SSH_USER creado correctamente."
    echo "UUID: $UUID"
    echo "Expira: $EXP_DATE"

    log_action "Usuario $SSH_USER creado, expira $EXP_DATE"

    # Generar link VMess automáticamente
    VMESS_JSON=$(cat <<EOF
{
  "v": "2",
  "ps": "$SSH_USER",
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

    VMESS_LINK="vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"
    echo "Link VMess TLS listo para copiar:"
    echo "$VMESS_LINK"
    read -p "Enter para continuar"
}

# Listar usuarios
list_users() {
    clear
    echo "==== USUARIOS ACTIVOS ===="
    if [[ -s "$DB_FILE" ]]; then
        while IFS="|" read USER UUID EXPIRA
        do
            echo "Usuario: $USER | UUID: $UUID | Expira: $EXPIRA"
        done < $DB_FILE
    else
        echo "No hay usuarios activos."
    fi
    read -p "Enter para continuar"
}

# Borrar usuario
delete_user() {
    clear
    echo "==== ELIMINAR USUARIO ===="
    read -p "Nombre de usuario a eliminar: " USER_DEL

    if grep -q "^$USER_DEL|" $DB_FILE; then
        grep -v "^$USER_DEL|" $DB_FILE > /tmp/tmp_db && mv /tmp/tmp_db $DB_FILE
        echo "Usuario $USER_DEL eliminado correctamente."
        log_action "Usuario $USER_DEL eliminado"
    else
        echo "Usuario no encontrado."
    fi
    read -p "Enter para continuar"
}

# Cambiar banner
change_banner() {
    clear
    echo "==== CAMBIAR BANNER ===="
    read -p "Ruta del archivo del nuevo banner: " BANNER_PATH
    if [[ -f "$BANNER_PATH" ]]; then
        cp "$BANNER_PATH" /etc/issue.net
        echo "Banner actualizado correctamente."
        log_action "Banner actualizado"
    else
        echo "Archivo no encontrado."
    fi
    read -p "Enter para continuar"
}

# Menú User Manager
while true
do
    clear
    echo "======================================="
    echo "         ZERO KNITHG - USER MANAGER"
    echo "======================================="
    echo "[1] Crear usuario"
    echo "[2] Listar usuarios"
    echo "[3] Eliminar usuario"
    echo "[4] Cambiar banner"
    echo "[5] Volver al panel"
    echo "======================================="
    read -p "Selecciona una opción: " op

    case $op in
        1) create_user ;;
        2) list_users ;;
        3) delete_user ;;
        4) change_banner ;;
        5) break ;;
        *) echo "Opción inválida"; sleep 2 ;;
    esac
done