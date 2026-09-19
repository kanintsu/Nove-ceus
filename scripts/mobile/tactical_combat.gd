class_name TacticalCombat
extends RefCounted

const ENEMIES: Dictionary = {
	1:[
		{"name":"Lobo da Névoa","hp":54,"attack":9,"defense":2,"realm":0,"reward_silver":14,"loot":"Pele da Névoa"},
		{"name":"Bandido da Estrada","hp":62,"attack":8,"defense":3,"realm":0,"reward_silver":20,"loot":"Bolsa de bandido"},
		{"name":"Javali de Presas Cinzentas","hp":74,"attack":11,"defense":4,"realm":0,"reward_silver":10,"loot":"Presa cinzenta"},
	],
	2:[
		{"name":"Artista Marcial Renegado","hp":86,"attack":13,"defense":5,"realm":0,"reward_silver":38,"loot":"Manual marcial rasgado"},
		{"name":"Serpente de Jade Jovem","hp":92,"attack":15,"defense":4,"realm":1,"reward_silver":25,"loot":"Escama de jade"},
		{"name":"Cultivador Ladrão","hp":104,"attack":17,"defense":6,"realm":2,"reward_silver":48,"loot":"Talismã gasto"},
	],
	3:[
		{"name":"Discípulo Rival","hp":122,"attack":20,"defense":8,"realm":4,"reward_silver":55,"loot":"Ficha de mérito"},
		{"name":"Macaco Espiritual","hp":138,"attack":23,"defense":7,"realm":5,"reward_silver":42,"loot":"Sangue espiritual diluído"},
		{"name":"Guardião de Pedra","hp":160,"attack":25,"defense":11,"realm":6,"reward_silver":30,"loot":"Núcleo de formação menor"},
	],
	4:[
		{"name":"Tigre Carmesim","hp":210,"attack":34,"defense":13,"realm":11,"reward_silver":85,"loot":"Núcleo bestial carmesim"},
		{"name":"Marionete de Lianshi","hp":236,"attack":31,"defense":17,"realm":10,"reward_silver":70,"loot":"Fragmento de formação antiga"},
		{"name":"Serpente do Espelho Negro","hp":248,"attack":38,"defense":12,"realm":12,"reward_silver":90,"loot":"Olho de espelho negro"},
	],
	5:[
		{"name":"Sentinela Celestial","hp":330,"attack":46,"defense":21,"realm":18,"reward_silver":130,"loot":"Selo celestial rachado"},
		{"name":"Eco de um Antigo","hp":360,"attack":51,"defense":19,"realm":19,"reward_silver":0,"loot":"Fragmento de memória antiga"},
		{"name":"Fera da Tribulação","hp":410,"attack":57,"defense":20,"realm":20,"reward_silver":160,"loot":"Cristal de trovão celestial"},
	]
}

static func create_battle(life: Dictionary, phase: int, rng: RandomNumberGenerator) -> Dictionary:
	var pool: Array = ENEMIES.get(clampi(phase,1,5),ENEMIES[1])
	var enemy_template: Dictionary = pool[rng.randi_range(0,pool.size()-1)]
	var body: float = float(life.get("body_training",0.0))
	var realm: int = int(life.get("realm_index",0))
	var meridians: float = float(life.get("meridian_integrity",1.0))
	var max_hp: int = 82 + int(body*0.75) + realm*8
	var max_qi: int = 0
	if bool(life.get("qi_awakened",false)):
		max_qi = 3 + int(realm/3.0)
	return {
		"enemy":enemy_template.duplicate(true),
		"player_hp":max_hp,
		"player_max_hp":max_hp,
		"player_guard":0,
		"player_focus":0,
		"player_qi":max_qi,
		"player_max_qi":max_qi,
		"player_stamina":3,
		"turn":1,
		"finished":false,
		"victory":false,
		"fled":false,
		"log":[],
		"enemy_intent":"",
		"enemy_power":0,
		"observed":false,
		"meridian_factor":meridians,
	}

static func roll_enemy_intent(battle: Dictionary, rng: RandomNumberGenerator) -> void:
	var enemy: Dictionary = battle["enemy"]
	var hp_ratio: float = float(enemy["hp"])/maxf(1.0,float(enemy.get("max_hp",enemy["hp"])))
	var roll: float = rng.randf()
	var intent := "attack"
	if hp_ratio < 0.35 and roll < 0.28:
		intent = "guard"
	elif roll < 0.18:
		intent = "heavy"
	elif roll < 0.34:
		intent = "feint"
	elif roll < 0.47:
		intent = "charge"
	battle["enemy_intent"] = intent
	var attack: int = int(enemy["attack"])
	match intent:
		"heavy": battle["enemy_power"] = int(attack*1.55)
		"feint": battle["enemy_power"] = int(attack*0.72)
		"charge": battle["enemy_power"] = int(attack*1.28)
		"guard": battle["enemy_power"] = 0
		_: battle["enemy_power"] = attack

static func intent_text(battle: Dictionary) -> String:
	var intent: String = String(battle.get("enemy_intent","attack"))
	var power: int = int(battle.get("enemy_power",0))
	match intent:
		"heavy": return "PREPARA GOLPE PESADO · ~%d dano" % power
		"feint": return "MOVIMENTO ENGANOSO · ataque rápido provável"
		"charge": return "ACUMULA FORÇA · ataque forte no próximo movimento"
		"guard": return "FECHA A GUARDA · defesa aumentada"
		_: return "ATACA · ~%d dano" % power

