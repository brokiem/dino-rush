class_name Area extends Area2D

func _OnBodyEntered(body):
	if (body.name != "Dino"): return;
	
	var terrain = get_parent().duplicate();
	terrain.global_position = Vector2i((body.global_position.x + 384), 48);
	get_parent().get_parent().call_deferred("add_child", terrain);
	pass;
