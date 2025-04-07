#!/bin/bash
# /etc/sshmanager/menu_conexoes.sh

services=(dropbear stunnel4 squid badvpn-udpgw)
names=("Dropbear" "Stunnel" "Squid" "BadVPN")
instaladores=("apt install -y dropbear" "apt install -y stunnel4" "apt install -y squid" "wget -qO- https://github.com/BielZcode1/badvpn/raw/main/install.sh | bash")

RED='\e[1;31m'; GREEN='\e[1;32m'; CYAN='\e[1;36m'; YELLOW='\e[1;33m'; NC='\e[0m'
linha() { echo -e "${CYAN}══════════════════════════════════════════════════${NC}"; }

while true; do
  clear
  linha
  echo -e "${CYAN}🔌 GERENCIAR CONEXÕES E PORTAS${NC}"
  linha
  for i in "${!services[@]}"; do
    if systemctl list-unit-files | grep -q "${services[$i]}"; then
      status=$(systemctl is-active ${services[$i]})
      [[ "$status" == "active" ]] && icon="🟢 Ativo" || icon="🔴 Inativo"
    else
      icon="${RED}❌ Não instalado${NC}"
    fi
    echo -e "$((i+1)) - ${names[$i]} [ $icon ]"
  done
  echo -e "9 - Mostrar portas abertas"
  echo -e "0 - Voltar"
  linha
  read -p "Escolha uma opção: " opt

  case $opt in
    1|2|3|4)
      idx=$((opt-1))
      if ! systemctl list-unit-files | grep -q "${services[$idx]}"; then
        echo -e "${YELLOW}🔧 Instalando ${names[$idx]}...${NC}"
        eval "${instaladores[$idx]}"
      fi
      if systemctl is-active --quiet ${services[$idx]}; then
        systemctl stop ${services[$idx]}
        echo -e "${RED}⛔ ${names[$idx]} desativado.${NC}"
      else
        systemctl start ${services[$idx]}
        echo -e "${GREEN}✅ ${names[$idx]} ativado.${NC}"
      fi
      sleep 2
      ;;
    9)
      clear
      echo -e "${CYAN}🔍 PORTAS ABERTAS NO HOST:${NC}"
      ss -tunlp | awk '{print $5, $7}' | sort | uniq | grep -E 'LISTEN|:'
      echo ""
      read -p "Pressione ENTER para voltar..."
      ;;
    0) break ;;
    *) echo -e "${RED}Opção inválida!${NC}"; sleep 1 ;;
  esac
done
