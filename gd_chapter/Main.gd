extends Node2D

const BASE_POS_Y = 1080.0
const SPEED = 30.0

enum eType {
	NONE,
	CHAPTER,
	BODY,
}

class Chapter:
	var header:String = ""
	var body:String = ""
	func dump() -> void:
		print("# %s"%header)
		print(body)

@onready var _bg := $Bg
@onready var _label := $Label
@onready var _text_body := $TextBody
@onready var _chapter_drop := $ChapterIdx
@onready var _chapter_text := $Chapter

var chapter_no:int = 1
var chapter_list:Array[Chapter] = []
var scroll_y:float = 0
var total_time:float = 0
var ofs_time:float = 0

func init() -> void:
	scroll_y = 0
	total_time = 0
	ofs_time = 0
	_bg.texture = load("res://assets/images/%03d.png"%chapter_no)

func _ready() -> void:
	for i in range(7):
		_chapter_drop.add_item("CH%d"%(i+1))
	
	var file_path = "res://assets/scenario/script.txt"

	# FileAccess でファイルを開く
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var text = file.get_as_text()  # ファイル全体を文字列として読み込み.
		_parse(text)
		file.close()
	else:
		push_error("ファイルを開けませんでした: " + file_path)

func _parse(text:String) -> void:
	var state := eType.NONE
	var chapter:Chapter
	for line in text.split("\n"):
		line = line.strip_edges()
		match state:
			eType.NONE:
				if line == "#":
					# チャプター開始.
					state = eType.CHAPTER
			eType.CHAPTER:
				if line == "##":
					# 本文開始.
					state = eType.BODY
				else:
					chapter = Chapter.new()
					chapter_list.append(chapter)
					chapter.header = line
			eType.BODY:
				if line == "#":
					# チャプター終了.
					state = eType.CHAPTER
				else:
					chapter.body += line + "\n"
	for chapter2 in chapter_list:
		chapter2.dump()

func _process(delta: float) -> void:
	scroll_y += SPEED * delta
	var v_max = _get_scroll_max()
	scroll_y = min(scroll_y, v_max)
	var ratio := _get_scroll_ratio()
	if ratio < 1:
		total_time += delta
	elif ofs_time < 300:
		total_time += delta
		ofs_time += SPEED * delta
	_label.text = "%3.0f%%"%(ratio * 100)
	_label.text += "\n%3.0fsec"%total_time
	_text_body.position.y = BASE_POS_Y - scroll_y - ofs_time
	var chapter_idx:int = _chapter_drop.selected
	var chapter := chapter_list[chapter_idx]
	_text_body.text = chapter.body
	_chapter_text.text = chapter.header

func _get_scroll_max() -> float:
	return _text_body.size.y - 1080 + BASE_POS_Y

func _get_scroll_ratio() -> float:
	var size = _get_scroll_max()
	return scroll_y / size


func _on_chapter_idx_item_selected(_index: int) -> void:
	chapter_no = _index + 1
	init() # Replace with function body.
