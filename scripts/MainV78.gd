extends "res://scripts/MainV77D.gd"

# Eternal Realms V7.8
# Character Screen Reference Layout Pass
# Keeps gameplay stable while giving each Character Screen tab a focused layout.

var v78_paragon_nodes := {}
var v78_paragon_connectors := []
var v78_paragon_header: Label
var v78_equipment_hint: Label

func _ready() -> void:
	super._ready()
	create_v78_reference_helpers()
	create_v78_paragon_board()
	apply_v78_reference_layout()
	update_character_ui()
	update_inventory_ui()

func create_v78_reference_helpers() -> void:
	if character_preview_panel == null:
		return
	if v78_equipment_hint != null and is_instance_valid(v78_equipment_hint):
		return

	v78_equipment_hint = Label.new()
	v78_equipment_hint.name = "V78EquipmentHint"
	v78_equipment_hint.position = Vector2(600, 895)
	v78_equipment_hint.size = Vector2(420, 48)
	v78_equipment_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v78_equipment_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v78_equipment_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(v78_equipment_hint)

func create_v78_paragon_board() -> void:
	if character_preview_panel == null:
		return
	if v78_paragon_nodes.size() > 0:
		return

	v78_paragon_header = Label.new()
	v78_paragon_header.name = "V78ParagonHeader"
	v78_paragon_header.position = Vector2(470, 135)
	v78_paragon_header.size = Vector2(680, 60)
	v78_paragon_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v78_paragon_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v78_paragon_header.add_theme_font_size_override("font_size", 22)
	v78_paragon_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(v78_paragon_header)

	add_v78_paragon_connector(Vector2(794, 288), Vector2(8, 105))
	add_v78_paragon_connector(Vector2(794, 500), Vector2(8, 105))
	add_v78_paragon_connector(Vector2(642, 440), Vector2(130, 8))
	add_v78_paragon_connector(Vector2(828, 440), Vector2(130, 8))

	add_v78_paragon_node("Core Power", Vector2(700, 225), true)
	add_v78_paragon_node("Bloodline", Vector2(700, 405), level >= 40)
	add_v78_paragon_node("Fortress", Vector2(520, 405), level >= 40)
	add_v78_paragon_node("Treasure", Vector2(880, 405), level >= 40)
	add_v78_paragon_node("Ascendant", Vector2(700, 620), paragon_level >= 5)

func add_v78_paragon_connector(pos: Vector2, size: Vector2) -> void:
	var connector := ColorRect.new()
	connector.position = pos
	connector.size = size
	connector.color = Color(0.55, 0.42, 0.18, 0.85)
	connector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(connector)
	v78_paragon_connectors.append(connector)

func add_v78_paragon_node(node_name: String, pos: Vector2, unlocked: bool) -> void:
	var btn := Button.new()
	btn.position = pos
	btn.size = Vector2(170, 95)
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.disabled = not unlocked
	btn.text = node_name
	btn.tooltip_text = "Paragon board preview. Full allocation comes in a later version."
	btn.pressed.connect(func(): on_v78_paragon_node_clicked(node_name))
	character_preview_panel.add_child(btn)
	v78_paragon_nodes[node_name] = btn

func on_v78_paragon_node_clicked(node_name: String) -> void:
	if level < 40:
		loot_label.text = "Paragon unlocks at level 40."
		return
	loot_label.text = "Paragon preview node: " + node_name

