# Установка
> [!IMPORTANT]
> Для **TG WS Proxy Python** необходимо ≈ **25** МБ свободного места в корневом разделе
>
> Для **TG WS Proxy Go** и **TG WS Proxy Rust** необходимо ≈ **5** МБ свободного места в корневом разделе
>
> Пакеты **Python** для архитектур **mips_24kc / mipsel_24kc** могут быть недоступны в некоторых версиях **OpenWrt** !
>
> **TG WS Proxy Go**   только для архитектур **aarch64**, **armv7**, **x86_64**, **mipsel** и **mips**
>
> **TG WS Proxy Rust** только для архитектур **aarch64**, **armv7**, **x86_64** и **mipsel**


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

> [!IMPORTANT]
> При удалении **TG WS Proxy Python** будут удалены пакеты **python3-light**, **python3-pip**, **python3-cryptography**, **unzip** и все зависимости, связанные с ними.

---

<table>
  <tr>
    <td>
      <a href="https://github.com/StressOzz#-поддержать-проект">
        <img width="280" height="130" src="https://github.com/user-attachments/assets/2999757b-fbf3-4149-bf6c-48bf3e241529">
      </a>
    </td>
    <td>
      <a href="https://github.com/StressOzz/StressKVN">
        <img width="270" height="80" src="https://github.com/user-attachments/assets/7dbb964b-bb79-461a-9f47-9ca73323ebac">
      </a>
    </td>
  </tr>
</table>

---

# Благодарности

- [**tg-ws-proxy**](https://github.com/Flowseal/tg-ws-proxy) by [*Flowseal*](https://github.com/Flowseal)
- [**tg-ws-proxy-go**](https://github.com/d0mhate/-tg-ws-proxy-Manager-go) by [*d0mhate*](https://github.com/d0mhate)
- [**tg-ws-proxy-rs**](https://github.com/valnesfjord/tg-ws-proxy-rs) by [*valnesfjord*](https://github.com/valnesfjord)
- [**инструкция**](https://github.com/StressOzz/Zapret-Manager/issues/357#issue-4108723815) by [*gre4ka*](https://github.com/gre4kapi)
