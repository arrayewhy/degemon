extends Camera2D

const _speed:float = 1;

var _curr_power:float;
const _shake_falloff:float = 4;

var _zoom_tween:Tween;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _ready() -> void:

	set_process(false);
	
	$"../Environment".Shake.connect(_Shake);
	
	# Player creation is deferred because the base node of this scene is busy and cannot add new children yet.
	# Thus, we must defer connecting to player signals as well.
	call_deferred("_Connect_Player_Launch_Landed");
	
	$"../Initialiser".Battle_Start.connect(_SIGNAL_Battle_Start);


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Connect_Player_Launch_Landed() -> void:
	for player in World.PLAYERS.values():
		player.Launch_Landed.connect(_SIGNAL_Launch_Landed);
		player.Death.connect(_SIGNAL_Player_Death);


func _Shake(power:float) -> void:
	if power > _curr_power:
		_curr_power = power;


func _process(delta: float) -> void:
	
	var positions:Array[Vector2];
	
	var players:Array[Node2D] = World.PLAYERS.values();
	
	for player in players:
		positions.append(player.global_position);
	
	var top_most:float = positions[0].y;
	var btm_most:float = positions[0].y;
	var left_most:float = positions[0].x;
	var right_most:float = positions[0].x;
	
	for pos in positions:
		if pos.y < top_most:
			top_most = pos.y;
		elif pos.y > btm_most:
			btm_most = pos.y;
		
		if pos.x < left_most:
			left_most = pos.x;
		elif pos.x > right_most:
			right_most = pos.x;
		
	var targ_pos:Vector2;
	
	targ_pos.x = left_most + abs(left_most - right_most) / 2;
	targ_pos.y = top_most + abs(top_most - btm_most) / 2;
	
	var raw_dir:Vector2 = targ_pos - self.position;
	#var targ_pos:Vector2 = self.position + raw_dir_to_player * _speed * delta;
	self.position += raw_dir * _speed * delta;
	
	if players[0].position.distance_to(players[1].position) > 96:
		
		if _zoom_tween && _zoom_tween.is_running():
			_zoom_tween.stop();
		_zoom_tween = create_tween();
		_zoom_tween.tween_property(self, "zoom", Vector2.ONE, .125);
		
		#zoom = Vector2.ONE;
	else:
		
		if _zoom_tween && _zoom_tween.is_running():
			_zoom_tween.stop();
		_zoom_tween = create_tween();
		_zoom_tween.tween_property(self, "zoom", Vector2.ONE * 2, .125);
		
		#zoom = Vector2.ONE * 2;
	
	# Camera Shake
	
	if _curr_power <= 0:
		return;
	else:
		self.position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _curr_power;
		_curr_power -= _shake_falloff * delta;


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Player_Death() -> void:
	set_process(false);


func _SIGNAL_Battle_Start() -> void:
	set_process(true);


func _SIGNAL_Launch_Landed(_launch_pos:Vector2, _landing_pos:Vector2, _power:float, _dmg:int, knockback:float, _range:float) -> void:
	#if dmg > 4:
		#_Shake(2);
	_Shake(knockback / 64);
