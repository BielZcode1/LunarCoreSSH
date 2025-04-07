#!/bin/bash

# Cores
RED='\e[1;31m'; GREEN='\e[1;32m'; YELLOW='\e[1;33m'; CYAN='\e[1;36m'; NC='\e[0m'

# Função para linha estilizada
linha() {
  echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
}

# Clear e cabeçalho
clear
linha
echo -e "${CYAN}📊 MONITORAMENTO DO SISTEMA VPS${NC}"
linha

# CPU
cpu_model=$(grep -m 1 "model name" /proc/cpuinfo | cut -d ':' -f2 | sed 's/^ //')
cpu_cores=$(grep -c ^processor /proc/cpuinfo)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')

echo -e "${YELLOW}🧠 CPU:${NC} $cpu_model ($cpu_cores núcleos)"
echo -e "${YELLOW}📈 Uso da CPU:${NC} $cpu_usage"

# Memória
total_mem=$(free -m | awk '/^Mem:/ {print $2}')
used_mem=$(free -m | awk '/^Mem:/ {print $3}')
free_mem=$(free -m | awk '/^Mem:/ {print $4}')

echo -e "${YELLOW}💾 Memória RAM:${NC} Total: ${total_mem}MB | Usada: ${used_mem}MB | Livre: ${free_mem}MB"

# Disco
disk_info=$(df -h / | awk 'NR==2 {print "Total: "$2" | Usado: "$3" | Livre: "$4" | Uso: "$5}')
echo -e "${YELLOW}🗃️  Disco:${NC} $disk_info"

# Rede
ip=$(hostname -I | awk '{print $1}')
rx=$(cat /proc/net/dev | grep eth0 | awk '{print $2}')
tx=$(cat /proc/net/dev | grep eth0 | awk '{print $10}')
rx_mb=$(echo "scale=2; $rx / 1048576" | bc)
tx_mb=$(echo "scale=2; $tx / 1048576" | bc)

echo -e "${YELLOW}🌐 IP Local:${NC} $ip"
echo -e "${YELLOW}📡 Tráfego de Rede:${NC} ↓ ${rx_mb}MB / ↑ ${tx_mb}MB"

# Uptime
uptime_info=$(uptime -p | sed 's/up //')
echo -e "${YELLOW}⏳ Uptime:${NC} $uptime_info"

# Data e hora
echo -e "${YELLOW}🕒 Data e Hora:${NC} $(date "+%d/%m/%Y %H:%M:%S")"

linha
echo ""
read -p "Pressione ENTER para voltar..."
clear
