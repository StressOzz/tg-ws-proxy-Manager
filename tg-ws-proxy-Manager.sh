#!/bin/sh

GREEN="\033[1;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RED="\033[1;31m"
BLUE="\033[0;34m"
NC="\033[0m"

BIN_PATH_GO="/usr/bin/tg-ws-proxy-go"; INIT_PATH_GO="/etc/init.d/tg-ws-proxy-go"
BIN_PATH_RS="/usr/bin/tg-ws-proxy-rs"; INIT_PATH_RS="/etc/init.d/tg-ws-proxy-rs"
BIN_PATH="/usr/bin/tg-ws-proxy"; INIT_PATH="/etc/init.d/tg-ws-proxy"

TG_URL="https://github.com/Flowseal/tg-ws-proxy/archive/refs/heads/master.zip"

TMP_ARCHIVE="/tmp/tg-ws-proxy-rs.tar.gz"; TMP_DIR="/tmp/tg-ws-proxy-rs"

REQUIRED_PKGS="python3-light python3-pip python3-cryptography"

PAUSE() { echo -ne "\nНажмите Enter..."; read dummy; }

echo 'sh <(wget -O - https://raw.githubusercontent.com/StressOzz/tg-ws-proxy-Manager/main/tg-ws-proxy-Manager.sh)' > /usr/bin/tpm; chmod +x /usr/bin/tpm

if command -v opkg >/dev/null 2>&1; then
    PKG="opkg"
    UPDATE="opkg update"
    INSTALL="opkg install"
    CHECK_AVAIL="opkg list | cut -d ' ' -f1"
    PKG_IS_APK=0
else
    PKG="apk"
    UPDATE="apk update"
    INSTALL="apk add"
    CHECK_AVAIL="apk search -e"
    PKG_IS_APK=1
fi

######################################################################################################

get_arch_rs() {
    if command -v opkg >/dev/null 2>&1; then
        ARCH="$(opkg print-architecture | awk '{print $2}' | tail -n1)"
    elif command -v apk >/dev/null 2>&1; then
        ARCH="$(apk --print-arch 2>/dev/null)"
    fi

    case "$ARCH" in
        aarch64*)
            echo "tg-ws-proxy-aarch64-unknown-linux-musl.tar.gz"
        ;;
        x86_64)
            echo "tg-ws-proxy-x86_64-unknown-linux-musl.tar.gz"
        ;;
        *)
            echo -e "\n${RED}Архитектура не поддерживается: ${NC}$ARCH"
            PAUSE
            return 1
        ;;
    esac
}

remove_TG_RS() {
    echo -e "\n${MAGENTA}Удаляем TG WS Proxy Rs${NC}"
    /etc/init.d/tg-ws-proxy-rs stop >/dev/null 2>&1
    /etc/init.d/tg-ws-proxy-rs disable >/dev/null 2>&1
    rm -f "$BIN_PATH_RS"
    rm -f "$INIT_PATH_RS"
    echo -e "TG WS Proxy Rust ${GREEN}удалён!${NC}"
}

