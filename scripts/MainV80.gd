extends "res://scripts/MainV79.gd"

# Eternal Realms V8.0
# Shared Character Visual Foundation
# Replaces the colored arrow feel with class-based placeholder characters.
# The same class visual language is used in the main menu and in-game.

var v80_player_visual_root: Node2D
var v80_menu_character_nodes := {}
var v80_breath_time := 0.0
var v80_current_visual_class := ""

func _ready() -> void:
	super._ready()
	create_v80_player_visual()
	create_v80_menu_characters()
	apply_v80_character_class_visual(selected_menu_class)
	apply_v80_menu_layout_polish()

func _process(delta: float) -> void:
	super._process(delta)
	update_v80_character_idle(delta)

func create_v80_player_visual() -> void:
	if player == null:
		return
	if v80_player_visual_root != null and is_instance_valid(v80_player_visual_root):
		return

	if player is Polygon2D:
		# Hide the old arrow shape without disabling the player node.
		var p: Polygon2D = player
		p.polygon = PackedVector2Array()

	v80_player_visual_root = Node2D.new()
	v80_player_visual_root.name = "V80SharedPlayerVisual"
	v80_player_visual_root.z_index = 50
	player.add_child(v80_player_visual_root)

func create_v80_menu_characters() -> void:
	if class_select_panel == null:
		return
	if v80_menu_character_nodes.size() > 0:
		return

	var class_order := ["Warrior", "Rogue", "Paladin", "Mage", "Ranger"]
	for i in range(class_order.size()):
		var class_id := str(class_order[i])
		var holder := Node2D.new()
		holder.name = "V80MenuCharacter" + class_id
		holder.position = Vector2(240 + i * 350, 555)
		holder.scale = Vector2(2.2, 2.2)
		class_select_panel.add_child(holder)
		build_v80_class_visual(holder, class_id, true)
		v80_menu_character_nodes[class_id] = holder

	# Keep old click targets, but make them feel more like labels/cards than the character itself.
	for key in menu_hero_markers.keys():
		var hero_button: Button = menu_hero_markers[key]
		if hero_button != null and is_instance_valid(hero_button):
			hero_button.position.y += 35
			hero_button.modulate = Color(1, 1, 1, 0.18)

func apply_v80_menu_layout_polish() -> void:
	if main_menu_title != null:
		main_menu_title.position = Vector2(58, 70)
		main_menu_title.size = Vector2(470, 145)
		main_menu_title.add_theme_font_size_override("font_size", 54)
	if main_menu_subtitle != null:
		main_menu_subtitle.position = Vector2(72, 255)

	if class_select_panel != null:
		class_select_panel.position = Vector2(520, 70)
		class_select_panel.size = Vector2(1860, 1190)

	# Compact cards so characters become the focus.
	for key in class_card_buttons.keys():
		var card: Button = class_card_buttons[key]
		if card == null or not is_instance_valid(card):
			continue
		var idx := ["Warrior", "Rogue", "Paladin", "Mage", "Ranger"].find(str(key))
		if idx >= 0:
			card.position = Vector2(64 + idx * 350, 770)
			card.size = Vector2(285, 205)
			card.add_theme_font_size_override("font_size", 14)

	# Pull the campfire closer to the character line.
	if menu_fire != null and is_instance_valid(menu_fire):
		menu_fire.position = Vector2(1280, 910)

