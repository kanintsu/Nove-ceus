class_name RelationshipSystem
extends RefCounted

static func ensure_person(person: Dictionary) -> void:
	if not person.has("bond"):
		person["bond"] = 0
	if not person.has("trust"):
		person["trust"] = 0
	if not person.has("training_support"):
		person["training_support"] = 0
	if not person.has("education_support"):
		person["education_support"] = 0

static func interact(person: Dictionary, action: String, patron_life: Dictionary) -> Dictionary:
	ensure_person(person)
	var bond: int = int(person.get("bond",0))
	var trust: int = int(person.get("trust",0))
	match action:
		"talk":
			person["bond"] = bond+2
			person["trust"] = trust+1
			return {"days":1,"text":"Vocês conversaram sem transformar a relação em um número de missão.","silver":0}
		"teach":
			person["bond"] = bond+1
			person["trust"] = trust+2
			person["education_support"] = int(person.get("education_support",0))+2
			person["career_progress"] = float(person.get("career_progress",0.0))+1.5
			return {"days":7,"text":"Você dedicou uma semana a ensinar o que sabe.","silver":0}
		"train":
			person["bond"] = bond+1
			person["training_support"] = int(person.get("training_support",0))+2
			person["career_progress"] = float(person.get("career_progress",0.0))+1.2
			return {"days":7,"text":"Vocês treinaram juntos. O resultado depende do corpo e do caminho dessa pessoa.","silver":0}
		"support":
			var cost: int = 20
			if int(patron_life.get("silver",0)) < cost:
				return {"days":0,"text":"Você não possui prata suficiente para oferecer apoio material.","silver":0}
			patron_life["silver"] = int(patron_life.get("silver",0))-cost
			person["bond"] = bond+3
			person["trust"] = trust+2
			person["career_progress"] = float(person.get("career_progress",0.0))+2.0
			return {"days":1,"text":"Você gastou recursos para melhorar as condições dessa pessoa.","silver":-cost}
	return {"days":0,"text":"Nada mudou.","silver":0}

static func relation_title(person: Dictionary) -> String:
	ensure_person(person)
	var bond: int = int(person.get("bond",0))
	var trust: int = int(person.get("trust",0))
	if trust >= 18 and bond >= 22:
		return "vínculo profundo"
	if trust >= 10 and bond >= 12:
		return "confiança forte"
	if bond >= 6:
		return "próximo"
	return "recente"