install_TG_RS() {
    echo -e "\n${MAGENTA}Установка TG WS Proxy Rust${NC}"

    ARCH_FILE="$(get_arch_rs)" || {
        echo -e "\n${RED}Архитектура не поддерживается:${NC} $(uname -m)"
        PAUSE
        return 1
    }

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${CYAN}Устанавливаем ${NC}curl"

        if command -v opkg >/dev/null 2>&1; then
            opkg update >/dev/null 2>&1 && opkg install curl >/dev/null 2>&1 || {
                echo -e "\n${RED}Ошибка установки curl${NC}"
                PAUSE
                return 1
            }
        elif command -v apk >/dev/null 2>&1; then
            apk update >/dev/null 2>&1 && apk add curl >/dev/null 2>&1 || {
                echo -e "\n${RED}Ошибка установки curl${NC}"
                PAUSE
                return 1
            }
        fi
    fi

    echo -e "${CYAN}Скачиваем и устанавливаем${NC} $ARCH_FILE"

    LATEST_TAG="$(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/valnesfjord/tg-ws-proxy-rs/releases/latest | sed 's#.*/tag/##')"
    [ -z "$LATEST_TAG" ] && {
        echo -e "\n${RED}Не удалось получить версию${NC} TG WS Proxy Rust"
        PAUSE
        return 1
    }

DOWNLOAD_URL="https://github.com/valnesfjord/tg-ws-proxy-rs/releases/download/$LATEST_TAG/$ARCH_FILE"

TMP_ARCHIVE="/tmp/tg-ws-proxy-rs.tar.gz"
TMP_DIR="/tmp/tg-ws-proxy-rs"

curl -L --fail -o "$TMP_ARCHIVE" "$DOWNLOAD_URL" >/dev/null 2>&1 || {
    echo -e "\n${RED}Ошибка скачивания${NC}"
    PAUSE
    return 1
}

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

tar -xzf "$TMP_ARCHIVE" -C "$TMP_DIR" || {
    echo -e "\n${RED}Ошибка распаковки${NC}"
    PAUSE
    return 1
}

mv "$TMP_DIR"/tg-ws-proxy* "$BIN_PATH_RS"

chmod +x "$BIN_PATH_RS"

cat << EOF > /etc/init.d/tg-ws-proxy-rs
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/tg-ws-proxy-rs --host 0.0.0.0 --port 2443 --secret $SECRET
    procd_set_param respawn
    procd_close_instance
}
EOF

    chmod +x "$INIT_PATH_RS"
    /etc/init.d/tg-ws-proxy-rs enable
    /etc/init.d/tg-ws-proxy-rs start

    if pidof tg-ws-proxy-rs >/dev/null 2>&1; then
        echo -e "${GREEN}Сервис ${NC}TG WS Proxy Rust${GREEN} запущен!${NC}"
    else
        echo -e "\n${RED}Сервис TG WS Proxy Rust не запущен!${NC}"
    fi
}

tg_RS() {
    if [ -f "$BIN_PATH_RS" ] && [ -f "$INIT_PATH_RS" ]; then
        remove_TG_RS
        PAUSE
    elif [ "$(df -m /root 2>/dev/null | awk 'NR==2 {print $4+0}')" -lt 5 ]; then
        echo -e "\n${RED}Недостаточно свободного места!${NC}"
        PAUSE
        return 1
    else
        install_TG_RS
        PAUSE
    fi
}

##############################################################################################################

install_tg_ws() {
if [ "$(df -m /root 2>/dev/null | awk 'NR==2 {print $4+0}')" -lt 25 ]; then
    echo -e "\n${RED}Недостаточно свободного места!${NC}"
    PAUSE
    return 1
fi

echo -e "\n${MAGENTA}Обновляем пакеты${NC}"
if ! $UPDATE; then
    echo -e "\n${RED}Ошибка при обновлении пакетов!${NC}"
    PAUSE
    return 1
fi

echo -e "\n${MAGENTA}Проверяем доступность пакетов Python${NC}"
failed=0
for pkg in $REQUIRED_PKGS; do
    if sh -c "$CHECK_AVAIL" | grep -qw "$pkg"; then
        echo -e "${GREEN}[OK]   ${NC}$pkg"
    else
        echo -e "${RED}[FALL] ${NC}$pkg"
        failed=1
    fi
done
if [ $failed -ne 0 ]; then
    echo -e "\n${RED}Архитектура не поддерживается! Установка невозможна!${NC}"
    PAUSE
    return 1
fi

echo -e "\n${MAGENTA}Устанавливаем необходимые пакеты${NC}"
$INSTALL python3-light python3-pip python3-cryptography unzip
echo -e "\n${MAGENTA}Скачиваем и распаковываем TG WS Proxy Phyton${NC}"
rm -rf "/root/tg-ws-proxy"
cd /root
if ! wget -O tg-ws-proxy.zip "$TG_URL"; then
    echo -e "\n${RED}Ошибка скачивания архива!${NC}"
    PAUSE
    return 1
fi
if ! unzip tg-ws-proxy.zip >/dev/null 2>&1; then
    echo -e "\n${RED}Ошибка распаковки!${NC}"
    PAUSE
    return 1
fi
mv tg-ws-proxy-main tg-ws-proxy
rm -f tg-ws-proxy.zip
cd /root/tg-ws-proxy

echo -e "\n${MAGENTA}Устанавливаем TG WS Proxy Phyton${NC}"
pip install --root-user-action=ignore --no-deps --disable-pip-version-check --timeout 2 --retries 1 -e .

cat << EOF > /etc/init.d/tg-ws-proxy
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
    procd_open_instance
    procd_set_param command /usr/bin/tg-ws-proxy --host 0.0.0.0 --secret $SECRET
    procd_set_param respawn
    procd_close_instance
}
EOF

