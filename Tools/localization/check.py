#!/usr/bin/env python3
"""Classifies every English-looking string literal in the Swift sources: SUI = SwiftUI literal key,
LOC = loc()/locf() key, COMP = title passed to a component that translates it, IND = key looked up
indirectly (indirect.txt), IGN = not interface text. Anything else is printed for review."""
import sys, os, re, json
HERE=os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0,HERE)
from swiftlex import lex, context

SWIFTUI_FIRST = {'Text','Button','Label','Section','Toggle','Picker','TextField','SecureField','Menu','Link','LabeledContent',
  'Stepper','DatePicker','NavigationLink','ContentUnavailableView','GroupBox','DisclosureGroup','ProgressView','Gauge','ShareLink',
  'LocalizedStringKey','Slider'}
SWIFTUI_MOD = {'.value','.chartXAxisLabel','.chartYAxisLabel','.navigationTitle','.help','.accessibilityLabel','.accessibilityHint','.accessibilityValue','.alert','.confirmationDialog','.badge'}
SWIFTUI_LABELS = {('TextField','prompt'),('.searchable','prompt'),('Text','tableName')}
LOC_FUNCS = {'loc','locf','String.localizedStringWithFormat'}
# custom components that localize the given argument label (None = first unlabeled arg)
COMPONENTS = {}
INDIRECT = set(); NONUI = set()
def load_components():
    p=os.path.join(HERE,'components.json')
    if os.path.exists(p):
        for k,v in json.load(open(p)).items(): COMPONENTS[k]=set(None if x=='_' else x for x in v)
    for fn,S in (('indirect.txt',INDIRECT),('nonui.txt',NONUI)):
        p=os.path.join(HERE,fn)
        if os.path.exists(p):
            for line in open(p):
                line=line.rstrip('\n')
                if not line.strip() or line.startswith('#'): continue
                f,_,t=line.partition('\t')
                S.add((f,t))
load_components()

NONUI_ARGS={}
def load_nonui_args():
    p=os.path.join(HERE,'nonui_args.json')
    if os.path.exists(p):
        for k,v in json.load(open(p)).items(): NONUI_ARGS[k]=set(v)
load_nonui_args()

def nonui_arg(ctx):
    if ctx['kind']!='call': return False
    spec=NONUI_ARGS.get(ctx['callee'].split('.')[-1])
    if not spec: return False
    return (ctx['label'] in spec) or (ctx['label'] is None and ('#%d'%ctx['argidx']) in spec)

def comp_match(ctx):
    if ctx['kind']=='call':
        cal=ctx['callee'].split('.')[-1]
        spec=COMPONENTS.get(cal) or COMPONENTS.get(ctx['callee'])
        if not spec: return False
        lab=ctx['label']
        if lab is not None and lab in spec: return True
        if lab is None and (None in spec and ctx['argidx']==0 or ('#%d'%ctx['argidx']) in spec): return True
        return False
    if ctx['kind']=='array' and ctx.get('parent',{}).get('kind')=='call':
        p=ctx['parent']; cal=p['callee'].split('.')[-1]
        spec=COMPONENTS.get(cal) or COMPONENTS.get(p['callee'])
        if spec and ('[]' in spec or ('[%s]'%(p['label'] or '_')) in spec): return True
    return False

def userish(t):
    s=t.strip()
    if not re.search(r'[A-Za-z]{2,}',s) and not re.fullmatch(r'[A-Za-z]',s): return False
    if re.fullmatch(r'[a-z0-9]+(\.[a-z0-9]+)+',s): return False   # sf symbol / ids
    if re.fullmatch(r'[a-z][a-z0-9_]*',s) and ('_' in s): return False
    if re.fullmatch(r'[a-z][a-zA-Z0-9]*',s) and len(s)>1 and not s.islower(): return False
    if re.fullmatch(r'rf\.[A-Za-z.]+',s): return False
    if re.fullmatch(r'%[^ ]*',s): return False
    return True

def outside_interp_text(lit):
    b=lit['body']; 
    if not lit['interp']: return b
    out=''; pos=lit['start']+(3 if lit['multiline'] else 1); last=0
    for a,e in lit['spans']:
        out+=b[last:a-pos]+' '; last=e-pos
    return out+b[last:]

def pure_arg(seg, masked_seg=None):
    # literal alone, or ternary whose branches are both literals: cond ? "a" : "b"
    s=re.sub(r'^\s*[A-Za-z_]\w*\s*:(?!:)\s*','',seg.strip())
    lit=r'(?:"\s*"|"""[\s\S]*?""")'
    if re.fullmatch(lit,s): return True
    if re.fullmatch(r'[\s\S]*\?\s*'+lit+r'\s*:\s*'+lit,s): return True
    return False

