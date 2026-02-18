#!/bin/bash
# core/logger.sh

log_action() {
    local MESSAGE="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $MESSAGE" >> /opt/zeroknithg/database/actions.log
}