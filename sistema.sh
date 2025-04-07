#!/bin/bash
# /etc/sshmanager/sistema.sh

RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; CYAN='\e[1;36m'; NC='\e[0m'

linha() { echo -e "${CYAN}══════════════════════════════════════════════════${NC}"; }
titulo() { linha; echo -e "${YELLOW}📊 INFORMAÇÕES DO SISTEMA${NC}"; linha; }

clear
titulo

echo -e "${GREEN}Hostname:${NC} $(hostname)"
echo -e "${GREEN}IP:${NC} $(curl -s ifconfig.me)"
echo -e "${GREEN}Sistema:${NC} $(lsb_release -d | cut -f2)"
echo -e "${GREEN}Uptime:${NC} $(uptime -p)"
echo -e "${GREEN}Data/Hora:${NC} $(date)"
echo -e "${GREEN}CPU:${NC} $(grep 'model name' /proc/cpuinfo | uniq | cut -d ':' -f2)"
echo -e "${GREEN}Cores:${NC} $(nproc)"
echo -e "${GREEN}RAM Total:${NC} $(free -h | grep Mem | awk '{print $2}')"
echo -e "${GREEN}RAM Usada:${NC} $(free -h | grep Mem | awk '{print $3}')"
echo -e "${GREEN}Disco Usado:${NC} $(df -h / | awk 'NR==2{print $3}') / $(df -h / | awk 'NR==2{print $2}')"
echo -e "${GREEN}Usuários Criados:${NC} $(cut -d: -f1 /etc/passwd | wc -l)"
linha

read -p "Pressione ENTER para voltar..."
clear