func build_v80_class_visual(root: Node2D, class_id: String, menu_scale: bool = false) -> void:
	for child in root.get_children():
		child.queue_free()

	var data: Dictionary = menu_classes.get(class_id, menu_classes["Warrior"])
	var class_color: Color = data.get("color", Color(0.9, 0.75, 0.45, 1.0))
	var dark := Color(class_color.r * 0.22, class_color.g * 0.22, class_color.b * 0.22, 1.0)
	var metal := Color(0.42, 0.39, 0.34, 1.0)
	var accent := class_color.lightened(0.25)

	# Shadow / feet anchor.
	add_v80_poly(root, PackedVector2Array([Vector2(-22, 24), Vector2(22, 24), Vector2(34, 30), Vector2(-34, 30)]), Color(0.0, 0.0, 0.0, 0.38), Vector2.ZERO)

	# Body silhouette.
	var body_color := metal
	if class_id == "Mage":
		body_color = Color(0.22, 0.16, 0.33, 1.0)
	elif class_id == "Rogue" or class_id == "Ranger":
		body_color = Color(0.15, 0.20, 0.16, 1.0)
	elif class_id == "Warrior":
		body_color = Color(0.34, 0.30, 0.28, 1.0)
	elif class_id == "Paladin":
		body_color = Color(0.52, 0.47, 0.36, 1.0)

	add_v80_poly(root, PackedVector2Array([Vector2(-18, -8), Vector2(-12, -54), Vector2(0, -70), Vector2(12, -54), Vector2(18, -8), Vector2(11, 22), Vector2(-11, 22)]), body_color, Vector2.ZERO)
	add_v80_poly(root, PackedVector2Array([Vector2(-12, -54), Vector2(0, -72), Vector2(12, -54), Vector2(6, -46), Vector2(-6, -46)]), accent.darkened(0.05), Vector2.ZERO)

	# Head / helmet.
	add_v80_poly(root, make_circle_polygon(10.0, 18), Color(0.64, 0.56, 0.44, 1.0), Vector2(0, -82))
	add_v80_poly(root, PackedVector2Array([Vector2(-14, -88), Vector2(0, -105), Vector2(14, -88), Vector2(9, -78), Vector2(-9, -78)]), dark.lightened(0.15), Vector2.ZERO)

	# Arms.
	add_v80_poly(root, PackedVector2Array([Vector2(-16, -46), Vector2(-42, -18), Vector2(-34, -8), Vector2(-10, -36)]), body_color.darkened(0.08), Vector2.ZERO)
	add_v80_poly(root, PackedVector2Array([Vector2(16, -46), Vector2(42, -18), Vector2(34, -8), Vector2(10, -36)]), body_color.darkened(0.08), Vector2.ZERO)

	# Legs.
	add_v80_poly(root, PackedVector2Array([Vector2(-10, 18), Vector2(-25, 58), Vector2(-12, 62), Vector2(0, 22)]), body_color.darkened(0.18), Vector2.ZERO)
	add_v80_poly(root, PackedVector2Array([Vector2(10, 18), Vector2(25, 58), Vector2(12, 62), Vector2(0, 22)]), body_color.darkened(0.18), Vector2.ZERO)

	# Class-specific weapon/identity pieces.
	if class_id == "Warrior":
		add_v80_poly(root, PackedVector2Array([Vector2(36, -60), Vector2(41, -60), Vector2(41, 34), Vector2(36, 34)]), Color(0.78, 0.76, 0.70, 1.0), Vector2.ZERO)
		add_v80_poly(root, PackedVector2Array([Vector2(31, -66), Vector2(46, -66), Vector2(38, -88)]), Color(0.92, 0.86, 0.72, 1.0), Vector2.ZERO)
	elif class_id == "Rogue":
		add_v80_poly(root, PackedVector2Array([Vector2(-43, -20), Vector2(-22, 4), Vector2(-29, 10), Vector2(-50, -14)]), Color(0.82, 0.82, 0.75, 1.0), Vector2.ZERO)
		add_v80_poly(root, PackedVector2Array([Vector2(43, -20), Vector2(22, 4), Vector2(29, 10), Vector2(50, -14)]), Color(0.82, 0.82, 0.75, 1.0), Vector2.ZERO)
	elif class_id == "Paladin":
		add_v80_poly(root, make_circle_polygon(23.0, 24), Color(0.75, 0.58, 0.22, 1.0), Vector2(-42, -16))
		add_v80_poly(root, PackedVector2Array([Vector2(-42, -36), Vector2(-22, -16), Vector2(-42, 4), Vector2(-62, -16)]), Color(0.95, 0.82, 0.36, 0.95), Vector2.ZERO)
		add_v80_poly(root, PackedVector2Array([Vector2(35, -48), Vector2(41, -48), Vector2(41, 38), Vector2(35, 38)]), Color(0.84, 0.82, 0.72, 1.0), Vector2.ZERO)
	elif class_id == "Mage":
		add_v80_poly(root, PackedVector2Array([Vector2(40, -72), Vector2(46, -72), Vector2(32, 50), Vector2(26, 50)]), Color(0.58, 0.40, 0.22, 1.0), Vector2.ZERO)
		add_v80_poly(root, make_circle_polygon(12.0, 18), Color(0.70, 0.35, 1.0, 0.90), Vector2(44, -83))
	elif class_id == "Ranger":
		add_v80_poly(root, PackedVector2Array([Vector2(42, -54), Vector2(57, -18), Vector2(42, 20), Vector2(48, 18), Vector2(64, -18), Vector2(48, -56)]), Color(0.72, 0.50, 0.25, 1.0), Vector2.ZERO)
		add_v80_poly(root, PackedVector2Array([Vector2(-38, -26), Vector2(44, -14), Vector2(42, -10), Vector2(-40, -22)]), Color(0.82, 0.82, 0.72, 1.0), Vector2.ZERO)

	# Subtle class glow marker.
	add_v80_poly(root, make_circle_polygon(45.0, 32), Color(class_color.r, class_color.g, class_color.b, 0.10 if menu_scale else 0.08), Vector2(0, -18))

