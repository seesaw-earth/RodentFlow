"""Generate docs/tasks/*.md and docs/zh/tasks/*.md from the app's paradigm catalog and the simulated values."""
import json, os, re, sys

ROOT = sys.argv[1]                      # docs/
cat = json.load(open(sys.argv[2]))      # catalog.json
vals = json.load(open(sys.argv[3]))     # values.json

CATS = [
    ('social', 'Social behaviour', '社交行为'),
    ('navigation', 'Navigation & neural recording', '空间导航与神经记录'),
    ('anxiety', 'Anxiety & risk assessment', '焦虑与风险评估'),
    ('memory', 'Learning, memory & fear', '学习、记忆与恐惧'),
    ('motor', 'Motor function & coping', '运动功能与应对'),
    ('general', 'General', '通用'),
]
METHOD = {
    'pose': ('Pose · one animal', '单鼠姿态'),
    'pose2': ('Pose · two animals', '双鼠姿态'),
    'multi': ('Multi-chamber', '多格同步'),
}
ZH_TITLE = {
    'threeChamber': '三箱社交', 'socialInteraction': '社交回避测试', 'dyadicSocial': '双鼠社交互动',
    'residentIntruder': '居住者–入侵者（攻击）', 'headDirection': '头朝向', 'spatialExploration': '空间探索 · 位置细胞',
    'openField': '旷场', 'elevatedPlusMaze': '高架十字迷宫', 'elevatedZeroMaze': '高架零迷宫', 'lightDark': '明暗箱',
    'noveltySuppressedFeeding': '新奇抑制摄食', 'visualCliff': '视觉悬崖', 'marbleBurying': '埋珠实验',
    'stepDown': 'Step-down 抑制性回避', 'platformAvoidance': '平台介导回避', 'novelObject': '新物体识别',
    'barnesMaze': 'Barnes 迷宫', 'waterMaze': 'Morris 水迷宫', 'passiveAvoidance': '被动回避（穿梭箱）',
    'placePreference': '位置偏好（RTPP / CPP）', 'yMaze': 'Y 迷宫自发交替', 'tMaze': 'T 迷宫 · VTE',
    'fearConditioning': '恐惧条件化', 'looming': 'Looming 逃跑', 'rotation': '旋转行为', 'poseOnly': '仅导出姿态',
}
EN_TITLE = {'socialInteraction': 'Social interaction test (CSDS)', 'residentIntruder': 'Resident–intruder (aggression)',
            'spatialExploration': 'Spatial exploration (place / grid cells)', 'threeChamber': 'Three-chamber sociability',
            'dyadicSocial': 'Dyadic social interaction', 'headDirection': 'Head direction', 'openField': 'Open field',
            'elevatedPlusMaze': 'Elevated plus maze', 'elevatedZeroMaze': 'Elevated zero maze', 'lightDark': 'Light–dark box',
            'noveltySuppressedFeeding': 'Novelty-suppressed feeding', 'visualCliff': 'Visual cliff', 'marbleBurying': 'Marble burying',
            'stepDown': 'Step-down inhibitory avoidance', 'platformAvoidance': 'Platform-mediated avoidance',
            'novelObject': 'Novel object recognition', 'barnesMaze': 'Barnes maze', 'waterMaze': 'Morris water maze',
            'passiveAvoidance': 'Passive avoidance (step-through)', 'placePreference': 'Place preference (RTPP / CPP)',
            'yMaze': 'Y-maze spontaneous alternation', 'tMaze': 'T-maze choice & VTE', 'fearConditioning': 'Fear conditioning',
            'looming': 'Looming threat escape', 'rotation': 'Rotation (unilateral lesion)', 'poseOnly': 'Pose only'}

