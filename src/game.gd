extends Node3D

@onready var hp_bar: TextureProgressBar = $CanvasLayer/UIRoot/HPBar
@onready var player: CharacterBody3D = $Player  # Adjust path as needed

func _process(_delta):
	hp_bar.value = player.current_hp
	
