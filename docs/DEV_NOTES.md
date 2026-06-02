# Kitsune — БИБА (мастер-контекст для продолжения после сжатия)

> Команда пользователя **«обнови бибу»** = обновить ЭТОТ файл (docs/DEV_NOTES.md) актуальным состоянием.
> Это авторитетный документ. Источник правды — код (`app.py`, `qml/App/*`, `engine.py`).
> Старый `…/nekobox-ui/HANDOFF.md` — УСТАРЕЛ (там старый план C++-форка); актуальное — здесь.

## 0. TL;DR
Проект **Kitsune** — десктоп VPN-клиент (Windows). Репозиторий **github.com/Tawreos228/KitsuneVPN** (PRIVATE).
Локально: `C:\Users\danii\Documents\KitsuneVPN`.
- **UI:** PySide6 + QML (Qt Quick) — готов и отполирован (эппловский стиль, анимации, 3 темы).
- **Движок:** Python (`engine.py`) управляет **ядром sing-box** как отдельным процессом.
  По умолчанию берётся **`core/nekobox_core.exe`** (патченый sing-box, больше протоколов) через CLI `sing-box run -c`;
  если его нет — официальный `core/sing-box.exe`. Ядро то же, что у NekoBox → **скорость/качество идентичны**.
- Сейчас UI работает на **моковом** `Backend` (в app.py). `engine.py` уже умеет генерить конфиг/валидировать/
  запускать-останавливать ядро, но **ещё НЕ связан с Backend** (это след. шаг).

## 1. ПРАВИЛА/ТРЕБОВАНИЯ пользователя (соблюдать!)
- **Панель логов — СКРЫТА.** В обычном виде клиента её не должно быть видно. Открывается ТОЛЬКО отдельной
  кнопкой в Settings по желанию юзера. (Реализовать так, когда дойдём до логов.)
- Проект «чисто свой», **без брендинга NekoBox** в UI/репо и без атрибуции (в т.ч. без "Claude" в коммитах).
  (Использование их core-бинаря как процесса — это технический выбор движка, не брендинг.)
- Общение по-русски. По одной задаче за раз. После правок: smoke-тест → скриншот → перезапуск → краткий отчёт.
- Эстетика: сдержанный Apple, мягкие цвета в тёмной теме (кольцо не должно «бить в глаза»).
- Честность: где паритет с NekoBox, где наши добавки, где ещё не сделано.

## 2. Решения и ПОЧЕМУ
- **Не форкаем C++ NekoBox.** Причины: их «движок» = sing-box core (Go) + C++-обвязка, вплетённая в их Qt-приложение
  (= снова форк); GPL-3.0 (при раздаче обязал бы открыть исходники + сохранить атрибуцию — против «чистого своего»);
  тяжёлая сборка (статический Qt + Thrift + Docker). Python+sing-box: чисто, легко, собирается PyInstaller.
- **Качество = от ядра sing-box** (то же, что у NekoBox). Python не в «горячем пути» данных.
- **Берём их core-бинарь** (nekobox_core.exe) ради экзотических протоколов (mieru/juicity/amnezia/xhttp/kcp/
  vless-encryption), которых нет в официальном sing-box. Дёргать как отдельный процесс — лицензионно чисто.

## 3. Стек / запуск / команды
- PySide6 6.11 / Qt 6.11, Python 3.14. QtQuick.Controls **Basic**. Шрифты: Segoe UI Variable / Segoe Fluent Icons.
- Зависимости: PySide6, segno (QR), Pillow (gen_icon).
- Ядро: `python core/fetch_core.py` тянет официальный sing-box; для патченого — положить `nekobox_core.exe` в `core/`
  (берётся из установленного NekoBox: `%AppData%\NekoBox\nekobox_core.exe`). `core/*.exe` в .gitignore (не коммитим).
- Запуск приложения: `python app.py` (окно + трей; закрытие → трей).
- Smoke-тест QML: `python _smoketest.py` (ждать LOADED:True / WARN:0). (Файл лежит в старом nekobox-ui; при нужде создать тут.)
- Скриншоты: `QT_QPA_PLATFORM=windows python _capture.py` (offscreen даёт «тофу» вместо шрифтов!).
- Перезапуск: глушить старый процесс (PowerShell: убить python.exe/pythonw.exe c CommandLine `*app.py*`).

## 4. Файлы
- **app.py:** `Backend` (МОК-движок: всё состояние + Property/Slot/Signal; таймеры имитируют connect/ping/tick);
  `HotkeyManager` (WinAPI RegisterHotKey + нативный фильтр); `AppController` (трей с анимацией, жизненный цикл UI,
  снимок настроек); `main()`.
- **engine.py:** РЕАЛЬНЫЙ движок (готов, но не подключён к Backend): `core_cmd()` (авто-выбор nekobox_core/sing-box),
  `build_outbound`/`gen_config` (vless/vmess/trojan/ss + TLS/Reality/uTLS + transport ws/grpc/httpupgrade + mixed inbound + route),
  `check_config` (sing-box check), `port_listening`, класс `Core` (start/stop/running). Проверено: ядро стартует, порт 2080 поднимается.
- **qml/App/**: Main.qml (окно/страницы/модалки), Theme.qml (singleton, scheme dark/light/kitsune),
  ConnectButton, ServerCard, Waveform, ModeSwitch, Segmented, Toggle, ThemeToggle, IconButton, ValueField,
  ChipRow, SettingRow, HotkeyField, Toast; qmldir.
- **assets/**: icon.png/.ico + tray/f00..f13.png (анимация китсунэ: f00 выглянул=подключено, f13 спрятан=отключено).
- **core/**: sing-box.exe / nekobox_core.exe (gitignored) + fetch_core.py.
- **gen_icon.py**: из арта (китсунэ в коробке) делает иконку + кадры трея (PIL floodfill убирает белый фон).
- **docs/COMPARISON.md**: полная таблица Kitsune↔NekoBox по фичам со статусами.

## 5. Состояние
- В **backend** (переживает трей): status, server, ping, down, up, elapsed, exitIp, mode, groups, currentGroup,
  autoConnect/Mode, hotkeyEnabled/Text, fav на сервере.
- В **QML/win → снимок JSON при выгрузке UI** (AppController._snap; Main.exportSettings/importSettings,
  property settingsSnapshot:string): тумблеры Settings, routeRules, port/mtu/dns, rt*-пресеты.
- Theme.scheme — в синглтоне, при выгрузке UI сбрасывается на dark (в снимок не входит).

## 6. ПОДВОДНЫЕ КАМНИ
1. Нельзя emit'ить PUA-глифы → иконки в QML через `String.fromCharCode(0xE7..)`.
2. Theme-синглтон: setProperty из Python НЕ пробрасывается в биндинги → для скрина темы временно менять `scheme`
   по умолчанию в Theme.qml и возвращать. В приложении `Theme.scheme=…` работает.
3. Edit по большим блокам мажет по ведущим пробелам → якориться короткими подстроками.
4. Drag в Flickable: DragHandler крадётся → `MouseArea{preventStealing:true; drag.target}`.
5. Кросс-родительский anchor не работает → `mapToItem/mapFromItem(null,…)` + фиктивные зависимости.
6. QJSValue привязан к движку → снимок настроек в JSON-строке.
7. QSystemTrayIcon требует QApplication (QtWidgets), `setQuitOnLastWindowClosed(False)`.
8. nekobox_core CLI: `nekobox_core.exe sing-box run/check -c config.json` (работает, проверено).
9. `sing-box check` ≠ `run`: семантику ловит только `run`. Грабли (1.13): `detour:"direct"` на пустой direct-outbound = FATAL;
   remote rule-set качается на старте и валит подключение при 404/без сети (имя РФ-geosite = `geosite-category-ru`).
   Вывод: после правок config-gen ОБЯЗАТЕЛЬНО гонять живой `run`, а не только `check`. Реальные тест-ссылки даёт пользователь.
10. TUN/elevation: non-elevated процесс НЕ может убить elevated → нельзя элевейтить только ядро (сломается stop).
    Решение — повышать весь процесс (`ShellExecuteW "runas"` → ядро-потомок наследует уровень). TUN-блокер = только права
    («Access is denied» при configure tun interface), wintun.dll ядро встраивает само (отдельная DLL не нужна).
11. ТЕСТИРОВАНИЕ ТУННЕЛЯ — конфаунды (важно!): (а) у юзера ПОСТОЯННО активна своя TUN-VPN на 77.110.118.219 → если тестить
    на ТОМ ЖЕ сервере, exit IP совпадёт и докажет НИЧЕГО (ложный «работает»). Тестировать ТОЛЬКО на ДРУГОМ сервере и сверять,
    что exit IP = новый сервер. (б) «безпрокси» запрос через urllib может уйти в системный прокси юзера (urllib читает
    getproxies) → опять не наш туннель. Чистый тест прокси-режима — через ЯВНЫЙ прокси 127.0.0.1:2080 (engine.exit_ip).
    (в) две системные TUN-VPN конфликтуют за дефолтный маршрут — TUN валидно тестить только без второй активной TUN.
    strict_route дефолт=false (= дефолт sing-box). Наблюдалось, что ON ломал DNS, НО данные искажены конфликтом с чужим VPN —
    не делать твёрдых выводов про strict_route, пока не проверено на чистой машине.

## 7. Контракт backend (что engine-связка должна сохранить; имена как в QML)
Свойства: status, server, ping, down, up, elapsed, exitIp, mode, pinging, servers, groups, currentGroup,
autoConnect, autoConnectMode, hotkeyEnabled, hotkeyText.
Слоты: toggle, connectVpn, disconnectVpn, selectServer(name), selectBest, pingAll, setMode, setCurrentGroup,
addSubscription, removeGroup, updateGroup, setGroupAuto, addServer(map), updateServer(i,map), removeServer,
duplicateServer, toggleFavorite, importFromClipboard, importText, serverLink(i)->str, serverQr(i)->str,
copyToClipboard, setHotkey, suspendHotkey, startup. Сигнал: notify(message, kind).

## 8. Сравнение с NekoBox
Полная таблица — `docs/COMPARISON.md`. Кратко: UI — паритет/лучше уже сейчас; движок — базис работает (то же ядро +
генерация/запуск конфига), остальное поступательно. Потолок = как у NekoBox (ядро одно).

## 9. СЛЕДУЮЩИЕ ШАГИ (движок), по порядку
1. ✅ СДЕЛАНО — engine.py связан с Backend: реальный connect/stop, статус из поллинга порта.
   **РЕАЛЬНО ПРОВЕРЕНО** на сервере (vless+Reality+PQC `encryption=mlkem768…`): exit IP через туннель = IP сервера.
   В парсере/профиле добавлены поля `encryption` и `fp` (utls). build_outbound их учитывает.
   Нюанс: «Подключено» = ядро+порт; реальный туннель подтверждается IP-проверкой (см. шаг 4).
   **ЧИСТО ПОДТВЕРЖДЕНО** на ДРУГОМ сервере (Финляндия, finland-warp.cloudpath.live, reality/encryption=none): через явный
   прокси 127.0.0.1:2080 exit IP = 171.22.114.180 (≠ VPN юзера 77.x, ≠ входной IP сервера) → прокси-туннель реально работает.
2. ✅ СДЕЛАНО — системный прокси Windows (winreg + WinINET refresh) при подключении / сброс при отключении и выходе.
3. ✅ СДЕЛАНО — config-gen: маршрутизация/DNS/mux/sniffing из UI. Ядро = sing-box **v1.13.11**
   (современная схема: action-based rules, rule_set для geosite/geoip, новый DNS-формат + default_domain_resolver).
   `engine.gen_config(server, settings)` строит: sniff+hijack-dns, LAN-обход (`ip_is_private`),
   пользовательские правила (domain/geosite/geoip/ip/process/port → proxy/direct/reject), RU-direct (geosite-ru+geoip-ru),
   adblock (geosite-category-ads-all→reject), final (proxy/direct/«блок»=catch-all reject), DNS remote(via proxy)+direct(+fakeip),
   mux на outbound (smux/yamux/h2mux). rule_set'ы тянутся ядром remote с github SagerNet (download_detour=direct).
   Связка: QML реактивно пушит снимок (`_cfgKey`→`syncConfig`) → `backend.applyConfig(json)` → `self._settings` → `Core.start(srv, settings)`.
   Кастомный `portMixed` учитывается в поллинге порта и системном прокси. Всё провалидировано `sing-box check`.
   Smoke: `_smoketest.py` (LOADED:True/WARN:0/SETTINGS_PUSHED:True).
   **РЕАЛЬНО ПРОВЕРЕНО** на живом сервере (vless+Reality+PQC): порт 2080 поднимается, exit IP = IP сервера,
   rule-set'ы (geosite-category-ru/geoip-ru/category-ads-all) качаются через туннель. Подводные камни рантайма
   (НЕ ловятся `sing-box check`, только при `run`): (а) `detour:"direct"` на пустой direct-outbound = FATAL →
   для прямого DNS detour НЕ ставим, для rule-set download_detour="proxy" только когда есть сервер; (б) geosite для РФ =
   **`geosite-category-ru`**, НЕ `geosite-ru` (404); geoip-ru — ок. Добавлен `experimental.cache_file` (кэш rule-set'ов).
   ВАЖНО: remote rule-set качается на СТАРТЕ и при ошибке валит подключение → нужны верные имена/сеть (на будущее — bundling локальных .srs).
4. ✅ СДЕЛАНО — Clash API + реальные пинги. В конфиг добавлен `experimental.clash_api` (external_controller 127.0.0.1:9090).
   engine: `clash_traffic()` (downloadTotal/uploadTotal из `/connections` → ↓/↑ за сессию в МБ),
   `clash_delay()` (URL-delay активного proxy через `/proxies/proxy/delay`), `tcp_ping(host,port)` (реальный TCP-connect пинг),
   `exit_ip(port)` (внешний IP через mixed-прокси → подтверждает туннель). app: `_on_tick` тянет реальный трафик (с базой
   на момент connect), активный пинг кольца — реальный URL-delay (раз в 5 c, в фоновом потоке), `pingAll` — реальный TCP-пинг
   серверов группы (в потоке, результат через Qt-сигнал `_pingAllDone`), exit IP — реальный (сигнал `_exitIpDone`).
   Весь мок (`random` ping/traffic/IP) убран. Фоновые задачи → основной поток через Signal (queued).
   **РЕАЛЬНО ПРОВЕРЕНО** на живом сервере: `clash_delay`=147 ms, `clash_traffic` инкрементится ((0,0)→(225,117) байт после прогона),
   `exit_ip`=IP сервера. Фоновые задачи → основной поток через Signal (queued). Smoke OK.
5. ✅ СДЕЛАНО — подписки по URL. `engine.fetch_subscription(url)` (HTTP GET, TLS без верификации — подписки часто на
   IP/самоподписанных сертах, UA=Kitsune/1.0). Backend: `_decode_subscription` (base64-блоб ИЛИ плейн-текст → список ссылок),
   `_refresh_subscription(gi)` грузит/парсит в потоке → сигнал `_subDone` → `_on_sub_done` (заменяет сервера группы,
   сохраняет fav по address:port, авто-пинг свежих). `addSubscription` создаёт группу с «загрузка…» и сразу фетчит;
   `updateGroup` для подписок = refetch, для ручных групп = реальный пинг. Переиспользует `_parse_link`/`_make_server`.
   **РЕАЛЬНО ПРОВЕРЕНО** на живой подписке: base64 декодирован, спарсен vless+Reality+PQC сервер, конфиг валиден.
6. ✅ СДЕЛАНО и ПОДТВЕРЖДЕНО (см. ниже про методику). При `mode=="tun"` в конфиг добавляется tun-inbound
   (`engine._tun_inbound`: address 172.18.0.1/30 + ipv6, auto_route, strict_route из UI, stack gvisor/system/mixed, mtu из UI)
   + `route.auto_detect_interface=true`. DNS-перехват: `{port:53,hijack-dns}` + `{protocol:dns,hijack-dns}`. mixed-inbound остаётся.
   **Права:** `engine.is_admin()`; при connect в TUN без админа Backend перезапускает приложение с UAC (`ShellExecuteW "runas"`,
   exe+script+workdir; отказ UAC → notify, остаёмся). Модель: повышаем ВЕСЬ процесс (ядро-потомок наследует уровень → start/stop
   работают; non-elevated НЕ может убить elevated). `setMode` синхронизирован: home ModeSwitch ↔ настроечный тумблер (через
   backend.mode), смена режима на лету переподнимает ядро.
   **ПОДТВЕРЖДЕНО вживую:** TUN-адаптер `tun0` создаётся с правами админа (без прав — «Access is denied»), wintun ядро встраивает
   само (отдельная DLL не нужна), elevation-модель работает, конфиг валиден для всех стеков.
   **НЕ ПОДТВЕРЖДЕНО:** что системный трафик реально идёт через мой туннель. Причина — у пользователя ПОСТОЯННО активен
   свой TUN-VPN (на тот же IP 77.110.118.219, что в первых тест-ссылках), отключить нельзя (через него идёт связь со мной).
   Две системные TUN-VPN конфликтуют за дефолтный маршрут; плюс чужой системный прокси может ловить «безпрокси» запросы.
   Ранний инструментальный вывод «TUN работает на том же сервере» был ложным (совпадение exit IP с VPN юзера).
   **ПОДТВЕРЖДЕНИЕ:** пользователь полностью выключил свой nekobox и подключился через Kitsune — интернет появился через
   НАШ туннель, полная скорость 100/100 Mbps, проверено на НЕСКОЛЬКИХ подписках. Авторская инструментальная проверка
   через Clash API в этот момент была невозможна (связь с агентом идёт через VPN юзера; пока его VPN выключен — агент offline).
   Совокупно: (1) wintun-адаптер создаётся с админ-правами на этой машине ✅, (2) config валиден для всех 3 стеков ✅,
   (3) прокси-режим чисто проверен на ДРУГОМ сервере (Финляндия, exit 171.x ≠ VPN юзера) ✅, (4) elevation/UAC-перезапуск ✅,
   (5) пользовательская проверка TUN на multiple подписках ✅. `strict_route` дефолт=FALSE (= дефолт sing-box).
7. ✅ СДЕЛАНО (по тому, что есть в UI) — экзотика. **WireGuard endpoint** (в 1.13 WG только через секцию `endpoints`,
   legacy outbound выпилен): `engine._wireguard_endpoint(s)` → `{type:wireguard, tag:proxy, address:[local_addr],
   private_key, mtu, peers:[{address,port,public_key,allowed_ips,pre_shared_key?}]}`. В `gen_config` при `protocol=='wireguard'`
   профиль идёт в `cfg["endpoints"]`, а не в outbounds (mux к WG неприменим). UI редактора сервера расширен полями:
   peerKey, localAddr (default `172.16.0.2/32`), allowedIps (default `0.0.0.0/0`), MTU (default 1420), pre-shared key (опц.).
   Профильные ключи (`_PROFILE_KEYS`) обновлены. **xhttp transport** добавлен в `_transport_block` (path+host). Регрессии
   vless/vmess/trojan/ss/реальный reality+PQC прошли. Конфиги валидируются `sing-box check` (WG, WG+TUN, vless+xhttp).
   Не сделано (нет в UI): mieru/juicity/amnezia (требуют отдельных типов outbound + UI-форм; ядро `with_awg`-тег есть,
   но формат AWG-полей в этой сборке отличается — поле `jc` отклонено схемой; будущий шаг).
   **НЕ протестировано вживую:** WG/xhttp серверов у пользователя нет — только схематическая валидация.
8. ✅ СДЕЛАНО — панель логов ядра. `Core.start` теперь принимает `on_log` callback; при наличии — захватывает stdout/stderr ядра
   в фоновом потоке (демон), вызывает `on_log(line)` построчно. Backend: rolling-буфер `deque(maxlen=2000)`, сигнал `_logLine`
   (thread-safe queued из потока ядра → `_on_log_line` в основном потоке → append в буфер + `logsChanged`), property `logsText`
   (`\n`.join буфера), слот `clearLogs`. `_begin_connect` пробрасывает `on_log=self._logLine.emit`. UI: новая секция
   «ДИАГНОСТИКА → Логи ядра → [Открыть]» в Settings (по правилу §1 — **по умолчанию скрыто**, только явное открытие).
   Модалка: backdrop + центрированная карточка с моноширинным выводом (Consolas), авто-скролл вниз при новых строках,
   кнопки «Копировать»/«Очистить»/закрыть. Без захвата лога (`on_log=None`) ядро запускается как раньше — обратная совместимость.

## 9.Б Профили маршрутизации (поверх #4)
✅ СДЕЛАНО — именованные пресеты всех routing-настроек. Свойства QML: `routingProfiles: [{id, name, rtProfile, rtLan,
rtRegionDirect, rtAdblock, rtProxyAll, rtFinal, routeRules}]`, `currentProfileId`. Функции: `applyProfile(id)` (выгружает
профиль в `win.*` под `_profileLoading`-флагом), `saveActiveProfile()` (записывает текущее состояние в активный профиль),
`createProfile(name)` (копирует текущее → новый id), `deleteProfile(id)` (default неудаляем; при удалении активного
переключает на default), `renameProfile(id, newName)`. Автосейв: `_profileKey`-биндинг тригерит `saveActiveProfile`
при любой правке rt-настроек или routeRules. Persist: профили + activeId в settingsSnapshot.
UI: секция «ПРОФИЛИ» в шапке страницы Routing — Flow из чипов (имя + крестик удаления на hover/active), «+» открывает
модалку ввода имени → копирует текущее в новый профиль. Per-app переименован «Авто» → «По умолчанию» (=использовать
финальное действие активного профиля). Хинт под списком приложений показывает «Активный профиль: «X», по умолчанию: Y».
Пример пользователя «Игровой»: создать профиль → переключить final на Прямо → в Приложениях у Discord выбрать VPN.
Всё остальное системно идёт мимо туннеля, Discord — через VPN.

## 9.Г Здоровье сервера, bundled rule-sets, seamless switch, UI freeze fix
Закрыты 4 архитектурных TODO (плюс proxy cleanup) в одной сессии:

### #7 — Health-check сервера перед добавлением
`Backend._validate_server(srv)` прогоняет профиль через `engine.gen_config(srv, {})` + `engine.check_config()`.
Ловит невалидные ключи reality, кривой UUID, encryption, transport, отсутствие address/port. Сообщение очищается от ANSI-цветов и префикса `FATAL[0000]` → пользователь видит читаемое.
Где работает:
- `addServer` / `updateServer` — отклоняет с ошибкой;
- `_import_text` (буфер) — пропускает битые, счётчик skipped;
- `_refresh_subscription` — валидация в **фоновом потоке** (не блокирует main).
Все сервера получают флаг `_valid: bool`, кеш для быстрого `_valid_servers_of_group()`.

### #8 — Bundled rule-sets (offline-ready)
`core/rulesets/` содержит 3 локальных `.srs`: `geosite-category-ru.srs` (7 KB), `geosite-category-ads-all.srs` (8 KB), `geoip-ru.srs` (50 KB). Итого ~65 КБ к дистрибутиву.
`engine._ruleset_def(tag, detour)` сначала проверяет `core/rulesets/<tag>.srs` на диске → если есть: `{type:"local", path: str(...)}` → ядро без github. Если файла нет (пользовательский geosite/geoip) → fallback на remote с `download_detour: "proxy"`.
Старт ядра с RU-direct+adblock — **мгновенный**, без HTTP-загрузки rule-set'ов. Работает без интернета.
TODO на потом: периодическое обновление local `.srs` (как core update).

### #9 — Seamless server switch через selector outbound
**`engine.server_tag(idx)`** → стабильный тег `srv-N`. **`_build_server_member(s, tag, settings)`** — выделено в helper.
**`gen_config(server, settings, ...)`** теперь принимает `dict` ИЛИ `list[dict]`:
- single (dict) → tag=`"proxy"`, без селектора (обратная совместимость);
- multi (list, 2+) → каждый получает `srv-N`, плюс `{type:"selector", tag:"proxy", outbounds:[...], default:<active>}`;
- multi (list, 1) → как single.
**`clash_select(member_tag)`** → `PUT /proxies/proxy` с `{"name": tag}`.
**Backend:**
- `_valid_servers_of_group()` — фильтр по `_valid` флагу, БЕЗ subprocess (быстро).
- `_active_idx_in(valid)` — индекс активного.
- `_begin_connect` собирает список валидных, передаёт `settings["activeIdx"]`, ядро запускается со ВСЕМИ серверами в селекторе.
- `selectServer` (connected, 2+ серверов) → `engine.clash_select(target)` в фоне, без перезапуска ядра.
- (connected, 1 сервер) → fallback на штатный `_disconnect() + _begin_connect()`.

### #11 — UI freeze на больших подписках
**Корень:** `_valid_servers_of_group()` ре-валидировал каждый сервер группы через `sing-box check` (subprocess ~100ms). На 50+ серверах — main-thread блокировался на 5-10с при connect/select/import.
**Фикс:** кэш `_valid` флага на каждом сервере (ставится один раз при импорте/добавлении), `_valid_servers_of_group` — мгновенный фильтр. Валидация подписочных серверов перенесена в фоновый поток `_refresh_subscription.work()`. Сигнал `_subDone` расширен до `(gi, valid_servers, fetched_ok, invalid_count)`.

### #13 — Precautionary cleanup системного прокси
**Принцип:** приложение НЕ должно оставлять следов в системе после своего завершения.
`Backend.__init__` чистит leftover при старте:
- **Firewall kill-switch** — наше правило с уникальным именем `Kitsune-KillSwitch-BlockOut`, можно удалять без опаски.
- **Системный прокси** — `_clean_leftover_system_proxy()` проверяет `HKCU\...\Internet Settings\ProxyServer`; ТОЛЬКО если `127.0.0.1:...` (наш) → выключаем. Чужой Fiddler/Charles не трогаем.
Проверено: leftover `(1, '127.0.0.1:2080')` → `(0, ...)`. Чужой `(1, '192.168.1.1:8080')` → не тронут.

### #3 (V2 per-app + Профили) — финал
`Segmented [Авто / VPN / Прямо]` для каждого приложения. **Кнопка «+ Добавить»** через `QFileDialog` для приложений без Start Menu shortcut (portable/dev-tools). Custom apps персистятся в snapshot, чистятся через ✕ в строке. Кнопка «Сбросить» убирает все process-правила.
Profiles готовы: автосейв при правке, ChipRow в шапке Routing, защита от удаления `default` профиля.
Фикс «прыжка строки»: process-правила скрыты из глобального списка «ПРАВИЛА» (height:0, visible:false) — они уже в секции ПРИЛОЖЕНИЯ.

### Фикс изначально кривого UI: thin scrollbar, UTF-8 имена приложений
**`ThinScrollBar.qml`** — реюзабельный macOS-style (3px idle, 6px hover, accent press). `policy: AsNeeded` + `visible: bar.size < 1.0` (Qt оставлял ползунок-полосу при равном контенте). Навешен на все 7 Flickable/ListView.
**UTF-8 фикс в scan_apps_raw:** PowerShell с явным `[Console]::OutputEncoding = UTF8` + `$OutputEncoding = UTF8`, в subprocess.run `encoding="utf-8", errors="replace"`. Имена приложений с кириллицей читаемы, фильтр шума («Удалить»/«Справка») снова работает.

## 9.Д i18n RU/EN — ПОЛНОСТЬЮ (Phase 2 + Phase 3)

### Phase 2 — QML строки (161 строка переведена)
`qml/App/T.qml` — словарь ~250 ключей в RU + EN. 5 проходов миграции по `Main.qml`. Покрыто:
- Все SettingRow (label + sub) — 30+
- Все секции (БЕЗОПАСНОСТЬ, ЯДРО, ПРОФИЛИ, ПРЕСЕТЫ, ПРАВИЛА, ПРИЛОЖЕНИЯ, ...)
- Все модалки (server editor, new sub, new profile, new rule, import rules, share, logs)
- Контекстное меню сервера
- Segmented options (Авто/VPN/Прямо, Прокси/Прямо/Блок, Последний/Быстрейший, ...)
- Locations: поиск/пустое/Мой IP/Соединение не защищено
- Confirm-диалоги (Удалить подписку/профиль/сервер, Сбросить per-app)
- Тосты (Настройки применены из подписки, 🦊 Режим Китсунэ)
- Динамика приложений: «Активный профиль: «X» (default: Y). ...»
- Единицы измерения (МБ/ГБ → MB/GB)
Остались только язык-нейтральные символы (·, », —, ★, ✕).

### Phase 3 — Backend notify (52 ключа, все 50+ вызовов)
`Backend._NOTIFY_TR = {lang: {key: template}}` со словарём + `self._tr(key, **kwargs)` с плейсхолдерами `{name}/{ver}/{err}/{tag}/{tries}/{max}/{path}/{n}/{skip}/{fmt}/{ping}/{text}`.
`@Slot(str) setLang(lang)` — синк с QML.
QML: `Component.onCompleted: backend.setLang(T.lang)` + `Connections { target: T; onLangChanged: backend.setLang(T.lang) }` — реактивный синк.
Graceful fallback: неизвестный ключ → возвращает сам ключ (видно в UI). Missing args → возвращает шаблон.
Все 50+ `notify.emit(...)` заменены на `self.notify.emit(self._tr("key", ...), kind)`.

## 9.В Дореализованные «мок-тумблеры» из Settings
✅ СДЕЛАНО — пройдено по 6 задачам из аудита Settings, которые висели как UI-only без реальной логики:
1. **setBlock удалён** — был дубликатом `setStrictRoute` (та же фича по смыслу). Оставлен только Strict route в TUN-секции.
2. **setLan** — `engine.gen_config` mixed inbound теперь `"listen": "0.0.0.0" if lan else "127.0.0.1"`. Прокинут через `applyConfig`
   и реактивный `_cfgKey`.
3. **setAutostart** — `Backend.setAutostart(on)` пишет/удаляет `HKCU\Software\Microsoft\Windows\CurrentVersion\Run\Kitsune`
   через winreg, со значением `"python.exe" "app.py"` (или просто `Kitsune.exe` для frozen-сборки). Слот `isAutostartEnabled()`
   читает реестр на старте → QML-тумблер синкается с реальным состоянием системы.
4. **Адаптивная иконка трея** — `_windows_uses_light_theme()` через `HKCU\...\Personalize\SystemUsesLightTheme`. На светлой теме
   `_adapt_tray_icon` через QPainter добавляет тонкий белый ореол (8 направлений, alpha 220) — тёмные пиксели иконки не сливаются
   с панелью задач. На тёмной — оригинал без изменений.
5. **setReconnect (watchdog)** — `_on_tick` дополнен проверкой `port_listening`; при нештатном обрыве (`status==connected`,
   но порт упал) и `_user_disconnected==False` и `_reconnect_attempts < 5` → `QTimer.singleShot(1500, _reconnect_now)`.
   `_user_disconnected` ставится в True в `toggle`/`disconnectVpn` (юзер сам), сбрасывается в `_begin_connect`.
   `_reconnect_attempts` сбрасывается в `_on_connected`. После 5 попыток — честный disconnect + notify «переподключите вручную».
6. **setKill (Windows Firewall kill-switch)** — V1 реактивный: `engine.firewall_block_all_outbound()` через
   `netsh advfirewall firewall add rule name=Kitsune-KillSwitch-BlockOut dir=out action=block`. В `_handle_unexpected_drop`
   при `setKill==True && is_admin()` блокирует весь исходящий → юзер не утекает до восстановления. В `_on_connected`/`_disconnect`/
   `AppController.quit` — `firewall_unblock_all` (КРИТИЧНО для quit, иначе после закрытия приложения юзер останется без интернета).
   На старте Backend.__init__ — превентивная чистка leftover-правил от возможного прошлого крэша. Без админ-прав netsh
   возвращает access denied → False, без exception; toggle информирует юзера: «Kill-switch требует прав администратора (TUN-режим даёт их автоматически)».

## 9.А ИДЕИ НА БУДУЩЕЕ (от пользователя, после §9.8)
1. ✅ СДЕЛАНО — авто-обнова **только sing-box.exe** (nekobox_core управляется через NekoBox-инсталлятор, его не трогаем).
   engine: `core_version(exe)` (regex парсит обе формы: `sing-box version 1.13.12` и `sing-box version v1.13.11`),
   `latest_singbox_release()` (GitHub API `SagerNet/sing-box/releases/latest` → asset `windows-amd64.zip`),
   `install_core_update(url, dest)` (скачивает zip, ищет exe, атомарная замена через `.new` → rename → `.old`;
   ловит PermissionError если файл занят).
   Backend: signals `_coreCheckDone`/`_coreUpdateDone`, properties `coreVersion / coreLatest / coreUpdateAvailable / coreUpdating`,
   слоты **`checkCoreUpdate()`** (ТИХАЯ — тостит только при находке апдейта; используется при автозапуске) и
   **`checkCoreUpdateForce()`** (ручная из UI — фидбек в обе стороны: «доступно» / «актуально»), `updateCore()` (блокируется
   при `status != disconnected`), `openUrl(url)`.
   UI: секция «ЯДРО» в Settings — одна строка про sing-box.exe c версией и кнопкой «Обновить» (показывается только когда апдейт
   реально есть; во время загрузки превращается в «Загрузка…»), плюс строка «Проверка обновлений → [Проверить]».
   **Деликатный индикатор:** маленькая точка accent-цвета на иконке Settings в сайдбаре, видна только при `coreUpdateAvailable` —
   не блокирует, не отвлекает, увидит кому интересно. Авто-проверка тихо стартует на `Component.onCompleted`.
   Проверено: текущий v1.13.12 распознан, latest = v1.13.12 → «обновлений нет», без лишнего тоста.
2. ✅ СДЕЛАНО — импорт правил маршрутизации из чужих клиентов (sing-box JSON + Clash/clash.meta YAML; 80% случаев).
   engine: `parse_singbox_rules(text)` (принимает полный конфиг с `route.rules`, объект с `rules`, или массив; пропускает
   системные `sniff`/`hijack-dns`/`ip_is_private`; распаковывает `domain_suffix` в отдельные правила; маппит `rule_set`
   `geosite-X`/`geoip-X` обратно в `{type:geosite|geoip, value:X}`; пробрасывает `process_name`/`ip_cidr`/`port`/`domain`;
   `action:reject` → block, `outbound:direct` → direct, иначе proxy). `parse_clash_rules(text)` (минимальный YAML-парсер
   секции `rules:` без зависимости от PyYAML; поддержанные типы: DOMAIN/DOMAIN-SUFFIX/IP-CIDR(6)/GEOIP/GEOSITE/PROCESS-NAME/
   DST-PORT; полиси Proxy→proxy, DIRECT→direct, REJECT(-DROP)→block, кастомные → proxy; пропускает DOMAIN-KEYWORD/MATCH/
   SRC-* и игнорит `no-resolve` суффикс). `parse_imported_rules(text)` — авто-детект формата по первому непробельному
   символу (`{`/`[` → sing-box) или наличию `^\s*rules:` (Clash). Backend: signal `rulesImported(QVariantList, format)`,
   slots `importRulesText(text)` / `importRulesFromClipboard()`. UI: кнопка «Импорт» рядом с «+ Правило» на странице
   Routing → модалка с моноширинным TextEdit для вставки + кнопки «Из буфера» / «Импортировать» / закрыть. QML
   `Connections.onRulesImported` конкатенирует правила в `win.routeRules` → реактивно → applyConfig → реальная маршрутизация.
   **Проверено end-to-end**: Clash YAML → 4 правила → `engine.check_config = True`, sing-box JSON → 10 правил с правильным
   пропуском системных и распаковкой domain_suffix/rule_set.
3. 🟡 **i18n RU/EN** — ФАЗА 1 СДЕЛАНА: инфраструктура + переключатель + базовые строки. Реализован QML-синглтон `T.qml`
   (`pragma Singleton`, прописан в `qmldir`) со словарём `dict.ru` / `dict.en` и функцией `T.s(key)`. Реактивно: при смене
   `T.lang` все text-биндинги, ссылающиеся на `T.s(...)`, переоцениваются автоматически. Переключатель: новая секция «ЯЗЫК»
   в Settings (Segmented `Русский / English`), `T.lang` сохраняется в settingsSnapshot (export/import). Переведены:
   sidebar navModel (key вместо label) + статус-строка низа, заголовки страниц (Локации/Настройки/Маршрутизация),
   секции Settings (ИНТЕРФЕЙС/ПОДПИСКА/ПОДКЛЮЧЕНИЕ/ГОРЯЧАЯ КЛАВИША/БЕЗОПАСНОСТЬ/ВХОДЯЩЕЕ/TUN/DNS/MUX/ДИАГНОСТИКА/ЯЗЫК),
   ConnectButton (ЗАЩИЩЕНО/ПОДКЛЮЧЕНИЕ/ОТКЛЮЧЕНО), панель логов (title/sub/footer + кнопки Открыть/Копировать/Очистить).
   Smoke OK, без QML-warnings.
   **TODO (Фаза 2):** остальные SettingRow-строки (label/sub десятков рядов), модалки (Новая подписка, редактор сервера,
   share/QR, контекстное меню сервера), импорт/экспорт ссылок, страница Локации (поиск/сорт/Авто). **TODO (Фаза 3):**
   Backend `notify` идёт из Python — нужен либо ключевой контракт (Backend emits key+args, QML переводит), либо `Backend.lang`
   и Python-словарь. Сейчас все уведомления RU.
4. ✅ СДЕЛАНО (V2) — per-app проксирование с **3 состояниями** (Авто / VPN / Прямо). engine: `scan_apps_raw()` через
   PowerShell+WScript.Shell резолвит .lnk обоих Start Menu → exe-таргеты, дедуп по basename, фильтр шума
   (uninstall/readme/help). Backend: signal `_appsScanDone`, slot `scanApps()` (async), `_on_apps_scan_done` в main-thread
   достаёт иконки через `QFileIconProvider.icon(QFileInfo(exe)).pixmap(32,32)` → PNG в `temp/kitsune_icons/<md5>.png`,
   property `appList` (`QVariantList` of `{name, exe, exeName, icon:"file:///..."}`).
   UI: раздел «ПРИЛОЖЕНИЯ» в Routing — поиск, «Пересканировать», «Сбросить» (видна при наличии process-правил),
   Repeater (иконка + имя + exeName + **Segmented [Авто/VPN/Прямо]**).
   QML-хелперы: `appRouteState(exe)` → `"auto"|"proxy"|"direct"` (читает routeRules), `setAppRouteState(exe, state)`
   (удаляет старое process-правило для exe, добавляет новое если state != auto), `resetAppRules()`, `appsFiltered()`.
   **Важно про Segmented:** его TapHandler императивно делает `root.currentIndex = seg.index` — ломает inline-биндинг
   снаружи. Решено через `Binding on currentIndex { value: ... }` — пере-устанавливает при ЛЮБОМ изменении routeRules,
   включая правки из глобальной таблицы правил.
   **Семантика по режимам:** VPN (`action:proxy`) — принудительно гнать в туннель (полезно в proxy-режиме для процессов,
   игнорирующих системный прокси). Прямо (`action:direct`) — мимо туннеля по реальному NIC (полезно в TUN-режиме как
   исключение: банковские клиенты, Steam/Epic, корп.VPN, Discord/Zoom, локальная разработка). Авто — нет правила.
   Авто-сканирование на `Component.onCompleted`. Проверено: 93 приложения за 1.7с, генерация конфига с миксом proxy+direct
   process-правил даёт корректный `process_name:[exe] outbound:proxy|direct` и проходит `sing-box check`.

Приоритет (пересмотрено): §9.8 (логи) ✅ → #1 (авто-обнова) → #4 (per-app) → #2 (импорт правил) → **#3 (i18n) ПОСЛЕДНИМ**, после стабилизации UI
(чтобы новые фичи добавили все недостающие строки и не переводить дважды; инфраструктура T-singleton уже на месте, словарь добивается финальным проходом).

## 10. Прочее
- Старый публичный форк `Tawreos228/nekobox` пользователь удаляет вручную (у токена нет scope delete_repo).
- Тема «Китсунэ» — секрет: 5 тапов по логотипу в сайдбаре. Тёмная — дефолт.
- Иконка/арт: китсунэ в оранжевой коробке (от пользователя через Gemini), фон убран в gen_icon.py.
