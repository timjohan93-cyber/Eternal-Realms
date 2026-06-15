extends "res://scripts/MainV78B.gd"

# Eternal Realms V7.8C
# Inventory Scroll/Fit Pass
# Replaces the legacy fixed 4-column inventory buttons with a clipped, scrollable 3-column grid.

var v78c_inventory_scroll: ScrollContainer
var v78c_inventory_grid: GridContainer
var v78c_inventory_hint: Label
var v78c_inventory_buttons: Array = []

func _ready() -> void:
	super._ready()
	create_v78c_inventory_scroll()
	update_inventory_ui()

func create_v78c_inventory_scroll() -> void:
	if inventory_panel == null:
		return
	if v78c_inventory_scroll != null and is_instance_valid(v78c_inventory_scroll):
		return

	v78c_inventory_hint = Label.new()
	v78c_inventory_hint.position = Vector2(18, 70)
	v78c_inventory_hint.size = Vector2(455, 44)
	v78c_inventory_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v78c_inventory_hint.text = "Select an item, then click matching equipment slot."
	v78c_inventory_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v78c_inventory_hint.add_theme_font_size_override("font_size", 13)
	v78c_inventory_hint.add_theme_color_override("font_color", Color(0.74, 0.68, 0.56, 1.0))
	inventory_panel.add_child(v78c_inventory_hint)

	v78c_inventory_scroll = ScrollContainer.new()
	v78c_inventory_scroll.name = "V78CInventoryScroll"
	v78c_inventory_scroll.position = Vector2(18, 118)
	v78c_inventory_scroll.size = Vector2(462, 890)
	v78c_inventory_scroll.clip_contents = true
	v78c_inventory_scroll.follow_focus = true
	v78c_inventory_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	inventory_panel.add_child(v78c_inventory_scroll)

	v78c_inventory_grid = GridContainer.new()
	v78c_inventory_grid.name = "V78CInventoryGrid"
	v78c_inventory_grid.columns = 3
	v78c_inventory_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v78c_inventory_grid.add_theme_constant_override("h_separation", 8)
	v78c_inventory_grid.add_theme_constant_override("v_separation", 8)
	v78c_inventory_scroll.add_child(v78c_inventory_grid)

	hide_v78c_legacy_inventory_controls()

func hide_v78c_legacy_inventory_controls() -> void:
	if inventory_label != null and is_instance_valid(inventory_label):
		inventory_label.visible = false
		inventory_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	for old_button in inventory_buttons:
		if old_button != null and is_instance_valid(old_button):
			old_button.visible = false
			old_button.disabled = true
			old_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

func update_inventory_ui() -> void:
	super.update_inventory_ui()
	create_v78c_inventory_scroll()
	apply_v78c_inventory_layout()
	hide_v78c_legacy_inventory_controls()
	rebuild_v78c_inventory_grid()
	update_potion_belt_ui()

func apply_v78c_inventory_layout() -> void:
	if inventory_panel == null:
		return

	inventory_panel.position = Vector2(2035, 90)
	inventory_panel.size = Vector2(500, 1040)
	inventory_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.018, 0.019, 0.022, 0.985), Color(0.58, 0.46, 0.25, 0.98), 2))

	if sort_button != null and is_instance_valid(sort_button):
		sort_button.position = Vector2(365, 18)
		sort_button.size = Vector2(110, 36)
		sort_button.add_theme_stylebox_override("normal", make_v78a_button_style(Color(0.06, 0.055, 0.05, 0.98), Color(0.40, 0.32, 0.18, 0.92), 1))
		sort_button.add_theme_stylebox_override("hover", make_v78a_button_style(Color(0.12, 0.095, 0.065, 1.0), Color(0.95, 0.70, 0.30, 1.0), 1))
		sort_button.add_theme_color_override("font_color", Color(0.92, 0.86, 0.76, 1.0))

	if v78c_inventory_scroll != null and is_instance_valid(v78c_inventory_scroll):
		v78c_inventory_scroll.position = Vector2(18, 118)
		v78c_inventory_scroll.size = Vector2(462, 890)
		v78c_inventory_scroll.visible = inventory_panel.visible

	if v78c_inventory_hint != null and is_instance_valid(v78c_inventory_hint):
		v78c_inventory_hint.visible = inventory_panel.visible
		if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
			var selected_item = inventory[selected_inventory_index]
			v78c_inventory_hint.text = "Selected: " + str(selected_item.get("name", "Item")) + "  |  Sell: " + str(get_item_price(selected_item)) + " gold"
		else:
			v78c_inventory_hint.text = "Select an item, then click matching equipment slot."

