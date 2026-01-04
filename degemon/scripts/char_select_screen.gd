extends CanvasLayer

signal Activate_Char_Select;

var _chars_selected:int;


func _ready() -> void:
	$"../Title_Screen".Game_Start.connect(_On_Game_Start);
	
	$"P1".Selected.connect(_Attempt_Battle_Start);
	$"P2".Selected.connect(_Attempt_Battle_Start);


func _Attempt_Battle_Start() -> void:
	
	_chars_selected += 1;
	
	if _chars_selected >= 2:
		Music_Master.Play_Normal_Battle_Music();
		await get_tree().create_timer(3).timeout;
		get_tree().change_scene_to_file(World.LEVELS["Rocks"]);


func _On_Game_Start() -> void:
	
	Music_Master.Play_Arena_Music();
	
	await get_tree().create_timer(1).timeout;
	
	var tween:Tween = create_tween();
	tween.set_parallel(true);
	
	Sound_Master.Play_Window();
	
	for c in get_children().size():
		# Offset Frames
		var init_pos:Vector2 = get_child(c).position;
		match c:
			0: get_child(c).position.y -= 128;
			1: get_child(c).position.y += 128;
		# Move them to the Center
		tween.tween_property(get_child(c), "position", init_pos, .25);
		
	self.show();
	
	await tween.finished;
	
	Activate_Char_Select.emit();
	World.Disconnect_Signal_Connections(Activate_Char_Select);
