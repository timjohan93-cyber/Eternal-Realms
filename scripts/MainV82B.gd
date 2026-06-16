extends "res://scripts/MainV82A.gd"

# Eternal Realms V8.2B
# First Real Paladin Pass
# Gives Paladin a much stronger Last Epoch-inspired silhouette in-game and in the menu.

var v82b_paladin_menu_node: Node2D
var v82b_paladin_glow_time := 0.0

func _ready() -> void:
	super._ready()
	upgrade_v82b_paladin_menu_visual()
	if current_class == "Paladin":
		apply_v82b_paladin_body()

func _process(delta: float) -> void:
	super._process(delta)
	update_v82b_paladin_glow(delta)

func apply_v81_character_body(class_id: String) -> void:
	if class_id == "Paladin":
		apply_v82b_paladin_body()
	else:
		super.apply_v81_character_body(class_id)

func upgrade_v82b_paladin_menu_visual() -> void:
	if class_select_panel == null:
		return
	if v82b_paladin_menu_node != null and is_instance_valid(v82b_paladin_menu_node):
		return
	if not v80_menu_character_nodes.has("Paladin"):
		return

	var old_node: Node2D = v80_menu_character_nodes["Paladin"]
	if old_node != null and is_instance_valid(old_node):
		old_node.visible = false

	v82b_paladin_menu_node = Node2D.new()
	v82b_paladin_menu_node.name = "V82BRealPaladinMenu"
	v82b_paladin_menu_node.position = Vector2(240 + 2 * 350, 565)
	v82b_paladin_menu_node.scale = Vector2(2.35, 2.35)
	class_select_panel.add_child(v82b_paladin_menu_node)
	build_v82b_paladin_visual(v82b_paladin_menu_node, true)
	v80_menu_character_nodes["Paladin"] = v82b_paladin_menu_node

func apply_v82b_paladin_body() -> void:
	if player == null:
		return
	create_v80_player_visual()
	if v80_player_visual_root == null or not is_instance_valid(v80_player_visual_root):
		return

	for child in v80_player_visual_root.get_children():
		child.queue_free()
	v81_player_parts.clear()
	build_v82b_paladin_visual(v80_player_visual_root, false)
	v80_player_visual_root.scale = Vector2(0.86, 0.86)
	v80_current_visual_class = "Paladin"

