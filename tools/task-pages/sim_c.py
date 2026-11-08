"""Simulated figures, part C: avoidance, fear, threat, motor and pose-only."""
import math
import numpy as np
from matplotlib import patches as mp
from simlib import *
from sim_a import NOTE, angdiff

FPS = 10


def km_curve(times, event):
    """Kaplan–Meier estimate of 'not yet entered'. Returns step x, y and censor points."""
    order = np.argsort(times)
    t = np.asarray(times)[order]; e = np.asarray(event)[order]
    n = len(t); s = 1.0
    xs, ys = [0.0], [1.0]
    cens = []
    at_risk = n
    for ti, ei in zip(t, e):
        if ei:
            xs += [ti, ti]; ys += [s, s * (at_risk - 1) / at_risk]
            s = s * (at_risk - 1) / at_risk
        else:
            cens.append((ti, s))
        at_risk -= 1
    return np.array(xs), np.array(ys), cens


def km_axes(ax, groups, cutoff, ylabel, xlabel):
    for name, times, ev, col in groups:
        xs, ys, cens = km_curve(times, ev)
        xs = np.r_[xs, cutoff]; ys = np.r_[ys, ys[-1]]
        ax.plot(xs, ys, color=col, lw=2, label=name, drawstyle='default')
        for tc, sc in cens:
            ax.plot(tc, sc, '|', color=col, ms=9, mew=1.6)
    ax.set_xlim(0, cutoff * 1.04); ax.set_ylim(-0.03, 1.05)
    ax.set_ylabel(ylabel); ax.set_xlabel(xlabel)
    ax.grid(axis='y', color=GRID, lw=0.6)
    ax.legend(loc='center right')


def median_latency(times, ev, cutoff):
    xs, ys, _ = km_curve(times, ev)
    below = np.where(ys <= 0.5)[0]
    return float(xs[below[0]]) if len(below) else None


# ------------------------------------------------------------------ passive avoidance
def passive_avoidance(lang, out):
    W, H, xd, cutoff = 40, 20, 20, 300
    rng = np.random.default_rng(161)
    n = 10
    train = np.clip(rng.lognormal(math.log(16), 0.5, n), 4, 80)
    test = rng.lognormal(math.log(330), 0.45, n)
    test_ev = test < cutoff
    test = np.minimum(test, cutoff)
    # one test session that never enters: stays on the light side, now and then puts its head through the door
    inside = lambda x, y: 0.8 < x < xd - 1.5 and 0.8 < y < H - 0.8
    light = [(4, 4), (4, 16), (10, 10), (14, 4), (14, 16), (16, 10, 30, 10)]
    m = simulate(cutoff, FPS, (5, 10), inside, light, [1, 1, 1, 1, 1, 0.5], seed=162, dwell=(2, 8))
    heading_from_motion(m)
    inject_looks(m, rng, 8, lambda i: m.x[i] > xd - 5.0 and 8 < m.y[i] < 12, lambda i: rng.normal(0, 0.2))
    nx, ny = m.nose; tx, ty = m.tail
    probe = min_duration((nx > xd) & (m.x < xd) & (tx < xd), 3)
    n_probe = len(runs(probe))
    fig, a, b = figure(ratios=(1, 1.1))
    arena_axes(a, (0, W), (0, H), T(lang, 'Passive avoidance, test day, 300 s', '被动回避，测试日，300 秒'), pad=2)
    rect(a, xd, 0, W - xd, H, fc='#e7e6e1', ec='none', z=0)
    rect(a, 0, 0, W, H)
    a.plot([xd, xd], [0, 8], color=INK2, lw=2); a.plot([xd, xd], [12, H], color=INK2, lw=2)
    label(a, 10, H + 2.2, T(lang, 'light side (start)', '明室（起点）'), color=INK2)
    label(a, 30, H + 2.2, T(lang, 'dark side (shock on training day)', '暗室（训练日电击）'), color=INK2)
    track(a, m, lw=0.5, alpha=0.8)
    for s0, s1 in runs(probe):
        i = (s0 + s1) // 2
        a.plot(nx[i], ny[i], 'o', ms=4.5, color=ORANGE, mec=SURF, mew=0.8, zorder=6)
    km_axes(b, [(T(lang, 'Training', '训练'), train, np.ones(n, bool), MUTED),
                (T(lang, 'Test (24 h later)', '测试（24 h 后）'), test, test_ev, BLUE)], cutoff,
            T(lang, 'Not yet entered the dark side', '尚未进入暗室的比例'), T(lang, 'Time (s)', '时间（s）'))
    med_tr = median_latency(train, np.ones(n, bool), cutoff)
    n_cens = int((~test_ev).sum())
    b.set_title(T(lang, f'Median latency {med_tr:.0f} s in training · {n_cens} of {n} stayed out at test',
                  f'训练时中位潜伏期 {med_tr:.0f} s · 测试时 {n} 只中 {n_cens} 只未进入'))
    finish(fig, out, NOTE[lang] + T(lang, '  Ticks: cut-off reached (censored). Orange dots: head through the door.',
                                    '  竖线：到截止时间（删失）。橙点：探头进暗室。'))
    return dict(median_train_s=round(med_tr), censored_test=n_cens, n=n, probes=n_probe)


