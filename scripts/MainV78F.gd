extends "res://scripts/MainV78E.gd"

# Eternal Realms V7.8F
# Skill Icon Asset Pass
# Loads the generated PNG skill icons into action bar buttons when the files exist.

func _ready() -> void:
	super._ready()
	update_v73_action_bar()
	update_character_ui()

func format_v78b_action_slot_text(slot_name: String, skill_index: int, skill: Dictionary, rank: int) -> String:
	var skill_name: String = str(skill.get("name", "Skill"))
	var short_name: String = skill_name.substr(0, 9)
	var rank_text: String = "R" + str(rank)
	if rank <= 0:
		rank_text = "LOCK"
	return "\n" + short_name + "\n" + rank_text

func apply_v78b_action_slot_style(slot_name: String, skill_name: String, unlocked: bool) -> void:
	super.apply_v78b_action_slot_style(slot_name, skill_name, unlocked)
	if not action_bar_slots.has(slot_name):
		return

	var btn: Button = action_bar_slots[slot_name]
	if btn == null or not is_instance_valid(btn):
		return

	var icon_texture: Texture2D = get_v78f_skill_texture(skill_name)
	if icon_texture != null:
		btn.icon = icon_texture
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	else:
		btn.icon = null

	btn.add_theme_font_size_override("font_size", 12)
	btn.tooltip_text = get_v78f_action_slot_tooltip(slot_name, skill_name, icon_texture != null)

func get_v78f_skill_texture(skill_name: String) -> Texture2D:
	if skill_name == "Move":
		return null

	var path := get_v78b_skill_icon_path(skill_name)
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	if ResourceLoader.exists("res://assets/icons/skills/_placeholder.png"):
		return load("res://assets/icons/skills/_placeholder.png") as Texture2D
	return null

func get_v78f_action_slot_tooltip(slot_name: String, skill_name: String, has_icon: bool) -> String:
	if slot_name == "LMB":
		return "Left Mouse Button\nMove / Interact / Basic Attack"

	var status := "PNG loaded" if has_icon else "Text fallback"
	return slot_name + " - " + skill_name + "\n" + status + "\n" + get_v78b_skill_icon_path(skill_name)

func update_v77_content() -> void:
	if v77_content_label == null:
		return
	if character_tab != "Skills":
		super.update_v77_content()
		return

	var text := "SKILL ICON ASSETS\n\n"
	text += "Class: " + current_class + "\n"
	text += "Skill Points: " + str(skill_points) + "\n\n"
	text += "Action Bar Slots\n"
	for slot_name_value in v78b_skill_slots:
		var slot_name: String = str(slot_name_value)
		var skill_index: int = get_combat_slot_skill_index(slot_name)
		var skill: Dictionary = get_skill(skill_index)
		var skill_name: String = str(skill.get("name", "Skill"))
		var rank: int = get_skill_rank(skill_index)
		var icon_status := "PNG" if ResourceLoader.exists(get_v78b_skill_icon_path(skill_name)) else "Fallback"
		text += slot_name + "  " + skill_name + "  Rank " + str(rank) + "/20  [" + icon_status + "]\n"

	text += "\nGenerated PNG paths\n"
	var book = get_class_skill_book()
	for i in range(book.size()):
		var sk = book[i]
		var skill_name: String = str(sk.get("name", "Skill"))
		var status := "OK" if ResourceLoader.exists(get_v78b_skill_icon_path(skill_name)) else "Missing"
		text += status + "  " + skill_name + " -> " + get_v78b_skill_icon_path(skill_name) + "\n"
	v77_content_label.text = text