func apply_v78_reference_layout() -> void:
	if character_preview_panel == null:
		return

	character_preview_panel.position = Vector2(310, 90)
	character_preview_panel.size = Vector2(1710, 1040)
	character_preview_panel.z_index = 170

	for tab in v77_tab_buttons.keys():
		var btn: Button = v77_tab_buttons[tab]
		var index := ["Equipment", "Skills", "Passives", "Paragon", "Build"].find(tab)
		if index >= 0:
			btn.position = Vector2(340 + index * 205, 38)
			btn.size = Vector2(185, 44)

	if character_preview_label != null:
		character_preview_label.position = Vector2(620, 98)
		character_preview_label.size = Vector2(460, 36)
		character_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	if character_preview_body != null:
		character_preview_body.position = Vector2(800, 515)
	if character_preview_aura != null:
		character_preview_aura.position = Vector2(800, 515)

	if v77a_left_panel != null:
		v77a_left_panel.position = Vector2(25, 100)
		v77a_left_panel.size = Vector2(310, 850)
	if v77a_left_label != null:
		v77a_left_label.position = Vector2(18, 20)
		v77a_left_label.size = Vector2(275, 810)

	if v77a_right_panel != null:
		v77a_right_panel.position = Vector2(1360, 100)
		v77a_right_panel.size = Vector2(325, 850)
	if v77a_right_label != null:
		v77a_right_label.position = Vector2(18, 20)
		v77a_right_label.size = Vector2(290, 810)

	if v77_content_label != null:
		v77_content_label.position = Vector2(380, 150)
		v77_content_label.size = Vector2(890, 760)

	set_preview_slot_rect("Helmet", Vector2(470, 170), Vector2(150, 64))
	set_preview_slot_rect("Amulet", Vector2(470, 300), Vector2(150, 64))
	set_preview_slot_rect("Chest", Vector2(470, 430), Vector2(150, 64))
	set_preview_slot_rect("Gloves", Vector2(470, 560), Vector2(150, 64))
	set_preview_slot_rect("Ring1", Vector2(470, 690), Vector2(150, 64))
	set_preview_slot_rect("Weapon", Vector2(980, 220), Vector2(150, 64))
	set_preview_slot_rect("Offhand", Vector2(980, 350), Vector2(150, 64))
	set_preview_slot_rect("Belt", Vector2(980, 480), Vector2(150, 64))
	set_preview_slot_rect("Boots", Vector2(980, 610), Vector2(150, 64))
	set_preview_slot_rect("Ring2", Vector2(980, 740), Vector2(150, 64))

	if inventory_panel != null:
		inventory_panel.position = Vector2(2035, 90)
		inventory_panel.size = Vector2(500, 1040)

func update_character_ui() -> void:
	super.update_character_ui()
	apply_v78_reference_layout()
	apply_v78_tab_visibility()
	update_v78_focused_passives()
	update_v78_paragon_board()
	if character_preview_label != null:
		character_preview_label.text = current_class + " " + character_tab
	if v78_equipment_hint != null:
		v78_equipment_hint.text = "Select inventory item, then click an equipment slot. Click equipped slot with no selected item to unequip."

func update_inventory_ui() -> void:
	super.update_inventory_ui()
	if inventory_panel != null:
		inventory_panel.position = Vector2(2035, 90)
		inventory_panel.size = Vector2(500, 1040)

func apply_v78_tab_visibility() -> void:
	var show_equipment := character_open and character_tab == "Equipment"
	var show_passives := character_open and character_tab == "Passives"
	var show_paragon := character_open and character_tab == "Paragon"

	if v77a_left_panel != null:
		v77a_left_panel.visible = show_equipment
	if v77a_right_panel != null:
		v77a_right_panel.visible = show_equipment
	if v78_equipment_hint != null:
		v78_equipment_hint.visible = show_equipment

	for slot_name in character_preview_slots.keys():
		var btn: Button = character_preview_slots[slot_name]
		if btn != null and is_instance_valid(btn):
			btn.visible = show_equipment

	if character_preview_body != null:
		character_preview_body.visible = show_equipment
	if character_preview_aura != null:
		character_preview_aura.visible = show_equipment

	for key in v77a_passive_nodes.keys():
		var node = v77a_passive_nodes[key]
		if is_instance_valid(node):
			node.visible = show_passives
	for c in v77a_passive_connectors:
		if is_instance_valid(c):
			c.visible = show_passives

	if v78_paragon_header != null:
		v78_paragon_header.visible = show_paragon
	for key in v78_paragon_nodes.keys():
		var btn: Button = v78_paragon_nodes[key]
		if is_instance_valid(btn):
			btn.visible = show_paragon
	for c in v78_paragon_connectors:
		if is_instance_valid(c):
			c.visible = show_paragon