# ------------------------------------------------------------------ step-down
def step_down(lang, out):
    W, P, cutoff = 25, 7, 180
    rng = np.random.default_rng(171)
    n = 10
    train = np.clip(rng.lognormal(math.log(9), 0.5, n), 2, 40)
    test = rng.lognormal(math.log(260), 0.5, n)
    test_ev = test < cutoff
    test = np.minimum(test, cutoff)
    c = W / 2; hp = P / 2
    inside = lambda x, y: abs(x - c) < 0.6 and abs(y - c) < 0.6
    m = simulate(cutoff, FPS, (c, c), inside, [(c - 0.4, c - 0.4), (c + 0.4, c + 0.4), (c - 0.4, c + 0.4), (c + 0.4, c - 0.4)],
                 seed=172, speed=(0.5, 1.5), dwell=(3, 12), L=6.0)
    rng2 = np.random.default_rng(173)
    dirs = [0.0, math.pi / 2, math.pi, -math.pi / 2]
    picks = sorted(rng2.choice(np.arange(20, len(m.x) - 40), 9, replace=False))
    for i0 in picks:
        d = int(rng2.uniform(0.6, 1.6) * FPS)
        a_ = dirs[rng2.integers(4)] + rng2.normal(0, 0.2)
        ramp = np.sin(np.linspace(0, math.pi, d))
        m.h[i0:i0 + d] = a_
        m.x[i0:i0 + d] += 0.9 * ramp * math.cos(a_); m.y[i0:i0 + d] += 0.9 * ramp * math.sin(a_)
    nx, ny = m.nose; tx, ty = m.tail
    on = lambda X, Y: (np.abs(X - c) <= hp) & (np.abs(Y - c) <= hp)
    dips = min_duration(~on(nx, ny) & on(m.x, m.y) & on(tx, ty), 3)
    n_dips = len(runs(dips))
    fig, a, b = figure(ratios=(1, 1.15))
    arena_axes(a, (c - 8, c + 8), (c - 8, c + 8), T(lang, 'Step-down, test day: the platform', '跳台，测试日：平台'), pad=0.5)
    rect(a, c - 8, c - 8, 16, 16, fc='#ecebe6', ec='none', z=0)
    rect(a, c - hp, c - hp, P, P, fc=SURF, ec=INK2, lw=1.4)
    label(a, c, c + hp + 2.8, T(lang, 'platform 7 × 7 cm', '平台 7 × 7 cm'), color=INK2, size=7)
    label(a, c, c - hp - 2.8, T(lang, 'floor (shock on training day)', '底板（训练日电击）'), color=MUTED, size=7)
    a.plot(m.x, m.y, color=BLUE, lw=0.6, alpha=0.7, zorder=3)
    for s0, s1 in runs(dips):
        i = (s0 + s1) // 2
        a.plot([m.x[i], nx[i]], [m.y[i], ny[i]], color=ORANGE, lw=1.2, zorder=5)
        a.plot(nx[i], ny[i], 'o', ms=4.5, color=ORANGE, mec=SURF, mew=0.8, zorder=6)
    km_axes(b, [(T(lang, 'Training', '训练'), train, np.ones(n, bool), MUTED),
                (T(lang, 'Test (24 h later)', '测试（24 h 后）'), test, test_ev, BLUE)], cutoff,
            T(lang, 'Still on the platform', '仍在平台上的比例'), T(lang, 'Time (s)', '时间（s）'))
    med_tr = median_latency(train, np.ones(n, bool), cutoff)
    n_cens = int((~test_ev).sum())
    b.set_title(T(lang, f'Median step-down {med_tr:.0f} s in training · {n_cens} of {n} stayed up at test',
                  f'训练时中位跳下潜伏期 {med_tr:.0f} s · 测试时 {n} 只中 {n_cens} 只未跳下'))
    finish(fig, out, NOTE[lang] + T(lang, f'  Orange: {n_dips} edge head dips in one 180 s test.', f'  橙色：一次 180 秒测试中的 {n_dips} 次边缘探头。'))
    return dict(median_train_s=round(med_tr), censored_test=n_cens, n=n, edge_dips=n_dips)


