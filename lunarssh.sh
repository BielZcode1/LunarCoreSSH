#!/bin/bash

# Cores
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
NC='\e[0m'

# Funções visuais
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
  return 1
}

# Segurança: Root
if [[ "$EUID" -ne 0 ]]; then
  clear
  echo -e "${RED}❌ Este script deve ser executado como root!${NC}"
  return 1
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

# Essenciais
linha
barra_animada "Instalando pacotes essenciais"
apt install -y curl git screen net-tools unzip openssh-server > /dev/null 2>&1

# Criar pasta
linha
barra_animada "Criando diretório do sistema"
mkdir -p /etc/sshmanager

# Baixar arquivos do painel
REPO_URL="https://github.com/seuusuario/sshmanager" # altere aqui
DEST_DIR="/etc/sshmanager"

linha
barra_animada "Clonando arquivos do GitHub"
git clone "$REPO_URL" "$DEST_DIR" > /dev/null 2>&1

barra_animada "Aplicando permissões"
chmod +x $DEST_DIR/*.sh

barra_animada "Criando comando global"
ln -sf $DEST_DIR/menu.sh /usr/bin/sshmanager

linha
echo -e "${GREEN}✅ Instalação concluída!${NC}"
linha
echo -e "${YELLOW}🟢 Execute com:${NC} ${CYAN}sshmanager${NC}\n"

read -p "Pressione ENTER para sair..."
clear
