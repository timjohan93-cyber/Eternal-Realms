extends "res://scripts/MainV80B.gd"

# Eternal Realms V8.1A
# Shared Character Body Parts
# Rebuilds the in-game player visual as a body-part character instead of the old arrow.
# This remains polygon-only for now, but the structure prepares us for real sprites/models and gear visuals later.

var v81_player_parts := {}
var v81_walk_time: float = 0.0
var v81_last_player_position: Vector2 = Vector2.ZERO
var v81_last_facing: Vector2 = Vector2(1, 0)

func _ready() -> void:
	super._ready()
	hide_v81_old_player_arrow()
	apply_v81_character_body(current_class)
	if player != null:
		v81_last_player_position = player.position

func _process(delta: float) -> void:
	super._process(delta)
	update_v81_body_animation(delta)

func create_v80_player_visual() -> void:
	if player == null:
		return
	if v80_player_visual_root != null and is_instance_valid(v80_player_visual_root):
		return
	v80_player_visual_root = Node2D.new()
	v80_player_visual_root.name = "V81SharedPlayerBodyParts"
	v80_player_visual_root.z_index = 90
	player.add_child(v80_player_visual_root)

func hide_v81_old_player_arrow() -> void:
	if player_shape != null and is_instance_valid(player_shape):
		player_shape.visible = false
		player_shape.polygon = PackedVector2Array()

func apply_v80_character_class_visual(class_id: String) -> void:
	v80_current_visual_class = class_id
	create_v80_player_visual()
	apply_v81_character_body(class_id)
	for key in v80_menu_character_nodes.keys():
		var node: Node2D = v80_menu_character_nodes[key]
		if node == null or not is_instance_valid(node):
			continue
		var active: bool = str(key) == class_id
		node.modulate = Color(1, 1, 1, 1) if active else Color(0.45, 0.45, 0.48, 0.62)
		node.scale = Vector2(2.45, 2.45) if active else Vector2(2.05, 2.05)

