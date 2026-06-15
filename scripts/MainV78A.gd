extends "res://scripts/MainV78.gd"

# Eternal Realms V7.8A
# Character Screen Polish Pass
# Adds ARPG-style panel framing, active tab styling, rarity slot frames, and a subtle animated edge.

var v78a_frame_strips: Array = []
var v78a_corner_marks: Array = []
var v78a_pulse_time := 0.0

func _ready() -> void:
	super._ready()
	create_v78a_polish_frame()
	apply_v78a_polish()
	update_character_ui()
	update_inventory_ui()

func _process(delta: float) -> void:
	super._process(delta)
	v78a_pulse_time += delta
	update_v78a_frame_animation()

func create_v78a_polish_frame() -> void:
	if character_preview_panel == null:
		return
	if v78a_frame_strips.size() > 0:
		return

	var frame_data := [
		{"name": "Top", "pos": Vector2(10, 8), "size": Vector2(1690, 4)},
		{"name": "Bottom", "pos": Vector2(10, 1028), "size": Vector2(1690, 4)},
		{"name": "Left", "pos": Vector2(8, 10), "size": Vector2(4, 1020)},
		{"name": "Right", "pos": Vector2(1698, 10), "size": Vector2(4, 1020)}
	]

	for data in frame_data:
		var strip := ColorRect.new()
		strip.name = "V78AFrame" + str(data["name"])
		strip.position = data["pos"]
		strip.size = data["size"]
		strip.color = Color(0.95, 0.62, 0.18, 0.72)
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.z_index = 400
		character_preview_panel.add_child(strip)
		v78a_frame_strips.append(strip)

	var corner_data := [Vector2(20, 20), Vector2(1644, 20), Vector2(20, 970), Vector2(1644, 970)]
	for i in range(corner_data.size()):
		var mark := ColorRect.new()
		mark.name = "V78ACorner" + str(i)
		mark.position = corner_data[i]
		mark.size = Vector2(46, 46)
		mark.color = Color(1.0, 0.72, 0.22, 0.68)
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mark.z_index = 401
		character_preview_panel.add_child(mark)
		v78a_corner_marks.append(mark)

func apply_v78a_polish() -> void:
	apply_v78a_panel_styles()
	apply_v78a_tab_styles()
	apply_v78a_slot_styles()
	apply_v78a_text_styles()
	apply_v78a_paragon_styles()

func apply_v78a_panel_styles() -> void:
	if character_preview_panel != null:
		character_preview_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.045, 0.038, 0.032, 0.96), Color(0.78, 0.50, 0.18, 0.95), 3))
	if inventory_panel != null:
		inventory_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.035, 0.034, 0.038, 0.96), Color(0.42, 0.36, 0.27, 0.95), 2))
	if v77a_left_panel != null:
		v77a_left_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.025, 0.028, 0.032, 0.92), Color(0.46, 0.34, 0.16, 0.9), 2))
	if v77a_right_panel != null:
		v77a_right_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.025, 0.028, 0.032, 0.92), Color(0.46, 0.34, 0.16, 0.9), 2))

func apply_v78a_tab_styles() -> void:
	for tab in v77_tab_buttons.keys():
		var btn: Button = v77_tab_buttons[tab]
		if btn == null or not is_instance_valid(btn):
			continue
		var active := tab == character_tab
		var normal_bg := Color(0.17, 0.13, 0.085, 0.96) if active else Color(0.07, 0.065, 0.06, 0.94)
		var normal_border := Color(1.0, 0.70, 0.25, 1.0) if active else Color(0.45, 0.34, 0.18, 0.88)
		btn.add_theme_stylebox_override("normal", make_v78a_button_style(normal_bg, normal_border, 2))
		btn.add_theme_stylebox_override("hover", make_v78a_button_style(Color(0.20, 0.15, 0.09, 0.98), Color(1.0, 0.78, 0.32, 1.0), 2))
		btn.add_theme_stylebox_override("pressed", make_v78a_button_style(Color(0.30, 0.19, 0.08, 1.0), Color(1.0, 0.86, 0.38, 1.0), 2))
		btn.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48, 1.0) if active else Color(0.78, 0.70, 0.58, 1.0))
		btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.62, 1.0))