func build_v82b_paladin_visual(root: Node2D, is_menu: bool) -> void:
	var rig := Node2D.new()
	rig.name = "RealPaladinRig"
	root.add_child(rig)
	v81_player_parts["rig"] = rig

	var shadow := add_v81_poly(rig, "PaladinShadow", make_v81_ellipse(34, 10, 28), Color(0, 0, 0, 0.36), Vector2(0, 29), -10)
	if not is_menu:
		v81_player_parts["shadow"] = shadow

	# Holy/fire-lit aura behind the body.
	var aura := add_v81_poly(rig, "PaladinHolyAura", make_circle_polygon(48.0, 36), Color(1.0, 0.72, 0.18, 0.10), Vector2(0, -20), -6)
	if not is_menu:
		v81_player_parts["paladin_aura"] = aura

	# Blue cape, large enough to read as a real character silhouette.
	var cape := add_v81_poly(rig, "BlueCape", PackedVector2Array([
		Vector2(-24, -50), Vector2(24, -50), Vector2(34, -4), Vector2(29, 54),
		Vector2(0, 72), Vector2(-29, 54), Vector2(-34, -4)
	]), Color(0.05, 0.12, 0.32, 0.96), Vector2.ZERO, -1)
	v81_player_parts["cape"] = cape
	add_v81_poly(rig, "CapeHighlight", PackedVector2Array([Vector2(-10, -45), Vector2(7, -45), Vector2(12, 44), Vector2(0, 62), Vector2(-16, 43)]), Color(0.08, 0.22, 0.52, 0.58), Vector2.ZERO, 0)

	# Legs/boots.
	v81_player_parts["left_leg"] = add_v81_poly(rig, "LeftSabatons", PackedVector2Array([Vector2(-8, -1), Vector2(-18, 39), Vector2(-7, 44), Vector2(4, 3)]), Color(0.46, 0.43, 0.36, 1), Vector2(-6, 16), 1)
	v81_player_parts["right_leg"] = add_v81_poly(rig, "RightSabatons", PackedVector2Array([Vector2(8, -1), Vector2(18, 39), Vector2(7, 44), Vector2(-4, 3)]), Color(0.46, 0.43, 0.36, 1), Vector2(6, 16), 1)
	add_v81_poly(rig, "LeftGoldBootTrim", PackedVector2Array([Vector2(-18, 37), Vector2(-5, 41), Vector2(-2, 47), Vector2(-20, 44)]), Color(0.95, 0.72, 0.23, 1), Vector2(-6, 16), 2)
	add_v81_poly(rig, "RightGoldBootTrim", PackedVector2Array([Vector2(18, 37), Vector2(5, 41), Vector2(2, 47), Vector2(20, 44)]), Color(0.95, 0.72, 0.23, 1), Vector2(6, 16), 2)

	# Torso armor with gold trim.
	v81_player_parts["torso"] = add_v81_poly(rig, "PaladinPlateTorso", PackedVector2Array([
		Vector2(-22, -45), Vector2(22, -45), Vector2(28, 5), Vector2(13, 31),
		Vector2(0, 38), Vector2(-13, 31), Vector2(-28, 5)
	]), Color(0.70, 0.67, 0.58, 1), Vector2.ZERO, 5)
	v81_player_parts["chest_plate"] = add_v81_poly(rig, "GoldChestCross", PackedVector2Array([Vector2(-5, -39), Vector2(5, -39), Vector2(5, 22), Vector2(-5, 22)]), Color(1.0, 0.78, 0.28, 1), Vector2.ZERO, 7)
	add_v81_poly(rig, "GoldChestBar", PackedVector2Array([Vector2(-18, -18), Vector2(18, -18), Vector2(18, -9), Vector2(-18, -9)]), Color(1.0, 0.78, 0.28, 1), Vector2.ZERO, 7)
	add_v81_poly(rig, "Belt", PackedVector2Array([Vector2(-21, 11), Vector2(21, 11), Vector2(18, 21), Vector2(-18, 21)]), Color(0.18, 0.12, 0.07, 1), Vector2.ZERO, 8)
	add_v81_poly(rig, "BeltBuckle", make_v81_ellipse(6, 5, 12), Color(1.0, 0.75, 0.25, 1), Vector2(0, 16), 9)

	# Big shoulder plates.
	v81_player_parts["left_shoulder"] = add_v81_poly(rig, "LeftGoldShoulder", PackedVector2Array([Vector2(-5, -8), Vector2(-27, -3), Vector2(-35, 10), Vector2(-24, 19), Vector2(-5, 11)]), Color(0.95, 0.72, 0.25, 1), Vector2(-24, -38), 8)
	v81_player_parts["right_shoulder"] = add_v81_poly(rig, "RightGoldShoulder", PackedVector2Array([Vector2(5, -8), Vector2(27, -3), Vector2(35, 10), Vector2(24, 19), Vector2(5, 11)]), Color(0.95, 0.72, 0.25, 1), Vector2(24, -38), 8)

	# Head/helmet/crest.
	v81_player_parts["head"] = add_v81_poly(rig, "HelmetFace", make_v81_ellipse(10, 12, 18), Color(0.40, 0.36, 0.30, 1), Vector2(0, -65), 9)
	v81_player_parts["helmet"] = add_v81_poly(rig, "WingedHelmet", PackedVector2Array([
		Vector2(-16, -70), Vector2(-8, -86), Vector2(0, -95), Vector2(8, -86), Vector2(16, -70),
		Vector2(12, -58), Vector2(-12, -58)
	]), Color(0.82, 0.75, 0.58, 1), Vector2.ZERO, 10)
	add_v81_poly(rig, "HelmetGoldCrest", PackedVector2Array([Vector2(-4, -92), Vector2(0, -106), Vector2(4, -92), Vector2(2, -63), Vector2(-2, -63)]), Color(1.0, 0.78, 0.25, 1), Vector2.ZERO, 11)
	add_v81_poly(rig, "LeftHelmetWing", PackedVector2Array([Vector2(-13, -75), Vector2(-34, -83), Vector2(-26, -68), Vector2(-12, -64)]), Color(0.90, 0.85, 0.68, 1), Vector2.ZERO, 10)
	add_v81_poly(rig, "RightHelmetWing", PackedVector2Array([Vector2(13, -75), Vector2(34, -83), Vector2(26, -68), Vector2(12, -64)]), Color(0.90, 0.85, 0.68, 1), Vector2.ZERO, 10)

	# Arms.
	v81_player_parts["left_arm"] = add_v81_poly(rig, "LeftArmoredArm", PackedVector2Array([Vector2(-3, -5), Vector2(-32, 23), Vector2(-23, 34), Vector2(5, 5)]), Color(0.60, 0.56, 0.48, 1), Vector2(-23, -28), 6)
	v81_player_parts["right_arm"] = add_v81_poly(rig, "RightArmoredArm", PackedVector2Array([Vector2(3, -5), Vector2(32, 23), Vector2(23, 34), Vector2(-5, 5)]), Color(0.60, 0.56, 0.48, 1), Vector2(23, -28), 6)

	# Kite shield with cross.
	v81_player_parts["offhand"] = add_v81_poly(rig, "LargeKiteShield", PackedVector2Array([
		Vector2(0, -36), Vector2(27, -20), Vector2(22, 23), Vector2(0, 49), Vector2(-22, 23), Vector2(-27, -20)
	]), Color(0.72, 0.56, 0.23, 1), Vector2(-57, -12), 12)
	add_v81_poly(rig, "ShieldFace", PackedVector2Array([Vector2(0, -28), Vector2(19, -16), Vector2(15, 17), Vector2(0, 38), Vector2(-15, 17), Vector2(-19, -16)]), Color(0.18, 0.25, 0.42, 1), Vector2(-57, -12), 13)
	add_v81_poly(rig, "ShieldCrossV", PackedVector2Array([Vector2(-4, -31), Vector2(4, -31), Vector2(4, 31), Vector2(-4, 31)]), Color(1.0, 0.78, 0.28, 1), Vector2(-57, -12), 14)
	add_v81_poly(rig, "ShieldCrossH", PackedVector2Array([Vector2(-17, -8), Vector2(17, -8), Vector2(17, 1), Vector2(-17, 1)]), Color(1.0, 0.78, 0.28, 1), Vector2(-57, -12), 14)

	# Mace.
	v81_player_parts["weapon"] = add_v81_poly(rig, "PaladinMaceHandle", PackedVector2Array([Vector2(35, -54), Vector2(43, -54), Vector2(42, 43), Vector2(34, 43)]), Color(0.70, 0.60, 0.42, 1), Vector2.ZERO, 12)
	v81_player_parts["mace_head"] = add_v81_poly(rig, "PaladinMaceHead", PackedVector2Array([
		Vector2(39, -84), Vector2(54, -72), Vector2(54, -55), Vector2(39, -44), Vector2(24, -55), Vector2(24, -72)
	]), Color(0.95, 0.76, 0.26, 1), Vector2.ZERO, 13)
	add_v81_poly(rig, "MaceGlow", make_circle_polygon(18.0, 20), Color(1.0, 0.73, 0.18, 0.15), Vector2(39, -64), 11)

	if is_menu:
		var name := Label.new()
		name.name = "PaladinMenuName"
		name.position = Vector2(-58, 76)
		name.size = Vector2(116, 24)
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name.text = "PALADIN"
		name.add_theme_font_size_override("font_size", 15)
		name.add_theme_color_override("font_color", Color(1.0, 0.82, 0.42, 1))
		rig.add_child(name)

