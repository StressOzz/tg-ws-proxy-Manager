#!/bin/sh

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RED="\033[1;31m"
BLUE="\033[0;34m"
DGRAY="\033[38;5;244m"
NC="\033[0m"

TG_URL="https://github.com/StressOzz/tg-ws-proxy-Manager/raw/main/tg-ws-proxy-main.zip"
# TG_URL="https://github.com/Flowseal/tg-ws-proxy/archive/refs/heads/master.zip"

echo 'sh <(wget -O - https://raw.githubusercontent.com/StressOzz/tg-ws-proxy-Manager/main/tg-ws-proxy-Manager.sh)' > /usr/bin/tpm; chmod +x /usr/bin/tpm

ARCH="$(awk -F\' '/DISTRIB_ARCH/ {print $2}' /etc/openwrt_release)"

if [ "$ARCH" = "mipsel_24kc" ] || [ "$ARCH" = "mips_24kc" ]; then
    echo -e "\n${RED}Архитектура ${NC}$ARCH${RED} не поддерживается !${NC}\n"
    exit 1
fi

if command -v opkg >/dev/null 2>&1; then
    PKG="opkg"
    UPDATE="opkg update"
    INSTALL="opkg install --force-reinstall"
else
    PKG="apk"
    UPDATE="apk update"
    INSTALL="apk add --force-reinstall"
fi

LAN_IP=$(uci get network.lan.ipaddr 2>/dev/null | cut -d/ -f1)

PAUSE() { echo -ne "\nНажмите Enter..."; read dummy; }

install_tg_ws() {

if [ "$(df -m /root 2>/dev/null | awk 'NR==2 {print $4+0}')" -lt 50 ]; then
    echo -e "\n${RED}Недостаточно свободного места!${NC}"
    PAUSE
    return 1
fi

echo -e "\n${MAGENTA}Обновляем пакеты${NC}"
$UPDATE

echo -e "${MAGENTA}Устанавливаем необходимые пакеты${NC}"
$INSTALL python3-light python3-pip python3-psutil python3-cryptography unzip

echo -e "${MAGENTA}Скачиваем и распаковываем tg-ws-proxy${NC}"

rm -rf "/root/tg-ws-proxy"

cd /root || exit 1

if ! wget -O tg-ws-proxy.zip "$TG_URL"; then
    echo -e "\n${RED}Ошибка скачивания архива${NC}\n"
    PAUSE
    return 1
fi

if ! unzip tg-ws-proxy.zip >/dev/null 2>&1; then
    echo -e "\n${RED}Ошибка распаковки${NC}\n"
    PAUSE
    return 1
fi

mv tg-ws-proxy-main tg-ws-proxy
rm -f tg-ws-proxy.zip

cd /root/tg-ws-proxy || exit 1

echo -e "${MAGENTA}Устанавливаем tg-ws-proxy${NC}"
pip install --no-deps --disable-pip-version-check --timeout 2 --retries 1 -e .

cat << 'EOF' > /etc/init.d/tg-ws-proxy
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/tg-ws-proxy --host 0.0.0.0
    procd_set_param respawn
    procd_close_instance
}
EOF

chmod +x /etc/init.d/tg-ws-proxy
/etc/init.d/tg-ws-proxy enable >/dev/null 2>&1
/etc/init.d/tg-ws-proxy start >/dev/null 2>&1

echo -e "\n${GREEN}Установка завершена${NC}"
PAUSE
}

delete_tg_ws() {
echo -e "\n${MAGENTA}Удаялем tg-ws-proxy${NC}"

echo -e "${CYAN}Останавливаем сервис${NC}"
/etc/init.d/tg-ws-proxy stop >/dev/null 2>&1
/etc/init.d/tg-ws-proxy disable >/dev/null 2>&1

echo -e "${CYAN}Удаляем ${NC}init.d${CYAN} скрипт${NC}"
rm -f /etc/init.d/tg-ws-proxy >/dev/null 2>&1

echo -e "${CYAN}Удаляем ${NC}tg-ws-proxy"
rm -rf /root/tg-ws-proxy >/dev/null 2>&1

echo -e "${CYAN}Удаляем пакеты и зависимости${NC}"
python3 -m pip uninstall -y tg-ws-proxy >/dev/null 2>&1
pip uninstall -y tg-ws-proxy >/dev/null 2>&1

local attempts=0
while [ $attempts -lt 10 ]; do
    if command -v opkg >/dev/null 2>&1; then
        opkg remove --autoremove --force-removal-of-dependent-packages python3-light python3-pip python3-psutil python3-cryptography unzip >/dev/null 2>&1
        CHECK_CMD="opkg list-installed"
    else
        apk del python3-light python3-pip python3-psutil python3-cryptography unzip >/dev/null 2>&1
        CHECK_CMD="apk info"
    fi
    
    if ! $CHECK_CMD | grep -q "python3-light\|python3-pip\|python3-psutil\|python3-cryptography"; then
        break
    fi
    
    attempts=$((attempts + 1))
done
    
    if [ $attempts -eq 10 ]; then
        echo -e "${RED}Некоторые пакеты не удалились! Повторите удаление!${NC}"
    fi
    
rm -rf /usr/lib/python* /usr/bin/python* /root/.cache/pip /root/.local/lib/python* /usr/bin/tg-ws-proxy* >/dev/null 2>&1

echo -e "\n${GREEN}Удаление завершино${NC}"
PAUSE
}

menu() {
clear
echo -e "╔═════════════════════════════════╗"
echo -e "║ ${BLUE}tg-ws-proxy by Flowseal Manager${NC} ║"
echo -e "╚═════════════════════════════════╝"
echo -e "                       ${DGRAY}by StressOzz${NC}\n"

if pgrep -f tg-ws-proxy >/dev/null 2>&1; then
    echo -e "${YELLOW}tg-ws-proxy:  ${GREEN}запущен${NC}"
elif [ -d "/root/tg-ws-proxy" ] || python3 -m pip show tg-ws-proxy >/dev/null 2>&1; then
    echo -e "${YELLOW}Статус tg-ws-proxy: ${RED}не запущен${NC}"
else
    echo -e "${YELLOW}Статус tg-ws-proxy: ${RED}не установлен${NC}"
fi

if pgrep -f tg-ws-proxy >/dev/null 2>&1; then
    PORT=$(netstat -lnpt 2>/dev/null | grep tg-ws-proxy | awk '{print $4}' | cut -d: -f2)
    echo -e "${YELLOW}адрес SOCKS5: ${NC}$LAN_IP:${PORT:-1080}"
fi

echo -e "\n${CYAN}1) ${GREEN}Установить${NC} tg-ws-proxy"
echo -e "${CYAN}2) ${GREEN}Удалить${NC} tg-ws-proxy"
echo -e "${CYAN}Enter) ${GREEN}Выход${NC}\n"
echo -en "${YELLOW}Выберите пункт: ${NC}"
read choice
case "$choice" in 
1) install_tg_ws ;;
2) delete_tg_ws ;;
*) echo; exit 0 ;;
esac
}
while true; do menu; done
