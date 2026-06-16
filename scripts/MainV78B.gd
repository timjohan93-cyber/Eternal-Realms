extends "res://scripts/MainV78A.gd"

# Eternal Realms V7.8B
# Skill Icon Foundation
# Prepares PNG icon paths and upgrades action bar / Skills tab visuals while keeping text fallback icons.

var v78b_skill_icon_paths := {}
var v78b_skill_icon_tints := {}
var v78b_skill_slots := ["RMB", "Q", "W", "E", "R"]

func _ready() -> void:
	super._ready()
	setup_v78b_skill_icon_manifest()
	update_v73_action_bar()
	update_character_ui()

func setup_v78b_skill_icon_manifest() -> void:
	v78b_skill_icon_paths = {}
	v78b_skill_icon_tints = {}

	var warrior_skills := ["Cleave", "Charge", "Ground Slam", "Ragnarok", "Whirlwind", "Leap", "War Cry", "Execute"]
	var rogue_skills := ["Poison Arrow", "Dash", "Fan of Knives", "Endless Barrage", "Quick Shot", "Shadow Step", "Rain of Arrows", "Smoke Bomb"]
	var paladin_skills := ["Smite", "Heal", "Consecration", "Final Judgment", "Holy Shield", "Blessed Hammer", "Judgement", "Radiant Charge"]
	var mage_skills := ["Fireball", "Teleport", "Ice Nova", "Apocalypse", "Lightning Bolt", "Meteor", "Arcane Nova", "Mana Surge"]

	register_v78b_skill_icon_group("warrior", warrior_skills, Color(0.85, 0.22, 0.16, 1.0))
	register_v78b_skill_icon_group("rogue", rogue_skills, Color(0.18, 0.85, 0.36, 1.0))
	register_v78b_skill_icon_group("paladin", paladin_skills, Color(1.0, 0.82, 0.28, 1.0))
	register_v78b_skill_icon_group("mage", mage_skills, Color(0.42, 0.35, 1.0, 1.0))

func register_v78b_skill_icon_group(class_slug: String, skill_names: Array, tint: Color) -> void:
	for skill_name_value in skill_names:
		var skill_name: String = str(skill_name_value)
		var slug: String = make_v78b_skill_slug(skill_name)
		v78b_skill_icon_paths[skill_name] = "res://assets/icons/skills/" + class_slug + "/" + slug + ".png"
		v78b_skill_icon_tints[skill_name] = tint

func make_v78b_skill_slug(skill_name: String) -> String:
	var slug := skill_name.to_lower()
	slug = slug.replace(" ", "_")
	slug = slug.replace("'", "")
	slug = slug.replace("/", "_")
	return slug

func get_v78b_skill_icon_path(skill_name: String) -> String:
	return str(v78b_skill_icon_paths.get(skill_name, "res://assets/icons/skills/_placeholder.png"))

func get_v78b_skill_tint(skill_name: String) -> Color:
	if v78b_skill_icon_tints.has(skill_name):
		return v78b_skill_icon_tints[skill_name]
	return Color(0.55, 0.48, 0.36, 1.0)

func get_v78b_skill_icon_code(skill_name: String) -> String:
	return get_skill_icon(skill_name)

func format_v78b_action_slot_text(slot_name: String, skill_index: int, skill: Dictionary, rank: int) -> String:
	var skill_name: String = str(skill.get("name", "Skill"))
	var code: String = get_v78b_skill_icon_code(skill_name)
	var short_name: String = skill_name.substr(0, 9)
	var rank_text: String = "R" + str(rank)
	if rank <= 0:
		rank_text = "LOCK"
	return code + "\n" + short_name + "\n" + rank_text

