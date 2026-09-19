from __future__ import annotations
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
errors=[]
warnings=[]

required=[ROOT/'project.godot', ROOT/'main.tscn', ROOT/'scripts/mobile/mobile_game.gd', ROOT/'scripts/mobile/mobile_card.gd', ROOT/'scripts/mobile/game_content.gd', ROOT/'scripts/mobile/mobile_audio.gd', ROOT/'scripts/mobile/mobile_fx.gd', ROOT/'scripts/mobile/tactical_combat.gd', ROOT/'scripts/mobile/journey_system.gd', ROOT/'scripts/mobile/contract_system.gd', ROOT/'scripts/mobile/relationship_system.gd', ROOT/'export_presets.cfg']
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
main=(ROOT/'scripts/mobile/mobile_game.gd').read_text('utf-8')
for expected in ['_reincarnate','_awaken_qi','_end_life','_render_map','_render_inventory','_render_people']:
    if f'func {expected}' not in main: errors.append(f'mobile game missing {expected}')
scene=(ROOT/'main.tscn').read_text('utf-8')
if 'type="Node3D"' in scene: errors.append('main scene must not use Node3D in mobile rebuild')
if 'scripts/mobile/mobile_game.gd' not in scene: errors.append('main scene is not wired to mobile_game.gd')
project=(ROOT/'project.godot').read_text('utf-8')
if 'window/size/viewport_width=720' not in project or 'window/size/viewport_height=1280' not in project:
    errors.append('mobile rebuild must use 720x1280 portrait viewport')
for obsolete in ['scripts/ui/mobile_controls.gd','scripts/ui/virtual_joystick.gd','scripts/player/player_controller.gd']:
    if (ROOT/obsolete).exists(): errors.append(f'obsolete movement runtime still present: {obsolete}')

content_file=(ROOT/'scripts/mobile/game_content.gd').read_text('utf-8')
if content_file.count('"number":') != 5:
    errors.append('V0.4 must define exactly five macro phases')
if content_file.count('"phase":') < 40:
    errors.append('V0.4 must define at least forty locations across the five phases')
for bg in [
    'phase_1_vale_mortal.svg','phase_2_qinghe.svg','phase_3_ceu_velado.svg',
    'phase_4_terras_ancestrais.svg','phase_5_nove_ceus.svg'
]:
    if not (ROOT/'assets/mobile'/bg).exists():
        errors.append(f'missing phase background: {bg}')
audio=(ROOT/'scripts/mobile/mobile_audio.gd').read_text('utf-8')
for expected in ['play_phase_theme','play_sfx','THEME_NOTES']:
    if expected not in audio:
        errors.append(f'mobile audio missing {expected}')


print(f'Validated {sum(1 for _ in ROOT.rglob("*.gd"))} GDScript files and {sum(1 for p in ROOT.rglob("*") if p.is_file())} total files.')
if warnings:
    print('WARNINGS:')
    for w in warnings: print(' -',w)
if errors:
    print('ERRORS:')
    for e in errors: print(' -',e)
    sys.exit(1)
print('Static project validation: PASS')

gameplay=(ROOT/'scripts/mobile/mobile_game.gd').read_text('utf-8')
for expected in ['_start_tactical_combat','_render_battle_overlay','_start_journey','_render_journey_overlay','_render_contract_board','_person_action']:
    if f'func {expected}' not in gameplay:
        errors.append(f'V0.5 gameplay missing {expected}')
