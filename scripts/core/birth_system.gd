class_name BirthSystem
extends RefCounted

enum QiPotential {
	AWAKENED,
	LATENT,
	SEALED,
	MORTAL,
}

const ORIGINS: Array[Dictionary] = [
	{"id": "farm_village", "label": "Vila agrícola", "weight": 30},
	{"id": "frontier_hunters", "label": "Família de caçadores", "weight": 18},
	{"id": "merchant_town", "label": "Cidade mercantil", "weight": 15},
	{"id": "martial_house", "label": "Família marcial menor", "weight": 10},
	{"id": "sect_servants", "label": "Servos ligados a uma seita", "weight": 8},
	{"id": "spirit_mine", "label": "Acampamento de mineração espiritual", "weight": 5},
	{"id": "deep_forest", "label": "Sobrevivente da floresta profunda", "weight": 8},
	{"id": "ruined_clan", "label": "Descendente de um clã arruinado", "weight": 6},
]

# O mundo é majoritariamente mortal. Os números ficam ocultos do jogador.
const QI_WEIGHTS: Array[Dictionary] = [
	{"value": QiPotential.AWAKENED, "weight": 4},
	{"value": QiPotential.LATENT, "weight": 7},
	{"value": QiPotential.SEALED, "weight": 4},
	{"value": QiPotential.MORTAL, "weight": 85},
]

static func generate_birth(rng: RandomNumberGenerator) -> Dictionary:
	var origin: Dictionary = _weighted_pick(ORIGINS, rng)
	var potential: int = _roll_qi_potential(rng)
	var intelligence := _roll_attribute(rng)
	var willpower := _roll_attribute(rng)
	var physique := _roll_attribute(rng)
	var constitution := _roll_constitution(rng)
	return {
		"origin_id": String(origin["id"]),
		"origin_label": String(origin["label"]),
		"qi_potential": potential,
		"qi_known": false,
		"qi_awakened": false,
		"intelligence": intelligence,
		"willpower": willpower,
		"physique": physique,
		"constitution": constitution,
		"body_training": 0.0,
		"worldly_knowledge": 0.0,
		"meridian_integrity": 1.0,
		"soul_stability": 1.0,
		"natural_lifespan": clampi(58 + physique / 5 + rng.randi_range(-7, 14), 48, 102),
		"alive": true,
	}

static func can_naturally_awaken(potential: int) -> bool:
	return potential == QiPotential.AWAKENED or potential == QiPotential.LATENT

static func requires_heaven_defying_opportunity(potential: int) -> bool:
	return potential == QiPotential.SEALED or potential == QiPotential.MORTAL

static func hidden_diagnosis(potential: int) -> String:
	match potential:
		QiPotential.AWAKENED:
			return "Afinidade espiritual detectada"
		QiPotential.LATENT:
			return "Raiz espiritual dormente"
		QiPotential.SEALED:
			return "Meridianos selados"
		_:
			return "Nenhuma raiz espiritual detectável"

static func constitution_name(constitution: int) -> String:
	match constitution:
		2:
			return "Constituição lendária desconhecida"
		1:
			return "Constituição espiritual rara"
		_:
			return "Corpo comum"

static func _roll_qi_potential(rng: RandomNumberGenerator) -> int:
	var picked: Dictionary = _weighted_pick(QI_WEIGHTS, rng)
	return int(picked["value"])

static func _roll_attribute(rng: RandomNumberGenerator) -> int:
	# Curva simples centrada: gênios mortais continuam raros.
	var value := int(round((rng.randf() + rng.randf() + rng.randf()) / 3.0 * 100.0))
	return clampi(value, 8, 96)

static func _roll_constitution(rng: RandomNumberGenerator) -> int:
	# 0,05% rara; 0,001% lendária.
	var roll := rng.randi_range(1, 100000)
	if roll == 1:
		return 2
	if roll <= 51:
		return 1
	return 0

static func _weighted_pick(entries: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var total := 0
	for entry in entries:
		total += int(entry["weight"])
	var roll := rng.randi_range(1, total)
	var cursor := 0
	for entry in entries:
		cursor += int(entry["weight"])
		if roll <= cursor:
			return entry
	return entries[entries.size() - 1]
