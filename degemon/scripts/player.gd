extends Node2D

var _player_num:int;
var _stats:Mon_Stats;

var _hp_bar:Control;
var _hp_bar_width:float;

var _spr:AnimatedSprite2D;
var _init_spr_scale:Vector2;

var _facing_right:bool = false;

var _controls:Dictionary[String, String];

var _grounded:bool = true;
var _busy:bool;

var _charging:bool;
var _charging_time:float;

var _cool_down:bool;
var _cooldown_time:float;

#var _curr_launch_speed:float;
var _launch_height:float;
var _launch_start:Vector2;
var _launch_end:Vector2;
var _launch_prog:float = 0;
var _launch_power:float;
var _shadow:Sprite2D;

const _damage:int = 5;
var _hurt:bool;

var _other_players:Array[Node2D];

@onready var _environment:Node2D = $"../../Environment";

signal Submit_Button(state:bool);
signal Launch_Landed(launch_pos:Vector2, landing_pos:Vector2, power:float, dmg:int, knockback:float, atk_range:float);
signal Death;
signal Arm_Launcher;


# Functions: Built-in ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Initialise(player_idx:int, mon_idx:int, battle_start_sig:Signal) -> void:
	
	_player_num = player_idx;
	
	if mon_idx == 0:
		_stats = load(Mon_Stats.Paths[randi_range(1, Mon_Stats.Paths.size() - 1)]);
	else:
		_stats = load(Mon_Stats.Paths[mon_idx]);
	
	match player_idx:
		0: _controls = World.CONTROLS_1;
		1: _controls = World.CONTROLS_2;
	
	World.Add_Player(player_idx, self);
	
	_spr = _stats.Anim.instantiate();
	self.add_child(_spr);
	_spr.position.y -= 8;
	
	_init_spr_scale = _spr.scale;
	
	battle_start_sig.connect(_SIGNAL_Battle_Start);


func _ready() -> void:
	
	_Disable_Player();
	
	$Launcher.Launch.connect(_SIGNAL_Launch_Triggered);
	
	$"../../Environment".Fall_Check.connect(_SIGNAL_Fall_Check);
	
	await get_tree().process_frame;
	
	_other_players = Other_Players_In_World();
	
	for other in _other_players:
		other.Launch_Landed.connect(_SIGNAL_Enemy_Launch_Landed);
		other.Death.connect(_SIGNAL_Check_Winner);
	
	# Health Bar
	
	match _player_num:
		0: _hp_bar = $"../../Battle_UI/P1_HP/Bar";
		1: _hp_bar = $"../../Battle_UI/P2_HP/Bar";
		
	_hp_bar_width = _hp_bar.size.x;


