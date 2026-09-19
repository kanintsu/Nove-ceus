from __future__ import annotations
from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
errors=[]
warnings=[]

required=[ROOT/'project.godot', ROOT/'main.tscn', ROOT/'scripts/mobile/mobile_game.gd', ROOT/'scripts/mobile/mobile_card.gd', ROOT/'scripts/mobile/game_content.gd', ROOT/'scripts/mobile/mobile_audio.gd', ROOT/'scripts/mobile/mobile_fx.gd', ROOT/'scripts/mobile/tactical_combat.gd', ROOT/'scripts/mobile/journey_system.gd', ROOT/'scripts/mobile/contract_system.gd', ROOT/'scripts/mobile/relationship_system.gd', ROOT/'scripts/mobile/cultivation_session.gd', ROOT/'scripts/mobile/world_event_system.gd', ROOT/'scripts/mobile/sect_mission_system.gd', ROOT/'scripts/mobile/celestial_backdrop.gd', ROOT/'scripts/mobile/nav_tile.gd', ROOT/'scripts/mobile/event_card.gd', ROOT/'scripts/mobile/ornate_separator.gd', ROOT/'scripts/mobile/portrait_medallion.gd', ROOT/'scripts/mobile/cultivation_diagram.gd', ROOT/'scripts/mobile/inventory_tile.gd', ROOT/'scripts/v08/v08_game.gd', ROOT/'scripts/v08/home_screen.gd', ROOT/'scripts/v08/world_map_screen.gd', ROOT/'scripts/v08/cultivation_screen.gd', ROOT/'scripts/v08/realms_screen.gd', ROOT/'scripts/v08/inventory_screen.gd', ROOT/'scripts/v08/people_screen.gd', ROOT/'scripts/v08/base_screen.gd', ROOT/'scripts/v08/missions_screen.gd', ROOT/'scripts/v08/sect_screen.gd', ROOT/'scripts/v08/lifecycle_screen.gd', ROOT/'scripts/v08/legacy_screen.gd', ROOT/'scripts/v08/combat_screen.gd', ROOT/'scripts/v08/more_screen.gd', ROOT/'export_presets.cfg']
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


gameplay=(ROOT/'scripts/mobile/mobile_game.gd').read_text('utf-8')
for expected in ['_start_tactical_combat','_render_battle_overlay','_start_journey','_render_journey_overlay','_render_contract_board','_person_action','_cultivate_mode']:
    if f'func {expected}' not in gameplay:
        errors.append(f'V0.5 gameplay missing {expected}')

events=(ROOT/'scripts/mobile/world_event_system.gd').read_text('utf-8')
if events.count('"type":') < 15:
    errors.append('V0.6 must define at least fifteen world event types')
sect=(ROOT/'scripts/mobile/sect_mission_system.gd').read_text('utf-8')
if sect.count('"title":') < 15:
    errors.append('V0.6 must define at least fifteen sect mission templates')
if 'func _render_world_events' not in gameplay or 'func _render_sect' not in gameplay:
    errors.append('V0.6 world events or sect screen missing')
if 'func _is_phase_unlocked(_phase:int) -> bool:\n\treturn true' not in gameplay:
    errors.append('V0.6 must keep macro phases open instead of hard realm locks')

print(f'Validated {sum(1 for _ in ROOT.rglob("*.gd"))} GDScript files and {sum(1 for p in ROOT.rglob("*") if p.is_file())} total files.')
if warnings:
    print('WARNINGS:')
    for w in warnings: print(' -',w)
if errors:
    print('ERRORS:')
    for e in errors: print(' -',e)
    sys.exit(1)
print('Static project validation: PASS')

visual=(ROOT/'scripts/mobile/mobile_game.gd').read_text('utf-8')
for forbidden in ['background.texture = load(String(PHASE_BACKGROUNDS','bg_cultivation.svg']:
    if forbidden in visual:
        errors.append(f'V0.7 still masks old visual with static background asset: {forbidden}')
for expected in ['CelestialBackdropScript','NavTileScript','EventCardScript','CultivationDiagramScript','InventoryTileScript']:
    if expected not in visual:
        errors.append(f'V0.7 visual rebuild missing {expected}')
if 'TextureRect.new()\n\tbackground' in visual:
    errors.append('V0.7 must not rebuild the old fullscreen TextureRect background')

main_scene=(ROOT/'main.tscn').read_text('utf-8')
if 'res://scripts/v08/v08_game.gd' not in main_scene:
    errors.append('V0.8 main scene must boot the new screen architecture')
v08=(ROOT/'scripts/v08/v08_game.gd').read_text('utf-8')
for forbidden in ['TextureRect.new()', 'PHASE_BACKGROUNDS', 'avatar_mortal.svg', 'bg_cultivation.svg']:
    if forbidden in v08:
        errors.append(f'V0.8 must not mask the lobby with legacy visual asset: {forbidden}')
for required in ['V08Home','V08Map','V08Cultivation','V08Inventory','V08People','V08Base','V08Missions','V08Sect','V08Lifecycle','V08Legacy','V08Combat','V08More']:
    if required not in v08:
        errors.append(f'V0.8 missing dedicated screen: {required}')
