# Установка
> [!IMPORTANT]
> Для **TG WS Proxy MTProto** необходимо ≈ **25** МБ свободного места в корневом разделе 
>
> Для **TG WS Proxy GO** необходимо ≈ **5** МБ свободного места в корневом разделе 

- в SSH выполните
```
sh <(wget -O - https://raw.githubusercontent.com/StressOzz/tg-ws-proxy-Manager/main/tg-ws-proxy-Manager.sh)
```
---

# Настройка Telegram

В **Telegram Desktop**:
- Настройки **→** Продвинутые настройки **→** Тип соеденения **→** Добавить прокси
- Выберите **SOCKS5** / **MTPROTO**
- В поле **Хост** укажите **IP**, в **Порт** укажите **порт**
- Для **MTPROTO** в **Ключ** укажите **ключ**
- Нажмите Сохранить

В **приложении Telegram**:
- Настройки **→** Данные и память **→** Настройки прокси **→** Добавить прокси
- Выберите **SOCKS5** / **MTPROTO**
- В поле **Сервер** укажите **IP**, в **Порт** укажите **порт**
- Для **MTPROTO** в **Ключ** укажите **ключ**
- Нажмите на галочку в верхнем правом углу

--- 

> [!WARNING]
> Пакеты **Python** для архитектур **mips_24kc / mipsel_24kc** могут быть недоступны в некоторых версиях **OpenWrt** !
>
> Скрипт проверит возможность установки пакетов на вашем устройстве.

> [!IMPORTANT]
> При удалении **TG WS Proxy MTProto** будут удалены пакеты **python3-light**, **python3-pip**, **python3-cryptography**, **unzip** и все зависимости, связанные с ними.

---

# Благодарности

- [**tg-ws-proxy**](https://github.com/Flowseal/tg-ws-proxy) by [*Flowseal*](https://github.com/Flowseal)
- [**tg-ws-proxy-go**](https://github.com/d0mhate/-tg-ws-proxy-Manager-go) by [*d0mhate*](https://github.com/d0mhate)
- [**инструкция**](https://github.com/StressOzz/Zapret-Manager/issues/357#issue-4108723815) by [*gre4ka*](https://github.com/gre4kapi)
