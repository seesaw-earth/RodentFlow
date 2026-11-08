"""Extract per-paradigm text from Paradigms.swift into JSON (zh + en)."""
import json, re, sys
src = open(sys.argv[1], encoding='utf-8').read()
tr = json.load(open(sys.argv[2], encoding='utf-8'))
def en(z): return tr.get(z, z)
def block(var):
    i = src.index(f'    var {var}')
    j = src.index('\n    }\n', i)
    return src[i:j]
def cases(b):
    parts = re.split(r'\n        case ([^\n]+?):', b)
    out = {}
    for k in range(1, len(parts), 2):
        names = re.findall(r'\.(\w+)', parts[k])
        for n in names: out[n] = parts[k + 1]
    return out
S = lambda s: re.findall(r'L10n\.tr\("((?:[^"\\]|\\.)*)"\)', s)
res = {}
for var in ('englishName', 'title', 'tagline', 'summary', 'whyPose'):
    for n, body in cases(block(var)).items():
        m = re.search(r'return (?:L10n\.tr\()?"((?:[^"\\]|\\.)*)"', body)
        if m:
            res.setdefault(n, {})[var] = m.group(1)
for n, body in cases(block('setupTips')).items():
    res.setdefault(n, {})['setup_zh'] = S(body); res[n]['setup_en'] = [en(x) for x in S(body)]
for n, body in cases(block('measures')).items():
    ms = re.findall(r'MeasureInfo\(name: (L10n\.tr\("(?:[^"\\]|\\.)*"\)|"(?:[^"\\]|\\.)*"), definition: L10n\.tr\("((?:[^"\\]|\\.)*)"\)\)', body)
    out = []
    for nm, d in ms:
        nz = re.sub(r'^L10n\.tr\("|"\)$|^"|"$', '', nm)
        out.append(dict(name_zh=nz, name_en=en(nz), def_zh=d, def_en=en(d)))
    res.setdefault(n, {})['measures'] = out
for n, body in cases(block('references')).items():
    refs = re.findall(r'PaperRef\(citation: "((?:[^"\\]|\\.)*)", doi: (?:"([^"]*)"|nil)\)', body)
    res.setdefault(n, {})['refs'] = [dict(citation=c, doi=d) for c, d in refs]
for n in res:
    for k in ('title', 'tagline', 'summary', 'whyPose'):
        if k in res[n]: res[n][k + '_en'] = en(res[n][k])
json.dump(res, open(sys.argv[3], 'w'), ensure_ascii=False, indent=1)
print(len(res), 'paradigms;', sum(len(v.get('refs', [])) for v in res.values()), 'refs;', sum(len(v.get('measures', [])) for v in res.values()), 'measures')
missing = [n for n, v in res.items() if 'measures' not in v or 'refs' not in v]
print('missing parts:', missing)
