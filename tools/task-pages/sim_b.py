"""Simulated figures, part B: social, navigation and memory tasks."""
import math
import numpy as np
from matplotlib import patches as mp
from simlib import *
from sim_a import NOTE, angdiff

FPS = 10


def facing(m, cx, cy, deg=45):
    ang = np.arctan2(cy - m.y, cx - m.x)
    return np.abs(angdiff(m.h, ang)) <= np.radians(deg)


def around(cx, cy, r, angles_deg, w=1.0):
    return [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)), cx, cy) for a in angles_deg]


# ------------------------------------------------------------------ three-chamber
def three_chamber(lang, out):
    W, H, rc = 60, 40, 4.0
    cups = {'L': (10, 20), 'R': (50, 20)}

    def chamber(x):
        return 0 if x < 20 else (1 if x < 40 else 2)

    def inside(x, y):
        if not (0.8 < x < W - 0.8 and 0.8 < y < H - 0.8):
            return False
        for cx, cy in cups.values():
            if math.hypot(x - cx, y - cy) < rc + 1.0:
                return False
        for wx in (20, 40):
            if abs(x - wx) < 0.6 and not (15.5 < y < 24.5):
                return False
        return True

    def via(px, py, gx, gy):
        a, b = chamber(px), chamber(gx)
        if a == b:
            return gx, gy
        if b > a:
            wx = 20 if a == 0 else 40
            return wx + 2.0, 20
        wx = 40 if a == 2 else 20
        return wx - 2.0, 20

    soc = around(*cups['L'], rc + 3.4, [-60, -20, 20, 60, 0, 300, 100, 260])
    obj = around(*cups['R'], rc + 3.4, [120, 160, 200, 240, 180])
    mid = [(30, 8), (30, 32), (27, 20), (33, 26)]
    corners = [(4, 4), (4, 36), (56, 4), (56, 36)]
    goals = soc + obj + mid + corners
    wts = [1.2] * len(soc) + [0.7] * len(obj) + [0.9] * len(mid) + [0.5] * len(corners)
    m = simulate(600, FPS, (30, 20), inside, goals, wts, seed=51, dwell=(1.0, 3.5), via=via)
    nx, ny = m.nose
    ch = np.array([chamber(x) for x in m.x])
    inv = {}
    for k, (cx, cy) in cups.items():
        inv[k] = ((np.hypot(nx - cx, ny - cy) - rc) < 2.0) & facing(m, cx, cy)
    t_soc, t_obj = inv['L'].sum() / FPS, inv['R'].sum() / FPS
    c_soc, c_mid, c_obj = [(ch == k).sum() / FPS for k in (0, 1, 2)]
    idx = (t_soc - t_obj) / (t_soc + t_obj)
    fig, a, b = figure(ratios=(1.25, 1))
    arena_axes(a, (0, W), (0, H), T(lang, 'Three-chamber test, sociability phase, 10 min', '三箱实验，社交偏好阶段，10 分钟'))
    rect(a, 0, 0, W, H)
    for wx in (20, 40):
        a.plot([wx, wx], [0, 15.5], color=INK2, lw=2); a.plot([wx, wx], [24.5, H], color=INK2, lw=2)
    for k, (cx, cy) in cups.items():
        circ(a, cx, cy, rc + 2, fc=ZONE_B if k == 'L' else ZONE_G, ec='none', z=0)
        circ(a, cx, cy, rc, fc='#d9d8d2', ec=INK2, lw=1, z=2)
    label(a, 10, H + 2.6, T(lang, 'stranger mouse', '陌生鼠'), color=BLUE)
    label(a, 30, H + 2.6, T(lang, 'centre', '中间箱'), color=INK2)
    label(a, 50, H + 2.6, T(lang, 'empty cup', '空杯'), color=INK2)
    track(a, m, lw=0.5, alpha=0.75)
    bouts = runs(min_duration(inv['L'] | inv['R'], 3))
    pts = np.array([b_[0] for b_ in bouts], int)
    grouped_bars(b, [T(lang, 'Chamber time', '箱室时间'), T(lang, 'Cup investigation', '嗅探杯子')],
                 [T(lang, 'Stranger side', '陌生鼠侧'), T(lang, 'Empty-cup side', '空杯侧')],
                 [[c_soc, t_soc], [c_obj, t_obj]], [BLUE, MUTED], unit=' s', ylabel=T(lang, 'Time (s)', '时间（s）'))
    b.set_title(T(lang, f'Social preference index {idx:.2f} (investigation)', f'社交指数 {idx:.2f}（按嗅探时间）'))
    finish(fig, out, NOTE[lang] + T(lang, '  Shaded ring: 2 cm investigation zone.', '  浅色圆环：2 cm 嗅探区。'))
    return dict(chamber_stranger_s=round(c_soc), chamber_centre_s=round(c_mid), chamber_empty_s=round(c_obj),
                inv_stranger_s=round(t_soc, 1), inv_empty_s=round(t_obj, 1), index=round(idx, 2),
                bouts=int(len(pts)))


# ------------------------------------------------------------------ social interaction (CSDS)
def social_interaction(lang, out):
    W = 42
    ex0, ex1, ey1 = 16, 26, 6           # enclosure against the top wall
    iz = (8, 0, 34, 14)                 # 26 × 14 around the enclosure
    corners = [(0, 33, 9, 42), (33, 33, 42, 42)]

    def inside(x, y):
        if not (0.8 < x < W - 0.8 and 0.8 < y < W - 0.8):
            return False
        return not (ex0 - 1 < x < ex1 + 1 and y < ey1 + 1)

    def zone_masks(m):
        izm = (m.x > iz[0]) & (m.x < iz[2]) & (m.y < iz[3])
        cm = np.zeros(len(m.x), bool)
        for c in corners:
            cm |= (m.x > c[0]) & (m.x < c[2]) & (m.y > c[1]) & (m.y < c[3])
        return izm, cm

    spread = [(x, y) for x in (5, 13, 21, 29, 37) for y in (5, 13, 21, 29, 37) if inside(x, y)]
    near = [(x, 10.5, x, 3) for x in (12, 17, 21, 25, 30)]
    cgo = [(4.5, 37.5), (37.5, 37.5)]
    m0 = simulate(150, FPS, (21, 37), inside, spread + cgo, [1] * len(spread) + [0.8, 0.8], seed=61)
    m1 = simulate(150, FPS, (21, 37), inside, spread + near + cgo, [1] * len(spread) + [2.6] * len(near) + [0.6, 0.6],
                  seed=62, dwell=(1, 5))
    iz0, c0 = zone_masks(m0); iz1, c1 = zone_masks(m1)
    t_iz = [iz0.sum() / FPS, iz1.sum() / FPS]; t_c = [c0.sum() / FPS, c1.sum() / FPS]
    ratio = t_iz[1] / t_iz[0]
    fig, a, b = figure(ratios=(1, 1.1))
    arena_axes(a, (0, W), (0, W), T(lang, 'Social interaction test, target present, 150 s', '社交互动测试，有目标鼠阶段，150 秒'))
    rect(a, iz[0], iz[1], iz[2] - iz[0], iz[3] - iz[1], fc=ZONE_B, ec='none', z=0)
    for c in corners:
        rect(a, c[0], c[1], c[2] - c[0], c[3] - c[1], fc=ZONE_G, ec='none', z=0)
    rect(a, 0, 0, W, W)
    rect(a, ex0, 0, ex1 - ex0, ey1, fc='#d9d8d2', ec=INK2, z=2, hatch='////')
    label(a, 8.6, 12.6, T(lang, 'interaction zone', '互动区'), color=BLUE, size=7, ha='left')
    label(a, 4.5, 31.5, T(lang, 'corner', '角落区'), color=INK2, size=7)
    track(a, m1, lw=0.55, alpha=0.8)
    grouped_bars(b, [T(lang, 'Interaction zone', '互动区'), T(lang, 'Corners', '角落区')],
                 [T(lang, 'No target', '无目标'), T(lang, 'Target', '有目标')],
                 [[t_iz[0], t_c[0]], [t_iz[1], t_c[1]]], [MUTED, BLUE], unit=' s', ylabel=T(lang, 'Time (s)', '时间（s）'))
    b.set_title(T(lang, f'SI ratio {ratio:.2f} (target ÷ no target, interaction zone)',
                  f'SI 比值 {ratio:.2f}（互动区：有目标 ÷ 无目标）'))
    finish(fig, out, NOTE[lang])
    return dict(iz_no=round(t_iz[0], 1), iz_target=round(t_iz[1], 1), corner_no=round(t_c[0], 1),
                corner_target=round(t_c[1], 1), si_ratio=round(ratio, 2))


# ------------------------------------------------------------------ two-animal engine
class Agent:
    def __init__(self, rng, x, y, L=7.0):
        self.x, self.y, self.h = x, y, rng.uniform(-math.pi, math.pi)
        self.L = L
        self.mode, self.timer = 'explore', rng.uniform(2, 5)
        self.goal = (x, y)
        self.v = 8.0
        self.paused = False

    def nose(self):
        return self.x + self.L / 2 * math.cos(self.h), self.y + self.L / 2 * math.sin(self.h)

    def tail(self):
        return self.x - self.L / 2 * math.cos(self.h), self.y - self.L / 2 * math.sin(self.h)


