#!/bin/bash
# /etc/sshmanager/criaruser.sh

RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; NC='\e[0m'
clear
read -p "🧑 Nome do usuário: " user
read -p "🔑 Senha: " pass
read -p "📅 Dias de validade: " dias

expira=$(date -d "+$dias days" +"%Y-%m-%d")
useradd -e $expira -M -s /bin/false $user
echo "$user:$pass" | chpasswd

echo -e "${GREEN}✅ Usuário '$user' criado com sucesso! Expira em: $expira${NC}"
read -p "Pressione ENTER para voltar..."
clear
