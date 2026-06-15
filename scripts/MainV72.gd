extends "res://scripts/MainV69.gd"

# Eternal Realms V7.2 stable patch
# Clean Godlike limit + aura version using V6.9 as base.

const MAX_GODLIKE_EQUIPPED := 2

var godlike_aura: Polygon2D
var godlike_orb_1: Polygon2D
var godlike_orb_2: Polygon2D
var godlike_aura_time: float = 0.0

func _ready() -> void:
	super._ready()
	create_godlike_aura_visuals()
	update_godlike_aura_visuals(0.0)
	update_hud()
	update_character_ui()

func _process(delta: float) -> void:
	super._process(delta)
	update_godlike_aura_visuals(delta)

func create_godlike_aura_visuals() -> void:
	if player == null:
		return
	if godlike_aura != null and is_instance_valid(godlike_aura):
		return

	godlike_aura = Polygon2D.new()
	godlike_aura.name = "GodlikeAura"
	godlike_aura.polygon = make_circle_polygon(42.0, 32)
	godlike_aura.color = Color(0.8, 0.2, 1.0, 0.18)
	godlike_aura.z_index = -1
	player.add_child(godlike_aura)

	godlike_orb_1 = Polygon2D.new()
	godlike_orb_1.name = "GodlikeOrb1"
	godlike_orb_1.polygon = make_circle_polygon(7.0, 14)
	godlike_orb_1.color = Color(1.0, 0.35, 1.0, 0.9)
	player.add_child(godlike_orb_1)

	godlike_orb_2 = Polygon2D.new()
	godlike_orb_2.name = "GodlikeOrb2"
	godlike_orb_2.polygon = make_circle_polygon(7.0, 14)
	godlike_orb_2.color = Color(0.6, 0.35, 1.0, 0.9)
	player.add_child(godlike_orb_2)

func make_circle_polygon(radius: float, points: int) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for i in range(points):
		var a: float = TAU * float(i) / float(points)
		arr.append(Vector2(cos(a), sin(a)) * radius)
	return arr

func update_godlike_aura_visuals(delta: float) -> void:
	if godlike_aura == null or not is_instance_valid(godlike_aura):
		return

	godlike_aura_time += delta
	var count: int = get_equipped_godlike_count()
	var show: bool = count > 0

	godlike_aura.visible = show
	godlike_orb_1.visible = show
	godlike_orb_2.visible = count >= 2

	if not show:
		return

	var pulse: float = 0.16 + abs(sin(godlike_aura_time * 3.0)) * 0.12
	var size_boost: float = 1.0 + float(count) * 0.18 + abs(sin(godlike_aura_time * 2.0)) * 0.08
	godlike_aura.scale = Vector2(size_boost, size_boost)
	godlike_aura.color = get_godlike_aura_color()
	godlike_aura.color.a = pulse

	var orbit: float = 34.0 + float(count) * 8.0
	godlike_orb_1.position = Vector2(cos(godlike_aura_time * 2.5), sin(godlike_aura_time * 2.5)) * orbit
	godlike_orb_2.position = Vector2(cos(godlike_aura_time * 2.5 + PI), sin(godlike_aura_time * 2.5 + PI)) * orbit

func get_godlike_aura_color() -> Color:
	var count: int = get_equipped_godlike_count()
	if count >= 2:
		return Color(1.0, 0.1, 1.0, 0.28)
	return Color(0.75, 0.2, 1.0, 0.20)

func get_equipped_godlike_count(excluding_slot: String = "") -> int:
	var count: int = 0
	for slot in equipment.keys():
		if slot == excluding_slot:
			continue
		var item = equipment.get(slot, null)
		if item != null and str(item.get("rarity", "")) == "Godlike":
			count += 1
	return count

func can_equip_godlike_item(item: Dictionary, target_slot: String) -> bool:
	if str(item.get("rarity", "")) != "Godlike":
		return true
	var current_count: int = get_equipped_godlike_count(target_slot)
	return current_count < MAX_GODLIKE_EQUIPPED

func equip_item_to_specific_slot(index: int, slot: String) -> void:
	if index < 0 or index >= inventory.size():
		return
	if not equipment.has(slot):
		return

	var item = inventory[index]
	if not can_item_go_in_slot(item, slot):
		loot_label.text = "Wrong slot. " + str(item.get("name", "Item")) + " cannot go in " + display_slot_name(slot) + "."
		return

	if not can_equip_godlike_item(item, slot):
		loot_label.text = "Godlike limit reached. You may only equip " + str(MAX_GODLIKE_EQUIPPED) + " Godlike items at once."
		return

	var old = equipment[slot]
	equipment[slot] = item
	inventory.remove_at(index)
	if old != null:
		inventory.append(old)

	recalculate_stats()
	loot_label.text = "Equipped to " + display_slot_name(slot) + ":\n" + item_to_text(item)
	update_hud()
	update_inventory_ui()
	update_character_ui()
	update_godlike_aura_visuals(0.0)
	save_game()

func update_character_ui() -> void:
	super.update_character_ui()
	if character_label == null:
		return
	if character_tab in ["Equipment", "Build"]:
		character_label.text += "\n\nGODLIKE POWER SLOTS: " + str(get_equipped_godlike_count()) + "/" + str(MAX_GODLIKE_EQUIPPED)

func update_hud() -> void:
	super.update_hud()
	if hud_label != null:
		hud_label.text += "\nGodlike: " + str(get_equipped_godlike_count()) + "/" + str(MAX_GODLIKE_EQUIPPED)

func item_to_text(item: Dictionary) -> String:
	var text: String = super.item_to_text(item)
	if str(item.get("rarity", "")) == "Godlike":
		text += "GODLIKE POWER: Counts toward the " + str(MAX_GODLIKE_EQUIPPED) + " item Godlike limit.\n"
	return text