def two_mice(T_s, fps, W, H, seed, probs, fight=None, enter_at=0.0, speed=(6, 16)):
    """Two simulated mice. probs: dict mode -> probability for an agent that starts a new act.
    Modes: explore, nose (nose-to-nose), tail (anogenital sniff), follow, attack (resident only)."""
    rng = np.random.default_rng(seed)
    n = int(T_s * fps); dt = 1 / fps
    A = Agent(rng, W * 0.3, H * 0.5); B = Agent(rng, W * 0.75, H * 0.5)
    ag = [A, B]
    out = np.full((2, 3, n), np.nan)
    modes = np.empty((2, n), dtype=object)
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < H - 0.8
    i_enter = int(enter_at * fps)
    for i in range(n):
        present = [True, i >= i_enter]
        for k, me in enumerate(ag):
            if not present[k]:
                continue
            other = ag[1 - k]
            me.timer -= dt
            if me.timer <= 0:
                busy = other.mode != 'explore' and present[1 - k]
                if busy or not present[1 - k]:
                    me.mode = 'explore'
                else:
                    names = list(probs[k].keys()); p = np.array(list(probs[k].values()), float); p /= p.sum()
                    me.mode = names[rng.choice(len(names), p=p)]
                me.timer = {'explore': rng.uniform(3, 8), 'nose': rng.uniform(1.5, 3), 'tail': rng.uniform(2, 4),
                            'follow': rng.uniform(2, 4), 'attack': rng.uniform(0.6, 1.6)}[me.mode]
                me.goal = (rng.uniform(4, W - 4), rng.uniform(4, H - 4))
            # target point
            ou = (math.cos(other.h), math.sin(other.h))
            if me.mode == 'explore' or not present[1 - k]:
                # partner acts on me
                if present[1 - k] and other.mode == 'nose' and math.hypot(other.x - me.x, other.y - me.y) < 10:
                    tx, ty = me.x, me.y; want = math.atan2(other.y - me.y, other.x - me.x); v = 0.3
                elif present[1 - k] and other.mode in ('follow',):
                    tx, ty = me.goal; v = max(me.v, 11)
                elif present[1 - k] and other.mode == 'attack' and math.hypot(other.x - me.x, other.y - me.y) < 8:
                    tx, ty = me.x + rng.normal(0, 5), me.y + rng.normal(0, 5); v = rng.uniform(25, 45)
                else:
                    tx, ty = me.goal
                    if math.hypot(tx - me.x, ty - me.y) < 2:
                        me.goal = (rng.uniform(4, W - 4), rng.uniform(4, H - 4))
                        me.paused = rng.random() < 0.4
                    if me.paused and rng.random() < 0.03:
                        me.paused = False
                    v = 0.3 if me.paused else me.v
                    if rng.random() < 0.01:
                        me.v = rng.uniform(*speed)
                want = math.atan2(ty - me.y, tx - me.x) if (tx, ty) != (me.x, me.y) else me.h
            elif me.mode == 'nose':
                onx, ony = other.nose()
                tx, ty = onx + (me.L / 2 + 0.8) * math.cos(math.atan2(me.y - ony, me.x - onx)), \
                    ony + (me.L / 2 + 0.8) * math.sin(math.atan2(me.y - ony, me.x - onx))
                d = math.hypot(tx - me.x, ty - me.y)
                want = math.atan2(ony - me.y, onx - me.x) if d < 1.5 else math.atan2(ty - me.y, tx - me.x)
                v = 0.3 if d < 1.5 else 12
            elif me.mode == 'tail':
                otx, oty = other.tail()
                tx, ty = otx - (me.L / 2 + 0.7) * ou[0], oty - (me.L / 2 + 0.7) * ou[1]
                d = math.hypot(tx - me.x, ty - me.y)
                want = math.atan2(oty - me.y, otx - me.x) if d < 1.5 else math.atan2(ty - me.y, tx - me.x)
                v = min(other.v, 4) if d < 1.5 else 12
            elif me.mode == 'follow':
                otx, oty = other.tail()
                tx, ty = otx - 4 * ou[0], oty - 4 * ou[1]
                want = math.atan2(oty - me.y, otx - me.x)
                v = 13 if math.hypot(tx - me.x, ty - me.y) > 1 else 10
            else:  # attack
                tx, ty = other.x, other.y
                d = math.hypot(tx - me.x, ty - me.y)
                want = math.atan2(ty - me.y, tx - me.x) + (rng.normal(0, 1.2) if d < 7 else 0)
                v = rng.uniform(30, 50) if d < 7 else 30
            diff = (want - me.h + math.pi) % (2 * math.pi) - math.pi
            me.h += 0.4 * diff + rng.normal(0, 0.05)
            step = v * dt
            nx, ny = me.x + step * math.cos(me.h), me.y + step * math.sin(me.h)
            if not inside(nx, ny):
                me.h += math.pi * rng.uniform(0.5, 1.0)
                nx, ny = me.x + step * math.cos(me.h), me.y + step * math.sin(me.h)
                me.goal = (rng.uniform(4, W - 4), rng.uniform(4, H - 4))
            if inside(nx, ny):
                me.x, me.y = nx, ny
            out[k, :, i] = me.x, me.y, me.h
            modes[k, i] = me.mode
    t = np.arange(n) * dt
    mice = []
    for k in range(2):
        mice.append(Mouse(t, out[k, 0], out[k, 1], out[k, 2]))
    return mice, modes


def following(f, g, fps, min_s=0.5):
    """f follows g: distance < 15 cm, both faster than 5 cm/s, f oriented to g within ±45°, for ≥ 0.5 s."""
    d = np.hypot(f.x - g.x, f.y - g.y)
    ok = (d < 15) & (f.speed > 5) & (g.speed > 5) & facing(f, g.x, g.y)
    return min_duration(np.nan_to_num(ok, nan=0).astype(bool), int(min_s * fps))


def dyadic(lang, out):
    W = 40; fps = 15
    probs = [{'nose': 0.12, 'tail': 0.18, 'follow': 0.12, 'explore': 1.0},
             {'nose': 0.1, 'tail': 0.15, 'follow': 0.14, 'explore': 1.0}]
    (A, B), _ = two_mice(300, fps, W, W, seed=71, probs=probs)
    anx, any_ = A.nose; bnx, bny = B.nose; atx, aty = A.tail; btx, bty = B.tail
    nn = min_duration(np.hypot(anx - bnx, any_ - bny) < 2.5, 2)
    ab = min_duration(np.hypot(anx - btx, any_ - bty) < 2.5, 2)
    ba = min_duration(np.hypot(bnx - atx, bny - aty) < 2.5, 2)
    fab = following(A, B, fps); fba = following(B, A, fps)
    dist = np.hypot(A.x - B.x, A.y - B.y)
    s = lambda m: m.sum() / fps
    fig, a, b = figure(ratios=(0.9, 1.35))
    arena_axes(a, (0, W), (0, W), T(lang, 'Two mice, 5 min (A blue, B red)', '两只小鼠，5 分钟（A 蓝，B 红）'))
    rect(a, 0, 0, W, W)
    sl = slice(int(200 * fps), int(260 * fps))
    a.plot(A.x[sl], A.y[sl], color=BLUE, lw=0.8, alpha=0.9)
    a.plot(B.x[sl], B.y[sl], color=RED, lw=0.8, alpha=0.9)
    j = sl.stop - 1
    for M, col in ((A, BLUE), (B, RED)):
        (nx, ny), (tx, ty) = (M.nose[0][j], M.nose[1][j]), (M.tail[0][j], M.tail[1][j])
        a.plot([tx, M.x[j], nx], [ty, M.y[j], ny], '-', color=col, lw=2.2, solid_capstyle='round', zorder=6)
        a.plot(nx, ny, 'o', ms=4, color=col, mec=SURF, mew=0.8, zorder=7)
    label(a, W / 2, W + 3.2, T(lang, 'track: one minute (200–260 s) · bars: nose → tail base', '轨迹：其中一分钟（200–260 s）· 线段：鼻尖 → 尾根'), size=6.8, color=MUTED)
    rows = [(T(lang, f'Nose–nose · {s(nn):.0f} s', f'鼻–鼻 · {s(nn):.0f} s'), nn, VIOLET),
            (T(lang, f'A sniffs B (anogenital) · {s(ab):.0f} s', f'A 嗅 B 肛周 · {s(ab):.0f} s'), ab, BLUE),
            (T(lang, f'B sniffs A (anogenital) · {s(ba):.0f} s', f'B 嗅 A 肛周 · {s(ba):.0f} s'), ba, RED),
            (T(lang, f'A follows B · {s(fab):.0f} s', f'A 跟随 B · {s(fab):.0f} s'), fab, BLUE),
            (T(lang, f'B follows A · {s(fba):.0f} s', f'B 跟随 A · {s(fba):.0f} s'), fba, RED)]
    ethogram(b, A.t, rows, 300)
    b.set_xlabel(T(lang, 'Time (s)', '时间（s）'))
    b.set_title(T(lang, f'Social contacts over 5 min · mean distance {np.nanmean(dist):.0f} cm',
                  f'5 分钟内的社交接触 · 平均间距 {np.nanmean(dist):.0f} cm'))
    finish(fig, out, NOTE[lang])
    return dict(nose_nose_s=round(s(nn), 1), ag_ab_s=round(s(ab), 1), ag_ba_s=round(s(ba), 1),
                follow_ab_s=round(s(fab), 1), follow_ba_s=round(s(fba), 1), mean_dist=round(float(np.nanmean(dist)), 1),
                within10_pct=round(float(np.nanmean(dist < 10) * 100), 1))


