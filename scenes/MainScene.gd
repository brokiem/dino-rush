class_name MainScene extends Node2D

var obstacleScenes = [
	preload("res://scenes/obstacles/Cactus.tscn"),
	preload("res://scenes/obstacles/Cactus2.tscn"),
	preload("res://scenes/obstacles/CactusGroup.tscn"),
	preload("res://scenes/obstacles/Bird.tscn")
];
var obstacleInstances = [];

var _minSpawnDelay = 55;
var _maxSpawnDelay = 100;
var _spawnDelay = 55;

var IsStarted = false;
var Score = 0;
var HighScore = 0;

@onready var _dino = $Dino;
@onready var _scoreLabel = $CanvasLayer/ScoreLabel;
@onready var _highScoreLabel = $CanvasLayer/HighScoreLabel;
@onready var _fpsLabel = $CanvasLayer/FPSLabel;

const WINDOWS_OS_NAMES = ["Windows","UWP"]
const MACOS_OS_NAMES = ["macOS"]
const LINUX_OS_NAMES = ["Linux"]
const BSD_OS_NAMES = ["FreeBSD", "NetBSD", "OpenBSD","BSD"]
const MOBILE_OS_NAMES = ["Android","iOS"]
const DESKTOP_OS_NAMES = WINDOWS_OS_NAMES + MACOS_OS_NAMES + LINUX_OS_NAMES + BSD_OS_NAMES
const WEB_OS_NAMES = ["HTML5"]

var OS_NAME = OS.get_name()
var __isDesktop = OS_NAME in DESKTOP_OS_NAMES
var __isMobile = OS_NAME in MOBILE_OS_NAMES
var __isWeb = OS_NAME in WEB_OS_NAMES

func get_os_name():
	return OS_NAME
func isDesktop():
	return __isDesktop
func isMobile():
	return __isMobile
func isWeb():
	return __isWeb

# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE);
	
	for scene in obstacleScenes:
		obstacleInstances.append(scene.instantiate())
		pass;
		
	if (isMobile()):
		$CanvasLayer/StartLabel.text = " Press Jump to play ";
		$CanvasLayer/InstructionLabel.text = "Controls\nYou can press the left side of your screen to Sneak\nYou can also press the right side of your screen to Jump"
		
	$CanvasLayer/RestartButton.visible = false;
	$CanvasLayer/GameOverLabel.visible = false;
	
	LoadHighScore();
	pass
	
func _input(event):
	if event is InputEventScreenTouch and event.is_pressed() and !IsStarted:
		StartGame();
		pass;

func _physics_process(_delta):
	_fpsLabel.text = "FPS: " + str(Engine.get_frames_per_second());
	
	if (!IsStarted && Input.is_action_just_pressed("jump")):
		StartGame();
	
	if (!_dino.IsAlive || !IsStarted):
		return
		
	_scoreLabel.text = str(Score);
	Score += 1;
	
	if (Score % 1000 == 0):
		_dino.Point();	
		_dino.SetSpeed(_dino.Speed + 30);
		if (_minSpawnDelay > 35): _minSpawnDelay -= 5;
		if (_maxSpawnDelay > 40): _maxSpawnDelay -= 10;
		
	_spawnDelay -= 1;
	SpawnRandomObstacle();
	pass;
	
func SpawnRandomObstacle():
	if (_spawnDelay > 0): return;
	
	_spawnDelay = randi() % (_maxSpawnDelay - _minSpawnDelay + 1) + _minSpawnDelay;

	var spawnIndex = randi() % obstacleInstances.size();
	var node = obstacleInstances[spawnIndex].duplicate();
	node.global_position = Vector2(_dino.global_position.x + 375, 48);
	add_child(node);
	pass;
	
func _OnRestartButtonPressed():
	get_tree().reload_current_scene();
	pass;
		
func StartGame(): 
	IsStarted = true;
	$CanvasLayer/StartLabel.visible = false;
	$CanvasLayer/InstructionLabel.visible = false;
	
	if (isMobile()):
		$CanvasLayer/JumpButton.visible = true;
		$CanvasLayer/SneakButton.visible = true;
	
	_dino.Start();
	pass;
	
func LoadHighScore():
	if (!FileAccess.file_exists("user://highscore.dat")): return;
	
	var file = FileAccess.open("user://highscore.dat", FileAccess.READ);
	HighScore = int(file.get_as_text());
	_highScoreLabel.text = "HI " + str(HighScore);
	file.close();
	pass;
	
func SaveHighScore():
	if (Score <= HighScore): return;
	
	HighScore = Score;
	_highScoreLabel.text = "HI " + str(HighScore);
	
	var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE);
	file.store_string(str(HighScore));
	file.close();
	pass;

func _on_jump_button_button_down():
	if (!_dino.IsAlive || !IsStarted):
		return;
	
	_dino.Jump();
	pass;

func _on_sneak_button_button_down():
	if (!_dino.IsAlive || !IsStarted):
		return;
		
	_dino.Sneak(true);
	pass;

func _on_sneak_button_button_up():
	if (!_dino.IsAlive || !IsStarted):
		return;
		
	_dino.Sneak(false);
	pass
