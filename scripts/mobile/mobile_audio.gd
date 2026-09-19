class_name MobileAudio
extends Node

var music_player := AudioStreamPlayer.new()
var sfx_player := AudioStreamPlayer.new()
var music_enabled := true
var sfx_enabled := true
var current_phase := 0

const SAMPLE_RATE := 22050
const THEME_NOTES := {
	1:[220.0,293.66,329.63,440.0,329.63,293.66],
	2:[246.94,329.63,369.99,493.88,369.99,329.63],
	3:[261.63,392.0,440.0,523.25,440.0,392.0],
	4:[196.0,261.63,311.13,392.0,311.13,261.63],
	5:[293.66,440.0,523.25,587.33,659.25,523.25],
}

func _ready() -> void:
	add_child(music_player)
	add_child(sfx_player)
	music_player.volume_db = -17.0
	sfx_player.volume_db = -8.0

func play_phase_theme(phase: int) -> void:
	if not music_enabled:
		return
	phase = clampi(phase,1,5)
	if current_phase == phase and music_player.playing:
		return
	current_phase = phase
	music_player.stop()
	music_player.stream = _make_theme(phase)
	music_player.play()

func play_sfx(kind: String) -> void:
	if not sfx_enabled:
		return
	var params := {
		"tap":[620.0,0.055,0.22],
		"travel":[410.0,0.18,0.30],
		"item":[880.0,0.22,0.34],
		"qi":[520.0,0.50,0.38],
		"breakthrough":[740.0,0.85,0.42],
		"danger":[130.0,0.55,0.40],
		"death":[92.0,1.10,0.34],
		"rare":[1046.5,0.65,0.36],
	}
	var p: Array = params.get(kind,[520.0,0.10,0.25])
	sfx_player.stop()
	sfx_player.stream = _make_sfx(float(p[0]),float(p[1]),float(p[2]),kind)
	sfx_player.play()

func set_music_enabled(value: bool) -> void:
	music_enabled = value
	if not value:
		music_player.stop()
	elif current_phase > 0:
		play_phase_theme(current_phase)

func set_sfx_enabled(value: bool) -> void:
	sfx_enabled = value

func _make_theme(phase: int) -> AudioStreamWAV:
	var duration := 12.0
	var frames := int(SAMPLE_RATE*duration)
	var data := PackedByteArray()
	data.resize(frames*2)
	var notes: Array = THEME_NOTES[phase]
	for i in range(frames):
		var t := float(i)/SAMPLE_RATE
		var step := int(t/2.0) % notes.size()
		var f := float(notes[step])
		var pulse := sin(TAU*f*t)*0.22
		var high := sin(TAU*(f*2.0)*t+0.8)*0.06
		var drone := sin(TAU*(f/2.0)*t)*0.12
		var breath := sin(TAU*0.083*t)*0.04
		var env := 0.72 + 0.28*sin(PI*fmod(t,2.0)/2.0)
		var sample := (pulse+high+drone+breath)*env
		if phase == 4:
			sample += sin(TAU*65.0*t)*0.045
		elif phase == 5:
			sample += sin(TAU*(f*1.5)*t)*0.055
		var value := clampi(int(sample*28000.0),-32768,32767)
		data[i*2] = value & 0xff
		data[i*2+1] = (value >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frames
	stream.data = data
	return stream

func _make_sfx(freq: float,duration: float,gain: float,kind: String) -> AudioStreamWAV:
	var frames := maxi(1,int(SAMPLE_RATE*duration))
	var data := PackedByteArray()
	data.resize(frames*2)
	for i in range(frames):
		var t := float(i)/SAMPLE_RATE
		var progress := t/duration
		var env := pow(maxf(0.0,1.0-progress),1.8)
		var f := freq
		if kind == "breakthrough":
			f = freq*(1.0+progress*1.7)
		elif kind == "death":
			f = freq*(1.0-progress*0.55)
		elif kind == "travel":
			f = freq*(1.0+0.08*sin(TAU*6.0*t))
		var sample := sin(TAU*f*t)*gain*env
		if kind in ["qi","rare","breakthrough"]:
			sample += sin(TAU*f*1.5*t)*gain*0.35*env
		if kind == "danger":
			sample += sin(TAU*freq*0.5*t)*gain*0.45*env
		var value := clampi(int(sample*30000.0),-32768,32767)
		data[i*2] = value & 0xff
		data[i*2+1] = (value >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream
