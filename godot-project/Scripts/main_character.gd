extends CharacterBody2D

# Assigning variables
var SPEED := 200.0
var MAX_FALL_SPEED := 700
const JUMP_VELOCITY := -800.0
var is_left := false
var hit := false
var alive := true
@onready var health = get_parent().get_parent().level_parameters.player1_health
@onready var healthbar := get_parent().get_parent().get_node('UI/Health/HealthBars/Player1Health')
@onready var sprite_2d := $Sprite2D
@onready var ap := $AnimationPlayer
@onready var player2 := get_parent().get_node('Player2')
@onready var level := get_parent().get_parent()
@onready var camera := $Camera2D
# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')

# Double jump variables
var jump_count := 0
var max_jumps := 2
var can_flip := true

# Dash variables
var DASHSPEED := 550.0
var is_dashing := false
var can_dash := true

func _ready() -> void:
	# Sets the boundaries of the camera for each level
	if get_parent().get_parent().get_name() == 'Level 1':
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = 4797
		camera.limit_bottom = 813
	if get_parent().get_parent().get_name() == 'Level 2':
		camera.limit_left = 2
		camera.limit_top = 0
		camera.limit_right = 2883
		camera.limit_bottom = 760
	# The camera is set to slowly move when at a limit, this snaps it in place
	# At the beginning of the level so the camera is never out of the level
	camera.reset_smoothing()

func _physics_process(delta) -> void:
	# Add the gravity
	if not is_on_floor():
		# Set max fall speed, once reached, stop acceleration
		if velocity.y < MAX_FALL_SPEED:
			velocity.y += gravity * delta
		# If you drop off a cliff it'll only let you double jump
		if jump_count == 0:
			jump_count = 1

	# Reset jump count and ability to play the flip animation
	else:
		jump_count = 0
		can_flip = true

	# If you've been hit you can't move
	if not hit:
		# Handle dash
		if Input.is_action_just_pressed('dash') and can_dash and velocity.x != 0:
			level.dash_sound()
			$Indicator.frame = 1
			is_dashing = true
			can_dash = false
			$DashTimer.start()
			$DashAgainTimer.start()

		# Handle jump and double jump
		if Input.is_action_just_pressed('jump') and (jump_count < max_jumps):
			level.jump_sound()
			if jump_count == 1:
				# Cancel a dash (if there is one)
				# and do a double jump with a height directly proportional to the main jump height
				is_dashing = false
				jump_count += 1
				velocity.y = JUMP_VELOCITY / 1.5
			else:
				jump_count += 1
				velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration
		var direction := Input.get_axis('left', 'right')
		if direction:
			if is_dashing:
				# Dash
				velocity.x = direction * DASHSPEED
				velocity.y = 0
			else:
				# Regular movespeed
				velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 30)

		# Manage which way to face
		if velocity.x < 0:
			is_left = true
		elif velocity.x > 0:
			is_left = false
		sprite_2d.flip_h = is_left
	else:
		# If hit, then approach velocity of 0 (stopping)
		velocity.x = move_toward(velocity.x, 0, 30)

	# Movement and animation function calls
	move_and_slide()
	update_animations()

# Animations
func update_animations() -> void:
	if alive:
		if not is_on_floor():
			# Begin flip animation if not flipping already
			if jump_count == 2 and can_flip:
				ap.play('flipping')
			else:
				# Jumping/Falling
				if velocity.y < 0:
					ap.play('jumping')
				elif velocity.y >= 0:
					ap.play('falling')
		else:
			# Idle/Walking
			if (velocity.x > 1 || velocity.x < -1):
				ap.play('running')
			else:
				ap.play('idle')

func _on_dash_timer_timeout() -> void:
	# Ends the dash
	is_dashing = false

func _on_dash_again_timer_timeout() -> void:
	# Allows the player to dash again
	can_dash = true
	$Indicator.frame = 0

func _on_animation_player_animation_finished(anim_name) -> void:
	# Once the flip animation is done, turn it off
	if anim_name == 'flipping':
		can_flip = false

func bounce_up() -> void:
	# Cancels a dash if there is one, launched up and unlocking player-enemy interactions
	is_dashing = false
	velocity.y = -600
	# Let's the player double jump after stomping
	can_flip = true
	jump_count = 1

func ouch(enemy_position) -> void:
	level.get_hit_sound()
	# What happens to the player when getting hit
	hit = true
	# Change health, update level parameter, and lose health icon in UI
	health -= 1
	get_parent().get_parent().level_parameters.player1_health = health
	match health:
		2:
			healthbar.get_node('Health3').hide()
		1:
			healthbar.get_node('Health2').hide()
		0:
			healthbar.hide()
	if health != 0:
		# Turn red
		set_modulate(Color(1, 0.3, 0.3, 0.3))
		# Launch away and look towards enemy that hit you
		velocity.y = -300
		if position.x < enemy_position:
			velocity.x = -600
			is_left = false
		elif position.x > enemy_position:
			velocity.x = 600
			is_left = true
		sprite_2d.flip_h = is_left
		# Can't hurt the enemy
		set_collision_layer_value(2, false)
		# If the player isn't dead, it comes back after being hit
		$ReanimateTimer.start()
	elif health == 0:
		# Die, plays animation, launched up, and goes through enemies and floors
		alive = false
		ap.play('hit')
		velocity.y = -600
		collision_layer = 0
		collision_mask = 0

func _on_reanimate_timer_timeout() -> void:
	# Allows character to move again
	hit = false
	$InvincibilityTimer.start()

func _on_invincibility_timer_timeout() -> void:
	# Turns back to normal color and can hit and be hit by enemies again
	set_collision_layer_value(2, true)
	set_modulate(Color(1, 1, 1, 1))

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Once leaving the screen after dying
	# If player 2 is alive, transfer camera to it
	if alive:
			hit = true # Just prevents player from playing after falling
			get_parent().get_parent().level_parameters.player1_health = health - 1
			if get_parent().get_parent().level_parameters.player1_health == 0:
				if is_instance_valid(player2):
					get_parent().get_parent().on_fall()
				else:
					get_parent().get_parent().on_quit()
			else:
				get_parent().get_parent().on_fall()
	else:
		if is_instance_valid(player2):
				player2.camera_transfer()
				healthbar.hide()
				queue_free()
		# If not, exit to main menu
		else:
			hit = true # Just prevents player from playing after falling
			get_parent().get_parent().on_quit()
