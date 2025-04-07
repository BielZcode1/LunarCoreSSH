#!/bin/bash

# Cores
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
NC='\e[0m'

# Limpa ao entrar
clear

# Funções visuais
linha() {
  echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
}

titulo() {
  linha
  echo -e "${CYAN}             🌙 PAINEL SSHMANAGER - LUNARSSH 🌙${NC}"
  linha
}

menu() {
  echo -e "${YELLOW}Selecione uma opção:${NC}"
  echo -e "${GREEN}[1]${NC} Criar usuário VPN"
  echo -e "${GREEN}[2]${NC} Remover usuário VPN"
  echo -e "${GREEN}[3]${NC} Monitoramento (Online, Limites)"
  echo -e "${GREEN}[4]${NC} Gerenciar conexões (Dropbear, Stunnel, Squid, BadVPN)"
  echo -e "${GREEN}[5]${NC} Informações do sistema"
  echo -e "${GREEN}[0]${NC} Sair para o terminal"
}

# Loop principal
while true; do
  clear
  titulo
  menu
  linha
  read -p $'\n➡️  Digite sua opção: ' opcao

  case $opcao in
    1)
      clear
      bash /etc/sshmanager/criaruser.sh
      read -p $'\nPressione ENTER para voltar ao menu...'
      ;;
    2)
      clear
      bash /etc/sshmanager/deleteuser.sh
      read -p $'\nPressione ENTER para voltar ao menu...'
      ;;
    3)
      clear
      bash /etc/sshmanager/monitorar.sh
      read -p $'\nPressione ENTER para voltar ao menu...'
      ;;
    4)
      clear
      bash /etc/sshmanager/menu_conexoes.sh
      read -p $'\nPressione ENTER para voltar ao menu...'
      ;;
    5)
      clear
      bash /etc/sshmanager/sistema.sh
      read -p $'\nPressione ENTER para voltar ao menu...'
      ;;
    0)
      echo -e "${RED}Saindo do painel...${NC}"
      sleep 1
      clear
      break
      ;;
    *)
      echo -e "${RED}Opção inválida!${NC}"
      sleep 1
      ;;
  esac
done
