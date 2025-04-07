#!/bin/bash

RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; CYAN='\e[1;36m'; NC='\e[0m'
linha() { echo -e "${CYAN}══════════════════════════════════════════════════${NC}"; }

clear
linha
echo -e "${CYAN}👥 MONITORAMENTO DE USUÁRIOS SSH${NC}"
linha

echo -e "${GREEN}📋 USUÁRIOS CRIADOS NO SISTEMA:${NC}"
cut -d: -f1 /etc/passwd | grep -vE '^(root|nobody)' | while read user; do
  shell=$(getent passwd "$user" | cut -d: -f7)
  [[ "$shell" == *"nologin"* || "$shell" == *"false"* ]] && continue
  echo -e "${YELLOW}↳ $user${NC}"
done

linha
echo -e "${GREEN}🔐 USUÁRIOS CONECTADOS VIA SSH:${NC}"
who | awk '{print $1}' | sort | uniq | while read online; do
  echo -e "${CYAN}🟢 $online${NC}"
done

linha
echo ""
read -p "Pressione ENTER para voltar..."
clear
