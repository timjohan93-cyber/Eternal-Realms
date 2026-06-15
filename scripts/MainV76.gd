extends "res://scripts/MainV75.gd"

# Eternal Realms V7.6.0
# Visual Foundation: icon framework + Character Screen 2.0 preview.
# This version does not require external PNG files yet. It creates a clean placeholder system first.

var icon_registry := {}
var character_preview_panel: Panel
var character_preview_label: Label
var character_preview_slots := {}
var character_preview_body: Polygon2D
var character_preview_aura: Polygon2D
var character_preview_time: float = 0.0

func _ready() -> void:
	super._ready()
	setup_v76_icon_registry()
	create_v76_character_preview()
	update_v76_character_preview()
	update_hud()
	update_character_ui()

func _process(delta: float) -> void:
	super._process(delta)
	update_v76_character_animation(delta)

func setup_v76_icon_registry() -> void:
	icon_registry = {
		"skill": {
			"Fireball": "FB", "Ice Nova": "IN", "Lightning Bolt": "LB", "Heal": "HL",
			"Shadow Step": "SS", "Whirlwind": "WW", "Cleave": "CL", "Charge": "CH",
			"Ground Slam": "GS", "Ragnarok": "RG", "Poison Arrow": "PA", "Dash": "DS",
			"Smite": "SM", "Teleport": "TP", "Meteor": "MT", "Arcane Nova": "AN"
		},
		"passive": {
			"Damage": "DMG", "Crit Chance": "CRT", "Crit Damage": "CDM",
			"Health": "HP", "Armor": "ARM", "Regen": "REG",
			"Move Speed": "SPD", "Gold Find": "GLD", "Magic Find": "MAG"
		},
		"item_slot": {
			"Weapon": "WPN", "Offhand": "OFF", "Helmet": "HLM", "Chest": "CHS",
			"Gloves": "GLV", "Boots": "BTS", "Ring1": "R1", "Ring2": "R2",
			"Amulet": "AMU", "Belt": "BLT"
		}
	}

func get_icon(category: String, key: String, fallback: String = "ICN") -> String:
	if icon_registry.has(category):
		var group = icon_registry[category]
		if group.has(key):
			return str(group[key])
	return fallback

func get_skill_icon(skill_name: String) -> String:
	return get_icon("skill", skill_name, "SK")

func get_passive_icon(node_name: String) -> String:
	return get_icon("passive", node_name, "PAS")

