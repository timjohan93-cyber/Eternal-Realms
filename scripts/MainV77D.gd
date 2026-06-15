extends "res://scripts/MainV77C.gd"

# Eternal Realms V7.7D
# Loot Visuals Foundation
# Adds rarity-colored equipment slot visuals and basic equipped rarity summary.

var rarity_colors := {
	"Common": Color(0.55, 0.55, 0.55, 1.0),
	"Magic": Color(0.25, 0.45, 1.0, 1.0),
	"Rare": Color(1.0, 0.86, 0.2, 1.0),
	"Legendary": Color(1.0, 0.48, 0.08, 1.0),
	"Unique": Color(0.65, 0.35, 1.0, 1.0),
	"Godlike": Color(1.0, 0.1, 0.95, 1.0)
}

var rarity_text_prefix := {
	"Common": "COM",
	"Magic": "MAG",
	"Rare": "RAR",
	"Legendary": "LEG",
	"Unique": "UNI",
	"Godlike": "GOD"
}

func _ready() -> void:
	super._ready()
	update_loot_visuals()

func get_rarity_color(rarity: String) -> Color:
	if rarity_colors.has(rarity):
		return rarity_colors[rarity]
	return Color(0.38, 0.38, 0.38, 1.0)

func get_rarity_prefix(rarity: String) -> String:
	if rarity_text_prefix.has(rarity):
		return rarity_text_prefix[rarity]
	return "---"

func get_equipped_rarity_counts() -> Dictionary:
	var counts := {
		"Common": 0,
		"Magic": 0,
		"Rare": 0,
		"Legendary": 0,
		"Unique": 0,
		"Godlike": 0
	}
	for slot_name in equipment.keys():
		var item = equipment.get(slot_name, null)
		if item == null:
			continue
		var rarity := str(item.get("rarity", "Common"))
		if not counts.has(rarity):
			counts[rarity] = 0
		counts[rarity] += 1
	return counts

func update_loot_visuals() -> void:
	if character_preview_slots == null:
		return
	for slot_name in character_preview_slots.keys():
		if not character_preview_slots.has(slot_name):
			continue
		var btn: Button = character_preview_slots[slot_name]
		if btn == null or not is_instance_valid(btn):
			continue
		var item = equipment.get(slot_name, null)
		if item == null:
			btn.modulate = Color(0.42, 0.42, 0.42, 1.0)
			btn.self_modulate = Color(0.42, 0.42, 0.42, 1.0)
			continue
		var rarity := str(item.get("rarity", "Common"))
		var color := get_rarity_color(rarity)
		btn.modulate = color
		btn.self_modulate = color
		if rarity == "Godlike":
			btn.modulate = Color(1.0, 0.35, 1.0, 1.0)

func update_v76_character_preview() -> void:
	super.update_v76_character_preview()
	update_loot_visuals()
	for slot_name in character_preview_slots.keys():
		var btn: Button = character_preview_slots[slot_name]
		if btn == null or not is_instance_valid(btn):
			continue
		var item = equipment.get(slot_name, null)
		var icon: String = get_icon("item_slot", slot_name, "ITM")
		if item == null:
			btn.text = icon + "\nEmpty"
		else:
			var rarity := str(item.get("rarity", "Common"))
			var prefix := get_rarity_prefix(rarity)
			btn.text = prefix + " " + icon + "\n" + str(item.get("name", "Item")).substr(0, 12)

func update_v77a_panels() -> void:
	super.update_v77a_panels()
	if not character_open:
		return
	if v77a_right_label != null:
		var counts := get_equipped_rarity_counts()
		v77a_right_label.text += "\n\nEQUIPPED RARITY\n\n"
		v77a_right_label.text += "Common: " + str(counts.get("Common", 0)) + "\n"
		v77a_right_label.text += "Magic: " + str(counts.get("Magic", 0)) + "\n"
		v77a_right_label.text += "Rare: " + str(counts.get("Rare", 0)) + "\n"
		v77a_right_label.text += "Legendary: " + str(counts.get("Legendary", 0)) + "\n"
		v77a_right_label.text += "Unique: " + str(counts.get("Unique", 0)) + "\n"
		v77a_right_label.text += "Godlike: " + str(counts.get("Godlike", 0)) + "\n"

func equip_selected_to_slot(slot_name: String) -> void:
	super.equip_selected_to_slot(slot_name)
	update_loot_visuals()

func unequip_slot(slot_name: String) -> void:
	super.unequip_slot(slot_name)
	update_loot_visuals()

func update_character_ui() -> void:
	super.update_character_ui()
	update_loot_visuals()