func update_v73_action_bar() -> void:
	if action_bar_panel == null or not is_instance_valid(action_bar_panel):
		return

	apply_v78b_action_bar_panel_style()
	set_action_slot_text("LMB", "MOV\nMove\nBasic")
	apply_v78b_action_slot_style("LMB", "Move", true)

	for slot_name_value in v78b_skill_slots:
		var slot_name: String = str(slot_name_value)
		var skill_index: int = get_combat_slot_skill_index(slot_name)
		var skill: Dictionary = get_skill(skill_index)
		var rank: int = get_skill_rank(skill_index)
		var skill_name: String = str(skill.get("name", "Skill"))
		set_action_slot_text(slot_name, format_v78b_action_slot_text(slot_name, skill_index, skill, rank))
		apply_v78b_action_slot_style(slot_name, skill_name, rank > 0)
		if action_bar_labels.has(slot_name):
			var label: Label = action_bar_labels[slot_name]
			if label != null and is_instance_valid(label):
				label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.52, 1.0))

func apply_v78b_action_bar_panel_style() -> void:
	if action_bar_panel == null:
		return
	action_bar_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.028, 0.026, 0.028, 0.96), Color(0.56, 0.40, 0.18, 0.95), 2))

func apply_v78b_action_slot_style(slot_name: String, skill_name: String, unlocked: bool) -> void:
	if not action_bar_slots.has(slot_name):
		return
	var btn: Button = action_bar_slots[slot_name]
	if btn == null or not is_instance_valid(btn):
		return

	var tint: Color = get_v78b_skill_tint(skill_name)
	var border: Color = tint if unlocked else Color(0.30, 0.30, 0.32, 0.95)
	var bg: Color = Color(tint.r * 0.16, tint.g * 0.16, tint.b * 0.16, 0.98) if unlocked else Color(0.035, 0.035, 0.04, 0.96)
	btn.add_theme_stylebox_override("normal", make_v78a_button_style(bg, border, 2))
	btn.add_theme_stylebox_override("disabled", make_v78a_button_style(bg, border, 2))
	btn.add_theme_stylebox_override("hover", make_v78a_button_style(bg.lightened(0.12), border.lightened(0.18), 2))
	btn.add_theme_color_override("font_color", Color(0.96, 0.88, 0.70, 1.0) if unlocked else Color(0.48, 0.48, 0.50, 1.0))
	btn.add_theme_color_override("font_disabled_color", Color(0.96, 0.88, 0.70, 1.0) if unlocked else Color(0.48, 0.48, 0.50, 1.0))
	btn.add_theme_font_size_override("font_size", 14)
	btn.tooltip_text = get_v78b_action_slot_tooltip(slot_name, skill_name)

func get_v78b_action_slot_tooltip(slot_name: String, skill_name: String) -> String:
	if slot_name == "LMB":
		return "Left Mouse Button\nMove / Interact / Basic Attack"
	return slot_name + " - " + skill_name + "\nIcon path: " + get_v78b_skill_icon_path(skill_name)

func update_v77_content() -> void:
	if v77_content_label == null:
		return
	if character_tab != "Skills":
		super.update_v77_content()
		return

	var text := "SKILL ICON FOUNDATION\n\n"
	text += "Class: " + current_class + "\n"
	text += "Skill Points: " + str(skill_points) + "\n\n"
	text += "Action Bar Slots\n"
	for slot_name_value in v78b_skill_slots:
		var slot_name: String = str(slot_name_value)
		var skill_index: int = get_combat_slot_skill_index(slot_name)
		var skill: Dictionary = get_skill(skill_index)
		var skill_name: String = str(skill.get("name", "Skill"))
		var rank: int = get_skill_rank(skill_index)
		text += slot_name + "  " + get_v78b_skill_icon_code(skill_name) + "  " + skill_name + "  Rank " + str(rank) + "/20\n"
	text += "\nPNG paths prepared\n"
	var book = get_class_skill_book()
	for i in range(book.size()):
		var sk = book[i]
		var skill_name: String = str(sk.get("name", "Skill"))
		text += get_v78b_skill_icon_code(skill_name) + "  " + skill_name + " -> " + get_v78b_skill_icon_path(skill_name) + "\n"
	text += "\nNext: add real PNG files to assets/icons/skills/<class>/ and the UI can start loading them."
	v77_content_label.text = text

func update_character_ui() -> void:
	super.update_character_ui()
	if character_tab == "Skills":
		update_v77_content()
	update_v73_action_bar()
