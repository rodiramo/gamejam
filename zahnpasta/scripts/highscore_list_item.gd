extends HBoxContainer


const THOUSANDS_SEPARATOR = ","


@onready var rank_label: Label = $RankLabel
@onready var name_label: Label = $NameLabel
@onready var score_label: Label = $ScoreLabel


func initialize(entry: HighscoreEntry) -> void:
	rank_label.text = "%d." % entry.rank
	name_label.text = entry.player_name
	score_label.text = "%d" % entry.score


func _format_score(score: int) -> String:
	var current_num: int = score
	var separator_counter: int = 0
	var result: String = ""
	
	while current_num > 0:
		var digit: int = current_num % 10
		
		result += "%d" % digit
		if separator_counter == 2:
			result += THOUSANDS_SEPARATOR
		
		current_num /= 10
		separator_counter += 1
		separator_counter %= 3
	
	return result.reverse()
