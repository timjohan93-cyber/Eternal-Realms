extends "res://scripts/MainV73.gd"

# Eternal Realms V7.4.0
# Passive Tree Visual Foundation + safer UI cleanup.
# Stable UI-only step on top of V7.3.

var passive_tree_panel: Panel
var passive_buttons := {}
var passive_button_order := []

func _ready() -> void:
	super._ready()
	create_v74_passive_tree_ui()
	update_v74_passive_tree_ui()

func update_character_ui() -> void:
	super.update_character_ui()
	update_v74_passive_tree_ui()
	if character_tab == "Passives" and character_label != null:
		character_label.text = "PASSIVE TREE\nPassive Points: " + str(passive_points) + "\n\nClick a node to upgrade it.\nHold SHIFT and click to refund later.\n\nV7.4 starts moving passives away from hotkeys so Q/W/E/R can become skill keys."

func create_v74_passive_tree_ui() -> void:
	if hud == null:
		return
	if passive_tree_panel != null and is_instance_valid(passive_tree_panel):
		return

	passive_tree_panel = Panel.new()
	passive_tree_panel.name = "V74PassiveTree"
	passive_tree_panel.position = Vector2(620, 210)
	passive_tree_panel.size = Vector2(900, 620)
	passive_tree_panel.visible = false
	hud.add_child(passive_tree_panel)

	var title := Label.new()
	title.position = Vector2(30, 18)
	title.size = Vector2(840, 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "PASSIVE TREE"
	title.add_theme_font_size_override("font_size", 22)
	passive_tree_panel.add_child(title)

	add_passive_column("OFFENSE", Vector2(95, 80), ["Damage", "Crit Chance", "Crit Damage"])
	add_passive_column("DEFENSE", Vector2(365, 80), ["Health", "Armor", "Regen"])
	add_passive_column("UTILITY", Vector2(635, 80), ["Move Speed", "Gold Find", "Magic Find"])

func add_passive_column(title_text: String, origin: Vector2, names: Array) -> void:
	var header := Label.new()
	header.position = origin
	header.size = Vector2(180, 30)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.text = title_text
	header.add_theme_font_size_override("font_size", 18)
	passive_tree_panel.add_child(header)

	for i in range(names.size()):
		var node_name: String = names[i]
		var btn := Button.new()
		btn.position = origin + Vector2(0, 60 + i * 145)
		btn.size = Vector2(180, 82)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(func(): on_passive_node_clicked(node_name))
		passive_tree_panel.add_child(btn)
		passive_buttons[node_name] = btn
		passive_button_order.append(node_name)

		if i < names.size() - 1:
			var connector := ColorRect.new()
			connector.position = origin + Vector2(86, 142 + i * 145)
			connector.size = Vector2(8, 58)
			connector.color = Color(0.45, 0.38, 0.22, 0.85)
			passive_tree_panel.add_child(connector)

func on_passive_node_clicked(node_name: String) -> void:
	if not passive_ranks.has(node_name):
		loot_label.text = "Passive not found yet: " + node_name
		return

	if Input.is_key_pressed(KEY_SHIFT):
		refund_passive_node(node_name)
	else:
		upgrade_passive_node(node_name)

	update_hud()
	update_character_ui()
	save_game()

func upgrade_passive_node(node_name: String) -> void:
	var current_rank: int = int(passive_ranks.get(node_name, 0))
	if current_rank >= 10:
		loot_label.text = node_name + " is already max rank."
		return
	if passive_points <= 0:
		loot_label.text = "No passive points available."
		return
	passive_points -= 1
	passive_ranks[node_name] = current_rank + 1
	recalculate_stats()
	loot_label.text = "Upgraded passive: " + node_name + " " + str(passive_ranks[node_name]) + "/10"

func refund_passive_node(node_name: String) -> void:
	var current_rank: int = int(passive_ranks.get(node_name, 0))
	if current_rank <= 0:
		loot_label.text = node_name + " has no points to refund."
		return
	passive_ranks[node_name] = current_rank - 1
	passive_points += 1
	recalculate_stats()
	loot_label.text = "Refunded passive: " + node_name + " " + str(passive_ranks[node_name]) + "/10"

func update_v74_passive_tree_ui() -> void:
	if passive_tree_panel == null or not is_instance_valid(passive_tree_panel):
		return
	passive_tree_panel.visible = character_open and character_tab == "Passives"

	for node_name in passive_button_order:
		if not passive_buttons.has(node_name):
			continue
		var btn: Button = passive_buttons[node_name]
		var rank: int = int(passive_ranks.get(node_name, 0))
		var icon: String = get_passive_icon(node_name)
		btn.text = icon + "\n" + node_name + "\n" + str(rank) + "/10"
		btn.tooltip_text = get_passive_tooltip(node_name)
		if rank > 0:
			btn.modulate = Color(1.0, 0.95, 0.75, 1.0)
		else:
			btn.modulate = Color(0.75, 0.75, 0.75, 1.0)

func get_passive_icon(node_name: String) -> String:
	match node_name:
		"Damage":
			return "DMG"
		"Crit Chance":
			return "CRT"
		"Crit Damage":
			return "CDM"
		"Health":
			return "HP"
		"Armor":
			return "ARM"
		"Regen":
			return "REG"
		"Move Speed":
			return "SPD"
		"Gold Find":
			return "GLD"
		"Magic Find":
			return "MAG"
	return "PAS"

func get_passive_tooltip(node_name: String) -> String:
	var rank: int = int(passive_ranks.get(node_name, 0))
	var text := node_name + "\nRank: " + str(rank) + "/10\n"
	match node_name:
		"Damage":
			text += "Increases damage."
		"Crit Chance":
			text += "Increases critical strike chance."
		"Crit Damage":
			text += "Increases critical strike damage."
		"Health":
			text += "Increases maximum health."
		"Armor":
			text += "Increases armor."
		"Regen":
			text += "Increases health and mana regeneration."
		"Move Speed":
			text += "Increases movement speed. Good for speed builds."
		"Gold Find":
			text += "Increases gold drops."
		"Magic Find":
			text += "Improves loot quality."
	text += "\n\nLeft click: upgrade\nShift + click: refund"
	return text

func close_town_windows_except(which: String) -> void:
	super.close_town_windows_except(which)
	update_v74_passive_tree_ui()

func toggle_character_screen() -> void:
	super.toggle_character_screen()
	update_v74_passive_tree_ui()
