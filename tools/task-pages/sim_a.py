"""Simulated figures, part A: anxiety & exploration tasks."""
import math
import numpy as np
from matplotlib import patches as mp
from simlib import *


def py(d):
    return {k: (float(v) if isinstance(v, (np.floating,)) else int(v) if isinstance(v, np.integer) else v) for k, v in d.items()}

FPS = 10


def angdiff(a, b):
    return (a - b + np.pi) % (2 * np.pi) - np.pi


# ------------------------------------------------------------------ open field
def open_field(lang, out):
    W = 40
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < W - 0.8
    wall = [(3, y) for y in range(4, 37, 6)] + [(37, y) for y in range(4, 37, 6)] + \
           [(x, 3) for x in range(4, 37, 6)] + [(x, 37) for x in range(4, 37, 6)]
    centre = [(20, 20), (15, 25), (25, 15), (17, 17), (24, 24)]
    m = simulate(600, FPS, (20, 20), inside, wall + centre, [1] * len(wall) + [0.9] * len(centre), seed=3)
    inc = (m.x > 10) & (m.x < 30) & (m.y > 10) & (m.y < 30)
    step = np.hypot(np.diff(m.x), np.diff(m.y))
    dist = step.sum() / 100
    centre_pct = inc.mean() * 100
    entries = sum(1 for a, b in runs(inc) if a > 0)
    imm = min_duration(m.speed < 1.0, FPS * 1)
    per_min = [step[i * 60 * FPS:(i + 1) * 60 * FPS].sum() / 100 for i in range(10)]
    turns = (m.h[-1] - m.h[0]) / (2 * np.pi)
    fig, a, b = figure()
    arena_axes(a, (0, W), (0, W), T(lang, 'Open field, 40 × 40 cm, 10 min', '旷场，40 × 40 cm，10 分钟'))
    rect(a, 10, 10, 20, 20, fc=ZONE_B, ec='none', z=0)
    rect(a, 0, 0, W, W)
    label(a, 20, 11.8, T(lang, 'centre (50 % of side)', '中央区（边长的 50 %）'), color=BLUE, size=7)
    track(a, m, lw=0.55, alpha=0.75)
    bars(b, [str(i + 1) for i in range(10)], per_min, [BLUE] * 10, fmt='{:.1f}', ylabel=T(lang, 'Distance (m)', '路程（m）'))
    b.set_xlabel(T(lang, 'Minute', '分钟'))
    b.set_title(T(lang, f'Distance per minute · total {dist:.1f} m · centre {centre_pct:.0f} % of time',
                  f'每分钟路程 · 共 {dist:.1f} m · 中央区 {centre_pct:.0f} % 时间'))
    finish(fig, out, NOTE[lang])
    return dict(distance_m=round(dist, 1), centre_pct=round(centre_pct, 1), centre_entries=entries,
                immobile_s=round(imm.sum() / FPS, 1), net_turns=round(turns, 1))


