class_name WorldState
extends Node

signal calendar_changed(year: int, day: int)
signal life_started(life: Dictionary)
signal life_ended(summary: Dictionary)
signal chronicle_changed
signal rare_encounter_changed(profile: Dictionary)

const NotablePersonSystemScript = preload("res://scripts/core/notable_person_system.gd")

var rng := RandomNumberGenerator.new()
var world_seed: int = 0
var world_year: int = 137
var world_day: int = 72
var incarnation_index: int = 0
var current_life: Dictionary = {}
var chronicles: Array[Dictionary] = []
var world_events: Array[String] = []
var active_dynamic_events: Array[Dictionary] = []
var notable_people: Array[Dictionary] = []
var current_rare_encounter: Dictionary = {}

func initialize(seed_value: int = 0) -> void:
	world_seed = seed_value
	if world_seed == 0:
		world_seed = int(Time.get_unix_time_from_system()) ^ int(Time.get_ticks_msec())
	rng.seed = world_seed
	if current_life.is_empty():
		_start_new_life(false)

func advance_days(days: int) -> void:
	if days <= 0:
		return
	world_day += days
	while world_day > 360:
		world_day -= 360
		world_year += 1
	if not current_life.is_empty():
		current_life["age"] = current_age()
	_try_generate_rare_encounter(days)
	calendar_changed.emit(world_year, world_day)

func end_life(cause: String, age_years: int) -> Dictionary:
	if current_life.is_empty() or not bool(current_life.get("alive", false)):
		return {}
	current_life["alive"] = false
	var summary := {
		"incarnation": incarnation_index,
		"birth_year": int(current_life.get("birth_year", world_year - age_years)),
		"death_year": world_year,
		"age": maxi(age_years, 0),
		"cause": cause,
		"origin": String(current_life.get("origin_label", "Desconhecida")),
		"reached_qi": bool(current_life.get("qi_awakened", false)),
		"body_training": float(current_life.get("body_training", 0.0)),
		"worldly_knowledge": float(current_life.get("worldly_knowledge", 0.0)),
	}
	chronicles.append(summary)
	if chronicles.size() > 30:
		chronicles.pop_front()
	life_ended.emit(summary)
	chronicle_changed.emit()
	return summary

func reincarnate() -> Dictionary:
	var years_until_birth := rng.randi_range(1, 34)
	current_rare_encounter = {}
	rare_encounter_changed.emit({})
	world_year += years_until_birth
	_simulate_world(years_until_birth)
	var new_birth_year := world_year
	world_year += 16
	_simulate_world(16)
	world_day = rng.randi_range(1, 360)
	_start_new_life(true, new_birth_year)
	calendar_changed.emit(world_year, world_day)
	return current_life

func record_world_event(text: String) -> void:
	world_events.push_front("Ano %d — %s" % [world_year, text])
	if world_events.size() > 20:
		world_events.pop_back()
	chronicle_changed.emit()

func accept_current_rare_encounter() -> bool:
	if current_rare_encounter.is_empty():
		return false
	var person: Dictionary = current_rare_encounter.duplicate(true)
	person["accepted"] = true
	person["relation"] = "protegido da Vida %d" % incarnation_index
	person["patron_life"] = incarnation_index
	notable_people.append(person)
	record_world_event("%s passou a ser protegido pela sua Vida %d." % [String(person.get("name", "Alguém")), incarnation_index])
	current_rare_encounter = {}
	rare_encounter_changed.emit({})
	chronicle_changed.emit()
	return true

func public_life_info() -> Dictionary:
	return {
		"incarnation": incarnation_index,
		"origin": String(current_life.get("origin_label", "Desconhecida")),
		"birth_year": int(current_life.get("birth_year", world_year - 16)),
		"qi_known": bool(current_life.get("qi_known", false)),
	}

func current_age() -> int:
	return maxi(world_year - int(current_life.get("birth_year", world_year - 16)), 0)

func chronicle_text() -> String:
	var lines: Array[String] = []
	lines.append("[b]CRÔNICA DO MUNDO[/b]")
	lines.append("Ano %d · Dia %d" % [world_year, world_day])
	lines.append("")
	if world_events.is_empty():
		lines.append("O mundo ainda não registrou grandes mudanças nesta era.")
	else:
		for event_text in world_events:
			lines.append("• " + event_text)
	lines.append("")
	lines.append("[b]PESSOAS LIGADAS ÀS SUAS VIDAS[/b]")
	if notable_people.is_empty():
		lines.append("Nenhuma relação persistente atravessou o tempo ainda.")
	else:
		for person in notable_people:
			lines.append("• " + NotablePersonSystemScript.public_summary(person))
	lines.append("")
	lines.append("[b]VIDAS ANTERIORES[/b]")
	if chronicles.is_empty():
		lines.append("Nenhuma vida anterior registrada.")
	else:
		for summary in chronicles:
			var cultivation_text := "tocou o Qi" if bool(summary["reached_qi"]) else "permaneceu mortal"
			lines.append("• Vida %d: %s; morreu aos %d anos (%s), %s." % [int(summary["incarnation"]), String(summary["origin"]), int(summary["age"]), String(summary["cause"]), cultivation_text])
	return "\n".join(lines)

func _start_new_life(is_reincarnation: bool, birth_year_override: int = -1) -> void:
	incarnation_index += 1
	current_life = BirthSystem.generate_birth(rng)
	current_life["incarnation"] = incarnation_index
	current_life["birth_year"] = birth_year_override if birth_year_override >= 0 else world_year - 16
	current_life["age"] = 16
	current_life["alive"] = true
	if is_reincarnation:
		record_world_event("uma nova alma despertou em algum ponto da região de Qinghe.")
	life_started.emit(current_life)

func _try_generate_rare_encounter(days_exposed: int) -> void:
	if not current_rare_encounter.is_empty():
		return
	var encounter: Dictionary = NotablePersonSystemScript.roll_rare_encounter(rng, world_year, days_exposed)
	if encounter.is_empty():
		return
	current_rare_encounter = encounter
	record_world_event("um encontro incomum surgiu nas estradas da região: %s." % String(encounter.get("role", "viajante")))
	rare_encounter_changed.emit(current_rare_encounter)

func _simulate_world(years_passed: int) -> void:
	if years_passed <= 0:
		return
	var person_events: Array[String] = NotablePersonSystemScript.advance_people(notable_people, years_passed, rng, world_year)
	for person_event in person_events:
		record_world_event(person_event)

	var event_count := clampi(1 + int(years_passed / 10.0), 1, 4)
	var candidates: Array[String] = [
		"uma família mercante ampliou a estrada de Qinghe.",
		"uma pequena linhagem de cultivadores surgiu ao norte.",
		"bestas espirituais foram vistas mais perto das aldeias.",
		"a Vila da Nascente recebeu novas famílias de agricultores.",
		"caçadores desapareceram na Floresta da Névoa Fria.",
		"rumores falam de luzes estranhas nas Ruínas de Lianshi.",
		"o preço de ervas espirituais subiu após uma estação ruim.",
		"um jovem desconhecido foi aceito por uma seita distante.",
		"uma disputa territorial entre famílias terminou sem vencedor.",
		"a concentração de Qi na Montanha do Véu aumentou por alguns dias.",
		"um estudioso mortal publicou métodos que melhoraram a irrigação de aldeias.",
		"uma velha família perdeu prestígio depois da morte de seu patriarca.",
	]
	for _i in range(event_count):
		record_world_event(candidates[rng.randi_range(0, candidates.size() - 1)])
