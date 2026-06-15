extends "res://scripts/MainV69.gd"

# Eternal Realms V7.1
# Equipment Identity Update
# Adds Godlike equipment limits, Godlike aura visuals and Rogue dual-wield foundation.

const MAX_GODLIKE_EQUIPPED := 2

var godlike_aura: Polygon2D
var godlike_orb_1: Polygon2D
var godlike_orb_2: Polygon2D
var godlike_aura_time := 0.0

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
	godlike_aura.color = Color(1.0, 0.15, 1.0, 0.18)
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
	godlike_orb_2.color = Color(0.7, 0.35, 1.0, 0.9)
	player.add_child(godlike_orb_2)

func make_circle_polygon(radius: float, points: int) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for i in range(points):
		var a := TAU * float(i) / float(points)
		arr.append(Vector2(cos(a), sin(a)) * radius)
	return arr

func update_godlike_aura_visuals(delta: float) -> void:
	if godlike_aura == null or not is_instance_valid(godlike_aura):
		return

	godlike_aura_time += delta
	var count := get_equipped_godlike_count()
	var show := count > 0
	godlike_aura.visible = show
	godlike_orb_1.visible = show
	godlike_orb_2.visible = count >= 2

	if not show:
		return

	var pulse := 0.16 + abs(sin(godlike_aura_time * 3.0)) * 0.12
	var size_boost := 1.0 + float(count) * 0.18 + abs(sin(godlike_aura_time * 2.0)) * 0.08
	godlike_aura.scale = Vector2(size_boost, size_boost)
	godlike_aura.color = get_godlike_aura_color()
	godlike_aura.color.a = pulse

	var orbit := 34.0 + float(count) * 8.0
	godlike_orb_1.position = Vector2(cos(godlike_aura_time * 2.5), sin(godlike_aura_time * 2.5)) * orbit
	godlike_orb_2.position = Vector2(cos(godlike_aura_time * 2.5 + PI), sin(godlike_aura_time * 2.5 + PI)) * orbit

func get_godlike_aura_color() -> Color:
	# Later we can make this depend on item theme: infernal, frost, holy, shadow, nature, etc.
	var count := get_equipped_godlike_count()
	if count >= 2:
		return Color(1.0, 0.1, 1.0, 0.28)
	return Color(0.75, 0.2, 1.0, 0.20)

func get_equipped_godlike_count(excluding_slot: String = "") -> int:
	var count := 0
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
	var old = equipment.get(target_slot, null)
	var current_count := get_equipped_godlike_count(target_slot)
	if old != null and str(old.get("rarity", "")) == "Godlike":
		return current_count < MAX_GODLIKE_EQUIPPED
	return current_count < MAX_GODLIKE_EQUIPPED

func equip_item_to_specific_slot(index: int, slot: String) -> void:
	if index < 0 or index >= inventory.size():
		return
	if not equipment.has(slot):
		return

	var item = inventory[index]
	item = normalize_item_equipment_data(item)
	inventory[index] = item

	if not can_item_go_in_slot(item, slot):
		loot_label.text = "Wrong slot. " + item["name"] + " cannot go in " + display_slot_name(slot) + "."
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

func can_item_go_in_slot(item: Dictionary, slot: String) -> bool:
	item = normalize_item_equipment_data(item)
	if not item.has("slot"):
		return false

	if slot in ["Ring1", "Ring2"]:
		return item["slot"] == "Ring"

	if slot == "Offhand":
		if item["slot"] == "Offhand":
			return true
		if current_class == "Rogue" and item["slot"] == "Weapon" and is_one_handed_weapon(item):
			return true
		return false

	return item["slot"] == slot

func normalize_item_equipment_data(item: Dictionary) -> Dictionary:
	if item == null:
		return item

	if not item.has("weapon_type") and item.has("slot") and item["slot"] == "Weapon":
		item["weapon_type"] = infer_weapon_type(item)

	if not item.has("offhand_type") and item.has("slot") and item["slot"] == "Offhand":
		item["offhand_type"] = infer_offhand_type(item)

	return item