# slug, catalog key, category, method, classic centroid version?, default arena (en, zh)
T = [
    ('three-chamber', 'threeChamber', 'social', 'pose', False, ('60 × 40 cm, three chambers', '60 × 40 cm，三个箱室')),
    ('social-interaction', 'socialInteraction', 'social', 'pose', False, ('42 × 42 cm; 150 s per phase', '42 × 42 cm；每阶段 150 秒')),
    ('dyadic-social', 'dyadicSocial', 'social', 'pose2', False, ('40 × 40 cm', '40 × 40 cm')),
    ('resident-intruder', 'residentIntruder', 'social', 'pose2', False, ('home cage 30 × 18 cm; 10 min from the intruder’s entry', '饲养笼 30 × 18 cm；入侵者放入后 10 分钟')),
    ('head-direction', 'headDirection', 'navigation', 'pose', False, ('50 × 50 cm', '50 × 50 cm')),
    ('spatial-exploration', 'spatialExploration', 'navigation', 'pose', False, ('50 × 50 cm', '50 × 50 cm')),
    ('open-field', 'openField', 'anxiety', 'pose', True, ('40 × 40 cm', '40 × 40 cm')),
    ('elevated-plus-maze', 'elevatedPlusMaze', 'anxiety', 'pose', True, ('arms 30 × 5 cm; 5 min', '臂长 30 cm、宽 5 cm；5 分钟')),
    ('elevated-zero-maze', 'elevatedZeroMaze', 'anxiety', 'pose', False, ('60 cm outer diameter, 5 cm track; 5 min', '外径 60 cm，跑道宽 5 cm；5 分钟')),
    ('light-dark-box', 'lightDark', 'anxiety', 'pose', True, ('45 × 30 cm, light side 2/3', '45 × 30 cm，明室占 2/3')),
    ('novelty-suppressed-feeding', 'noveltySuppressedFeeding', 'anxiety', 'pose', False, ('40 × 40 cm; 10 min cut-off', '40 × 40 cm；截止 10 分钟')),
    ('visual-cliff', 'visualCliff', 'anxiety', 'pose', False, ('60 × 40 cm, centre board 20 % of the length', '60 × 40 cm，中间板占长度的 20 %')),
    ('marble-burying', 'marbleBurying', 'anxiety', 'pose', False, ('40 × 25 cm cage, 4 × 5 marbles', '40 × 25 cm 笼子，4 × 5 颗珠子')),
    ('novel-object-recognition', 'novelObject', 'memory', 'pose', True, ('40 × 40 cm, object radius 2.5 cm', '40 × 40 cm，物体半径 2.5 cm')),
    ('barnes-maze', 'barnesMaze', 'memory', 'pose', True, ('92 cm platform, 20 holes', '92 cm 平台，20 个洞')),
    ('water-maze', 'waterMaze', 'memory', 'pose', True, ('120 cm pool, 10 cm platform; 60 s trials', '120 cm 水池，10 cm 平台；每次 60 秒')),
    ('passive-avoidance', 'passiveAvoidance', 'memory', 'pose', False, ('40 × 20 cm, equal compartments; 300 s cut-off', '40 × 20 cm，两室等大；截止 300 秒')),
    ('step-down', 'stepDown', 'memory', 'pose', False, ('25 × 25 cm box, 7 × 7 cm platform', '25 × 25 cm 箱，7 × 7 cm 平台')),
    ('place-preference', 'placePreference', 'memory', 'pose', True, ('50 × 25 cm, divider at the middle', '50 × 25 cm，隔板在中间')),
    ('y-maze', 'yMaze', 'memory', 'pose', True, ('arms 35 × 5 cm', '臂长 35 cm、宽 5 cm')),
    ('t-maze', 'tMaze', 'memory', 'pose', True, ('arms 30 × 8 cm', '臂长 30 cm、宽 8 cm')),
    ('fear-conditioning', 'fearConditioning', 'memory', 'pose', True, ('30 × 24 cm chamber', '30 × 24 cm 箱')),
    ('looming-escape', 'looming', 'memory', 'pose', False, ('48 × 48 cm with a shelter', '48 × 48 cm，带庇护所')),
    ('platform-avoidance', 'platformAvoidance', 'memory', 'pose', False, ('30 × 25 cm, 10 × 10 cm platform', '30 × 25 cm，10 × 10 cm 平台')),
    ('rotation', 'rotation', 'motor', 'pose', False, ('30 cm bowl; 5-min bins', '30 cm 圆桶；按 5 分钟分段')),
    ('pose-only', 'poseOnly', 'general', 'pose', False, ('any arena', '任意场地')),
]
SLUG = {k: s for s, k, *_ in T}

