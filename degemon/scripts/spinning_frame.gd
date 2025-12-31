extends Node3D

const _norm_speed:float = 14;
var _curr_speed:float = _norm_speed;


func _process(delta: float) -> void:
	$"Sprite3D".rotate(Vector3.UP, delta * _curr_speed);


func Affect_Speed(normalised_val:float):
	_curr_speed = clamp(_norm_speed * normalised_val, 8, _norm_speed);
	
