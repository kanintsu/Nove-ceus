class_name RebornGameState
extends RefCounted

const REALMS:Array[String]=[
	"Corpo Mortal",
	"Refinamento de Qi I","Refinamento de Qi II","Refinamento de Qi III",
	"Refinamento de Qi IV","Refinamento de Qi V","Refinamento de Qi VI",
	"Refinamento de Qi VII","Refinamento de Qi VIII","Refinamento de Qi IX",
	"Estabelecimento de Fundação","Núcleo Dourado","Alma Nascente",
	"Formação do Espírito","Transformação Celestial","Vazio Espiritual",
	"Transcendência","Meio Imortal","Imortal Terreno","Imortal Celestial",
	"Imortal Verdadeiro","Grande Imortal","Rei Imortal","Imperador Imortal",
	"Santo Celestial","Além do Céu"
]

const LOCATIONS:Array[Dictionary]=[
	{"name":"Vila da Nascente","phase":1,"danger":"Baixo","qi":0.25,"kind":"village","desc":"Uma vila mortal entre rios, arrozais e montanhas antigas."},
	{"name":"Cidade Qinghe","phase":2,"danger":"Médio","qi":0.55,"kind":"city","desc":"Mercado, famílias marciais e os primeiros cultivadores conhecidos."},
	{"name":"Seita do Véu Celeste","phase":3,"danger":"Alto","qi":1.0,"kind":"sect","desc":"Montanhas suspensas e pavilhões erguidos sobre veios espirituais."},
	{"name":"Ruínas de Lianshi","phase":4,"danger":"Extremo","qi":1.7,"kind":"ruins","desc":"Formações quebradas, heranças e coisas que deveriam permanecer seladas."},
	{"name":"Palácio dos Nove Céus","phase":5,"danger":"Lendário","qi":2.6,"kind":"celestial","desc":"O limiar entre o mundo conhecido e caminhos além do céu."}
]

var rng:=RandomNumberGenerator.new()

var life_index:=1
var year:=137
var day:=72
var age:=16
var location_index:=0

var silver:=48
var spirit_stones:=0
var dao:=0.0
var knowledge:=0.0
var body:=7.0
var willpower:=54.0
var meridian_integrity:=1.0
var qi_awakened:=false
var realm_index:=0
var cultivation_progress:=0.0
var sect_merit:=0
var sect_status:="Sem vínculo formal"

var inventory:Array[Dictionary]=[
	{"name":"Pão seco","qty":3,"kind":"Comida","rarity":"Comum","desc":"Simples, mas mantém um mortal de pé."},
	{"name":"Erva da margem","qty":4,"kind":"Erva","rarity":"Comum","desc":"Usada por curandeiros locais."},
	{"name":"Faca de ferro","qty":1,"kind":"Equipamento","rarity":"Comum","desc":"Ferramenta e última defesa."},
	{"name":"Manual de respiração","qty":1,"kind":"Manual","rarity":"Incomum","desc":"Método mortal de controle da respiração."}
]

var people:Array[Dictionary]=[
	{"name":"Mei Lan","age":15,"role":"Amiga de infância","bond":14,"trust":11,"path":"Aprendiz de curandeira","story":"Cresceu na mesma vila e conhece seus silêncios melhor que quase todos."},
	{"name":"Velho Shen","age":63,"role":"Ferreiro","bond":8,"trust":9,"path":"Artesão mortal","story":"Diz que um bom metal e uma boa vida exigem o mesmo: tempo e calor."}
]

var world_events:Array[Dictionary]=[
	{"uid":"e1","title":"Chuva Espiritual","location":"Cidade Qinghe","days":18,"danger":1,"text":"Uma chuva rara elevou o Qi regional e atraiu cultivadores."},
	{"uid":"e2","title":"Caravana dos Três Rios","location":"Vila da Nascente","days":22,"danger":0,"text":"Mercadores, notícias e estranhos chegaram à estrada da vila."}
]

var missions:Array[Dictionary]=[
	{"uid":"m1","title":"Ameaça na Região","desc":"Moradores relatam uivos estranhos perto dos arrozais.","progress":0,"goal":1,"reward":58},
	{"uid":"m2","title":"Ervas para a Curandeira","desc":"Mei Lan precisa de ervas frescas antes do anoitecer.","progress":1,"goal":3,"reward":28}
]

var combat:Dictionary={}

func _init()->void:
	rng.randomize()

func current_location()->Dictionary:
	return LOCATIONS[location_index]

func current_phase()->int:
	return int(current_location()["phase"])

func current_realm()->String:
	return REALMS[clampi(realm_index,0,REALMS.size()-1)]

func advance_days(value:int)->void:
	day+=value
	while day>360:
		day-=360
		year+=1
		age+=1

