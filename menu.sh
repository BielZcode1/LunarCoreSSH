#!/bin/bash

# Cores vibrantes
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
ORANGE='\e[38;5;208m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[96m'
NC='\e[0m'

# Linha estilizada
linha() {
  echo -e "${ORANGE}══════════════════════════════════════════════════════════${NC}"
}

# Informações do sistema
RAM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')
RAM_USADA=$(free -h | awk '/Mem:/ {print $3}')
CPU_CORES=$(nproc)
CPU_MODEL=$(awk -F: '/model name/ {print $2}' /proc/cpuinfo | head -n1)
USUARIOS=$(cut -d: -f1 /etc/passwd | grep -vE "^(root|nobody|_.*)" | wc -l)
DATA_HORA=$(date '+%d/%m/%Y %H:%M:%S')
REDE=$(ip route get 1 | awk '{print $NF;exit}')
IP_PUB=$(curl -s ifconfig.me)
HOST=$(hostname)

# Loop do menu
while true; do
  clear
  linha
  echo -e "${CYAN}       ▸ ${ORANGE}SSHMANAGER - PAINEL PRINCIPAL${CYAN} ◂${NC}"
  linha
  echo -e "${YELLOW}📆 Data/Hora:     ${NC}$DATA_HORA"
  echo -e "${YELLOW}🖥️ Host:           ${NC}$HOST"
  echo -e "${YELLOW}🌐 IP Público:     ${NC}$IP_PUB"
  echo -e "${YELLOW}📡 Interface:      ${NC}$REDE"
  echo -e "${YELLOW}🧠 RAM Usada:      ${NC}$RAM_USADA / $RAM_TOTAL"
  echo -e "${YELLOW}🧮 CPU:            ${NC}${CYAN}$CPU_CORES núcleos${NC} - ${MAGENTA}$CPU_MODEL${NC}"
  echo -e "${YELLOW}👥 Usuários Criados:${NC} $USUARIOS"
  linha
  echo -e "${GREEN} 1) ${NC}➕ Criar Usuário"
  echo -e "${GREEN} 2) ${NC}❌ Remover Usuário"
  echo -e "${GREEN} 3) ${NC}📊 Monitorar Usuários"
  echo -e "${GREEN} 4) ${NC}🔌 Conexões & Serviços"
  echo -e "${GREEN} 5) ${NC}📋 Informações da VPS"
  echo -e "${RED} 6) ${NC}🚪 Sair do Menu"
  linha
  read -p "▸ Escolha uma opção: " op

  case $op in
    1) bash /etc/sshmanager/criaruser.sh ;;
    2) bash /etc/sshmanager/deleteuser.sh ;;
    3) bash /etc/sshmanager/monitor.sh ;;
    4) bash /etc/sshmanager/menu_conexoes.sh ;;
    5) bash /etc/sshmanager/sistema.sh ;;
    6)
      echo -e "${ORANGE}Saindo do menu... pressione ENTER para finalizar.${NC}"
      read
      clear
      return
      ;;
    *) echo -e "${RED}⚠️ Opção inválida!${NC}"; sleep 1 ;;
  esac
done
