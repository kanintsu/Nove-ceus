class_name CultivationSession
extends RefCounted

const MODES: Dictionary = {
	"safe":{
		"name":"Circulação segura",
		"days":15,
		"progress_mult":0.72,
		"risk":0.008,
		"meridian":0.012,
		"dao":0.3,
		"text":"Circula Qi lentamente, priorizando controle e estabilidade."
	},
	"compress":{
		"name":"Comprimir Qi",
		"days":18,
		"progress_mult":1.18,
		"risk":0.035,
		"meridian":-0.005,
		"dao":0.1,
		"text":"Força maior densidade de Qi no dantian para acelerar o progresso."
	},
	"temper":{
		"name":"Temperar meridianos",
		"days":24,
		"progress_mult":0.58,
		"risk":0.018,
		"meridian":0.035,
		"dao":0.2,
		"text":"Aceita dor e lentidão para fortalecer o caminho por onde o Qi circula."
	},
	"insight":{
		"name":"Contemplar o Dao",
		"days":21,
		"progress_mult":0.34,
		"risk":0.010,
		"meridian":0.004,
		"dao":2.6,
		"text":"Troca velocidade de cultivo por compreensão e uma fundação mais consciente."
	},
	"reckless":{
		"name":"Absorção imprudente",
		"days":10,
		"progress_mult":1.62,
		"risk":0.095,
		"meridian":-0.020,
		"dao":0.0,
		"text":"Absorve tudo o que consegue sem respeitar completamente os limites do corpo."
	}
}

static func perform(mode_key: String, life: Dictionary, local_qi: float, rng: RandomNumberGenerator) -> Dictionary:
	var mode: Dictionary = MODES.get(mode_key,MODES["safe"])
	var realm: int = int(life.get("realm_index",1))
	var willpower: float = float(life.get("willpower",50))
	var intelligence: float = float(life.get("intelligence",50))
	var integrity: float = float(life.get("meridian_integrity",1.0))
	var base: float = 4.0+willpower/24.0+intelligence/70.0
	var realm_penalty: float = 1.0
	if realm >= 10:
		realm_penalty *= 0.62
	if realm >= 14:
		realm_penalty *= 0.70
	if realm >= 17:
		realm_penalty *= 0.68
	var progress: float = base*maxf(0.25,local_qi)*float(mode["progress_mult"])*realm_penalty
	var risk: float = float(mode["risk"])*maxf(0.55,local_qi)*maxf(0.7,1.22-integrity)
	var deviation := rng.randf() < minf(risk,0.38)
	var meridian_delta: float = float(mode["meridian"])
	var dao_gain: float = float(mode["dao"])
	var text: String = String(mode["text"])
	if deviation:
		meridian_delta -= 0.075+local_qi*0.008
		progress *= 0.62
		text += "\nO fluxo saiu do controle e feriu seus meridianos."
	elif mode_key == "temper" and rng.randf() < 0.14:
		meridian_delta += 0.018
		text += "\nSeu corpo respondeu melhor do que o esperado ao tempero."
	elif mode_key == "insight" and rng.randf() < 0.10:
		dao_gain *= 2.0
		text += "\nUm instante de clareza tornou a contemplação extraordinariamente produtiva."

	return {
		"name":String(mode["name"]),
		"days":int(mode["days"]),
		"progress":progress,
		"risk":risk,
		"deviation":deviation,
		"meridian_delta":meridian_delta,
		"dao_gain":dao_gain,
		"text":text,
	}
