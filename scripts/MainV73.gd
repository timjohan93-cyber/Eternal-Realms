extends "res://scripts/MainV72.gd"

# Eternal Realms V7.3.1
# Skill Icons + Action Bar Visual Foundation
# Stable visual-only step. Gameplay input remains inherited from V7.2 for now.

var action_bar_panel: Panel
var action_bar_slots := {}
var action_bar_labels := {}

func _ready() -> void:
	super._ready()
	create_v73_action_bar()
	update_v73_action_bar()

func update_hud() -> void:
	super.update_hud()
	update_v73_action_bar()

func create_v73_action_bar() -> void:
	if hud == null:
		return
	if action_bar_panel != null and is_instance_valid(action_bar_panel):
		return

	action_bar_panel = Panel.new()
	action_bar_panel.name = "V73ActionBar"
	action_bar_panel.position = Vector2(760, 1265)
	action_bar_panel.size = Vector2(1040, 125)
	hud.add_child(action_bar_panel)

	var slots = ["LMB", "RMB", "1", "2", "3", "4", "5"]
	for i in range(slots.size()):
		var slot_name = slots[i]
		var btn := Button.new()
		btn.position = Vector2(20 + i * 140, 16)
		btn.size = Vector2(118, 92)
		btn.focus_mode = Control.FOCUS_NONE
		btn.disabled = true
		action_bar_panel.add_child(btn)
		action_bar_slots[slot_name] = btn

		var key_label := Label.new()
		key_label.position = Vector2(20 + i * 140, 96)
		key_label.size = Vector2(118, 22)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.text = slot_name
		action_bar_panel.add_child(key_label)
		action_bar_labels[slot_name] = key_label

func update_v73_action_bar() -> void:
	if action_bar_panel == null or not is_instance_valid(action_bar_panel):
		return

	set_action_slot_text("LMB", "M\nMove")

	var slots = ["RMB", "1", "2", "3", "4", "5"]
	for slot_name in slots:
		var skill_index: int = get_combat_slot_skill_index(slot_name)
		var skill = get_skill(skill_index)
		var rank: int = get_skill_rank(skill_index)
		var icon: String = get_skill_icon(str(skill["name"]))
		var short_name: String = str(skill["name"]).substr(0, 8)
		var rank_text: String = "R" + str(rank)
		if rank <= 0:
			rank_text = "LOCK"
		set_action_slot_text(slot_name, icon + "\n" + short_name + "\n" + rank_text)

func set_action_slot_text(slot_name: String, text: String) -> void:
	if not action_bar_slots.has(slot_name):
		return
	var btn: Button = action_bar_slots[slot_name]
	btn.text = text
	btn.tooltip_text = get_action_slot_tooltip(slot_name)

func get_action_slot_tooltip(slot_name: String) -> String:
	if slot_name == "LMB":
		return "Left Mouse Button\nMove / Interact / Basic Attack"
	var skill_index: int = get_combat_slot_skill_index(slot_name)
	var skill = get_skill(skill_index)
	var text: String = slot_name + " - " + str(skill["name"]) + "\n"
	text += "Category: " + str(skill.get("category", "Skill")) + "\n"
	text += "Mana: " + str(get_skill_cost(skill_index)) + "\n"
	text += "Cooldown: " + str(get_skill_cooldown(skill_index)) + "s\n"
	text += "Rank: " + str(get_skill_rank(skill_index)) + "/20"
	return text

func get_skill_icon(skill_name: String) -> String:
	match skill_name:
		"Cleave":
			return "SW"
		"Charge":
			return "CH"
		"Ground Slam":
			return "GS"
		"Ragnarok":
			return "RG"
		"Whirlwind":
			return "WW"
		"Leap":
			return "LP"
		"War Cry":
			return "WC"
		"Execute":
			return "EX"
		"Poison Arrow":
			return "PA"
		"Dash":
			return "DS"
		"Fan of Knives":
			return "FK"
		"Endless Barrage":
			return "EB"
		"Quick Shot":
			return "QS"
		"Shadow Step":
			return "SS"
		"Rain of Arrows":
			return "RA"
		"Smoke Bomb":
			return "SB"
		"Smite":
			return "SM"
		"Heal":
			return "HL"
		"Consecration":
			return "CO"
		"Final Judgment":
			return "FJ"
		"Holy Shield":
			return "HS"
		"Blessed Hammer":
			return "BH"
		"Judgement":
			return "JD"
		"Radiant Charge":
			return "RC"
		"Fireball":
			return "FB"
		"Teleport":
			return "TP"
		"Ice Nova":
			return "IN"
		"Apocalypse":
			return "AP"
		"Lightning Bolt":
			return "LB"
		"Meteor":
			return "MT"
		"Arcane Nova":
			return "AN"
		"Mana Surge":
			return "MS"
	return "SK"

func update_potion_belt_ui() -> void:
	# V7.3 uses the new visual action bar. Keep the old potion belt compact.
	if potion_belt_label == null:
		return
	potion_belt_label.text = "Potions: Q Health " + str(health_potions) + "/" + str(max_health_potions) + "    E Mana " + str(mana_potions) + "/" + str(max_mana_potions)
