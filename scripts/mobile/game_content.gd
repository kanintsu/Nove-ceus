class_name GameContent
extends RefCounted

const PHASES: Array[Dictionary] = [
	{
		"id":"phase_1",
		"number":1,
		"name":"Vale Mortal da Nascente",
		"subtitle":"Onde uma vida comum pode terminar sem jamais tocar o Qi.",
		"required_realm":0,
		"theme":"mortal_valley",
		"accent":"jade",
		"goal":"Sobreviver, construir uma vida mortal e descobrir se existe um caminho além do corpo comum.",
	},
	{
		"id":"phase_2",
		"number":2,
		"name":"Qinghe e as Rotas do Mundo",
		"subtitle":"Comércio, famílias, rumores, oportunidades e as primeiras escolhas que deixam marcas.",
		"required_realm":1,
		"theme":"qinghe",
		"accent":"amber",
		"goal":"Entrar no mundo dos cultivadores sem perder sua identidade, relações e recursos mortais.",
	},
	{
		"id":"phase_3",
		"number":3,
		"name":"Montanha do Véu Celeste",
		"subtitle":"Técnicas, mestres, disciplina, rivalidade e o peso real de uma seita.",
		"required_realm":4,
		"theme":"veiled_mountain",
		"accent":"azure",
		"goal":"Aprender técnicas verdadeiras, criar vínculos e provar que sua fundação merece permanecer.",
	},
	{
		"id":"phase_4",
		"number":4,
		"name":"Terras Selvagens Ancestrais",
		"subtitle":"Bestas, ruínas e tesouros que não existem para recompensar o jogador.",
		"required_realm":10,
		"theme":"ancestral_wilds",
		"accent":"crimson",
		"goal":"Sobreviver a territórios que não pertencem aos humanos e conquistar oportunidades que outros também desejam.",
	},
	{
		"id":"phase_5",
		"number":5,
		"name":"Palácio dos Nove Céus",
		"subtitle":"Tribulações, legado, Dao e o caminho para romper os limites do mundo conhecido.",
		"required_realm":17,
		"theme":"nine_heavens",
		"accent":"celestial",
		"goal":"Enfrentar tribulação, compreender seu Dao e decidir o que sua existência deixará para o mundo.",
	}
]