# ------------------------------------------------------------------ fear conditioning
def motion_session(rng, phases, fps):
    """phases: list of (duration_s, freeze_prob). Alternating freeze / move bouts; returns speed (cm/s)."""
    sp = []
    for dur, pf in phases:
        n = int(dur * fps); k = 0
        while k < n:
            freeze = rng.random() < pf
            L = int((rng.uniform(1.5, 8) if freeze else rng.uniform(1, 5)) * fps)
            L = min(L, n - k)
            if freeze:
                sp += list(np.abs(rng.normal(0.3, 0.2, L)))
            else:
                base = rng.uniform(3, 14)
                sp += list(np.abs(base + rng.normal(0, 2.5, L)))
            k += L
    return np.array(sp)


def fear(lang, out):
    rng = np.random.default_rng(181)
    fps = 10
    cs_on = [180, 270, 360]; cs_len = 30
    phases = [(180, 0.07), (30, 0.8), (60, 0.5), (30, 0.82), (60, 0.55), (30, 0.85), (60, 0.5)]
    v = motion_session(rng, phases, fps)
    k = int(0.5 * fps)
    vs = np.convolve(v, np.ones(k) / k, 'same')
    frz = min_duration(vs < 1.0, int(1.0 * fps))
    t = np.arange(len(v)) / fps
    def pct(a_, b_):
        return frz[int(a_ * fps):int(b_ * fps)].mean() * 100
    pre = pct(0, 180)
    cs = [pct(o, o + cs_len) for o in cs_on]
    iti = np.mean([pct(210, 270), pct(300, 360), pct(390, 450)])
    fig, a, b = figure(ratios=(1.45, 1))
    a.axis('on')
    for o in cs_on:
        a.axvspan(o, o + cs_len, color=ZONE_O, zorder=0, lw=0)
        a.text(o + cs_len / 2, 25.5, 'CS', ha='center', fontsize=7, color=ORANGE)
    for s0, s1 in runs(frz):
        a.add_patch(mp.Rectangle((t[s0], -3.2), t[s1 - 1] - t[s0], 2.0, fc=INK2, ec='none', zorder=2))
    a.plot(t, vs, color=BLUE, lw=0.7, zorder=3)
    a.axhline(1.0, color=INK2, lw=0.8, ls='--')
    a.set_xlim(0, t[-1]); a.set_ylim(-3.6, 27)
    a.set_yticks([0, 5, 10, 15, 20, 25])
    a.set_xlabel(T(lang, 'Time (s)', '时间（s）')); a.set_ylabel(T(lang, 'Speed (cm/s)', '速度（cm/s）'))
    a.grid(axis='y', color=GRID, lw=0.6)
    a.set_title(T(lang, 'Cued fear test: motion and freezing (dark bars)', '线索恐惧测试：运动与冻结（深色条）'))
    names = [T(lang, 'Before CS', 'CS 前'), 'CS 1', 'CS 2', 'CS 3', T(lang, 'Between', 'CS 间')]
    bars(b, names, [pre] + cs + [iti], [MUTED, ORANGE, ORANGE, ORANGE, MUTED], unit=' %', ylim=(0, 100),
         ylabel=T(lang, 'Freezing (%)', '冻结（%）'))
    b.set_title(T(lang, 'Freezing by CS segment', '按 CS 分段的冻结比例'))
    finish(fig, out, NOTE[lang] + T(lang, '  Freezing: speed < 1 cm/s (0.5 s window) for ≥ 1 s.', '  冻结：速度 < 1 cm/s（0.5 s 窗口）持续 ≥ 1 s。'))
    return dict(pre_pct=round(pre, 1), cs1=round(cs[0], 1), cs2=round(cs[1], 1), cs3=round(cs[2], 1), iti_pct=round(iti, 1))


