"""Shared pieces for the simulated task figures: style, a simulated mouse, arena drawing."""
import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import patches as mp

INK, INK2, MUTED, GRID = '#0b0b0b', '#52514e', '#8a8984', '#e4e3de'
SURF = '#fcfcfb'
BLUE, ORANGE, AQUA, RED, VIOLET = '#2a78d6', '#eb6834', '#1baf7a', '#e34948', '#6250d6'
ZONE_B, ZONE_O, ZONE_G, ZONE_A = '#e3eefb', '#fde9e0', '#efeee9', '#dff4ec'
ARENA_EDGE = '#9b9a94'

plt.rcParams.update({
    'font.family': ['Inter', 'Noto Sans CJK SC'],
    'font.size': 8.5,
    'axes.edgecolor': GRID, 'axes.labelcolor': INK2, 'axes.titlecolor': INK,
    'axes.titlesize': 9.5, 'axes.titleweight': 'semibold', 'axes.titlelocation': 'left', 'axes.titlepad': 8,
    'xtick.color': INK2, 'ytick.color': INK2, 'xtick.labelsize': 7.5, 'ytick.labelsize': 7.5,
    'axes.spines.top': False, 'axes.spines.right': False,
    'figure.facecolor': SURF, 'axes.facecolor': SURF, 'savefig.facecolor': SURF,
    'legend.frameon': False, 'legend.fontsize': 7.5,
    'axes.unicode_minus': False,
})


def T(lang, en, zh):
    return en if lang == 'en' else zh


class Mouse:
    """A simulated mouse: body centre, heading, nose and tail base at a fixed rate."""

    def __init__(self, t, x, y, heading, L=7.0):
        self.t, self.x, self.y, self.h = t, x, y, heading
        self.L = L
        self.dt = t[1] - t[0]

    @property
    def nose(self):
        return self.x + 0.5 * self.L * np.cos(self.h), self.y + 0.5 * self.L * np.sin(self.h)

    @property
    def tail(self):
        return self.x - 0.5 * self.L * np.cos(self.h), self.y - 0.5 * self.L * np.sin(self.h)

    @property
    def speed(self):
        v = np.hypot(np.gradient(self.x, self.dt), np.gradient(self.y, self.dt))
        return v


def simulate(T_s, fps, start, inside, goals, weights=None, seed=0, speed=(6, 18), pause=(0.04, 0.25),
             dwell=(0.5, 4.0), turn_noise=0.35, heading=None, L=7.0, goal_sampler=None, via=None):
    """Correlated random walk steered towards goals, kept inside `inside(x, y)`.

    goals: list of (x, y); weights: their sampling weights. The mouse walks to a goal, may dwell there,
    then picks the next goal. Returns a Mouse.
    """
    rng = np.random.default_rng(seed)
    n = int(T_s * fps)
    dt = 1.0 / fps
    x = np.zeros(n); y = np.zeros(n); h = np.zeros(n)
    px, py = start
    hd = rng.uniform(-math.pi, math.pi) if heading is None else heading
    if goals is not None:
        w = np.ones(len(goals)) if weights is None else np.asarray(weights, float)
        w = w / w.sum()

    focus = [None]

    def pick():
        if goal_sampler is not None:
            return goal_sampler(rng)
        g = goals[rng.choice(len(goals), p=w)]
        focus[0] = (g[2], g[3]) if len(g) >= 4 else None
        return g[0] + rng.normal(0, 1.0), g[1] + rng.normal(0, 1.0)

    gx, gy = pick()
    dwell_left = 0.0
    dwell_focus = None
    v = rng.uniform(*speed)
    moving = True
    for i in range(n):
        if dwell_left > 0:
            dwell_left -= dt
            if dwell_focus is not None:          # face the object being investigated
                want = math.atan2(dwell_focus[1] - py, dwell_focus[0] - px)
                hd += 0.35 * (((want - hd + math.pi) % (2 * math.pi)) - math.pi) + rng.normal(0, 0.12)
            else:
                hd += rng.normal(0, 0.25)          # head turns while dwelling
            step = 0.4 * rng.normal(0, 1) * dt
        else:
            dx, dy = gx - px, gy - py
            dist = math.hypot(dx, dy)
            if dist < 2.0:
                dwell_focus = focus[0]
                dwell_left = rng.uniform(*dwell) if (rng.random() < 0.6 or dwell_focus is not None) else 0.0
                gx, gy = pick()
            if via is not None:                      # route through doors etc.
                sx, sy = via(px, py, gx, gy)
                dx, dy = sx - px, sy - py
            want = math.atan2(dy, dx)
            diff = (want - hd + math.pi) % (2 * math.pi) - math.pi
            hd += 0.25 * diff + rng.normal(0, turn_noise) * math.sqrt(dt * 10)
            if moving and rng.random() < pause[0] * dt * 10:
                moving = False
            elif not moving and rng.random() < pause[1] * dt * 10:
                moving = True
                v = rng.uniform(*speed)
            step = (v if moving else 0.3) * dt
        nx, ny = px + step * math.cos(hd), py + step * math.sin(hd)
        tries = 0
        while not inside(nx, ny) and tries < 12:
            hd += rng.uniform(1.0, 2.5) * rng.choice([-1, 1])
            nx, ny = px + step * math.cos(hd), py + step * math.sin(hd)
            tries += 1
        if inside(nx, ny):
            px, py = nx, ny
        x[i], y[i], h[i] = px, py, hd
    t = np.arange(n) * dt
    return Mouse(t, x, y, np.unwrap(h), L=L)


