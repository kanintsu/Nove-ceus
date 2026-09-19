class_name ContractSystem
extends RefCounted

const TEMPLATES: Array[Dictionary] = [
	{"id":"gather","title":"Coleta solicitada","action":"gather","goal":2,"reward_silver":34,"rep":1,"text":"Alguém precisa de materiais deste lugar antes que outro grupo os recolha."},
	{"id":"explore","title":"Mapear caminho perigoso","action":"explore","goal":1,"reward_silver":45,"rep":2,"text":"Um comerciante quer informação sobre uma rota que seus guardas evitam."},
	{"id":"hunt","title":"Ameaça na região","action":"hunt","goal":1,"reward_silver":58,"rep":2,"text":"Moradores oferecem recompensa por reduzir uma ameaça local."},
	{"id":"study","title":"Pesquisar registros","action":"study","goal":2,"reward_silver":28,"rep":1,"text":"Um estudioso procura ajuda para organizar conhecimento antigo."},
	{"id":"work","title":"Trabalho por contrato","action":"work","goal":2,"reward_silver":40,"rep":1,"text":"Há serviço honesto para quem aceita gastar semanas trabalhando."},
	{"id":"rumors","title":"Confirmar um rumor","action":"rumors","goal":2,"reward_silver":24,"rep":1,"text":"Informação vale prata se você conseguir separar história de mentira."},
	{"id":"trial","title":"Provar capacidade","action":"trial","goal":1,"reward_silver":70,"rep":3,"text":"Uma facção local quer alguém disposto a aceitar uma prova real."},
	{"id":"comprehend","title":"Registrar fenômeno espiritual","action":"comprehend","goal":1,"reward_silver":82,"rep":2,"text":"Cultivadores pagam por observações de fenômenos que não compreendem."},
]

static func ensure_contracts(life: Dictionary, phase: int, world_year: int, world_day: int, rng: RandomNumberGenerator) -> void:
	if not life.has("contracts"):
		life["contracts"] = []
	var contracts: Array = life["contracts"]
	for contract in contracts:
		if bool(contract.get("completed",false)) or bool(contract.get("failed",false)):
			continue
		if _absolute_day(world_year,world_day) > int(contract.get("expires",999999)):
			contract["failed"] = true
	var active_count := 0
	for contract in contracts:
		if not bool(contract.get("completed",false)) and not bool(contract.get("failed",false)):
			active_count += 1
	while active_count < 3:
		var template: Dictionary = TEMPLATES[rng.randi_range(0,TEMPLATES.size()-1)]
		var difficulty_scale: int = maxi(1,phase)
		var goal: int = int(template["goal"])
		var contract := {
			"uid":"%s-%d-%d-%d" % [String(template["id"]),world_year,world_day,rng.randi_range(100,999)],
			"title":String(template["title"]),
			"action":String(template["action"]),
			"goal":goal,
			"progress":0,
			"reward_silver":int(template["reward_silver"])*difficulty_scale,
			"rep":int(template["rep"]),
			"text":String(template["text"]),
			"phase":phase,
			"expires":_absolute_day(world_year,world_day)+90+phase*15,
			"completed":false,
			"failed":false,
			"claimed":false,
		}
		contracts.append(contract)
		active_count += 1
	life["contracts"] = contracts

static func record_action(life: Dictionary, action: String, phase: int) -> Array[String]:
	var completed: Array[String] = []
	if not life.has("contracts"):
		return completed
	for contract in life["contracts"]:
		if bool(contract.get("completed",false)) or bool(contract.get("failed",false)):
			continue
		if String(contract.get("action","")) != action:
			continue
		if int(contract.get("phase",phase)) != phase:
			continue
		contract["progress"] = mini(int(contract.get("goal",1)),int(contract.get("progress",0))+1)
		if int(contract["progress"]) >= int(contract["goal"]):
			contract["completed"] = true
			completed.append(String(contract["title"]))
	return completed

static func claim(life: Dictionary, uid: String) -> Dictionary:
	if not life.has("contracts"):
		return {}
	for contract in life["contracts"]:
		if String(contract.get("uid","")) != uid:
			continue
		if not bool(contract.get("completed",false)) or bool(contract.get("claimed",false)):
			return {}
		contract["claimed"] = true
		var silver: int = int(contract.get("reward_silver",0))
		var rep: int = int(contract.get("rep",0))
		life["silver"] = int(life.get("silver",0))+silver
		life["world_reputation"] = int(life.get("world_reputation",0))+rep
		return {"silver":silver,"rep":rep,"title":String(contract.get("title","Contrato"))}
	return {}

static func _absolute_day(year: int, day: int) -> int:
	return year*360+day
