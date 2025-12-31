extends Node

const _songs:Dictionary[String, AudioStream] = {
	"arena" : preload("res://music/digimon_Arena_Battle_Theme 3.mp3"),
	"normal_battle" : preload("res://music/digimon_normal_battle.mp3"),
}


func _ready() -> void:
	var audio_player:AudioStreamPlayer = AudioStreamPlayer.new();
	self.add_child(audio_player);


func Play_Arena_Music(vol:float = 1) -> void:
	get_child(0).stream = _songs["arena"];
	get_child(0).volume_linear = vol;
	get_child(0).play();
	

func Play_Normal_Battle_Music(vol:float = 1) -> void:
	get_child(0).stream = _songs["normal_battle"];
	get_child(0).volume_linear = vol;
	get_child(0).play();


func Stop() -> void:
	get_child(0).stop();
