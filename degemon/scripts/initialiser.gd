extends Node

var _player_prefab:PackedScene = load("res://prefabs/player.tscn");
@onready var _spawn_point_holder:Node2D = $"../Spawn_Points";

signal Battle_Start;


func _ready() -> void:
	World.Set_Current_Level(get_tree().current_scene.name);
	call_deferred("_Create_Players");


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Cancel"):
		World.Reset_Current_Scene();


func _Create_Players() -> void:
	
	for player_obj in World.PLAYERS.values():
		if player_obj:
			player_obj.queue_free();
	
	var player_count:int = 2;
	var player_holder:Node2D = Node2D.new();
	player_holder.name = "Player_Holder"
	player_holder.y_sort_enabled = true;
	player_holder.hide();
	get_parent().add_child(player_holder);
	
	var init_y:Array[float] = [0, 0];
	
	for i in player_count:
		var player:Node2D = _player_prefab.instantiate();
		player.Initialise(i, World.ACTIVE_MONS[i], Battle_Start);
		
		var cam:Camera2D = Camera2D.new();
		cam.zoom = Vector2(4, 4);
		player.add_child(cam);
		
		match i:
			0: $"../Split_Screen/P1_SVPC/SubViewport".add_child(player);
			1: $"../Split_Screen/P2_SVPC/SubViewport".add_child(player);
		
		init_y[i] = player.position.y;
		player.position = _spawn_point_holder.get_child(i).global_position + Vector2.UP * 256;
	
	var tween:Tween;
	tween = create_tween();
	tween.set_parallel(true);
	
	tween.tween_property($"../Split_Screen/P1_SVPC/SubViewport".get_child(0), \
	"global_position:y", init_y[0], .5 + randf_range(.1, .5));
	tween.tween_property($"../Split_Screen/P2_SVPC/SubViewport".get_child(0), \
	"global_position:y", init_y[1], .5 + randf_range(.1, .5));
	
	player_holder.show();
	
	await tween.finished;
	
	Battle_Start.emit();
	World.Disconnect_Signal_Connections(Battle_Start);