def resident_intruder(lang, out):
    W, H, fps, t_in = 30, 18, 25, 60.0
    probs = [{'tail': 0.5, 'follow': 0.25, 'attack': 0.32, 'explore': 0.45}, {'tail': 0.15, 'explore': 1.0}]
    (R, I), modes = two_mice(300, fps, W, H, seed=81, probs=probs, enter_at=t_in, speed=(5, 12))
    rx, ry = R.nose; itx, ity = I.tail
    present = ~np.isnan(I.x)
    d = np.hypot(R.x - I.x, R.y - I.y)
    hr = np.abs(np.gradient(np.unwrap(np.nan_to_num(R.h)))) * fps
    k = int(0.3 * fps)
    fast = np.convolve(((R.speed > 18) & (np.nan_to_num(I.speed) > 18)).astype(float), np.ones(k) / k, 'same') > 0.5
    turn = np.convolve(hr, np.ones(k) / k, 'same') > np.radians(250)
    attack = min_duration(present & (d < 8) & fast & turn, int(0.2 * fps))
    sniff = min_duration(present & (np.hypot(rx - itx, ry - ity) < 2.5), int(0.2 * fps))
    chase = following(R, I, fps) & ~attack
    att_runs = runs(attack)
    lat = (R.t[att_runs[0][0]] - t_in) if att_runs else None
    s = lambda m: m.sum() / fps
    fig, a, b = figure(ratios=(0.9, 1.3))
    arena_axes(a, (0, W), (0, H), T(lang, 'Resident–intruder, home cage 30 × 18 cm', '居住者–入侵者，饲养笼 30 × 18 cm'), pad=1.5)
    rect(a, 0, 0, W, H)
    sl = slice(int((t_in + 40) * fps), int((t_in + 100) * fps))
    a.plot(R.x[sl], R.y[sl], color=BLUE, lw=0.6, alpha=0.85)
    a.plot(I.x[sl], I.y[sl], color=RED, lw=0.6, alpha=0.85)
    label(a, W / 2, H + 2.6, T(lang, 'one minute of tracks · resident blue, intruder red', '其中一分钟的轨迹 · 居住者蓝，入侵者红'), size=6.8, color=MUTED)
    rows = [(T(lang, f'Anogenital sniff · {s(sniff):.0f} s', f'肛周嗅探 · {s(sniff):.0f} s'), sniff, AQUA),
            (T(lang, f'Following / chasing · {s(chase):.0f} s', f'跟随 / 追逐 · {s(chase):.0f} s'), chase, VIOLET),
            (T(lang, f'Attack · {len(att_runs)} bouts, {s(attack):.1f} s', f'攻击 · {len(att_runs)} 次，{s(attack):.1f} s'), attack, RED)]
    ethogram(b, R.t, rows, 300)
    b.axvspan(0, t_in, color=SURF, zorder=1.5, lw=0)
    b.text(t_in / 2, 1.0, T(lang, 'resident\nalone', '仅居住者'), ha='center', va='center', fontsize=7, color=MUTED, zorder=4)
    b.axvline(t_in, color=INK2, lw=1, zorder=4)
    if lat is not None:
        b.plot(t_in + lat, -0.36, '^', ms=6, color=RED, mec=SURF, mew=0.8, zorder=5, clip_on=False)
        b.text(t_in + lat + 4, -0.36, T(lang, 'first attack', '首次攻击'), fontsize=7, color=INK, va='center')
    b.set_xlabel(T(lang, 'Time (s)', '时间（s）'))
    b.set_title(T(lang, f'Intruder in at {t_in:.0f} s · attack latency {lat:.0f} s',
                  f'{t_in:.0f} s 放入入侵者 · 攻击潜伏期 {lat:.0f} s'))
    finish(fig, out, NOTE[lang])
    return dict(attack_latency_s=round(lat, 1) if lat is not None else None, attack_bouts=len(att_runs),
                attack_s=round(s(attack), 1), chase_s=round(s(chase), 1), sniff_s=round(s(sniff), 1))


# ------------------------------------------------------------------ group behaviour
GROUP_COLS = ['#1E88E5', '#E53935', '#009E73', '#E69F00']   # the app's animal colours 1-4


def _seg_dist(p, a, b):
    """Distance from point p to segment ab (arrays of shape (2,))."""
    ab = b - a
    t = np.clip(np.dot(p - a, ab) / max(np.dot(ab, ab), 1e-9), 0, 1)
    return float(np.hypot(*(a + t * ab - p)))


def _body_dist(pa, pb):
    """The app's contact distance: points of one body polyline to the segments of the other, both ways."""
    d = math.inf
    for P, Q in ((pa, pb), (pb, pa)):
        for x in P:
            for k in range(len(Q) - 1):
                d = min(d, _seg_dist(x, Q[k], Q[k + 1]))
    return d


def _sustained(mask, gap, n_min):
    """Fill gaps of at most `gap` frames, then keep runs of at least n_min frames (Bouts.sustained)."""
    m = np.asarray(mask, bool).copy()
    rr = runs(m)
    for (a0, b0), (a1, b1) in zip(rr, rr[1:]):
        if a1 - b0 <= gap:
            m[b0:a1] = True
    return min_duration(m, n_min)


def davids_scores(w):
    """David's score with Dij (Gammell et al. 2003), as in the app's GroupHierarchy.swift."""
    n = len(w)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            t = w[i][j] + w[j][i]
            if i != j and t > 0:
                p = w[i][j] / t
                D[i][j] = p - (p - 0.5) / (t + 1)
    wn = D.sum(1); ln = D.sum(0)
    return np.array([wn[i] + sum(D[i][j] * wn[j] for j in range(n) if j != i)
                     - ln[i] - sum(D[j][i] * ln[j] for j in range(n) if j != i) for i in range(n)])


