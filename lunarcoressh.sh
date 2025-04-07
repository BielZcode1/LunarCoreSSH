#!/bin/bash

# Cores
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
NC='\e[0m'

# Verifica se está sendo sourced
is_sourced() {
  [ "${BASH_SOURCE[0]}" != "$0" ]
}

# Estilo visual
linha() {
  echo -e "${BLUE}══════════════════════════════════════════════════${NC}"
}

barra_animada() {
  echo -ne "${YELLOW}→ $1 ${NC}"
  spin='|/-\\'
  for i in $(seq 1 15); do
    i=$(( (i+1) %4 ))
    printf "\b${spin:$i:1}"
    sleep 0.1
  done
  echo -e " ${GREEN}[OK]${NC}"
}

barra_carregando() {
  echo -ne "${CYAN}$1${NC}"
  for i in $(seq 1 30); do
    echo -ne "${GREEN}▇"
    sleep 0.02
  done
  echo -e "${NC}"
}

cancelar_script() {
  echo -e "\n${RED}[!] Instalação cancelada. Saindo...${NC}"
  sleep 1
  clear
  if is_sourced; then
    return 0
  else
    exit 0
  fi
}

# Root
if [[ "$EUID" -ne 0 ]]; then
  clear
  echo -e "${RED}❌ Este script deve ser executado como root!${NC}"
  if is_sourced; then return 1; else exit 1; fi
fi

# Ctrl+C
trap cancelar_script SIGINT

clear
linha
echo -e "${CYAN}        🚀 INSTALADOR DO SSHMANAGER (VPN MOBILE) 🚀${NC}"
linha

read -p $'\nDeseja instalar o SSHMANAGER? (s/n): ' resp
[[ "$resp" != "s" && "$resp" != "S" ]] && cancelar_script

clear
linha
echo -e "${YELLOW}➡️  Preparando o sistema para instalação...${NC}"
linha
barra_carregando "Aguarde "
sleep 0.5

# Atualização inicial
linha
barra_animada "Atualizando pacotes"
apt update -y > /dev/null 2>&1
apt upgrade -y > /dev/null 2>&1

# Pacotes essenciais
linha
barra_animada "Instalando pacotes essenciais"
apt install -y curl wget git screen net-tools unzip openssh-server > /dev/null 2>&1

# Criar diretório
linha
barra_animada "Criando diretório do sistema"
rm -rf /etc/sshmanager > /dev/null 2>&1
mkdir -p /etc/sshmanager
cd /etc/sshmanager

# Lista de scripts para baixar
SCRIPTS=(
  menu.sh
  sistema.sh
  criaruser.sh
  deleteuser.sh
  menu_conexoes.sh
  monitorar.sh
  conexoes.sh
)

# Baixando scripts
linha
for script in "${SCRIPTS[@]}"; do
  barra_animada "Baixando $script"
  wget -q --show-progress "https://raw.githubusercontent.com/BielZcode1/LunarCoreSSH/main/$script"
done

# Permissões e comando global
barra_animada "Aplicando permissões"
chmod +x *.sh

barra_animada "Criando comando global"
ln -sf /etc/sshmanager/menu.sh /usr/bin/sshmanager

linha
echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
linha
echo -e "${YELLOW}🟢 Execute com:${NC} ${CYAN}sshmanager${NC}\n"

read -p "Pressione ENTER para sair..."
clear