func _process(delta: float) -> void:
	
	if Input.is_action_pressed(_controls.get("Submit"), true):
		Submit_Button.emit(true);
	elif Input.is_action_just_released(_controls.get("Submit"), true):
		Submit_Button.emit(false);
	
	if _charging:
		if _charging_time >= 0:
			_charging_time -= delta;
			return;
		else:
			_charging = false;
			_spr.play("Jump");
			
			# Jump Sound
			if _stats.JUMP_SFX:
				Sound_Master.Play_Pitched_Sound(_stats.JUMP_SFX);
			
	elif _cool_down:
		if _cooldown_time >= 0:
			_cooldown_time -= delta;
			return;
		else:
			_cool_down = false;
			_spr.play("Idle");
			_Reset_Launch();
	
	if !_grounded:
		
		var next_prog:float;
		
		if !_hurt:
			#var prog_accel:float = 1 + _launch_prog / .05;
			#next_prog = _launch_prog + (_curr_launch_speed / _launch_power / 8) * prog_accel * delta;
			#next_prog = _launch_prog + _stats.MOVE_SPEED * prog_accel * delta;
			var prog_accel:float = sin(_launch_prog);
			#next_prog = (_launch_prog + delta + (prog_accel / (_stats.MOVE_SPEED * _launch_power)));
			next_prog = (_launch_prog + delta + (prog_accel / (_stats.MOVE_SPEED)));
			
		elif _hurt:
			
			# Digitamamon Falls Faster than others
			#if _stats.NAME == Mon_Stats.MONS.DIGITAMAMON:
				#var prog_accel:float = sin(_launch_prog);
				#next_prog = (_launch_prog + delta + (prog_accel / (_stats.MOVE_SPEED * _launch_power)));
			#else:
				#next_prog = _launch_prog + 2 * delta;
				
			next_prog = _launch_prog + 2 * delta;
		
		if next_prog < 1:
			
			# Progress Launch
			_launch_prog = next_prog;
			
			self.position = _Mid_Launch_Position(_launch_start, _launch_end, _launch_prog);
			# Sprite Scale
			if !_hurt:
				_spr.scale = _init_spr_scale * clamp(sin(_launch_prog * PI) + _launch_power, 1, 2);
			# Move Shadow
			if _shadow:
				_shadow.position = _launch_start + ((_launch_end - _launch_start) * _launch_prog);
			
		elif next_prog >= 1:
			
			# Landing Sound
			if _stats.LAND_SFX:
				Sound_Master.Play_Pitched_Sound(_stats.LAND_SFX);
			
			_grounded = true;
			_launch_prog = 1;
			_spr.scale = _init_spr_scale;
			# Shadow
			if _shadow: _Reset_Shadow();
			# Floor Fall
			if _Fall_Off_World():
				_Fall_Death();
				return;
			# Snap to Launch End
			self.position = _launch_end;
			
			if _hurt:
				_Poop();
				_Reset_Launch();
				
				# Digitamamon can Knockback when being Knocked Back
				if _stats.NAME == Mon_Stats.MONS.DIGITAMAMON:
					Launch_Landed.emit(_launch_start, self.position, _launch_power, _stats.ATK_1, 16, _stats.RANGE_1 * 2);
				
			elif !_hurt:
				
				var knockback:float = _stats.KNOCKBACK_1 if _launch_power < 0.8 else _stats.KNOCKBACK_2;
				Launch_Landed.emit(_launch_start, self.position, _launch_power, _stats.ATK_1, knockback, _stats.RANGE_1);
				
				_cool_down = true;
				
				if _launch_power > 0.25:
					_cooldown_time = 1;
					_spr.play("Prep");
				else:
					_cooldown_time = _stats.MOVE_DELAY;
					_spr.play("Land");
					
				#if World.DEBUG: print("Player ", _player_num, " Landed");
	
	if !_busy:
		#if $Launcher.Is_Aiming():
		_Player_Move();


func _Fall_Off_World() -> bool:
	
	var closest:Node2D = _environment.get_child(0);
			
	for cell in _environment.get_children():
		if self.global_position.distance_to(cell.global_position) < self.global_position.distance_to(closest.global_position):
			closest = cell;
	
	#if World.DEBUG: closest.modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1), 1);
	
	if !closest.visible:
		return true;
	elif self.global_position.distance_to(closest.global_position) > 12:
		#if World.DEBUG: closest.modulate = Color.RED;
		return true;
		
	return false;


# Functions: Signals ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Launch_Triggered(end:Vector2, y_offset:float, power:float, hurt:bool) -> void:
	#if World.DEBUG: print("Player ", _player_num, " Launch Triggered");
	_Launch(end, y_offset, power, hurt);