chmod +x /etc/init.d/tg-ws-proxy
/etc/init.d/tg-ws-proxy enable >/dev/null 2>&1
/etc/init.d/tg-ws-proxy start >/dev/null 2>&1

if pgrep -f tg-ws-proxy >/dev/null 2>&1; then
    echo -e "\n${GREEN}Сервис ${NC}TG WS Proxy Phyton${GREEN} запущен!${NC}"
else
    echo -e "\n${RED}Ошибка установки!${NC}"
fi
PAUSE
}

delete_tg_ws() {
echo -e "\n${MAGENTA}Удаляем TG WS Proxy Phyton${NC}"

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
attempts=0
while [ $attempts -lt 10 ]; do
    if command -v opkg >/dev/null 2>&1; then
        opkg remove --autoremove --force-removal-of-dependent-packages python3-light python3-pip python3-cryptography unzip >/dev/null 2>&1
        CHECK_CMD="opkg list-installed"
    else
        apk del python3-light python3-pip python3-cryptography unzip >/dev/null 2>&1
        CHECK_CMD="apk info"
    fi
    
    if ! $CHECK_CMD | grep -q "python3-light\|python3-pip\|python3-cryptography"; then
        break
    fi    
    attempts=$((attempts + 1))
done

    if [ $attempts -eq 10 ]; then
        echo -e "\n${RED}Некоторые пакеты не удалились!${NC}"
    fi
    
rm -rf /usr/lib/python* /usr/bin/python* /root/.cache/pip /root/.local/lib/python* /usr/bin/tg-ws-proxy >/dev/null 2>&1

echo -e "\n${GREEN}Удаление завершено!${NC}"
PAUSE
}

##############################################################################################################

get_arch() {
    if command -v opkg >/dev/null 2>&1; then
        ARCH="$(opkg print-architecture | awk '{print $2}' | tail -n1)"
    elif command -v apk >/dev/null 2>&1; then
        ARCH="$(apk --print-arch 2>/dev/null)"
    fi

    case "$ARCH" in
        aarch64*)
            echo "tg-ws-proxy-openwrt-aarch64"
        ;;
        armv7*|armhf|armv7l)
            echo "tg-ws-proxy-openwrt-armv7"
        ;;
        mipsel_24kc|mipsel*)
            echo "tg-ws-proxy-openwrt-mipsel_24kc"
        ;;
        mips_24kc|mips*)
            echo "tg-ws-proxy-openwrt-mips_24kc"
        ;;
        x86_64)
            echo "tg-ws-proxy-openwrt-x86_64"
        ;;
        *)
            echo "Неизвестная архитектура: $ARCH"
            return 1
        ;;
    esac
}

remove_TG() {
    echo -e "\n${MAGENTA}Удаляем TG WS Proxy Go${NC}"
    /etc/init.d/tg-ws-proxy-go stop >/dev/null 2>&1
    /etc/init.d/tg-ws-proxy-go disable >/dev/null 2>&1
    rm -f "$BIN_PATH_GO"
    rm -f "$INIT_PATH_GO"
    echo -e "TG WS Proxy Go ${GREEN}удалён!${NC}"
}

