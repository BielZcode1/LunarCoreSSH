#!/bin/bash

DB="/etc/vpnusers.db"
LOG="/var/log/vpnmanager.log"

# Funções de proteção do banco
proteger_db() {
    chattr +i "$DB" 2>/dev/null
}
desproteger_db() {
    chattr -i "$DB" 2>/dev/null
}
[ ! -f "$DB" ] && touch "$DB" && proteger_db

# Estilos de cores
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[1;31m'
NC='\033[0m' # No color

# Instalar Stunnel
instalar_stunnel() {
    clear
    echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
    echo -e "║        ${GREEN}Instalando SSL/TLS Proxy (Stunnel)${ORANGE}      ║"
    echo -e "╚═══════════════════════════════════════════════╝${NC}"
    sleep 1
    apt update -y && apt install stunnel4 -y
    cat > /etc/stunnel/stunnel.conf <<EOF
cert = /etc/stunnel/stunnel.pem
client = no
delay = yes
[ssh]
accept = 443
connect = 22
EOF
    openssl req -new -x509 -days 365 -nodes \
    -out /etc/stunnel/stunnel.pem \
    -keyout /etc/stunnel/stunnel.pem \
    -subj "/C=BR/ST=RJ/L=VPN/O=LunarCore/OU=SSH/CN=localhost"
    chmod 600 /etc/stunnel/stunnel.pem
    sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/stunnel4
    systemctl enable stunnel4 && systemctl restart stunnel4
    echo -e "${GREEN}✅ Stunnel instalado e rodando na porta 443!${NC}"
    sleep 3
}

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

# Monitoramento
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

# Submenu: Conexões para VPN
menu_conexoes() {
    while true; do
        clear
        echo -e "${ORANGE}╔═══════════════════════════════════════════════╗"
        echo -e "║       ${GREEN}Menu - Conexões para VPN${ORANGE}               ║"
        echo -e "╚═══════════════════════════════════════════════╝${NC}"
        echo -e "${BLUE}1) Instalar SSL/TLS Proxy (Stunnel)"
        echo -e "0) Voltar ao menu principal${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        read -p "Escolha uma opção: " conexao_opcao

        case $conexao_opcao in
            1) instalar_stunnel ;;
            0) break ;;
            *) echo -e "${RED}❌ Opção inválida!${NC}"; sleep 1 ;;
        esac
    done
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
        echo -e "6. Categoria: Conexões para VPN"
        echo -e "7. Fechar menu"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        read -p "Escolha uma opção: " opcao

        case $opcao in
            1) criar_usuario ;;
            2) deletar_usuario ;;
            3) listar_usuarios ;;
            4) usuarios_online ;;
            5) contar_usuarios ;;
            6) menu_conexoes ;;
            7) echo -e "${GREEN}Saindo do menu...${NC}"; sleep 1; break ;;
            *) echo -e "${RED}❌ Opção inválida!${NC}"; sleep 2 ;;
        esac
    done
}

menu