def four_mice(T_s, fps, W, seed, dominance):
    """Four simulated mice: exploring, resting together in a huddle, and approach–avoid interactions in which
    the higher-ranked mouse usually makes the other move away."""
    rng = np.random.default_rng(seed)
    n = int(T_s * fps); dt = 1 / fps; m = len(dominance)
    inside = lambda x, y: 1.0 < x < W - 1.0 and 1.0 < y < W - 1.0
    nest = (9.0, W - 9.0)
    rest = [(95, 175), (330, 420), (520, 575)]          # stretches when the group settles into a huddle
    A = [Agent(rng, rng.uniform(8, W - 8), rng.uniform(8, W - 8)) for _ in range(m)]
    for k, a in enumerate(A):
        a.slot = (nest[0] + 3.2 * math.cos(k * 1.7), nest[1] + 3.2 * math.sin(k * 1.7))
        a.target = None; a.v = rng.uniform(3, 9); a.goal = (rng.uniform(4, W - 4), rng.uniform(4, W - 4))
    out = np.zeros((m, 3, n))
    for i in range(n):
        t = i * dt
        resting = any(a0 <= t < b0 for a0, b0 in rest)
        for k, me in enumerate(A):
            me.timer -= dt
            if me.mode in ('approach', 'flee', 'follow') and me.timer <= 0:
                me.mode, me.timer, me.target = 'explore', rng.uniform(2, 6), None
            if me.mode == 'explore' and resting and rng.random() < 0.6 * dt:
                me.mode, me.timer = 'nest', rng.uniform(25, 80)
            if me.mode == 'nest' and (not resting and me.timer <= 0):
                me.mode, me.timer = 'explore', rng.uniform(2, 6)
            if me.mode == 'explore' and rng.random() < 0.06 * dt:
                near = [j for j in range(m) if j != k and A[j].mode in ('explore', 'nest')
                        and math.hypot(A[j].x - me.x, A[j].y - me.y) < 22]
                if near:
                    j = min(near, key=lambda j: math.hypot(A[j].x - me.x, A[j].y - me.y))
                    yields = rng.random() < (0.88 if dominance[k] > dominance[j] else 0.12)
                    fast = rng.random() < 0.25
                    me.mode, me.target, me.timer = 'approach', j, rng.uniform(4, 6)
                    me.yields, me.fast = yields, fast
            if me.mode == 'approach':
                o = A[me.target]
                d = math.hypot(o.x - me.x, o.y - me.y)
                want = math.atan2(o.y - me.y, o.x - me.x)
                v = (rng.uniform(22, 28) if me.fast else rng.uniform(11, 15))
                if d < 9:
                    if me.yields:          # the other moves away; the approacher keeps after it for a moment
                        o.mode, o.timer, o.target = 'flee', rng.uniform(0.9, 1.6), k
                        o.fast = me.fast
                        me.mode, me.timer = 'follow', o.timer
                    else:                  # the other holds its ground; the approacher turns away
                        me.mode, me.timer, me.target = 'explore', rng.uniform(2, 5), None
                        me.goal = (rng.uniform(4, W - 4), rng.uniform(4, W - 4))
            elif me.mode == 'follow':
                o = A[me.target]
                want = math.atan2(o.y - me.y, o.x - me.x)
                v = (rng.uniform(22, 28) if me.fast else rng.uniform(10, 14))
            elif me.mode == 'flee':
                o = A[me.target]
                want = math.atan2(me.y - o.y, me.x - o.x) + rng.normal(0, 0.1)
                v = (rng.uniform(22, 28) if me.fast else rng.uniform(11, 15))
            elif me.mode == 'nest':
                tx, ty = me.slot
                d = math.hypot(tx - me.x, ty - me.y)
                want = math.atan2(ty - me.y, tx - me.x) if d > 0.6 else me.h + rng.normal(0, 0.08)
                v = min(9, d * 2.5) if d > 0.6 else 0.0
            else:                          # explore
                tx, ty = me.goal
                if math.hypot(tx - me.x, ty - me.y) < 2:
                    me.goal = (rng.uniform(4, W - 4), rng.uniform(4, W - 4))
                    me.paused = rng.random() < 0.5
                if me.paused and rng.random() < 0.04:
                    me.paused = False
                want = math.atan2(ty - me.y, tx - me.x)
                v = 0.2 if me.paused else me.v
                if rng.random() < 0.01:
                    me.v = rng.uniform(3, 9)
            diff = (want - me.h + math.pi) % (2 * math.pi) - math.pi
            me.h += (0.55 if me.mode in ('approach', 'follow', 'flee') else 0.3) * diff + rng.normal(0, 0.04)
            step = v * dt
            nx, ny = me.x + step * math.cos(me.h), me.y + step * math.sin(me.h)
            tries = 0
            while not inside(nx, ny) and tries < 10:
                me.h += rng.uniform(0.6, 1.4) * rng.choice([-1, 1])
                nx, ny = me.x + step * math.cos(me.h), me.y + step * math.sin(me.h)
                tries += 1
            if inside(nx, ny):
                me.x, me.y = nx, ny
            out[k, :, i] = me.x, me.y, me.h
    tt = np.arange(n) * dt
    return [Mouse(tt, out[k, 0], out[k, 1], np.unwrap(out[k, 2])) for k in range(m)]


def group_measures(M, fps, L):
    """Simplified versions of the app's group rules (AnalyzersGroup.swift), in body lengths L."""
    m, n = len(M), len(M[0].x)
    C = np.stack([np.stack([q.x, q.y], 1) for q in M])                       # m × n × 2
    poly = [np.stack([np.stack(q.nose, 1), C[k], np.stack(q.tail, 1)], 1) for k, q in enumerate(M)]   # n × 3 × 2
    k2 = max(1, round(0.2 * fps))
    V = np.zeros_like(C)
    V[:, k2:-k2] = (C[:, 2 * k2:] - C[:, :-2 * k2]) / (2 * k2 / fps)
    spd = np.hypot(V[..., 0], V[..., 1]) / L
    contact_an = np.zeros((m, n), bool); largest = np.zeros(n); together = np.zeros(n, bool); nnd = np.zeros(n)
    for i in range(n):
        par = list(range(m))

        def root(x):
            while par[x] != x:
                x = par[x]
            return x
        near = np.full(m, np.inf)
        for a in range(m):
            for b in range(a + 1, m):
                d = float(np.hypot(*(C[a, i] - C[b, i])))
                near[a] = min(near[a], d); near[b] = min(near[b], d)
                if d < 2 * L and _body_dist(poly[a][i], poly[b][i]) < 0.35 * L:
                    contact_an[a, i] = contact_an[b, i] = True
                    par[root(a)] = root(b)
        sizes = {}
        for a in range(m):
            sizes[root(a)] = sizes.get(root(a), 0) + 1
        largest[i] = max(sizes.values()); together[i] = len(sizes) == 1; nnd[i] = near.mean()
    raw = {}; chase_raw = {}
    for i in range(k2, n - k2):
        for a in range(m):
            if spd[a, i] <= 0.6:
                continue
            best, bd = -1, np.inf
            for b in range(m):
                if b == a:
                    continue
                u = C[b, i] - C[a, i]; d = np.hypot(*u) / L
                cos = np.dot(V[a, i], u) / (np.hypot(*V[a, i]) * np.hypot(*u) + 1e-9)
                if 0.3 < d < 2.5 and cos > 0.8 and d < bd:
                    best, bd = b, d
            if best < 0 or spd[best, i] <= 0.6:
                continue
            u = C[best, i] - C[a, i]
            if np.dot(V[best, i], u) / (np.hypot(*V[best, i]) * np.hypot(*u) + 1e-9) <= 0.5:
                continue
            raw.setdefault((a, best), np.zeros(n, bool))[i] = True
            if spd[a, i] > 2.7 and spd[best, i] > 0.75 * 2.7:
                chase_raw.setdefault((a, best), np.zeros(n, bool))[i] = True
    events = []
    gap = int(0.25 * fps)
    for (a, b), mask in raw.items():
        ch = _sustained(chase_raw[(a, b)], gap, max(1, round(0.3 * fps))) if (a, b) in chase_raw else np.zeros(n, bool)
        for s0, e0 in runs(_sustained(mask, gap, max(1, round(0.4 * fps)))):
            events.append((s0 / fps, a, b, bool(ch[s0:e0].any())))
    events.sort()
    w = np.zeros((m, m), int)
    for _, a, b, _c in events:
        w[a, b] += 1
    ds = davids_scores(w)
    nds = (ds + m * (m - 1) / 2) / m
    return dict(contact=contact_an.mean(), nnd=nnd.mean(), largest=largest, together=together, events=events, wins=w, nds=nds)


def group_behaviour(lang, out):
    W, fps, T_s = 40, 10, 600
    dominance = [2, 3, 0, 1]              # ID 2 is top, ID 3 bottom: IDs are arbitrary, as in the app
    M = four_mice(T_s, fps, W, seed=17, dominance=dominance)
    L = M[0].L
    r = group_measures(M, fps, L)
    m = len(M)
    sizes = [float((r['largest'] == s).mean() * 100) for s in range(1, m + 1)]
    order = list(np.argsort(-r['nds']))
    n_ev = len(r['events']); n_ch = sum(1 for e in r['events'] if e[3])
    fig = plt.figure(figsize=(8.4, 3.5))
    gs = fig.add_gridspec(1, 3, width_ratios=(0.95, 0.72, 0.9), left=0.03, right=0.985, top=0.86, bottom=0.17, wspace=0.32)
    a, b, c = (fig.add_subplot(gs[k]) for k in range(3))
    arena_axes(a, (0, W), (0, W), T(lang, 'Four mice, 10 min', '四只小鼠，10 分钟'))
    rect(a, 0, 0, W, W)
    sl = slice(int(240 * fps), int(270 * fps))
    j = sl.stop - 1
    for k, q in enumerate(M):
        a.plot(q.x[sl], q.y[sl], color=GROUP_COLS[k], lw=0.8, alpha=0.85, zorder=3)
    for k, q in enumerate(M):
        (nx, ny), (tx, ty) = (q.nose[0][j], q.nose[1][j]), (q.tail[0][j], q.tail[1][j])
        a.plot([tx, q.x[j], nx], [ty, q.y[j], ny], '-', color=GROUP_COLS[k], lw=2.4, solid_capstyle='round', zorder=6)
        a.plot(nx, ny, 'o', ms=4, color=GROUP_COLS[k], mec=SURF, mew=0.8, zorder=7)
        label(a, tx - 2.2 * math.cos(q.h[j]), ty - 2.2 * math.sin(q.h[j]), str(k + 1), color=GROUP_COLS[k], size=7.5, weight='bold', box=True, z=8)
    label(a, W / 2, W + 3.2, T(lang, '30 s of tracks (240–270 s) · colour = ID', '其中 30 秒的轨迹（240–270 s）· 颜色 = 编号'), size=6.8, color=MUTED)
    bars(b, [str(s) for s in range(1, m + 1)], sizes, ['#c9c8c2'] * (m - 1) + [VIOLET], unit=' %', ylim=(0, max(sizes) * 1.25))
    b.set_xlabel(T(lang, 'Mice in the largest group', '最大聚集团的只数'))
    b.set_title(T(lang, 'Largest group, % of time', '最大聚集团，时间比例'))
    ys = np.arange(m)[::-1]
    for y, k in zip(ys, order):
        c.barh(y, r['nds'][k], height=0.58, color=GROUP_COLS[k], edgecolor=SURF, lw=1.5, zorder=3)
        c.text(r['nds'][k] + 0.05, y, f"{r['nds'][k]:.2f}  ·  {int(r['wins'][k].sum())}–{int(r['wins'][:, k].sum())}",
               va='center', fontsize=7.3, color=INK, zorder=4)
    c.set_yticks(ys, [T(lang, f'#{rk + 1}  ID {k + 1}', f'第 {rk + 1}  编号 {k + 1}') for rk, k in enumerate(order)])
    c.tick_params(axis='y', length=0)
    c.set_xlim(0, m - 1 + 0.9)
    c.set_xticks(range(m))
    c.grid(axis='x', color=GRID, lw=0.6, zorder=0); c.set_axisbelow(True)
    c.set_xlabel(T(lang, "Normalised David's score  ·  wins–losses", "标准化 David's score  ·  胜–负"))
    c.set_title(T(lang, f'Rank from {n_ev} approach–avoid events', f'由 {n_ev} 次接近–回避事件排出的等级'))
    finish(fig, out, NOTE[lang])
    return dict(contact_pct=round(r['contact'] * 100, 1), nnd_cm=round(float(r['nnd']), 1),
                together_pct=round(sizes[-1], 1), no_contact_pct=round(sizes[0], 1), events=n_ev, chases=n_ch,
                per_mouse=round(n_ev / m, 1), top_id=int(order[0] + 1), bottom_id=int(order[-1] + 1),
                nds_top=round(float(r['nds'][order[0]]), 2), nds_bottom=round(float(r['nds'][order[-1]]), 2))


