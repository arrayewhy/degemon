extends Node2D

@onready var _player:Node2D = get_parent();

var _other_players:Array[Node2D];

const _dash_count:float = 11;
var _dash_spr_holder:Node2D;
#const _y_offset:float = 50;
const _init_power:float = .1;
var _curr_power:float = _init_power;
var _power_acceleration:float = .5;

var _aiming:bool;
var _aim_speed:float = 2;

var _launch_dest:Vector2;

signal Launch(end:Vector2, y_offset:float, power:float, hurt:bool);


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:
	# Create Dash Sprites
	_Create_Dash_Sprites()
	# Disable On Start
	_Stop_Aiming();

	_player.Arm_Launcher.connect(_Arm);
	_player.Death.connect(_Disarm);
	
	# Fixes a strange Bug(?) where multiple SubViewports get drawn on Top of each other.
	if _player.Number() == 0:
		$"Cursor_Holder/SubViewportContainer/SubViewport/Box".position.x = 2;
	
	await get_tree().process_frame;
	
	_other_players = _Other_Players_In_World();
	

func _process(delta: float) -> void:
	
	if Input.is_action_pressed(_player.Controls().get("Up"), true):
		_launch_dest += Vector2.UP * _aim_speed;
	elif Input.is_action_pressed(_player.Controls().get("Down"), true):
		_launch_dest += Vector2.DOWN * _aim_speed;
		
	if Input.is_action_pressed(_player.Controls().get("Left"), true):
		_launch_dest += Vector2.LEFT * _aim_speed;
	elif Input.is_action_pressed(_player.Controls().get("Right"), true):
		_launch_dest += Vector2.RIGHT * _aim_speed;
	
	# Power Build-up
	if _curr_power + delta * _power_acceleration < 1:
		_curr_power += delta * _power_acceleration;
	else:
		_curr_power = 1;
	
	$"Cursor_Holder/SubViewportContainer/SubViewport/Box".Affect_Speed(_curr_power);
	$Cursor_Holder.scale = Vector2(1, 1) * clamp(_curr_power, .25, 1);
	
	var targ_pos:Vector2 = _launch_dest;
	#var targ_pos:Vector2 = _Get_Closest_PlayerPosition();
	# Get Direction
	var raw_dir:Vector2 = targ_pos - _player.position;
	# Position the Landing Point
	self.global_position = _launch_dest;
	#self.global_position = _player.position + raw_dir * _curr_power;
	# Calculate Space between Dashes
	var space:Vector2 = raw_dir / (_dash_count - 1);
	# Position Dashes
	for idx in _dash_count:
		var dash_pos:Vector2 = -(space * idx);
		#var dash_pos:Vector2 = -(space * idx) * _curr_power;
		# Get current Normalized Progression
		var normalized_progression:float = 1 / (_dash_count - 1) * idx;
		# Get Initial Sine Offset
		var init_sin:float = sin(normalized_progression * PI);
		# Calculate Final Y Offset
		var final_y_offset:float = init_sin * (_curr_power * _player.Stats().JUMP_HEIGHT);
		# Apply Offset and Position
		dash_pos.y -= final_y_offset;
		_dash_spr_holder.get_child(idx).position = dash_pos;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Get_Closest_PlayerPosition() -> Vector2:
	
	var lowest_dist:float;
	var closest:Node2D;
	
	for other in _other_players:
		
		var dist:float = other.position.distance_to(_player.position);
		
		if lowest_dist == 0 or dist < lowest_dist:
			lowest_dist = dist;
			closest = other;
	
	return closest.position;


func _Start_Aiming() -> void:
	set_process(true);
	
	$Cursor_Holder.scale = Vector2(1, 1) * clamp(_curr_power, .25, 1);
	self.show();
	
	_dash_spr_holder.show();


func _Stop_Aiming() -> void:
	set_process(false);
	self.hide();
	_dash_spr_holder.hide();


func _Create_Dash_Sprites() -> void:
	_dash_spr_holder = Node2D.new();
	self.add_child(_dash_spr_holder);
	for i in _dash_count:
		var spr:Sprite2D = Sprite2D.new();
		spr.texture = PlaceholderTexture2D.new();
		spr.texture.size = Vector2(2, 2);
		spr.material = ShaderMaterial.new();
		spr.material.shader = load("res://shaders/white.gdshader");
		spr.modulate = Color(0.612, 0.949, 0.11, 1.0)
		_dash_spr_holder.add_child(spr);


func _Other_Players_In_World() -> Array[Node2D]:
	
	var others:Array[Node2D] = World.PLAYERS.values() as Array;
	
	for p in others:
		if p.Number() == _player.Number():
			others.erase(p);
	
	return others;


func _Arm() -> void:
	if !_player.Submit_Button.is_connected(_SIGNAL_Submit_Button):
		_player.Submit_Button.connect(_SIGNAL_Submit_Button);
		
		if World.DEBUG: print("Arming Player ", _player.Number());

func _Disarm() -> void:
	if _player.Submit_Button.is_connected(_SIGNAL_Submit_Button):
		_player.Submit_Button.disconnect(_SIGNAL_Submit_Button);
	self.hide();


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Submit_Button(state:bool) -> void:
	if state == true:
		if !is_processing():
			_launch_dest = _player.global_position;
			_curr_power = 0;
			_Start_Aiming();
			_aiming = true;
	else:
		if is_processing():
			_Stop_Aiming();
			Launch.emit(self.global_position, _curr_power * _player.Stats().JUMP_HEIGHT, _curr_power, false);
			
			if World.DEBUG: print("Player ", _player.Number(), " Launching!");
				
			_aiming = false;


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Is_Aiming() -> bool:
	return _aiming;
