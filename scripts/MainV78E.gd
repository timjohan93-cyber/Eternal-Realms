extends "res://scripts/MainV78D.gd"

# Eternal Realms V7.8E
# Compact Scroll Panels Pass
# Makes growing stat/details panels intentionally scrollable instead of oversized.

var v78e_left_scroll: ScrollContainer

func _ready() -> void:
	super._ready()
	create_v78e_left_scroll()
	apply_v78e_compact_scroll_panels()
	update_character_ui()

func create_v78e_left_scroll() -> void:
	if v77a_left_panel == null or v77a_left_label == null:
		return
	if v78e_left_scroll != null and is_instance_valid(v78e_left_scroll):
		return

	v77a_left_panel.clip_contents = true

	v78e_left_scroll = ScrollContainer.new()
	v78e_left_scroll.name = "V78ELeftStatsScroll"
	v78e_left_scroll.position = Vector2(18, 20)
	v78e_left_scroll.size = Vector2(274, 680)
	v78e_left_scroll.clip_contents = true
	v78e_left_scroll.follow_focus = true
	v78e_left_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	v77a_left_panel.add_child(v78e_left_scroll)

	v77a_left_label.reparent(v78e_left_scroll)
	v77a_left_label.position = Vector2.ZERO
	v77a_left_label.size = Vector2(252, 1040)
	v77a_left_label.custom_minimum_size = Vector2(252, 1040)
	v77a_left_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_character_ui() -> void:
	super.update_character_ui()
	create_v78e_left_scroll()
	apply_v78e_compact_scroll_panels()

func update_v77a_panels() -> void:
	super.update_v77a_panels()
	create_v78e_left_scroll()
	apply_v78e_compact_scroll_panels()

func apply_v78e_compact_scroll_panels() -> void:
	var show_equipment := character_open and character_tab == "Equipment"

	if v77a_left_panel != null and is_instance_valid(v77a_left_panel):
		v77a_left_panel.position = Vector2(25, 135)
		v77a_left_panel.size = Vector2(310, 720)
		v77a_left_panel.clip_contents = true

	if v78e_left_scroll != null and is_instance_valid(v78e_left_scroll):
		v78e_left_scroll.position = Vector2(18, 20)
		v78e_left_scroll.size = Vector2(274, 680)
		v78e_left_scroll.visible = show_equipment

	if v77a_left_label != null and is_instance_valid(v77a_left_label):
		v77a_left_label.position = Vector2.ZERO
		v77a_left_label.size = Vector2(252, 1040)
		v77a_left_label.custom_minimum_size = Vector2(252, 1040)
		v77a_left_label.add_theme_font_size_override("font_size", 14)

	if v77a_right_panel != null and is_instance_valid(v77a_right_panel):
		v77a_right_panel.position = Vector2(1360, 135)
		v77a_right_panel.size = Vector2(325, 720)
		v77a_right_panel.clip_contents = true

	if v78d_right_scroll != null and is_instance_valid(v78d_right_scroll):
		v78d_right_scroll.position = Vector2(18, 20)
		v78d_right_scroll.size = Vector2(289, 680)
		v78d_right_scroll.visible = show_equipment

	if v77a_right_label != null and is_instance_valid(v77a_right_label):
		v77a_right_label.position = Vector2.ZERO
		v77a_right_label.size = Vector2(270, 1180)
		v77a_right_label.custom_minimum_size = Vector2(270, 1180)
		v77a_right_label.add_theme_font_size_override("font_size", 14)

	if v78_equipment_hint != null and is_instance_valid(v78_equipment_hint):
		v78_equipment_hint.position = Vector2(615, 875)
		v78_equipment_hint.size = Vector2(470, 52)

	if character_preview_body != null and is_instance_valid(character_preview_body):
		character_preview_body.position = Vector2(800, 500)
	if character_preview_aura != null and is_instance_valid(character_preview_aura):
		character_preview_aura.position = Vector2(800, 500)
