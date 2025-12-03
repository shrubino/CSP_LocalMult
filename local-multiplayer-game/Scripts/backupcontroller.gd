extends CharacterBody2D

class_name PlatformerController2D


@export_category("Necesary Child Nodes")
@onready var PlayerSprite = $Sprite2D
@onready var PlayerCollider = $CollisionShape2D
@onready var leftRaycast: RayCast2D = $LeftCast
##Raycast used for corner cutting calculations. Place above of the players head point up. ALL ARE NEEDED FOR IT TO WORK.
@onready var middleRaycast: RayCast2D = $MiddleCast
##Raycast used for corner cutting calculations. Place above and to the right of the players head point up. ALL ARE NEEDED FOR IT TO WORK.
@onready var rightRaycast: RayCast2D = $RightCast

#INFO HORIZONTAL MOVEMENT 
@export_category("L/R Movement")
##The max speed your player will move
@export_range(50, 500) var maxSpeed: float = 150.0
##How fast your player will reach max speed from rest (in seconds)
@export_range(0, 4) var timeToReachMaxSpeed: float = 0.2
##How fast your player will reach zero speed from max speed (in seconds)
@export_range(0, 4) var timeToReachZeroSpeed: float = 0.2
##If true, player will instantly move and switch directions. Overrides the "timeToReach" variables, setting them to 0.
@export var directionalSnap: bool = false

#INFO JUMPING 
@export_category("Jumping and Gravity")
##The peak height of your player's jump
@export_range(0, 20) var jumpHeight: float = 2.0
##How many jumps your character can do before needing to touch the ground again. Giving more than 1 jump disables jump buffering and coyote time.
@export_range(0, 4) var jumps: int = 1
##The strength at which your character will be pulled to the ground.
@export_range(0, 100) var gravityScale: float = 20.0
##The fastest your player can fall
@export_range(0, 1000) var terminalVelocity: float = 500.0
##Your player will move this amount faster when falling providing a less floaty jump curve.
@export_range(0.5, 3) var descendingGravityFactor: float = 1.3
##Enabling this toggle makes it so that when the player releases the jump key while still ascending, their vertical velocity will cut by the height cut, providing variable jump height.
@export var shortHopAkaVariableJumpHeight: bool = true
##How much the jump height is cut by.
@export_range(1, 10) var jumpVariable: float = 2
##How much extra time (in seconds) your player will be given to jump after falling off an edge. This is set to 0.2 seconds by default.
@export var coyoteTime: float = 0.0
##The window of time (in seconds) that your player can press the jump button before hitting the ground and still have their input registered as a jump. This is set to 0.2 seconds by default.
@export_range(0, 0.5) var jumpBuffering: float = 0.2

#INFO EXTRAS
@export_category("Wall Jumping")
##Allows your player to jump off of walls. Without a Wall Kick Angle, the player will be able to scale the wall.
@export var wallJump: bool = true
##How long the player's movement input will be ignored after wall jumping.
@export_range(0, 0.5) var inputPauseAfterWallJump: float = 0.1
##The angle at which your player will jump away from the wall. 0 is straight away from the wall, 90 is straight up. Does not account for gravity
@export_range(0, 90) var wallKickAngle: float = 63.0
##The player's gravity will be divided by this number when touch a wall and descending. Set to 1 by default meaning no change will be made to the gravity and there is effectively no wall sliding. THIS IS OVERRIDDED BY WALL LATCH.
@export_range(1, 20) var wallSliding: float = 2.5

@export_category("Corner Cutting/Jump Correct")
##If the player's head is blocked by a jump but only by a little, the player will be nudged in the right direction and their jump will execute as intended. NEEDS RAYCASTS TO BE ATTACHED TO THE PLAYER NODE. AND ASSIGNED TO MOUNTING RAYCAST. DISTANCE OF MOUNTING DETERMINED BY PLACEMENT OF RAYCAST.
@export var cornerCutting: bool = true
##How many pixels the player will be pushed (per frame) if corner cutting is needed to correct a jump.
@export_range(1, 5) var correctionAmount: float = 2.0
##Raycast used for corner cutting calculations. Place above and to the left of the players head point up. ALL ARE NEEDED FOR IT TO WORK.