func _SIGNAL_Enemy_Launch_Landed(launch_pos:Vector2, landing_pos:Vector2, power:float, dmg:int, knockback:float, atk_range:float) -> void:
	
	if landing_pos.distance_to(self.position) < atk_range + power * 8:
		
		if !_grounded:
			return;
		
		# Shove
		
		var dir:Vector2 = (self.position - landing_pos).normalized();
		
		if dir <= Vector2(1, 1):
			dir = (landing_pos - launch_pos).normalized();
		
		# Knockback
		
		if _stats.NAME == Mon_Stats.MONS.DIGITAMAMON:
			_Launch(self.position + dir * knockback, 8, .25, true);
		else:
			_Launch(self.position + dir * knockback, 0, .25, true);
		
		# Receive Damage
		
		if $Health.Is_Alive():
			$Health.Damage(dmg);
		
		match _player_num:
			0:
				_hp_bar.size.x -= _hp_bar_width / $Health.Max_Health() * dmg;
				_hp_bar.position.x += _hp_bar_width / $Health.Max_Health() * dmg;
				_hp_bar.get_child(0).size.x -= _hp_bar_width / $Health.Max_Health() * dmg;
			1:
				_hp_bar.size.x -= _hp_bar_width / $Health.Max_Health() * dmg;
				_hp_bar.get_child(0).size.x -= _hp_bar_width / $Health.Max_Health() * dmg;
		
		await get_tree().process_frame;
		
		if !$Health.Is_Alive():
			_Death();
			World.Remove_Player(_player_num);
			_spr.play("Death");
			_hp_bar.hide();
		
		# Sparks
		
		if dmg > 0:
			var spark:Sprite2D = Embellishments.Get_Spark();
			#var spark_scale:Vector2 = spark.scale;
			#spark.scale *= [1, 2].pick_random();
			
			var spark_pos:Vector2 = self.global_position + (landing_pos - self.global_position) / 2;
			spark_pos.y += randf_range(-12, 4);
			spark.global_position = spark_pos.round();
			
			spark.modulate = Color.BLACK;
			await get_tree().create_timer(.1).timeout;
			spark.modulate = Color.WHITE;
			await get_tree().create_timer(.1).timeout;
			spark.modulate.a = 0;
			spark.hide();
			#spark.scale = spark_scale;


func _SIGNAL_Fall_Check() -> void:
	if !_grounded:
		return;
	if _Fall_Off_World():
		_Fall_Death();
		_environment.Fall_Check.disconnect(_SIGNAL_Fall_Check);


func _SIGNAL_Check_Winner() -> void:
	for p_num in World.PLAYERS.keys():
		if p_num == _player_num:
			
			_Disable_Player();
			
			# Play Win Animation and Reload the Scene
			await get_tree().create_timer(3).timeout;
			
			_spr.play("Win");
			Music_Master.Stop();
			Sound_Master.Play_Win();
			
			await get_tree().create_timer(4).timeout;
			
			World.Load_Next_Scene();
			
			return;


# Functions ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _SIGNAL_Battle_Start() -> void:
	_Enable_Player();
	Arm_Launcher.emit();


func _Player_Move() -> void:
	# Up & Down
	if Input.is_action_pressed(_controls.get("Up"), true):
		var next_pos:Vector2 = self.global_position + Vector2.UP * _stats.MOVE_DIST;
		#_Launch(next_pos, _stats.JUMP_HEIGHT / 3, 0.25, false);
		_Launch(next_pos, _stats.JUMP_HEIGHT, 0, false);
	elif Input.is_action_pressed(_controls.get("Down"), true):
		var next_pos:Vector2 = self.global_position + Vector2.DOWN * _stats.MOVE_DIST;
		#_Launch(next_pos, _stats.JUMP_HEIGHT / 3, 0.25, false);
		_Launch(next_pos, _stats.JUMP_HEIGHT, 0, false);
	# Left & Right
	if Input.is_action_pressed(_controls.get("Left"), true):
		var next_pos:Vector2 = self.global_position + Vector2.LEFT * _stats.MOVE_DIST;
		#_Launch(next_pos, _stats.JUMP_HEIGHT / 3, 0.25, false);
		_Launch(next_pos, _stats.JUMP_HEIGHT, 0, false);
		_Flip_Sprite(-1);
	elif Input.is_action_pressed(_controls.get("Right"), true):
		var next_pos:Vector2 = self.global_position + Vector2.RIGHT * _stats.MOVE_DIST;
		#_Launch(next_pos, _stats.JUMP_HEIGHT / 3, 0.25, false);
		_Launch(next_pos, _stats.JUMP_HEIGHT, 0, false);
		_Flip_Sprite(1);


func _Death() -> void:
	print("Player ", _player_num, " Died!");
	_Disable_Player();
	Death.emit();
	World.Disconnect_Signal_Connections(Death);