install_TG() {
    echo -e "\n${MAGENTA}Установка TG WS Proxy Go${NC}"

    ARCH_FILE="$(get_arch)" || {
        echo -e "\n${RED}Архитектура не поддерживается:${NC} $(uname -m)"
        PAUSE
        return 1
    }

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${CYAN}Устанавливаем ${NC}curl"

        if command -v opkg >/dev/null 2>&1; then
            opkg update >/dev/null 2>&1 && opkg install curl >/dev/null 2>&1 || {
                echo -e "\n${RED}Ошибка установки curl${NC}"
                PAUSE
                return 1
            }
        elif command -v apk >/dev/null 2>&1; then
            apk update >/dev/null 2>&1 && apk add curl >/dev/null 2>&1 || {
                echo -e "\n${RED}Ошибка установки curl${NC}"
                PAUSE
                return 1
            }
        fi
    fi

    echo -e "${CYAN}Скачиваем и устанавливаем${NC} $ARCH_FILE"

    LATEST_TAG="$(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/d0mhate/-tg-ws-proxy-Manager-go/releases/latest | sed 's#.*/tag/##')"
    [ -z "$LATEST_TAG" ] && {
        echo -e "\n${RED}Не удалось получить версию${NC} TG WS Proxy Go"
        PAUSE
        return 1
    }

    DOWNLOAD_URL="https://github.com/d0mhate/-tg-ws-proxy-Manager-go/releases/download/$LATEST_TAG/$ARCH_FILE"

    curl -L --fail -o "$BIN_PATH_GO" "$DOWNLOAD_URL" >/dev/null 2>&1 || {
        echo -e "\n${RED}Ошибка скачивания${NC}"
        PAUSE
        return 1
    }

    chmod +x "$BIN_PATH_GO"

    printf '%s\n' \
        '#!/bin/sh /etc/rc.common' \
        'START=99' \
        'USE_PROCD=1' \
        'start_service() { procd_open_instance; procd_set_param command /usr/bin/tg-ws-proxy-go --host 0.0.0.0 --port 1080; procd_set_param respawn; procd_set_param stdout /dev/null; procd_set_param stderr /dev/null; procd_close_instance; }' \
        > "$INIT_PATH_GO"

    chmod +x "$INIT_PATH_GO"
    /etc/init.d/tg-ws-proxy-go enable
    /etc/init.d/tg-ws-proxy-go start

    if pidof tg-ws-proxy-go >/dev/null 2>&1; then
        echo -e "${GREEN}Сервис ${NC}TG WS Proxy Go${GREEN} запущен!${NC}"
    else
        echo -e "\n${RED}Сервис TG WS Proxy Go не запущен!${NC}"
    fi
}

tg_GO() {
    if [ -f "$BIN_PATH_GO" ] && [ -f "$INIT_PATH_GO" ]; then
        remove_TG
        PAUSE
    elif [ "$(df -m /root 2>/dev/null | awk 'NR==2 {print $4+0}')" -lt 5 ]; then
        echo -e "\n${RED}Недостаточно свободного места!${NC}"
        PAUSE
        return 1
    else
        install_TG
        PAUSE
    fi
}

##############################################################################################################

