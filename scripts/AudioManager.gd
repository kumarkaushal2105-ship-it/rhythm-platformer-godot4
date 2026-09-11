extends Node

# Audio and beat synchronization
var music_player: AudioStreamPlayer
var beat_duration: float = 0.5  # 120 BPM = 0.5s per beat
var current_beat: int = 0
var music_time: float = 0.0

signal beat_triggered(beat: int)
signal measure_triggered(measure: int)

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = &"Master"

func _process(delta: float) -> void:
	if music_player.playing:
		music_time = music_player.get_playback_position()
		var beat = int(music_time / beat_duration)
		if beat > current_beat:
			current_beat = beat
			beat_triggered.emit(current_beat)
			if current_beat % 4 == 0:
				measure_triggered.emit(current_beat / 4)

func play_music(music_path: String) -> void:
	var audio_stream = load(music_path)
	if audio_stream:
		music_player.stream = audio_stream
		music_player.play()
		current_beat = 0
		music_time = 0.0

func stop_music() -> void:
	music_player.stop()

func get_beat_progress() -> float:
	return fmod(music_time, beat_duration) / beat_duration

func get_music_time() -> float:
	return music_time
