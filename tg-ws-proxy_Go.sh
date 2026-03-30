#!/bin/sh

BIN_PATH="/usr/bin/tg-ws-proxy-go"
INIT_PATH="/etc/init.d/tg-ws-proxy-go"

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
NC="\033[0m"

get_arch() {
    case "$(uname -m)" in
        aarch64)
            echo "tg-ws-proxy-openwrt-aarch64"
            ;;
        armv7*|armv7l)
            echo "tg-ws-proxy-openwrt-armv7"
            ;;
        mipsel*)
            echo "tg-ws-proxy-openwrt-mipsel_24kc"
            ;;
        mips*)
            echo "tg-ws-proxy-openwrt-mips_24kc"
            ;;
        x86_64)
            echo "tg-ws-proxy-openwrt-x86_64"
            ;;
        *)
            return 1
            ;;
    esac
}

get_router_ip() {
    uci get network.lan.ipaddr 2>/dev/null | cut -d/ -f1
}

remove_all() {
    echo -e "${MAGENTA}Удаляем tg-ws-proxy-go${NC}"

    /etc/init.d/tg-ws-proxy-go stop >/dev/null 2>&1
    /etc/init.d/tg-ws-proxy-go disable >/dev/null 2>&1

    rm -f "$BIN_PATH"
    rm -f "$INIT_PATH"

    echo -e "\ntg-ws-proxy-go ${GREEN}удалён!\n${NC}"
}

install_all() {
echo -e "${MAGENTA}Установка tg-ws-proxy-go${NC}"

ARCH_FILE="$(get_arch)" || { echo -e "\n${RED}Неизвестная архитектура:${NC} $(uname -m)"; exit 1; }

echo -e "${CYAN}Скачиваем и устанавливаем${NC} $ARCH_FILE"

LATEST_TAG="$(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/d0mhate/-tg-ws-proxy-Manager-go/releases/latest | sed 's#.*/tag/##')"

DOWNLOAD_URL="https://github.com/d0mhate/-tg-ws-proxy-Manager-go/releases/download/$LATEST_TAG/$ARCH_FILE"

curl -L --fail -o "$BIN_PATH" "$DOWNLOAD_URL" >/dev/null 2>&1 || { echo -e "\n${RED}Ошибка скачивания${NC}"; exit 1; }

chmod +x "$BIN_PATH"

    cat << 'EOF' > "$INIT_PATH"
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/tg-ws-proxy-go --host 0.0.0.0 --port 1080
    procd_set_param respawn
    procd_set_param stdout /dev/null
    procd_set_param stderr /dev/null
    procd_close_instance
}
EOF

    chmod +x "$INIT_PATH"

    /etc/init.d/tg-ws-proxy-go enable
    /etc/init.d/tg-ws-proxy-go start

    IP="$(get_router_ip)"

    if pidof tg-ws-proxy-go >/dev/null 2>&1; then
        echo -e "${GREEN}Сервис ${NC}tg-ws-proxy-go${GREEN} запущен!${NC}"
        echo -e "\n${YELLOW}адрес SOCKS5:${NC} ${NC}${IP}:1080\n"
    else
        echo -e "\n${RED}Сервис tg-ws-proxy-go не запущен!${NC}\n"
    fi
}

main() {

clear

if ! command -v curl >/dev/null 2>&1; then
    echo -e "${CYAN}Устанавливаем ${NC}curl"

    if command -v opkg >/dev/null 2>&1; then
        opkg update >/dev/null 2>&1 && opkg install curl >/dev/null 2>&1 || { echo -e "\n${RED}Ошибка установки curl${NC}"; exit 1; }
    elif command -v apk >/dev/null 2>&1; then
        apk update >/dev/null 2>&1 && apk add curl >/dev/null 2>&1 || { echo -e "\n${RED}Ошибка установки curl${NC}"; exit 1; }
    fi
fi

    if [ -f "$BIN_PATH" ] || [ -f "$INIT_PATH" ]; then
        remove_all
    else
        install_all
    fi
}

main "$@"