# ------------------------------------------------------------------ looming
def looming(lang, out):
    W = 48; sx, sy = 8, 8; fps = 30
    rng = np.random.default_rng(191)
    trials = []
    starts = [(36, 30), (30, 40), (40, 18), (24, 34), (38, 40)]
    for k, (x0, y0) in enumerate(starts):
        pre_n, post_n = 3 * fps, 8 * fps
        base = rng.uniform(3, 7)
        h0 = rng.uniform(-math.pi, math.pi)
        X = [x0]; Y = [y0]; V = []
        hd = h0
        for i in range(pre_n):
            hd += rng.normal(0, 0.15)
            vv = abs(base + rng.normal(0, 1.5))
            nx_, ny_ = X[-1] + vv / fps * math.cos(hd), Y[-1] + vv / fps * math.sin(hd)
            if not (2 < nx_ < W - 2 and 2 < ny_ < W - 2):
                hd += math.pi; nx_, ny_ = X[-1], Y[-1]
            X.append(nx_); Y.append(ny_); V.append(vv)
        freeze = (k == 3)
        lat = rng.uniform(0.18, 0.45)
        arrived = False
        for i in range(post_n):
            tt = i / fps
            px, py = X[-1], Y[-1]
            d = math.hypot(sx - px, sy - py)
            if freeze:
                vv = abs(rng.normal(0.4, 0.3)) if tt < 4 else abs(rng.normal(4, 1.5))
                want = math.atan2(sy - py, sx - px)
            elif tt < lat:
                vv = abs(base + rng.normal(0, 1))
                want = hd
            elif d > 1.5 and not arrived:
                vv = min(55, 18 + (tt - lat) * 140) + rng.normal(0, 3)
                want = math.atan2(sy - py, sx - px)
            else:
                arrived = True
                vv = abs(rng.normal(0.5, 0.3)); want = hd
            hd += 0.45 * (((want - hd + math.pi) % (2 * math.pi)) - math.pi)
            step = min(vv / fps, max(d, 0.05)) if not freeze or tt >= 4 else vv / fps
            X.append(px + step * math.cos(hd)); Y.append(py + step * math.sin(hd)); V.append(vv)
        X, Y = np.array(X[1:]), np.array(Y[1:])
        t = (np.arange(len(X)) - pre_n) / fps
        spd = np.hypot(np.gradient(X), np.gradient(Y)) * fps
        spd = np.convolve(spd, np.ones(3) / 3, 'same')
        bl = spd[:pre_n].mean()
        thr = max(4 * bl, 15)
        cross = np.where((t >= 0) & (spd > thr))[0]
        latency = t[cross[0]] if len(cross) else None
        dsh = np.hypot(X - sx, Y - sy)
        in_shelter = np.where((t >= 0) & (dsh < 5))[0]
        escape = latency is not None and len(in_shelter) and t[in_shelter[0]] <= 10
        trials.append(dict(t=t, X=X, Y=Y, spd=spd, thr=thr, latency=latency, escape=bool(escape),
                           shelter_t=float(t[in_shelter[0]]) if len(in_shelter) else None))
    fig, a, b = figure(ratios=(1, 1.2))
    arena_axes(a, (0, W), (0, W), T(lang, 'Looming: five trials, −3 to +8 s', '逼近刺激：5 次试验，−3 至 +8 s'))
    rect(a, 0, 0, W, W)
    rect(a, sx - 6, sy - 6, 12, 12, fc=ZONE_A, ec=AQUA, lw=1, z=0.5)
    label(a, sx, sy + 8, T(lang, 'shelter', '庇护所'), color=AQUA, size=7)
    for k, tr in enumerate(trials):
        pre = tr['t'] < 0
        a.plot(tr['X'][pre], tr['Y'][pre], color=MUTED, lw=0.9, zorder=3)
        a.plot(tr['X'][~pre], tr['Y'][~pre], color=ORANGE if not tr['escape'] else BLUE, lw=1.1, zorder=3)
        i0 = int(np.argmax(~pre))
        a.plot(tr['X'][i0], tr['Y'][i0], 'o', ms=5, mfc=SURF, mec=INK, mew=1, zorder=5)
    label(a, W / 2, W + 3.2, T(lang, 'circle: stimulus onset · blue: escape · orange: freezing', '圆圈：刺激开始 · 蓝：逃跑 · 橙：冻结'), size=6.8, color=MUTED)
    for tr in trials:
        b.plot(tr['t'], tr['spd'], color=BLUE if tr['escape'] else ORANGE, lw=1, alpha=0.85)
    b.axvline(0, color=INK, lw=1)
    b.axhline(15, color=INK2, lw=0.8, ls='--')
    b.text(7.8, 16.5, T(lang, 'threshold: max(4 × baseline, 15 cm/s)', '阈值：max(4 × 基线, 15 cm/s)'), ha='right', fontsize=7, color=INK2)
    b.set_xlim(-3, 8); b.set_ylim(0, None)
    b.set_xlabel(T(lang, 'Time from stimulus onset (s)', '距刺激开始（s）')); b.set_ylabel(T(lang, 'Speed (cm/s)', '速度（cm/s）'))
    b.grid(axis='y', color=GRID, lw=0.6)
    lats = [tr['latency'] for tr in trials if tr['escape']]
    n_esc = sum(tr['escape'] for tr in trials)
    b.set_title(T(lang, f'{n_esc} of 5 escapes · median response latency {np.median(lats):.2f} s',
                  f'5 次中 {n_esc} 次逃跑 · 反应潜伏期中位数 {np.median(lats):.2f} s'))
    finish(fig, out, NOTE[lang])
    return dict(escapes=int(n_esc), trials=5, median_latency_s=round(float(np.median(lats)), 2),
                median_to_shelter_s=round(float(np.median([tr['shelter_t'] for tr in trials if tr['escape']])), 1))


