#!/bin/bash
# run_zero.sh - Script “todo en uno” para Zero Knithg Panel
# Autor: Zero Knithg

# Variables
REPO="https://github.com/Z3r0Kn1ght-KYZ/Script-Kyz-.git"
DIR="/opt/zeroknithg"

# 1️⃣ Clonar o actualizar repositorio
if [ ! -d "$DIR" ]; then
    echo "Clonando repositorio en $DIR..."
    git clone $REPO $DIR
else
    echo "Repositorio ya existe, actualizando..."
    cd $DIR
    git pull
fi

# 2️⃣ Dar permisos de ejecución a todos los scripts
echo "Dando permisos de ejecución..."
chmod +x $DIR/full_install.sh
chmod +x $DIR/panel.sh
chmod +x $DIR/modules/*.sh
chmod +x $DIR/core/*.sh

# 3️⃣ Ejecutar instalador completo
echo "Ejecutando full_install.sh..."
bash $DIR/full_install.sh

# 4️⃣ Abrir el panel principal
echo "Abriendo panel Zero Knithg..."
bash $DIR/panel.sh