# ------------------------------------------------------------------ elevated plus maze
def epm(lang, out):
    L, w = 30, 5
    hw = w / 2

    def on(x, y):
        return (abs(x) <= hw and abs(y) <= L + hw) or (abs(y) <= hw and abs(x) <= L + hw)
    inside = lambda x, y: on(x, y)
    closed = [(-26, 0), (26, 0), (-14, 0), (14, 0)]
    open_ = [(0, -12, -6, -12), (0, 12, 6, 12), (0, -24, 6, -24), (0, 22, -6, 22)]
    m = simulate(300, FPS, (0, 0), inside, closed + open_, [1.4] * 4 + [0.55] * 4, seed=11,
                 dwell=(1.0, 4.0), speed=(5, 14))
    heading_from_motion(m)
    # along an arm the body points along the arm (the arms are 5 cm wide)
    vy = np.gradient(m.y); vx = np.gradient(m.x)
    on_open = (np.abs(m.x) <= hw) & (np.abs(m.y) > hw + 1)
    on_closed = (np.abs(m.y) <= hw) & (np.abs(m.x) > hw + 1)
    m.h = np.where(on_open, np.where(np.convolve(vy, np.ones(9) / 9, 'same') >= 0, math.pi / 2, -math.pi / 2),
                   np.where(on_closed, np.where(np.convolve(vx, np.ones(9) / 9, 'same') >= 0, 0.0, math.pi), m.h))
    rng = np.random.default_rng(12)
    inject_looks(m, rng, 14, lambda i: abs(m.y[i]) > 6 and abs(m.x[i]) <= hw,
                 lambda i: (0.0 if rng.random() < 0.5 else math.pi) + rng.normal(0, 0.2))
    bx, by = m.x, m.y
    tx, ty = m.tail
    nx, ny = m.nose
    zone = lambda X, Y: np.where((np.abs(X) <= hw) & (np.abs(Y) <= hw), 0,
                                np.where(np.abs(Y) > hw, 1, 2))   # 0 centre, 1 open (N/S), 2 closed (E/W)
    zb, zt = zone(bx, by), zone(tx, ty)
    # entry rule: body centre and tail base in the arm
    arm = np.where((zb == zt) & (zb > 0), zb, 0)
    state = np.zeros(len(arm), int)
    cur = 0
    for i, a_ in enumerate(arm):
        if a_ > 0:
            cur = a_
        elif zb[i] == 0 and zt[i] == 0:
            cur = 0
        state[i] = cur
    t_open = (state == 1).sum() / FPS
    t_closed = (state == 2).sum() / FPS
    t_centre = (state == 0).sum() / FPS
    open_pct = 100 * t_open / max(t_open + t_closed, 1e-9)
    ent = [state[a] for a, b in runs(state > 0) for _ in [0]]
    ent = [state[a] for a, b in [(i, i) for i in range(1, len(state)) if state[i] != state[i - 1] and state[i] > 0]]
    n_open, n_closed = ent.count(1), ent.count(2)
    # head dips: nose beyond an open-arm edge, body on the open arm or protected?  (body on open arm)
    beyond = (np.abs(ny) > hw) & (np.abs(nx) > hw) & (state == 1)
    dips = [r for r in runs(beyond) if r[1] - r[0] >= 2]
    fig, a, b = figure(ratios=(1, 1.1))
    arena_axes(a, (-L - hw, L + hw), (-L - hw, L + hw), T(lang, 'Elevated plus maze, 5 min', '高架十字迷宫，5 分钟'))
    rect(a, -hw, -L - hw, w, 2 * L + w, fc=ZONE_O, ec=ARENA_EDGE)
    rect(a, -L - hw, -hw, 2 * L + w, w, fc=ZONE_G, ec=ARENA_EDGE)
    rect(a, -hw, -hw, w, w, fc=SURF, ec=ARENA_EDGE)
    for s_ in (-1, 1):
        a.plot([-L - hw, -hw] if s_ < 0 else [hw, L + hw], [-hw - 0.6] * 2, color=INK2, lw=2.2)
        a.plot([-L - hw, -hw] if s_ < 0 else [hw, L + hw], [hw + 0.6] * 2, color=INK2, lw=2.2)
    label(a, 6.5, -L + 1, T(lang, 'open', '开放臂'), color=ORANGE, ha='left')
    label(a, L - 3, -5.5, T(lang, 'closed', '闭合臂'), color=INK2)
    track(a, m, lw=0.6)
    for s0, s1 in dips:
        i = (s0 + s1) // 2
        a.plot(nx[i], ny[i], 'o', ms=4.5, color=ORANGE, mec=SURF, mew=0.8, zorder=6)
    names = [T(lang, 'Open arms', '开放臂'), T(lang, 'Centre', '中央'), T(lang, 'Closed arms', '闭合臂')]
    bars(b, names, [t_open, t_centre, t_closed], [ORANGE, MUTED, INK2], unit=' s', ylabel=T(lang, 'Time (s)', '时间（s）'))
    b.set_title(T(lang, f'Open-arm time {open_pct:.0f} % · {len(dips)} head dips (orange dots)',
                  f'开放臂时间 {open_pct:.0f} % · 头探 {len(dips)} 次（橙点）'))
    finish(fig, out, NOTE[lang])
    return dict(open_pct=round(open_pct, 1), open_entries=n_open, closed_entries=n_closed,
                open_entry_pct=round(100 * n_open / max(n_open + n_closed, 1), 1), head_dips=len(dips),
                t_open=round(t_open), t_closed=round(t_closed), t_centre=round(t_centre))