@export_category("Down Input")
##Holding down will crouch the player. Crouching script may need to be changed depending on how your player's size proportions are. It is built for 32x player's sprites.
@export var crouch: bool = false
##Holding down and pressing the input for "roll" will execute a roll if the player is grounded. Assign a "roll" input in project settings input.
@export var canRoll: bool = false
@export_range(1.25, 2) var rollLength: float = 2
##If enabled, the player will stop all horizontal movement midair, wait (groundPoundPause) seconds, and then slam down into the ground when down is pressed. 
@export var groundPound: bool = true
##The amount of time the player will hover in the air before completing a ground pound (in seconds)
@export_range(0.05, 0.75) var groundPoundPause: float = 0.25
##If enabled, pressing up will end the ground pound early
@export var upToCancel: bool = false

@export_category("Animations (Check Box if has animation)")
##Animations must be named "run" all lowercase as the check box says
@export var run: bool
##Animations must be named "jump" all lowercase as the check box says
@export var jump: bool
##Animations must be named "idle" all lowercase as the check box says
@export var idle: bool
##Animations must be named "walk" all lowercase as the check box says
@export var walk: bool
##Animations must be named "slide" all lowercase as the check box says
@export var slide: bool
##Animations must be named "falling" all lowercase as the check box says
@export var falling: bool


# Constants to replace magic numbers
const GROUND_POUND_VELOCITY_FACTOR = 2.0
const GROUND_POUND_TERMINAL_FACTOR = 10.0
const ANIMATION_SPEED_DIVISOR = 150.0
const SQUASH_STRETCH_FACTOR = 0.8
const ROLL_TIME_FACTOR = 0.25
const ROLL_INPUT_PAUSE_FACTOR = 0.0625
const COLLIDER_CROUCH_FACTOR = 8.0
const VERTICAL_IMPULSE_FACTOR = 10.0
const LATCH_CHECK_DELAY = 0.2

# State enum to manage player state
enum PlayerState {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING,
	WALL_SLIDING,
	WALL_LATCHING,
	DASHING,
	ROLLING,
	CROUCHING,
	GROUND_POUNDING
}

# Player state
var current_state = PlayerState.IDLE

# Animation related variables
var default_scale: Vector2
var is_stretching: bool = false
var is_squashing: bool = false
var stretch_amount: float = 1.1
var squash_amount: float = 0.90
var animation_speed: float = 15.0
var was_in_air: bool = false
var anim # Cached animation player
var col # Cached collider
var animScaleLock : Vector2

# Movement variables
var acceleration: float
var deceleration: float
var instantAccel: bool = false
var instantStop: bool = false

# Jumping variables
var jumpMagnitude: float = 500.0
var jumpCount: int
var jumpWasPressed: bool = false
var time_since_floor: float = 0.0

# Wall jumping variables
var latched: bool = false
var wasLatched: bool = false

# Direction tracking
var wasMovingR: bool = true
var wasPressingR: bool = false

# Special move variables
var dashing: bool = false
var rolling: bool = false
var crouching: bool = false
var groundPounding: bool = false

# Gravity variables
var appliedGravity: float
var appliedTerminalVelocity: float
var gravityActive: bool = true

# Dash variables
var dashMagnitude: float
var dashCount: int
var twoWayDashHorizontal: bool = false
var twoWayDashVertical: bool = false
var eightWayDash: bool = false

# Timer variables
var dash_time_remaining: float = 0.0
var roll_time_remaining: float = 0.0
var input_pause_time: float = 0.0

# Collider cache
var colliderScaleLockY
var colliderPosLockY

#Aiming and crosshair variables
var is_aiming = false
var crosshair_radius = 100.0
var crosshair_angle = 0.0
var crosshair_active = false
var crosshair_rotation_speed = 3.0

