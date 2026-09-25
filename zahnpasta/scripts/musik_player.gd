extends Node2D

@onready var stream0 = $Stream0
@onready var stream1 = $Stream1

var current_Stream0 := true
var intensity_data = ["res://assets/musik/test.mp3", "res://assets/musik/test.mp3", "res://assets/musik/test.mp3", "res://assets/musik/test2.mp3"]


func _ready() -> void:
	stream0.audio_player.stream = load(intensity_data[0])
	stream0.audio_player.play(0.0)


func switch(fromStream: Variant, toStream: Variant, intensity: int):
	var playback_pos = fromStream.audio_player.get_playback_position()

	toStream.audio_player.stream = load(intensity_data[intensity])
	toStream.audio_player.volume_linear = 0.0
	toStream.audio_player.play(playback_pos)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(fromStream.audio_player, "volume_linear", 0.0, 1.0)
	tween.tween_property(toStream.audio_player, "volume_linear", 1.0, 1.0)

	tween.chain().tween_callback(fromStream.audio_player.stop)


func _on_level_switch_audio(intensity, max_intensity) -> void:
	if intensity < max_intensity:
		if current_Stream0:
			await switch(stream0, stream1, intensity)
		else:
			await switch(stream1, stream0, intensity)
		current_Stream0 = !current_Stream0
