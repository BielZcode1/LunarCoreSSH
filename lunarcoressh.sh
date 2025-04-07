#!/bin/bash

DB="/etc/vpnusers.db"
LOG="/var/log/vpnmanager.log"

# Protege o arquivo de banco de dados
proteger_db() {
    chattr +i "$DB" 2>/dev/null
}

# Desprotege o arquivo de banco de dados
desproteger_db() {
    chattr -i "$DB" 2>/dev/null
}

# Cria banco de dados se não existir
[ ! -f "$DB" ] && touch "$DB" && proteger_db

# Criação de usuário VPN
criar_usuario() {
    read -p "Nome do usuário: " usuario
    read -p "Senha: " senha
    read -p "Dias de validade: " dias

    if id "$usuario" &>/dev/null; then
        echo "Usuário já existe."
        return
    fi

    useradd -e $(date -d "+$dias days" +%Y-%m-%d) -M -s /bin/false "$usuario"
    echo "$usuario:$senha" | chpasswd

    desproteger_db
    echo "$usuario|$(date +%Y-%m-%d)|$dias" >> "$DB"
    proteger_db

    echo "Usuário $usuario criado com validade de $dias dias."
    echo "$(date) - Criado: $usuario" >> "$LOG"
}

# Deletar usuário VPN
deletar_usuario() {
    read -p "Nome do usuário para deletar: " usuario
    if ! id "$usuario" &>/dev/null; then
        echo "Usuário não existe."
        return
    fi

    userdel "$usuario"
    desproteger_db
    sed -i "/^$usuario|/d" "$DB"
    proteger_db

    echo "Usuário $usuario deletado."
    echo "$(date) - Deletado: $usuario" >> "$LOG"
}

# Listar todos os usuários
listar_usuarios() {
    echo "Usuários cadastrados:"
    cut -d'|' -f1,2 "$DB" | column -t -s '|'
}

# Monitorar conexões ativas (usuários logados via SSH)
usuarios_online() {
    echo "Usuários online:"
    who
}

# Quantidade de usuários
contar_usuarios() {
    total=$(wc -l < "$DB")
    echo "Total de usuários cadastrados: $total"
}

# Monitorar sistema
monitorar_sistema() {
    echo "=== SISTEMA ==="
    echo "Arquitetura: $(uname -m)"
    echo "Hora: $(date)"
    echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4"%"}')"
    echo "RAM: $(free -m | awk '/Mem:/ {printf "%.2f%% usado (%s MB de %s MB)\n", $3/$2*100, $3, $2}')"
    echo "Usuários Online: $(who | wc -l)"
    echo "Rede:"
    if command -v iwconfig &> /dev/null; then
        iwconfig 2>/dev/null | grep -i --color=never 'ssid\|link'
    else
        echo "iwconfig não disponível (modo Wi-Fi não detectado)."
    fi
}

# Menu principal
menu() {
    clear
    echo "=== LUNARCORE SSH MANAGER ==="
    echo "1. Criar usuário VPN"
    echo "2. Deletar usuário"
    echo "3. Listar usuários"
    echo "4. Ver usuários online"
    echo "5. Contar usuários"
    echo "6. Monitorar sistema"
    echo "7. Sair"
    echo "============================="
    read -p "Escolha uma opção: " opcao

    case $opcao in
        1) criar_usuario ;;
        2) deletar_usuario ;;
        3) listar_usuarios ;;
        4) usuarios_online ;;
        5) contar_usuarios ;;
        6) monitorar_sistema ;;
        7) exit ;;
        *) echo "Opção inválida." ;;
    esac

    read -p "Pressione Enter para voltar ao menu..."
    menu
}

menu
