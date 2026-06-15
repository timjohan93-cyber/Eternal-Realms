extends "res://scripts/MainV78G.gd"

# Eternal Realms V7.8H
# Character UI Finalization Pass
# Gives each Character Screen tab a focused layout while preserving V7.8G action bar, icons and cooldown feedback.

var v78h_focus_panel: Panel
var v78h_focus_scroll: ScrollContainer
var v78h_focus_label: Label
var v78h_tab_title: Label

func _ready() -> void:
	super._ready()
	create_v78h_focus_panel()
	apply_v78h_layout()
	update_character_ui()

func create_v78h_focus_panel() -> void:
	if character_preview_panel == null:
		return
	if v78h_focus_panel != null and is_instance_valid(v78h_focus_panel):
		return

	v78h_focus_panel = Panel.new()
	v78h_focus_panel.name = "V78HFocusedTabPanel"
	v78h_focus_panel.position = Vector2(360, 135)
	v78h_focus_panel.size = Vector2(980, 720)
	v78h_focus_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	v78h_focus_panel.clip_contents = true
	v78h_focus_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.018, 0.019, 0.024, 0.96), Color(0.58, 0.42, 0.18, 0.95), 2))
	character_preview_panel.add_child(v78h_focus_panel)

	v78h_tab_title = Label.new()
	v78h_tab_title.name = "V78HTabTitle"
	v78h_tab_title.position = Vector2(22, 16)
	v78h_tab_title.size = Vector2(936, 32)
	v78h_tab_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v78h_tab_title.add_theme_font_size_override("font_size", 22)
	v78h_tab_title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.32, 1.0))
	v78h_tab_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v78h_focus_panel.add_child(v78h_tab_title)

	v78h_focus_scroll = ScrollContainer.new()
	v78h_focus_scroll.name = "V78HFocusedTabScroll"
	v78h_focus_scroll.position = Vector2(22, 62)
	v78h_focus_scroll.size = Vector2(936, 635)
	v78h_focus_scroll.clip_contents = true
	v78h_focus_scroll.follow_focus = true
	v78h_focus_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	v78h_focus_panel.add_child(v78h_focus_scroll)

	v78h_focus_label = Label.new()
	v78h_focus_label.name = "V78HFocusedTabText"
	v78h_focus_label.position = Vector2.ZERO
	v78h_focus_label.size = Vector2(900, 1200)
	v78h_focus_label.custom_minimum_size = Vector2(900, 1200)
	v78h_focus_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v78h_focus_label.add_theme_font_size_override("font_size", 15)
	v78h_focus_label.add_theme_color_override("font_color", Color(0.88, 0.82, 0.70, 1.0))
	v78h_focus_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v78h_focus_scroll.add_child(v78h_focus_label)

func update_character_ui() -> void:
	super.update_character_ui()
	create_v78h_focus_panel()
	apply_v78h_layout()
	update_v78h_tab_content()
	update_v78h_visibility()

func update_inventory_ui() -> void:
	super.update_inventory_ui()
	apply_v78h_layout()

func apply_v78h_layout() -> void:
	if character_preview_panel == null:
		return

	character_preview_panel.position = Vector2(310, 90)
	character_preview_panel.size = Vector2(1710, 1040)
	character_preview_panel.z_index = 230
	character_preview_panel.clip_contents = true

	for tab in v77_tab_buttons.keys():
		var btn: Button = v77_tab_buttons[tab]
		if btn == null or not is_instance_valid(btn):
			continue
		var index := ["Equipment", "Skills", "Passives", "Paragon", "Build"].find(str(tab))
		if index >= 0:
			btn.position = Vector2(340 + index * 205, 38)
			btn.size = Vector2(185, 44)

	if v78h_focus_panel != null and is_instance_valid(v78h_focus_panel):
		v78h_focus_panel.position = Vector2(360, 135)
		v78h_focus_panel.size = Vector2(980, 720)
	if v78h_focus_scroll != null and is_instance_valid(v78h_focus_scroll):
		v78h_focus_scroll.position = Vector2(22, 62)
		v78h_focus_scroll.size = Vector2(936, 635)
	if v78h_focus_label != null and is_instance_valid(v78h_focus_label):
		v78h_focus_label.position = Vector2.ZERO
		v78h_focus_label.size = Vector2(900, 1200)
		v78h_focus_label.custom_minimum_size = Vector2(900, 1200)

	if inventory_panel != null:
		inventory_panel.position = Vector2(2035, 90)
		inventory_panel.size = Vector2(500, 1040)

	apply_v78h_equipment_layout()
	apply_v78h_passive_layout()
	apply_v78h_paragon_layout()