const LOCATIONS: Dictionary = {
	"spring_village":{
		"name":"Vila da Nascente","phase":1,"danger":"Baixo","qi":0.28,"travel":0,
		"desc":"Campos, casas de madeira e vidas mortais que raramente ouvem falar de cultivadores.",
		"actions":["work","study","train","rumors"],"tags":["mortal","village"]
	},
	"qinghe_road":{
		"name":"Estrada de Qinghe","phase":1,"danger":"Baixo","qi":0.32,"travel":2,
		"desc":"Uma rota de carroças, viajantes e histórias que podem ser verdade ou superstição.",
		"actions":["travel","rumors","encounter"],"tags":["road"]
	},
	"willow_grove":{
		"name":"Bosque dos Salgueiros","phase":1,"danger":"Baixo","qi":0.38,"travel":3,
		"desc":"Um bosque silencioso usado por herbalistas e crianças da vila.",
		"actions":["gather","meditate","encounter"],"tags":["forest","herbs"]
	},
	"cold_mist_forest":{
		"name":"Floresta da Névoa Fria","phase":1,"danger":"Médio","qi":0.72,"travel":4,
		"desc":"A névoa esconde ervas, animais e pegadas grandes demais para um caçador comum.",
		"actions":["gather","hunt","explore"],"tags":["forest","beasts"]
	},
	"abandoned_temple":{
		"name":"Templo Abandonado","phase":1,"danger":"Médio","qi":0.84,"travel":5,
		"desc":"Ídolos rachados e inscrições de uma fé esquecida. O ar parece mais pesado ao anoitecer.",
		"actions":["study","explore","meditate"],"tags":["ruin","lore"]
	},
	"clearwater_cave":{
		"name":"Caverna da Água Clara","phase":1,"danger":"Médio","qi":0.93,"travel":6,
		"desc":"Uma nascente fria corre entre pedras antigas. Alguns juram sentir algo diferente aqui.",
		"actions":["meditate","gather","explore"],"tags":["cave","spring"]
	},
	"mortal_training_field":{
		"name":"Campo Marcial Mortal","phase":1,"danger":"Baixo","qi":0.20,"travel":1,
		"desc":"Soldados aposentados e artistas marciais treinam corpos que jamais tocaram o Qi.",
		"actions":["train","spar","study"],"tags":["martial"]
	},
	"old_stone_bridge":{
		"name":"Ponte de Pedra Antiga","phase":1,"danger":"Baixo","qi":0.30,"travel":2,
		"desc":"A ponte liga aldeias há séculos. Mercadores, mendigos e viajantes param aqui.",
		"actions":["rumors","encounter","trade"],"tags":["road","social"]
	},

	"qinghe_city":{
		"name":"Cidade Qinghe","phase":2,"danger":"Baixo","qi":0.68,"travel":8,
		"desc":"Uma cidade regional grande o bastante para atrair famílias marciais e pequenos cultivadores.",
		"actions":["trade","spirit_test","work","rumors"],"tags":["city"]
	},
	"lower_jade_market":{
		"name":"Mercado do Jade Baixo","phase":2,"danger":"Baixo","qi":0.62,"travel":8,
		"desc":"Ervas, minério, talismãs duvidosos e mercadorias de três reinos chegam a este mercado.",
		"actions":["trade","auction","rumors"],"tags":["market"]
	},
	"hundred_lantern_auction":{
		"name":"Casa das Cem Lanternas","phase":2,"danger":"Baixo","qi":0.75,"travel":9,
		"desc":"Leilões discretos misturam relíquias verdadeiras, falsificações e fortunas familiares.",
		"actions":["auction","trade","encounter"],"tags":["auction"]
	},
	"qinghe_library":{
		"name":"Biblioteca de Qinghe","phase":2,"danger":"Baixo","qi":0.54,"travel":8,
		"desc":"Registros sobre história, medicina, engenharia, guerras e fragmentos de relatos espirituais.",
		"actions":["study","research"],"tags":["knowledge"]
	},
	"smiths_district":{
		"name":"Distrito dos Ferreiros","phase":2,"danger":"Baixo","qi":0.46,"travel":9,
		"desc":"Forjas trabalham noite e dia. Um mortal inteligente pode construir um legado aqui.",
		"actions":["work","forge","trade"],"tags":["craft"]
	},
	"white_crane_inn":{
		"name":"Estalagem Garça Branca","phase":2,"danger":"Baixo","qi":0.50,"travel":8,
		"desc":"Mercadores e viajantes espalham rumores antes que eles cheguem aos salões oficiais.",
		"actions":["rumors","rest","encounter"],"tags":["social"]
	},
	"qing_river_docks":{
		"name":"Cais do Rio Qing","phase":2,"danger":"Baixo","qi":0.57,"travel":10,
		"desc":"Barcos trazem grãos, madeira, minério e pessoas de lugares que você ainda não conhece.",
		"actions":["work","travel","trade"],"tags":["river"]
	},
	"old_graves_hill":{
		"name":"Colina dos Túmulos Antigos","phase":2,"danger":"Médio","qi":0.96,"travel":11,
		"desc":"Famílias locais evitam a colina após o pôr do sol. Algumas lápides não possuem nomes.",
		"actions":["explore","study","encounter"],"tags":["grave","mystery"]
	},

	"veiled_gate":{
		"name":"Portão do Céu Velado","phase":3,"danger":"Médio","qi":1.35,"travel":14,
		"desc":"O primeiro portão da seita. Entrar é um privilégio; permanecer é mais difícil.",
		"actions":["sect","test","rumors"],"tags":["sect"]
	},
	"outer_courtyard":{
		"name":"Pátio dos Discípulos","phase":3,"danger":"Baixo","qi":1.48,"travel":14,
		"desc":"Centenas treinam, competem e tentam chamar a atenção de alguém acima deles.",
		"actions":["train","spar","relationships"],"tags":["sect","social"]
	},
	"technique_pavilion":{
		"name":"Pavilhão das Técnicas","phase":3,"danger":"Baixo","qi":1.62,"travel":15,
		"desc":"Manuais são guardados por mérito, posição e segredos que a seita não entrega de graça.",
		"actions":["study","technique"],"tags":["sect","knowledge"]
	},
	"spirit_herb_garden":{
		"name":"Jardim das Ervas Espirituais","phase":3,"danger":"Baixo","qi":1.78,"travel":15,
		"desc":"Ervas são cultivadas por anos ou décadas. Colher sem permissão pode destruir uma carreira.",
		"actions":["alchemy","gather","work"],"tags":["herbs","sect"]
	},
	"meditation_lake":{
		"name":"Lago da Meditação","phase":3,"danger":"Baixo","qi":2.05,"travel":16,
		"desc":"A superfície quase imóvel reflete o fluxo de Qi nas noites sem lua.",
		"actions":["meditate","comprehend"],"tags":["cultivation"]
	},
	"trial_cliff":{
		"name":"Penhasco da Provação","phase":3,"danger":"Alto","qi":2.18,"travel":17,
		"desc":"Discípulos enfrentam medo, vento, formações e a própria arrogância.",
		"actions":["trial","train"],"tags":["trial"]
	},
	"sword_graveyard":{
		"name":"Cemitério das Espadas","phase":3,"danger":"Alto","qi":2.42,"travel":18,
		"desc":"Milhares de lâminas quebradas guardam intenções deixadas por cultivadores mortos.",
		"actions":["comprehend","explore"],"tags":["sword","legacy"]
	},
	"veiled_peak":{
		"name":"Pico do Véu Celeste","phase":3,"danger":"Alto","qi":2.80,"travel":19,
		"desc":"Anciões cultivam em cavernas fechadas e nuvens passam abaixo dos pavilhões.",
		"actions":["meditate","sect","encounter"],"tags":["peak"]
	},

	"lianshi_ruins":{
		"name":"Ruínas de Lianshi","phase":4,"danger":"Alto","qi":3.10,"travel":24,
		"desc":"Uma antiga potência desapareceu; suas formações ainda não entenderam que seus mestres morreram.",
		"actions":["explore","inheritance","formations"],"tags":["ruin","legacy"]
	},
	"hundred_beasts_valley":{
		"name":"Vale das Cem Bestas","phase":4,"danger":"Extremo","qi":3.35,"travel":25,
		"desc":"Territórios se sobrepõem. Entrar sem conhecer cheiro, vento e hierarquia das bestas é suicídio.",
		"actions":["hunt","observe","explore"],"tags":["beasts"]
	},
	"crimson_forest":{
		"name":"Floresta Rubra","phase":4,"danger":"Alto","qi":3.22,"travel":26,
		"desc":"Folhas vermelhas absorvem traços de energia de sangue deixados por batalhas antigas.",
		"actions":["gather","explore","comprehend"],"tags":["forest","blood"]
	},
	"broken_spirit_mine":{
		"name":"Mina Espiritual Fraturada","phase":4,"danger":"Alto","qi":3.55,"travel":27,
		"desc":"Veios espirituais racharam a montanha. Clãs e feras disputam o que ainda resta.",
		"actions":["mine","territory","explore"],"tags":["mine","territory"]
	},
	"black_mirror_lake":{
		"name":"Lago do Espelho Negro","phase":4,"danger":"Extremo","qi":3.75,"travel":28,
		"desc":"A água reflete coisas que não estão atrás de você.",
		"actions":["comprehend","explore"],"tags":["mystery","soul"]
	},
	"shattered_cloud_sea":{
		"name":"Mar das Nuvens Partidas","phase":4,"danger":"Extremo","qi":4.05,"travel":29,
		"desc":"Ilhas flutuantes aparecem e desaparecem entre tempestades espirituais.",
		"actions":["travel","explore","inheritance"],"tags":["sky","secret"]
	},
	"broken_peak":{
		"name":"Pico Quebrado","phase":4,"danger":"Extremo","qi":4.22,"travel":30,
		"desc":"Uma única batalha partiu a montanha séculos atrás. A intenção residual ainda corta pedra.",
		"actions":["comprehend","train"],"tags":["battlefield"]
	},
	"beast_ancestor_shrine":{
		"name":"Santuário do Ancestral Bestial","phase":4,"danger":"Extremo","qi":4.50,"travel":31,
		"desc":"Totens antigos sugerem que humanos não foram os primeiros cultivadores desta região.",
		"actions":["legacy","beast_pact","explore"],"tags":["beasts","legacy"]
	},

	"celestial_stair":{
		"name":"Escadaria Celestial","phase":5,"danger":"Lendário","qi":5.40,"travel":38,
		"desc":"Cada degrau pressiona corpo, alma e intenção. Muitos chegam aqui; poucos continuam.",
		"actions":["trial","ascend"],"tags":["celestial"]
	},
	"nine_heavens_palace":{
		"name":"Palácio dos Nove Céus","phase":5,"danger":"Lendário","qi":6.00,"travel":39,
		"desc":"Pavilhões suspensos em um mar de luz guardam registros de eras esquecidas.",
		"actions":["legacy","study","court"],"tags":["celestial","palace"]
	},
	"destiny_hall":{
		"name":"Salão do Destino","phase":5,"danger":"Lendário","qi":6.25,"travel":40,
		"desc":"Inscrições registram nomes que mudaram eras — e nomes apagados de propósito.",
		"actions":["karma","legacy","comprehend"],"tags":["destiny"]
	},
	"dao_mirror_lake":{
		"name":"Lago do Espelho do Dao","phase":5,"danger":"Lendário","qi":6.45,"travel":41,
		"desc":"Não reflete rosto ou corpo, apenas aquilo que o cultivador acredita ser seu caminho.",
		"actions":["comprehend","meditate"],"tags":["dao"]
	},
	"tribulation_tower":{
		"name":"Torre da Tribulação","phase":5,"danger":"Lendário","qi":6.80,"travel":42,
		"desc":"Raios antigos dormem dentro da torre. Alguns afirmam que ela escolhe quem merece sofrer.",
		"actions":["tribulation","train"],"tags":["tribulation"]
	},
	"immortality_garden":{
		"name":"Jardim da Imortalidade","phase":5,"danger":"Lendário","qi":7.10,"travel":43,
		"desc":"Plantas aqui contam idade em séculos. Uma única colheita pode iniciar uma guerra.",
		"actions":["alchemy","gather","legacy"],"tags":["herbs","celestial"]
	},
	"broken_ancient_throne":{
		"name":"Trono Quebrado dos Antigos","phase":5,"danger":"Lendário","qi":7.35,"travel":44,
		"desc":"Ninguém lembra quem se sentava aqui. Ainda assim, o mundo parece inclinar-se diante do trono.",
		"actions":["legacy","comprehend"],"tags":["ancient"]
	},
	"ascension_gate":{
		"name":"Portal da Ascensão","phase":5,"danger":"Lendário","qi":8.00,"travel":45,
		"desc":"Além dele não existe promessa de vitória — apenas outro céu acima deste.",
		"actions":["ascend","tribulation"],"tags":["ascension"]
	}
}

static func phase(number: int) -> Dictionary:
	for entry in PHASES:
		if int(entry["number"]) == number:
			return entry
	return PHASES[0]

static func phase_locations(number: int) -> Array[String]:
	var result: Array[String] = []
	for key in LOCATIONS.keys():
		if int(LOCATIONS[key]["phase"]) == number:
			result.append(String(key))
	result.sort_custom(func(a: String,b: String) -> bool:
		return int(LOCATIONS[a]["travel"]) < int(LOCATIONS[b]["travel"])
	)
	return result

static func unlocked_phase_for_realm(realm_index: int) -> int:
	var unlocked := 1
	for entry in PHASES:
		if realm_index >= int(entry["required_realm"]):
			unlocked = int(entry["number"])
	return unlocked
