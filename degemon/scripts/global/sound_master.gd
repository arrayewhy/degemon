extends Node

const _sounds:Dictionary[String, AudioStream] = {
	"select" : preload("res://sounds/digimon_select_loud.wav"),
	"submit" : preload("res://sounds/digimon_submit.wav"),
	"window" : preload("res://sounds/digimon_window.wav"),
	"win" : preload("res://sounds/digimon_win.wav"),
	"smack_1" : preload("res://sounds/smack.wav"),
	"smack_2" : preload("res://sounds/smack_2.wav"),
	
	"skullgreymon_cry" : preload("res://sounds/skullgreymon_cry.wav"),
}


func _ready() -> void:
	for i in 2:
		var audio_stream_player:AudioStreamPlayer = AudioStreamPlayer.new();
		self.add_child(audio_stream_player);


func Play_Sound(sound:AudioStream, pitch_mod:float = 1, vol:float = 1) -> void:
	
	for audio_player in get_children():
		if !audio_player.playing:
			audio_player.stream = sound;
			audio_player.volume_db = linear_to_db(vol);
			audio_player.pitch_scale = pitch_mod;
			audio_player.play();
			return;
			
	var new_audio_player:AudioStreamPlayer2D = AudioStreamPlayer2D.new();
	self.add_child(new_audio_player);
	new_audio_player.stream = sound;
	new_audio_player.volume_db = linear_to_db(vol);
	new_audio_player.pitch_scale = pitch_mod;
	new_audio_player.play();

func Play_Pitched_Sound(sound:AudioStream) -> void:
	Play_Sound(sound, randf_range(.95, 1.05));


func Play_Select(pitch_mod:float = 1, vol:float = 1) -> void:
	Play_Sound(_sounds["select"], pitch_mod, vol);

func Play_Submit(pitch_mod:float = 1) -> void:
	Play_Sound(_sounds["submit"], pitch_mod);

func Play_Window(pitch_mod:float = 1) -> void:
	Play_Sound(_sounds["window"], pitch_mod);

func Play_Win(pitch_mod:float = 1) -> void:
	Play_Sound(_sounds["win"], pitch_mod);

func Play_Smack(pitch_mod:float = 1) -> void:
	Play_Sound(_sounds[
		["smack_1", "smack_2"].pick_random()
	], pitch_mod);


func Play_Skullgreymon_Cry(pitch_mod:float = 1) -> void:
	Play_Sound(_sounds["skullgreymon_cry"], pitch_mod);