# ------------------------------------------------------------------ platform-mediated avoidance
def pma(lang, out):
    W, H = 30, 25; P = 10
    rng = np.random.default_rng(201)
    inside = lambda x, y: 0.8 < x < W - 0.8 and 0.8 < y < H - 0.8
    onp = lambda X, Y: (X < P) & (Y > H - P)
    pre_s, tone_s, post_s = 10, 30, 10
    lat_mean = [24, 20, 15, 11, 8, 6, 5, 4, 3]
    rows = []; keep = None
    offp = [(x, y) for x in (14, 20, 26) for y in (4, 10, 16)] + [(14, 21), (20, 21), (26, 21)]
    for k, lm in enumerate(lat_mean):
        lat = max(1.0, rng.normal(lm, 2))
        a1 = simulate(pre_s + lat, FPS, (20, 10), inside, offp + [(5, 20)], [1] * 12 + [0.2 + 0.08 * k], seed=300 + k, dwell=(1, 3))
        a2 = walk_seq(FPS, (a1.x[-1], a1.y[-1]), [(5, H - 5, tone_s - lat + rng.uniform(2, 6))], inside, seed=400 + k, speed=(14, 22))
        rest = (pre_s + tone_s + post_s) - (len(a1.x) + len(a2.x)) / FPS
        a3 = simulate(max(rest, 0.5), FPS, (a2.x[-1], a2.y[-1]), inside, offp, None, seed=500 + k)
        m = concat(a1, a2, a3)
        n = int((pre_s + tone_s + post_s) * FPS)
        x = np.pad(m.x[:n], (0, max(0, n - len(m.x))), mode='edge'); y = np.pad(m.y[:n], (0, max(0, n - len(m.y))), mode='edge')
        rows.append(onp(x, y))
        if k == 7:
            keep = (x, y)
    t = np.arange(len(rows[0])) / FPS - pre_s
    tone_pct = [r[(t >= 0) & (t < tone_s)].mean() * 100 for r in rows]
    fig, a, b = figure(ratios=(0.95, 1.3))
    arena_axes(a, (0, W), (0, H), T(lang, 'Platform-mediated avoidance, trial 8', '平台介导回避，第 8 次'), pad=2)
    rect(a, 0, H - P, P, P, fc=ZONE_B, ec=BLUE, lw=1, z=0.5)
    rect(a, 0, 0, W, H)
    label(a, P / 2, H - P - 1.8, T(lang, 'platform', '平台'), color=BLUE, size=7)
    x, y = keep
    tt = np.arange(len(x)) / FPS - pre_s
    pre = tt < 0
    a.plot(x[pre], y[pre], color=MUTED, lw=0.8, zorder=3)
    a.plot(x[(tt >= 0) & (tt < tone_s)], y[(tt >= 0) & (tt < tone_s)], color=ORANGE, lw=1.1, zorder=4)
    label(a, W / 2, H + 2.4, T(lang, 'grey: before tone · orange: during tone', '灰：音前 · 橙：音中'), size=6.8, color=MUTED)
    for k, r in enumerate(rows):
        yk = len(rows) - 1 - k
        b.add_patch(mp.Rectangle((0, yk - 0.38), tone_s, 0.76, fc=ZONE_O, ec='none', zorder=0))
        for s0, s1 in runs(r):
            b.add_patch(mp.Rectangle((t[s0], yk - 0.3), t[s1 - 1] - t[s0] + 0.1, 0.6, fc=BLUE, ec='none', zorder=2))
        b.text(tone_s + post_s + 0.8, yk, f'{tone_pct[k]:.0f} %', va='center', fontsize=7, color=INK)
    b.add_patch(mp.Rectangle((tone_s - 2, -0.7), 2, len(rows) + 0.2, fc='none', ec=RED, lw=0.9, ls='--', zorder=3))
    b.text(tone_s - 1, len(rows) - 0.25, T(lang, 'shock', '电击'), ha='center', va='bottom', fontsize=7, color=RED)
    b.set_xlim(-pre_s, tone_s + post_s + 5); b.set_ylim(-0.7, len(rows) - 0.1)
    b.set_yticks(range(len(rows)), [str(len(rows) - i) for i in range(len(rows))])
    b.tick_params(axis='y', length=0)
    b.set_ylabel(T(lang, 'Trial', '试次')); b.set_xlabel(T(lang, 'Time from tone onset (s)', '距声音开始（s）'))
    b.spines['left'].set_visible(False)
    b.set_title(T(lang, f'On the platform (blue) during the tone: trial 1 {tone_pct[0]:.0f} %, trial 9 {tone_pct[-1]:.0f} %',
                  f'声音期间在平台上（蓝）：第 1 次 {tone_pct[0]:.0f} %，第 9 次 {tone_pct[-1]:.0f} %'))
    finish(fig, out, NOTE[lang] + T(lang, '  Right: % of tone time on the platform.', '  右侧数字：声音期间在平台上的时间比例。'))
    return dict(tone_pct_first=round(float(tone_pct[0]), 1), tone_pct_last=round(float(tone_pct[-1]), 1),
                tone_pct=[round(float(v), 1) for v in tone_pct])


