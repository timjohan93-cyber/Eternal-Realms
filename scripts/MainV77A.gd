extends "res://scripts/MainV77.gd"

# Eternal Realms V7.7A
# Character Screen Cleanup / Reference Layout Pass
# Fixes double Passive UI and starts moving toward one unified ARPG character screen.

var v77a_left_panel: Panel
var v77a_left_label: Label
var v77a_right_panel: Panel
var v77a_right_label: Label
var v77a_passive_nodes := {}
var v77a_passive_connectors := []

func _ready() -> void:
	super._ready()
	create_v77a_layout_panels()
	create_v77a_integrated_passive_tree()
	update_character_ui()

func create_v77a_layout_panels() -> void:
	if character_preview_panel == null:
		return

	character_preview_panel.position = Vector2(35, 85)
	character_preview_panel.size = Vector2(2490, 1180)
	character_preview_panel.z_index = 160

	if v77a_left_panel == null:
		v77a_left_panel = Panel.new()
		v77a_left_panel.name = "V77ALeftStats"
		v77a_left_panel.position = Vector2(25, 105)
		v77a_left_panel.size = Vector2(420, 980)
		v77a_left_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		character_preview_panel.add_child(v77a_left_panel)

		v77a_left_label = Label.new()
		v77a_left_label.position = Vector2(25, 25)
		v77a_left_label.size = Vector2(370, 930)
		v77a_left_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v77a_left_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v77a_left_panel.add_child(v77a_left_label)

	if v77a_right_panel == null:
		v77a_right_panel = Panel.new()
		v77a_right_panel.name = "V77ARightStats"
		v77a_right_panel.position = Vector2(1990, 105)
		v77a_right_panel.size = Vector2(470, 980)
		v77a_right_panel.mouse_filter = Control.MOUSE_FILTER_STOP
		character_preview_panel.add_child(v77a_right_panel)

		v77a_right_label = Label.new()
		v77a_right_label.position = Vector2(25, 25)
		v77a_right_label.size = Vector2(420, 930)
		v77a_right_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v77a_right_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v77a_right_panel.add_child(v77a_right_label)

	# Move the existing title/tabs into a wide top-bar style.
	for tab in v77_tab_buttons.keys():
		var btn: Button = v77_tab_buttons[tab]
		var index := ["Equipment", "Skills", "Passives", "Paragon", "Build"].find(tab)
		if index >= 0:
			btn.position = Vector2(680 + index * 215, 45)
			btn.size = Vector2(190, 48)

	# Move preview body to center.
	if character_preview_label != null:
		character_preview_label.position = Vector2(950, 112)
		character_preview_label.size = Vector2(590, 36)
	if character_preview_body != null:
		character_preview_body.position = Vector2(1260, 585)
	if character_preview_aura != null:
		character_preview_aura.position = Vector2(1260, 585)

	# Equipment slot placement inspired by the reference mockup.
	set_preview_slot_rect("Helmet", Vector2(690, 215), Vector2(170, 72))
	set_preview_slot_rect("Amulet", Vector2(690, 365), Vector2(170, 72))
	set_preview_slot_rect("Chest", Vector2(690, 520), Vector2(170, 72))
	set_preview_slot_rect("Gloves", Vector2(690, 675), Vector2(170, 72))
	set_preview_slot_rect("Ring1", Vector2(690, 830), Vector2(170, 72))
	set_preview_slot_rect("Weapon", Vector2(1645, 245), Vector2(170, 72))
	set_preview_slot_rect("Offhand", Vector2(1830, 245), Vector2(170, 72))
	set_preview_slot_rect("Belt", Vector2(1645, 510), Vector2(170, 72))
	set_preview_slot_rect("Boots", Vector2(1645, 680), Vector2(170, 72))
	set_preview_slot_rect("Ring2", Vector2(1645, 850), Vector2(170, 72))

func set_preview_slot_rect(slot_name: String, pos: Vector2, size: Vector2) -> void:
	if not character_preview_slots.has(slot_name):
		return
	var btn: Button = character_preview_slots[slot_name]
	btn.position = pos
	btn.size = size

func create_v77a_integrated_passive_tree() -> void:
	if character_preview_panel == null:
		return
	if v77a_passive_nodes.size() > 0:
		return
	add_v77a_passive_column("OFFENSE", Vector2(720, 210), ["Damage", "Crit Chance", "Crit Damage"])
	add_v77a_passive_column("DEFENSE", Vector2(1170, 210), ["Health", "Armor", "Regen"])
	add_v77a_passive_column("UTILITY", Vector2(1620, 210), ["Move Speed", "Gold Find", "Magic Find"])

func add_v77a_passive_column(title_text: String, origin: Vector2, nodes: Array) -> void:
	var header := Label.new()
	header.position = origin
	header.size = Vector2(260, 34)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.text = title_text
	header.add_theme_font_size_override("font_size", 20)
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(header)
	v77a_passive_nodes[title_text + "_header"] = header

	for i in range(nodes.size()):
		var node_name: String = nodes[i]
		var btn := Button.new()
		btn.position = origin + Vector2(35, 75 + i * 220)
		btn.size = Vector2(190, 95)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.pressed.connect(func(): on_passive_node_clicked(node_name))
		character_preview_panel.add_child(btn)
		v77a_passive_nodes[node_name] = btn

		if i < nodes.size() - 1:
			var connector := ColorRect.new()
			connector.position = origin + Vector2(126, 170 + i * 220)
			connector.size = Vector2(8, 125)
			connector.color = Color(0.55, 0.45, 0.25, 0.8)
			connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
			character_preview_panel.add_child(connector)
			v77a_passive_connectors.append(connector)