EX = {
 'open-field': ("In this simulated 10-minute session the mouse travels {distance_m} m and spends {centre_pct} % of the time in the centre, entering it {centre_entries} times.",
                "这段 10 分钟的模拟实验中，小鼠走了 {distance_m} m，{centre_pct} % 的时间在中央区，进入中央区 {centre_entries} 次。"),
 'elevated-plus-maze': ("Open-arm time is {open_pct} % of the time on the arms ({t_open} s open, {t_closed} s closed); {open_entries} of {entries_total} arm entries are into an open arm, and there are {head_dips} head dips over the open-arm edges.",
                        "开放臂时间占臂上时间的 {open_pct} %（开放臂 {t_open} s，闭合臂 {t_closed} s）；{entries_total} 次进臂中有 {open_entries} 次进入开放臂，开放臂边缘头探 {head_dips} 次。"),
 'elevated-zero-maze': ("The mouse spends {open_pct} % of the 5 minutes on the open segments, with {dips_outer} head dips over the outer edge and {dips_inner} over the inner edge.",
                        "5 分钟中有 {open_pct} % 的时间在开放段，外缘头探 {dips_outer} 次，内缘 {dips_inner} 次。"),
 'light-dark-box': ("The mouse enters the dark side after {latency_dark} s and spends {light_pct} % of the time on the light side, with {transitions} crossings and {head_pokes} head pokes from the dark side into the light.",
                    "小鼠 {latency_dark} s 后首次进入暗室，{light_pct} % 的时间在明室，穿梭 {transitions} 次，从暗室向明室探头 {head_pokes} 次。"),
 'novelty-suppressed-feeding': ("The nose first reaches the food zone after {first_approach_s} s and returns {approaches} times in all. The first stretch that meets the candidate-feeding rule starts at {candidate_s} s; in the review you confirm the first bite there.",
                                "鼻尖 {first_approach_s} s 时首次到达食物区，共接近 {approaches} 次。第一段符合候选进食规则的时间从 {candidate_s} s 开始，在回看中在这里确认首次进食。"),
 'visual-cliff': ("The first choice is the shallow side. Over 10 minutes the mouse spends {shallow_pct} % of the time on the shallow side, {board_pct} % on the centre board and {deep_pct} % on the deep side, with {edge_dips} head dips over the deep edge.",
                  "首次选择浅侧。10 分钟中 {shallow_pct} % 的时间在浅侧，{board_pct} % 在中间板，{deep_pct} % 在深侧；向深侧边缘探头 {edge_dips} 次。"),
 'marble-burying': ("After 30 minutes {buried} of the 20 marbles count as buried (at least two-thirds covered); {half} are at least half covered.",
                    "30 分钟后 20 颗珠子中有 {buried} 颗算作埋住（至少盖住 2/3），{half} 颗至少盖住一半。"),
 'three-chamber': ("The mouse investigates the stranger’s cup for {inv_stranger_s} s and the empty cup for {inv_empty_s} s, a social preference index of {index}. Chamber times are {chamber_stranger_s} s (stranger side), {chamber_centre_s} s (centre) and {chamber_empty_s} s (empty-cup side).",
                   "小鼠嗅探陌生鼠杯子 {inv_stranger_s} s、空杯 {inv_empty_s} s，社交指数 {index}。三个箱室的停留时间分别是 {chamber_stranger_s} s（陌生鼠侧）、{chamber_centre_s} s（中间）和 {chamber_empty_s} s（空杯侧）。"),
 'social-interaction': ("Interaction-zone time rises from {iz_no} s without a target to {iz_target} s with one, an SI ratio of {si_ratio}; corner time falls from {corner_no} s to {corner_target} s.",
                        "互动区时间从无目标时的 {iz_no} s 增加到有目标时的 {iz_target} s，SI 比值 {si_ratio}；角落区时间从 {corner_no} s 降到 {corner_target} s。"),
 'dyadic-social': ("Over 5 minutes the pair spends {nose_nose_s} s nose to nose. A sniffs B’s anogenital region for {ag_ab_s} s and B sniffs A’s for {ag_ba_s} s; A follows B for {follow_ab_s} s and B follows A for {follow_ba_s} s. The mean distance between them is {mean_dist} cm.",
                   "5 分钟内两只鼠鼻对鼻 {nose_nose_s} s；A 嗅 B 的肛周 {ag_ab_s} s，B 嗅 A 的 {ag_ba_s} s；A 跟随 B {follow_ab_s} s，B 跟随 A {follow_ba_s} s。平均间距 {mean_dist} cm。"),
 'resident-intruder': ("The first attack comes {attack_latency_s} s after the intruder is put in. Over the next four minutes there are {attack_bouts} attack bouts ({attack_s} s in all), {chase_s} s of following or chasing and {sniff_s} s of anogenital sniffing. (The figure uses a simplified version of the attack rule.)",
                       "入侵者放入后 {attack_latency_s} s 出现首次攻击。之后 4 分钟内攻击 {attack_bouts} 次（共 {attack_s} s），跟随或追逐 {chase_s} s，肛周嗅探 {sniff_s} s。（图中用的是简化版攻击规则。）"),
 'head-direction': ("Every 6° bin is visited for at least a second (coverage {coverage_pct} %), and the occupancy mean vector length is {mvl}: the mouse sampled all directions nearly evenly, which is what normalising a tuning curve needs.",
                    "每个 6° 区间都停留了至少 1 秒（覆盖 {coverage_pct} %），停留分布的平均向量长度为 {mvl}：各个方向几乎均匀采样，正好满足调谐曲线归一化的需要。"),
 'spatial-exploration': ("Coverage reaches {coverage_5min} % of the 2.5 cm bins after 5 minutes and {coverage_pct} % after 20. The mouse moves faster than 2 cm/s for {moving_pct} % of the time and covers {distance_m} m.",
                         "5 分钟时覆盖了 {coverage_5min} % 的 2.5 cm 网格，20 分钟时 {coverage_pct} %。{moving_pct} % 的时间速度超过 2 cm/s，共走了 {distance_m} m。"),
 'novel-object-recognition': ("Over 10 minutes the mouse investigates the novel object for {novel_s} s and the familiar one for {familiar_s} s: DI {di}, RI {ri} %. Total investigation reaches 20 s at {t20_s} s, where DI is {di20}.",
                              "10 分钟内小鼠探索新物体 {novel_s} s、熟悉物体 {familiar_s} s：DI {di}，RI {ri} %。累计探索在 {t20_s} s 时达到 20 s，此时 DI 为 {di20}。"),
 'barnes-maze': ("Mean latency to the escape hole falls from {day1_latency} s on day 1 to {day4_latency} s on day 4, and errors before finding it from {day1_errors} to {day4_errors}.",
                 "到达逃生洞的平均潜伏期从第 1 天的 {day1_latency} s 降到第 4 天的 {day4_latency} s，找到之前的错误次数从 {day1_errors} 降到 {day4_errors}。"),
 'water-maze': ("In the 60-second probe the mouse spends {target_pct} % of the time in the target quadrant ({opposite_pct} % in the opposite one), crosses the former platform zone {crossings} times and stays {proximity_cm} cm from it on average.",
                "60 秒探查测试中，小鼠 {target_pct} % 的时间在目标象限（对侧象限 {opposite_pct} %），穿越原平台区 {crossings} 次，平均距离 {proximity_cm} cm。"),
 'y-maze': ("Of {entries} arm entries, {alternations} of the {triplets} overlapping triplets visit three different arms: {alternation_pct} % alternation. Twice the nose entered an arm and the body turned back.",
            "{entries} 次进臂中，{triplets} 组相邻三次进臂里有 {alternations} 组是三个不同的臂：自发交替 {alternation_pct} %。另有 2 次鼻尖进了臂、身体却转回。"),
 't-maze': ("{vte} of {trials} passes have zIdPhi ≥ 0.5 and are classed as VTE; their mean IdPhi is {idphi_vte}°, against {idphi_direct}° for direct passes.",
            "{trials} 次经过中有 {vte} 次 zIdPhi ≥ 0.5，判为 VTE；它们的平均 IdPhi 为 {idphi_vte}°，直接通过时为 {idphi_direct}°。"),
 'place-preference': ("Paired-side time rises from {pre_mean_s} s in the pre-test to {post_mean_s} s in the post-test (mean of {n} mice): a CPP score of +{cpp_score_s} s.",
                      "配对侧时间从前测的 {pre_mean_s} s 增加到后测的 {post_mean_s} s（{n} 只均值）：CPP 分数 +{cpp_score_s} s。"),
 'passive-avoidance': ("In training the median latency to enter the dark side is {median_train_s} s. On the test day {censored_test} of {n} mice are still on the light side at the 300 s cut-off; they are kept as censored values, not dropped.",
                       "训练时进入暗室的中位潜伏期为 {median_train_s} s。测试日 {n} 只中有 {censored_test} 只到 300 s 截止时仍在明室；它们作为删失值保留，而不是被剔除。"),
 'step-down': ("Median step-down latency is {median_train_s} s in training; in the test {censored_test} of {n} mice stay on the platform until the 180 s cut-off. The example test shows {edge_dips} head dips over the platform edge.",
               "训练时中位跳下潜伏期为 {median_train_s} s；测试时 {n} 只中有 {censored_test} 只在平台上待到 180 s 截止。示例测试中有 {edge_dips} 次平台边缘探头。"),
 'fear-conditioning': ("Freezing is {pre_pct} % before the first CS, {cs1} %, {cs2} % and {cs3} % during the three CSs, and {iti_pct} % between them.",
                       "冻结比例：首个 CS 前 {pre_pct} %，三个 CS 期间分别为 {cs1} %、{cs2} % 和 {cs3} %，CS 之间 {iti_pct} %。"),
 'looming-escape': ("{escapes} of {trials} stimuli trigger an escape to the shelter, with a median response latency of {median_latency_s} s; one trial ends in freezing instead.",
                    "{trials} 次刺激中有 {escapes} 次逃回庇护所，反应潜伏期中位数 {median_latency_s} s；另一次以冻结结束。"),
 'platform-avoidance': ("Time on the platform during the tone rises from {tone_pct_first} % in trial 1 to {tone_pct_last} % in trial 9 as the mouse learns to avoid the shock at the end of the tone.",
                        "随着小鼠学会回避声音结束时的电击，声音期间在平台上的时间从第 1 次的 {tone_pct_first} % 增加到第 9 次的 {tone_pct_last} %。"),
 'rotation': ("A left-lesioned mouse makes {ipsi} ipsilateral and {contra} contralateral full turns in 60 minutes: net {net} turns, {per_min} per minute, highest in minutes {peak_bin}.",
              "一只左侧损毁的小鼠 60 分钟内同侧转 {ipsi} 圈、对侧 {contra} 圈：净 {net} 圈，每分钟 {per_min} 圈，第 {peak_bin} 分钟最多。"),
 'pose-only': ("Each frame gives six keypoints with a confidence each; the export adds smoothed coordinates, speed, head direction, body heading, the head–body angle and body length.",
               "每帧 6 个关键点，各带置信度；导出时再加上平滑后的坐标、速度、头朝向、身体朝向、头–身夹角和体长。"),
}

BRIT = [(r'\bcenters\b', 'centres'), (r'\bcenter\b', 'centre'), (r'\bCenter\b', 'Centre'), (r'\bcentered\b', 'centred'),
        (r'\bbehavior', 'behaviour'), (r'\bBehavior', 'Behaviour'), (r'\bcolor', 'colour'), (r'\banalyze', 'analyse'),
        (r'\banalyzed', 'analysed'), (r'\bAnalyze', 'Analyse'), (r'\bgray\b', 'grey'), (r'\bcentimeter', 'centimetre'),
        (r'\bnormalization', 'normalisation'), (r'\boptimiz', 'optimis'), (r'\bfavor', 'favour'), (r'\bmeters?\b', 'metres')]


def brit(s):
    for a, b in BRIT:
        s = re.sub(a, b, s)
    return s


def esc(s):
    return s.replace('|', '\\|')


def fmt(slug, lang):
    v = dict(vals.get(slug, {}))
    if slug == 'elevated-plus-maze':
        v['entries_total'] = v['open_entries'] + v['closed_entries']
    if slug == 'rotation':
        v['peak_bin'] = v['peak_bin']
    for k, x in list(v.items()):
        if isinstance(x, float):
            v[k] = (f'{x:.2f}' if abs(x) < 1 and k not in ('median_latency_s',) else f'{x:g}') if k in ('index', 'si_ratio', 'mvl', 'di', 'di20', 'median_latency_s') else f'{x:g}'
    if slug == 'head-direction':
        v['mvl'] = f"{vals[slug]['mvl']:.2f}"
        v['coverage_pct'] = f"{vals[slug]['coverage_pct']:.0f}"
    if slug == 'barnes-maze':
        for k in v:
            v[k] = f'{float(v[k]):.0f}' if 'latency' in k else v[k]
    return EX[slug][0 if lang == 'en' else 1].format(**v)