def runs(mask):
    """Start/end index pairs of True runs."""
    m = np.concatenate([[False], np.asarray(mask, bool), [False]])
    d = np.diff(m.astype(int))
    return list(zip(np.where(d == 1)[0], np.where(d == -1)[0]))


def min_duration(mask, n_min):
    out = np.zeros(len(mask), bool)
    for a, b in runs(mask):
        if b - a >= n_min:
            out[a:b] = True
    return out


def track(ax, m, color=BLUE, lw=0.7, alpha=0.85, every=1, start_end=True, z=3):
    ax.plot(m.x[::every], m.y[::every], color=color, lw=lw, alpha=alpha, zorder=z, solid_capstyle='round')
    if start_end:
        ax.plot(m.x[0], m.y[0], 'o', ms=4.5, mfc=SURF, mec=color, mew=1.2, zorder=z + 1)
        ax.plot(m.x[-1], m.y[-1], 's', ms=4.2, mfc=color, mec=SURF, mew=0.8, zorder=z + 1)


def arena_axes(ax, xlim, ylim, title=None, pad=1.5):
    ax.set_xlim(xlim[0] - pad, xlim[1] + pad)
    ax.set_ylim(ylim[1] + pad, ylim[0] - pad)   # image coordinates: y down
    ax.set_aspect('equal')
    ax.axis('off')
    if title:
        ax.set_title(title, loc='left')


def rect(ax, x0, y0, w, h, fc='none', ec=ARENA_EDGE, lw=1.0, z=1, **kw):
    ax.add_patch(mp.Rectangle((x0, y0), w, h, fc=fc, ec=ec, lw=lw, zorder=z, **kw))


def circ(ax, cx, cy, r, fc='none', ec=ARENA_EDGE, lw=1.0, z=1, **kw):
    ax.add_patch(mp.Circle((cx, cy), r, fc=fc, ec=ec, lw=lw, zorder=z, **kw))


def label(ax, x, y, s, color=INK2, size=7.5, ha='center', va='center', weight='normal', z=6, box=False):
    kw = dict(bbox=dict(fc=SURF, ec='none', pad=1.2, alpha=0.88, boxstyle='round,pad=0.2')) if box else {}
    ax.text(x, y, s, color=color, fontsize=size, ha=ha, va=va, fontweight=weight, zorder=z, **kw)


