from __future__ import annotations
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
errors=[]
warnings=[]

required=[ROOT/'project.godot', ROOT/'main.tscn', ROOT/'scripts/main.gd', ROOT/'export_presets.cfg']
for p in required:
    if not p.exists(): errors.append(f'missing required file: {p.relative_to(ROOT)}')

for p in ROOT.rglob('*'):
    if not p.is_file() or p.suffix not in {'.gd','.tscn','.godot','.cfg','.md'}:
        continue
    text=p.read_text('utf-8')
    for ref in re.findall(r'res://[^"\'\s)]+', text):
        ref_clean=ref.rstrip(']}>.,;')
        target=ROOT/ref_clean[6:]
        if not target.exists():
            errors.append(f'{p.relative_to(ROOT)} references missing {ref_clean}')

classes={}
for p in ROOT.rglob('*.gd'):
    text=p.read_text('utf-8')
    m=re.search(r'(?m)^class_name\s+(\w+)', text)
    if m:
        name=m.group(1)
        if name in classes: errors.append(f'duplicate class_name {name}: {classes[name]} and {p.relative_to(ROOT)}')
        classes[name]=p.relative_to(ROOT)
    stack=[]
    pairs={')':'(',']':'[','}':'{'}
    in_string=None; escaped=False
    for lineno,line in enumerate(text.splitlines(),1):
        i=0
        while i < len(line):
            ch=line[i]
            if in_string:
                if escaped: escaped=False
                elif ch=='\\': escaped=True
                elif ch==in_string: in_string=None
            else:
                if ch=='#': break
                if ch in {'"',"'"}: in_string=ch
                elif ch in '([{': stack.append((ch,lineno))
                elif ch in ')]}':
                    if not stack or stack[-1][0]!=pairs[ch]:
                        errors.append(f'{p.relative_to(ROOT)}:{lineno} mismatched {ch}')
                        break
                    stack.pop()
            i+=1
    if stack: errors.append(f'{p.relative_to(ROOT)} unclosed delimiters: {stack[-3:]}')
    if in_string: errors.append(f'{p.relative_to(ROOT)} unclosed string')

birth=(ROOT/'scripts/core/birth_system.gd').read_text('utf-8')
if '"weight": 85' not in birth: warnings.append('mortal baseline is no longer 85%; review rarity design')
if 'QiPotential.MORTAL' not in birth: errors.append('mortal spiritual state missing')
main=(ROOT/'scripts/main.gd').read_text('utf-8')
for expected in ['_reincarnate','on_player_awakened','_on_player_died']:
    if f'func {expected}' not in main: errors.append(f'main missing {expected}')

print(f'Validated {sum(1 for _ in ROOT.rglob("*.gd"))} GDScript files and {sum(1 for p in ROOT.rglob("*") if p.is_file())} total files.')
if warnings:
    print('WARNINGS:')
    for w in warnings: print(' -',w)
if errors:
    print('ERRORS:')
    for e in errors: print(' -',e)
    sys.exit(1)
print('Static project validation: PASS')