# ------------------------------------------------------------------ rotation
def count_turns(theta):
    """Full 360° turns, CCW and CW separately; a reversal of > 90° restarts the count."""
    d = np.diff(theta)
    acc = 0.0; hi = 0.0; lo = 0.0; ccw = []; cw = []
    for i, x in enumerate(d):
        acc += x
        hi = max(hi, acc); lo = min(lo, acc)
        if acc >= 2 * math.pi:
            ccw.append(i); acc = 0.0; hi = lo = 0.0
        elif acc <= -2 * math.pi:
            cw.append(i); acc = 0.0; hi = lo = 0.0
        elif hi > 0 and hi - acc > math.pi / 2:
            acc = 0.0; hi = lo = 0.0
        elif lo < 0 and acc - lo > math.pi / 2:
            acc = 0.0; hi = lo = 0.0
    return np.array(ccw, int), np.array(cw, int)


def rotation(lang, out):
    fps = 10; T_s = 3600
    rng = np.random.default_rng(211)
    n = T_s * fps
    tm = np.arange(n) / fps / 60
    drift = 2 * math.pi * (0.09 * (tm / 20) * np.exp(1 - tm / 20)) / 1.0   # rad/s: rises, peaks ~ 20 min
    w = np.zeros(n); o = 0.0
    for i in range(n):
        o += -0.05 * o + rng.normal(0, 0.25)
        w[i] = o
    omega = drift + w
    theta = np.cumsum(omega / fps)
    ccw, cw = count_turns(theta)          # the drawn position angle is −theta; with image y pointing down,
    ipsi_idx, contra_idx = ccw, cw        # increasing theta looks counter-clockwise = left turns = ipsilateral (left lesion)
    bins = np.arange(0, 61, 5)
    ipsi = np.histogram(ipsi_idx / fps / 60, bins)[0]; contra = np.histogram(contra_idx / fps / 60, bins)[0]
    net = len(ipsi_idx) - len(contra_idx)
    r = 6 + 2 * np.sin(np.arange(n) / fps / 7)
    x = 15 + r * np.cos(-theta); y = 15 + r * np.sin(-theta)
    fig, a, b = figure(ratios=(0.8, 1.35))
    arena_axes(a, (0, 30), (0, 30), T(lang, 'Rotation bowl, minutes 18–20', '旋转测试，第 18–20 分钟'), pad=2)
    circ(a, 15, 15, 15, fc='#f4f3ef')
    sl = slice(18 * 60 * fps, 20 * 60 * fps)
    a.plot(x[sl], y[sl], color=BLUE, lw=0.5, alpha=0.7)
    a.annotate('', xy=(15 - 10.5, 15 + 1.0), xytext=(15 - 10.0, 15 - 3.2),
               arrowprops=dict(arrowstyle='->', color=INK, lw=1.4))
    label(a, 15, 32.5, T(lang, 'left-lesioned mouse turning left (ipsilateral)', '左侧损毁的小鼠向左转（同侧）'), size=6.8, color=MUTED)
    grouped_bars(b, [f'{bins[i]}–{bins[i + 1]}' for i in range(12)], [T(lang, 'Ipsilateral', '同侧'), T(lang, 'Contralateral', '对侧')],
                 [ipsi, contra], [BLUE, ORANGE], ylabel=T(lang, 'Full turns per 5 min', '每 5 分钟完整转圈数'), width=0.4)
    for txt in b.texts:
        txt.set_fontsize(6)
    b.tick_params(axis='x', labelsize=6.5)
    b.set_xlabel(T(lang, 'Minutes', '分钟'))
    b.set_title(T(lang, f'Net {net} ipsilateral turns in 60 min ({net / 60:.1f} per min)',
                  f'60 分钟净同侧转圈 {net} 圈（每分钟 {net / 60:.1f} 圈）'))
    finish(fig, out, NOTE[lang])
    return dict(ipsi=int(len(ipsi_idx)), contra=int(len(contra_idx)), net=int(net), per_min=round(net / 60, 2),
                peak_bin=f'{bins[int(np.argmax(ipsi))]}–{bins[int(np.argmax(ipsi)) + 1]}')