# ------------------------------------------------------------------ elevated zero maze
def ezm(lang, out):
    R, wtrack = 30, 5
    r_in = R - wtrack
    rng = np.random.default_rng(5)
    n = 300 * FPS
    th = np.zeros(n); rr = np.zeros(n); hd = np.zeros(n)
    t_ = 0.0; v = 0.0; theta = math.radians(135); r = R - wtrack / 2
    open_ = lambda a: (np.cos(a) > math.cos(math.radians(45))) | (np.cos(a) < -math.cos(math.radians(45)))
    dwell = 0
    for i in range(n):
        if dwell > 0:
            dwell -= 1
            v *= 0.6
        else:
            if rng.random() < 0.015:
                dwell = int(rng.uniform(10, 40))
            in_open = open_(theta)
            target = rng.normal(0.0, 0.004) + (0.010 if not in_open else 0.016) * (1 if v >= 0 else -1)
            v = 0.9 * v + 0.1 * target * 10 + rng.normal(0, 0.004)
            if rng.random() < 0.004:
                v = -v
        theta += v
        r = min(max(r + rng.normal(0, 0.15), r_in + 0.8), R - 0.8)
        th[i], rr[i] = theta, r
        tangent = theta + (math.pi / 2 if v >= 0 else -math.pi / 2)
        hd[i] = tangent
    # head dips: during pauses in open segments the head turns outward or inward
    for a_, b_ in runs(np.r_[np.diff(th) == 0, False] | (np.abs(np.gradient(th)) < 0.002)):
        if b_ - a_ > 6 and open_(th[a_]):
            k = rng.choice([1, -1])
            hd[a_ + 2:b_ - 2] = th[a_ + 2:b_ - 2] + (0 if k > 0 else math.pi)
    x, y = rr * np.cos(th), rr * np.sin(th)
    m = Mouse(np.arange(n) / FPS, x, y, hd)
    nx, ny = m.nose
    rn = np.hypot(nx, ny)
    inopen = open_(th)
    open_pct = inopen.mean() * 100
    outer = min_duration(inopen & (rn > R + 1), 2)
    inner = min_duration(inopen & (rn < r_in - 1), 2)
    n_out, n_in = len(runs(outer)), len(runs(inner))
    per_min = [inopen[i * 60 * FPS:(i + 1) * 60 * FPS].mean() * 100 for i in range(5)]
    fig, a, b = figure()
    arena_axes(a, (-R, R), (-R, R), T(lang, 'Elevated zero maze, 5 min', '高架零迷宫，5 分钟'), pad=4)
    for c0 in (-45, 135):
        a.add_patch(mp.Wedge((0, 0), R, c0, c0 + 90, width=wtrack, fc=ZONE_O, ec=ARENA_EDGE, lw=1))
    for c0 in (45, 225):
        a.add_patch(mp.Wedge((0, 0), R, c0, c0 + 90, width=wtrack, fc=ZONE_G, ec=ARENA_EDGE, lw=1))
        a.add_patch(mp.Arc((0, 0), 2 * R, 2 * R, theta1=c0, theta2=c0 + 90, color=INK2, lw=2.2))
        a.add_patch(mp.Arc((0, 0), 2 * r_in, 2 * r_in, theta1=c0, theta2=c0 + 90, color=INK2, lw=2.2))
    label(a, R + 2.5, 0, T(lang, 'open', '开放段'), color=ORANGE, ha='left')
    label(a, 0, -R - 3, T(lang, 'closed', '闭合段'), color=INK2)
    track(a, m, lw=0.35, alpha=0.5)
    for (s0, s1), col in [(r_, ORANGE) for r_ in runs(outer)] + [(r_, VIOLET) for r_ in runs(inner)]:
        i = (s0 + s1) // 2
        a.plot(nx[i], ny[i], 'o', ms=4.5, color=col, mec=SURF, mew=0.8, zorder=6)
    xs = np.arange(1, 6)
    b.plot(xs, per_min, '-o', color=ORANGE, lw=2, ms=5, mec=SURF, mew=1)
    for xi, v_ in zip(xs, per_min):
        b.text(xi, v_ + 3, f'{v_:.0f} %', ha='center', fontsize=7.5, color=INK)
    b.set_ylim(0, 100); b.set_xticks(xs)
    b.set_xlabel(T(lang, 'Minute', '分钟')); b.set_ylabel(T(lang, 'Time in open segments (%)', '开放段时间（%）'))
    b.grid(axis='y', color=GRID, lw=0.6)
    b.set_title(T(lang, f'Open segments {open_pct:.0f} % · head dips: {n_out} outer (orange), {n_in} inner (violet)',
                  f'开放段 {open_pct:.0f} % · 头探：外缘 {n_out} 次（橙）、内缘 {n_in} 次（紫）'))
    finish(fig, out, NOTE[lang])
    return dict(open_pct=round(open_pct, 1), dips_outer=n_out, dips_inner=n_in)


