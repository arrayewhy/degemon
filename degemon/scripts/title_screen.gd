extends CanvasGroup

signal Game_Start;


func _ready() -> void:
	set_process(false);
	self.modulate.a = 0;
	var tween:Tween = create_tween();
	tween.tween_property(self, "modulate:a", 1, 2);
	await tween.finished;
	set_process(true);


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("Submit_1") || \
	Input.is_action_just_pressed("Submit_2"):
		
		Sound_Master.Play_Submit();
		
		set_process(false);
		
		$"Press_Start".material.set_shader_parameter("speed", 15);
		var tween:Tween = create_tween();
		tween.set_trans(Tween.TRANS_QUAD);
		tween.set_ease(Tween.EASE_IN);
		tween.tween_property(self, "modulate:a", 0, 1);
		await tween.finished;
		
		Game_Start.emit();
		World.Disconnect_Signal_Connections(Game_Start);
