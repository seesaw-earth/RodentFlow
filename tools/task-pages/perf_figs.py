"""Figures for principles/performance.md: speed, keypoint accuracy, identity."""
import os, sys
import numpy as np
from simlib import *

OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)


def save(fig, path):
    fig.savefig(path, dpi=200)
    plt.close(fig)
    from PIL import Image
    Image.open(path).convert('RGB').quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).save(path, optimize=True)


def speed(lang):
    dev = [('MacBook Air M4', 'MacBook Air M4', 109, 4.4), ('iPhone 17 Pro Max', 'iPhone 17 Pro Max', 89, 3.6),
           ('iPad Pro M2', 'iPad Pro M2', 75, 3.0), ('MacBook Pro M2', 'MacBook Pro M2', 62, 2.5)]
    fig, ax = plt.subplots(figsize=(8.4, 2.9))
    fig.subplots_adjust(left=0.2, right=0.97, top=0.8, bottom=0.2)
    ys = np.arange(len(dev))[::-1]
    for y, (e, z, fps, x) in zip(ys, dev):
        ax.barh(y, x, height=0.56, color=BLUE, edgecolor=SURF, linewidth=2, zorder=3)
        ax.text(x + 0.06, y, T(lang, f'{x:.1f}×  ·  {fps} frames/s  ·  10 min of video in {10 / x:.1f} min',
                              f'{x:.1f}×  ·  每秒 {fps} 帧  ·  10 分钟视频约 {10 / x:.1f} 分钟'),
                va='center', fontsize=7.8, color=INK)
    ax.axvline(1, color=INK2, lw=1, ls='--', zorder=4)
    ax.text(1.06, ys[-1] - 0.55, T(lang, 'real time', '实时'), fontsize=7.5, color=INK2, va='center')
    ax.set_yticks(ys, [d[0] for d in dev])
    ax.set_xlim(0, 7.6); ax.set_ylim(ys[-1] - 0.85, ys[0] + 0.5); ax.set_xticks([0, 1, 2, 3, 4, 5])
    ax.set_xlabel(T(lang, 'Times faster than real time (25 frames/s video)', '比实时快几倍（25 帧/秒视频）'))
    ax.grid(axis='x', color=GRID, lw=0.6, zorder=0)
    ax.tick_params(axis='y', length=0)
    ax.spines['left'].set_visible(False)
    ax.set_title(T(lang, 'Pose tracking speed on Apple devices, one mouse, 1280 × 960 video',
                   'Apple 设备上的姿态追踪速度：单鼠，1280 × 960 视频'), loc='left')
    save(fig, os.path.join(OUT, f'speed.{lang}.png'))


def accuracy(lang):
    rows = [('MousePose6', T(lang, 'one dark mouse', '单只深色鼠'), 94.6, 96.1),
            ('WhiteMousePose6', T(lang, 'one white mouse', '单只白鼠'), 99.3, 95.8),
            ('MousePose6Dyad', T(lang, 'two dark mice', '两只深色鼠'), 99.5, 94.7),
            ('MousePose6DyadBW', T(lang, 'one dark, one white', '一黑一白'), 98.7, 94.0)]
    fig, ax = plt.subplots(figsize=(8.4, 3.0))
    fig.subplots_adjust(left=0.27, right=0.97, top=0.8, bottom=0.2)
    ys = np.arange(len(rows))[::-1]
    for y, (m, sub, det, pck) in zip(ys, rows):
        ax.plot([min(det, pck), max(det, pck)], [y, y], color=GRID, lw=3, zorder=2, solid_capstyle='round')
        ax.plot(det, y, 'o', ms=9, color=BLUE, mec=SURF, mew=1.5, zorder=4)
        ax.plot(pck, y, 'D', ms=8, color=ORANGE, mec=SURF, mew=1.5, zorder=4)
        lo, hi = (det, pck) if det < pck else (pck, det)
        ax.text(lo - 0.25, y, f'{lo:.1f}', ha='right', va='center', fontsize=7.5, color=INK)
        ax.text(hi + 0.25, y, f'{hi:.1f}', ha='left', va='center', fontsize=7.5, color=INK)
    ax.set_yticks(ys, [f'{m}\n{s}' for m, s, *_ in rows])
    ax.set_xlim(88, 101); ax.set_xticks([90, 92, 94, 96, 98, 100])
    ax.set_xlabel(T(lang, 'Percent, held-out test images', '百分比，留出测试图像'))
    ax.grid(axis='x', color=GRID, lw=0.6, zorder=0)
    ax.tick_params(axis='y', length=0, labelsize=7.5)
    ax.spines['left'].set_visible(False)
    ax.plot([], [], 'o', ms=8, color=BLUE, label=T(lang, 'Mice detected', '检出的小鼠'))
    ax.plot([], [], 'D', ms=7, color=ORANGE, label=T(lang, 'Keypoints within 0.1 body length (PCK@0.1 L)', '误差在 0.1 体长以内的关键点（PCK@0.1 L）'))
    ax.legend(loc='lower left', bbox_to_anchor=(0, 1.0), ncol=2, handletextpad=0.4, columnspacing=1.4, borderaxespad=0.2)
    fig.text(0.012, 0.95, T(lang, 'Detection and keypoint accuracy of the four pose models', '四个姿态模型的检出率与关键点精度'),
             fontsize=9.5, fontweight='semibold', color=INK)
    save(fig, os.path.join(OUT, f'accuracy.{lang}.png'))