func update_character_ui() -> void:
	super.update_character_ui()
	if passive_tree_panel != null:
		passive_tree_panel.visible = false
	if character_panel != null:
		character_panel.visible = false
	if character_label != null:
		character_label.visible = false
	update_v77a_panels()
	update_v77a_integrated_passives()

func update_v77a_panels() -> void:
	if v77a_left_panel == null or v77a_right_panel == null:
		return
	var show := character_open
	v77a_left_panel.visible = show
	v77a_right_panel.visible = show

	if v77a_left_label != null:
		var left := "ATTRIBUTES\n\n"
		left += "Strength: " + str(strength) + "\n"
		left += "Dexterity: " + str(dexterity) + "\n"
		left += "Intellect: " + str(intellect) + "\n"
		left += "Willpower: " + str(willpower) + "\n\n"
		left += "COMBAT\n\n"
		left += "Damage: " + str(damage) + "\n"
		left += "Armor: " + str(armor) + "\n"
		left += "Crit Chance: " + str(int(crit_chance * 100)) + "%\n"
		left += "Crit Damage: " + str(int(crit_damage * 100)) + "%\n"
		left += "Move Speed: " + str(int(move_speed)) + "\n\n"
		left += "LOOT\n\n"
		left += "Magic Find: " + str(int(magic_find_bonus * 100)) + "%\n"
		left += "Gold Find: " + str(int(gold_find_bonus * 100)) + "%\n"
		v77a_left_label.text = left

	if v77a_right_label != null:
		var right := current_class + "\nLevel " + str(level) + "\nXP " + str(xp) + "/" + str(xp_to_next) + "\n\n"
		right += "STATS\n\n"
		right += "Health: " + str(hp) + "/" + str(max_hp) + "\n"
		right += "Mana: " + str(mana) + "/" + str(max_mana) + "\n"
		right += "Health Regen: " + str(int(health_regen)) + "/s\n"
		right += "Mana Regen: " + str(int(mana_regen)) + "/s\n\n"
		right += "GODLIKE\n\n"
		right += "Godlike Slots: " + str(get_equipped_godlike_count()) + "/2\n"
		right += "Aura: " + ("Active" if get_equipped_godlike_count() > 0 else "Inactive") + "\n\n"
		right += "SELECTED\n\n"
		if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
			right += item_to_text(inventory[selected_inventory_index])
		else:
			right += "None"
		v77a_right_label.text = right

func update_v77a_integrated_passives() -> void:
	var show := character_open and character_tab == "Passives"
	for key in v77a_passive_nodes.keys():
		var node = v77a_passive_nodes[key]
		if is_instance_valid(node):
			node.visible = show
	for c in v77a_passive_connectors:
		if is_instance_valid(c):
			c.visible = show

	if not show:
		return

	for node_name in passive_ranks.keys():
		if v77a_passive_nodes.has(node_name):
			var btn: Button = v77a_passive_nodes[node_name]
			var rank: int = int(passive_ranks.get(node_name, 0))
			btn.text = get_passive_icon(node_name) + "\n" + node_name + "\n" + str(rank) + "/10"
			btn.tooltip_text = get_passive_tooltip(node_name)
			btn.modulate = Color(1.0, 0.95, 0.75, 1.0) if rank > 0 else Color(0.72, 0.72, 0.72, 1.0)

func update_v77_content() -> void:
	if v77_content_label == null:
		return

	var text := ""
	if character_tab == "Equipment":
		text += "EQUIPMENT\n"
		text += "Click item in inventory, then click gear slot.\n"
		text += "Click equipped slot with no selected item to unequip."
	elif character_tab == "Skills":
		text += "SKILLS\n\n"
		var book = get_class_skill_book()
		for i in range(book.size()):
			var sk = book[i]
			text += get_skill_icon(str(sk["name"])) + "  " + str(sk["name"]) + " Rank " + str(get_skill_rank(i)) + "/20\n"
	elif character_tab == "Passives":
		text += "PASSIVES\n"
		text += "Passive Points: " + str(passive_points) + "\n"
		text += "Click nodes in the main panel to upgrade.\nShift-click to refund."
	elif character_tab == "Paragon":
		text += "PARAGON\n\n"
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
		btn.visible = character_open and character_tab == "Equipment"

func update_v74_passive_tree_ui() -> void:
	if passive_tree_panel != null:
		passive_tree_panel.visible = false

func is_mouse_over_open_ui(mouse_pos: Vector2) -> bool:
	if character_preview_panel != null and character_preview_panel.visible and get_panel_rect_global(character_preview_panel).has_point(mouse_pos):
		return true
	return super.is_mouse_over_open_ui(mouse_pos)
