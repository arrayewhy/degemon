extends Sprite2D

var _players:Dictionary[int, Node2D];


func _ready() -> void:
	await get_tree().process_frame;
	_players = World.PLAYERS;


func _process(_delta: float) -> void:
	for player in _players.values():
		if player.position.distance_to(self.position) <= 16:
			self.hide();
			set_process(false);
			$"../../Environment".Trigger_Floor_Fall(.1, .1);
			return;