def title(key, lang):
    return EN_TITLE[key] if lang == 'en' else ZH_TITLE[key]


def page(slug, key, cg, method, classic, arena, lang):
    c = cat[key]
    en = lang == 'en'
    L = lambda e, z: e if en else z
    cg_name = [x for x in CATS if x[0] == cg][0][1 if en else 2]
    ttl = title(key, lang)
    tagline = brit(c['tagline_en']) if en else c['tagline']
    desc = (f"{ttl} in RodentFlow: {tagline}. Design, why keypoints help, measures, a simulated example and references."
            if en else f"RodentFlow 的{ttl}：{tagline}。实验设计、为什么用关键点、测量指标、模拟示例与参考文献。")
    out = ['---', f'title: "{ttl}"', f'description: "{desc}"', '---', '']
    out.append(f'<p class="rf-eyebrow">{L("TASK", "实验范式")} · {cg_name.upper() if en else cg_name}</p>\n')
    out.append(f'# {ttl}\n')
    tags = [METHOD[method][0 if en else 1]]
    if classic:
        tags.append(L('Also: classic centroid', '也可用质心法'))
    tags.append(L(f'Default arena: {arena[0]}', f'默认场地：{arena[1]}'))
    out.append('<div class="rf-tags">' + ''.join(f'<span>{t}</span>' for t in tags) + '</div>\n')
    out.append(f'**{tagline}**\n')
    out.append((brit(c['summary_en']) if en else c['summary']) + '\n')
    # example
    out.append(f'## {L("Simulated example", "模拟示例")} {{#example}}\n')
    alt = L(f'Simulated {ttl.lower()} session: tracks and measures', f'{ttl}模拟实验：轨迹与指标')
    out.append('<figure>\n')
    out.append(f'![{alt}](/img/tasks/{slug}.{lang}.png)\n')
    out.append(f'<figcaption>{fmt(slug, lang)}' + L(' ', '') +
               L('Simulated data, made to show how the measures are defined; not a result.', '模拟数据，用来说明指标的定义，不是实验结果。') +
               '</figcaption>')
    out.append('</figure>\n')
    # why keypoints
    out.append(f'## {L("Why keypoints", "为什么用关键点")} {{#why}}\n')
    out.append((brit(c['whyPose_en']) if en else c['whyPose']) + '\n')
    # measures
    out.append(f'## {L("What RodentFlow measures", "测量指标")} {{#measures}}\n')
    out.append(L('| Measure | Definition |', '| 指标 | 定义 |'))
    out.append('|---|---|')
    for m in c['measures']:
        if en:
            out.append(f"| **{esc(brit(m['name_en']))}** | {esc(brit(m['def_en']))} |")
        else:
            out.append(f"| **{esc(m['name_zh'])}** | {esc(m['def_zh'])} |")
    out.append('')
    out.append(L('Thresholds are defaults and can be changed in the analysis parameters; the values used are saved with each session and written into the Methods text.',
                 '阈值都是默认值，可以在分析参数里修改；每次分析实际用的数值随结果保存，并写进方法学文字。') + '\n')
    # setup
    out.append(f'## {L("Setting up", "设置")} {{#setup}}\n')
    steps = c['setup_en'] if en else c['setup_zh']
    for i, s in enumerate(steps, 1):
        s = brit(s).strip() if en else s.strip()
        if en and not s.endswith(('.', ')')):
            s += '.'
        if not en and not s.endswith(('。', '）')):
            s += '。'
        out.append(f'{i}. {s}')
    out.append('')
    out.append(L('The general steps (choose the task, calibrate, track, review, export) are the same for every task: see [Analysing a video](../guide/video-analysis.md).',
                 '各范式通用的步骤（选范式、标定、追踪、回看、导出）见[分析一段视频](../guide/video-analysis.md)。') + '\n')
    if classic:
        out.append(f'## {L("Classic centroid version", "质心法版本")} {{#classic}}\n')
        out.append(L('This test can also be analysed with the **classic centroid** method, the tracker of RodentFlow 1.x: background subtraction and the body centroid at 10 Hz, with no model. It gives the zone, path and time measures; measures that need the nose or head (investigation, head dips, head direction) come from the pose version. See [Classic centroid](../guide/video-analysis.md#classic).',
                     '这个测试也可以用**质心法**分析，也就是 RodentFlow 1.x 的追踪方法：背景减除、10 Hz 的身体质心，不用模型。它给出区域、路径和时间类指标；需要鼻尖或头部的指标（嗅探、头探、头朝向）来自姿态版。见[质心法](../guide/video-analysis.md#classic)。') + '\n')
    # references
    out.append(f'## {L("References", "参考文献")} {{#references}}\n')
    for r in c['refs']:
        cit = r['citation'].strip()
        if r.get('doi'):
            out.append(f"- {cit} [doi:{r['doi']}](https://doi.org/{r['doi']})")
        else:
            out.append(f'- {cit}')
    out.append('')
    # related
    rel = [s for s, k, g, *_ in T if g == cg and s != slug]
    if rel:
        out.append(f'## {L("Related tasks", "同类范式")} {{#related}}\n')
        out.append(' · '.join(f'[{title(k, lang)}](./{s}.md)' for s, k, g, *_ in T if s in rel) + '\n')
    return '\n'.join(out)