func apply_v78a_slot_styles() -> void:
	for slot_name in character_preview_slots.keys():
		var btn: Button = character_preview_slots[slot_name]
		if btn == null or not is_instance_valid(btn):
			continue
		var item = equipment.get(slot_name, null)
		var rarity := "Empty"
		if item != null:
			rarity = str(item.get("rarity", "Common"))
		var border := get_v78a_rarity_frame_color(rarity)
		var bg := Color(0.045, 0.045, 0.052, 0.96) if item == null else Color(0.075, 0.06, 0.055, 0.96)
		btn.add_theme_stylebox_override("normal", make_v78a_button_style(bg, border, 2))
		btn.add_theme_stylebox_override("hover", make_v78a_button_style(Color(0.10, 0.082, 0.065, 0.98), border.lightened(0.18), 2))
		btn.add_theme_stylebox_override("pressed", make_v78a_button_style(Color(0.14, 0.095, 0.06, 1.0), border.lightened(0.28), 2))
		btn.add_theme_color_override("font_color", Color(0.92, 0.86, 0.74, 1.0))
		btn.add_theme_font_size_override("font_size", 13)

func apply_v78a_text_styles() -> void:
	var labels := [character_preview_label, v77_content_label, v77a_left_label, v77a_right_label, v78_equipment_hint, v78_paragon_header]
	for label in labels:
		if label != null and is_instance_valid(label):
			label.add_theme_color_override("font_color", Color(0.90, 0.82, 0.68, 1.0))
	if character_preview_label != null:
		character_preview_label.add_theme_font_size_override("font_size", 24)
		character_preview_label.add_theme_color_override("font_color", Color(1.0, 0.75, 0.28, 1.0))
	if v78_equipment_hint != null:
		v78_equipment_hint.add_theme_font_size_override("font_size", 13)
		v78_equipment_hint.add_theme_color_override("font_color", Color(0.70, 0.64, 0.52, 1.0))

func apply_v78a_paragon_styles() -> void:
	for key in v78_paragon_nodes.keys():
		var btn: Button = v78_paragon_nodes[key]
		if btn == null or not is_instance_valid(btn):
			continue
		var unlocked := not btn.disabled
		var border := Color(0.95, 0.68, 0.22, 1.0) if unlocked else Color(0.36, 0.34, 0.32, 0.9)
		var bg := Color(0.11, 0.075, 0.04, 0.98) if unlocked else Color(0.045, 0.045, 0.05, 0.92)
		btn.add_theme_stylebox_override("normal", make_v78a_button_style(bg, border, 2))
		btn.add_theme_stylebox_override("hover", make_v78a_button_style(Color(0.16, 0.10, 0.04, 0.98), border.lightened(0.18), 2))
		btn.add_theme_color_override("font_color", Color(0.95, 0.82, 0.52, 1.0) if unlocked else Color(0.52, 0.50, 0.48, 1.0))

func make_v78a_panel_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func make_v78a_button_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func get_v78a_rarity_frame_color(rarity: String) -> Color:
	if rarity == "Godlike":
		return Color(1.0, 0.18, 0.92, 1.0)
	if rarity == "Legendary":
		return Color(1.0, 0.48, 0.08, 1.0)
	if rarity == "Unique":
		return Color(0.70, 0.38, 1.0, 1.0)
	if rarity == "Rare":
		return Color(1.0, 0.86, 0.22, 1.0)
	if rarity == "Magic":
		return Color(0.28, 0.48, 1.0, 1.0)
	if rarity == "Common":
		return Color(0.58, 0.58, 0.58, 1.0)
	return Color(0.34, 0.31, 0.27, 0.92)

func update_character_ui() -> void:
	super.update_character_ui()
	apply_v78a_polish()
	set_v78a_polish_visible(character_open)

func update_inventory_ui() -> void:
	super.update_inventory_ui()
	apply_v78a_panel_styles()
	apply_v78a_slot_styles()

func update_v78_paragon_board() -> void:
	super.update_v78_paragon_board()
	apply_v78a_paragon_styles()

func equip_selected_to_slot(slot_name: String) -> void:
	super.equip_selected_to_slot(slot_name)
	apply_v78a_slot_styles()

func unequip_slot(slot_name: String) -> void:
	super.unequip_slot(slot_name)
	apply_v78a_slot_styles()

func set_v78a_polish_visible(show: bool) -> void:
	for strip in v78a_frame_strips:
		if is_instance_valid(strip):
			strip.visible = show
	for mark in v78a_corner_marks:
		if is_instance_valid(mark):
			mark.visible = show

func update_v78a_frame_animation() -> void:
	if not character_open:
		return
	var pulse := 0.55 + sin(v78a_pulse_time * 2.2) * 0.18
	var edge_color := Color(1.0, 0.62, 0.18, pulse)
	var corner_color := Color(1.0, 0.78, 0.28, pulse + 0.08)
	for strip in v78a_frame_strips:
		if is_instance_valid(strip):
			strip.color = edge_color
	for mark in v78a_corner_marks:
		if is_instance_valid(mark):
			mark.color = corner_color
