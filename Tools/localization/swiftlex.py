"""Swift string-literal lexer with a masked copy of the source (comments and literal bodies blanked)
and a context analyzer that finds the enclosing call / argument label of every literal."""
import re

def lex(src):
    """Returns (lits, masked). lits: list of dict(start,end,body,interp,line,multiline,raw).
    start/end are the positions of the opening/closing quote characters (end exclusive)."""
    n=len(src); i=0; line=1
    mask=list(src)
    lits=[]
    def blank(a,b):
        for k in range(a,b):
            if mask[k]!='\n': mask[k]=' '
    while i<n:
        c=src[i]
        if c=='\n': line+=1; i+=1; continue
        if src.startswith('//',i):
            j=src.find('\n',i); j = n if j<0 else j; blank(i,j); i=j; continue
        if src.startswith('/*',i):
            j=src.find('*/',i+2)+2; blank(i,j); line+=src[i:j].count('\n'); i=j; continue
        if c=='#' and src.startswith('#"',i):
            j=src.find('"#',i+2); lits.append(dict(start=i,end=j+2,body=src[i+2:j],interp=False,line=line,multiline=False,raw=True))
            blank(i+2,j); line+=src[i:j+2].count('\n'); i=j+2; continue
        if src.startswith('"""',i):
            j=i+3; spans=[]
            while not src.startswith('"""',j):
                if src.startswith('\\(',j):
                    k=_skip_interp(src,j+2); spans.append((j,k)); j=k; continue
                if src[j]=='\\': j+=2; continue
                j+=1
            lits.append(dict(start=i,end=j+3,body=src[i+3:j],interp=bool(spans),line=line,multiline=True,raw=False,spans=spans))
            blank(i+3,j); line+=src[i:j+3].count('\n'); i=j+3; continue
        if c=='"':
            j=i+1; spans=[]
            while src[j]!='"':
                if src.startswith('\\(',j):
                    k=_skip_interp(src,j+2); spans.append((j,k)); j=k; continue
                if src[j]=='\\': j+=2; continue
                j+=1
            lits.append(dict(start=i,end=j+1,body=src[i+1:j],interp=bool(spans),line=line,multiline=False,raw=False,spans=spans))
            blank(i+1,j); i=j+1; continue
        i+=1
    return lits,''.join(mask)

def _skip_interp(src,j):
    depth=1
    while depth>0:
        ch=src[j]
        if ch=='(': depth+=1
        elif ch==')': depth-=1
        elif ch=='"':
            if src.startswith('"""',j):
                j=src.find('"""',j+3)+3; continue
            k=j+1
            while src[k]!='"':
                if src.startswith('\\(',k): k=_skip_interp(src,k+2); continue
                if src[k]=='\\': k+=2; continue
                k+=1
            j=k+1; continue
        j+=1
    return j

OPEN={')':'(',']':'[','}':'{'}
def context(masked, lit):
    """Find enclosing bracket of literal and describe it."""
    i=lit['start']-1; depth=0
    while i>=0:
        ch=masked[i]
        if ch in ')]}': depth+=1
        elif ch in '([{':
            if depth==0: break
            depth-=1
        i-=1
    if i<0: return dict(kind='top')
    br=masked[i]
    # argument segment: from bracket+1 to literal, split on top-level commas
    seg_start=i+1; d=0; argidx=0
    for k in range(i+1,lit['start']):
        ch=masked[k]
        if ch in '([{': d+=1
        elif ch in ')]}': d-=1
        elif ch==',' and d==0: seg_start=k+1; argidx+=1
    # end of segment
    k=lit['end']; d=0
    while k<len(masked):
        ch=masked[k]
        if ch in '([{': d+=1
        elif ch in ')]}':
            if d==0: break
            d-=1
        elif ch==',' and d==0: break
        k+=1
    seg=masked[seg_start:k]
    m=re.match(r'\s*([A-Za-z_]\w*)\s*:(?!:)',seg)
    label=m.group(1) if m else None
    # ternary or simple?
    if br=='(':
        j=i-1
        while j>=0 and masked[j] in ' \t': j-=1
        e=j+1
        while j>=0 and (masked[j].isalnum() or masked[j] in '_.<>'): j-=1
        callee=masked[j+1:e]
        # strip generic args e.g. Foo<Bar>
        callee=re.sub(r'<.*>$','',callee)
        return dict(kind='call',callee=callee,label=label,seg=seg.strip(),bracket=i,argidx=argidx)
    if br=='[':
        parent=context(masked, dict(start=i,end=i+1))
        return dict(kind='array',label=label,seg=seg.strip(),bracket=i,parent=parent)
    # statement inside { }
    ls=masked.rfind('\n',0,lit['start'])+1
    return dict(kind='stmt',prefix=masked[ls:lit['start']].strip(),bracket=i)