# ------------------------------------------------------------------ head direction
def head_direction(lang, out):
    W = 50
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < W - 0.8
    m = simulate(600, FPS, (25, 25), inside, None, seed=91, goal_sampler=lambda r: (r.uniform(4, W - 4), r.uniform(4, W - 4)),
                 dwell=(0.5, 2.5))
    heading_from_motion(m, min_speed=3)
    rng = np.random.default_rng(92)
    off = np.zeros(len(m.x)); o = 0.0
    for i in range(len(off)):
        o += -0.08 * o + rng.normal(0, 0.09)
        off[i] = o
    hd = m.h + np.clip(off, -0.8, 0.8)
    # screen convention: 0° = image right, counter-clockwise positive (image y points down)
    ang = np.degrees(np.arctan2(-np.sin(hd), np.cos(hd))) % 360
    bins = np.arange(0, 361, 6)
    occ, _ = np.histogram(ang, bins) ; occ = occ / FPS
    cover = (occ >= 1).mean() * 100
    z = np.exp(1j * np.radians(ang)).mean()
    mvl = abs(z)
    ahv = np.degrees(np.abs(np.diff(np.unwrap(np.radians(ang))))) * FPS
    fig = plt.figure(figsize=(8.4, 3.5))
    gs = fig.add_gridspec(1, 2, width_ratios=(1, 1.05), left=0.03, right=0.97, top=0.80, bottom=0.10, wspace=0.25)
    a = fig.add_subplot(gs[0]); b = fig.add_subplot(gs[1], projection='polar')
    arena_axes(a, (0, W), (0, W))
    fig.text(0.03, 0.93, T(lang, 'Head direction, 10 min', '头朝向，10 分钟'), fontsize=9.5, fontweight='semibold', color=INK)
    rect(a, 0, 0, W, W)
    a.plot([18, 32], [0.4, 0.4], color=INK, lw=4, solid_capstyle='butt')
    label(a, 25, 3, T(lang, 'cue card', '提示卡'), size=7)
    a.plot(m.x, m.y, color=BLUE, lw=0.4, alpha=0.45)
    idx = np.arange(0, len(m.x), int(10 * FPS))
    a.quiver(m.x[idx], m.y[idx], np.cos(hd[idx]), np.sin(hd[idx]), color=ORANGE, scale=26, width=0.006,
             headwidth=4, headlength=4, zorder=5, angles='xy')
    label(a, W / 2, W + 3, T(lang, 'arrows: head direction every 10 s', '箭头：每 10 秒的头朝向'), size=6.8, color=MUTED)
    th = np.radians(bins[:-1] + 3)
    b.bar(th, occ, width=np.radians(6) * 0.92, color=BLUE, edgecolor=SURF, linewidth=0.6)
    b.set_theta_zero_location('E'); b.set_theta_direction(1)
    b.set_xticks(np.radians([0, 90, 180, 270]), ['0°', '90°', '180°', '270°'])
    b.tick_params(labelsize=7, colors=INK2)
    b.set_rlabel_position(112)
    b.set_rticks([5, 10])
    b.grid(color=GRID, lw=0.6)
    b.spines['polar'].set_color(GRID)
    fig.text(0.47, 0.93, T(lang, f'Seconds per 6° bin · coverage {cover:.0f} % · mean vector length {mvl:.2f}',
                           f'每 6° 区间的秒数 · 覆盖 {cover:.0f} % · 平均向量长度 {mvl:.2f}'),
             fontsize=9.5, fontweight='semibold', color=INK, ha='left')
    finish(fig, out, NOTE[lang])
    return dict(coverage_pct=round(cover, 1), mvl=round(float(mvl), 3), median_ahv=round(float(np.median(ahv)), 1))


# ------------------------------------------------------------------ spatial exploration
def spatial(lang, out):
    W, binw = 50, 2.5
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < W - 0.8
    m = simulate(1200, FPS, (25, 25), inside, None, seed=95, goal_sampler=lambda r: (r.uniform(3, W - 3), r.uniform(3, W - 3)),
                 dwell=(0.5, 3.0), speed=(6, 14))
    nb = int(W / binw)
    H2, _, _ = np.histogram2d(m.y, m.x, bins=nb, range=[[0, W], [0, W]])
    occ = H2 / FPS
    cov_t = []
    for mi in range(1, 21):
        k = mi * 60 * FPS
        h, _, _ = np.histogram2d(m.y[:k], m.x[:k], bins=nb, range=[[0, W], [0, W]])
        cov_t.append(((h / FPS) >= 0.2).mean() * 100)
    moving = (m.speed > 2).mean() * 100
    dist = np.hypot(np.diff(m.x), np.diff(m.y)).sum() / 100
    fig, a, b = figure(ratios=(1, 1.1))
    fig.subplots_adjust(wspace=0.3)
    im = a.imshow(occ, cmap='Blues', extent=(0, W, W, 0), vmin=0, vmax=np.percentile(occ, 99), interpolation='nearest')
    arena_axes(a, (0, W), (0, W), T(lang, 'Occupancy, 2.5 cm bins, 20 min', '停留时间分布，2.5 cm 网格，20 分钟'))
    rect(a, 0, 0, W, W)
    cb = fig.colorbar(im, ax=a, fraction=0.04, pad=0.02)
    cb.outline.set_visible(False); cb.ax.tick_params(labelsize=6.5, colors=INK2, length=0)
    label(a, W / 2, W + 3, T(lang, 'darker = more seconds in that bin', '颜色越深 = 该格停留越久'), size=6.8, color=MUTED)
    xs = np.arange(1, 21)
    b.plot(xs, cov_t, '-', color=BLUE, lw=2)
    b.plot(xs[[0, 4, 9, 19]], np.array(cov_t)[[0, 4, 9, 19]], 'o', color=BLUE, ms=5, mec=SURF, mew=1)
    for k in (0, 4, 9, 19):
        b.text(xs[k], cov_t[k] + 4, f'{cov_t[k]:.0f} %', ha='center', fontsize=7.5, color=INK)
    b.set_ylim(0, 105); b.set_xlim(0.5, 20.5); b.set_xticks([1, 5, 10, 15, 20])
    b.grid(axis='y', color=GRID, lw=0.6)
    b.set_xlabel(T(lang, 'Minute', '分钟')); b.set_ylabel(T(lang, 'Bins visited ≥ 0.2 s (%)', '停留 ≥ 0.2 s 的网格（%）'))
    b.set_title(T(lang, f'Coverage over time · moving {moving:.0f} % of the time · {dist:.0f} m',
                  f'覆盖率随时间 · 运动时间 {moving:.0f} % · 路程 {dist:.0f} m'))
    finish(fig, out, NOTE[lang])
    return dict(coverage_pct=round(cov_t[-1], 1), coverage_5min=round(cov_t[4], 1), moving_pct=round(moving, 1),
                distance_m=round(dist, 1))


