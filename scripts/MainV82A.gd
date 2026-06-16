extends "res://scripts/MainV81A.gd"

# Eternal Realms V8.2A
# Starter Gear Foundation
# Visible hero gear is now backed by real equipped starter items.

var v82_starter_gear_applied := false

func _ready() -> void:
	super._ready()
	ensure_v82_starter_gear(false)

func start_v79_game() -> void:
	super.start_v79_game()
	ensure_v82_starter_gear(true)
	apply_v81_character_body(current_class)
	update_hud()
	update_inventory_ui()
	update_character_ui()

func change_class() -> void:
	super.change_class()
	ensure_v82_starter_gear(false)
	apply_v81_character_body(current_class)
	update_hud()
	update_inventory_ui()
	update_character_ui()

func ensure_v82_starter_gear(show_message: bool = false) -> void:
	if current_class == "":
		return

	var added := false
	var starter_set := get_v82_class_starter_set(current_class)
	for slot in starter_set.keys():
		if not equipment.has(slot):
			continue
		if equipment.get(slot, null) == null:
			equipment[slot] = starter_set[slot]
			added = true

	if added:
		recalculate_stats()
		hp = max_hp
		mana = max_mana
		v82_starter_gear_applied = true
		if show_message and loot_label != null:
			loot_label.text = current_class + " equipped starter gear. This is real Common gear, not just visual armor."
		save_game()

func get_v82_class_starter_set(class_id: String) -> Dictionary:
	match class_id:
		"Paladin":
			return {
				"Helmet": make_v82_item("Initiate Helm", "Helmet", {"Armor": 3, "Willpower": 1}),
				"Chest": make_v82_item("Initiate Plate", "Chest", {"Armor": 7, "Health": 18}),
				"Weapon": make_v82_item("Rusted Mace", "Weapon", {"Damage": 4, "Willpower": 1}),
				"Offhand": make_v82_item("Wooden Kite Shield", "Offhand", {"Armor": 5, "Health": 10}),
				"Boots": make_v82_item("Traveler Boots", "Boots", {"Armor": 2, "Movement Speed": 3})
			}
		"Warrior":
			return {
				"Helmet": make_v82_item("Worn Iron Helm", "Helmet", {"Armor": 3, "Strength": 1}),
				"Chest": make_v82_item("Dented Breastplate", "Chest", {"Armor": 8, "Health": 15}),
				"Weapon": make_v82_item("Chipped Sword", "Weapon", {"Damage": 5, "Strength": 1}),
				"Offhand": make_v82_item("Cracked Round Shield", "Offhand", {"Armor": 4, "Health": 8}),
				"Boots": make_v82_item("Heavy Boots", "Boots", {"Armor": 3})
			}
		"Rogue":
			return {
				"Helmet": make_v82_item("Tattered Hood", "Helmet", {"Armor": 1, "Dexterity": 2}),
				"Chest": make_v82_item("Scavenger Leather", "Chest", {"Armor": 4, "Dexterity": 1}),
				"Weapon": make_v82_item("Rusty Dagger", "Weapon", {"Damage": 4, "Crit Chance": 2}),
				"Offhand": make_v82_item("Old Shiv", "Offhand", {"Damage": 2, "Dexterity": 1}),
				"Boots": make_v82_item("Soft Boots", "Boots", {"Movement Speed": 5})
			}
		"Mage":
			return {
				"Helmet": make_v82_item("Apprentice Hood", "Helmet", {"Mana": 12, "Intellect": 1}),
				"Chest": make_v82_item("Threadbare Robe", "Chest", {"Mana": 20, "Armor": 1}),
				"Weapon": make_v82_item("Cracked Staff", "Weapon", {"Damage": 4, "Intellect": 2}),
				"Offhand": make_v82_item("Faint Arcane Orb", "Offhand", {"Mana": 15, "Cooldown Reduction": 1}),
				"Boots": make_v82_item("Cloth Sandals", "Boots", {"Movement Speed": 3})
			}
		"Ranger":
			return {
				"Helmet": make_v82_item("Hunter Hood", "Helmet", {"Armor": 1, "Dexterity": 1}),
				"Chest": make_v82_item("Worn Hide Vest", "Chest", {"Armor": 4, "Health": 8}),
				"Weapon": make_v82_item("Short Hunting Bow", "Weapon", {"Damage": 4, "Dexterity": 2}),
				"Offhand": make_v82_item("Frayed Quiver", "Offhand", {"Crit Chance": 1, "Dexterity": 1}),
				"Boots": make_v82_item("Trail Boots", "Boots", {"Movement Speed": 4})
			}
	return get_v82_class_starter_set("Warrior")

func make_v82_item(item_name: String, slot_name: String, stats: Dictionary) -> Dictionary:
	return {
		"name": item_name,
		"slot": slot_name,
		"rarity": "Common",
		"level": 1,
		"value": 1,
		"stats": stats,
		"power_id": "",
		"power_name": "",
		"power_desc": "",
		"starter_item": true
	}

func item_to_text(item: Dictionary) -> String:
	var text := super.item_to_text(item)
	if bool(item.get("starter_item", false)):
		text += "Starter Gear: Basic equipment granted to new heroes. Replace it with loot as soon as you find upgrades.\n"
	return text
