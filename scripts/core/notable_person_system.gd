class_name NotablePersonSystem
extends RefCounted

const GIVEN_NAMES: Array[String] = [
	"Liang", "Mei", "Shen", "Rui", "Han", "Yun", "Jian", "Lian",
	"Bo", "Qiao", "Ren", "Xue", "Tao", "Ming", "Wei", "Lin"
]

const FAMILY_NAMES: Array[String] = [
	"Chen", "Li", "Zhao", "Shen", "Wu", "Han", "Qin", "Bai", "Luo", "Jiang"
]

static func roll_rare_encounter(rng: RandomNumberGenerator, world_year: int, days_exposed: int) -> Dictionary:
	if days_exposed <= 0:
		return {}
	# Chances anuais regionais deliberadamente baixas. O jogador não vê estes números.
	var annual_roll := rng.randf()
	var exposure := clampf(float(days_exposed) / 360.0, 0.0, 1.0)
	var kind := ""
	if annual_roll < 0.006 * exposure:
		kind = "abandoned_child"
	elif annual_roll < 0.014 * exposure:
		kind = "injured_youth"
	elif annual_roll < 0.024 * exposure:
		kind = "gifted_mortal"
	if kind.is_empty():
		return {}

	var spiritual_birth := BirthSystem.generate_birth(rng)
	var age := 0
	var story := ""
	var role := ""
	match kind:
		"abandoned_child":
			age = rng.randi_range(0, 3)
			role = "criança abandonada"
			story = "Uma criança foi deixada perto da estrada sem nome, família ou proteção."
		"injured_youth":
			age = rng.randi_range(11, 17)
			role = "jovem ferido"
			story = "Um jovem desconhecido sobreviveu a um ataque na estrada e não tem para onde voltar."
		_:
			age = rng.randi_range(12, 19)
			role = "jovem estudioso"
			story = "Um jovem mortal demonstra inteligência incomum, mas não possui mestre nem recursos."

	return {
		"id": "%d-%d-%d" % [world_year, rng.randi_range(1000, 9999), age],
		"kind": kind,
		"name": _random_name(rng),
		"age": age,
		"birth_year": world_year - age,
		"role": role,
		"story": story,
		"intelligence": int(spiritual_birth.get("intelligence", 50)),
		"willpower": int(spiritual_birth.get("willpower", 50)),
		"physique": int(spiritual_birth.get("physique", 50)),
		"qi_potential": int(spiritual_birth.get("qi_potential", BirthSystem.QiPotential.MORTAL)),
		"qi_known": false,
		"qi_awakened": false,
		"alive": true,
		"accepted": false,
		"relation": "desconhecido",
		"path": role,
		"career_progress": 0.0,
		"career_stage": 0,
		"lifespan": clampi(58 + int(spiritual_birth.get("physique", 50)) / 5 + rng.randi_range(-7, 14), 48, 102),
	}

static func advance_people(people: Array[Dictionary], years_passed: int, rng: RandomNumberGenerator, world_year: int) -> Array[String]:
	var events: Array[String] = []
	if years_passed <= 0:
		return events
	for person in people:
		if not bool(person.get("alive", true)):
			continue
		var previous_age := int(person.get("age", 0))
		var age := previous_age + years_passed
		person["age"] = age
		var lifespan := int(person.get("lifespan", 70))
		if age >= lifespan:
			person["alive"] = false
			events.append("%s, alguém que fez parte de uma vida anterior, morreu aos %d anos." % [String(person.get("name", "Alguém")), lifespan])
			continue

		if not bool(person.get("qi_awakened", false)) and age >= 14:
			var potential := int(person.get("qi_potential", BirthSystem.QiPotential.MORTAL))
			var chance_per_year := 0.0
			if potential == BirthSystem.QiPotential.AWAKENED:
				chance_per_year = 0.028
			elif potential == BirthSystem.QiPotential.LATENT:
				chance_per_year = 0.012
			var discover_chance := 1.0 - pow(1.0 - chance_per_year, float(years_passed))
			if chance_per_year > 0.0 and rng.randf() < discover_chance:
				person["qi_awakened"] = true
				person["qi_known"] = true
				person["path"] = "cultivador errante · Refinamento de Qi"
				events.append("%s encontrou uma oportunidade e entrou no Refinamento de Qi." % String(person.get("name", "Alguém")))
				continue

		if not bool(person.get("qi_awakened", false)):
			var intelligence := int(person.get("intelligence", 50))
			var willpower := int(person.get("willpower", 50))
			var progress := float(person.get("career_progress", 0.0))
			progress += float(years_passed) * (0.35 + float(intelligence + willpower) / 240.0)
			person["career_progress"] = progress
			var career_stage := int(person.get("career_stage", 0))
			if intelligence >= 82 and progress >= 28.0 and career_stage < 2:
				person["path"] = "inventor e estudioso mortal"
				person["career_stage"] = 2
				events.append("%s tornou-se conhecido por invenções e estudos no mundo mortal." % String(person.get("name", "Alguém")))
			elif intelligence >= 68 and progress >= 14.0 and career_stage < 1:
				person["path"] = "estudioso mortal"
				person["career_stage"] = 1
				events.append("%s ganhou reputação como estudioso mortal." % String(person.get("name", "Alguém")))
			elif int(person.get("physique", 50)) >= 76 and progress >= 16.0 and career_stage < 1:
				person["path"] = "artista marcial mortal"
				person["career_stage"] = 1
				events.append("%s alcançou renome como artista marcial mortal." % String(person.get("name", "Alguém")))

		person["last_simulated_year"] = world_year
	return events

static func public_summary(person: Dictionary) -> String:
	var state := String(person.get("path", person.get("role", "mortal")))
	if not bool(person.get("alive", true)):
		state += " · falecido"
	return "%s · %d anos · %s" % [String(person.get("name", "Desconhecido")), int(person.get("age", 0)), state]

static func _random_name(rng: RandomNumberGenerator) -> String:
	return "%s %s" % [
		FAMILY_NAMES[rng.randi_range(0, FAMILY_NAMES.size() - 1)],
		GIVEN_NAMES[rng.randi_range(0, GIVEN_NAMES.size() - 1)]
	]
