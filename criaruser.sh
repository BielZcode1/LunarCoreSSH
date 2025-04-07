#!/bin/bash

# Cores
RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; NC='\e[0m'

# Função para linha
linha() {
  echo -e "${YELLOW}══════════════════════════════════════════════════${NC}"
}

# Cabeçalho
clear
linha
echo -e "${GREEN}👤 CRIAÇÃO DE USUÁRIO SSH${NC}"
linha

# Entrada de dados
read -p "Digite o nome do usuário: " usuario
[[ -z "$usuario" ]] && echo -e "${RED}❌ Nome de usuário inválido!${NC}" && exit 1

# Verificar se já existe
id -u "$usuario" &>/dev/null
if [[ $? -eq 0 ]]; then
  echo -e "${RED}⚠️  O usuário '${usuario}' já existe!${NC}"
  exit 1
fi

read -p "Digite a senha do usuário: " senha
[[ -z "$senha" ]] && echo -e "${RED}❌ Senha inválida!${NC}" && exit 1

read -p "Validade (em dias): " dias
[[ ! "$dias" =~ ^[0-9]+$ ]] && echo -e "${RED}❌ Valor inválido para validade!${NC}" && exit 1

# Calcular data de expiração
expiracao=$(date -d "+$dias days" +"%Y-%m-%d")

# Criar o usuário
useradd -e "$expiracao" -s /bin/false -M "$usuario"
echo "$usuario:$senha" | chpasswd

# Confirmação
linha
echo -e "${GREEN}✅ Usuário criado com sucesso!${NC}"
echo -e "${YELLOW}🔐 Usuário:${NC} $usuario"
echo -e "${YELLOW}🔑 Senha:${NC} $senha"
echo -e "${YELLOW}📅 Expira em:${NC} $expiracao"
linha

read -p "Pressione ENTER para voltar..."
clear
