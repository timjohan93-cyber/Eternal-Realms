extends "res://scripts/MainV80A.gd"

# Eternal Realms V8.0B
# Combat Control Fix
# Prevents enemy target-lock from feeling like lost movement control during/after attacks.

func _process(delta: float) -> void:
	clear_invalid_v80b_combat_target()
	super._process(delta)
	clear_invalid_v80b_combat_target()

func handle_input() -> void:
	var screen_mouse := get_viewport().get_mouse_position()
	var world_mouse := get_global_mouse_position()
	var left_clicked := mouse_button_just_pressed(MOUSE_BUTTON_LEFT)
	var mouse_over_ui := is_mouse_over_open_ui(screen_mouse)

	# Important: while attacking, a normal left-click on empty ground must break target-lock
	# before inherited input keeps chasing the old enemy.
	if left_clicked and not mouse_over_ui and not game_menu_open:
		var clicked_enemy = get_enemy_at_position(world_mouse)
		var clicked_item = get_ground_item_at_position(world_mouse)
		if clicked_enemy == null and clicked_item == null and not is_click_on_portal_master(world_mouse):
			selected_enemy = null
			pending_portal_interaction = false
			target_pos = world_mouse

	super.handle_input()

func update_player(delta: float) -> void:
	clear_invalid_v80b_combat_target()
	super.update_player(delta)

func try_auto_attack() -> void:
	clear_invalid_v80b_combat_target()
	if selected_enemy == null:
		return
	if not selected_enemy.has("body") or not is_instance_valid(selected_enemy["body"]):
		selected_enemy = null
		if player != null:
			target_pos = player.position
		return
	if bool(selected_enemy.get("is_dead", false)) or float(selected_enemy.get("hp", 1)) <= 0.0:
		selected_enemy = null
		if player != null:
			target_pos = player.position
		return
	super.try_auto_attack()
	clear_invalid_v80b_combat_target()

func damage_enemy(enemy, amount: int, crit := false) -> void:
	super.damage_enemy(enemy, amount, crit)
	clear_invalid_v80b_combat_target()

func clear_invalid_v80b_combat_target() -> void:
	if selected_enemy == null:
		return
	if typeof(selected_enemy) != TYPE_DICTIONARY:
		selected_enemy = null
		if player != null:
			target_pos = player.position
		return
	if not selected_enemy.has("body") or not is_instance_valid(selected_enemy["body"]):
		selected_enemy = null
		if player != null:
			target_pos = player.position
		return
	if bool(selected_enemy.get("is_dead", false)) or float(selected_enemy.get("hp", 1)) <= 0.0:
		selected_enemy = null
		if player != null:
			target_pos = player.position