func work()->String:
	advance_days(7)
	var gain:=rng.randi_range(12,23)
	silver+=gain
	body=minf(100.0,body+0.5)
	return "Uma semana de trabalho rendeu %d prata." % gain

func study()->String:
	advance_days(10)
	var gain:=2.5+rng.randf()*2.5
	knowledge=minf(100.0,knowledge+gain)
	return "Você estudou com cuidado. Conhecimento +%.1f%%." % gain

func train()->String:
	advance_days(7)
	var gain:=1.8+rng.randf()*2.2
	body=minf(100.0,body+gain)
	return "Seu corpo ficou mais preparado. Corpo +%.1f." % gain

func listen_rumors()->String:
	advance_days(1)
	var rumors=[
		"Uma família de Qinghe procura jovens para um teste espiritual.",
		"Caçadores viram luzes azuis dentro da floresta durante a madrugada.",
		"Um discípulo da Seita do Véu Celeste desapareceu perto de Lianshi.",
		"Há quem diga que um mortal encontrou uma fruta capaz de abrir meridianos."
	]
	return rumors[rng.randi_range(0,rumors.size()-1)]

func travel_to(index:int)->String:
	index=clampi(index,0,LOCATIONS.size()-1)
	if index==location_index:return "Você já está aqui."
	var distance:=absi(index-location_index)
	advance_days(2+distance*3)
	location_index=index
	return "Você chegou a %s." % current_location()["name"]

func meditate(mode:String)->String:
	if not qi_awakened:
		var chance:=0.03+knowledge*0.0008+willpower*0.0005
		advance_days(14)
		if rng.randf()<chance:
			qi_awakened=true
			realm_index=1
			cultivation_progress=4.0
			return "Pela primeira vez, você sentiu Qi entrando nos meridianos."
		return "Nada respondeu. Talvez esta vida ainda não possua um caminho aberto."
	var mult:=1.0
	var risk:=0.01
	var days:=14
	match mode:
		"safe": mult=0.8; risk=0.005; days=18
		"compress": mult=1.25; risk=0.035; days=16
		"temper": mult=0.65; risk=0.015; days=22
		"insight": mult=0.4; risk=0.008; days=20; dao+=2.0
		"reckless": mult=1.7; risk=0.10; days=10
	advance_days(days)
	var local_qi:=float(current_location()["qi"])
	var gain:=(4.0+willpower/20.0)*local_qi*mult
	cultivation_progress=minf(100.0,cultivation_progress+gain)
	if rng.randf()<risk:
		meridian_integrity=maxf(0.2,meridian_integrity-0.08)
		return "O Qi saiu do controle. Progresso +%.1f%%, mas seus meridianos foram feridos." % gain
	return "Sessão concluída. Progresso +%.1f%%." % gain

func breakthrough()->String:
	if cultivation_progress<100.0:return "Seu acúmulo ainda não chegou ao limite."
	var chance:=clampf(0.52+dao*0.004+meridian_integrity*0.25,0.15,0.92)
	if rng.randf()<chance:
		realm_index=min(realm_index+1,REALMS.size()-1)
		cultivation_progress=0.0
		return "O gargalo se rompeu. Você alcançou %s." % current_realm()
	meridian_integrity=maxf(0.2,meridian_integrity-0.07)
	cultivation_progress=82.0
	return "O avanço falhou. Sua base resistiu, mas os meridianos sofreram."

func start_combat()->void:
	var phase:=current_phase()
	var enemy_names=["Lobo Cinzento","Bandido Marcial","Serpente de Jade","Guardião de Lianshi","Sentinela Celestial"]
	var hp:=70+phase*55
	combat={
		"enemy":enemy_names[phase-1],
		"enemy_hp":hp,
		"enemy_max_hp":hp,
		"enemy_attack":7+phase*8,
		"player_hp":100+realm_index*10+int(body),
		"player_max_hp":100+realm_index*10+int(body),
		"guard":0,
		"focus":0,
		"qi":3 if qi_awakened else 0,
		"turn":1,
		"log":"A ameaça mede seus movimentos."
	}

