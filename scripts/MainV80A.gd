extends "res://scripts/MainV80.gd"

# Eternal Realms V8.0A
# Dungeon Input Safety Patch
# Keeps V8.0 character visuals, but makes dungeon geometry non-interactive so it cannot steal movement clicks.

func _ready() -> void:
	super._ready()
	apply_v80a_world_mouse_filters()

func enter_random_dungeon() -> void:
	super.enter_random_dungeon()
	cleanup_v80a_transition_state()
	apply_v80a_world_mouse_filters()
	apply_v80_character_class_visual(current_class)
	if player != null:
		target_pos = player.position
	loot_label.text += "\nDungeon input ready. Left-click floor to move."

func return_to_town() -> void:
	super.return_to_town()
	cleanup_v80a_transition_state()
	apply_v80a_world_mouse_filters()
	apply_v80_character_class_visual(current_class)
	if player != null:
		target_pos = player.position

func create_room_rect(center: Vector2, room_type: String) -> void:
	super.create_room_rect(center, room_type)
	apply_v80a_world_mouse_filters()

func create_corridor(a: Vector2, b: Vector2) -> void:
	super.create_corridor(a, b)
	apply_v80a_world_mouse_filters()

func cleanup_v80a_transition_state() -> void:
	pending_portal_interaction = false
	selected_enemy = null
	mouse_memory.clear()
	key_memory.clear()
	game_menu_open = false
	options_open = false
	inventory_open = false
	character_open = false
	merchant_open = false
	blacksmith_open = false
	mystic_open = false
	dev_open = false

	if game_menu_panel != null:
		game_menu_panel.visible = false
	if options_panel != null:
		options_panel.visible = false
	if inventory_panel != null:
		inventory_panel.visible = false
	if character_panel != null:
		character_panel.visible = false
	if character_preview_panel != null:
		character_preview_panel.visible = false
	if merchant_panel != null:
		merchant_panel.visible = false
	if blacksmith_panel != null:
		blacksmith_panel.visible = false
	if mystic_panel != null:
		mystic_panel.visible = false
	if dev_panel != null:
		dev_panel.visible = false

	# Main menu should stay hidden after Play, including after dungeon/town transitions.
	if main_menu_panel != null:
		main_menu_panel.visible = false
	game_started = true

func apply_v80a_world_mouse_filters() -> void:
	# Visual-only world rectangles must not capture mouse clicks.
	if has_node("Background"):
		var bg = get_node("Background")
		if bg is Control:
			var bg_control: Control = bg
			bg_control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for n in dungeon_nodes:
		if n != null and is_instance_valid(n) and n is Control:
			var ctrl: Control = n
			ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Menu character visuals are decorative; the existing class cards/buttons remain the click targets.
	for key in v80_menu_character_nodes.keys():
		var node: Node2D = v80_menu_character_nodes[key]
		if node != null and is_instance_valid(node):
			for child in node.get_children():
				if child is Control:
					var child_control: Control = child
					child_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