func apply_v81_character_body(class_id: String) -> void:
	if player == null:
		return
	create_v80_player_visual()
	if v80_player_visual_root == null or not is_instance_valid(v80_player_visual_root):
		return
	for child in v80_player_visual_root.get_children():
		child.queue_free()
	v81_player_parts.clear()
	var colors: Dictionary = get_v81_class_palette(class_id)
	var body := Node2D.new()
	body.name = "BodyRig"
	v80_player_visual_root.add_child(body)
	v81_player_parts["rig"] = body
	v81_player_parts["shadow"] = add_v81_poly(body, "Shadow", make_v81_ellipse(25, 9, 24), Color(0, 0, 0, 0.32), Vector2(0, 18), -5)
	v81_player_parts["left_leg"] = add_v81_poly(body, "LeftLeg", PackedVector2Array([Vector2(-7, 0), Vector2(-17, 34), Vector2(-7, 38), Vector2(3, 4)]), colors["leg"], Vector2(-5, 8), 1)
	v81_player_parts["right_leg"] = add_v81_poly(body, "RightLeg", PackedVector2Array([Vector2(7, 0), Vector2(17, 34), Vector2(7, 38), Vector2(-3, 4)]), colors["leg"], Vector2(5, 8), 1)
	if class_id in ["Mage", "Ranger", "Rogue", "Paladin"]:
		v81_player_parts["cape"] = add_v81_poly(body, "Cape", PackedVector2Array([Vector2(-18, -38), Vector2(18, -38), Vector2(28, 42), Vector2(0, 58), Vector2(-28, 42)]), colors["cape"], Vector2.ZERO, 0)
	v81_player_parts["torso"] = add_v81_poly(body, "Torso", PackedVector2Array([Vector2(-17, -35), Vector2(17, -35), Vector2(21, 9), Vector2(10, 25), Vector2(-10, 25), Vector2(-21, 9)]), colors["torso"], Vector2.ZERO, 5)
	v81_player_parts["chest_plate"] = add_v81_poly(body, "ChestPlate", PackedVector2Array([Vector2(-11, -28), Vector2(11, -28), Vector2(13, 6), Vector2(0, 20), Vector2(-13, 6)]), colors["accent"], Vector2.ZERO, 6)
	v81_player_parts["left_shoulder"] = add_v81_poly(body, "LeftShoulder", make_v81_ellipse(12, 8, 14), colors["metal"], Vector2(-23, -29), 7)
	v81_player_parts["right_shoulder"] = add_v81_poly(body, "RightShoulder", make_v81_ellipse(12, 8, 14), colors["metal"], Vector2(23, -29), 7)
	v81_player_parts["head"] = add_v81_poly(body, "Head", make_circle_polygon(9.0, 18), colors["skin"], Vector2(0, -53), 8)
	v81_player_parts["helmet"] = add_v81_poly(body, "Helmet", PackedVector2Array([Vector2(-13, -58), Vector2(0, -75), Vector2(13, -58), Vector2(8, -48), Vector2(-8, -48)]), colors["helmet"], Vector2.ZERO, 9)
	v81_player_parts["left_arm"] = add_v81_poly(body, "LeftArm", PackedVector2Array([Vector2(-4, -4), Vector2(-31, 22), Vector2(-23, 30), Vector2(3, 4)]), colors["arm"], Vector2(-21, -22), 4)
	v81_player_parts["right_arm"] = add_v81_poly(body, "RightArm", PackedVector2Array([Vector2(4, -4), Vector2(31, 22), Vector2(23, 30), Vector2(-3, 4)]), colors["arm"], Vector2(21, -22), 4)
	match class_id:
		"Warrior":
			v81_player_parts["weapon"] = add_v81_poly(body, "Sword", PackedVector2Array([Vector2(34, -62), Vector2(39, -62), Vector2(40, 28), Vector2(33, 28)]), colors["weapon"], Vector2.ZERO, 10)
			v81_player_parts["weapon_tip"] = add_v81_poly(body, "SwordTip", PackedVector2Array([Vector2(30, -66), Vector2(43, -66), Vector2(36, -88)]), colors["weapon"].lightened(0.18), Vector2.ZERO, 11)
			v81_player_parts["offhand"] = add_v81_poly(body, "Shield", make_v81_shield(), colors["shield"], Vector2(-42, -12), 10)
		"Rogue":
			v81_player_parts["weapon"] = add_v81_poly(body, "DaggerR", PackedVector2Array([Vector2(28, -8), Vector2(53, 16), Vector2(48, 21), Vector2(23, -3)]), colors["weapon"], Vector2.ZERO, 10)
			v81_player_parts["offhand"] = add_v81_poly(body, "DaggerL", PackedVector2Array([Vector2(-28, -8), Vector2(-53, 16), Vector2(-48, 21), Vector2(-23, -3)]), colors["weapon"], Vector2.ZERO, 10)
		"Paladin":
			v81_player_parts["weapon"] = add_v81_poly(body, "Mace", PackedVector2Array([Vector2(34, -52), Vector2(40, -52), Vector2(40, 31), Vector2(34, 31)]), colors["weapon"], Vector2.ZERO, 10)
			v81_player_parts["mace_head"] = add_v81_poly(body, "MaceHead", make_v81_ellipse(13, 13, 16), colors["holy"], Vector2(37, -62), 11)
			v81_player_parts["offhand"] = add_v81_poly(body, "HolyShield", make_v81_shield(), colors["shield"], Vector2(-43, -12), 10)
		"Mage":
			v81_player_parts["weapon"] = add_v81_poly(body, "Staff", PackedVector2Array([Vector2(38, -72), Vector2(44, -72), Vector2(28, 48), Vector2(22, 48)]), colors["weapon"], Vector2.ZERO, 10)
			v81_player_parts["orb"] = add_v81_poly(body, "Orb", make_circle_polygon(11.0, 18), colors["magic"], Vector2(43, -83), 11)
		"Ranger":
			v81_player_parts["weapon"] = add_v81_poly(body, "Bow", PackedVector2Array([Vector2(38, -56), Vector2(55, -17), Vector2(38, 24), Vector2(44, 21), Vector2(62, -17), Vector2(44, -59)]), colors["weapon"], Vector2.ZERO, 10)
			v81_player_parts["arrow"] = add_v81_poly(body, "Arrow", PackedVector2Array([Vector2(-32, -25), Vector2(45, -13), Vector2(44, -9), Vector2(-34, -21)]), colors["weapon"].lightened(0.18), Vector2.ZERO, 11)
	v80_player_visual_root.scale = Vector2(0.82, 0.82)