menu() {

SECRET="$(head -c16 /dev/urandom | hexdump -e '16/1 "%02x"')"

clear
echo -e "╔══════════════════════════════════╗"
echo -e "║ ${BLUE}TG WS Proxy Manager by StressOzz${NC} ║"
echo -e "╚══════════════════════════════════╝\n"

if pgrep -f tg-ws-proxy >/dev/null 2>&1; then
    echo -e "${YELLOW}TG WS Proxy: ${GREEN}запущен${NC}"
elif [ -d "/root/tg-ws-proxy" ] || python3 -m pip show tg-ws-proxy >/dev/null 2>&1; then
    echo -e "${YELLOW}TG WS Proxy: ${RED}не запущен${NC}"
else
    echo -e "${YELLOW}TG WS Proxy: ${RED}не установлен${NC}"
fi

if pidof tg-ws-proxy-go >/dev/null 2>&1 && [ -f "$BIN_PATH_GO" ] && [ -f "$INIT_PATH_GO" ]; then 
echo -e "\n${YELLOW}Настройки ${CYAN}Go${YELLOW} версии в TG:${NC}"
    echo -e " ${YELLOW}Типы прокси:${NC} SOCKS5"
    echo -e " ${YELLOW}Хост:${NC} $(uci get network.lan.ipaddr 2>/dev/null | cut -d/ -f1)"
    echo -e " ${YELLOW}Порт:${NC} 1080${NC}"
fi

if pgrep -f tg-ws-proxy >/dev/null 2>&1 && [ -f "$BIN_PATH" ] && [ -f "$INIT_PATH" ] && [ -f /root/tg-ws-proxy/README.md ]; then
    SECRET_IN="$(sed -n 's/.*--secret[[:space:]]*\([0-9a-fA-F]\{32\}\).*/\1/p' "$INIT_PATH")"
    echo -e "\n${YELLOW}Настройки ${CYAN}Phyton${YELLOW} версии в TG:${NC}"
    echo -e " ${YELLOW}Типы прокси:${NC} MTProto"
    echo -e " ${YELLOW}Хост:${NC} $(ip -4 route get 1 | awk '{print $7; exit}')"
    echo -e " ${YELLOW}Порт:${NC} 1443"
    echo -e " ${YELLOW}Ключ:${NC} dd$SECRET_IN"
    echo -e "${YELLOW}Ссылка для подключения:${NC}\ntg://proxy?server=$(ip -4 route get 1 | awk '{print $7; exit}')&port=1443&secret=dd$SECRET_IN"
fi

if pgrep -f tg-ws-proxy-rs >/dev/null 2>&1 && [ -f "$BIN_PATH_RS" ] && [ -f "$INIT_PATH_RS" ]; then
    SECRET_IN_RS="$(sed -n 's/.*--secret[[:space:]]*\([0-9a-fA-F]\{32\}\).*/\1/p' "$INIT_PATH_RS")"
    echo -e "\n${YELLOW}Настройки ${CYAN}Rust${YELLOW} версии в TG:${NC}"
    echo -e " ${YELLOW}Типы прокси:${NC} MTProto"
    echo -e " ${YELLOW}Хост:${NC} $(ip -4 route get 1 | awk '{print $7; exit}')"
    echo -e " ${YELLOW}Порт:${NC} 2443"
    echo -e " ${YELLOW}Ключ:${NC} dd$SECRET_IN"
    echo -e "${YELLOW}Ссылка для подключения:${NC}\ntg://proxy?server=$(ip -4 route get 1 | awk '{print $7; exit}')&port=2443&secret=dd$SECRET_IN_RS"
fi

echo -e "\n${CYAN}1)${GREEN} $( [ -f "$BIN_PATH_GO" ] && [ -f "$INIT_PATH_GO" ] && echo -e "Удалить ${NC}TG WS Proxy Go" || echo "Установить ${NC}TG WS Proxy Go" )"
echo -e "${CYAN}2)${GREEN} $( [ -f "$BIN_PATH_RS" ] && [ -f "$INIT_PATH_RS" ] && echo -e "Удалить ${NC}TG WS Proxy Rust" || echo "Установить ${NC}TG WS Proxy Rust" )"
echo -e "${CYAN}3)${GREEN} $( [ -f "$BIN_PATH" ] && [ -f "$INIT_PATH" ] && [ -f /root/tg-ws-proxy/README.md ] && echo -e "Удалить ${NC}TG WS Proxy Phyton" || echo "Установить ${NC}TG WS Proxy Phyton" )"
echo -e "${CYAN}Enter) ${GREEN}Выход${NC}\n"
echo -en "${YELLOW}Выберите пункт: ${NC}"
read choice
case "$choice" in
1) tg_GO ;;
2) tg_RS ;;
3) if [ -f "$BIN_PATH" ] && [ -f "$INIT_PATH" ]; then delete_tg_ws; else install_tg_ws; fi ;;
*) echo; exit 0 ;;
esac
}
while true; do menu; done