# Rope variables
var can_fire = true
var is_firing_rope = false
var is_swinging = false
var current_rope_length = 0.0
var has_been_on_rope = false
var current_rope_angle = 0.0
var spring_joint: DampedSpringJoint2D = null
var rope_body: StaticBody2D = null
var max_rope_length = 1000.0
var rope_firing_speed = 1000.0
var min_rope_length = 30.0
var swing_gravity = 9.8      # Adjustable swing gravity
var swing_damping = 0.995    # Slight damping for more natural feel
var swing_acceleration = 300.0  # How quickly swing builds up
var climb_speed = 100.0      # Speed at which player can climb the rope

# Input tracking structure
var input = {
	"left": false,
	"right": false,
	"up": false,
	"down": false,
	"left_tap": false,
	"right_tap": false,
	"left_release": false,
	"right_release": false,
	"jump": false,
	"jump_release": false,
	"run": false,
	"latch": false,
	"dash": false,
	"roll": false,
	"down_tap": false,
	"shift" : false,
	"Z" : false
}

# Movement input control 
var movementInputMonitoring: Vector2 = Vector2(true, true)

func _ready():
	# Initialize references and cache values
	anim = PlayerSprite
	col = PlayerCollider
	
	if anim:
		default_scale = anim.scale
	
	# Set initial state
	_updateData()

func _updateData():
	# Calculate movement parameters
	timeToReachMaxSpeed = max(timeToReachMaxSpeed, 0.01)  # Prevent division by zero
	timeToReachZeroSpeed = max(timeToReachZeroSpeed, 0.01)  # Prevent division by zero
	
	acceleration = maxSpeed / timeToReachMaxSpeed
	deceleration = -maxSpeed / timeToReachZeroSpeed
	
	# Calculate jump parameters
	jumpMagnitude = (10.0 * jumpHeight) * gravityScale
	jumpCount = jumps
	

	if anim:
		animScaleLock = abs(anim.scale)
	
	if col:
		colliderScaleLockY = col.scale.y
		colliderPosLockY = col.position.y
	
	# Set movement behavior flags
	instantAccel = timeToReachMaxSpeed <= 0
	instantStop = timeToReachZeroSpeed <= 0
	
	if directionalSnap:
		instantAccel = true
		instantStop = true
	
	# Disable coyote time and jump buffering for multi-jumps
	if jumps > 1:
		jumpBuffering = 0
		coyoteTime = 0
	
	# Ensure positive values
	coyoteTime = abs(coyoteTime)
	jumpBuffering = abs(jumpBuffering)
	
	# Set dash type flags
	twoWayDashHorizontal = false
	twoWayDashVertical = false
	eightWayDash = false
	

func _process(delta):
	# Handle animations
	#_handle_animations(delta)
	
	# Update timers
	_update_timers(delta)

func _physics_process(delta):
	# Update input state
	_update_input()
	# Handle movement
	_handle_horizontal_movement(delta)
	# Handle jumping, wall jumping, and gravity
	_handle_jumping_and_gravity(delta)
	# Handle special moves
	_handle_corner_cutting()
	_handle_ground_pound(delta)
	move_and_slide()
	

func _update_input():
	# Store previous state
	input.left_tap = false
	input.right_tap = false
	input.left_release = false
	input.right_release = false
	input.up = false
	input.down = false
	input.jump = false
	input.jump_release = false
	input.dash = false
	input.roll = false
	input.down_tap = false
	input.Z = false
	
	# Get current input state
	input.left = Input.is_action_pressed("ui_left")
	input.right = Input.is_action_pressed("ui_right")
	input.up = Input.is_action_pressed("ui_up")
	input.down = Input.is_action_pressed("ui_down")
	input.left_tap = Input.is_action_just_pressed("ui_left")
	input.right_tap = Input.is_action_just_pressed("ui_right")
	input.left_release = Input.is_action_just_released("ui_left")
	input.right_release = Input.is_action_just_released("ui_right")
	input.jump = Input.is_action_just_pressed("Space")
	input.jump_release = Input.is_action_just_released("Space")
	input.down_tap = Input.is_action_just_pressed("ui_down")
	
	# Update direction tracking
	if input.right_tap:
		wasPressingR = true
	if input.left_tap:
		wasPressingR = false