# ------------------------------------------------------------------ tail suspension, multi-chamber
def tst(lang, out):
    rng = np.random.default_rng(221)
    fps = 10; T_s = 360
    n = T_s * fps; t = np.arange(n) / fps
    imm_prob = [0.55, 0.38, 0.7, 0.48]
    series = []
    for p_end in imm_prob:
        mi = np.zeros(n); k = 0
        while k < n:
            p = 0.12 + (p_end - 0.12) * min(1, t[k] / 150)
            still = rng.random() < p
            L = int((rng.uniform(2, 14) if still else rng.uniform(1, 6)) * fps)
            L = min(L, n - k)
            mi[k:k + L] = np.abs(rng.normal(0.8, 0.5, L)) if still else np.abs(rng.normal(rng.uniform(5, 18), 4, L))
            k += L
        series.append(mi)
    def med(v, w=5):
        return np.array([np.median(v[max(0, i - w // 2):i + w // 2 + 1]) for i in range(len(v))])
    fig = plt.figure(figsize=(8.4, 3.6))
    gs = fig.add_gridspec(4, 2, width_ratios=(1.5, 1), left=0.075, right=0.985, top=0.86, bottom=0.15, wspace=0.22, hspace=0.25)
    b = fig.add_subplot(gs[:, 1])
    res = []
    for c, mi in enumerate(series):
        ax = fig.add_subplot(gs[c, 0])
        sm = med(mi)
        imm = min_duration(sm < 2.0, fps)
        res.append(imm[int(120 * fps):].sum() / fps)
        ax.axvspan(120, 360, color='#f1f0ec', zorder=0, lw=0)
        ax.plot(t, sm, color=BLUE, lw=0.5)
        for s0, s1 in runs(imm):
            ax.add_patch(mp.Rectangle((t[s0], -6), t[s1 - 1] - t[s0], 4, fc=INK2, ec='none'))
        ax.axhline(2.0, color=INK2, lw=0.7, ls='--')
        ax.set_xlim(0, 360); ax.set_ylim(-7, 30); ax.set_yticks([0, 20])
        ax.text(-24, 12, f'{c + 1}', fontsize=8, fontweight='bold', color=INK, ha='center', va='center')
        ax.tick_params(labelsize=6.5)
        if c < 3:
            ax.set_xticklabels([])
        else:
            ax.set_xticks([0, 60, 120, 180, 240, 300, 360], ['0', '1', '2', '3', '4', '5', '6'])
            ax.set_xlabel(T(lang, 'Minute', '分钟'))
        if c == 0:
            ax.set_title(T(lang, 'Motion (% of body pixels changing) · dark bars: immobile', '运动指数（身体像素变化 %）· 深色条：不动'), fontsize=9)
    fig.text(0.012, 0.52, T(lang, 'Chamber', '隔间'), rotation=90, fontsize=7.5, color=INK2, va='center')
    bars(b, ['1', '2', '3', '4'], res, [BLUE] * 4, unit=' s', ylim=(0, 240), ylabel=T(lang, 'Immobility, minutes 2–6 (s)', '第 2–6 分钟不动时间（s）'))
    b.set_xlabel(T(lang, 'Chamber', '隔间'))
    b.set_title(T(lang, 'Four mice scored at once', '一段视频同时计分 4 只'))
    finish(fig, out, NOTE[lang] + T(lang, '  Threshold 2 % (dashed), immobile ≥ 1 s; shaded: minutes 2–6.',
                                    '  阈值 2 %（虚线），不动 ≥ 1 s；灰底：第 2–6 分钟。'))
    return dict(immobility_s=[round(v) for v in res])


# ------------------------------------------------------------------ pose only
def pose_only(lang, out):
    rng = np.random.default_rng(231)
    fig = plt.figure(figsize=(8.4, 3.5))
    gs = fig.add_gridspec(2, 2, width_ratios=(1, 1.3), left=0.03, right=0.985, top=0.86, bottom=0.15, wspace=0.22, hspace=0.45)
    a = fig.add_subplot(gs[:, 0]); b1 = fig.add_subplot(gs[0, 1]); b2 = fig.add_subplot(gs[1, 1])
    a.set_xlim(-2, 15); a.set_ylim(7, -7); a.set_aspect('equal'); a.axis('off')
    a.set_title(T(lang, 'Six keypoints per frame', '每帧 6 个关键点'), loc='left')
    a.add_patch(mp.Ellipse((5.2, 0), 8.6, 5.0, fc='#e6e4de', ec='none'))
    a.add_patch(mp.Ellipse((10.2, 0), 4.2, 3.0, fc='#e6e4de', ec='none'))
    tx = np.linspace(1.0, -1.8, 30); a.plot(tx, 0.9 * np.sin((tx - 1) * 1.6), color='#cfccc4', lw=2.2, solid_capstyle='round')
    kp = {T(lang, 'nose', '鼻尖'): (12.2, 0), T(lang, 'left ear', '左耳'): (9.6, -1.7), T(lang, 'right ear', '右耳'): (9.6, 1.7),
          T(lang, 'neck', '颈部'): (8.3, 0), T(lang, 'body centre', '身体中心'): (5.2, 0), T(lang, 'tail base', '尾根'): (1.0, 0)}
    cols = [BLUE, ORANGE, ORANGE, AQUA, VIOLET, RED]
    pts = list(kp.values())
    for i, j in ((0, 3), (1, 3), (2, 3), (3, 4), (4, 5)):
        a.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]], color=INK2, lw=1, zorder=2)
    offs = [(0, -1.4), (0, -1.3), (0, 1.5), (-0.3, -1.6), (0, 1.5), (0, -1.4)]
    for (name, (x, y)), c, (dx, dy) in zip(kp.items(), cols, offs):
        a.plot(x, y, 'o', ms=7, color=c, mec=SURF, mew=1.2, zorder=3)
        a.text(x + dx, y + dy, name, fontsize=7.2, color=INK, ha='center', va='center')
    a.annotate('', xy=(14.4, 0), xytext=(12.4, 0), arrowprops=dict(arrowstyle='->', color=BLUE, lw=1.2))
    a.text(13.4, 4.9, T(lang, 'head direction:\near midpoint → nose', '头朝向：\n双耳中点 → 鼻尖'), fontsize=7, color=INK2, ha='center')
    fps = 30; tt = np.arange(0, 20, 1 / fps)
    speed = np.clip(6 + 5 * np.sin(tt / 2.1) + 3 * np.sin(tt * 1.3 + 1) + rng.normal(0, 0.8, len(tt)), 0, None)
    speed[(tt > 8) & (tt < 11.5)] = np.abs(rng.normal(0.3, 0.2, ((tt > 8) & (tt < 11.5)).sum()))
    hb = 25 * np.sin(tt * 0.9) + 12 * np.sin(tt * 2.7) + rng.normal(0, 2, len(tt))
    hb[(tt > 8) & (tt < 11.5)] = 40 * np.sin((tt[(tt > 8) & (tt < 11.5)] - 8) * 3.0)
    b1.plot(tt, speed, color=BLUE, lw=1); b1.set_ylabel(T(lang, 'Speed\n(cm/s)', '速度\n（cm/s）'))
    b2.plot(tt, hb, color=VIOLET, lw=1); b2.set_ylabel(T(lang, 'Head–body\nangle (°)', '头–身\n夹角（°）'))
    b2.axhline(0, color=GRID, lw=0.8)
    for ax in (b1, b2):
        ax.axvspan(8, 11.5, color='#f1f0ec', zorder=0, lw=0)
        ax.set_xlim(0, 20); ax.grid(axis='y', color=GRID, lw=0.6)
    b1.set_xticklabels([])
    b1.text(9.75, b1.get_ylim()[1] * 0.92, T(lang, 'still, scanning', '静止、扫视'), ha='center', fontsize=7, color=INK2, va='top')
    b2.set_xlabel(T(lang, 'Time (s)', '时间（s）'))
    b1.set_title(T(lang, 'Kinematics in the frame-by-frame export', '逐帧导出中的运动学'))
    finish(fig, out, NOTE[lang])
    return dict(keypoints=6)


TASKS_C = {
    'passive-avoidance': passive_avoidance, 'step-down': step_down, 'fear-conditioning': fear,
    'looming-escape': looming, 'platform-avoidance': pma, 'rotation': rotation, 'tail-suspension': tst,
    'pose-only': pose_only,
}