func infer_weapon_type(item: Dictionary) -> String:
	var n := str(item.get("name", "")).to_lower()
	if "dagger" in n or "knife" in n or "edge" in n:
		return "1H Dagger"
	if "wand" in n:
		return "1H Wand"
	if "staff" in n:
		return "2H Staff"
	if "bow" in n:
		return "2H Bow"
	if "warhammer" in n or "executioner" in n:
		return "2H Heavy"
	if "axe" in n:
		return "1H Axe"
	if "mace" in n or "hammer" in n or "scepter" in n:
		return "1H Mace"
	if "sword" in n or "blade" in n:
		return "1H Sword"
	return "1H Weapon"

func infer_offhand_type(item: Dictionary) -> String:
	var n := str(item.get("name", "")).to_lower()
	if "shield" in n or "guard" in n or "buckler" in n:
		return "Shield"
	if "tome" in n or "orb" in n or "focus" in n:
		return "Focus"
	if "quiver" in n:
		return "Quiver"
	if "dagger" in n:
		return "Offhand Dagger"
	return "Offhand"

func is_one_handed_weapon(item: Dictionary) -> bool:
	item = normalize_item_equipment_data(item)
	var wt := str(item.get("weapon_type", ""))
	return wt.begins_with("1H")

func is_rogue_dual_wielding() -> bool:
	if current_class != "Rogue":
		return false
	var main = equipment.get("Weapon", null)
	var off = equipment.get("Offhand", null)
	if main == null or off == null:
		return false
	return main.get("slot", "") == "Weapon" and off.get("slot", "") == "Weapon" and is_one_handed_weapon(main) and is_one_handed_weapon(off)

func recalculate_stats() -> void:
	# Normalize existing saved gear before stat calculation.
	for slot in equipment.keys():
		var item = equipment.get(slot, null)
		if item != null:
			equipment[slot] = normalize_item_equipment_data(item)

	super.recalculate_stats()

	if is_rogue_dual_wielding():
		attack_speed_bonus += 0.15
		crit_chance += 0.10

func generate_item(use_boss_table := false) -> Dictionary:
	var item := super.generate_item(use_boss_table)
	item = normalize_item_equipment_data(item)
	return item

func make_unique_item(boss_name: String = "") -> Dictionary:
	var item := super.make_unique_item(boss_name)
	item = normalize_item_equipment_data(item)
	return item

func update_character_ui() -> void:
	super.update_character_ui()
	if character_label == null:
		return
	if character_tab in ["Equipment", "Build"]:
		var extra := "\n\nGODLIKE POWER SLOTS: " + str(get_equipped_godlike_count()) + "/" + str(MAX_GODLIKE_EQUIPPED)
		if current_class == "Rogue":
			extra += "\nRogue Dual Wield: " + ("ACTIVE (+15% Atk Speed, +10% Crit)" if is_rogue_dual_wielding() else "Equip two 1H weapons")
		character_label.text += extra

func update_hud() -> void:
	super.update_hud()
	if hud_label != null:
		hud_label.text += "\nGodlike: " + str(get_equipped_godlike_count()) + "/" + str(MAX_GODLIKE_EQUIPPED)
		if current_class == "Rogue" and is_rogue_dual_wielding():
			hud_label.text += " | Dual Wield ACTIVE"

func item_to_text(item: Dictionary) -> String:
	item = normalize_item_equipment_data(item)
	var text := super.item_to_text(item)
	if item.has("weapon_type"):
		text += "Type: " + str(item["weapon_type"]) + "\n"
	if item.has("offhand_type"):
		text += "Type: " + str(item["offhand_type"]) + "\n"
	if str(item.get("rarity", "")) == "Godlike":
		text += "GODLIKE POWER: Counts toward the " + str(MAX_GODLIKE_EQUIPPED) + " item Godlike limit.\n"
	return text