def index(lang):
    en = lang == 'en'
    L = lambda e, z: e if en else z
    DOTS = {'pose': '<i class="rf-dot" style="--c:#12B89A"></i>', 'pose2': '<i class="rf-dot rf-ab"></i>',
            'multi': '<i class="rf-dot" style="--c:#9A6BFF"></i>', 'classic': '<i class="rf-dot" style="--c:#F2B441"></i>'}
    MN = {'pose': L('One animal', '单鼠'), 'pose2': L('Two animals', '双鼠'), 'multi': L('Multi-chamber', '多格'), 'classic': L('Centroid', '质心')}
    nref = sum(len(cat[k]['refs']) for _, k, *_ in T) + 3
    out = ['---', f'title: "{L("Tasks", "实验范式")}"',
           f'description: "{L("The 27 video tasks in RodentFlow: design, why keypoints help, measures, a simulated example and references for each.", "RodentFlow 的 27 个视频范式：每个范式的设计、为什么用关键点、测量指标、模拟示例与参考文献。")}"',
           'aside: false', '---', '']
    out.append(f'<p class="rf-eyebrow">{L("TASK LIBRARY", "范式库")}</p>\n')
    out.append(f'# {L("27 tasks, each explained", "27 个范式，逐一讲透")}\n')
    out.append('<div class="rf-taskhero">\n')
    out.append('<p class="rf-taskhero-lede">' + L(
        'Pick a test to see exactly how RodentFlow scores it: the design, why keypoints measure it better than a body centroid, the rule behind every measure, a simulated example and the papers it is built on.',
        '选一个测试，看 RodentFlow 到底怎样评分：实验设计、为什么关键点比身体质心测得更准、每个指标背后的规则、一个模拟示例，以及它所依据的文献。') + '</p>')
    out.append('<div class="rf-stats">'
               f'<span><b>27</b>{L("tasks", "个范式")}</span>'
               f'<span><b>{sum(len(cat[k]["measures"]) for _, k, *_ in T) + 5}</b>{L("defined measures", "个有定义的指标")}</span>'
               f'<span><b>{nref}</b>{L("references", "篇参考文献")}</span>'
               f'<span><b>4</b>{L("pose models", "个姿态模型")}</span></div>')
    chips = []
    for cg, cen, czh in CATS:
        n = sum(1 for s, k, g, *_ in T if g == cg) + (1 if cg == 'motor' else 0)
        chips.append(f'<a href="#{cg}">{cen if en else czh}<span>{n}</span></a>')
    out.append('<nav class="rf-catchips" aria-label="' + L('Areas', '领域') + '">' + ''.join(chips) + '</nav>')
    out.append('<p class="rf-legend">' + ''.join(f'<span>{DOTS[m]}{MN[m]}</span>' for m in ('pose', 'pose2', 'classic', 'multi')) + '</p>')
    out.append('\n</div>\n')
    out.append(L('Every task runs on iPhone, iPad and Mac. The task decides how many animals are tracked; for one-animal tasks you choose a dark or white coat, for two-animal tasks two dark mice or one dark and one white ([Models](../models.md#coat)). The example on each page is a **simulated session**: it shows what each measure means, not data.',
                 '所有范式在 iPhone、iPad 和 Mac 上都能用。范式决定追踪几只动物；单鼠范式可选深色或白色毛色，双鼠范式可选两只深色或一黑一白（[模型](../models.md#coat)）。每页的示例都是**模拟实验**，用来说明指标的含义，不是实验数据。') + '\n')

    def card(slug, name, tag, methods):
        meth = ''.join(f'<span>{DOTS[m]}{MN[m]}</span>' for m in methods)
        return (f'<a href="./{slug}.html"><span class="rf-thumb"><img src="/img/tasks/thumbs/{slug}.{lang}.png" alt="" loading="lazy"></span>'
                f'<strong>{name}</strong><span class="rf-tl">{tag}</span><span class="rf-meth">{meth}</span></a>')
    for cg, cen, czh in CATS:
        out.append(f'## {cen if en else czh} {{#{cg}}}\n')
        out.append('<div class="rf-taskgrid">')
        for s, k, g, method, classic, _ in T:
            if g != cg:
                continue
            tl = brit(cat[k]['tagline_en']) if en else cat[k]['tagline']
            out.append(card(s, title(k, lang), tl, [method] + (['classic'] if classic else [])))
        if cg == 'motor':
            out.append(card('tail-suspension', L('Tail suspension, multi-chamber', '多格悬尾'),
                            L('Several mice in one recording · immobility in minutes 2–6', '一段录像里多只小鼠 · 第 2–6 分钟不动时间'), ['multi']))
        out.append('</div>\n')
    out.append(f'## {L("Results without video", "不用视频的结果")} {{#manual}}\n')
    out.append(L('Marble burying, sucrose preference, beam walking, gait, two-armed bandit and your own measures can also be entered by hand or imported from a table, on iPhone and iPad. These results take part in group comparisons like any other. See [Manual entry & importing tables](../guide/manual-and-import.md).',
                 '埋珠、糖水偏好、平衡木、步态、双臂老虎机和自定义指标，也可以在 iPhone 和 iPad 上手动录入或从表格导入，和其他结果一样参与组间比较。见[手动录入与导入表格](../guide/manual-and-import.md)。') + '\n')
    return '\n'.join(out)


