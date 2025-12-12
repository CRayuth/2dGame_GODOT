extends Node

# Audio Manager Singleton
# Ensures background music plays across all scenes

var music_player: AudioStreamPlayer
var current_music_stream: AudioStream

func _ready():
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"
	music_player.stream = null
	# Music will be started from main menu

func play_music(stream: AudioStream, loop: bool = true):
	if stream == null:
		return
	
	if music_player == null:
		_ready()
	
	# Set looping on the stream resource itself (Godot 4)
	# AudioStreamMP3 has a 'loop' property that can be set
	if stream is AudioStreamMP3:
		stream.loop = loop
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	
	current_music_stream = stream
	music_player.stream = stream
	if not music_player.playing:
		music_player.play()

func stop_music():
	if music_player != null:
		music_player.stop()

func set_music_volume(volume: float):
	# Volume is handled by SettingsManager through audio bus
	pass
