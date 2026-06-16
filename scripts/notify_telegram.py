"""Постит GitHub-релиз в Telegram-канал @Kitsune_VPN.

Использование:
    python scripts/notify_telegram.py            # latest release
    python scripts/notify_telegram.py v0.2.1     # конкретный тег

Токен:
    Читается из переменной окружения KITSUNE_TG_TOKEN.
    Никогда не передаётся аргументом и не пишется в код.

Требования:
    Бот @KitsuneAdmin должен быть админом канала @Kitsune_VPN
    с правами «Публикация сообщений».
"""
import json
import os
import sys
import urllib.request
import urllib.error

REPO    = "Tawreos228/KitsuneVPN"
CHANNEL = "@Kitsune_VPN"
GH_API  = "https://api.github.com"
TG_API  = "https://api.telegram.org"

# Telegram MarkdownV2 escape — экранируем спецсимволы.
# Это НЕ нужно делать для тех символов которые мы сами вставляем как разметку
# (например *...*), только для пользовательского текста.
MD_ESCAPE = r"_*[]()~`>#+-=|{}.!\\"


def md_escape(text: str) -> str:
    """Экранирует Telegram MarkdownV2 спецсимволы в произвольном тексте."""
    out = []
    for ch in text:
        if ch in MD_ESCAPE:
            out.append("\\" + ch)
        else:
            out.append(ch)
    return "".join(out)


def gh_release(tag: str | None) -> dict:
    """Тянет release по тегу или latest если tag=None."""
    url = f"{GH_API}/repos/{REPO}/releases/" + (f"tags/{tag}" if tag else "latest")
    req = urllib.request.Request(url, headers={
        "Accept": "application/vnd.github+json",
        "User-Agent": "Kitsune-Telegram-Notifier/1.0",
    })
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.loads(r.read().decode("utf-8"))


def assets_by_name(rel: dict) -> dict[str, str]:
    """Маппинг имени файла → download URL для всех assets."""
    return {a["name"]: a["browser_download_url"] for a in rel.get("assets", [])}


def format_post(rel: dict) -> str:
    """Сформировать тело поста в MarkdownV2."""
    tag = rel["tag_name"]
    name = (rel.get("name") or tag).strip()
    body = (rel.get("body") or "").strip()
    # Заголовок жирным
    title = f"🦊 *Kitsune {md_escape(tag)}*"
    # Имя релиза (часть после tag в title) как подзаголовок
    if name and name != tag and not name.startswith(tag):
        title += f"\n_{md_escape(name)}_"
    # Тело: обрезаем до 3500 chars (общий лимит Telegram — 4096, оставляем запас на заголовок и кнопки)
    if len(body) > 3500:
        body = body[:3490].rstrip() + "\n\n…"
    # Экранируем тело целиком (это release-notes с GH-markdown — без попыток конверсии).
    return title + "\n\n" + md_escape(body)


def build_keyboard(rel: dict) -> dict:
    """Inline-кнопки: установщик / portable / release page."""
    assets = assets_by_name(rel)
    setup  = next((u for n, u in assets.items() if n.lower().endswith(".exe")),  None)
    portable = next((u for n, u in assets.items() if n.lower().endswith(".zip")), None)
    rows = []
    if setup:
        rows.append([{"text": "📥 Установщик (.exe)", "url": setup}])
    if portable:
        rows.append([{"text": "📦 Portable (.zip)", "url": portable}])
    rows.append([{"text": "📝 Release notes", "url": rel["html_url"]}])
    return {"inline_keyboard": rows}


def tg_send(token: str, text: str, keyboard: dict) -> dict:
    """sendMessage в канал. Бросает RuntimeError если Telegram не принял."""
    payload = {
        "chat_id": CHANNEL,
        "text": text,
        "parse_mode": "MarkdownV2",
        "disable_web_page_preview": True,
        "reply_markup": json.dumps(keyboard, ensure_ascii=False),
    }
    data = urllib.parse.urlencode(payload).encode("utf-8")
    req = urllib.request.Request(f"{TG_API}/bot{token}/sendMessage", data=data,
                                 headers={"Content-Type": "application/x-www-form-urlencoded"})
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            return json.loads(r.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", "ignore")
        raise RuntimeError(f"Telegram API HTTP {e.code}: {body}") from e


def main() -> int:
    token = os.environ.get("KITSUNE_TG_TOKEN", "").strip()
    if not token:
        print("ERROR: переменная окружения KITSUNE_TG_TOKEN не задана.", file=sys.stderr)
        print("       PowerShell: [Environment]::SetEnvironmentVariable('KITSUNE_TG_TOKEN','TOKEN','User')",
              file=sys.stderr)
        return 2
    tag = sys.argv[1] if len(sys.argv) > 1 else None
    try:
        rel = gh_release(tag)
    except Exception as e:
        print(f"ERROR: не удалось получить release{' ' + tag if tag else ' latest'}: {e}", file=sys.stderr)
        return 3
    print(f"→ release: {rel['tag_name']} — {rel.get('name','')}")
    text = format_post(rel)
    kb = build_keyboard(rel)
    try:
        resp = tg_send(token, text, kb)
    except Exception as e:
        print(f"ERROR: Telegram отказал: {e}", file=sys.stderr)
        return 4
    if not resp.get("ok"):
        print(f"ERROR: Telegram вернул не-ок: {resp}", file=sys.stderr)
        return 5
    msg_id = resp["result"]["message_id"]
    print(f"✓ posted to {CHANNEL} — message_id={msg_id}")
    print(f"  link: https://t.me/Kitsune_VPN/{msg_id}")
    return 0


# импорт сюда, чтобы main() не падал ImportError'ом раньше времени при неправильном вызове
import urllib.parse

if __name__ == "__main__":
    sys.exit(main())