def main():
    for lang in ('en', 'zh'):
        d = os.path.join(ROOT, 'tasks') if lang == 'en' else os.path.join(ROOT, 'zh', 'tasks')
        os.makedirs(d, exist_ok=True)
        for slug, key, cg, method, classic, arena in T:
            open(os.path.join(d, slug + '.md'), 'w').write(page(slug, key, cg, method, classic, arena, lang))
        open(os.path.join(d, 'index.md'), 'w').write(index(lang))
    print('ok', len(T), 'tasks')


if __name__ == '__main__':
    main()


def reading(lang):
    en = lang == 'en'
    L = lambda e, z: e if en else z
    out = ['---', f'title: "{L("Further reading", "延伸阅读")}"',
           f'description: "{L("The papers behind every RodentFlow task, and tools and guidelines for behavioural studies.", "RodentFlow 每个范式背后的文献，以及行为研究的工具和指南。")}"', '---', '']
    out.append(f'# {L("Further reading", "延伸阅读")}\n')
    out.append(L('The papers each task is built on, grouped as in the [Tasks](../tasks/) page. Every task page lists them with what they are used for.',
                 '每个范式所依据的文献，分组与[实验范式](../tasks/)页面一致。每个范式页面也列出了这些文献。') + '\n')
    for cg, cen, czh in CATS:
        out.append(f'## {cen if en else czh} {{#{cg}}}\n')
        for s, k, g, *_ in T:
            if g != cg:
                continue
            out.append(f'### [{title(k, lang)}](../tasks/{s}.md)\n')
            for r in cat[k]['refs']:
                cit = r['citation'].strip()
                out.append(f"- {cit}" + (f" [doi:{r['doi']}](https://doi.org/{r['doi']})" if r.get('doi') else ''))
            out.append('')
        if cg == 'motor':
            out.append(f'### [{L("Tail suspension, multi-chamber", "多格悬尾")}](../tasks/tail-suspension.md)\n')
            out.append('- Steru L, Chermat R, Thierry B, Simon P (1985) The tail suspension test: a new method for screening antidepressants in mice. Psychopharmacology 85:367–370. [doi:10.1007/BF00428203](https://doi.org/10.1007/BF00428203)')
            out.append('- Can A, Dao DT, Terrillion CE, Piantadosi SC, Bhat S, Gould TD (2012) The tail suspension test. J Vis Exp 59:e3769. [doi:10.3791/3769](https://doi.org/10.3791/3769)')
            out.append('- Commons KG, Cholanians AB, Babb JA, Ehlinger DG (2017) The rodent forced swim test measures stress-coping strategy, not depression-like behavior. ACS Chem Neurosci 8:955–960. [doi:10.1021/acschemneuro.7b00042](https://doi.org/10.1021/acschemneuro.7b00042)\n')
    out.append(f'## {L("Design, reporting and tools", "设计、报告与工具")} {{#tools}}\n')
    out.append(L('- [ARRIVE 2.0 guidelines](https://arriveguidelines.org/) for reporting animal research.\n'
                 '- Lazic SE, Clarke-Williams CJ, Munafò MR (2018) What exactly is ‘N’ in cell culture and animal experiments? PLOS Biol 16:e2005282. [doi:10.1371/journal.pbio.2005282](https://doi.org/10.1371/journal.pbio.2005282)\n'
                 '- [BORIS](https://www.boris.unito.it/): free software for scoring behaviour by hand; RodentFlow exports BORIS-style event tables.\n'
                 '- [DeepLabCut](https://deeplabcut.github.io/DeepLabCut/), [SimBA](https://github.com/sgoldenlab/simba) and [keypoint-MoSeq](https://keypoint-moseq.readthedocs.io/): further analysis of the exported keypoints.\n'
                 '- [HandBrake](https://handbrake.fr/): free video converter.',
                 '- [ARRIVE 2.0 指南](https://arriveguidelines.org/)：动物研究的报告规范。\n'
                 '- Lazic SE, Clarke-Williams CJ, Munafò MR (2018) What exactly is ‘N’ in cell culture and animal experiments? PLOS Biol 16:e2005282. [doi:10.1371/journal.pbio.2005282](https://doi.org/10.1371/journal.pbio.2005282)\n'
                 '- [BORIS](https://www.boris.unito.it/)：免费的人工行为评分软件；RodentFlow 可导出 BORIS 形式的事件表。\n'
                 '- [DeepLabCut](https://deeplabcut.github.io/DeepLabCut/)、[SimBA](https://github.com/sgoldenlab/simba) 和 [keypoint-MoSeq](https://keypoint-moseq.readthedocs.io/)：对导出关键点的进一步分析。\n'
                 '- [HandBrake](https://handbrake.fr/)：免费的视频转换工具。') + '\n')
    out.append(L('How the pose models were made, and how to cite them, is in the [tutorials](../tutorials/) and [How to cite](../tutorials/citations.md).',
                 '姿态模型如何制作、如何引用，见[教程](../tutorials/)和[如何引用](../tutorials/citations.md)。') + '\n')
    return '\n'.join(out)


if __name__ == '__main__' and len(sys.argv) > 4 and sys.argv[4] == 'reading':
    for lang in ('en', 'zh'):
        d = os.path.join(ROOT, 'reference') if lang == 'en' else os.path.join(ROOT, 'zh', 'reference')
        open(os.path.join(d, 'reading.md'), 'w').write(reading(lang))
    print('reading ok')
