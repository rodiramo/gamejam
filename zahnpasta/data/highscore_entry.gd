class_name HighscoreEntry
extends Resource

const NAME_KEY = "name"
const SCORE_KEY = "score"
const RANK_KEY = "rank"

@export var player_name: String = ""
@export var score: int = 0
@export var rank: int = 0


func _init(player_name: String, score: int, rank: int = 0) -> void:
	self.player_name = player_name
	self.score = score
	self.rank = rank


static func from_json(json: Dictionary) -> HighscoreEntry:
	var _player_name: String = json[NAME_KEY] if json.has(NAME_KEY) else "???"
	var _score: int = json[SCORE_KEY] if json.has(SCORE_KEY) else 0
	var _rank: int = json[RANK_KEY] if json.has(RANK_KEY) else 0

	return new(_player_name, _score, _rank)


func to_json() -> Dictionary:
	return { NAME_KEY: player_name, SCORE_KEY: score, RANK_KEY: rank }