func _Fall_Death() -> void:
	print("Player ", _player_num, " Fell!");
	$"Health".Damage($"Health".Max_Health());
	#_Disable_Player();
	_Death();
	_Reset_Shadow();
	
	_spr.play("Idle");
	await get_tree().create_timer(.5).timeout;
	_spr.play("Hurt");
	await get_tree().create_timer(.5).timeout;
	# Parent player with Environment for Y-Sort when Falling
	self.reparent(_environment);
	var fall_tween:Tween = create_tween();
	fall_tween.set_parallel(true);
	fall_tween.tween_property(_spr, "offset:y", 64, .5);
	fall_tween.tween_property(_spr, "modulate:a", 0, .5);
	
	await get_tree().create_timer(2).timeout;
	
	World.Remove_Player(_player_num);


func _Enable_Player() -> void:
	set_process(true);


func _Disable_Player() -> void:
	
	# Disconnect Connections to Signals in This Script
	
	for item in [
		Launch_Landed,
		Submit_Button
	]:
		var sig:Signal = item;
		World.Disconnect_Signal_Connections(sig);
	
	# Disconnect Connections to External Signals
	
	if $Launcher.Launch.is_connected(_Launch):
		$Launcher.Launch.disconnect(_Launch);
		
	for other in _other_players:
		if other.Launch_Landed.is_connected(_SIGNAL_Enemy_Launch_Landed):
			other.Launch_Landed.disconnect(_SIGNAL_Enemy_Launch_Landed);
	
	set_process(false);


func Other_Players_In_World() -> Array[Node2D]:
	
	var others:Array[Node2D] = World.PLAYERS.values() as Array;
	
	for player in others:
		if player.Number() == _player_num:
			others.erase(player);
	
	return others;


func _Flip_Sprite(dir:int):
	if dir < 0 && _facing_right:
		_facing_right = false;
	elif dir > 0 && !_facing_right:
		_facing_right = true;
	_spr.flip_h = _facing_right;


func _Poop() -> void:
	var poop:Sprite2D = Spawner.New_Poop();
	get_parent().add_child(poop);
	poop.position = self.position.round();


func _Reset_Shadow() -> void:
	if _shadow:
		Embellishments.Reset_Shadow(_shadow);


# Functions: Launch ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func _Launch(end:Vector2, y_offset:float, power:float, hurt:bool) -> void:
	
	#if World.DEBUG: print("Player ", _player_num, " Attempt Launch");
	
	if _busy:
		return;
		
	var starting_point:Vector2 = self.global_position;
	
	_launch_start = starting_point;
	_launch_end = end;
	#_launch_height = y_offset * _stats.JUMP_HEIGHT;
	_launch_height = clamp(y_offset, 3, y_offset);
	_launch_power = power;
	
	_busy = true;
	
	_hurt = hurt;
	
	# Start Launch
	_launch_prog = 0;
	_grounded = false;
	
	if _hurt:
		
		# Smack Sound
		Sound_Master.Play_Smack(randf_range(.95, 1.05));
		
		_spr.play("Hurt");
		
	elif !_hurt:
		
		_spr.play("Land");
		_charging = true;
		
		if _launch_power > 0.25:
			_charging_time = 1;
			# Shadow
			_shadow = Embellishments.Get_Shadow();
			_shadow.position = starting_point;
			_shadow.modulate.a = 1;
			# Snarl Sound
			if _stats.PREP_SFX:
				Sound_Master.Play_Pitched_Sound(_stats.PREP_SFX);
		else:
			_charging_time = _stats.MOVE_DELAY;


func _Mid_Launch_Position(start:Vector2, end:Vector2, progress:float) -> Vector2:
	var raw_dir:Vector2 = end - start;
	var next_pos:Vector2 = start + raw_dir * progress;
	next_pos.y -= sin(progress * PI) * _launch_height;
	return next_pos;


func _Reset_Launch() -> void:
	await get_tree().process_frame;
	_busy = false;
	if $Health.Is_Alive():
		_spr.play("Idle");


# Functions: Get Set ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Number() -> int:
	return _player_num;


func Stats() -> Mon_Stats:
	return _stats;


func Controls() -> Dictionary:
	return _controls;


func _Get_Closest_PlayerPosition() -> Vector2:
	
	var lowest_dist:float;
	var closest:Node2D;
	
	for other in _other_players:
		
		var dist:float = other.position.distance_to(self.position);
		
		if lowest_dist == 0 or dist < lowest_dist:
			lowest_dist = dist;
			closest = other;

	return closest.position;
