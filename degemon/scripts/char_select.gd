extends NinePatchRect

@export var _player_num:int;

@onready var _controls:Dictionary[String, String] = \
	World.CONTROLS_1 if _player_num == 0 else World.CONTROLS_2;
	
@onready var _chars:Array[Sprite2D];
@onready var _curr_select:String = get_child(0).name;

var _shadow:Sprite2D;

signal Selected;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	
	set_process(false);
	
	$"..".Activate_Char_Select.connect(_Activate);
	
	for child in get_children():
		_chars.push_back(child);
		child.z_index = 1;
		child.material = ShaderMaterial.new();
		child.material.shader = load("res://shaders/flash.gdshader");
	
	_Flash_OFF();
	
	_Create_Shadow();


func _process(_delta: float) -> void:
	
	if Input.is_action_pressed(_controls["Submit"]):
		_Choose();
		set_process(false);
		return;
	
	if Input.is_action_just_pressed(_controls["Up"]):
		_Cycle_Characters(-1);
	elif Input.is_action_just_pressed(_controls["Down"]):
		_Cycle_Characters(1);
	elif Input.is_action_just_pressed(_controls["Left"]):
		_Cycle_Characters(-1);
	elif Input.is_action_just_pressed(_controls["Right"]):
		_Cycle_Characters(1);


func _exit_tree() -> void:
	_Reset_Shadow();


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Cycle_Characters(dir:int) -> void:
	
	Sound_Master.Play_Select(1, 1);
	
	for i in _chars.size():
		
		if !_chars[i].visible:
			continue;
		
		_chars[i].hide();
		
		var next_idx:int = i + dir;
		
		if next_idx < _chars.size():
			_chars[next_idx].show();
			_curr_select = _chars[next_idx].name;
			return;
		
		# Start from Top
		
		if dir > 0:
			_chars[0].show();
			_curr_select = _chars[0].name;
		elif dir < 0:
			_chars[_chars.size() - 1].show();
			_curr_select = _chars[_chars.size() - 1].name;


func _Choose() -> void:
	
	match _curr_select:
		"RANDOM": World.Set_Mon_For_Player(_player_num, randi_range(1, Mon_Stats.MONS.size() - 1));
		"SUKAMON": World.Set_Mon_For_Player(_player_num, 1);
		"DIGITAMAMON": World.Set_Mon_For_Player(_player_num, 2);
		"SKULLGREYMON": World.Set_Mon_For_Player(_player_num, 3);
		"TORQUE": World.Set_Mon_For_Player(_player_num, 4);
	
	Selected.emit();
	World.Disconnect_Signal_Connections(Selected);
	
	Sound_Master.Play_Submit();
	
	# Flash Sprite
	_Flash_ON();
	await get_tree().create_timer(1).timeout;
	_Flash_OFF();


func _Flash_OFF() -> void:
	for c in _chars:
		c.material.set_shader_parameter("speed", 0);
		c.material.set_shader_parameter("force_white", 1);


func _Flash_ON() -> void:
	for c in _chars:
		c.material.set_shader_parameter("speed", 8);
		c.material.set_shader_parameter("force_white", 0);


func _Activate() -> void:
	set_process(true);


# Shadow ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Create_Shadow() -> void:
	_shadow = Embellishments.Get_Shadow();
	_shadow.reparent(self);
	_shadow.scale *= 2;
	_shadow.position = get_child(0).position + Vector2.DOWN * 6;
	_shadow.z_index = 0;
	_shadow.modulate.a = 1;


func _Reset_Shadow() -> void:
	if _shadow:
		Embellishments.Reset_Shadow(_shadow);
