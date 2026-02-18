#!/bin/bash
# core/system_info.sh

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