# ------------------------------------------------------------------ novel object recognition
def nor(lang, out):
    W, ro = 40, 2.5
    objs = {'F': (13, 13), 'N': (27, 27)}

    def inside(x, y):
        if not (0.8 < x < W - 0.8 and 0.8 < y < W - 0.8):
            return False
        return all(math.hypot(x - cx, y - cy) > ro + 1.0 for cx, cy in objs.values())

    fam = around(*objs['F'], ro + 3.6, [0, 60, 120, 180, 240, 300])
    nov = around(*objs['N'], ro + 3.6, [0, 60, 120, 180, 240, 300])
    other = [(5, 35), (35, 5), (5, 5), (35, 35), (20, 20), (20, 5), (5, 20), (35, 20), (20, 35)]
    m = simulate(600, FPS, (20, 38), inside, fam + nov + other, [0.22] * 6 + [0.4] * 6 + [1.0] * 9, seed=101,
                 dwell=(0.6, 2.2))
    nx, ny = m.nose
    inv = {k: ((np.hypot(nx - cx, ny - cy) - ro) < 2) & facing(m, cx, cy) for k, (cx, cy) in objs.items()}
    cf, cn = np.cumsum(inv['F']) / FPS, np.cumsum(inv['N']) / FPS
    tot = cf + cn
    i20 = int(np.argmax(tot >= 20)) if (tot >= 20).any() else len(tot) - 1
    di20 = (cn[i20] - cf[i20]) / (cn[i20] + cf[i20])
    di = (cn[-1] - cf[-1]) / (cn[-1] + cf[-1])
    fig, a, b = figure()
    arena_axes(a, (0, W), (0, W), T(lang, 'Novel object recognition, test, 10 min', '新物体识别，测试阶段，10 分钟'))
    rect(a, 0, 0, W, W)
    for k, (cx, cy) in objs.items():
        circ(a, cx, cy, ro + 2, fc=ZONE_O if k == 'N' else ZONE_B, ec='none', z=0)
        circ(a, cx, cy, ro, fc='#d9d8d2', ec=INK2, z=2)
    label(a, 13, 7.0, T(lang, 'familiar', '熟悉物体'), color=BLUE, box=True)
    label(a, 27, 33.8, T(lang, 'novel', '新物体'), color=ORANGE, box=True)
    track(a, m, lw=0.5, alpha=0.7)
    b.plot(m.t, cn, color=ORANGE, lw=2, label=T(lang, 'Novel', '新物体'))
    b.plot(m.t, cf, color=BLUE, lw=2, label=T(lang, 'Familiar', '熟悉物体'))
    b.axvline(m.t[i20], color=INK2, lw=1, ls='--')
    b.text(m.t[i20] + 8, max(cn[-1], cf[-1]) * 0.62, T(lang, f'20 s total reached\nat {m.t[i20]:.0f} s: DI {di20:.2f}',
                                                     f'{m.t[i20]:.0f} s 时累计 20 s\nDI {di20:.2f}'), fontsize=7.2, color=INK, va='top')
    b.text(m.t[-1], cn[-1] + 0.6, f'{cn[-1]:.0f} s', ha='right', va='bottom', fontsize=7.5, color=INK)
    b.text(m.t[-1], cf[-1] + 0.6, f'{cf[-1]:.0f} s', ha='right', va='bottom', fontsize=7.5, color=INK)
    b.set_xlim(0, 600); b.set_ylim(0, None)
    b.grid(axis='y', color=GRID, lw=0.6)
    b.legend(loc='upper left', bbox_to_anchor=(0.0, 1.0))
    b.set_xlabel(T(lang, 'Time (s)', '时间（s）')); b.set_ylabel(T(lang, 'Cumulative investigation (s)', '累计探索时间（s）'))
    b.set_title(T(lang, f'Discrimination index {di:.2f} over 10 min', f'10 分钟辨别指数 {di:.2f}'))
    finish(fig, out, NOTE[lang])
    return dict(novel_s=round(float(cn[-1]), 1), familiar_s=round(float(cf[-1]), 1), di=round(float(di), 2),
                t20_s=round(float(m.t[i20])), di20=round(float(di20), 2), ri=round(float(100 * cn[-1] / tot[-1]), 1))


# ------------------------------------------------------------------ Barnes maze
def barnes(lang, out):
    R, Rh, rh, nH = 46, 40, 2.5, 20
    ang = np.radians(np.arange(nH) * 360 / nH - 90)
    holes = np.c_[Rh * np.cos(ang), Rh * np.sin(ang)]
    tgt = 3
    inside = lambda x, y: math.hypot(x, y) < R - 0.8
    rng = np.random.default_rng(111)
    lam = {1: 8, 2: 5, 3: 3, 4: 1.6}
    res = {d: [] for d in lam}
    keep = {}
    for d in (1, 2, 3, 4):
        for tr in range(3):
            k = int(rng.poisson(lam[d]))
            wps = [(rng.normal(0, 1.5), rng.normal(0, 1.5), rng.uniform(3, 8))]   # start box lifted
            cur = rng.integers(nH)
            for e in range(k):
                if d >= 3:
                    cur = (tgt + rng.choice([-2, -1, 1, 2])) % nH
                else:
                    cur = (cur + rng.choice([-2, -1, 1, 1, 2, 5, 9])) % nH
                    if cur == tgt:
                        cur = (cur + 2) % nH
                hx, hy = holes[cur]
                if d <= 2 and rng.random() < 0.6:
                    wps.append((rng.uniform(-25, 25), rng.uniform(-25, 25), rng.uniform(0, 3)))
                u = np.array([hx, hy]) / Rh
                wps.append((hx - u[0] * 5.2, hy - u[1] * 5.2, rng.uniform(0.6, 1.5), hx, hy))
            hx, hy = holes[tgt]; u = np.array([hx, hy]) / Rh
            wps.append((hx - u[0] * 5.2, hy - u[1] * 5.2, 1.0, hx, hy))
            m = walk_seq(FPS, (0, 0), wps, inside, seed=int(rng.integers(1e6)), speed=(4, 9) if d == 1 else (6, 12))
            nx, ny = m.nose
            dh = np.hypot(nx[:, None] - holes[:, 0], ny[:, None] - holes[:, 1])
            inhole = dh < rh
            first = np.argmax(inhole[:, tgt]) if inhole[:, tgt].any() else len(m.x) - 1
            errs = 0
            for h in range(nH):
                if h == tgt:
                    continue
                errs += sum(1 for a_, b_ in runs(inhole[:first, h]))
            res[d].append((m.t[first], errs))
            if tr == 0 and d in (1, 4):
                keep[d] = (m, first)
    fig = plt.figure(figsize=(8.4, 3.5))
    gs = fig.add_gridspec(1, 3, width_ratios=(1.15, 0.8, 0.8), left=0.03, right=0.985, top=0.86, bottom=0.17, wspace=0.42)
    a = fig.add_subplot(gs[0]); b1 = fig.add_subplot(gs[1]); b2 = fig.add_subplot(gs[2])
    arena_axes(a, (-R, R), (-R, R), T(lang, 'Barnes maze, 20 holes', 'Barnes 迷宫，20 个洞'))
    circ(a, 0, 0, R, fc='#f4f3ef')
    for h, (hx, hy) in enumerate(holes):
        circ(a, hx, hy, rh, fc=AQUA if h == tgt else '#dddcd6', ec='none', z=2)
    for d, col in ((1, MUTED), (4, BLUE)):
        m, first = keep[d]
        a.plot(m.x[:first + 1], m.y[:first + 1], color=col, lw=0.9 if d == 4 else 0.6, alpha=0.9, zorder=3)
    hx, hy = holes[tgt]
    label(a, hx * 0.72, hy * 0.72, T(lang, 'escape\nhole', '逃生洞'), color=AQUA, size=7, box=True)
    label(a, 0, R + 4, T(lang, 'grey: day 1, trial 1 · blue: day 4, trial 1', '灰：第 1 天第 1 次 · 蓝：第 4 天第 1 次'), size=6.8, color=MUTED)
    days = np.arange(1, 5)
    for ax, j, ttl, yl in ((b1, 0, T(lang, 'Latency', '潜伏期'), T(lang, 'Seconds', '秒')),
                           (b2, 1, T(lang, 'Errors', '错误次数'), T(lang, 'Holes probed', '探错的洞'))):
        for d in days:
            vals = [r[j] for r in res[d]]
            ax.plot([d] * 3 + rng.normal(0, 0.06, 3), vals, 'o', ms=3.5, color=BLUE, alpha=0.35, mec='none')
        mean = [np.mean([r[j] for r in res[d]]) for d in days]
        ax.plot(days, mean, '-o', color=BLUE, lw=2, ms=5, mec=SURF, mew=1)
        ax.set_xticks(days); ax.set_xlabel(T(lang, 'Day', '天')); ax.set_ylabel(yl)
        ax.set_ylim(0, None); ax.grid(axis='y', color=GRID, lw=0.6)
        ax.set_title(ttl)
    finish(fig, out, NOTE[lang] + T(lang, '  3 trials per day; line = daily mean.', '  每天 3 次；折线为每日均值。'))
    return {f'day{d}_latency': round(float(np.mean([r[0] for r in res[d]])), 1) for d in days} | \
           {f'day{d}_errors': round(float(np.mean([r[1] for r in res[d]])), 1) for d in days}


