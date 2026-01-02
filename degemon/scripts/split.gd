extends Node

@onready var _p1:Node2D;
@onready var _p2:Node2D;


#func _ready() -> void:
	
	#var world:World2D = $World_SVPC/SubViewport.find_world_2d();
	#$P1_SVPC/SubViewport.world_2d = world;
	#$P2_SVPC/SubViewport.world_2d = world;
	
	#await get_tree().process_frame;
	
	#_p1 = $P1_SVPC/SubViewport.get_child(0);
	#_p2 = $P2_SVPC/SubViewport.get_child(0);
	
	#_p1.Launch_Landed.connect(_SIGNAL_Launch_Landed);
	#_p2.Launch_Landed.connect(_SIGNAL_Launch_Landed);


func _SIGNAL_Launch_Landed(_launch_pos:Vector2, _landing_pos:Vector2, _power:float, _dmg:int, _knockback:float, _atk_range:float):
	
	if _p1.global_position.distance_to(_p2.global_position) > 96:
		$P1_SVPC.show();
		$P2_SVPC.show();
	else:
		$P1_SVPC.hide();
		$P2_SVPC.hide();