func update_v77a_panels() -> void:
	super.update_v77a_panels()
	if v77a_left_panel != null:
		v77a_left_panel.visible = character_open and character_tab == "Equipment"
	if v77a_right_panel != null:
		v77a_right_panel.visible = character_open and character_tab == "Equipment"

func update_v77_content() -> void:
	if v77_content_label == null:
		return

	var text := ""
	if character_tab == "Equipment":
		text += "EQUIPMENT\n\n"
		text += "Character in center. Gear slots around the hero. Stats live in the left panel and item/build details live on the right.\n\n"
		if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
			text += "Selected item:\n" + item_to_text(inventory[selected_inventory_index])
		else:
			text += "Selected item: None\n\nOpen inventory and choose an item to equip."
	elif character_tab == "Skills":
		text += "SKILLS\n\n"
		text += "Skill Points: " + str(skill_points) + "\n\n"
		var book = get_class_skill_book()
		for i in range(book.size()):
			var sk = book[i]
			text += get_skill_icon(str(sk["name"])) + "  " + str(sk["name"]) + "  Rank " + str(get_skill_rank(i)) + "/20\n"
		text += "\nAssignments remain on the current hotkey system for this pass."
	elif character_tab == "Passives":
		text += "PASSIVES\n\n"
		text += "Passive Points: " + str(passive_points) + "\n"
		text += "Use the focused passive tree in this tab. Stats are hidden here so the tree has breathing room.\n"
		text += "Click nodes to upgrade. Shift-click to refund."
	elif character_tab == "Paragon":
		text += "PARAGON\n\n"
		if level < 40:
			text += "Locked until level 40.\n\n"
		else:
			text += "Paragon Level: " + str(paragon_level) + "\nPoints: " + str(paragon_points) + "\n\n"
		text += "This version adds the first dedicated Paragon board space. Full node spending can build on this next."
	elif character_tab == "Build":
		text += "BUILD\n\n"
		text += get_build_analysis()

	v77_content_label.text = text

func update_v78_paragon_board() -> void:
	if v78_paragon_header != null:
		if level < 40:
			v78_paragon_header.text = "PARAGON BOARD\nUnlocks at level 40"
		else:
			v78_paragon_header.text = "PARAGON BOARD\nLevel " + str(paragon_level) + " | Points " + str(paragon_points)

	for key in v78_paragon_nodes.keys():
		var btn: Button = v78_paragon_nodes[key]
		if not is_instance_valid(btn):
			continue
		var unlocked := level >= 40
		if key == "Core Power":
			unlocked = true
		if key == "Ascendant":
			unlocked = paragon_level >= 5
		btn.disabled = not unlocked
		btn.modulate = Color(1.0, 0.82, 0.35, 1.0) if unlocked else Color(0.45, 0.45, 0.45, 1.0)
		btn.text = key + ("\nUnlocked" if unlocked else "\nLocked")

func update_v78_focused_passives() -> void:
	if not (character_open and character_tab == "Passives"):
		return

	var node_to_rank := {
		"Damage": "Damage Training",
		"Crit Chance": "Crit Training",
		"Crit Damage": "Crit Training",
		"Health": "Armor Training",
		"Armor": "Armor Training",
		"Regen": "Cooldown Training",
		"Move Speed": "Movement Training",
		"Gold Find": "Movement Training",
		"Magic Find": "Cooldown Training"
	}

	for key in v77a_passive_nodes.keys():
		var node = v77a_passive_nodes[key]
		if not is_instance_valid(node):
			continue
		if str(key).ends_with("_header"):
			node.visible = true
			continue
		if node is Button:
			var btn: Button = node
			var rank_key: String = str(node_to_rank.get(key, ""))
			var rank := int(passive_ranks.get(rank_key, 0)) if rank_key != "" else 0
			btn.text = str(key) + "\nRank " + str(rank) + "/10"
			btn.tooltip_text = "Mapped to " + rank_key if rank_key != "" else "Passive preview node"
			btn.modulate = Color(1.0, 0.88, 0.45, 1.0) if rank > 0 else Color(0.72, 0.72, 0.72, 1.0)