# ------------------------------------------------------------------ water maze (probe)
def water_maze(lang, out):
    R = 60; px_, py_ = 21, -21; rp = 5
    inside = lambda x, y: math.hypot(x, y) < R - 1.5
    goals = [(px_ + dx, py_ + dy) for dx, dy in ((0, 0), (8, 6), (-7, 8), (7, -8), (-8, -6))] + \
            [(r * math.cos(a), r * math.sin(a)) for r in (25, 45) for a in np.radians(np.arange(0, 360, 45))]
    m = simulate(60, FPS, (0, 57), inside, goals, [0.55] * 5 + [0.22] * 16, seed=128, speed=(18, 24), pause=(0.0, 1.0),
                 dwell=(0.0, 0.01), turn_noise=0.25)
    th = np.degrees(np.arctan2(-m.y, m.x)) % 360     # screen angle, counter-clockwise
    tq = 45.0                                        # target quadrant centred on 45° (upper right)
    rel = (th - tq + 180) % 360 - 180
    q = np.where(np.abs(rel) <= 45, 0, np.where((rel > 45) & (rel <= 135), 1, np.where(np.abs(rel) > 135, 2, 3)))
    pct = [(q == k).mean() * 100 for k in range(4)]
    zone = np.hypot(m.x - px_, m.y - py_) < rp + 2
    cross = len(runs(zone))
    prox = np.hypot(m.x - px_, m.y - py_).mean()
    fig, a, b = figure()
    arena_axes(a, (-R, R), (-R, R), T(lang, 'Water maze, probe trial, 60 s', '水迷宫，探查测试，60 秒'))
    circ(a, 0, 0, R, fc='#eef3f8')
    a.add_patch(mp.Wedge((0, 0), R, -90, 0, fc=ZONE_O, ec='none', zorder=0.5))
    a.plot([-R, R], [0, 0], color=GRID, lw=0.8, zorder=1); a.plot([0, 0], [-R, R], color=GRID, lw=0.8, zorder=1)
    circ(a, px_, py_, rp + 2, fc='none', ec=ORANGE, lw=1, ls='--', z=2)
    label(a, px_ + 15, py_ - 17, T(lang, 'former\nplatform', '原平台\n位置'), color=ORANGE, size=7, box=True)
    track(a, m, lw=0.7)
    names = [T(lang, 'Target', '目标'), T(lang, 'Adjacent', '相邻'), T(lang, 'Opposite', '对侧'), T(lang, 'Adjacent', '相邻')]
    bars(b, names, pct, [ORANGE, MUTED, MUTED, MUTED], unit=' %', ylim=(0, 100), ylabel=T(lang, 'Time in quadrant (%)', '象限时间（%）'))
    b.axhline(25, color=INK2, lw=0.9, ls='--'); b.text(2.5, 26.5, T(lang, 'chance 25 %', '随机 25 %'), ha='center', fontsize=7, color=INK2)
    b.set_title(T(lang, f'Target quadrant {pct[0]:.0f} % · {cross} crossings · proximity {prox:.0f} cm',
                  f'目标象限 {pct[0]:.0f} % · 穿越 {cross} 次 · 平均距离 {prox:.0f} cm'))
    finish(fig, out, NOTE[lang])
    return dict(target_pct=round(pct[0], 1), opposite_pct=round(pct[2], 1), crossings=cross, proximity_cm=round(float(prox), 1),
                path_m=round(float(np.hypot(np.diff(m.x), np.diff(m.y)).sum() / 100), 1))


