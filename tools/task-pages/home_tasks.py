"""Write the task strip (hero) and the task library section of the two home pages.

    python3 home_tasks.py ../../docs data/catalog.json

Replaces the blocks between <!-- TASK-STRIP:START/END --> and <!-- TASKS:START/END -->
in docs/public/index.html and docs/public/zh/index.html.
"""
import json, os, re, sys
from html import escape

DOCS, CAT = sys.argv[1], json.load(open(sys.argv[2]))
sys.argv = [sys.argv[0], DOCS, sys.argv[2], os.path.join(os.path.dirname(sys.argv[2]), 'values.json')]
src = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gen_tasks.py')).read()
g = {'__name__': 'gen'}
exec(src.split("if __name__ == '__main__':")[0], g)
T, title, brit = g['T'], g['title'], g['brit']

# Order on the home page: the tests most people look for first.
ORDER = ['open-field', 'elevated-plus-maze', 'three-chamber', 'novel-object-recognition', 'water-maze', 'dyadic-social',
         'y-maze', 'fear-conditioning', 'barnes-maze', 'light-dark-box', 'tail-suspension', 'resident-intruder',
         'group-behavior', 'social-interaction', 'elevated-zero-maze', 't-maze', 'place-preference', 'passive-avoidance', 'step-down',
         'looming-escape', 'platform-avoidance', 'novelty-suppressed-feeding', 'visual-cliff', 'marble-burying',
         'head-direction', 'spatial-exploration', 'rotation', 'pose-only']
CATS = [('social', 'Social', '社交'), ('navigation', 'Navigation', '导航'), ('anxiety', 'Anxiety', '焦虑'),
        ('memory', 'Memory & fear', '记忆与恐惧'), ('motor', 'Motor & coping', '运动与应对'), ('general', 'General', '通用')]
INFO = {s: dict(key=k, cat=c, method=m, classic=cl) for s, k, c, m, cl, _ in T}
INFO['tail-suspension'] = dict(key=None, cat='motor', method='multi', classic=False)
assert sorted(ORDER) == sorted(INFO), set(ORDER) ^ set(INFO)
N = len(ORDER)

TXT = {
    'en': dict(
        strip_label='{n} tasks', strip_hint='Drag to browse, tap one to see exactly how it is scored',
        kicker='Task library', h2='{n} tasks, each explained',
        lede='Pick a test and see how RodentFlow scores it: the design, why keypoints help, how every measure is defined, a simulated example and the papers behind it.',
        cta='Open the task library', all='All', more='Show all {n} tasks', filters='Filter tasks by area',
        table='Which tracker each test uses',
        note='Without video, marble burying, sucrose preference, beam walking, gait and the two-armed bandit can be entered by hand or imported from CSV, TSV or JSON, then compared like any other test.',
        m={'pose': 'One animal', 'pose2': 'Two animals', 'group': 'Group', 'multi': 'Multi-chamber', 'classic': 'Centroid'},
        tst=('Tail suspension, multi-chamber', 'Several mice in one recording · immobility in minutes 2–6')),
    'zh': dict(
        strip_label='{n} 个范式', strip_hint='拖动浏览，点一个看它到底怎样评分',
        kicker='范式库', h2='{n} 个范式，逐一讲透',
        lede='选一个测试，看 RodentFlow 怎样评分：实验设计、为什么用关键点、每个指标的定义、模拟示例和相关文献。',
        cta='打开范式库', all='全部', more='显示全部 {n} 个范式', filters='按领域筛选范式',
        table='每种实验用哪种追踪方式',
        note='不用视频时，埋珠、糖水偏好、平衡木、步态和双臂老虎机可以手动录入，或从 CSV、TSV、JSON 导入，再像其他实验一样比较。',
        m={'pose': '单鼠', 'pose2': '双鼠', 'group': '群体', 'multi': '多格', 'classic': '质心'},
        tst=('多格悬尾', '一段录像里多只小鼠 · 第 2–6 分钟不动时间')),
}
for _t in TXT.values():
    for _k in ('strip_label', 'h2', 'more'):
        _t[_k] = _t[_k].format(n=N)
DOT = {'pose': '<i class="dot" style="--c:var(--m-pose)"></i>', 'pose2': '<i class="dot ab"></i>', 'group': '<i class="dot grp"></i>',
       'multi': '<i class="dot" style="--c:var(--m-tst)"></i>', 'classic': '<i class="dot" style="--c:var(--m-centroid)"></i>'}
