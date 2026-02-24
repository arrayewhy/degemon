extends Node

var _player_prefab:PackedScene = load("res://prefabs/player.tscn");
@onready var _spawn_point_holder:Node2D = $"../Spawn_Points";

signal Battle_Start;


func _ready() -> void:
	World.Set_Current_Level(get_tree().current_scene.name);
	# Defer Creating Players because parent is busy and cannot add children yet
	call_deferred("_Create_Players");


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		World.Reset_Current_Scene();


func _Create_Players() -> void:
	
	# Clear all recorded players
	for player_obj in World.PLAYERS.values():
		if player_obj:
			player_obj.queue_free();
	
	var player_count:int = 2;
	var player_holder:Node2D = Node2D.new();
	player_holder.name = "Player_Holder";
	player_holder.y_sort_enabled = true;
	player_holder.hide();
	get_parent().add_child(player_holder);
	
	var init_y:Array[float] = [0, 0];
	
	for i in player_count:
		var player:Node2D = _player_prefab.instantiate();
		player.Initialise(i, World.ACTIVE_MONS[i], Battle_Start);
		
		player_holder.add_child(player);
		player.name = str("P", i + 1);
		
		init_y[i] = player.position.y;
		player.position = _spawn_point_holder.get_child(i).global_position + Vector2.UP * 256;
	
	var tween:Tween;
	tween = create_tween();
	tween.set_parallel(true);
	
	tween.tween_property($"../Player_Holder/P1", "global_position:y", init_y[0], .5 + randf_range(.1, .5));
	tween.tween_property($"../Player_Holder/P2", "global_position:y", init_y[1], .5 + randf_range(.1, .5));
	
	player_holder.show();
	
	await tween.finished;
	
	Battle_Start.emit();
	World.Disconnect_Signal_Connections(Battle_Start);
