"""Compose store artwork from untouched, localized Flutter widget captures.
Run with Python + Pillow + numpy. No network, image generation, or store writes.
"""
from pathlib import Path
import hashlib
import json
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
FONT = ROOT / 'source/fonts'
SLUGS = ['01_companion', '02_aurea', '03_play', '04_focus', '05_yours']
COPY = {
 'en-US': [
  ('YOUR POCKET COMPANION', 'A little face.\nA lot of feeling.', 'Meet Haze. Touch, play, and bring\na little personality to your day.', 'A small companion. A brighter screen.'),
  ('EXPLORE AUREA LAB', 'See a feeling\ntake shape.', 'Explore compassion, courage, and gratitude\nthrough interactive experiments.', 'Inspired by the Aurea System project.'),
  ('PLAY WITH EXPRESSION', 'Big feelings.\nLittle discoveries.', 'Read the face. Find the feeling.\nA playful game in English and Portuguese.', 'Look closer. Guess. Play again.'),
  ('MAKE ROOM TO FOCUS', 'A quiet moment.\nGood company.', 'Set a focus timer and let Haze\nkeep you company while you settle in.', 'Your desk has a new little friend.'),
  ('MAKE HAZE YOURS', 'Your colors.\nYour companion.', 'Choose eye and mouth colors.\nFind your glow in light or dark mode.', 'One expressive face. Your personal touch.'),
 ],
 'pt-BR': [
  ('SEU COMPANHEIRO DE BOLSO', 'Um rostinho.\nTantas emoções.', 'Conheça o Haze. Toque, brinque e dê\nmais personalidade ao seu dia.', 'Uma pequena companhia para o seu dia.'),
  ('EXPLORE O LAB AUREA', 'Veja a emoção\nganhar forma.', 'Explore compaixão, coragem e gratidão\nem experimentos interativos.', 'Inspirado no projeto Aurea System.'),
  ('BRINQUE COM AS EXPRESSÕES', 'Grandes emoções.\nNovas descobertas.', 'Observe o rosto. Descubra a emoção.\nUm jogo em português e inglês.', 'Observe. Adivinhe. Brinque de novo.'),
  ('RESERVE UM TEMPO PARA VOCÊ', 'Uma pausa.\nBoa companhia.', 'Ative o timer de foco e deixe o Haze\nfazer companhia no seu ritmo.', 'Sua mesa ganhou um pequeno amigo.'),
  ('DO SEU JEITO', 'Suas cores.\nSeu companheiro.', 'Escolha as cores dos olhos e da boca.\nExperimente os temas claro e escuro.', 'Um rosto expressivo com o seu toque.'),
 ],
}

def font(size, bold=False):
    return ImageFont.truetype(str(FONT / ('InterDisplay-Bold.ttf' if bold else 'Inter-Regular.ttf')), int(size))

def background(w, h, index):
    light = index == 4
    base = np.array([244, 238, 225] if light else [9, 17, 25], dtype=float)
    glow = np.array(([218, 202, 171] if light else [[13, 76, 85], [62, 59, 45], [77, 32, 62], [27, 64, 69]][index]), dtype=float)
    yy, xx = np.mgrid[0:h, 0:w]
    dist = ((xx / w - .62) / .64) ** 2 + ((yy / h - .62) / .52) ** 2
    a = np.exp(-dist * 2.0)[..., None] * .8
    rgb = np.uint8(base * (1-a) + glow * a)
    return Image.fromarray(rgb).convert('RGBA')

