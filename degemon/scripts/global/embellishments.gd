extends Node2D

var _shadow_holder:Node;
var _spark_holder:Node;


func _ready() -> void:
	get_tree().scene_changed.connect(_Initialise);
	_Initialise();


func _Initialise() -> void:
	# Shadows
	_shadow_holder = _Create_ShadowHolder_And_Shadows();
	_shadow_holder.name = "Shadow_Holder";
	self.add_child(_shadow_holder);
	# Sparks
	_spark_holder = _Create_SparkHolder_And_Sparks();
	_spark_holder.name = "Spark_Holder";
	self.add_child(_spark_holder);


# Sparks ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_Spark() -> Sprite2D:
	
	for spark in _spark_holder.get_children():
		# We use Visibility as a Signal of Activation
		# If this asset is Visible, we consider it In Use
		if !spark.visible:
			spark.show();
			return spark;
			
	var new_spark:Sprite2D = Spawner.New_Spark();
	new_spark.modulate.a = 0;
	_spark_holder.add_child(new_spark);
	return new_spark;


func Reset_Sparks() -> void:
	for spark in _spark_holder.get_children():
		if spark.visible:
			spark.hide();


func _Create_SparkHolder_And_Sparks() -> Node:
	var holder:Node2D = Node2D.new();
	for i in 2:
		var spark:Sprite2D = Spawner.New_Spark();
		spark.hide();
		spark.modulate.a = 0;
		holder.add_child(spark);
	return holder;


# Shadows ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


func Get_Shadow() -> Sprite2D:
	
	for shadow in _shadow_holder.get_children():
		# We use Visibility as a Signal of Activation
		# If this asset is Visible, we consider it In Use
		if !shadow.visible:
			shadow.show();
			return shadow;
			
	var new_shadow:Sprite2D = Spawner.New_Shadow();
	new_shadow.modulate.a = 0;
	_shadow_holder.add_child(new_shadow);
	return new_shadow;


func Reset_Shadow(shadow:Sprite2D) -> void:
	shadow.modulate.a = 0;
	shadow.hide();


func Reset_Shadows() -> void:
	for shadow in _shadow_holder.get_children():
		if shadow.visible:
			shadow.hide();


func _Create_ShadowHolder_And_Shadows() -> Node:
	var holder:Node2D = Node2D.new();
	for i in 2:
		var shadow:Sprite2D = Spawner.New_Shadow();
		shadow.hide();
		shadow.modulate.a = 0;
		holder.add_child(shadow);
	return holder;