func add_v81_poly(root: Node2D, part_name: String, poly: PackedVector2Array, color: Color, pos: Vector2, z: int) -> Polygon2D:
	var shape := Polygon2D.new()
	shape.name = part_name
	shape.polygon = poly
	shape.color = color
	shape.position = pos
	shape.z_index = z
	root.add_child(shape)
	return shape

func get_v81_class_palette(class_id: String) -> Dictionary:
	var skin := Color(0.64, 0.54, 0.42, 1.0)
	match class_id:
		"Warrior":
			return {"skin": skin, "torso": Color(0.34, 0.30, 0.27, 1), "accent": Color(0.55, 0.12, 0.08, 1), "metal": Color(0.50, 0.46, 0.40, 1), "helmet": Color(0.38, 0.36, 0.34, 1), "arm": Color(0.34, 0.30, 0.27, 1), "leg": Color(0.22, 0.20, 0.19, 1), "cape": Color(0.18, 0.05, 0.035, 0.95), "weapon": Color(0.82, 0.80, 0.74, 1), "shield": Color(0.48, 0.42, 0.34, 1), "holy": Color(1, 0.82, 0.28, 1), "magic": Color(0.65, 0.25, 1, 1)}
		"Rogue":
			return {"skin": skin, "torso": Color(0.10, 0.19, 0.13, 1), "accent": Color(0.18, 0.70, 0.28, 1), "metal": Color(0.18, 0.24, 0.18, 1), "helmet": Color(0.045, 0.075, 0.055, 1), "arm": Color(0.10, 0.18, 0.13, 1), "leg": Color(0.07, 0.10, 0.08, 1), "cape": Color(0.02, 0.045, 0.035, 0.95), "weapon": Color(0.74, 0.78, 0.72, 1), "shield": Color(0.16, 0.26, 0.16, 1), "holy": Color(1, 0.82, 0.28, 1), "magic": Color(0.65, 0.25, 1, 1)}
		"Paladin":
			return {"skin": skin, "torso": Color(0.52, 0.47, 0.36, 1), "accent": Color(0.95, 0.76, 0.28, 1), "metal": Color(0.78, 0.72, 0.58, 1), "helmet": Color(0.82, 0.70, 0.38, 1), "arm": Color(0.55, 0.49, 0.37, 1), "leg": Color(0.38, 0.34, 0.27, 1), "cape": Color(0.18, 0.12, 0.05, 0.95), "weapon": Color(0.86, 0.84, 0.72, 1), "shield": Color(0.75, 0.58, 0.22, 1), "holy": Color(1.0, 0.86, 0.32, 1), "magic": Color(0.65, 0.25, 1, 1)}
		"Mage":
			return {"skin": skin, "torso": Color(0.20, 0.13, 0.32, 1), "accent": Color(0.60, 0.24, 1.0, 1), "metal": Color(0.27, 0.17, 0.42, 1), "helmet": Color(0.13, 0.07, 0.22, 1), "arm": Color(0.20, 0.13, 0.32, 1), "leg": Color(0.12, 0.08, 0.18, 1), "cape": Color(0.08, 0.035, 0.15, 0.96), "weapon": Color(0.55, 0.34, 0.18, 1), "shield": Color(0.32, 0.19, 0.46, 1), "holy": Color(1, 0.82, 0.28, 1), "magic": Color(0.70, 0.32, 1.0, 0.95)}
		"Ranger":
			return {"skin": skin, "torso": Color(0.16, 0.24, 0.12, 1), "accent": Color(0.35, 0.75, 0.25, 1), "metal": Color(0.22, 0.32, 0.16, 1), "helmet": Color(0.08, 0.12, 0.06, 1), "arm": Color(0.17, 0.25, 0.13, 1), "leg": Color(0.10, 0.15, 0.08, 1), "cape": Color(0.05, 0.10, 0.04, 0.95), "weapon": Color(0.66, 0.43, 0.20, 1), "shield": Color(0.18, 0.28, 0.12, 1), "holy": Color(1, 0.82, 0.28, 1), "magic": Color(0.65, 0.25, 1, 1)}
	return get_v81_class_palette("Warrior")

func make_v81_ellipse(rx: float, ry: float, points: int) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for i in range(points):
		var a := TAU * float(i) / float(points)
		arr.append(Vector2(cos(a) * rx, sin(a) * ry))
	return arr

