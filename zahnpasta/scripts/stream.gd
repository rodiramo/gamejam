extends AudioStreamPlayer

var audio_player := AudioStreamPlayer.new()


func _ready() -> void:
	add_child(audio_player)
	audio_player.stream = AudioStreamMP3.new()
