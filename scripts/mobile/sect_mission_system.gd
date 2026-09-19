class_name SectMissionSystem
extends RefCounted

const TEMPLATES: Array[Dictionary] = [
	{"title":"Cuidar do Jardim Espiritual","action":"gather","goal":2,"days":40,"realm":0,"merit":3,"silver":28,"text":"O jardim precisa de trabalho cuidadoso; até servos mortais podem ajudar."},
	{"title":"Entregar Medicina em Qinghe","action":"travel","goal":1,"days":32,"realm":0,"merit":2,"silver":35,"text":"Leve suprimentos da seita até contatos na cidade."},
	{"title":"Catalogar Manuais Mortais","action":"study","goal":2,"days":50,"realm":0,"merit":3,"silver":24,"text":"Conhecimento comum também precisa de alguém capaz de organizá-lo."},
	{"title":"Patrulhar a Estrada da Montanha","action":"explore","goal":1,"days":35,"realm":1,"merit":5,"silver":50,"text":"Verifique desaparecimentos e sinais de bestas ao longo da rota."},
	{"title":"Caçar Besta Espiritual Jovem","action":"hunt","goal":1,"days":30,"realm":2,"merit":7,"silver":70,"text":"Uma besta começou a atacar caravanas. O alvo é mais perigoso do que animais comuns."},
	{"title":"Duelo de Discípulos Externos","action":"trial","goal":1,"days":24,"realm":1,"merit":6,"silver":45,"text":"Represente seu pátio em uma série de combates supervisionados."},
	{"title":"Coletar Ervas da Nuvem Azul","action":"gather","goal":3,"days":55,"realm":3,"merit":8,"silver":80,"text":"O pavilhão de alquimia precisa de ervas frescas antes da próxima fornada."},
	{"title":"Investigar Formação Danificada","action":"formations","goal":1,"days":45,"realm":5,"merit":10,"silver":100,"text":"Uma formação de fronteira perdeu estabilidade e ninguém sabe por quê."},
	{"title":"Escoltar Discípulo Alquimista","action":"travel","goal":2,"days":40,"realm":4,"merit":9,"silver":110,"text":"Um alquimista precisa atravessar território inseguro para buscar materiais."},
	{"title":"Investigar Ruínas de Lianshi","action":"explore","goal":2,"days":60,"realm":7,"merit":14,"silver":150,"text":"A seita quer registros do interior das ruínas antes que outra facção chegue."},
	{"title":"Eliminar Cultivador Renegado","action":"hunt","goal":1,"days":45,"realm":8,"merit":16,"silver":180,"text":"Um ex-discípulo roubou técnicas e feriu perseguidores enviados anteriormente."},
	{"title":"Proteger Veio Espiritual","action":"trial","goal":2,"days":70,"realm":10,"merit":20,"silver":240,"text":"Uma disputa territorial exige cultivadores capazes de suportar confronto prolongado."},
	{"title":"Registrar Fenômeno do Espelho Negro","action":"comprehend","goal":2,"days":75,"realm":11,"merit":18,"silver":220,"text":"Anciões querem observações detalhadas, não apenas relatos supersticiosos."},
	{"title":"Recuperar Herança Perdida","action":"inheritance","goal":1,"days":90,"realm":13,"merit":26,"silver":320,"text":"Uma herança ligada à história da seita desapareceu nas Terras Ancestrais."},
	{"title":"Apoiar Tribulação de um Ancião","action":"tribulation","goal":1,"days":120,"realm":17,"merit":40,"silver":500,"text":"Apenas cultivadores poderosos deveriam sequer aproximar-se desta missão."},
]

static func ensure_state(life: Dictionary) -> void:
	if not life.has("sect_status"):
		life["sect_status"] = "outsider"
	if not life.has("sect_merit"):
		life["sect_merit"] = 0
	if not life.has("sect_missions"):
		life["sect_missions"] = []
	if not life.has("sect_available"):
		life["sect_available"] = []

