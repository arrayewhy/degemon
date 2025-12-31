extends Node2D

const _max_health:int = 20;
var _curr_health:int = _max_health;


func Damage(dmg:int) -> void:
	_curr_health -= dmg;


func Health() -> int:
	return _curr_health;


func Max_Health() -> int:
	return _max_health;


func Is_Alive() -> bool:
	if _curr_health <= 0:
		print("Death");
	return _curr_health > 0;
