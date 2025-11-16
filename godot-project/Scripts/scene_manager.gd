extends Node
@onready var scene_anim := $SceneTransition/SceneTransitionControl/AnimationPlayer
@onready var current_level := $"MainMenu"
var next_level : Object
var next_level_name : String

func _ready() -> void:
	# Allows the signal to be emitted and carried out here
	current_level.connect('level_changed', handle_level_changed)
	# Start the main menu with a slide out animation
	scene_anim.play('slide_out')

# Runs when signal is emitted
func handle_level_changed(current_level_name : String, fell : bool) -> void:
	# Based on the level name given in the function parameter, and if the player fell, the next level will be determined
	if fell:
		next_level_name = current_level_name # current_level_name for level reset, main_menu for game reset
	else:
		match current_level_name:
			'main_menu':
				next_level_name = 'level1'
			'quit':
				next_level_name = 'main_menu'
			'level1':
				next_level_name = 'level2'
			'level2':
				next_level_name = 'main_menu'
	# Make the next level, but not put it in the game yet
	next_level = load('res://Scenes/' + next_level_name + '.tscn').instantiate()
	# During transition, you can't pause, no pause node in main menu, can't get node that doesn't exist
	if current_level_name != 'main_menu':
		current_level.get_node('UI/Pause').pause_enabled = false
	# Begin the slider
	scene_anim.play("slide_in")
	# Transfers data from current level to new level, resets data at main menu
	if next_level_name != 'main_menu':
		next_level.load_level_parameters(current_level.level_parameters)

func _on_animation_player_animation_finished(anim_name) -> void:
	match anim_name:
		'slide_in':
			# Black screen
			await get_tree().create_timer(1.5).timeout
			# Gets rid of current level
			current_level.queue_free()
			await get_tree().process_frame
			# Puts next level into the game
			add_child(next_level)
			# Allows signal to be emitted for the next level
			next_level.connect('level_changed', handle_level_changed)
			# Updates current_level
			current_level = next_level
			# Slide out
			scene_anim.play('slide_out')
		'slide_out':
			# After transition, pausing enabled again
			if current_level.name != 'MainMenu':
				current_level.get_node('UI/Pause').pause_enabled = true
