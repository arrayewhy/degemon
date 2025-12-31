extends Node2D

@export var _floor_fall:bool;

var _fall_tween:Tween;
var _floor_cells:Array[Sprite2D];

#var delay_between_cells:float = 1;
#var _dur_per_cell:float = .5;

signal Shake(power:float);
signal Fall_Check;


func _ready() -> void:
	
	for child in get_children():
		_floor_cells.push_back(child);
	
	if _floor_fall:
		_Floor_Fall(.1, .5);


func _Floor_Fall(delay_between_cells:float, _dur_per_cell:float) -> void:
	
	if _floor_cells.size() > 0:
		
		await get_tree().create_timer(delay_between_cells).timeout;
	
		var ground_cell:Sprite2D = _floor_cells.pick_random();
		_fall_tween = create_tween();
		_fall_tween.set_parallel();
		_fall_tween.set_trans(Tween.TRANS_QUAD);
		_fall_tween.set_ease(Tween.EASE_IN);
		_fall_tween.tween_property(ground_cell, "offset:y", ground_cell.offset.y + 32, _dur_per_cell);
		_fall_tween.tween_property(ground_cell, "modulate:a", 0, _dur_per_cell);
		Shake.emit(1);
		
		await _fall_tween.finished;
		#ground_cell.modulate = Color.RED;
		ground_cell.hide();
		Fall_Check.emit();
		_floor_cells.erase(ground_cell);
		#ground_cell.queue_free();
		
		_Floor_Fall(delay_between_cells, _dur_per_cell);


func Trigger_Floor_Fall(delay_between_cells:float = 1, fall_dur:float = .5):
	_Floor_Fall(delay_between_cells, fall_dur);
