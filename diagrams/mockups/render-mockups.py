"""Render visual wireframes from the RateFlow screen models, using Pillow."""
from pathlib import Path
import re
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = Path('C:/Windows/Fonts')
BG, INK, MUTED, LINE, WHITE = '#f3f4f6', '#17191d', '#636b75', '#ccd1d8', '#ffffff'

def font(size=22, bold=False):
    return ImageFont.truetype(str(FONT / ('arialbd.ttf' if bold else 'arial.ttf')), size)

def text(x, y, value, size=22, bold=False, color=INK):
    draw.text((x, y), value, font=font(size, bold), fill=color)

def box(x, y, w, h, fill=WHITE, border=LINE, radius=10):
    draw.rounded_rectangle((x, y, x+w, y+h), radius=radius, fill=fill, outline=border, width=2)

def label(x, y, title, value, width=330):
    text(x, y, title, 20, color=MUTED)
    box(x, y+34, width, 64)
    text(x+18, y+52, value.replace('   ▾', ''), 22)
    if '▾' in value:
        draw.line([(x+width-30, y+61), (x+width-23, y+69), (x+width-16, y+61)], fill=MUTED, width=2)

def button(x, y, title, width=210, primary=False):
    box(x, y, width, 58, fill=INK if primary else WHITE, border=INK)
    text(x+20, y+17, title, 20, bold=True, color=WHITE if primary else INK)

def base(model_name, active):
    global draw
    source = (ROOT.parent / f'{model_name}-page.sysml').read_text(encoding='utf-8-sig')
    match = re.search(r'attribute title : String = "([^"]+)"', source)
    if not match:
        raise ValueError(f'Missing page title in {model_name}')
    # Require the modeled page composition before rendering its visual layout.
    for part in ('header', 'footer'):
        if not re.search(rf'part {part}\s*:', source):
            raise ValueError(f'Missing component {part}')
    img = Image.new('RGB', (1600, 1100), BG)
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 1600, 100), fill=WHITE)
    draw.line((0, 100, 1600, 100), fill=LINE, width=2)
    text(64, 32, 'RateFlow', 32, True)
    for x, title in zip((415, 610, 855, 1070), ('Курсы', 'Конвертер', 'История', 'Уведомления')):
        text(x, 40, title, 23, bold=title == active, color=INK if title == active else MUTED)
        if title == active:
            draw.line((x, 83, x+len(title)*13, 83), fill=INK, width=4)
    text(64, 140, match.group(1), 34, True)
    text(64, 193, 'Демонстрационные данные · 25 октября 2026', 20, color=MUTED)
    draw.line((64, 1015, 1536, 1015), fill=LINE, width=2)
    text(64, 1040, 'Источник: НБРБ  ·  Официальные курсы  ·  Справочная информация', 19, color=MUTED)
    return img

# Screen 1: rates, currency selection, manual refresh and status.
img = base('rates', 'Курсы')
box(64, 245, 1472, 120)
text(92, 267, 'Отображаемые валюты', 21, True)
for x, value in ((92, 'USD'), (257, 'EUR'), (422, 'RUB')):
    box(x, 307, 26, 26, fill=INK, border=INK, radius=4)
    draw.line([(x+6, 320), (x+11, 325), (x+21, 313)], fill=WHITE, width=2)
    text(x+40, 308, value, 22)
button(1250, 277, 'Обновить курсы', 250, True)
box(64, 395, 1472, 395)
text(92, 420, 'Официальные курсы к BYN', 25, True)
for x, title in ((92, 'Валюта'), (570, 'Номинал'), (820, 'Курс BYN'), (1150, 'Изменение')):
    text(x, 485, title, 20, color=MUTED)
for y, row in zip((550, 630, 710), [('USD  Доллар США', '1 USD', '3,0000', '↑ +2,00%'), ('EUR  Евро', '1 EUR', '3,3000', '↓ −0,45%'), ('RUB  Российский рубль', '100 RUB', '3,5000', '↑ +0,30%')]):
    draw.line((92, y-20, 1505, y-20), fill=LINE, width=1)
    for x, value in zip((92, 570, 820, 1150), row):
        text(x, y, value, 23, bold=x == 820)
box(64, 825, 1472, 115)
text(92, 850, 'Данные загружены', 22, True)
text(92, 892, 'Дата действия: 25.10.2026   ·   Проверено: 12:00   ·   Изменение к предыдущей доступной дате', 20, color=MUTED)
img.save(ROOT / 'rates-mockup.png')