def bars(ax, names, values, colors, unit='', fmt='{:.0f}', ylim=None, ylabel=None):
    xs = np.arange(len(names))
    ax.bar(xs, values, width=0.6, color=colors, edgecolor=SURF, linewidth=2, zorder=3)
    for xi, v in zip(xs, values):
        ax.text(xi, v, ' ' + fmt.format(v) + unit, ha='center', va='bottom', fontsize=7.5, color=INK, zorder=4)
    ax.set_xticks(xs, names)
    ax.tick_params(axis='x', length=0)
    ax.grid(axis='y', color=GRID, lw=0.6, zorder=0)
    ax.set_axisbelow(True)
    if ylim:
        ax.set_ylim(*ylim)
    if ylabel:
        ax.set_ylabel(ylabel)


def finish(fig, path, note):
    fig.text(0.012, 0.015, note, fontsize=6.8, color=MUTED, ha='left', va='bottom')
    fig.savefig(path, dpi=200)
    plt.close(fig)


def figure(width=8.4, height=3.5, ratios=(1, 1.15)):
    fig = plt.figure(figsize=(width, height))
    gs = fig.add_gridspec(1, 2, width_ratios=ratios, left=0.03, right=0.985, top=0.86, bottom=0.17, wspace=0.18)
    return fig, fig.add_subplot(gs[0]), fig.add_subplot(gs[1])


def heading_from_motion(m, smooth_s=0.6, min_speed=2.0):
    """Body heading = direction of smoothed motion; held while the mouse is (almost) still."""
    k = max(1, int(smooth_s / m.dt))
    ker = np.ones(k) / k
    vx = np.convolve(np.gradient(m.x, m.dt), ker, mode='same')
    vy = np.convolve(np.gradient(m.y, m.dt), ker, mode='same')
    sp = np.hypot(vx, vy)
    h = np.zeros(len(m.x)); cur = m.h[0]
    for i in range(len(h)):
        if sp[i] > min_speed:
            cur = math.atan2(vy[i], vx[i])
        h[i] = cur
    m.h = np.unwrap(h)
    return m


def inject_looks(m, rng, n, cond, angle, dur=(0.4, 1.2)):
    """Add n short head turns (e.g. head dips) at random still moments where cond(i) holds.

    angle(i) returns the direction the head turns to at frame i.
    """
    still = np.where((m.speed < 3))[0]
    cand = [i for i in still if cond(i)]
    if not cand:
        return []
    picks = sorted(rng.choice(cand, size=min(n, len(cand)), replace=False))
    done = []
    last = -10 ** 9
    for i in picks:
        if i - last < int(3 / m.dt):
            continue
        d = int(rng.uniform(*dur) / m.dt)
        a = angle(i)
        m.h[i:i + d] = a
        done.append((i, i + d)); last = i
    return done