func _update_timers(delta):
	# Update dash timer
	if dash_time_remaining > 0:
		dash_time_remaining -= delta
		if dash_time_remaining <= 0:
			dashing = false
			if !is_on_floor():
				velocity.y = -gravityScale * VERTICAL_IMPULSE_FACTOR
	
	# Update roll timer
	if roll_time_remaining > 0:
		roll_time_remaining -= delta
		if roll_time_remaining <= 0:
			rolling = false
	
	# Update input pause timer
	if input_pause_time > 0:
		input_pause_time -= delta
		if input_pause_time <= 0:
			movementInputMonitoring = Vector2(true, true)
	
	# Update time since floor
	if is_on_floor():
		time_since_floor = 0.0
	else:
		time_since_floor = time_since_floor + delta

#func _handle_animations(delta):
	#
	## Set sprite direction
	#if input.right and !latched and anim:
		#anim.scale.x = animScaleLock.x
	#if input.left and !latched and anim:
		#anim.scale.x = animScaleLock.x * -1
	#
	## Apply squash and stretch effects
	#_apply_stretch_squash(delta)
	#
	## Handle state-based animations
	#if anim:
		#if dashing:
			#anim.speed_scale = 1
			#anim.play("dash")
			#return
			#
		#if rolling:
			#anim.speed_scale = 1
			#anim.play("roll")
			#return
			#
		#if latched:
			#anim.speed_scale = 1
			#anim.play("latch")
			#return
			#
		#if is_on_wall() and velocity.y > 0 and wallSliding != 1:
			#anim.speed_scale = 1
			#anim.play("slide")
			#return
			#
		#if velocity.y < 0 and !dashing:
			#anim.speed_scale = 1
			#anim.play("jump")
			#return
			#
		#if velocity.y > 40 and !dashing and !crouching:
			#anim.speed_scale = 1
			#anim.play("falling")
			#return
			#
		#if crouching and !rolling:
			#if abs(velocity.x) > 10:
				#anim.speed_scale = 1
				#anim.play("crouch_walk")
			#else:
				#anim.speed_scale = 1
				#anim.play("crouch_idle")
			#return
		#
		## Ground movement animations
		#if is_on_floor():
			#if abs(velocity.x) > 0.1:
				#anim.speed_scale = abs(velocity.x / ANIMATION_SPEED_DIVISOR)
				#if walk and abs(velocity.x) < maxSpeed:
					#anim.play("walk")
				#elif run:
					#anim.play("run")
			#elif idle:
				#anim.speed_scale = 1
				#anim.play("idle")

func _handle_horizontal_movement(delta):
	if !is_aiming:
	# Update movement direction tracking
		if velocity.x > 0:
			wasMovingR = true
		elif velocity.x < 0:
			wasMovingR = false
		
		# Process horizontal movement
		if input.right and input.left and movementInputMonitoring.x and movementInputMonitoring.y:
			# Handle opposing inputs
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0
		elif input.right and movementInputMonitoring.x:
			# Move right
			if velocity.x > maxSpeed or instantAccel:
				velocity.x = maxSpeed
			else:
				velocity.x += acceleration * delta
			
			if velocity.x < 0:
				if !instantStop:
					_decelerate(delta, false)
				else:
					velocity.x = 0
		elif input.left and movementInputMonitoring.y:
			# Move left
			if velocity.x < -maxSpeed or instantAccel:
				velocity.x = -maxSpeed
			else:
				velocity.x -= acceleration * delta
			
			if velocity.x > 0:
				if !instantStop:
					_decelerate(delta, false)
				else:
					velocity.x = 0
		elif !(input.left or input.right):
			# No horizontal input, slow down
			if !instantStop:
				_decelerate(delta, false)
			else:
				velocity.x = 0
	else:
		_decelerate(delta, false) #decelerate when aiming. not realllllly sure what the vertical (false) tag does in here though...