def device(raw_path, width, kind, light):
    raw = Image.open(raw_path).convert('RGBA')
    bezel = round(width * (.023 if kind == 'ipad' else .022))
    inset = round(width * (.055 if kind == 'ipad' else .065))
    bottom = round(width * .04)
    screen_w = width - bezel * 2
    raw = raw.resize((screen_w, round(raw.height * screen_w / raw.width)), Image.Resampling.LANCZOS)
    height = raw.height + inset + bottom + bezel * 2
    img = Image.new('RGBA', (width + 12, height), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    radius = round(width * (.045 if kind == 'ipad' else .095))
    d.rounded_rectangle((3, 0, width+3, height-1), radius, fill='#6d747b', outline='#9c9c97', width=2)
    d.rounded_rectangle((6, 3, width, height-4), radius-3, fill='#151a20', outline='#353d46', width=4)
    screen = Image.new('RGBA', (screen_w, height-bezel*2), '#f6f2e9' if light else '#0a1018')
    screen.alpha_composite(raw, (0, inset))
    sd = ImageDraw.Draw(screen)
    ui_color = '#26313b' if light else '#f1eadd'
    if kind == 'iphone':
        sd.rounded_rectangle((screen_w*.38, inset*.20, screen_w*.62, inset*.72), inset*.25, fill='#000000')
    elif kind == 'android':
        r = inset*.13
        sd.ellipse((screen_w/2-r, inset*.4-r, screen_w/2+r, inset*.4+r), fill='#000000')
    if kind != 'ipad':
        sd.text((screen_w*.065, inset*.18), '9:41', font=font(width*.023, True), fill=ui_color)
        for i in range(4):
            x = screen_w*.825 + i*width*.009
            sd.rounded_rectangle((x, inset*.52-i*inset*.07, x+width*.005, inset*.63), 1, fill=ui_color)
        sd.rounded_rectangle((screen_w*.90, inset*.30, screen_w*.95, inset*.57), 3, outline=ui_color, width=1)
        sd.rounded_rectangle((screen_w*.905, inset*.35, screen_w*.944, inset*.53), 1, fill=ui_color)
        sd.rounded_rectangle((screen_w*.35, screen.height-bottom*.45, screen_w*.65, screen.height-bottom*.33), 3, fill=ui_color)
    mask = Image.new('L', screen.size)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, screen.width-1, screen.height-1), max(8, radius-bezel), fill=255)
    img.paste(screen, (bezel+3, bezel), mask)
    return img

def place(canvas, phone, center, angle):
    rotated = phone.rotate(angle, Image.Resampling.BICUBIC, expand=True)
    x, y = round(center[0]-rotated.width/2), round(center[1]-rotated.height/2)
    shadow = Image.new('RGBA', canvas.size)
    silhouette = Image.new('RGBA', rotated.size, (0, 0, 0, 145))
    silhouette.putalpha(rotated.getchannel('A').point(lambda p: int(p*.55)))
    shadow.alpha_composite(silhouette, (x+10, y+35))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(35)))
    canvas.alpha_composite(rotated, (x, y))
    return [x,y,x+rotated.width,y+rotated.height]

def draw_text(draw, xy, content, size, fill, bold=False, width=None, spacing=1.12):
    f = font(size, bold)
    while width and max(draw.textlength(line, font=f) for line in content.split('\n')) > width:
        size -= 1
        f = font(size, bold)
    for n, line in enumerate(content.split('\n')):
        draw.text((xy[0], xy[1] + n*size*spacing), line, font=f, fill=fill, anchor='lt')
    return size