def walk_seq(fps, start, waypoints, inside=None, seed=0, speed=(8, 16), turn_noise=0.2, L=7.0, T_max=None,
             heading=None, arrive=1.2):
    """Walk through waypoints in order. A waypoint is (x, y) or (x, y, dwell_s) or (x, y, dwell_s, fx, fy):
    on arrival the mouse stays dwell_s seconds, facing (fx, fy) if given. Returns a Mouse."""
    rng = np.random.default_rng(seed)
    dt = 1.0 / fps
    px, py = start
    hd = heading if heading is not None else (math.atan2(waypoints[0][1] - py, waypoints[0][0] - px))
    X, Y, H = [], [], []
    v = rng.uniform(*speed)
    for wp in waypoints:
        gx, gy = wp[0], wp[1]
        dw = wp[2] if len(wp) > 2 else 0.0
        foc = (wp[3], wp[4]) if len(wp) > 4 else None
        guard = 0
        while math.hypot(gx - px, gy - py) > arrive and guard < 60 * fps:
            want = math.atan2(gy - py, gx - px)
            hd += 0.35 * (((want - hd + math.pi) % (2 * math.pi)) - math.pi) + rng.normal(0, turn_noise) * math.sqrt(dt * 10)
            step = min(v * dt, math.hypot(gx - px, gy - py))
            nx, ny = px + step * math.cos(hd), py + step * math.sin(hd)
            if inside is None or inside(nx, ny):
                px, py = nx, ny
            else:
                hd = want
                nx, ny = px + step * math.cos(hd), py + step * math.sin(hd)
                if inside(nx, ny):
                    px, py = nx, ny
            X.append(px); Y.append(py); H.append(hd); guard += 1
            if rng.random() < 0.02:
                v = rng.uniform(*speed)
        for _ in range(int(dw * fps)):
            if foc is not None:
                want = math.atan2(foc[1] - py, foc[0] - px)
                hd += 0.3 * (((want - hd + math.pi) % (2 * math.pi)) - math.pi) + rng.normal(0, 0.1)
            else:
                hd += rng.normal(0, 0.15)
            px += rng.normal(0, 0.03); py += rng.normal(0, 0.03)
            if inside is not None and not inside(px, py):
                px, py = X[-1] if X else start[0], Y[-1] if Y else start[1]
            X.append(px); Y.append(py); H.append(hd)
        if T_max is not None and len(X) >= T_max * fps:
            break
    if T_max is not None:
        X, Y, H = X[:int(T_max * fps)], Y[:int(T_max * fps)], H[:int(T_max * fps)]
    t = np.arange(len(X)) * dt
    return Mouse(t, np.array(X), np.array(Y), np.unwrap(np.array(H)), L=L)


def concat(*ms):
    x = np.concatenate([m.x for m in ms]); y = np.concatenate([m.y for m in ms]); h = np.concatenate([m.h for m in ms])
    dt = ms[0].dt
    return Mouse(np.arange(len(x)) * dt, x, y, np.unwrap(h), L=ms[0].L)


def grouped_bars(ax, groups, series, values, colors, unit='', fmt='{:.0f}', ylabel=None, ylim=None, width=0.34):
    """values[s][g]. A legend names the series."""
    xs = np.arange(len(groups))
    n = len(series)
    for k, (name, col) in enumerate(zip(series, colors)):
        off = (k - (n - 1) / 2) * (width + 0.03)
        ax.bar(xs + off, values[k], width=width, color=col, edgecolor=SURF, linewidth=2, zorder=3, label=name)
        for xi, v in zip(xs + off, values[k]):
            ax.text(xi, v, fmt.format(v) + unit, ha='center', va='bottom', fontsize=7.2, color=INK, zorder=4)
    ax.set_xticks(xs, groups)
    ax.tick_params(axis='x', length=0)
    ax.grid(axis='y', color=GRID, lw=0.6, zorder=0)
    ax.set_axisbelow(True)
    if ylabel:
        ax.set_ylabel(ylabel)
    if ylim:
        ax.set_ylim(*ylim)
    ax.legend(loc='upper right', handlelength=1.0)


def ethogram(ax, t, rows, T_end, height=0.5):
    """rows: list of (label, mask, color). One band per row (top row first), its label above the band."""
    n = len(rows)
    for k, (name, mask, col) in enumerate(rows):
        yk = n - 1 - k
        ax.add_patch(mp.Rectangle((0, yk - height / 2), T_end, height, fc='#f1f0ec', ec='none', zorder=1))
        segs = [(t[a], max(t[b - 1] - t[a], 0) + (t[1] - t[0])) for a, b in runs(mask)]
        if segs:
            ax.broken_barh(segs, (yk - height / 2, height), facecolors=col, zorder=2)
        ax.text(0, yk + height / 2 + 0.06, name, fontsize=7.4, color=INK, ha='left', va='bottom', zorder=4)
    ax.set_yticks([])
    ax.set_ylim(-0.5, n - 0.2)
    ax.set_xlim(0, T_end)
    ax.spines['left'].set_visible(False)
