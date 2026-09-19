class_name WorldEventSystem
extends RefCounted

const TEMPLATES: Array[Dictionary] = [
	{"type":"beast_tide","title":"Maré de Bestas","phases":[1,2,3,4],"duration":35,"realm":2,"locations":["cold_mist_forest","hundred_beasts_valley","crimson_forest"],"text":"Bestas estão deixando seus territórios e pressionando rotas habitadas."},
	{"type":"spirit_rain","title":"Chuva Espiritual","phases":[2,3,4,5],"duration":18,"realm":1,"locations":["qinghe_city","meditation_lake","shattered_cloud_sea","dao_mirror_lake"],"text":"Uma chuva rara aumenta temporariamente a densidade de Qi e atrai cultivadores."},
	{"type":"herb_bloom","title":"Florescimento Raro","phases":[1,2,3,4,5],"duration":28,"realm":0,"locations":["willow_grove","old_graves_hill","spirit_herb_garden","crimson_forest","immortality_garden"],"text":"Uma condição incomum fez ervas valiosas florescerem fora de época."},
	{"type":"sect_recruitment","title":"Recrutamento da Seita","phases":[1,2,3],"duration":45,"realm":0,"locations":["qinghe_city","veiled_gate","outer_courtyard"],"text":"A Seita do Céu Velado abriu tarefas, testes e recrutamento por tempo limitado."},
	{"type":"caravan","title":"Caravana dos Três Rios","phases":[1,2,3],"duration":22,"realm":0,"locations":["qinghe_road","qing_river_docks","veiled_gate"],"text":"Uma grande caravana transporta mercadorias, notícias e pessoas importantes."},
	{"type":"ancient_opening","title":"Abertura de Ruína Antiga","phases":[2,3,4],"duration":14,"realm":5,"locations":["old_graves_hill","sword_graveyard","lianshi_ruins"],"text":"Um selo antigo enfraqueceu. Outros cultivadores já estão se movendo para o local."},
	{"type":"tournament","title":"Torneio Regional","phases":[2,3,5],"duration":30,"realm":1,"locations":["qinghe_city","outer_courtyard","nine_heavens_palace"],"text":"Um torneio oferece reputação, recursos e a possibilidade de humilhação pública."},
	{"type":"plague","title":"Febre do Rio Qing","phases":[1,2],"duration":42,"realm":0,"locations":["spring_village","qing_river_docks"],"text":"Uma doença mortal se espalha. Conhecimento e recursos podem salvar mais vidas que força."},
	{"type":"spirit_vein","title":"Veio Espiritual Emergente","phases":[3,4,5],"duration":24,"realm":8,"locations":["veiled_peak","broken_spirit_mine","celestial_stair"],"text":"A terra liberou Qi concentrado. Clãs, seitas e bestas já disputam a fonte."},
	{"type":"rogue_bounty","title":"Recompensa por Cultivador Renegado","phases":[2,3,4],"duration":40,"realm":4,"locations":["white_crane_inn","trial_cliff","lianshi_ruins"],"text":"Uma recompensa foi publicada. O alvo é perigoso e pode ter aliados."},
	{"type":"faction_conflict","title":"Disputa entre Linhagens","phases":[2,3,4],"duration":55,"realm":2,"locations":["qinghe_city","veiled_gate","broken_spirit_mine"],"text":"Duas forças locais entraram em conflito por território, recursos e prestígio."},
	{"type":"eclipse","title":"Eclipse do Qi Yin","phases":[3,4,5],"duration":9,"realm":10,"locations":["meditation_lake","black_mirror_lake","destiny_hall"],"text":"O céu escureceu e o fluxo do Qi mudou. Técnicas Yin e fenômenos da alma se intensificam."},
	{"type":"flood","title":"Grande Enchente","phases":[1,2],"duration":25,"realm":0,"locations":["spring_village","qing_river_docks"],"text":"Chuvas destruíram estradas e plantações. A região precisa de trabalho, comida e organização."},
	{"type":"merchant_fair","title":"Feira dos Cem Ofícios","phases":[1,2,3],"duration":20,"realm":0,"locations":["old_stone_bridge","lower_jade_market","outer_courtyard"],"text":"Artesãos, médicos, ferreiros e pequenos cultivadores se reuniram para negociar conhecimento e bens."},
	{"type":"heaven_omen","title":"Presságio nos Nove Céus","phases":[4,5],"duration":12,"realm":16,"locations":["shattered_cloud_sea","ascension_gate"],"text":"Um fenômeno celeste visível por milhares de quilômetros provoca medo, culto e especulação."},
]

static func ensure_events(events: Array[Dictionary], year: int, day: int, rng: RandomNumberGenerator) -> void:
	var now := _absolute_day(year,day)
	for event in events:
		if not bool(event.get("resolved",false)) and now > int(event.get("expires",0)):
			event["expired"] = true
	var active := 0
	for event in events:
		if not bool(event.get("resolved",false)) and not bool(event.get("expired",false)):
			active += 1
	while active < 4:
		var template: Dictionary = TEMPLATES[rng.randi_range(0,TEMPLATES.size()-1)]
		var locs: Array = template["locations"]
		var location: String = String(locs[rng.randi_range(0,locs.size()-1)])
		var phase_values: Array = template["phases"]
		var phase: int = int(phase_values[rng.randi_range(0,phase_values.size()-1)])
		var duration: int = int(template["duration"])
		var event := {
			"uid":"event-%d-%d-%d" % [year,day,rng.randi_range(1000,9999)],
			"type":String(template["type"]),
			"title":String(template["title"]),
			"text":String(template["text"]),
			"location":location,
			"phase":phase,
			"recommended_realm":int(template["realm"]),
			"created":now,
			"expires":now+duration,
			"resolved":false,
			"expired":false,
		}
		events.append(event)
		active += 1
	if events.size() > 30:
		var kept: Array[Dictionary] = []
		for event in events:
			if not bool(event.get("expired",false)) or not bool(event.get("resolved",false)):
				kept.append(event)
		while kept.size() > 30:
			kept.pop_front()
		events.assign(kept)

static func active_events(events: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in events:
		if not bool(event.get("resolved",false)) and not bool(event.get("expired",false)):
			result.append(event)
	return result

static func remaining_days(event: Dictionary, year: int, day: int) -> int:
	return maxi(0,int(event.get("expires",0))-_absolute_day(year,day))

static func resolve(events: Array[Dictionary], uid: String) -> void:
	for event in events:
		if String(event.get("uid","")) == uid:
			event["resolved"] = true
			return

static func find_event(events: Array[Dictionary], uid: String) -> Dictionary:
	for event in events:
		if String(event.get("uid","")) == uid:
			return event
	return {}

static func _absolute_day(year:int,day:int) -> int:
	return year*360+day