func add_v80_poly(root: Node2D, poly: PackedVector2Array, color: Color, pos: Vector2) -> Polygon2D:
	var shape := Polygon2D.new()
	shape.polygon = poly
	shape.color = color
	shape.position = pos
	shape.z_index = 5
	root.add_child(shape)
	return shape

func apply_v80_character_class_visual(class_id: String) -> void:
	v80_current_visual_class = class_id
	create_v80_player_visual()
	if v80_player_visual_root != null and is_instance_valid(v80_player_visual_root):
		build_v80_class_visual(v80_player_visual_root, class_id, false)
		v80_player_visual_root.scale = Vector2(0.75, 0.75)

	for key in v80_menu_character_nodes.keys():
		var node: Node2D = v80_menu_character_nodes[key]
		if node == null or not is_instance_valid(node):
			continue
		var active: bool = str(key) == class_id
		node.modulate = Color(1, 1, 1, 1) if active else Color(0.45, 0.45, 0.48, 0.62)
		node.scale = Vector2(2.45, 2.45) if active else Vector2(2.05, 2.05)

func select_v79_menu_class(class_id: String) -> void:
	super.select_v79_menu_class(class_id)
	apply_v80_character_class_visual(class_id)

func start_v79_game() -> void:
	super.start_v79_game()
	apply_v80_character_class_visual(current_class)

func change_class() -> void:
	super.change_class()
	apply_v80_character_class_visual(current_class)

func update_v80_character_idle(delta: float) -> void:
	v80_breath_time += delta
	var breath := sin(v80_breath_time * 2.4)
	var sway := sin(v80_breath_time * 1.3)

	if v80_player_visual_root != null and is_instance_valid(v80_player_visual_root):
		v80_player_visual_root.scale = Vector2(0.75 + breath * 0.018, 0.75 + abs(breath) * 0.020)
		v80_player_visual_root.rotation = sway * 0.015

	for key in v80_menu_character_nodes.keys():
		var node: Node2D = v80_menu_character_nodes[key]
		if node == null or not is_instance_valid(node):
			continue
		var active: bool = str(key) == selected_menu_class
		var base_scale := 2.45 if active else 2.05
		node.scale = Vector2(base_scale + breath * 0.035, base_scale + abs(breath) * 0.040)
		node.rotation = sway * (0.012 if active else 0.006)

func update_v79_menu_animation(delta: float) -> void:
	super.update_v79_menu_animation(delta)
	# Slightly stronger fire glow for the new character lineup.
	if menu_fire != null and is_instance_valid(menu_fire):
		var pulse := 1.0 + sin(menu_fire_time * 5.0) * 0.12
		menu_fire.scale = Vector2(pulse * 1.15, pulse * 1.05)
