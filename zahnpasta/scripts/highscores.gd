extends Node

signal scores_updated(scores: Array[HighscoreEntry])
signal score_added(score: HighscoreEntry)
signal score_api_errored

## Sorted by rank
var scores: Array[HighscoreEntry] = []

var _http_request: HTTPRequest
var _request_queue: Array[Dictionary] = []
var _api_config: HighscoresApiConfig = preload("res://data/highscores_api_config.tres")
var _last_score_submission: HighscoreEntry = null


func _ready() -> void:
	# Don't want requests to pause when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if _api_config.url.is_empty():
		return
	
	_http_request = HTTPRequest.new()
	_http_request.request_completed.connect(_on_http_request_completed)
	add_child(_http_request)
	
	_fetch_current_scores_online()


func _fetch_current_scores_online() -> void:
	var request := { "url": _api_config.url, "headers": PackedStringArray(), "method": HTTPClient.METHOD_GET, "data": "" }
	_add_request_to_queue(request)


func _add_request_to_queue(request: Dictionary) -> void:
	_request_queue.append(request)
	if _request_queue.size() == 1:
		_consume_next_queue_item()


func _consume_next_queue_item() -> void:
	if _request_queue.size() == 0:
		return
	
	var request = _request_queue[0]
	_http_request.request(request["url"], request["headers"], request["method"], request["data"])


func refresh_scores() -> void:
	_fetch_current_scores_online()


func get_current_highest_score() -> HighscoreEntry:
	if scores.size() == 0:
		return HighscoreEntry.new("none", 0, 0)
	
	return scores[0]


func add_score(score: HighscoreEntry) -> void:
	var json = JSON.stringify(score.to_json())
	var headers := ["Authorization: Bearer " + _api_config.api_key, "Content-Type: application/json"]
	var request := { "url": _api_config.url, "headers": headers, "method": HTTPClient.METHOD_POST, "data": json }
	_add_request_to_queue(request)
	_last_score_submission = score


func has_last_submission_this_session() -> bool:
	return _last_score_submission != null


func get_last_submission_this_session() -> HighscoreEntry:
	return _last_score_submission


func _sort_by_rank_asc(a: HighscoreEntry, b: HighscoreEntry) -> bool:
	return a.rank < b.rank


func _sort_by_score_desc(a: HighscoreEntry, b: HighscoreEntry) -> bool:
	return a.rank > b.rank


func _on_http_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.Result.RESULT_SUCCESS:
		var json = JSON.parse_string(body.get_string_from_utf8())
		match typeof(json):
			TYPE_ARRAY:
				# Result of score list GET
				scores.resize(json.size())
				for entry in json:
					var highscore_entry := HighscoreEntry.from_json(entry)
					scores[highscore_entry.rank - 1] = highscore_entry
				scores_updated.emit(scores)
			TYPE_DICTIONARY:
				# Result of score add/update POST
				var highscore_entry := HighscoreEntry.from_json(json)
				scores.append(highscore_entry)
				scores.sort_custom(self._sort_by_rank_asc)
				_last_score_submission = highscore_entry
				score_added.emit(highscore_entry)
				_fetch_current_scores_online()
			_:
				print("Unknown json return type")
		_request_queue.pop_front()
		_consume_next_queue_item()
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		score_api_errored.emit()
		print(result, " ", _response_code, " ", _headers, " ", body.get_string_from_utf8())