def compose(locale, kind, index):
    # Apple 6.9-inch portrait, Apple 13-inch landscape, Play phone 9:16.
    w,h = {'iphone': (1320,2868), 'ipad': (2752,2064), 'android': (1080,1920)}[kind]
    tablet = kind == 'ipad'
    scale = w/1320 if not tablet else 1
    img = background(w,h,index)
    d = ImageDraw.Draw(img)
    light = index == 4
    fg = '#172630' if light else '#f6f0e3'
    accent = '#81623b' if light else '#ebcb8b'
    muted = '#53616b' if light else '#b7c7cd'
    eyebrow,title,sub,footer = COPY[locale][index]
    left = 112 if tablet else 84*scale
    text_w = 1190 if tablet else w-left*2
    brand_y = 135 if tablet else 106*scale
    draw_text(d, (left,brand_y), 'haze', 48*scale if not tablet else 60, fg, True)
    # Small native vector mark echoes Haze's two eyes.
    ex = left+(137 if tablet else 116*scale)
    ey = brand_y+7*scale
    for offset in [0, 24*scale]:
        d.rounded_rectangle((ex+offset, ey, ex+offset+15*scale, ey+22*scale), 7*scale, fill=accent)
    title_y = 650 if tablet else (300*scale if kind=='iphone' else 236*scale)
    draw_text(d, (left,title_y-72*scale), eyebrow, 25*scale, accent, True, text_w)
    title_size = 124 if tablet else (120*scale if kind=='iphone' else 114*scale)
    actual = draw_text(d, (left,title_y), title, title_size, fg, True, text_w, 1.08)
    sub_y = title_y + actual*2.16 + 45*scale
    sub_size = draw_text(d, (left,sub_y), sub, 39*scale if not tablet else 43, muted, width=text_w, spacing=1.4)
    copy_bounds = [left,title_y-72*scale,left+text_w,sub_y+sub_size*2.4]
    if tablet:
        phone = device(ROOT/'raw'/locale/kind/(SLUGS[index]+'.png'), 1230, kind, light)
        bounds = place(img, phone, (2050,1060), 0)
    else:
        dw = round(w*(.62 if kind=='iphone' else .49))
        phone = device(ROOT/'raw'/locale/kind/(SLUGS[index]+'.png'), dw, kind, light)
        angle = [5,0,-4,3,-3][index]
        top = 825*scale if kind=='iphone' else 680*scale
        center_y = top + phone.height/2
        bounds = place(img, phone, (w*.51,center_y), angle)
    d = ImageDraw.Draw(img)
    footer_y = h-(165 if tablet else 120*scale)
    draw_text(d, (left,footer_y), footer, 28*scale if not tablet else 30, muted, width=text_w)
    line_y = footer_y-35*scale
    d.line((left,line_y,left+75*scale,line_y), fill=accent, width=3)
    d.text((w-left,h-65*scale), f'{index+1:02d} / 05', font=font(22*scale), fill=muted, anchor='rs')
    out = ROOT/'exports'/kind/locale/(SLUGS[index]+'.png')
    out.parent.mkdir(parents=True, exist_ok=True)
    img.convert('RGB').save(out, optimize=True)
    return {'file':str(out.relative_to(ROOT)), 'width':w, 'height':h, 'deviceBounds':bounds, 'copyBounds':copy_bounds, 'footerTop':line_y,
            'sha256':hashlib.sha256(out.read_bytes()).hexdigest(), 'title':title, 'locale':locale}

def overview(locale,kind):
    thumbs=[]
    for slug in SLUGS:
        im=Image.open(ROOT/'exports'/kind/locale/(slug+'.png'))
        im.thumbnail((360,700))
        thumbs.append(im)
    tw,th=thumbs[0].size
    sheet=Image.new('RGB',((tw+20)*5+20,th+100),'#111b24')
    d=ImageDraw.Draw(sheet)
    d.text((20,20),f'HAZE / AUREA CAMPAIGN     {locale} · {kind}',font=font(24),fill='#ebcb8b')
    for i,im in enumerate(thumbs): sheet.paste(im,(20+i*(tw+20),70))
    sheet.save(ROOT/f'preview-{locale}-{kind}.jpg',quality=94)

if __name__=='__main__':
    manifest=[]
    for locale in COPY:
        for kind in ['iphone','ipad','android']:
            for index in range(5): manifest.append(compose(locale,kind,index))
            overview(locale,kind)
    (ROOT/'manifest.json').write_text(json.dumps({'storeUploaded':False,'files':manifest},indent=2)+'\n')
    print(f'Rendered {len(manifest)} store assets and six contact sheets.')