func _handle_jumping_and_gravity(delta):
	# Apply gravity based on velocity direction
	if velocity.y > 0:
		appliedGravity = gravityScale * descendingGravityFactor
	else:
		appliedGravity = gravityScale
	
	# Handle wall interactions
	if is_on_wall() and !groundPounding:
		appliedTerminalVelocity = terminalVelocity / wallSliding
		
	elif wallSliding != 1 and velocity.y > 0:
			# Wall sliding
			appliedGravity = appliedGravity / wallSliding
	elif !is_on_wall() and !groundPounding:
		appliedTerminalVelocity = terminalVelocity
	
	# Apply gravity
	if gravityActive:
		if velocity.y < appliedTerminalVelocity:
			velocity.y += appliedGravity
		elif velocity.y > appliedTerminalVelocity:
			velocity.y = appliedTerminalVelocity
	
	# Handle variable jump height
	if shortHopAkaVariableJumpHeight and input.jump_release and velocity.y < 0:
		velocity.y = velocity.y / jumpVariable
	
	# Reset jumps when on floor
	if is_on_floor():
		jumpCount = jumps
		
		# Perform buffered jump if needed
		if jumpWasPressed:
			_jump()
			jumpWasPressed = false
	# First jump after leaving the ground should only be allowed during coyote time
	elif !is_on_floor():
		if time_since_floor <= coyoteTime:
			jumpCount = jumps
		else:
		# If we've exceeded coyote time and haven't jumped yet, 
		# either remove ability to jump (jumps=1) or allow air jumps only (jumps>1)
			jumpCount = 0  # No jumps allowed after coyote time
	
	# Handle jump input
	if input.jump:
		if is_on_wall() and !is_on_floor():
			# Wall jump
			if wallJump:
				_wallJump()
		elif is_on_floor():
			# Normal jump from ground
			_jump()
		elif time_since_floor <= coyoteTime and jumpCount == jumps:
			# Coyote time jump (first jump only)
			_jump()
		elif jumpBuffering > 0 and jumps == 1:
			# Buffer jump for later
			jumpWasPressed = true
			_bufferJump()
		elif jumps > 1 and jumpCount > 0 and jumpCount < jumps:
			# Multi-jump in air, but ONLY for air jumps (not the ground jump)
			# This ensures we can't use the "ground" jump after coyote time
			velocity.y = -jumpMagnitude
			jumpCount -= 1
			_endGroundPound()

func _handle_corner_cutting():
	if !cornerCutting or velocity.y >= 0:
		return
	
	if leftRaycast and middleRaycast and rightRaycast:
		var left_colliding = leftRaycast.is_colliding()
		var middle_colliding = middleRaycast.is_colliding()
		var right_colliding = rightRaycast.is_colliding()
		
		if left_colliding and !middle_colliding and !right_colliding:
			position.x += correctionAmount
		elif !left_colliding and middle_colliding and !right_colliding:
			# Push in the direction of movement
			position.x += correctionAmount * (1 if wasMovingR else -1)
		elif !left_colliding and !middle_colliding and right_colliding:
			position.x -= correctionAmount

func _handle_ground_pound(delta):
	if groundPound:
		# Start ground pound
		if input.down_tap and !is_on_floor() and !is_on_wall() and !groundPounding:
			groundPounding = true
			gravityActive = false
			velocity.y = 0
			velocity.x = 0
			
			# Schedule the actual ground pound after pause
			await get_tree().create_timer(groundPoundPause).timeout
			if groundPounding:  # Check if still ground pounding
				_groundPound()
		
		# End ground pound when hitting ground
		if is_on_floor() and groundPounding:
			_endGroundPound()
		
		# Cancel ground pound with up
		if upToCancel and input.up and groundPounding:
			_endGroundPound()

