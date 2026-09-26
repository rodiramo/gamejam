class_name Snapshot
extends Resource

enum MoveType {
	UP,
	DASH_UP,
	DOWN,
	DASH_DOWN
}

var move_type: MoveType
var beat: int
var in_between_time: float


func set_move_type(type: MoveType):
	move_type = type


func set_beats(on_beat: int):
	beat = on_beat


func set_in_between_time(time: float):
	in_between_time = time
