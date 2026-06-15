extends "res://scripts/MainV76.gd"

# Eternal Realms V7.7.0
# Character Screen Merge
# Makes the new character preview the main character screen and makes equipment slots clickable.

var v77_tab_buttons := {}
var v77_content_label: Label

func _ready() -> void:
	super._ready()
	upgrade_v77_character_screen()
	update_character_ui()

func upgrade_v77_character_screen() -> void:
	if character_panel != null:
		character_panel.visible = false
		character_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if character_label != null:
		character_label.visible = false
		character_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if character_preview_panel == null:
		return

	character_preview_panel.position = Vector2(520, 120)
	character_preview_panel.size = Vector2(1320, 760)
	character_preview_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	character_preview_panel.z_index = 140

	create_v77_tabs()
	create_v77_content_label()
	make_preview_slots_clickable()

func create_v77_tabs() -> void:
	if character_preview_panel == null:
		return
	if v77_tab_buttons.size() > 0:
		return

	var tabs = ["Equipment", "Skills", "Passives", "Paragon", "Build"]
	for i in range(tabs.size()):
		var tab_name = tabs[i]
		var btn := Button.new()
		btn.position = Vector2(25 + i * 150, 52)
		btn.size = Vector2(135, 38)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.text = tab_name
		btn.pressed.connect(func(): set_v77_character_tab(tab_name))
		character_preview_panel.add_child(btn)
		v77_tab_buttons[tab_name] = btn

func create_v77_content_label() -> void:
	if character_preview_panel == null:
		return
	if v77_content_label != null and is_instance_valid(v77_content_label):
		return

	v77_content_label = Label.new()
	v77_content_label.position = Vector2(810, 105)
	v77_content_label.size = Vector2(470, 600)
	v77_content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v77_content_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(v77_content_label)

func make_preview_slots_clickable() -> void:
	for slot_name in character_preview_slots.keys():
		var btn: Button = character_preview_slots[slot_name]
		btn.disabled = false
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.focus_mode = Control.FOCUS_NONE
		if not btn.pressed.is_connected(func(): pass):
			pass
		btn.pressed.connect(func(): on_v77_equipment_slot_clicked(slot_name))

func set_v77_character_tab(tab_name: String) -> void:
	character_tab = tab_name
	update_character_ui()

func on_v77_equipment_slot_clicked(slot_name: String) -> void:
	if character_tab != "Equipment":
		character_tab = "Equipment"

	if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
		equip_selected_to_slot(slot_name)
		selected_inventory_index = -1
		update_inventory_ui()
		update_character_ui()
		return

	if equipment.has(slot_name) and equipment[slot_name] != null:
		unequip_slot(slot_name)
		update_inventory_ui()
		update_character_ui()
		return

	loot_label.text = "Select an inventory item, then click an equipment slot."

func toggle_character_screen() -> void:
	character_open = not character_open
	if character_panel != null:
		character_panel.visible = false
	if character_preview_panel != null:
		character_preview_panel.visible = character_open
	if character_open:
		close_vendor_windows()
		character_tab = "Equipment"
	update_inventory_ui()
	update_character_ui()

func update_character_ui() -> void:
	super.update_character_ui()
	if character_panel != null:
		character_panel.visible = false
	if character_label != null:
		character_label.visible = false

	if character_preview_panel != null:
		character_preview_panel.visible = character_open
		if character_preview_panel.visible:
			character_preview_panel.move_to_front()

	for tab in v77_tab_buttons.keys():
		var btn: Button = v77_tab_buttons[tab]
		btn.text = ("* " if tab == character_tab else "") + tab

	update_v77_content()
	update_v76_character_preview()

func update_v77_content() -> void:
	if v77_content_label == null:
		return

	var text := ""
	if character_tab == "Equipment":
		text += "EQUIPMENT\n"
		text += "Click item in inventory, then click a slot here.\n"
		text += "Click equipped slot with no selected item to unequip.\n\n"
		if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
			var item = inventory[selected_inventory_index]
			text += "Selected:\n" + item_to_text(item)
		else:
			text += "Selected: None\n\n"
		text += "Godlike Slots: " + str(get_equipped_godlike_count()) + "/2\n"
		text += "Damage: " + str(damage) + " | Armor: " + str(armor) + "\n"
		text += "HP: " + str(hp) + "/" + str(max_hp) + " | Mana: " + str(mana) + "/" + str(max_mana)

	elif character_tab == "Skills":
		text += "SKILLS\n"
		text += "Use F1-F8 to select skill for now.\n"
		text += "Assign: Z=RMB, X=Q, C=W, V=E, B=R soon.\n\n"
		var book = get_class_skill_book()
		for i in range(book.size()):
			var sk = book[i]
			text += get_skill_icon(str(sk["name"])) + "  " + str(sk["name"]) + " Rank " + str(get_skill_rank(i)) + "/20\n"

	elif character_tab == "Passives":
		text += "PASSIVES\n"
		text += "Passive tree opens in its own clean panel.\n"
		text += "Passive Points: " + str(passive_points) + "\n"
		text += "Click nodes to upgrade. Shift-click to refund."

	elif character_tab == "Paragon":
		text += "PARAGON\n"
		if level < 40:
			text += "Locked until level 40.\n"
		else:
			text += "Paragon Level: " + str(paragon_level) + "\nPoints: " + str(paragon_points) + "\n"
		text += "Future: constellation-style endgame tree."

	elif character_tab == "Build":
		text += get_build_analysis()

	v77_content_label.text = text

func update_v76_character_preview() -> void:
	super.update_v76_character_preview()
	if character_preview_panel == null:
		return
	character_preview_panel.visible = character_open

	for slot_name in character_preview_slots.keys():
		var btn: Button = character_preview_slots[slot_name]
		btn.visible = character_tab == "Equipment"

func update_v74_passive_tree_ui() -> void:
	super.update_v74_passive_tree_ui()
	if passive_tree_panel != null:
		passive_tree_panel.visible = character_open and character_tab == "Passives"
		if passive_tree_panel.visible:
			passive_tree_panel.move_to_front()

func is_mouse_over_open_ui(mouse_pos: Vector2) -> bool:
	if character_preview_panel != null and character_preview_panel.visible and get_panel_rect_global(character_preview_panel).has_point(mouse_pos):
		return true
	return super.is_mouse_over_open_ui(mouse_pos)
