# Kitsune ↔ NekoBox — ревизия функционала

Легенда статуса Kitsune:
- ✅ — готово и работает
- 🟡 — UI готов, движок (engine.py) дорабатывается
- ⚪ — пока нет

Ядро у обоих одно и то же — **nekobox_core (патченый sing-box)**, поэтому скорость/качество соединения идентичны.

| Область | NekoBox | Kitsune сейчас | Как будет работать (паритет) |
|---|---|---|---|
| **Ядро** | nekobox_core via Thrift | тот же nekobox_core via CLI (`sing-box run -c`) ✅ | то же ядро → та же скорость |
| **Подключение/отключение** | ✅ | engine.start/stop ✅ (проверено: ядро стартует, порт поднимается); связка с UI 🟡 | UI-кнопка → engine.start(профиль) |
| **Протоколы** (vless/vmess/trojan/ss) | ✅ | генерация конфига ✅ (vless/vmess/trojan/ss валидируются ядром) | профиль → sing-box outbound |
| **Протоколы exotic** (mieru/juicity/amnezia/wg/xhttp…) | ✅ (их форк) | ✅ WireGuard endpoint (peer/local/allowed/mtu/psk) + xhttp transport (полная UI-форма); ⚪ mieru/juicity/amnezia пока без UI | дописать config-gen под каждый |
| **Редактор сервера** | ✅ | ✅ UI (5 протоколов, TLS/Reality/transport) | поля → outbound JSON |
| **Импорт по ссылке** (vless/vmess/trojan/ss) | ✅ | ✅ парсер ссылок | вставка из буфера → профили |
| **Подписки/группы** | ✅ (HTTP-загрузка, авто-обновление) | ✅ реальная HTTP-загрузка (base64/плейн) + парс в группу, fav сохраняется | fetch URL → парс → группа |
| **Поиск/сортировка/Авто-лучший** | частично (сорт) | ✅ (поиск+сорт по пингу+авто) | равно/лучше |
| **Избранное** | ⚪/слабо | ✅ (звезда+фильтр+меню) | лучше |
| **Маршрутизация** (правила, geosite/geoip) | ✅ (rule-sets) | ✅ config-gen route (domain/geosite/geoip/ip/process/port → proxy/direct/reject) + remote rule-set'ы; UI drag-сорт ✅ | правила → sing-box route + rule-sets |
| **Финальный outbound / обход LAN/региона** | ✅ | ✅ (LAN `ip_is_private`, RU-direct, final proxy/direct/блок) | пресеты → route rules |
| **Блокировка рекламы** | ✅ | ✅ (geosite-category-ads-all → reject) | geosite-ads rule-set |
| **DNS** (удал./прямой/fake-ip) | ✅ | ✅ (remote via proxy + direct + опц. fake-ip, новый формат 1.13) | поля → sing-box dns |
| **TUN** | ✅ (+ elevated) | ✅ tun inbound (3 стека, auto_route, mtu) + auto_detect_interface + hijack-dns; UAC-перезапуск; адаптер создаётся, wintun встроена. Подтверждено пользователем на нескольких подписках (полная скорость 100/100), наш core реально несёт системный трафик | tun inbound + UAC |
| **Системный прокси** | ✅ | ✅ (winreg + WinINET refresh, учёт кастомного порта) | реестр Internet Settings → 127.0.0.1:port |
| **Mux / sniffing** | ✅ | ✅ (multiplex smux/yamux/h2mux на outbound; sniff-rule на route) | поля → outbound multiplex / sniff action |
| **Поделиться / QR** | ✅ | ✅ (ссылка из полей + QR) | равно |
| **Трей** | ✅ (меню) | ✅ + анимированный китсунэ | лучше (анимация) |
| **Глобальный хоткей** | ✅ (QHotkey) | ✅ (WinAPI RegisterHotKey) | равно |
| **Темы** | QSS-темы | ✅ dark/light/**kitsune** | равно/своё |
| **Статистика трафика ↓/↑** | ✅ | ✅ Clash API `/connections` (down/upTotal → МБ за сессию) | через Clash API ядра |
| **Пинг/URL-тест серверов** | ✅ | ✅ активный пинг = URL-delay (Clash API); список серверов = реальный TCP-пинг | Clash API delay / TCP |
| **Лог соединения** | ✅ (панель) | ✅ rolling-буфер 2000 строк, скрыта по умолчанию (Settings → ДИАГНОСТИКА → Открыть), авто-скролл, копировать/очистить | читать stdout ядра в панель |
| **Авто-подключение на старте** | ✅ | ✅ (последний/быстрейший) | равно |
| **Бесшовное переключение** | ✅ | ✅ (UI), движок 🟡 | reload конфига ядра |

## Что уже точно равно/лучше
Ядро (то же), импорт ссылок, поделиться/QR, поиск+сорт+авто, избранное, трей (анимация), хоткей, темы, авто-подключение.

## Что осталось до полного паритета (движок, по убыванию важности)
1. ✅ Связать `engine.py` с `Backend` (connect/disconnect/status реально).
2. ✅ Системный прокси (выставление в Windows) — самый частый режим.
3. ✅ config-gen: маршрутизация (route rules + rule-sets), DNS, mux, sniffing.
4. ✅ Clash API: статистика ↓/↑ и реальный пинг (URL delay) + реальный exit IP.
5. ✅ Реальная загрузка подписок по URL (base64/плейн → парс → группа).
6. ✅ TUN (адаптер+UAC проверены инструментально; маршрутизация подтверждена пользователем на нескольких подписках, полная скорость).
7. ✅ WireGuard endpoint + xhttp transport (UI+config-gen). mieru/juicity/amnezia — отдельный шаг, нужны UI-формы.
8. ✅ Панель логов (скрыта по умолчанию, открывается из Settings → ДИАГНОСТИКА).

## Движковый роадмап завершён (§9.1–§9.8). Следующие шаги — раздел «9.А» в DEV_NOTES (идеи юзера).
8. Панель логов.

Вывод: **UI — паритет/лучше уже сейчас**; по **движку** базис (то же ядро + генерация/запуск) работает,
остальное — поступательная дописка config-gen и подключение к UI. Потолок возможностей — как у NekoBox (ядро одно).