IGNORE_LABELS={'systemImage','icon','id','key','ext','zone','unit','image','systemName','forKey','named','identifier','category','subsystem','withExtension','forResource','ofType'}
IGNORE_CALLEES={'.id','.scrollTo','.onChange','.tag','appendingPathComponent','.appendingPathComponent','temporaryURL','.contains','.hasPrefix','.hasSuffix','.replacingOccurrences','Image','UIImage','Logger','.components','.split','.range','.set','set','out.set','.tag','Locale','DateFormatter','.dateFormat','URL','print','Notification.Name','.appendingPathExtension','.firstIndex','.removeValue','.decode','.encode','.decodeIfPresent','.object','.string','.double','.integer','.bool','UserDefaults','AppStorage','.onReceive','.trimmingCharacters','Selector','fatalError','precondition','assert','assertionFailure','os_log','NSPredicate'}
def ignorable(src_masked, lit, ctx):
    if ctx['kind']=='call':
        cal=ctx['callee']; lab=ctx['label']
        if lab in IGNORE_LABELS: return True
        if cal in IGNORE_CALLEES or cal.split('.')[-1] in {c.lstrip('.') for c in IGNORE_CALLEES if c.startswith('.')}: return True
        if cal.endswith('.contains') or cal.endswith('.appendingPathComponent') or cal.endswith('.hasPrefix'): return True
    if ctx['kind']=='array':
        b=ctx['bracket']; j=b-1
        while j>=0 and src_masked[j]==' ': j-=1
        if j>=0 and (src_masked[j].isalnum() or src_masked[j] in '_)]?!'):
            k=j
            while k>=0 and (src_masked[k].isalnum() or src_masked[k]=='_'): k-=1
            word=src_masked[k+1:j+1]
            if word not in ('return','case','in','where','else','throw','try','await','as','is','default'): return True   # subscript
    return False

def classify(src_masked, lit):
    ctx=context(src_masked, lit)
    if ctx['kind']=='call':
        cal=ctx['callee']; lab=ctx['label']
        if cal.split('.')[-1] in LOC_FUNCS and lab is None and ctx['argidx']==0:
            # the literal must be the whole first argument (not part of an expression)
            return ('LOC' if pure_arg(ctx['seg']) else 'LOC-EXPR'),ctx
        if lab is None and (cal in SWIFTUI_FIRST or cal in SWIFTUI_MOD):
            if lit['interp']: return 'SUI-INTERP',ctx
            return ('SUI' if pure_arg(ctx['seg']) else 'SUI-EXPR'),ctx
        if (cal,lab) in SWIFTUI_LABELS: return ('SUI' if not lit['interp'] else 'SUI-INTERP'),ctx
    if comp_match(ctx):
        if ctx['kind']=='call' and not pure_arg(ctx['seg']): return 'COMP-EXPR',ctx
        return ('COMP' if not lit['interp'] else 'COMP-INTERP'),ctx
    if ignorable(src_masked, lit, ctx) or nonui_arg(ctx): return 'IGN',ctx
    return 'OTHER',ctx

def run(root, files=None, show=('OTHER','SUI-INTERP','SUI-EXPR','COMP-INTERP'), allow=None):
    allow = allow or {}
    res=[]
    for f in sorted(os.listdir(root)):
        if not f.endswith('.swift'): continue
        if files and f not in files: continue
        src=open(os.path.join(root,f)).read()
        lits,masked=lex(src)
        for L in lits:
            if not userish(outside_interp_text(L)): continue
            cls,ctx=classify(masked,L)
            if cls=='SUI-EXPR' and (f,L['body']) in NONUI: cls='IGN'
            if cls=='OTHER':
                if (f,L['body']) in INDIRECT or (f,'*'+L['body']) in INDIRECT: cls='IND'
                elif (f,L['body']) in NONUI or ('*',L['body']) in NONUI or (f,'*') in NONUI: cls='IGN'
            res.append((f,L,cls,ctx))
    return res

if __name__=='__main__':
    import argparse
    ap=argparse.ArgumentParser(); ap.add_argument('root'); ap.add_argument('files',nargs='*'); ap.add_argument('--all',action='store_true'); ap.add_argument('--stats',action='store_true')
    a=ap.parse_args()
    res=run(a.root,a.files or None)
    if a.stats:
        from collections import Counter
        print(Counter(c for _,_,c,_ in res)); sys.exit()
    for f,L,cls,ctx in res:
        if not a.all and cls in ('LOC','SUI','COMP','IGN','IND'): continue
        desc = ctx.get('callee','') + ('('+ (ctx.get('label') or '_') +':)' if ctx['kind']=='call' else '') if ctx['kind']=='call' else ctx['kind']+':'+(ctx.get('prefix','')[-40:] if ctx['kind']=='stmt' else (ctx.get('label') or ''))
        print(f"{f[:-6]}:{L['line']} {cls:11s} {desc:28s} «{L['body'][:120]}»")