func rebuild_v78c_inventory_grid() -> void:
	if v78c_inventory_grid == null or not is_instance_valid(v78c_inventory_grid):
		return

	for child in v78c_inventory_grid.get_children():
		child.queue_free()
	v78c_inventory_buttons.clear()

	for i in range(max_inventory_size):
		var index: int = i
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(148, 64)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.clip_text = true
		btn.text = get_v78c_inventory_button_text(index)
		btn.tooltip_text = get_v78c_inventory_tooltip(index)
		btn.pressed.connect(func() -> void: select_v78c_inventory_item(index))
		apply_v78c_inventory_button_style(btn, index)
		v78c_inventory_grid.add_child(btn)
		v78c_inventory_buttons.append(btn)

func select_v78c_inventory_item(index: int) -> void:
	if index < inventory.size():
		select_inventory_item(index)
	else:
		selected_inventory_index = -1
		update_inventory_ui()
		update_character_ui()

func get_v78c_inventory_button_text(index: int) -> String:
	if index >= inventory.size():
		return "Empty"

	var item = inventory[index]
	var name: String = str(item.get("name", "Item"))
	if name.length() > 15:
		name = name.substr(0, 14) + "."
	var mark := "> " if index == selected_inventory_index else ""
	return mark + name + "\n" + str(item.get("rarity", "Common"))

func get_v78c_inventory_tooltip(index: int) -> String:
	if index >= inventory.size():
		return "Empty inventory slot"
	return item_to_text(inventory[index])

func apply_v78c_inventory_button_style(btn: Button, index: int) -> void:
	var rarity := "Empty"
	var filled := index < inventory.size()
	if filled:
		var item = inventory[index]
		rarity = str(item.get("rarity", "Common"))

	var border: Color = get_v78a_rarity_frame_color(rarity)
	var bg: Color = Color(0.045, 0.045, 0.050, 0.98) if filled else Color(0.025, 0.026, 0.030, 0.86)
	var border_width := 2 if index == selected_inventory_index else 1
	if index == selected_inventory_index:
		border = Color(1.0, 0.78, 0.30, 1.0)
		bg = Color(0.16, 0.105, 0.045, 1.0)

	btn.add_theme_stylebox_override("normal", make_v78a_button_style(bg, border, border_width))
	btn.add_theme_stylebox_override("hover", make_v78a_button_style(bg.lightened(0.12), border.lightened(0.16), 2))
	btn.add_theme_stylebox_override("pressed", make_v78a_button_style(bg.lightened(0.20), border.lightened(0.25), 2))
	btn.add_theme_color_override("font_color", Color(0.92, 0.88, 0.80, 1.0) if filled else Color(0.38, 0.36, 0.33, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.70, 1.0))
	btn.add_theme_font_size_override("font_size", 14)

func get_inventory_slot_rect(index: int) -> Rect2:
	if v78c_inventory_scroll != null and is_instance_valid(v78c_inventory_scroll):
		if index >= 0 and index < v78c_inventory_buttons.size():
			var btn: Button = v78c_inventory_buttons[index]
			if btn != null and is_instance_valid(btn):
				return Rect2(btn.global_position, btn.size)
	return super.get_inventory_slot_rect(index)

func handle_inventory_grid_click(mouse_pos: Vector2) -> bool:
	if inventory_panel != null and inventory_panel.visible and get_panel_rect_global(inventory_panel).has_point(mouse_pos):
		for i in range(v78c_inventory_buttons.size()):
			var btn: Button = v78c_inventory_buttons[i]
			if btn != null and is_instance_valid(btn) and Rect2(btn.global_position, btn.size).has_point(mouse_pos):
				select_v78c_inventory_item(i)
				return true
		return true
	return super.handle_inventory_grid_click(mouse_pos)