ARROW = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>'


def name_tag(slug, lang):
    t = TXT[lang]
    if slug == 'tail-suspension':
        return t['tst']
    k = INFO[slug]['key']
    tag = brit(CAT[k]['tagline_en']) if lang == 'en' else CAT[k]['tagline']
    return title(k, lang), tag


def paths(lang):
    up = '' if lang == 'en' else '../'
    return (lambda s: f'{up}img/tasks/thumbs/{s}.{lang}.png'), (lambda s: f'tasks/{s}.html')


def strip(lang):
    t = TXT[lang]; img, href = paths(lang)
    chips = []
    for s in ORDER:
        n, _ = name_tag(s, lang)
        chips.append(f'<a class="tk-chip" href="{href(s)}"><img src="{img(s)}" alt="" loading="lazy" draggable="false"><span>{escape(n)}</span></a>')
    track = ''.join(chips)
    dup = track.replace('<a class="tk-chip"', '<a class="tk-chip" tabindex="-1" aria-hidden="true"')
    return (f'<div class="tk-strip">\n'
            f'  <a class="tk-strip-head" href="#tasks"><b>{t["strip_label"]}</b><span>{t["strip_hint"]}</span>{ARROW}</a>\n'
            f'  <div class="tk-marquee"><div class="tk-track">{track}{dup}</div></div>\n'
            f'</div>')


def section(lang, table_html):
    t = TXT[lang]; img, href = paths(lang)
    counts = {c: sum(1 for s in ORDER if INFO[s]['cat'] == c) for c, *_ in CATS}
    btns = [f'<button type="button" data-cat="all" aria-pressed="true">{t["all"]}<span>{len(ORDER)}</span></button>']
    for c, en, zh in CATS:
        btns.append(f'<button type="button" data-cat="{c}" aria-pressed="false">{en if lang == "en" else zh}<span>{counts[c]}</span></button>')
    cards = []
    for s in ORDER:
        n, tag = name_tag(s, lang)
        i = INFO[s]
        ms = [i['method']] + (['classic'] if i['classic'] else [])
        meth = ''.join(f'<span>{DOT[m]}{t["m"][m]}</span>' for m in ms)
        cards.append(f'      <li data-cat="{i["cat"]}"><a href="{href(s)}">'
                     f'<span class="tk-img"><img src="{img(s)}" alt="" loading="lazy"></span>'
                     f'<span class="tk-name">{escape(n)}</span><span class="tk-tag">{escape(tag)}</span>'
                     f'<span class="tk-m">{meth}</span></a></li>')
    return f'''<section class="light tasks-sec" id="tasks" aria-labelledby="tasks-h">
  <span id="tests" class="anchor-alias"></span>
  <div class="wrap">
    <div class="tk-head">
      <div>
        <p class="tk-kicker">{t["kicker"]}</p>
        <h2 id="tasks-h">{t["h2"]}</h2>
        <p class="lede">{t["lede"]}</p>
      </div>
      <a class="tk-cta" href="tasks/">{t["cta"]}{ARROW}</a>
    </div>
    <div class="tk-filters" role="group" aria-label="{t["filters"]}">
      {"".join(btns)}
    </div>
    <ul class="tk-grid">
{chr(10).join(cards)}
    </ul>
    <button type="button" class="tk-more" hidden>{t["more"]}</button>
    <details class="tk-table">
      <summary>{t["table"]}</summary>
{table_html}
    </details>
    <p class="tests-note">{t["note"]}</p>
  </div>
</section>'''


def replace_block(s, name, new):
    a, b = f'<!-- {name}:START -->', f'<!-- {name}:END -->'
    i, j = s.index(a) + len(a), s.index(b)
    return s[:i] + '\n' + new + '\n' + s[j:]


for lang in ('en', 'zh'):
    p = os.path.join(DOCS, 'public', 'index.html' if lang == 'en' else 'zh/index.html')
    s = open(p, encoding='utf-8').read()
    table = re.search(r'<!-- TASK-TABLE:START -->\n(.*?)\n<!-- TASK-TABLE:END -->', s, re.S).group(1)
    s = replace_block(s, 'TASK-STRIP', strip(lang))
    s = replace_block(s, 'TASKS', section(lang, '<!-- TASK-TABLE:START -->\n' + table + '\n<!-- TASK-TABLE:END -->'))
    open(p, 'w', encoding='utf-8').write(s)
    print('ok', p)