func _jump():
	if (is_on_floor() or time_since_floor <= coyoteTime) and jumpCount > 0:
		velocity.y = -jumpMagnitude
		jumpCount -= 1
		jumpWasPressed = false

func _wallJump():
	var horizontalWallKick = abs(jumpMagnitude * cos(wallKickAngle * (PI / 180)))
	var verticalWallKick = abs(jumpMagnitude * sin(wallKickAngle * (PI / 180)))
	
	velocity.y = -verticalWallKick
	
	var dir = 1
	
	if wasMovingR:
		velocity.x = -horizontalWallKick * dir
	else:
		velocity.x = horizontalWallKick * dir
	
	if inputPauseAfterWallJump > 0:
		movementInputMonitoring = Vector2(false, false)
		input_pause_time = inputPauseAfterWallJump

func _bufferJump():
	await get_tree().create_timer(jumpBuffering).timeout
	jumpWasPressed = false

func _decelerate(delta, vertical):
	if !vertical:
		if (abs(velocity.x) > 0) and (abs(velocity.x) <= abs(deceleration * delta)):
			velocity.x = 0 
		elif velocity.x > 0:
			velocity.x += deceleration * delta
		elif velocity.x < 0:
			velocity.x -= deceleration * delta
	elif vertical and velocity.y > 0:
		velocity.y += deceleration * delta

func _groundPound():
	appliedTerminalVelocity = terminalVelocity * GROUND_POUND_TERMINAL_FACTOR
	velocity.y = jumpMagnitude * GROUND_POUND_VELOCITY_FACTOR
	
func _endGroundPound():
	groundPounding = false
	appliedTerminalVelocity = terminalVelocity
	gravityActive = true


func _apply_stretch_squash(delta):
	# Track when player is landing
	var just_landed = was_in_air and is_on_floor()
	was_in_air = !is_on_floor()
	
	# Start stretching when jumping
	if input.jump and (is_on_floor() or time_since_floor <= coyoteTime) and !is_stretching:
		is_stretching = true
		is_squashing = false
	
	# Start squashing when landing
	if just_landed and !is_squashing:
		is_squashing = true
		is_stretching = false
	
	if !anim:
		return
	
	# Calculate target scales with less extreme stretching
	var stretch_x_factor = 0.9  # Less extreme horizontal compression (was 0.7)
	var squash_x_factor = 1.1   # Less extreme horizontal stretching (inverse of 0.9)
	
	# Apply stretch effect (elongate vertically, compress horizontally)
	if is_stretching:
		anim.scale.y = lerp(anim.scale.y, default_scale.y * stretch_amount, animation_speed * delta)
		anim.scale.x = lerp(anim.scale.x, default_scale.x * stretch_x_factor, animation_speed * delta)
		
		# End stretch when close to target
		if abs(anim.scale.y - (default_scale.y * stretch_amount)) < 0.05:
			is_stretching = false
	
	# Apply squash effect (compress vertically, elongate horizontally)
	elif is_squashing:
		anim.scale.y = lerp(anim.scale.y, default_scale.y * squash_amount, animation_speed * delta)
		anim.scale.x = lerp(anim.scale.x, default_scale.x * squash_x_factor, animation_speed * delta)
		
		# End squash when close to target
		if abs(anim.scale.y - (default_scale.y * squash_amount)) < 0.05:
			is_squashing = false
	
	# Return to normal scale when not stretching or squashing
	elif !is_stretching and !is_squashing:
		anim.scale.y = lerp(anim.scale.y, default_scale.y, animation_speed * delta)
		anim.scale.x = lerp(anim.scale.x, default_scale.x * sign(anim.scale.x), animation_speed * delta)
	
	# Maintain the correct direction of the sprite
	if input.right and !latched:
		anim.scale.x = abs(anim.scale.x)
	if input.left and !latched:
		anim.scale.x = -abs(anim.scale.x)
