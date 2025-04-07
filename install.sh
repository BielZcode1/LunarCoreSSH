#!/bin/bash
set +H
clear

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31m⚠️  Desculpe, você precisa executar como root!\033[0m"
    read -p "Pressione Enter para sair..."
    clear
    exit 0  # <- encerra apenas o script, sem logout
fi

cd "$HOME"
tput civis
echo -ne "\033[1;33mAGUARDE \033[1;37m- \033[1;33m["