# Screen 2: converter, amount, currency pair and result.
img = base('converter', 'Конвертер')
box(64, 245, 950, 685)
text(100, 280, 'Пересчёт суммы', 27, True)
label(100, 345, 'Сумма', '10,00', 870)
label(100, 485, 'Исходная валюта', 'USD — Доллар США   ▾', 405)
label(565, 485, 'Целевая валюта', 'RUB — Российский рубль   ▾', 405)
draw.line((100, 640, 970, 640), fill=LINE, width=2)
text(100, 679, 'Результат', 22, color=MUTED)
text(100, 725, '857,14 RUB', 52, True)
text(100, 811, 'Расчёт обновляется при изменении суммы и валют.', 21, color=MUTED)
box(1045, 245, 491, 330)
text(1075, 280, 'Курсы для расчёта', 25, True)
text(1075, 345, '1 USD = 3,0000 BYN', 24)
text(1075, 400, '100 RUB = 3,5000 BYN', 24)
text(1075, 475, 'Дата: 25.10.2026', 21, color=MUTED)
text(1075, 517, 'Источник: НБРБ', 21, color=MUTED)
box(1045, 610, 491, 180)
for i, line in enumerate(('Справочный расчёт', 'Фактический курс обмена', 'в банке может отличаться.')):
    text(1075, 640+i*42, line, 23 if i == 0 else 21, bold=i == 0, color=INK if i == 0 else MUTED)
img.save(ROOT / 'converter-mockup.png')

# Screen 3: history filters, chart and period summary.
img = base('history', 'История')
box(64, 245, 1472, 135)
label(92, 264, 'Валюта', 'USD — Доллар США   ▾', 430)
text(620, 266, 'Период', 20, color=MUTED)
for x, title in ((620, '7 дней'), (825, '30 дней'), (1030, '90 дней')):
    button(x, 300, title, 175, primary=title == '7 дней')
box(64, 410, 1472, 420)
text(94, 435, 'USD / BYN — курс за 1 единицу валюты', 24, True)
chart_left, chart_top, chart_right, chart_bottom = 170, 505, 1470, 745
for index, value in enumerate(('3,03', '3,00', '2,97', '2,94')):
    y = chart_top+index*80
    draw.line((chart_left, y, chart_right, y), fill=LINE, width=1)
    text(94, y-12, value, 19, color=MUTED)
values = [3/1.02, 2.95, 2.96, 2.955, 2.945, 3/1.02, 3.00]
points = [(chart_left+i*(chart_right-chart_left)/6, chart_bottom-(v-2.94)/0.09*(chart_bottom-chart_top)) for i, v in enumerate(values)]
draw.line(points, fill=INK, width=4)
for i, (x, y) in enumerate(points):
    draw.ellipse((x-5, y-5, x+5, y+5), fill=INK)
    text(int(x)-25, 774, f'{19+i}.10', 19, color=MUTED)
for x, title, value in ((64, 'Начало периода · 19.10', '2,9412 BYN'), (565, 'Конец периода · 25.10', '3,0000 BYN'), (1066, 'Изменение за период', '↑ +2,00%')):
    box(x, 860, 470, 115)
    text(x+25, 882, title, 20, color=MUTED)
    text(x+25, 925, value, 27, True)
img.save(ROOT / 'history-mockup.png')

# Screen 4: alert rule and event list.
img = base('notifications', 'Уведомления')
box(64, 245, 1472, 250)
text(92, 270, 'Правило отслеживания', 25, True)
label(92, 323, 'Валюта', 'USD — Доллар США   ▾', 430)
label(565, 323, 'Порог изменения', '2,0 %', 330)
box(990, 360, 65, 32, fill=INK, border=INK, radius=16)
draw.ellipse((1027, 365, 1049, 387), fill=WHITE)
text(1070, 364, 'Правило включено', 21)
text(92, 455, 'Допустимый порог: 0,1–100%. Настройки сохраняются автоматически в этом браузере.', 19, color=MUTED)
text(64, 525, 'Проверка выполняется при открытом сайте и при следующем открытии.', 21, color=MUTED)
box(64, 580, 1472, 360)
text(92, 610, 'Последние уведомления', 26, True)
button(1015, 600, 'Прочитать все', 235)
button(1270, 600, 'Очистить', 230)
draw.line((92, 690, 1508, 690), fill=LINE, width=1)
draw.ellipse((96, 738, 110, 752), fill=INK)
text(135, 720, 'USD: рост курса на 2,00%', 27, True)
text(135, 770, '24.10.2026 → 25.10.2026   ·   2,941176… → 3,0000 BYN за 1 USD', 22)
text(135, 819, 'Порог правила: 2,0%   ·   Новое уведомление', 20, color=MUTED)
text(92, 899, 'Показываются последние 100 событий. Повторы для одной даты исключаются.', 19, color=MUTED)
img.save(ROOT / 'notifications-mockup.png')
print('Created four visual mockups.')