def identity(lang):
    rows = [(T(lang, 'Black and white coats', '黑白两色'), 98.0, None),
            (T(lang, 'Light mark on one mouse', '一只有浅色标记'), 97.9, None),
            (T(lang, 'Juvenile intruder', '幼年入侵者'), 97.5, None),
            (T(lang, 'Same coat, 5 % difference in length and activity', '同色，体长与活动量差 5 %'), 91.7, 98.1),
            (T(lang, 'Same coat, no difference', '同色，无差异'), 58.3, 96.7)]
    fig, ax = plt.subplots(figsize=(8.4, 3.3))
    fig.subplots_adjust(left=0.33, right=0.97, top=0.8, bottom=0.18)
    ys = np.arange(len(rows))[::-1] * 1.0
    h = 0.34
    for y, (name, a, c) in zip(ys, rows):
        if c is None:
            ax.barh(y, a, height=h * 1.5, color=BLUE, edgecolor=SURF, linewidth=2, zorder=3)
            ax.text(a + 0.8, y, f'{a:.1f} %', va='center', fontsize=7.5, color=INK)
        else:
            ax.barh(y + h / 2 + 0.01, a, height=h, color=BLUE, edgecolor=SURF, linewidth=2, zorder=3)
            ax.barh(y - h / 2 - 0.01, c, height=h, color=VIOLET, edgecolor=SURF, linewidth=2, zorder=3)
            ax.text(a + 0.8, y + h / 2, f'{a:.1f} %', va='center', fontsize=7.5, color=INK)
            ax.text(c + 0.8, y - h / 2, f'{c:.1f} %', va='center', fontsize=7.5, color=INK)
    ax.set_yticks(ys, [r[0] for r in rows])
    ax.set_xlim(0, 108); ax.set_xticks([0, 25, 50, 75, 100])
    ax.axvline(50, color=INK2, lw=0.9, ls='--', zorder=4)
    ax.text(51, ys[0] + 0.55, T(lang, 'chance', '随机'), fontsize=7.2, color=INK2)
    ax.set_xlabel(T(lang, 'Frames with the correct identity (%)', '身份正确的帧（%）'))
    ax.grid(axis='x', color=GRID, lw=0.6, zorder=0)
    ax.tick_params(axis='y', length=0, labelsize=7.6)
    ax.spines['left'].set_visible(False)
    from matplotlib.patches import Patch
    ax.legend(handles=[Patch(color=BLUE, label=T(lang, 'Automatic', '自动')),
                       Patch(color=VIOLET, label=T(lang, 'After checking flagged moments', '检查标记时刻之后'))],
              loc='lower left', bbox_to_anchor=(0, 1.0), ncol=2, borderaxespad=0.2)
    fig.text(0.012, 0.95, T(lang, 'Two-mouse identity, simulated 10-minute recordings (8 per scenario)', '双鼠身份：模拟 10 分钟录像（每种情形 8 段）'),
             fontsize=9.5, fontweight='semibold', color=INK)
    save(fig, os.path.join(OUT, f'identity.{lang}.png'))


for lang in ('en', 'zh'):
    speed(lang); accuracy(lang); identity(lang)
print('ok')