static func resolve_player_action(battle: Dictionary, action: String, life: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	if bool(battle.get("finished",false)):
		return {"text":"O combate já terminou.","damage":0}

	var enemy: Dictionary = battle["enemy"]
	var realm: int = int(life.get("realm_index",0))
	var body: float = float(life.get("body_training",0.0))
	var knowledge: float = float(life.get("worldly_knowledge",0.0))
	var focus: int = int(battle.get("player_focus",0))
	var stamina: int = int(battle.get("player_stamina",3))
	var qi: int = int(battle.get("player_qi",0))
	var enemy_defense: int = int(enemy.get("defense",0))
	if String(battle.get("enemy_intent","")) == "guard":
		enemy_defense += 8

	var result_text := ""
	var dealt := 0
	match action:
		"strike":
			if stamina <= 0:
				result_text = "Sem fôlego para atacar com força."
			else:
				battle["player_stamina"] = stamina-1
				var base: float = 10.0 + body*0.16 + realm*2.6 + focus*2.2
				dealt = maxi(1,int(base)-enemy_defense+rng.randi_range(-3,4))
				enemy["hp"] = maxi(0,int(enemy["hp"])-dealt)
				result_text = "Você ataca e causa %d de dano." % dealt
		"guard":
			battle["player_guard"] = 12 + int(body*0.12) + realm*2
			battle["player_stamina"] = mini(3,stamina+1)
			result_text = "Você fecha a guarda e recupera fôlego."
		"observe":
			battle["observed"] = true
			battle["player_focus"] = mini(5,focus+2)
			battle["player_stamina"] = mini(3,stamina+1)
			result_text = "Você observa postura, respiração e terreno. Foco +2."
		"feint":
			if stamina <= 0:
				result_text = "Você não possui fôlego para executar a finta."
			else:
				battle["player_stamina"] = stamina-1
				var chance: float = clampf(0.46+knowledge/220.0+focus*0.06,0.22,0.88)
				if rng.randf() < chance:
					dealt = maxi(1,int(7.0+body*0.11+realm*2.0)-int(enemy_defense*0.35))
					enemy["hp"] = maxi(0,int(enemy["hp"])-dealt)
					battle["player_focus"] = mini(5,focus+1)
					result_text = "A finta abre a defesa. %d dano e Foco +1." % dealt
				else:
					result_text = "O inimigo não morde a finta."
		"technique":
			if qi <= 0:
				result_text = "Seu Qi não é suficiente para uma técnica."
			else:
				battle["player_qi"] = qi-1
				var integrity: float = float(battle.get("meridian_factor",1.0))
				var base_qi: float = (18.0+realm*4.1+focus*2.8)*integrity
				dealt = maxi(2,int(base_qi)-int(enemy_defense*0.45)+rng.randi_range(-2,5))
				enemy["hp"] = maxi(0,int(enemy["hp"])-dealt)
				result_text = "Qi percorre os meridianos. A técnica causa %d de dano." % dealt
		"flee":
			var enemy_realm: int = int(enemy.get("realm",0))
			var flee_chance: float = clampf(0.60+knowledge/300.0+float(realm-enemy_realm)*0.05,0.12,0.92)
			if rng.randf() < flee_chance:
				battle["fled"] = true
				battle["finished"] = true
				result_text = "Você abandona a luta e sobrevive."
			else:
				result_text = "Sua tentativa de fuga falha."
		_:
			result_text = "Você hesita."

	battle["enemy"] = enemy
	if int(enemy["hp"]) <= 0:
		battle["finished"] = true
		battle["victory"] = true
		result_text += "\nO inimigo cai."
	return {"text":result_text,"damage":dealt}

static func resolve_enemy_turn(battle: Dictionary, rng: RandomNumberGenerator) -> String:
	if bool(battle.get("finished",false)):
		return ""
	var enemy: Dictionary = battle["enemy"]
	var intent: String = String(battle.get("enemy_intent","attack"))
	if intent == "guard":
		battle["player_stamina"] = mini(3,int(battle.get("player_stamina",0))+1)
		return "%s mantém a guarda e mede sua reação." % String(enemy["name"])

	var incoming: int = int(battle.get("enemy_power",int(enemy["attack"])))
	if intent == "feint" and bool(battle.get("observed",false)):
		incoming = int(incoming*0.45)
	var guard: int = int(battle.get("player_guard",0))
	var damage: int = maxi(0,incoming-guard+rng.randi_range(-2,2))
	battle["player_hp"] = maxi(0,int(battle["player_hp"])-damage)
	battle["player_guard"] = 0
	battle["observed"] = false
	battle["player_stamina"] = mini(3,int(battle.get("player_stamina",0))+1)
	if int(battle["player_hp"]) <= 0:
		battle["finished"] = true
	return "%s causa %d de dano." % [String(enemy["name"]),damage]

static func next_turn(battle: Dictionary, rng: RandomNumberGenerator) -> void:
	if bool(battle.get("finished",false)):
		return
	battle["turn"] = int(battle.get("turn",1))+1
	roll_enemy_intent(battle,rng)