# ------------------------------------------------------------------ Y maze
def y_maze(lang, out):
    Larm, w = 35, 5
    U = {'A': np.array([0, -1.0]), 'B': np.array([-math.sin(math.radians(60)), 0.5]),
         'C': np.array([math.sin(math.radians(60)), 0.5])}
    rj = w / 2 / math.tan(math.radians(60)) + 0.2

    def which(x, y):
        best = None
        for k, u in U.items():
            p = x * u[0] + y * u[1]; q = -x * u[1] + y * u[0]
            if p > rj and abs(q) < w / 2 and p < Larm + rj:
                best = k
        return best

    inside = lambda x, y: which(x, y) is not None or math.hypot(x, y) < w / 2 / math.sin(math.radians(60)) + 0.3
    rng = np.random.default_rng(131)
    seq = ['A', 'B']
    while len(seq) < 30:
        cand = [k for k in 'ABC' if k != seq[-1]]
        alt = [k for k in cand if k != seq[-2]][0]
        seq.append(alt if rng.random() < 0.72 else [k for k in cand if k != alt][0])
    wps = []
    for k in seq:
        u = U[k]; d = rng.uniform(20, Larm)
        if rng.random() < 0.15:     # look into another arm without entering
            o = rng.choice([z for z in 'ABC' if z != k]); uo = U[o]
            wps.append((uo[0] * 1.0, uo[1] * 1.0, rng.uniform(0.6, 1.2), uo[0] * 10, uo[1] * 10))
        wps.append((u[0] * d, u[1] * d, rng.uniform(0.5, 3)))
        wps.append((0, 0, rng.uniform(0, 0.8)))
    m = walk_seq(FPS, (U['A'][0] * 30, U['A'][1] * 30), wps, inside, seed=132, speed=(8, 16), T_max=480)
    tx, ty = m.tail; nx, ny = m.nose
    zb = [which(x, y) for x, y in zip(m.x, m.y)]
    zt = [which(x, y) for x, y in zip(tx, ty)]
    zn = [which(x, y) for x, y in zip(nx, ny)]
    entries = []; cur = None
    for i in range(len(zb)):
        if zb[i] is not None and zb[i] == zt[i] and zb[i] != cur:
            cur = zb[i]; entries.append((cur, m.t[i]))
        elif zb[i] is None and zt[i] is None:
            cur = None
    peeks = 0
    for k in 'ABC':
        nose_only = np.array([zn[i] == k and zb[i] != k and zt[i] != k for i in range(len(zb))])
        for s0, s1 in runs(nose_only):
            if s1 - s0 >= 6 and (s1 >= len(zb) or zb[s1] != k):
                peeks += 1
    letters = [e[0] for e in entries]
    trip = [len(set(letters[i:i + 3])) == 3 for i in range(len(letters) - 2)]
    alt = 100 * sum(trip) / max(len(trip), 1)
    cols = {'A': BLUE, 'B': ORANGE, 'C': AQUA}
    fig, a, b = figure(ratios=(0.85, 1.3))
    arena_axes(a, (-32, 32), (-Larm - 1, 20), T(lang, 'Y maze, 8 min', 'Y 迷宫，8 分钟'), pad=3)
    for k, u in U.items():
        p0 = u * rj; p1 = u * (Larm + rj); nrm = np.array([-u[1], u[0]]) * w / 2
        poly = np.array([p0 + nrm, p1 + nrm, p1 - nrm, p0 - nrm])
        a.add_patch(mp.Polygon(poly, closed=True, fc=SURF, ec=ARENA_EDGE, lw=1, zorder=1))
        e = u * (Larm + rj + 3.5)
        label(a, e[0], e[1], k, color=cols[k], size=9, weight='bold')
    a.add_patch(mp.Circle((0, 0), 3.1, fc=SURF, ec='none', zorder=1.5))
    a.plot(m.x, m.y, color=INK2, lw=0.45, alpha=0.6, zorder=3)
    b.set_xlim(-0.5, 12.5); b.set_ylim(-0.4 - 1.25 * ((len(letters) - 1) // 12) - 0.6, 1.0); b.axis('off')
    for i, k in enumerate(letters):
        r_, c_ = divmod(i, 12)
        y0 = -1.25 * r_
        b.add_patch(mp.FancyBboxPatch((c_ + 0.08, y0), 0.84, 0.8, boxstyle='round,pad=0,rounding_size=0.12',
                                      fc=cols[k], ec='none'))
        b.text(c_ + 0.5, y0 + 0.4, k, ha='center', va='center', fontsize=8, color='white', fontweight='bold')
        if i >= 2:
            ok = trip[i - 2]
            b.text(c_ + 0.5, y0 - 0.2, '✓' if ok else '·', ha='center', va='center', fontsize=7.5,
                   color=INK if ok else MUTED)
    b.set_title(T(lang, f'{len(letters)} arm entries in order · alternation {alt:.0f} % ({sum(trip)} of {len(trip)} triplets)',
                  f'按顺序的 {len(letters)} 次进臂 · 自发交替 {alt:.0f} %（{len(trip)} 组中 {sum(trip)} 组）'))
    b.text(-0.4, b.get_ylim()[0] + 0.1, T(lang, '✓ = this entry completes three different arms in a row',
                                          '✓ = 这一次进臂与前两次组成三个不同的臂'), fontsize=7, color=INK2)
    finish(fig, out, NOTE[lang])
    return dict(entries=len(letters), alternation_pct=round(alt, 1), triplets=len(trip), alternations=int(sum(trip)),
                head_only=peeks)


# ------------------------------------------------------------------ T maze VTE
def t_maze(lang, out):
    rng = np.random.default_rng(141)
    n_tr = 16
    vte = set(rng.choice(n_tr, 4, replace=False).tolist())
    fps = 30
    idphi = []; paths = {}; choices = []
    for k in range(n_tr):
        side = 1 if (k % 2 == 0) ^ (rng.random() < 0.2) else -1
        choices.append(side)
        X, Y, Hh = [], [], []
        y = 28.0
        while y > 1.5:
            y -= 15 / fps
            X.append(rng.normal(0, 0.15)); Y.append(y); Hh.append(-math.pi / 2 + rng.normal(0, 0.05))
        if k in vte:
            n = int(rng.uniform(1.6, 2.8) * fps)
            amp = rng.uniform(0.9, 1.3)
            for j in range(n):
                X.append(X[-1] * 0.95); Y.append(max(Y[-1] - 0.02, 0.5))
                Hh.append(-math.pi / 2 + amp * math.sin(2 * math.pi * 0.8 * j / fps) * (1 - 0.3 * j / n))
        else:
            for j in range(int(rng.uniform(0.1, 0.4) * fps)):
                X.append(X[-1]); Y.append(Y[-1]); Hh.append(-math.pi / 2 + rng.normal(0, 0.04))
        target = 0.0 if side > 0 else math.pi
        h = Hh[-1]
        x = X[-1]; yy = Y[-1]
        while abs(x) < 26:
            want = target if side > 0 else (math.pi if h > 0 or h < -math.pi / 2 else -math.pi)
            h += 0.25 * (((target - h + math.pi) % (2 * math.pi)) - math.pi)
            x += 15 / fps * math.cos(h); yy = yy + 15 / fps * math.sin(h) * 0.3
            yy = yy * 0.9
            X.append(x); Y.append(yy); Hh.append(h + rng.normal(0, 0.04))
        X, Y, Hh = np.array(X), np.array(Y), np.unwrap(np.array(Hh))
        zone = (np.abs(X) < 6) & (Y < 6)
        idphi.append(np.degrees(np.abs(np.diff(Hh))[zone[1:]]).sum())
        paths[k] = (X, Y, Hh)
    idphi = np.array(idphi)
    z = (idphi - idphi.mean()) / idphi.std()
    isv = z >= 0.5
    alt = 100 * np.mean([choices[i] != choices[i - 1] for i in range(1, n_tr)])
    fig, a, b = figure(ratios=(0.9, 1.25))
    arena_axes(a, (-30, 30), (-4, 30), T(lang, 'T maze: two passes through the choice point', 'T 迷宫：两次经过选择点'), pad=2.5)
    rect(a, -30, -4, 60, 8, fc=SURF); rect(a, -4, 4, 8, 26, fc=SURF)
    a.plot([-4, 4], [4, 4], color=SURF, lw=2.2, zorder=1.5)
    rect(a, -6, -4, 12, 10, fc=ZONE_B, ec='none', z=1.6, alpha=0.75)
    label(a, 9.5, 8, T(lang, 'choice zone', '选择区'), color=BLUE, size=7, ha='left')
    kv = [k for k in range(n_tr) if isv[k]][0]; kn = int(np.argmin(z))
    for k, col in ((kn, BLUE), (kv, ORANGE)):
        X, Y, Hh = paths[k]
        a.plot(X, Y, color=col, lw=1.2, zorder=3)
    X, Y, Hh = paths[kv]
    sel = np.where((np.abs(X) < 6) & (Y < 6))[0][::9]
    for i in sel:
        a.plot([X[i], X[i] + 4.5 * np.cos(Hh[i])], [Y[i], Y[i] + 4.5 * np.sin(Hh[i])], color=ORANGE, lw=0.8, alpha=0.75, zorder=5)
    label(a, 0, 33.5, T(lang, 'orange: head sweeps (VTE) · blue: direct pass', '橙：头部来回扫视（VTE）· 蓝：直接通过'), size=6.8, color=MUTED)
    xs = np.arange(1, n_tr + 1)
    b.bar(xs, z, width=0.7, color=[ORANGE if v else BLUE for v in isv], edgecolor=SURF, linewidth=1.5, zorder=3)
    b.axhline(0.5, color=INK2, lw=0.9, ls='--')
    b.text(n_tr + 0.4, 0.58, 'zIdPhi = 0.5', ha='right', va='bottom', fontsize=7, color=INK2)
    b.axhline(0, color=GRID, lw=0.8)
    b.set_xticks(xs); b.tick_params(axis='x', length=0, labelsize=6.8)
    b.set_xlabel(T(lang, 'Trial', '试次')); b.set_ylabel('zIdPhi')
    b.grid(axis='y', color=GRID, lw=0.6); b.set_axisbelow(True)
    b.set_title(T(lang, f'{isv.sum()} of {n_tr} passes classed as VTE (orange) · choice alternation {alt:.0f} %',
                  f'{n_tr} 次中 {isv.sum()} 次判为 VTE（橙）· 选择交替 {alt:.0f} %'))
    finish(fig, out, NOTE[lang])
    return dict(trials=n_tr, vte=int(isv.sum()), alternation_pct=round(float(alt), 1),
                idphi_vte=round(float(idphi[isv].mean())), idphi_direct=round(float(idphi[~isv].mean())))


# ------------------------------------------------------------------ place preference (CPP)
def place_pref(lang, out):
    W, H, xs_ = 50, 25, 25

    def inside(x, y):
        if not (0.8 < x < W - 0.8 and 0.8 < y < H - 0.8):
            return False
        return not (abs(x - xs_) < 0.6 and not (9 < y < 16))

    def via(px, py, gx, gy):
        if (px < xs_) != (gx < xs_):
            return (xs_ + (2 if gx > xs_ else -2), 12.5)
        return gx, gy

    L_ = [(x, y) for x in (5, 12, 19) for y in (5, 12.5, 20)]
    R_ = [(x, y) for x in (31, 38, 45) for y in (5, 12.5, 20)]
    rng = np.random.default_rng(151)
    pre, post = [], []
    keep = None
    for k in range(8):
        for phase, target in (('pre', rng.normal(0.47, 0.05)), ('post', rng.normal(0.64, 0.07))):
            wr = target / (1 - target)
            m = simulate(900, 5, (25, 12.5), inside, L_ + R_, [1] * 9 + [wr] * 9, seed=int(rng.integers(1e6)),
                         dwell=(2, 10), via=via, speed=(8, 18))
            t_paired = (m.x > xs_).sum() / 5
            (pre if phase == 'pre' else post).append(t_paired)
            if k == 0 and phase == 'post':
                keep = m
    pre, post = np.array(pre), np.array(post)
    score = post - pre
    fig, a, b = figure(ratios=(1.05, 1))
    arena_axes(a, (0, W), (0, H), T(lang, 'Place preference, post-test, 15 min', '位置偏好，后测，15 分钟'), pad=2)
    rect(a, xs_, 0, W - xs_, H, fc=ZONE_O, ec='none', z=0)
    rect(a, 0, 0, W, H)
    a.plot([xs_, xs_], [0, 9], color=INK2, lw=2); a.plot([xs_, xs_], [16, H], color=INK2, lw=2)
    label(a, 12.5, H + 2.4, T(lang, 'unpaired side', '非配对侧'), color=INK2)
    label(a, 37.5, H + 2.4, T(lang, 'paired side', '配对侧'), color=ORANGE)
    track(a, keep, lw=0.4, alpha=0.6)
    for p_, q_ in zip(pre, post):
        b.plot([0, 1], [p_, q_], '-', color=MUTED, lw=0.9, alpha=0.8)
        b.plot([0, 1], [p_, q_], 'o', color=MUTED, ms=3.5, mec=SURF, mew=0.6)
    b.plot([0, 1], [pre.mean(), post.mean()], '-o', color=ORANGE, lw=2.4, ms=6, mec=SURF, mew=1, zorder=4)
    b.text(1.06, post.mean(), f'{post.mean():.0f} s', va='center', fontsize=7.5, color=INK)
    b.text(-0.06, pre.mean(), f'{pre.mean():.0f} s', va='center', ha='right', fontsize=7.5, color=INK)
    b.axhline(450, color=INK2, lw=0.8, ls='--'); b.text(1.38, 444, T(lang, 'half of 15 min', '15 分钟的一半'), ha='right', va='top', fontsize=7, color=INK2)
    b.set_xlim(-0.4, 1.4); b.set_xticks([0, 1], [T(lang, 'Pre-test', '前测'), T(lang, 'Post-test', '后测')])
    b.tick_params(axis='x', length=0)
    b.set_ylabel(T(lang, 'Paired-side time (s)', '配对侧时间（s）')); b.grid(axis='y', color=GRID, lw=0.6)
    b.set_title(T(lang, f'CPP score +{score.mean():.0f} s (post − pre, mean of 8 mice)',
                  f'CPP 分数 +{score.mean():.0f} s（后测 − 前测，8 只均值）'))
    finish(fig, out, NOTE[lang] + T(lang, '  Grey lines: individual mice; orange: mean.', '  灰线：每只小鼠；橙线：均值。'))
    return dict(pre_mean_s=round(float(pre.mean())), post_mean_s=round(float(post.mean())), cpp_score_s=round(float(score.mean())),
                n=8)


TASKS_B = {
    'three-chamber': three_chamber, 'social-interaction': social_interaction, 'dyadic-social': dyadic,
    'resident-intruder': resident_intruder, 'group-behavior': group_behaviour, 'head-direction': head_direction, 'spatial-exploration': spatial,
    'novel-object-recognition': nor, 'barnes-maze': barnes, 'water-maze': water_maze, 'y-maze': y_maze,
    't-maze': t_maze, 'place-preference': place_pref,
}
