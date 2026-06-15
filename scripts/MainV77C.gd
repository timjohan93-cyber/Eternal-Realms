extends "res://scripts/MainV77B.gd"

# Eternal Realms V7.7C
# UI Fit / Equip Usability Patch
# Shrinks and repositions Character Screen and Inventory so they can be used together.

func _ready() -> void:
	super._ready()
	apply_v77c_ui_fit()
	update_character_ui()
	update_inventory_ui()

func apply_v77c_ui_fit() -> void:
	# Character screen: still wide enough for layout, but no longer covers the entire screen.
	if character_preview_panel != null:
		character_preview_panel.position = Vector2(520, 95)
		character_preview_panel.size = Vector2(1510, 1050)
		character_preview_panel.z_index = 150

	# Inventory: placed on the far right so selecting items and clicking character slots is practical.
	if inventory_panel != null:
		inventory_panel.position = Vector2(2045, 95)
		inventory_panel.size = Vector2(490, 1050)
		inventory_panel.z_index = 160

	if inventory_label != null:
		inventory_label.position = Vector2(18, 60)
		inventory_label.size = Vector2(450, 900)

	if equipment_label != null:
		equipment_label.visible = false

	# Hide separate passive tree permanently in this merged layout.
	if passive_tree_panel != null:
		passive_tree_panel.visible = false

	apply_v77c_character_layout_positions()

func apply_v77c_character_layout_positions() -> void:
	if character_preview_panel == null:
		return

	for tab in v77_tab_buttons.keys():
		var btn: Button = v77_tab_buttons[tab]
		var index := ["Equipment", "Skills", "Passives", "Paragon", "Build"].find(tab)
		if index >= 0:
			btn.position = Vector2(350 + index * 205, 40)
			btn.size = Vector2(185, 44)

	if character_preview_label != null:
		character_preview_label.position = Vector2(520, 95)
		character_preview_label.size = Vector2(470, 34)

	if character_preview_body != null:
		character_preview_body.position = Vector2(760, 520)
	if character_preview_aura != null:
		character_preview_aura.position = Vector2(760, 520)

	if v77a_left_panel != null:
		v77a_left_panel.position = Vector2(20, 100)
		v77a_left_panel.size = Vector2(300, 850)
	if v77a_left_label != null:
		v77a_left_label.position = Vector2(18, 20)
		v77a_left_label.size = Vector2(265, 810)

	if v77a_right_panel != null:
		v77a_right_panel.position = Vector2(1150, 100)
		v77a_right_panel.size = Vector2(335, 850)
	if v77a_right_label != null:
		v77a_right_label.position = Vector2(18, 20)
		v77a_right_label.size = Vector2(300, 810)

	if v77_content_label != null:
		v77_content_label.position = Vector2(1035, 160)
		v77_content_label.size = Vector2(430, 730)

	# Equipment slots compacted around the character.
	set_preview_slot_rect("Helmet", Vector2(430, 165), Vector2(145, 62))
	set_preview_slot_rect("Amulet", Vector2(430, 295), Vector2(145, 62))
	set_preview_slot_rect("Chest", Vector2(430, 425), Vector2(145, 62))
	set_preview_slot_rect("Gloves", Vector2(430, 555), Vector2(145, 62))
	set_preview_slot_rect("Ring1", Vector2(430, 685), Vector2(145, 62))
	set_preview_slot_rect("Weapon", Vector2(940, 220), Vector2(145, 62))
	set_preview_slot_rect("Offhand", Vector2(940, 350), Vector2(145, 62))
	set_preview_slot_rect("Belt", Vector2(940, 480), Vector2(145, 62))
	set_preview_slot_rect("Boots", Vector2(940, 610), Vector2(145, 62))
	set_preview_slot_rect("Ring2", Vector2(940, 740), Vector2(145, 62))

func toggle_inventory() -> void:
	inventory_open = not inventory_open
	inventory_panel.visible = inventory_open
	if inventory_open:
		# Inventory and character screen are allowed together for equip flow.
		close_vendor_windows()
		if inventory_panel != null:
			inventory_panel.move_to_front()
	update_inventory_ui()
	update_character_ui()

func toggle_character_screen() -> void:
	character_open = not character_open
	if character_panel != null:
		character_panel.visible = false
	if character_preview_panel != null:
		character_preview_panel.visible = character_open
	if character_open:
		close_vendor_windows()
		character_tab = "Equipment"
		if character_preview_panel != null:
			character_preview_panel.move_to_front()
		if inventory_panel != null and inventory_open:
			inventory_panel.move_to_front()
	apply_v77c_ui_fit()
	update_inventory_ui()
	update_character_ui()

func update_character_ui() -> void:
	super.update_character_ui()
	apply_v77c_ui_fit()
	if character_preview_panel != null:
		character_preview_panel.visible = character_open
	if passive_tree_panel != null:
		passive_tree_panel.visible = false

func update_inventory_ui() -> void:
	super.update_inventory_ui()
	if inventory_panel != null:
		inventory_panel.position = Vector2(2045, 95)
		inventory_panel.size = Vector2(490, 1050)
	if equipment_label != null:
		equipment_label.visible = false

func is_mouse_over_open_ui(mouse_pos: Vector2) -> bool:
	if inventory_panel != null and inventory_panel.visible and get_panel_rect_global(inventory_panel).has_point(mouse_pos):
		return true
	if character_preview_panel != null and character_preview_panel.visible and get_panel_rect_global(character_preview_panel).has_point(mouse_pos):
		return true
	return super.is_mouse_over_open_ui(mouse_pos)
