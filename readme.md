# Установка
> [!IMPORTANT]
>Для установки **tg-ws-proxy** необходимо не менее **50** МБ свободного места в корневом разделе.
>
>Установка может занять от **2** до **5** минут. Не прерывайте процесс!

- в SSH выполните
```
sh <(wget -O - https://raw.githubusercontent.com/StressOzz/tg-ws-proxy-Manager/main/tg-ws-proxy-Manager.sh)
```
- В меню нажмите **1**

# Настройка Telegram

В **Telegram Desktop**:
- Настройки **→** Продвинутые настройки **→** Тип соеденения **→** Добавить прокси
- Выберите **SOCKS5**
- В поле **Хост** укажите **IP**, в **Порт** укажите **порт**
- Нажмите Сохранить

В **приложении Telegram**:
- Настройки **→** Данные и память **→** Настройки прокси **→** Добавить прокси
- Выберите **SOCKS5**
- В поле **Сервер** укажите **IP**, в **Порт** укажите **порт**
- Нажмите на галочку в верхнем правом углу

# Удаление
- в SSH выполните
```
sh <(wget -O - https://raw.githubusercontent.com/StressOzz/tg-ws-proxy-Manager/main/tg-ws-proxy-Manager.sh)
```
В меню нажмите **2**

> [!IMPORTANT]
> При удалении будут также удалены пакеты **python**, **gi**t и все зависимости, связанные с ними.

# Благодарности

- **tg-ws-proxy** by [*Flowseal*](https://github.com/Flowseal)
- [**инструкция**](https://github.com/StressOzz/Zapret-Manager/issues/357#issue-4108723815) by [*gre4ka*](https://github.com/gre4kapi)
