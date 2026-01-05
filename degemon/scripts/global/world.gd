extends Node

const LEVELS:Dictionary[String, String] = {
	"Rocks" : "res://scenes/rocks.tscn",
	"Arena" : "res://scenes/arena.tscn",
}

var PLAYERS:Dictionary[int, Node2D];
var ACTIVE_MONS:Array[int] = [0, 0]
var CURR_LEVEL:String;
const BOUNDARIES:Vector4 = Vector4(-64, 64, -128, 128); # Up, Down, Left, Right

const CONTROLS_1:Dictionary[String, String] = { "Up":"Up_1", "Down":"Down_1", "Left":"Left_1", "Right":"Right_1", "Submit":"Submit_1" };
const CONTROLS_2:Dictionary[String, String] = { "Up":"Up_2", "Down":"Down_2", "Left":"Left_2", "Right":"Right_2", "Submit":"Submit_2" };

var DEBUG:bool;


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("Debug"):
		DEBUG = !DEBUG;


func Add_Player(player_num:int, player:Node2D) -> void:
	PLAYERS.set(player_num, player);


func Remove_Player(player_num:int) -> void:
	PLAYERS.erase(player_num);


func Set_Mon_For_Player(player_num:int, mon_idx:int) -> void:
	ACTIVE_MONS[player_num] = mon_idx;


func Clamp_Position_Within_Boundaries(pos:Vector2) -> Vector2:
	pos.x = clamp(pos.x, World.BOUNDARIES[2], World.BOUNDARIES[3]);
	pos.y = clamp(pos.y, World.BOUNDARIES[0], World.BOUNDARIES[1]);
	return pos;


func Disconnect_Signal_Connections(sig:Signal) -> void:
	for connection in sig.get_connections():
		var callable:Callable = connection.callable;
		sig.disconnect(callable);


func Set_Current_Level(scene_name:String) -> void:
	CURR_LEVEL = scene_name;


func Reset_Scene() -> void:
	Embellishments.Reset_Shadows();
	Embellishments.Reset_Sparks();


func Reset_Current_Scene() -> void:
	Reset_Scene();
	get_tree().change_scene_to_file(LEVELS[CURR_LEVEL]);


func Load_Next_Scene() -> void:
	Reset_Scene();
	for i in LEVELS.keys().size():
		if LEVELS.keys()[i] == CURR_LEVEL:
			if i < LEVELS.keys().size() - 1:
				var next_level_name:String = LEVELS.keys()[i + 1];
				get_tree().change_scene_to_file(LEVELS[next_level_name]);
			else:
				var next_level_name:String = LEVELS.keys()[0];
				get_tree().change_scene_to_file(LEVELS[next_level_name]);
