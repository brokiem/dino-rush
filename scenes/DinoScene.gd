class_name DinoScene extends CharacterBody2D

@export var Speed = 220;
@export var MaxSpeed = 500;
@export var JumpVelocity = -350;

var IsSneaking = false;
var IsAlive = true;
var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _isStarted = false;

@onready var _animatedSprite = $AnimatedSprite2D;
@onready var _jumpSfx = preload("res://assets/sfx/jump.wav");
@onready var _dieSfx = preload("res://assets/sfx/die.wav");
@onready var _pointSfx = preload("res://assets/sfx/point.wav");

func _ready():
	pass;

func _physics_process(delta):
	if (!IsAlive || !_isStarted): return;
	
	var isOnFloor = is_on_floor();
	
	if (!isOnFloor):
		velocity.y += _gravity * delta;
		pass;
		
	if (Input.is_action_just_pressed("jump") && isOnFloor):
		Jump();
	elif (isOnFloor && _animatedSprite.animation == "jump"):
		_animatedSprite.play("walk");
		pass;
	
	if (Input.is_action_just_pressed("sneak")):
		Sneak(true);
	elif (Input.is_action_just_released("sneak")):
		Sneak(false);
		pass;
		
	velocity.x = Speed;
	move_and_slide();
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collName = collision.get_collider().name;
		
		if (collName == "ObstacleTilemap" || collName == "StaticBody2D"):
			Kill();
			
			get_parent().get_node("CanvasLayer/RestartButton").visible = true;
			get_parent().get_node("CanvasLayer/GameOverLabel").visible = true;
			get_parent().get_node("CanvasLayer/JumpButton").visible = false;
			get_parent().get_node("CanvasLayer/SneakButton").visible = false;
			pass;

func Start():
	get_parent().LoadHighScore();
	
	_isStarted = true;
	IsAlive = true;
		
	Jump();
	pass;
	
func Kill():
	_isStarted = false;
	IsAlive = false;
	
	$Camera2D.shake(0.2, 15, 10);
				
	_animatedSprite.speed_scale = 1;
	_animatedSprite.play("dead");
	
	$AudioStreamPlayer2D.stream = _dieSfx;
	$AudioStreamPlayer2D.play();
	
	get_parent().SaveHighScore();
	pass;
	
func Jump():	
	_animatedSprite.play("jump");
	velocity.y = JumpVelocity;
	
	$AudioStreamPlayer2D.stream = _jumpSfx;
	$AudioStreamPlayer2D.play();
	pass;
	
func Sneak(val):
	if (val):
		$CollisionShape2D2.position.y = -2;
		
		var lastFrame = _animatedSprite.frame;
		_animatedSprite.play("sneak");
		_animatedSprite.frame = lastFrame;
		_gravity *= 4;
		IsSneaking = true;
	else:
		$CollisionShape2D2.position.y = -4;
		
		var lastFrame = _animatedSprite.frame;
		_animatedSprite.play("walk");
		_animatedSprite.frame = lastFrame;
		_gravity /= 4;
		IsSneaking = false;
	pass;
	
func SetSpeed(speed):
	if (Speed > MaxSpeed): return;
		
	Speed = speed;
	_animatedSprite.speed_scale = speed / 120;
	pass;
	
func Point():
	$AudioStreamPlayer2D2.stream = _pointSfx;
	$AudioStreamPlayer2D2.play();
	pass;
