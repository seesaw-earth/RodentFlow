"""Fix **bold** next to Chinese punctuation, which CommonMark does not close.

`**帧率：**大多数` renders with literal asterisks, because a closing ** that follows punctuation must be followed
by whitespace or punctuation. Move the punctuation outside: `**帧率**：大多数`. Likewise `点**“开始”**` → `点“**开始**”`.
Usage: python3 fix_cjk_bold.py FILE...
"""
import re, sys

P = set('：。，；、）！？」』”“（「『:;,.!?()')


def is_p(c):
    return c in P or c.isspace() or c == ''


def fix_line(line):
    if line.count('**') < 2 or '`' in line and line.strip().startswith('`'):
        return line
    parts = line.split('**')
    if len(parts) % 2 == 0:          # unbalanced, leave it
        return line
    out = [parts[0]]
    for k in range(1, len(parts), 2):
        before, bold, after = out[-1], parts[k], parts[k + 1]
        # closing delimiter: punctuation at the end of the bold text, a letter right after
        while bold and bold[-1] in P and after and not is_p(after[0]):
            after = bold[-1] + after
            bold = bold[:-1]
        # opening delimiter: a letter right before, punctuation at the start of the bold text
        while bold and bold[0] in P and before and not is_p(before[-1]):
            before = before + bold[0]
            bold = bold[1:]
        out[-1] = before
        out.append(bold)
        out.append(after)
    res = out[0]
    for k in range(1, len(out), 2):
        res += '**' + out[k] + '**' + out[k + 1]
    return res


def fix(path):
    lines = open(path, encoding='utf-8').read().split('\n')
    fence = False
    n = 0
    for i, l in enumerate(lines):
        if l.lstrip().startswith('```'):
            fence = not fence
            continue
        if fence:
            continue
        new = fix_line(l)
        if new != l:
            lines[i] = new
            n += 1
    if n:
        open(path, 'w', encoding='utf-8').write('\n'.join(lines))
    return n


if __name__ == '__main__':
    tot = 0
    for p in sys.argv[1:]:
        tot += fix(p)
    print('lines fixed', tot)
