class_name Mon_Stats extends Resource

enum MONS {
	RANDOM,
	SUKAMON,
	DIGITAMAMON,
	SKULLGREYMON,
	TORQUE,
}

const Paths:Array[String] = [
	"NULL",
	"res://scripts/stats/Sukamon.tres",
	"res://scripts/stats/Digitamamon.tres",
	"res://scripts/stats/Skullgreymon.tres",
	"res://scripts/stats/Torque.tres",
]

@export var Anim:PackedScene;
@export var PREP_SFX:AudioStream;
@export var JUMP_SFX:AudioStream;
@export var LAND_SFX:AudioStream;

@export var NAME:MONS;
@export var HP:int = 20;
@export var ATK_1:int = 1;
@export var ATK_2:int = 1;
@export var RANGE_1:float = 10;
@export var KNOCKBACK_1:float;
@export var KNOCKBACK_2:float;
@export var ACT_SPD:int;
@export var MOVE_DIST:int;
@export var MOVE_DELAY:float = .1;
@export var MOVE_SPEED:float = 1;
@export var JUMP_HEIGHT:float;
