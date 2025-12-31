class_name Spawner

const _main_spritesheet:Texture2D = preload("res://sprites/main_spritesheet.png");


static func New_Poop() -> Sprite2D:
	var spr:Sprite2D = Sprite2D.new();
	spr.texture = _main_spritesheet;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(16, 16);
	spr.region_rect.position = Vector2([0, 16, 32].pick_random(), 16);
	spr.z_as_relative = false;
	spr.z_index = -2;
	return spr;


static func New_Shadow() -> Sprite2D:
	var spr:Sprite2D = Sprite2D.new();
	spr.texture = _main_spritesheet;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(16, 16);
	spr.region_rect.position = Vector2(0, 0);
	spr.z_as_relative = false;
	spr.z_index = -1;
	return spr;


static func New_Spark() -> Sprite2D:
	var spr:Sprite2D = Sprite2D.new();
	spr.texture = _main_spritesheet;
	spr.region_enabled = true;
	spr.region_rect.size = Vector2(16, 16);
	spr.region_rect.position = Vector2(16, 0);
	spr.z_as_relative = false;
	spr.z_index = 10;
	return spr;
