#!/bin/bash

RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; CYAN='\e[1;36m'; NC='\e[0m'
linha() { echo -e "${CYAN}══════════════════════════════════════════════════${NC}"; }

clear
linha
echo -e "${CYAN}🖥️  MONITORAMENTO DO SISTEMA VPS${NC}"
linha

echo -e "${YELLOW}📅 Data e Hora:${NC} $(date)"
echo -e "${YELLOW}🧠 CPU:${NC} $(grep -m1 'model name' /proc/cpuinfo | cut -d ':' -f2 | xargs)"
echo -e "${YELLOW}📈 Uso de CPU:${NC} $(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')%"
echo -e "${YELLOW}💾 RAM Total:${NC} $(free -h | awk '/Mem:/ {print $2}')"
echo -e "${YELLOW}💾 RAM Usada:${NC} $(free -h | awk '/Mem:/ {print $3}')"
echo -e "${YELLOW}🗂️  Espaço em disco:${NC} $(df -h / | awk 'NR==2 {print $3 "/" $2}')"
echo -e "${YELLOW}🌐 IP Público:${NC} $(curl -s ifconfig.me)"
echo -e "${YELLOW}🏗️  Arquitetura:${NC} $(uname -m)"

linha
echo -e "${GREEN}👥 USUÁRIOS CRIADOS:${NC}"
cut -d: -f1 /etc/passwd | grep -vE '^(root|nobody)' | grep -v '/nologin' | grep -v 'false' | grep -v '^_'
linha

echo -e "${GREEN}🔐 USUÁRIOS CONECTADOS VIA SSH:${NC}"
who | awk '{print $1, $5}' | sort | uniq
linha

echo ""
read -p "Pressione ENTER para voltar..."
clear