# ------------------------------------------------------------------ light–dark box
def light_dark(lang, out):
    W, H, xd = 45, 30, 30          # light = x < 30 (2/3), dark = x > 30, door at the middle of the wall
    def inside(x, y):
        if not (0.8 < x < W - 0.8 and 0.8 < y < H - 0.8):
            return False
        return not (abs(x - xd) < 0.6 and not (11 < y < 19))
    dark = [(38, 6), (40, 24), (36, 15), (42, 15)]
    light = [(8, 6), (15, 24), (22, 12), (6, 22), (25, 25)]
    door = [(35, 15, 26, 15)]
    m = simulate(600, FPS, (8, 15), inside, dark + light + door, [2.0] * 4 + [0.5] * 5 + [0.4], seed=7, dwell=(3, 10),
                 speed=(14, 26))
    heading_from_motion(m)
    rng = np.random.default_rng(8)
    inject_looks(m, rng, 9, lambda i: xd + 2.0 < m.x[i] < xd + 4.5 and 11 < m.y[i] < 19, lambda i: math.pi + rng.normal(0, 0.15))
    nx, ny = m.nose; tx, ty = m.tail
    in_light = m.x < xd
    light_pct = in_light.mean() * 100
    trans = len(np.where(np.diff(in_light.astype(int)) != 0)[0])
    first_dark = m.t[np.argmax(~in_light)] if (~in_light).any() else None
    poke = min_duration((nx < xd) & (m.x > xd) & (tx > xd), 2)
    n_poke = len(runs(poke))
    per_min = [in_light[i * 60 * FPS:(i + 1) * 60 * FPS].mean() * 100 for i in range(10)]
    fig, a, b = figure()
    arena_axes(a, (0, W), (0, H), T(lang, 'Light–dark box, 10 min', '明暗箱，10 分钟'))
    rect(a, xd, 0, W - xd, H, fc='#e7e6e1', ec='none', z=0)
    rect(a, 0, 0, W, H)
    a.plot([xd, xd], [0, 11], color=INK2, lw=2); a.plot([xd, xd], [19, H], color=INK2, lw=2)
    label(a, xd / 2, H + 2.4, T(lang, 'light side (2/3)', '明室（2/3）'), color=INK2)
    label(a, (xd + W) / 2, H + 2.4, T(lang, 'dark side', '暗室'), color=INK2)
    track(a, m, lw=0.55, alpha=0.8)
    for s0, s1 in runs(poke):
        i = (s0 + s1) // 2
        a.plot(nx[i], ny[i], 'o', ms=4.5, color=ORANGE, mec=SURF, mew=0.8, zorder=6)
    bars(b, [str(i + 1) for i in range(10)], per_min, [AQUA] * 10, fmt='{:.0f}', ylim=(0, 100),
         ylabel=T(lang, 'Light-side time (%)', '明室时间（%）'))
    b.set_xlabel(T(lang, 'Minute', '分钟'))
    b.set_title(T(lang, f'Light side {light_pct:.0f} % · {trans} transitions · {n_poke} head pokes (orange)',
                  f'明室 {light_pct:.0f} % · 穿梭 {trans} 次 · 探头 {n_poke} 次（橙点）'))
    finish(fig, out, NOTE[lang])
    return dict(light_pct=round(light_pct, 1), transitions=trans, head_pokes=n_poke,
                latency_dark=round(float(first_dark), 1) if first_dark is not None else None)