func apply_v78h_equipment_layout() -> void:
	if character_preview_label != null:
		character_preview_label.position = Vector2(620, 98)
		character_preview_label.size = Vector2(460, 36)
		character_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		character_preview_label.text = current_class + " Equipment"

	if character_preview_body != null:
		character_preview_body.position = Vector2(800, 515)
	if character_preview_aura != null:
		character_preview_aura.position = Vector2(800, 515)

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

	if v77a_left_panel != null:
		v77a_left_panel.position = Vector2(25, 135)
		v77a_left_panel.size = Vector2(310, 720)
	if v77a_right_panel != null:
		v77a_right_panel.position = Vector2(1360, 135)
		v77a_right_panel.size = Vector2(325, 720)
	if v78_equipment_hint != null:
		v78_equipment_hint.position = Vector2(615, 875)
		v78_equipment_hint.size = Vector2(470, 52)

func apply_v78h_passive_layout() -> void:
	var column_origins := {
		"OFFENSE": Vector2(485, 190),
		"DEFENSE": Vector2(765, 190),
		"UTILITY": Vector2(1045, 190)
	}
	for key in v77a_passive_nodes.keys():
		var node = v77a_passive_nodes[key]
		if not is_instance_valid(node):
			continue
		var key_text := str(key)
		if key_text == "OFFENSE_header":
			node.position = column_origins["OFFENSE"]
			if node is Label:
				var l1: Label = node
				l1.size = Vector2(230, 30)
		elif key_text == "DEFENSE_header":
			node.position = column_origins["DEFENSE"]
			if node is Label:
				var l2: Label = node
				l2.size = Vector2(230, 30)
		elif key_text == "UTILITY_header":
			node.position = column_origins["UTILITY"]
			if node is Label:
				var l3: Label = node
				l3.size = Vector2(230, 30)

	var passive_positions := {
		"Damage": Vector2(520, 270),
		"Crit Chance": Vector2(520, 430),
		"Crit Damage": Vector2(520, 590),
		"Health": Vector2(800, 270),
		"Armor": Vector2(800, 430),
		"Regen": Vector2(800, 590),
		"Move Speed": Vector2(1080, 270),
		"Gold Find": Vector2(1080, 430),
		"Magic Find": Vector2(1080, 590)
	}
	for node_name in passive_positions.keys():
		if v77a_passive_nodes.has(node_name):
			var btn: Button = v77a_passive_nodes[node_name]
			if btn != null and is_instance_valid(btn):
				btn.position = passive_positions[node_name]
				btn.size = Vector2(180, 82)

func apply_v78h_paragon_layout() -> void:
	if v78_paragon_header != null:
		v78_paragon_header.position = Vector2(520, 150)
		v78_paragon_header.size = Vector2(760, 60)

	var paragon_positions := {
		"Core Power": Vector2(755, 260),
		"Bloodline": Vector2(755, 455),
		"Fortress": Vector2(535, 455),
		"Treasure": Vector2(975, 455),
		"Ascendant": Vector2(755, 675)
	}
	for key in paragon_positions.keys():
		if v78_paragon_nodes.has(key):
			var btn: Button = v78_paragon_nodes[key]
			if btn != null and is_instance_valid(btn):
				btn.position = paragon_positions[key]
				btn.size = Vector2(190, 95)

func update_v78h_visibility() -> void:
	var show_equipment := character_open and character_tab == "Equipment"
	var show_skills := character_open and character_tab == "Skills"
	var show_passives := character_open and character_tab == "Passives"
	var show_paragon := character_open and character_tab == "Paragon"
	var show_build := character_open and character_tab == "Build"
	var show_focus := show_skills or show_passives or show_paragon or show_build

	if v78h_focus_panel != null:
		v78h_focus_panel.visible = show_focus
	if v77_content_label != null:
		v77_content_label.visible = false

	if v77a_left_panel != null:
		v77a_left_panel.visible = show_equipment
	if v77a_right_panel != null:
		v77a_right_panel.visible = show_equipment
	if v78e_left_scroll != null:
		v78e_left_scroll.visible = show_equipment
	if v78d_right_scroll != null:
		v78d_right_scroll.visible = show_equipment
	if v78_equipment_hint != null:
		v78_equipment_hint.visible = show_equipment
	if character_preview_label != null:
		character_preview_label.visible = show_equipment
	if character_preview_body != null:
		character_preview_body.visible = show_equipment
	if character_preview_aura != null:
		character_preview_aura.visible = show_equipment and get_equipped_godlike_count() > 0

	for slot_name in character_preview_slots.keys():
		var slot_btn: Button = character_preview_slots[slot_name]
		if slot_btn != null and is_instance_valid(slot_btn):
			slot_btn.visible = show_equipment

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
		var pbtn: Button = v78_paragon_nodes[key]
		if is_instance_valid(pbtn):
			pbtn.visible = show_paragon
	for pc in v78_paragon_connectors:
		if is_instance_valid(pc):
			pc.visible = show_paragon

