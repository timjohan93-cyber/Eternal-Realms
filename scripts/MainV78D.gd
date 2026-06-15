extends "res://scripts/MainV78C.gd"

# Eternal Realms V7.8D
# Character Screen Text Fit Pass
# Clips/scrolls the right details panel and removes overlapping Equipment copy.

var v78d_right_scroll: ScrollContainer

func _ready() -> void:
	super._ready()
	create_v78d_right_scroll()
	apply_v78d_character_fit()
	update_character_ui()

func create_v78d_right_scroll() -> void:
	if v77a_right_panel == null or v77a_right_label == null:
		return
	if v78d_right_scroll != null and is_instance_valid(v78d_right_scroll):
		return

	v77a_right_panel.clip_contents = true

	v78d_right_scroll = ScrollContainer.new()
	v78d_right_scroll.name = "V78DRightDetailsScroll"
	v78d_right_scroll.position = Vector2(18, 20)
	v78d_right_scroll.size = Vector2(289, 810)
	v78d_right_scroll.clip_contents = true
	v78d_right_scroll.follow_focus = true
	v78d_right_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	v77a_right_panel.add_child(v78d_right_scroll)

	v77a_right_label.reparent(v78d_right_scroll)
	v77a_right_label.position = Vector2.ZERO
	v77a_right_label.size = Vector2(270, 1180)
	v77a_right_label.custom_minimum_size = Vector2(270, 1180)
	v77a_right_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_character_ui() -> void:
	super.update_character_ui()
	create_v78d_right_scroll()
	apply_v78d_character_fit()

func update_v77a_panels() -> void:
	super.update_v77a_panels()
	create_v78d_right_scroll()
	apply_v78d_character_fit()

func update_v77_content() -> void:
	super.update_v77_content()
	apply_v78d_content_visibility()

func apply_v78d_character_fit() -> void:
	if hud_label != null and is_instance_valid(hud_label):
		hud_label.visible = not character_open

	if character_preview_panel != null:
		character_preview_panel.clip_contents = true
		character_preview_panel.z_index = 220

	if v77a_left_panel != null:
		v77a_left_panel.clip_contents = true

	if v77a_right_panel != null:
		v77a_right_panel.clip_contents = true
		v77a_right_panel.size = Vector2(325, 850)

	if v78d_right_scroll != null and is_instance_valid(v78d_right_scroll):
		v78d_right_scroll.position = Vector2(18, 20)
		v78d_right_scroll.size = Vector2(289, 810)
		v78d_right_scroll.visible = character_open and character_tab == "Equipment"

	if v77a_right_label != null and is_instance_valid(v77a_right_label):
		v77a_right_label.position = Vector2.ZERO
		v77a_right_label.size = Vector2(270, 1180)
		v77a_right_label.custom_minimum_size = Vector2(270, 1180)
		v77a_right_label.add_theme_font_size_override("font_size", 15)

	if v77a_left_label != null and is_instance_valid(v77a_left_label):
		v77a_left_label.add_theme_font_size_override("font_size", 15)

	if v78_equipment_hint != null and is_instance_valid(v78_equipment_hint):
		v78_equipment_hint.position = Vector2(615, 900)
		v78_equipment_hint.size = Vector2(470, 52)
		v78_equipment_hint.add_theme_font_size_override("font_size", 12)

	apply_v78d_content_visibility()

func apply_v78d_content_visibility() -> void:
	if v77_content_label == null or not is_instance_valid(v77_content_label):
		return

	if character_tab == "Equipment":
		v77_content_label.visible = false
		v77_content_label.text = ""
	else:
		v77_content_label.visible = character_open
