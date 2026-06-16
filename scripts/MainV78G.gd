extends "res://scripts/MainV78F.gd"

# Eternal Realms V7.8G
# Compact Action Bar Feedback Pass
# Shrinks the action bar and adds pressed/cooldown visual feedback for abilities.

var v78g_action_flash_until := {}

func _ready() -> void:
	super._ready()
	apply_v78g_action_bar_layout()
	update_v73_action_bar()

func _process(delta: float) -> void:
	super._process(delta)
	update_v78g_action_bar_feedback()

func use_combat_slot(slot_name: String) -> void:
	var before: float = float(combat_slot_last_used.get(slot_name, -999.0))
	super.use_combat_slot(slot_name)
	var after: float = float(combat_slot_last_used.get(slot_name, -999.0))
	if after > before:
		v78g_action_flash_until[slot_name] = Time.get_ticks_msec() / 1000.0 + 0.18
	update_v73_action_bar()

func update_v73_action_bar() -> void:
	super.update_v73_action_bar()
	apply_v78g_action_bar_layout()
	update_v78g_action_bar_feedback()

func apply_v78g_action_bar_layout() -> void:
	if action_bar_panel == null or not is_instance_valid(action_bar_panel):
		return

	action_bar_panel.position = Vector2(845, 1304)
	action_bar_panel.size = Vector2(870, 82)
	action_bar_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.018, 0.017, 0.020, 0.94), Color(0.48, 0.34, 0.15, 0.88), 2))

	var slots := ["LMB", "RMB", "Q", "W", "E", "R"]
	for i in range(slots.size()):
		var slot_name: String = slots[i]
		if action_bar_slots.has(slot_name):
			var btn: Button = action_bar_slots[slot_name]
			if btn != null and is_instance_valid(btn):
				btn.position = Vector2(16 + i * 140, 10)
				btn.size = Vector2(106, 54)
				btn.custom_minimum_size = Vector2(106, 54)
				btn.expand_icon = false
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
				btn.add_theme_font_size_override("font_size", 10)
				btn.add_theme_constant_override("icon_spacing", 1)
		if action_bar_labels.has(slot_name):
			var label: Label = action_bar_labels[slot_name]
			if label != null and is_instance_valid(label):
				label.position = Vector2(16 + i * 140, 61)
				label.size = Vector2(106, 18)
				label.add_theme_font_size_override("font_size", 11)
				label.add_theme_color_override("font_color", Color(0.72, 0.62, 0.42, 1.0))

func format_v78b_action_slot_text(slot_name: String, skill_index: int, skill: Dictionary, rank: int) -> String:
	var skill_name: String = str(skill.get("name", "Skill"))
	var short_name: String = skill_name.substr(0, 8)
	var rank_text: String = "R" + str(rank)
	if rank <= 0:
		rank_text = "LOCK"
	return short_name + "\n" + rank_text

func update_v78g_action_bar_feedback() -> void:
	if action_bar_panel == null or not is_instance_valid(action_bar_panel):
		return

	apply_v78g_lmb_style()
	for slot_name_value in v78b_skill_slots:
		var slot_name: String = str(slot_name_value)
		apply_v78g_skill_slot_feedback(slot_name)

func apply_v78g_lmb_style() -> void:
	if not action_bar_slots.has("LMB"):
		return
	var btn: Button = action_bar_slots["LMB"]
	if btn == null or not is_instance_valid(btn):
		return
	btn.text = "Move\nBasic"
	btn.icon = null
	btn.add_theme_stylebox_override("normal", make_v78a_button_style(Color(0.045, 0.038, 0.026, 0.96), Color(0.66, 0.52, 0.30, 0.95), 1))
	btn.add_theme_stylebox_override("disabled", make_v78a_button_style(Color(0.045, 0.038, 0.026, 0.96), Color(0.66, 0.52, 0.30, 0.95), 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.92, 0.82, 0.56, 1.0))
	btn.add_theme_font_size_override("font_size", 10)

func apply_v78g_skill_slot_feedback(slot_name: String) -> void:
	if not action_bar_slots.has(slot_name):
		return

	var btn: Button = action_bar_slots[slot_name]
	if btn == null or not is_instance_valid(btn):
		return

	var skill_index: int = get_combat_slot_skill_index(slot_name)
	var skill: Dictionary = get_skill(skill_index)
	var skill_name: String = str(skill.get("name", "Skill"))
	var rank: int = get_skill_rank(skill_index)
	var now := Time.get_ticks_msec() / 1000.0
	var cd: float = get_skill_cooldown(skill_index)
	var last: float = float(combat_slot_last_used.get(slot_name, -999.0))
	var remaining: float = max(0.0, cd - (now - last))
	var unlocked := rank > 0
	var flashing := float(v78g_action_flash_until.get(slot_name, -999.0)) > now
	var tint: Color = get_v78b_skill_tint(skill_name)
	var icon_texture: Texture2D = get_v78f_skill_texture(skill_name)

	if icon_texture != null:
		btn.icon = icon_texture
		btn.expand_icon = false

	if not unlocked:
		btn.text = skill_name.substr(0, 8) + "\nLOCK"
		apply_v78g_slot_style(btn, Color(0.028, 0.028, 0.032, 0.96), Color(0.22, 0.22, 0.25, 0.95), Color(0.42, 0.42, 0.46, 1.0), 1)
	elif remaining > 0.05:
		btn.text = skill_name.substr(0, 8) + "\n" + str(snapped(remaining, 0.1)) + "s"
		apply_v78g_slot_style(btn, Color(0.018, 0.018, 0.022, 0.98), tint.darkened(0.35), Color(0.58, 0.58, 0.62, 1.0), 1)
	elif flashing:
		btn.text = skill_name.substr(0, 8) + "\nCAST"
		apply_v78g_slot_style(btn, Color(tint.r * 0.36, tint.g * 0.36, tint.b * 0.36, 1.0), tint.lightened(0.38), Color(1.0, 0.94, 0.68, 1.0), 3)
	else:
		btn.text = skill_name.substr(0, 8) + "\nR" + str(rank)
		apply_v78g_slot_style(btn, Color(tint.r * 0.12, tint.g * 0.12, tint.b * 0.12, 0.98), tint, Color(0.95, 0.84, 0.60, 1.0), 2)

	btn.tooltip_text = get_v78f_action_slot_tooltip(slot_name, skill_name, icon_texture != null) + "\nCooldown: " + str(cd) + "s"

func apply_v78g_slot_style(btn: Button, bg: Color, border: Color, font: Color, border_width: int) -> void:
	btn.add_theme_stylebox_override("normal", make_v78a_button_style(bg, border, border_width))
	btn.add_theme_stylebox_override("disabled", make_v78a_button_style(bg, border, border_width))
	btn.add_theme_stylebox_override("hover", make_v78a_button_style(bg.lightened(0.10), border.lightened(0.18), max(2, border_width)))
	btn.add_theme_color_override("font_color", font)
	btn.add_theme_color_override("font_disabled_color", font)
	btn.add_theme_font_size_override("font_size", 10)
