#!/bin/bash
# /etc/sshmanager/deleteuser.sh

RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; NC='\e[0m'
clear
read -p "🧹 Nome do usuário para remover: " user

if id "$user" >/dev/null 2>&1; then
  userdel "$user"
  echo -e "${GREEN}✅ Usuário '$user' removido com sucesso.${NC}"
else
  echo -e "${RED}❌ Usuário '$user' não encontrado.${NC}"
fi

read -p "Pressione ENTER para voltar..."
clear