func create_v76_character_preview() -> void:
	if hud == null:
		return
	if character_preview_panel != null and is_instance_valid(character_preview_panel):
		return

	character_preview_panel = Panel.new()
	character_preview_panel.name = "V76CharacterPreview"
	character_preview_panel.position = Vector2(1040, 180)
	character_preview_panel.size = Vector2(480, 640)
	character_preview_panel.visible = false
	character_preview_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	character_preview_panel.z_index = 90
	hud.add_child(character_preview_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.size = Vector2(440, 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "CHARACTER PREVIEW"
	title.add_theme_font_size_override("font_size", 20)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(title)

	character_preview_label = Label.new()
	character_preview_label.position = Vector2(20, 52)
	character_preview_label.size = Vector2(440, 40)
	character_preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_preview_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_preview_panel.add_child(character_preview_label)

	character_preview_aura = Polygon2D.new()
	character_preview_aura.position = Vector2(240, 315)
	character_preview_aura.polygon = make_circle_polygon(78.0, 40)
	character_preview_aura.color = Color(0.75, 0.2, 1.0, 0.18)
	character_preview_panel.add_child(character_preview_aura)

	character_preview_body = Polygon2D.new()
	character_preview_body.position = Vector2(240, 315)
	character_preview_body.polygon = PackedVector2Array([Vector2(0, -68), Vector2(44, 58), Vector2(0, 86), Vector2(-44, 58)])
	character_preview_body.color = Color(0.2, 0.7, 1.0, 1.0)
	character_preview_panel.add_child(character_preview_body)

	create_preview_slot("Helmet", Vector2(165, 105), Vector2(150, 54))
	create_preview_slot("Weapon", Vector2(35, 270), Vector2(145, 58))
	create_preview_slot("Offhand", Vector2(300, 270), Vector2(145, 58))
	create_preview_slot("Chest", Vector2(165, 405), Vector2(150, 58))
	create_preview_slot("Gloves", Vector2(35, 385), Vector2(145, 58))
	create_preview_slot("Boots", Vector2(165, 505), Vector2(150, 58))
	create_preview_slot("Ring1", Vector2(35, 485), Vector2(145, 58))
	create_preview_slot("Ring2", Vector2(300, 485), Vector2(145, 58))
	create_preview_slot("Amulet", Vector2(300, 125), Vector2(145, 58))
	create_preview_slot("Belt", Vector2(165, 470), Vector2(150, 42))

func create_preview_slot(slot_name: String, pos: Vector2, size: Vector2) -> void:
	var btn := Button.new()
	btn.position = pos
	btn.size = size
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.disabled = true
	character_preview_panel.add_child(btn)
	character_preview_slots[slot_name] = btn

func update_character_ui() -> void:
	super.update_character_ui()
	update_v76_character_preview()

func update_v76_character_preview() -> void:
	if character_preview_panel == null or not is_instance_valid(character_preview_panel):
		return
	character_preview_panel.visible = character_open and character_tab == "Equipment"
	if character_preview_panel.visible:
		character_preview_panel.move_to_front()

	if character_preview_label != null:
		character_preview_label.text = current_class + " | Godlike " + str(get_equipped_godlike_count()) + "/2"

	if character_preview_body != null:
		match current_class:
			"Warrior":
				character_preview_body.color = Color(0.2, 0.7, 1.0, 1.0)
			"Rogue":
				character_preview_body.color = Color(0.1, 0.9, 0.35, 1.0)
			"Paladin":
				character_preview_body.color = Color(1.0, 0.85, 0.25, 1.0)
			"Mage":
				character_preview_body.color = Color(0.65, 0.25, 1.0, 1.0)

	if character_preview_aura != null:
		character_preview_aura.visible = get_equipped_godlike_count() > 0

	for slot_name in character_preview_slots.keys():
		var btn: Button = character_preview_slots[slot_name]
		var item = equipment.get(slot_name, null)
		var icon: String = get_icon("item_slot", slot_name, "ITM")
		if item == null:
			btn.text = icon + "\nEmpty"
			btn.tooltip_text = display_slot_name(slot_name) + " empty"
		else:
			btn.text = icon + "\n" + str(item.get("name", "Item")).substr(0, 12)
			btn.tooltip_text = item_to_text(item)

func update_v76_character_animation(delta: float) -> void:
	if character_preview_panel == null or not character_preview_panel.visible:
		return
	character_preview_time += delta
	if character_preview_body != null:
		var pulse: float = 1.0 + sin(character_preview_time * 2.5) * 0.025
		character_preview_body.scale = Vector2(pulse, pulse)
	if character_preview_aura != null and character_preview_aura.visible:
		var aura_scale: float = 1.0 + abs(sin(character_preview_time * 2.0)) * 0.12
		character_preview_aura.scale = Vector2(aura_scale, aura_scale)
		character_preview_aura.color.a = 0.12 + abs(sin(character_preview_time * 3.0)) * 0.12

func is_mouse_over_open_ui(mouse_pos: Vector2) -> bool:
	if character_preview_panel != null and character_preview_panel.visible and get_panel_rect_global(character_preview_panel).has_point(mouse_pos):
		return true
	return super.is_mouse_over_open_ui(mouse_pos)

func update_v73_action_bar() -> void:
	if action_bar_panel == null or not is_instance_valid(action_bar_panel):
		return

	set_action_slot_text("LMB", "MOV\nMove")
	var slots = ["RMB", "Q", "W", "E", "R"]
	for slot_name in slots:
		var skill_index: int = get_combat_slot_skill_index(slot_name)
		var skill = get_skill(skill_index)
		var rank: int = get_skill_rank(skill_index)
		var icon: String = get_skill_icon(str(skill["name"]))
		var short_name: String = str(skill["name"]).substr(0, 8)
		var rank_text: String = "R" + str(rank)
		if rank <= 0:
			rank_text = "LOCK"
		set_action_slot_text(slot_name, icon + "\n" + short_name + "\n" + rank_text)
