#!/usr/bin/env python3
"""Localization check for RodentFlow.

usage: python3 Tools/localization/check_catalog.py            (from the project folder)

1. Lists string literals that look like interface text but are neither SwiftUI literals, loc()/locf()
   keys, component titles nor reviewed exceptions (indirect.txt / nonui.txt).
2. Lists keys used in code that are missing from RodentFlow/Localizable.xcstrings or lack a
   Simplified Chinese (zh-Hans) translation.
3. Checks that every translation keeps the printf placeholders (%@, %ld, %.1f, %%) of its key, in order.
Exit status 1 if anything needs attention."""
import os, sys, re, json
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from check import run
from extract import collect
root = os.path.abspath(os.path.join(HERE, '..', '..', 'RodentFlow'))
problems = 0
for f, L, cls, ctx in run(root):
    if cls in ('LOC', 'SUI', 'COMP', 'IGN', 'IND'): continue
    if (f, L['body']) in {('ResultDetailView.swift', 's'), ('SetupView.swift', ' (cm)')}: continue
    print(f"REVIEW  {f}:{L['line']} [{cls}] {L['body'][:100]}"); problems += 1
keys = collect(root)
cat = json.load(open(os.path.join(root, 'Localizable.xcstrings')))['strings']
SPEC = re.compile(r'%(?:\d+\$)?(?:\.\d+)?(?:ll|l)?[@dfs]|%%')
for k in sorted(keys):
    zh = cat.get(k, {}).get('localizations', {}).get('zh-Hans', {}).get('stringUnit', {}).get('value')
    if zh is None:
        print(f"MISSING zh-Hans: {k!r}  ({keys[k][0]})"); problems += 1
    elif SPEC.findall(k) != SPEC.findall(zh):
        print(f"PLACEHOLDERS {k!r} → {zh!r}"); problems += 1
print(f"{len(keys)} keys in code, {len(cat)} catalog entries, {problems} problem(s)")
sys.exit(1 if problems else 0)