func make_v81_shield() -> PackedVector2Array:
	return PackedVector2Array([Vector2(0, -25), Vector2(20, -13), Vector2(16, 14), Vector2(0, 30), Vector2(-16, 14), Vector2(-20, -13)])

func update_v81_body_animation(delta: float) -> void:
	if player == null or v80_player_visual_root == null or not is_instance_valid(v80_player_visual_root):
		return
	if not v81_player_parts.has("rig"):
		return
	var moved_dist: float = player.position.distance_to(v81_last_player_position)
	var moving: bool = moved_dist > 0.4
	if moving:
		v81_walk_time += delta * 8.0
		var move_dir: Vector2 = v81_last_player_position.direction_to(player.position)
		if move_dir.length() > 0.01:
			v81_last_facing = move_dir.normalized()
	else:
		v81_walk_time += delta * 2.2
	var rig: Node2D = v81_player_parts["rig"]
	var breath: float = sin(v81_walk_time * 1.25)
	var step: float = sin(v81_walk_time)
	var step_abs: float = absf(step)
	rig.scale = Vector2(1.0 + breath * 0.012, 1.0 + absf(breath) * 0.018)
	rig.position.y = -step_abs * 2.0 if moving else breath * 1.0
	rig.rotation = step * 0.035 if moving else sin(v81_walk_time * 0.6) * 0.012
	if v81_player_parts.has("left_leg"):
		var l: Polygon2D = v81_player_parts["left_leg"]
		l.rotation = step * 0.22 if moving else -0.03
		l.position.y = 8 + (step_abs * 2.0 if moving else 0.0)
	if v81_player_parts.has("right_leg"):
		var r: Polygon2D = v81_player_parts["right_leg"]
		r.rotation = -step * 0.22 if moving else 0.03
		r.position.y = 8 + ((1.0 - step_abs) * 1.2 if moving else 0.0)
	if v81_player_parts.has("left_arm"):
		var la: Polygon2D = v81_player_parts["left_arm"]
		la.rotation = -step * 0.18 if moving else sin(v81_walk_time * 0.8) * 0.04
	if v81_player_parts.has("right_arm"):
		var ra: Polygon2D = v81_player_parts["right_arm"]
		ra.rotation = step * 0.18 if moving else -sin(v81_walk_time * 0.8) * 0.04
	if v81_player_parts.has("weapon"):
		var w: Polygon2D = v81_player_parts["weapon"]
		w.rotation = step * 0.04 if moving else sin(v81_walk_time * 0.7) * 0.035
	if v81_player_parts.has("offhand"):
		var oh: Polygon2D = v81_player_parts["offhand"]
		oh.rotation = -step * 0.045 if moving else -sin(v81_walk_time * 0.7) * 0.025
	if v81_player_parts.has("cape"):
		var cape: Polygon2D = v81_player_parts["cape"]
		cape.rotation = -step * 0.045 if moving else sin(v81_walk_time * 0.55) * 0.025
	if v81_player_parts.has("orb"):
		var orb: Polygon2D = v81_player_parts["orb"]
		orb.position = Vector2(43 + cos(v81_walk_time * 1.7) * 2.0, -83 + sin(v81_walk_time * 1.9) * 3.0)
		orb.color.a = 0.78 + absf(sin(v81_walk_time * 2.0)) * 0.20
	if absf(v81_last_facing.x) > 0.05:
		v80_player_visual_root.scale.x = 0.82 * sign(v81_last_facing.x)
		v80_player_visual_root.scale.y = 0.82
	v81_last_player_position = player.position

func change_class() -> void:
	super.change_class()
	hide_v81_old_player_arrow()
	apply_v81_character_body(current_class)

func start_v79_game() -> void:
	super.start_v79_game()
	hide_v81_old_player_arrow()
	apply_v81_character_body(current_class)

func enter_random_dungeon() -> void:
	super.enter_random_dungeon()
	hide_v81_old_player_arrow()
	apply_v81_character_body(current_class)
	if player != null:
		v81_last_player_position = player.position

func return_to_town() -> void:
	super.return_to_town()
	hide_v81_old_player_arrow()
	apply_v81_character_body(current_class)
	if player != null:
		v81_last_player_position = player.position
