extends Node

const MAX_SCORES = 5
const NAME_KEY = "name"
const SCORE_KEY = "score"
const EMPTY_SLOT = { NAME_KEY: "none", SCORE_KEY: 0 }

## Each score has the shape { "name": "<name>", "score": <score> }
var scores: Array[Dictionary] = []


func _ready() -> void:
	for _i in range(MAX_SCORES):
		scores.append(EMPTY_SLOT)


func get_current_highest_score() -> int:
	if scores.size() == 0:
		return 0
	
	return scores[0][SCORE_KEY]


func create_entry(player_name: String, score: int) -> Dictionary:
	return { NAME_KEY: player_name, SCORE_KEY: score }


func add_score(score: Dictionary) -> bool:
	if scores[scores.size() - 1][SCORE_KEY] >= score[SCORE_KEY]:
		return false
	
	scores.append(score)
	scores.sort_custom(self._sort_desc)
	scores.resize(MAX_SCORES)
	
	return true


func _sort_desc(a: Dictionary, b: Dictionary) -> bool:
	return a[SCORE_KEY] > b[SCORE_KEY]