func update_v78h_tab_content() -> void:
	if v78h_focus_label == null or v78h_tab_title == null:
		return

	if character_tab == "Skills":
		v78h_tab_title.text = "SKILLS"
		v78h_focus_label.text = build_v78h_skills_text()
		v78h_focus_label.custom_minimum_size = Vector2(900, 1220)
	elif character_tab == "Passives":
		v78h_tab_title.text = "PASSIVE TREE"
		v78h_focus_label.text = build_v78h_passives_text()
		v78h_focus_label.custom_minimum_size = Vector2(900, 360)
	elif character_tab == "Paragon":
		v78h_tab_title.text = "PARAGON BOARD"
		v78h_focus_label.text = build_v78h_paragon_text()
		v78h_focus_label.custom_minimum_size = Vector2(900, 420)
	elif character_tab == "Build":
		v78h_tab_title.text = "BUILD ANALYSIS"
		v78h_focus_label.text = get_build_analysis()
		v78h_focus_label.custom_minimum_size = Vector2(900, 1220)
	else:
		v78h_tab_title.text = ""
		v78h_focus_label.text = ""

func build_v78h_skills_text() -> String:
	var text := "Skill Points Available: " + str(skill_points) + "\n\n"
	text += "ACTION BAR\n"
	for slot_name_value in v78b_skill_slots:
		var slot_name: String = str(slot_name_value)
		var skill_index: int = get_combat_slot_skill_index(slot_name)
		var skill: Dictionary = get_skill(skill_index)
		var skill_name: String = str(skill.get("name", "Skill"))
		text += slot_name + "  " + get_skill_icon(skill_name) + "  " + skill_name + "  Rank " + str(get_skill_rank(skill_index)) + "/20"
		text += "  Mana " + str(get_skill_cost(skill_index)) + "  CD " + str(get_skill_cooldown(skill_index)) + "s\n"

	text += "\nCLASS SKILL BOOK\n"
	var book = get_class_skill_book()
	for i in range(book.size()):
		var sk: Dictionary = book[i]
		var name: String = str(sk.get("name", "Skill"))
		text += str(i + 1) + ". " + get_skill_icon(name) + "  " + name + "\n"
		text += "   Rank " + str(get_skill_rank(i)) + "/20  Mana " + str(get_skill_cost(i)) + "  Cooldown " + str(get_skill_cooldown(i)) + "s\n"
		text += "   Icon: " + get_v78b_skill_icon_path(name) + "\n\n"
	text += "Controls: F1-F8 select, + rank up, - refund. Assignment UI will become click-based later."
	return text

func build_v78h_passives_text() -> String:
	var text := "Passive Points Available: " + str(passive_points) + "\n"
	text += "Total Points Spent: " + str(get_v78h_total_passive_points_spent()) + "\n\n"
	text += "POINTS BY CATEGORY\n"
	text += "Offense: " + str(get_v78h_passive_category_points(["Damage", "Crit Chance", "Crit Damage", "Damage Training", "Crit Training"])) + "\n"
	text += "Defense: " + str(get_v78h_passive_category_points(["Health", "Armor", "Regen", "Armor Training"])) + "\n"
	text += "Utility: " + str(get_v78h_passive_category_points(["Move Speed", "Gold Find", "Magic Find", "Movement Training", "Cooldown Training"])) + "\n\n"
	text += "Click passive nodes in the board below. Shift-click to refund.\n"
	text += "Stats are intentionally hidden here so the tree has room."
	return text

func build_v78h_paragon_text() -> String:
	var text := "Paragon Level: " + str(paragon_level) + "\n"
	text += "Paragon Points Available: " + str(paragon_points) + "\n"
	text += "Unlock: Level 40\n\n"
	if level < 40:
		text += "Paragon is locked. Continue leveling to unlock the endgame board.\n"
	else:
		text += "Paragon is active. This board is still a preview, but it now has its own focused space.\n"
	text += "\nCURRENT PREVIEW BONUSES\n"
	text += "Core Power: damage-oriented node\n"
	text += "Bloodline: sustain-oriented node\n"
	text += "Fortress: defense-oriented node\n"
	text += "Treasure: loot-oriented node\n"
	text += "Ascendant: late paragon node\n"
	return text

func get_v78h_total_passive_points_spent() -> int:
	var total := 0
	for key in passive_ranks.keys():
		total += int(passive_ranks.get(key, 0))
	return total

func get_v78h_passive_category_points(keys: Array) -> int:
	var total := 0
	for key_value in keys:
		var key := str(key_value)
		if passive_ranks.has(key):
			total += int(passive_ranks.get(key, 0))
	return total

func update_v77_content() -> void:
	# V7.8H owns focused tab text through v78h_focus_label.
	if v77_content_label != null:
		v77_content_label.visible = false
		v77_content_label.text = ""

func update_v78_paragon_board() -> void:
	super.update_v78_paragon_board()
	apply_v78h_paragon_layout()

func update_v78_focused_passives() -> void:
	super.update_v78_focused_passives()
	apply_v78h_passive_layout()