func combat_action(action:String)->String:
	if combat.is_empty():return "Não há combate."
	var enemy_hp:=int(combat["enemy_hp"])
	var player_hp:=int(combat["player_hp"])
	var guard:=int(combat.get("guard",0))
	match action:
		"strike":
			var dmg:=maxi(1,10+int(body*0.25)+realm_index*3+rng.randi_range(-2,4))
			enemy_hp=maxi(0,enemy_hp-dmg)
			combat["log"]="Você causa %d de dano." % dmg
		"guard":
			combat["guard"]=18+realm_index*2
			combat["log"]="Você fecha a guarda."
		"observe":
			combat["focus"]=mini(5,int(combat.get("focus",0))+2)
			combat["log"]="Você observa e encontra uma abertura."
		"technique":
			if int(combat.get("qi",0))<=0:
				combat["log"]="Você não possui Qi disponível."
			else:
				combat["qi"]=int(combat["qi"])-1
				var qd:=20+realm_index*5+int(combat.get("focus",0))*2
				enemy_hp=maxi(0,enemy_hp-qd)
				combat["log"]="Sua técnica causa %d de dano." % qd
		"flee":
			if rng.randf()<0.55:
				combat.clear()
				return "Você escapou."
			combat["log"]="A fuga falhou."
	combat["enemy_hp"]=enemy_hp
	if enemy_hp<=0:
		var reward:=20+current_phase()*18
		silver+=reward
		combat.clear()
		return "Vitória. Você obteve %d prata." % reward
	var incoming:=maxi(0,int(combat["enemy_attack"])-guard+rng.randi_range(-2,3))
	player_hp=maxi(0,player_hp-incoming)
	combat["guard"]=0
	combat["player_hp"]=player_hp
	if player_hp<=0:
		combat.clear()
		return "Você foi derrotado e sobreviveu por pouco."
	combat["turn"]=int(combat["turn"])+1
	return String(combat["log"])+" O inimigo causa %d de dano." % incoming


func interact_person(index:int,action:String)->String:
	if index<0 or index>=people.size():return "Essa pessoa já não está por perto."
	var person:Dictionary=people[index]
	match action:
		"talk":
			person["bond"]=int(person.get("bond",0))+2
			person["trust"]=int(person.get("trust",0))+1
			advance_days(1)
			return "Vocês conversaram por horas. O vínculo cresceu."
		"teach":
			person["bond"]=int(person.get("bond",0))+1
			person["trust"]=int(person.get("trust",0))+2
			knowledge=minf(100.0,knowledge+0.7)
			advance_days(5)
			return "Você ensinou o que sabia e também aprendeu ao explicar."
		"train":
			person["bond"]=int(person.get("bond",0))+1
			body=minf(100.0,body+1.0)
			advance_days(4)
			return "Treinaram juntos. Nem todo crescimento depende de Qi."
		"support":
			if silver<20:return "Você não possui prata suficiente."
			silver-=20
			person["bond"]=int(person.get("bond",0))+3
			person["trust"]=int(person.get("trust",0))+2
			advance_days(1)
			return "Você gastou recursos para apoiar essa pessoa."
	return "Nada mudou."

func sect_service()->String:
	advance_days(7)
	sect_merit+=rng.randi_range(1,3)
	if sect_status=="Sem vínculo formal":sect_status="Servo da Seita"
	elif sect_status=="Servo da Seita" and qi_awakened and sect_merit>=8:sect_status="Discípulo Externo"
	elif sect_status=="Discípulo Externo" and sect_merit>=45:sect_status="Discípulo Interno"
	elif sect_status=="Discípulo Interno" and sect_merit>=120:sect_status="Discípulo Central"
	return "Você cumpriu deveres da seita. Mérito atual: %d." % sect_merit

func resolve_event(uid:String)->String:
	for event in world_events:
		if String(event.get("uid",""))!=uid:continue
		var title:=String(event.get("title","Evento"))
		if title=="Chuva Espiritual":
			travel_to(1)
			if qi_awakened:
				cultivation_progress=minf(100.0,cultivation_progress+10.0)
				dao+=1.0
				return "Você alcançou Qinghe durante a Chuva Espiritual. Cultivo +10% e Dao +1."
			knowledge=minf(100.0,knowledge+2.0)
			return "Você viu cultivadores absorvendo a chuva. Sem Qi, restou observar e aprender."
		if title=="Caravana dos Três Rios":
			var gain:=rng.randi_range(18,40)
			silver+=gain
			advance_days(2)
			return "Você negociou com a caravana e ganhou %d prata." % gain
		return "Você acompanhou o evento até o fim."
	return "Esse evento já não está disponível."

func mark_mission(uid:String)->String:
	for mission in missions:
		if String(mission.get("uid",""))==uid:
			return "Missão marcada: %s." % String(mission["title"])
	return "Missão não encontrada."

func reincarnate()->String:
	var passed:=rng.randi_range(6,45)
	year+=passed
	life_index+=1
	age=16
	day=rng.randi_range(1,360)
	location_index=0
	silver=30+rng.randi_range(0,35)
	spirit_stones=0
	dao=maxf(0.0,dao*0.18)
	knowledge=maxf(0.0,knowledge*0.22)
	body=5.0+rng.randf()*5.0
	meridian_integrity=1.0
	qi_awakened=false
	realm_index=0
	cultivation_progress=0.0
	combat.clear()
	return "A roda girou. %d anos passaram e a Vida %d começou." % [passed,life_index]
