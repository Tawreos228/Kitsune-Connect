"""Готовит иконку приложения и кадры анимации трея из арта Gemini.
- убирает белый фон (заливкой от углов -> сохраняет жемчужину/белый мех внутри);
- делает квадратный прозрачный PNG + .ico (16..256);
- генерит кадры «спрятан -> выглядывает» (зум от коробки к полному кадру)."""
import os
from PIL import Image, ImageDraw

SRC = r"C:\Users\danii\Downloads\Gemini_Generated_Image_ix0bh6ix0bh6ix0b.png"
OUT = os.path.join(os.path.dirname(__file__), "assets")
TRAY = os.path.join(OUT, "tray")
os.makedirs(TRAY, exist_ok=True)

MARKER = (255, 0, 255)


def remove_bg(path):
    im = Image.open(path).convert("RGB")
    w, h = im.size
    for c in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        ImageDraw.floodfill(im, c, MARKER, thresh=45)
    rgba = im.convert("RGBA")
    px = rgba.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if (r, g, b) == MARKER:
                px[x, y] = (0, 0, 0, 0)
    bbox = rgba.getbbox()
    return rgba.crop(bbox)


def square(img):
    w, h = img.size
    s = max(w, h)
    canvas = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    canvas.paste(img, ((s - w) // 2, (s - h) // 2), img)
    return canvas


def frame(subj, p, size=72):
    """p=0 -> полный кадр (выглядывает); p=1 -> крупный план коробки (спрятан)."""
    w, h = subj.size
    box_top = int(0.50 * h)            # верх коробки ~середина
    out_side = max(w, h)
    out_x = (w - out_side) / 2
    out_y = (h - out_side) / 2
    hid_side = h - box_top
    hid_x = (w - hid_side) / 2
    hid_y = box_top
    side = out_side + (hid_side - out_side) * p
    x = out_x + (hid_x - out_x) * p
    y = out_y + (hid_y - out_y) * p
    crop = subj.crop((int(x), int(y), int(x + side), int(y + side)))
    return crop.resize((size, size), Image.LANCZOS)


subj = remove_bg(SRC)
print("subject:", subj.size)

# полная иконка приложения
full = square(subj)
full.resize((256, 256), Image.LANCZOS).save(os.path.join(OUT, "icon.png"))
ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
full.save(os.path.join(OUT, "icon.ico"), sizes=ico_sizes)

# кадры анимации трея
N = 14
for i in range(N):
    p = i / (N - 1)
    frame(subj, p).save(os.path.join(TRAY, f"f{i:02d}.png"))
# крайние — отдельно для превью/состояний
frame(subj, 0.0).save(os.path.join(OUT, "tray_out.png"))
frame(subj, 1.0).save(os.path.join(OUT, "tray_hidden.png"))
print("frames:", N, "-> ", TRAY)
print("DONE")
