#!/bin/bash

DB="/etc/vpnusers.db"
LOG="/var/log/vpnmanager.log"

# Estilos de cores
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m'

# Proteção do banco
proteger_db() {
    chattr +i "$DB" 2>/dev/null
}
desproteger_db() {
    chattr -i "$DB" 2>/dev/null
}
[ ! -f "$DB" ] && touch "$DB" && proteger_db

# Criar usuário
criar_usuario() {
    clear
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║          ${GREEN}Criar novo usuário VPN${ORANGE}           ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    read -p "Nome do usuário: " usuario
    read -p "Senha: " senha
    read -p "Dias de validade: " dias

    if id "$usuario" &>/dev/null; then
        echo -e "${RED}⚠️  Usuário já existe!${NC}"
        sleep 2
        return
    fi

    useradd -e $(date -d "+$dias days" +%Y-%m-%d) -M -s /bin/false "$usuario"
    echo "$usuario:$senha" | chpasswd

    desproteger_db
    echo "$usuario|$(date +%Y-%m-%d)|$dias" >> "$DB"
    proteger_db

    echo -e "${GREEN}✅ Usuário $usuario criado com sucesso!${NC}"
    echo "$(date) - Criado: $usuario" >> "$LOG"
    sleep 2
}

# Deletar usuário
deletar_usuario() {
    clear
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║          ${RED}Remover usuário VPN${ORANGE}              ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    read -p "Nome do usuário para deletar: " usuario

    if ! id "$usuario" &>/dev/null; then
        echo -e "${RED}⚠️  Usuário não existe.${NC}"
        sleep 2
        return
    fi

    userdel "$usuario"
    desproteger_db
    sed -i "/^$usuario|/d" "$DB"
    proteger_db
    echo -e "${GREEN}✅ Usuário $usuario deletado.${NC}"
    echo "$(date) - Deletado: $usuario" >> "$LOG"
    sleep 2
}

# Listar usuários
listar_usuarios() {
    clear
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║         ${BLUE}Lista de usuários VPN${ORANGE}            ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    echo ""
    cut -d'|' -f1,2 "$DB" | column -t -s '|'
    echo ""
    read -p "Pressione Enter para voltar ao menu..."
}

# Ver online
usuarios_online() {
    clear
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║         ${GREEN}Usuários Online no SSH${ORANGE}           ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    who
    echo ""
    read -p "Pressione Enter para voltar ao menu..."
}

# Contar usuários
contar_usuarios() {
    clear
    total=$(wc -l < "$DB")
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║       ${GREEN}Total de usuários cadastrados${ORANGE}       ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    echo -e "${BLUE}Total:${NC} $total"
    echo ""
    read -p "Pressione Enter para voltar ao menu..."
}

# Monitoramento do sistema
monitorar_sistema() {
    echo -e "${BLUE}━━━━━━━━━━━ MONITORAMENTO DO SISTEMA ━━━━━━━━━━━${NC}"
    echo -e "${ORANGE}Arquitetura:${NC} $(uname -m)"
    echo -e "${ORANGE}Hora atual:${NC}  $(date)"
    echo -e "${ORANGE}Uptime:${NC}      $(uptime -p)"
    echo -e "${ORANGE}CPU:${NC}         $(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4"%"}')"
    echo -e "${ORANGE}RAM:${NC}         $(free -m | awk '/Mem:/ {printf "%.2f%% usado (%s MB de %s MB)\n", $3/$2*100, $3, $2}')"
    echo -e "${ORANGE}Usuários Online:${NC} $(who | wc -l)"

    echo -e "\n${BLUE}━━━━━━━━━━━━━━━ REDE ━━━━━━━━━━━━━━━${NC}"
    INTERFACE=$(ip route get 8.8.8.8 | awk -- '{print $5; exit}')
    if [ -n "$INTERFACE" ]; then
        IP=$(ip -4 addr show "$INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        RX=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
        TX=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)
        RX_MB=$(echo "scale=2; $RX / 1048576" | bc)
        TX_MB=$(echo "scale=2; $TX / 1048576" | bc)

        echo -e "${ORANGE}Interface:${NC}   $INTERFACE"
        echo -e "${ORANGE}IP Local:${NC}    $IP"
        echo -e "${ORANGE}Tráfego:${NC}     ↓ $RX_MB MB / ↑ $TX_MB MB"
    else
        echo -e "${RED}iwconfig não disponível (modo Wi-Fi não detectado).${NC}"
    fi
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Conexão HTTP Injector
conexao_http_injector() {
    clear
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║   ${GREEN}Configuração HTTP Injector para celular${ORANGE}  ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"

    IP_SERVER=$(curl -s ifconfig.me)
    PORTA_SSH=22

    read -p "Informe um host (ex: m.youtube.com): " host_http
    read -p "Nome do usuário SSH: " usuario
    read -p "Senha do usuário: " senha

    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━ CONFIGURAÇÃO ━━━━━━━━━━━━━━${NC}"
    echo -e "${ORANGE}🔸 Payload:${NC}"
    echo -e "GET http://$host_http/ HTTP/1.1[crlf]Host: $host_http[crlf]Connection: Keep-Alive[crlf]User-Agent: [ua][crlf][crlf]"

    echo -e "\n${ORANGE}🔸 SSH Host:${NC} $IP_SERVER"
    echo -e "${ORANGE}🔸 Porta:${NC} $PORTA_SSH"
    echo -e "${ORANGE}🔸 Usuário:${NC} $usuario"
    echo -e "${ORANGE}🔸 Senha:${NC} $senha"

    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Copie os dados acima no seu HTTP Injector.${NC}"
    echo ""
    read -p "Pressione Enter para voltar ao menu..."
}

# Menu principal
menu() {
    while true; do
        clear
        echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
        echo -e "║         ${GREEN}LUNARCORE SSH MANAGER v1.0${ORANGE}            ║"
        echo -e "╚═══════════════════════════════════════════════╝${NC}"
        monitorar_sistema
        echo -e "${BLUE}━━━━━━━━━━━━━ MENU PRINCIPAL ━━━━━━━━━━━━━${NC}"
        echo -e "1. Criar usuário VPN"
        echo -e "2. Remover usuário"
        echo -e "3. Listar usuários"
        echo -e "4. Ver usuários online"
        echo -e "5. Total de usuários"
        echo -e "6. Fechar menu"
        echo -e "7. Categoria: Conexões para VPN (HTTP Injector)"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        read -p "Escolha uma opção: " opcao

        case $opcao in
            1) criar_usuario ;;
            2) deletar_usuario ;;
            3) listar_usuarios ;;
            4) usuarios_online ;;
            5) contar_usuarios ;;
            6) echo -e "${GREEN}Saindo do menu...${NC}"; sleep 1; break ;;
            7) conexao_http_injector ;;
            *) echo -e "${RED}❌ Opção inválida!${NC}"; sleep 2 ;;
        esac
    done
}

menu
