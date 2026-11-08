import json, sys, os, warnings
warnings.filterwarnings('ignore')
sys.path.insert(0, os.path.dirname(__file__))
from sim_a import TASKS_A
try:
    from sim_b import TASKS_B
except ImportError:
    TASKS_B = {}
try:
    from sim_c import TASKS_C
except ImportError:
    TASKS_C = {}
out_dir = sys.argv[1]
only = sys.argv[2:] or None
os.makedirs(out_dir, exist_ok=True)
vals_path = os.path.join(out_dir, 'values.json')
vals = json.load(open(vals_path)) if os.path.exists(vals_path) else {}
for slug, fn in {**TASKS_A, **TASKS_B, **TASKS_C}.items():
    if only and slug not in only:
        continue
    for lang in ('en', 'zh'):
        f = os.path.join(out_dir, f'{slug}.{lang}.png')
        v = fn(lang, f)
        from PIL import Image
        Image.open(f).convert('RGB').quantize(colors=128, method=Image.Quantize.MEDIANCUT,
                                              dither=Image.Dither.NONE).save(f, optimize=True)
    vals[slug] = {k: (x.item() if hasattr(x, "item") else x) for k, x in v.items()}
    print(slug, vals[slug])
json.dump(vals, open(vals_path, 'w'), indent=1, ensure_ascii=False)