static func refresh_board(life: Dictionary, year:int, day:int, rng:RandomNumberGenerator) -> void:
	ensure_state(life)
	var now := year*360+day
	var board: Array = life["sect_available"]
	var fresh: Array = []
	for mission in board:
		if now <= int(mission.get("expires",0)) and not bool(mission.get("accepted",false)):
			fresh.append(mission)
	board = fresh
	while board.size() < 6:
		var template: Dictionary = TEMPLATES[rng.randi_range(0,TEMPLATES.size()-1)]
		var uid := "sect-%d-%d-%d" % [year,day,rng.randi_range(1000,9999)]
		var mission := template.duplicate(true)
		mission["uid"] = uid
		mission["progress"] = 0
		mission["expires"] = now+int(template["days"])
		mission["accepted"] = false
		mission["completed"] = false
		mission["claimed"] = false
		board.append(mission)
	life["sect_available"] = board

static func join_or_upgrade(life: Dictionary) -> String:
	ensure_state(life)
	var status := String(life.get("sect_status","outsider"))
	var qi := bool(life.get("qi_awakened",false))
	var merit := int(life.get("sect_merit",0))
	if status == "outsider":
		if qi:
			life["sect_status"] = "external_disciple"
			return "Você foi aceito como Discípulo Externo."
		life["sect_status"] = "servant"
		return "Sem Qi, você entrou como Servo da Seita. Ainda pode trabalhar, estudar e criar vínculos."
	if status == "servant" and qi:
		life["sect_status"] = "external_disciple"
		return "Após despertar o Qi, sua posição mudou para Discípulo Externo."
	if status == "external_disciple" and merit >= 45:
		life["sect_status"] = "inner_disciple"
		return "Seu mérito abriu caminho para se tornar Discípulo Interno."
	if status == "inner_disciple" and merit >= 120:
		life["sect_status"] = "core_disciple"
		return "A seita agora o reconhece como Discípulo Central."
	return "Sua posição atual ainda não mudou."

static func accept(life:Dictionary,uid:String) -> Dictionary:
	ensure_state(life)
	var active: Array = life["sect_missions"]
	var active_count := 0
	for mission in active:
		if not bool(mission.get("completed",false)) and not bool(mission.get("claimed",false)):
			active_count += 1
	if active_count >= 4:
		return {"ok":false,"text":"Você já carrega quatro missões ativas."}
	var board: Array = life["sect_available"]
	for mission in board:
		if String(mission.get("uid","")) != uid:
			continue
		mission["accepted"] = true
		active.append(mission.duplicate(true))
		return {"ok":true,"text":"Missão aceita: %s" % String(mission.get("title","Missão")),"recommended_realm":int(mission.get("realm",0))}
	return {"ok":false,"text":"A missão já não está disponível."}

static func record_action(life:Dictionary,action:String) -> Array[String]:
	ensure_state(life)
	var completed: Array[String] = []
	for mission in life["sect_missions"]:
		if bool(mission.get("completed",false)) or bool(mission.get("claimed",false)):
			continue
		if String(mission.get("action","")) != action:
			continue
		mission["progress"] = mini(int(mission.get("goal",1)),int(mission.get("progress",0))+1)
		if int(mission["progress"]) >= int(mission.get("goal",1)):
			mission["completed"] = true
			completed.append(String(mission.get("title","Missão")))
	return completed

static func claim(life:Dictionary,uid:String) -> Dictionary:
	ensure_state(life)
	for mission in life["sect_missions"]:
		if String(mission.get("uid","")) != uid:
			continue
		if not bool(mission.get("completed",false)) or bool(mission.get("claimed",false)):
			return {}
		mission["claimed"] = true
		var merit := int(mission.get("merit",0))
		var silver := int(mission.get("silver",0))
		life["sect_merit"] = int(life.get("sect_merit",0))+merit
		life["sect_reputation"] = int(life.get("sect_reputation",0))+merit
		life["silver"] = int(life.get("silver",0))+silver
		return {"title":String(mission.get("title","Missão")),"merit":merit,"silver":silver}
	return {}

static func status_label(status:String) -> String:
	match status:
		"servant": return "Servo da Seita"
		"external_disciple": return "Discípulo Externo"
		"inner_disciple": return "Discípulo Interno"
		"core_disciple": return "Discípulo Central"
		_: return "Sem vínculo formal"