# ------------------------------------------------------------------ novelty-suppressed feeding
def nsf(lang, out):
    W = 40; fx, fy = 20, 20; rz = 3
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < W - 0.8
    wall = [(3, y) for y in range(5, 36, 6)] + [(37, y) for y in range(5, 36, 6)] + [(x, 3) for x in range(5, 36, 6)]
    food = [(fx + 4.5, fy + 0.5, fx, fy)]
    near = [(3, y) for y in range(5, 36, 5)] + [(x, 37) for x in range(5, 36, 5)]
    early = simulate(70, FPS, (4, 36), inside, near, None, seed=20)
    pre = simulate(170, FPS, (early.x[-1], early.y[-1]), inside, wall + food, [1] * len(wall) + [0.12], seed=21, dwell=(0.3, 1.2))
    pre = Mouse(np.arange(len(early.x) + len(pre.x)) / FPS, np.r_[early.x, pre.x], np.r_[early.y, pre.y], np.r_[early.h, pre.h])
    # feeding: the mouse comes to the food and stays (body almost still), then eats
    post = simulate(120, FPS, (pre.x[-1], pre.y[-1]), inside, food, [1], seed=22, dwell=(40, 60), speed=(8, 12))
    x = np.r_[pre.x, post.x]; y = np.r_[pre.y, post.y]; h = np.r_[pre.h, post.h]
    m = Mouse(np.arange(len(x)) / FPS, x, y, h)
    nx, ny = m.nose
    dn = np.hypot(nx - fx, ny - fy)
    inzone = dn < rz
    first_app = m.t[np.argmax(inzone)]
    n_app = len(runs(inzone))
    cand = min_duration(inzone & (m.speed < 2), 3 * FPS)
    c_start = m.t[np.argmax(cand)] if cand.any() else None
    fig, a, b = figure(ratios=(1, 1.35))
    arena_axes(a, (0, W), (0, W), T(lang, 'Novelty-suppressed feeding', '新奇抑制摄食'))
    rect(a, 0, 0, W, W)
    circ(a, fx, fy, rz, fc=ZONE_O, ec=ORANGE, lw=0.8, ls='--')
    circ(a, fx, fy, 1.2, fc='#c9a46a', ec='none', z=2)
    label(a, fx, fy - 5, T(lang, 'food zone', '食物区'), color=ORANGE, size=7)
    track(a, m, lw=0.55, alpha=0.8)
    b.plot(m.t, dn, color=BLUE, lw=0.9)
    b.axhline(rz, color=ORANGE, lw=1, ls='--')
    b.text(m.t[-1], rz + 1, T(lang, 'food zone (3 cm)', '食物区（3 cm）'), ha='right', fontsize=7, color=ORANGE)
    for s0, s1 in runs(cand):
        b.axvspan(m.t[s0], m.t[s1 - 1], color=ZONE_A, zorder=0)
    if c_start is not None:
        b.axvline(c_start, color=AQUA, lw=1.4)
        b.text(c_start + 3, b.get_ylim()[1] * 0.9 if b.get_ylim()[1] > 10 else 20,
               T(lang, 'candidate feeding\n→ first bite confirmed\nin the review', '候选进食\n→ 在回看中\n确认首次进食'),
               fontsize=7, color=INK, va='top')
    b.set_xlabel(T(lang, 'Time (s)', '时间（s）')); b.set_ylabel(T(lang, 'Nose–food distance (cm)', '鼻尖–食物距离（cm）'))
    b.set_xlim(0, m.t[-1]); b.set_ylim(0, None)
    b.grid(axis='y', color=GRID, lw=0.6)
    b.set_title(T(lang, f'First approach {first_app:.0f} s · {n_app} approaches · candidate feeding from {c_start:.0f} s',
                  f'首次接近 {first_app:.0f} s · 接近 {n_app} 次 · 候选进食始于 {c_start:.0f} s'))
    finish(fig, out, NOTE[lang])
    return dict(first_approach_s=round(float(first_app)), approaches=n_app, candidate_s=round(float(c_start)))


