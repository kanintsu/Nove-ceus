class_name JourneySystem
extends RefCounted

const ROUTES: Dictionary = {
	"safe":{"name":"Rota cautelosa","risk":-2,"discovery":1,"days":2,"text":"Avança devagar, marca o caminho e evita sinais de perigo."},
	"balanced":{"name":"Rota desconhecida","risk":0,"discovery":2,"days":1,"text":"Segue pistas promissoras sem ignorar completamente o risco."},
	"deep":{"name":"Rota profunda","risk":3,"discovery":4,"days":1,"text":"Abandona trilhas seguras para procurar aquilo que outros não encontraram."}
}

static func create_journey(location: Dictionary, phase: int) -> Dictionary:
	var base_risk: int = {"Baixo":1,"Médio":2,"Alto":4,"Extremo":6,"Lendário":8}.get(String(location.get("danger","Baixo")),2)
	return {
		"phase":phase,
		"step":1,
		"max_steps":3,
		"risk":base_risk,
		"discovery":0,
		"supplies":3,
		"finished":false,
		"abandoned":false,
		"log":[],
		"location_name":String(location.get("name","Local desconhecido")),
	}

static func choose_route(journey: Dictionary, route_key: String, life: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var route: Dictionary = ROUTES.get(route_key,ROUTES["balanced"])
	var knowledge: float = float(life.get("worldly_knowledge",0.0))
	var willpower: float = float(life.get("willpower",50))
	var risk: int = maxi(0,int(journey.get("risk",0))+int(route["risk"])-int(knowledge/40.0))
	var discovery: int = int(journey.get("discovery",0))+int(route["discovery"])
	var supplies: int = int(journey.get("supplies",0))-1
	journey["risk"] = risk
	journey["discovery"] = discovery
	journey["supplies"] = supplies

	var roll: float = rng.randf()
	var event_type := "quiet"
	var text := String(route["text"])
	if roll < minf(0.58,float(risk)*0.065):
		event_type = "danger"
		text += "\nVocê percebe sinais de uma ameaça próxima."
	elif roll > 0.82-minf(0.20,float(discovery)*0.02):
		event_type = "discovery"
		text += "\nAlgo fora do comum chama sua atenção."
	elif willpower > 75.0 and rng.randf() < 0.12:
		event_type = "insight"
		text += "\nA jornada força você a compreender algo sobre medo e persistência."

	return {
		"type":event_type,
		"text":text,
		"days":int(route["days"]),
		"risk":risk,
		"discovery":discovery,
		"supplies":supplies,
	}

static func advance_step(journey: Dictionary) -> void:
	journey["step"] = int(journey.get("step",1))+1
	if int(journey["step"]) > int(journey.get("max_steps",3)):
		journey["finished"] = true

static func final_quality(journey: Dictionary) -> int:
	var discovery: int = int(journey.get("discovery",0))
	var risk: int = int(journey.get("risk",0))
	return clampi(discovery+int(risk/3.0),1,12)