func update_v82b_paladin_glow(delta: float) -> void:
	v82b_paladin_glow_time += delta
	if current_class == "Paladin" and v81_player_parts.has("paladin_aura"):
		var aura: Polygon2D = v81_player_parts["paladin_aura"]
		if aura != null and is_instance_valid(aura):
			aura.scale = Vector2.ONE * (1.0 + abs(sin(v82b_paladin_glow_time * 2.0)) * 0.10)
			aura.color.a = 0.08 + abs(sin(v82b_paladin_glow_time * 2.6)) * 0.08

func update_v81_body_animation(delta: float) -> void:
	# Use base animation, but Paladin gets stronger readable idle/walk motion.
	super.update_v81_body_animation(delta)
	if current_class != "Paladin":
		return
	if not v81_player_parts.has("rig"):
		return
	var moved_dist := 0.0
	if player != null:
		moved_dist = player.position.distance_to(v81_last_player_position)
	var moving := moved_dist > 0.4
	var step := sin(v81_walk_time)
	if v81_player_parts.has("mace_head"):
		var mh: Polygon2D = v81_player_parts["mace_head"]
		mh.rotation = step * 0.035 if moving else sin(v81_walk_time * 0.7) * 0.025
	if v81_player_parts.has("helmet"):
		var helm: Polygon2D = v81_player_parts["helmet"]
		helm.position.y = -abs(sin(v81_walk_time * 0.7)) * 1.0