# ------------------------------------------------------------------ visual cliff
def visual_cliff(lang, out):
    W, H = 60, 40; b0, b1 = 24, 36          # neutral centre board (20 % of width), deep side = right
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < H - 0.8
    shallow = [(6, 6), (8, 32), (18, 20), (14, 8), (20, 34), (24, 20, 40, 20)]
    neutral = [(30, 10), (30, 30), (30, 20, 42, 20)]
    deep = [(44, 12), (50, 30)]
    m = simulate(600, FPS, (30, 20), inside, shallow + neutral + deep, [1] * 6 + [0.7] * 3 + [0.25] * 2, seed=31,
                 dwell=(1, 3))
    heading_from_motion(m)
    rng = np.random.default_rng(32)
    inject_looks(m, rng, 12, lambda i: b1 - 2.5 < m.x[i] < b1 - 0.5, lambda i: rng.normal(0, 0.25))
    tx, ty = m.tail; nx, ny = m.nose
    side = np.where((m.x > b1) & (tx > b1), 2, np.where((m.x < b0) & (tx < b0), 0, -1))
    state = np.zeros(len(side), int) + 1
    cur = 1
    for i, s_ in enumerate(side):
        if s_ >= 0:
            cur = s_
        elif b0 <= m.x[i] <= b1:
            cur = 1
        state[i] = cur
    pct = [(state == k).mean() * 100 for k in (0, 1, 2)]
    leave = np.argmax(state != 1)
    first = 'shallow' if state[leave] == 0 else 'deep'
    dips = min_duration((nx > b1) & (state != 2), 2)
    n_dips = len(runs(dips))
    fig, a, b = figure()
    arena_axes(a, (0, W), (0, H), T(lang, 'Visual cliff, 10 min', '视觉悬崖，10 分钟'))
    for xx in np.arange(0, b0, 4):
        for yy in np.arange(0, H, 4):
            if (int(xx / 4) + int(yy / 4)) % 2 == 0:
                rect(a, xx, yy, 4, 4, fc='#ecebe6', ec='none', z=0)
    for xx in np.arange(b1, W, 2):
        for yy in np.arange(0, H, 2):
            if (int(xx / 2) + int(yy / 2)) % 2 == 0:
                rect(a, xx, yy, 2, 2, fc='#f4f3ef', ec='none', z=0)
    rect(a, b0, 0, b1 - b0, H, fc=ZONE_B, ec='none', z=0)
    rect(a, 0, 0, W, H)
    label(a, 13, -2.6, T(lang, 'shallow', '浅侧'), color=INK2)
    label(a, 30, -2.6, T(lang, 'centre board', '中间板'), color=BLUE)
    label(a, 47, -2.6, T(lang, 'deep', '深侧'), color=INK2)
    track(a, m, lw=0.55, alpha=0.8)
    for s0, s1 in runs(dips):
        i = (s0 + s1) // 2
        a.plot(nx[i], ny[i], 'o', ms=4.5, color=ORANGE, mec=SURF, mew=0.8, zorder=6)
    bars(b, [T(lang, 'Shallow', '浅侧'), T(lang, 'Board', '中间板'), T(lang, 'Deep', '深侧')], pct, [AQUA, BLUE, ORANGE],
         unit=' %', ylim=(0, 100), ylabel=T(lang, 'Time (%)', '时间（%）'))
    b.set_title(T(lang, f'First choice: {first} side · {n_dips} edge head dips (orange)',
                  f'首次选择：{"浅侧" if first == "shallow" else "深侧"} · 边缘探头 {n_dips} 次（橙点）'))
    finish(fig, out, NOTE[lang])
    return dict(shallow_pct=round(pct[0], 1), board_pct=round(pct[1], 1), deep_pct=round(pct[2], 1),
                first_choice=first, edge_dips=n_dips)


# ------------------------------------------------------------------ marble burying
def marble(lang, out):
    W, H, rows, cols = 40, 25, 4, 5
    xs = np.linspace(6, W - 6, cols); ys = np.linspace(4.5, H - 4.5, rows)
    rng = np.random.default_rng(41)
    nM = rows * cols
    # covered-fraction readings every 5 min (0–30 min): digging raises it after the mouse leaves
    times = np.arange(0, 31, 5)
    c = np.zeros((nM, len(times)))
    level = np.zeros(nM)
    hot = rng.random(nM) < 0.55
    for k in range(1, len(times)):
        visits = rng.random(nM) < np.where(hot, 0.55, 0.15)
        level = np.clip(level + visits * rng.uniform(0.15, 0.45, nM), 0, 1)
        c[:, k] = level
    final = c[:, -1]
    buried = (c >= 2 / 3).sum(axis=0)
    fig, a, b = figure(ratios=(1, 1.15))
    arena_axes(a, (0, W), (0, H), T(lang, 'Marble burying, 20 marbles, 30 min', '埋珠实验，20 颗，30 分钟'), pad=2)
    rect(a, 0, 0, W, H, fc='#f3eee3')
    cmap = plt.get_cmap('Blues')
    for i in range(nM):
        cx, cy = xs[i % cols], ys[i // cols]
        col = cmap(0.15 + 0.8 * final[i])
        circ(a, cx, cy, 1.9, fc=col, ec=INK if final[i] >= 2 / 3 else ARENA_EDGE, lw=1.4 if final[i] >= 2 / 3 else 0.7, z=3)
        label(a, cx, cy + 3.2, f'{final[i]:.2f}', size=6.5, color=INK2)
    for k, (cx, cy) in enumerate([(xs[0], ys[0]), (xs[-1], ys[0]), (xs[-1], ys[-1]), (xs[0], ys[-1])]):
        label(a, cx - 2.6, cy - 2.4, str(k + 1), size=6.5, color=BLUE, weight='bold')
    b.step(times, buried, where='post', color=BLUE, lw=2)
    b.plot(times, buried, 'o', color=BLUE, ms=4.5, mec=SURF, mew=1)
    for tt, v in zip(times, buried):
        b.text(tt, v + 0.5, str(v), ha='center', fontsize=7.5, color=INK)
    b.set_xticks(times); b.set_ylim(0, 20)
    b.set_xlabel(T(lang, 'Minutes', '分钟')); b.set_ylabel(T(lang, 'Marbles buried (≥ 2/3 covered)', '埋住的珠子（≥ 2/3 被盖住）'))
    b.grid(axis='y', color=GRID, lw=0.6)
    b.set_title(T(lang, f'{buried[-1]} of 20 buried at 30 min · numbers = covered fraction c',
                  f'30 分钟时埋住 {buried[-1]} / 20 颗 · 数字为遮盖程度 c'))
    finish(fig, out, NOTE[lang])
    return dict(buried=int(buried[-1]), half=int((final >= 0.5).sum()), full=int((final >= 0.95).sum()))


NOTE = {'en': 'Simulated session for illustration: how RodentFlow turns tracking into the measures. Not real data.',
        'zh': '模拟实验，用来说明 RodentFlow 如何把追踪结果变成指标，不是真实数据。'}

TASKS_A = {
    'open-field': open_field, 'elevated-plus-maze': epm, 'elevated-zero-maze': ezm, 'light-dark-box': light_dark,
    'novelty-suppressed-feeding': nsf, 'visual-cliff': visual_cliff, 'marble-burying': marble,
}
