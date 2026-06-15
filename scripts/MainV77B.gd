extends "res://scripts/MainV77A.gd"

# Eternal Realms V7.7B
# XP Balance Foundation
# Centralizes XP gain and XP-to-next-level tuning.

const XP_KILL_MULTIPLIER: float = 0.32
const XP_MIN_KILL_GAIN: int = 1
const XP_LEVEL_BASE: int = 120
const XP_LEVEL_POWER: float = 1.72
const XP_LEVEL_FLAT_PER_LEVEL: int = 45
const XP_PARAGON_BASE: int = 3600
const XP_PARAGON_POWER: float = 1.35
const XP_SHOW_DEBUG_IN_HUD: bool = true

func _ready() -> void:
	super._ready()
	refresh_xp_to_next_from_balance()
	update_hud()

func refresh_xp_to_next_from_balance() -> void:
	if level < 40:
		xp_to_next = get_xp_required_for_level(level)
	else:
		xp_to_next = get_xp_required_for_paragon(paragon_level)

func get_xp_required_for_level(current_level: int) -> int:
	# XP required to go from current_level to current_level + 1.
	# Change these constants at the top of this file to tune pacing.
	var lvl: int = max(1, current_level)
	var curved: float = float(XP_LEVEL_BASE) * pow(float(lvl), XP_LEVEL_POWER)
	var flat: int = lvl * XP_LEVEL_FLAT_PER_LEVEL
	return int(curved) + flat

func get_xp_required_for_paragon(current_paragon: int) -> int:
	var p: int = max(0, current_paragon)
	return XP_PARAGON_BASE + int(pow(float(p + 1), XP_PARAGON_POWER) * 450.0)

func calculate_xp_gain(raw_amount: int, source: String = "kill") -> int:
	if source == "quest":
		return max(1, raw_amount)
	if source == "boss_quest":
		return max(1, raw_amount)
	var scaled: int = int(round(float(raw_amount) * XP_KILL_MULTIPLIER))
	return max(XP_MIN_KILL_GAIN, scaled)

func gain_xp(amount: int) -> void:
	var final_amount: int = calculate_xp_gain(amount, "kill")
	xp += final_amount
	spawn_floating_text("+" + str(final_amount) + " XP", player.position + Vector2(0, -80), true)

	while xp >= xp_to_next:
		xp -= xp_to_next
		level_up()

	update_hud()

func grant_quest_xp(amount: int, label: String = "Quest Complete") -> void:
	var final_amount: int = calculate_xp_gain(amount, "quest")
	xp += final_amount
	loot_label.text = label + "\n+" + str(final_amount) + " XP"
	while xp >= xp_to_next:
		xp -= xp_to_next
		level_up()
	update_hud()
	save_game()

func level_up() -> void:
	if level < 40:
		level += 1
		xp_to_next = get_xp_required_for_level(level)
		apply_class_base_stats()
		recalculate_stats()
		hp = max_hp
		mana = max_mana
		loot_label.text = "LEVEL UP! You are now level " + str(level)
	else:
		paragon_level += 1
		paragon_points += 1
		xp_to_next = get_xp_required_for_paragon(paragon_level)
		base_damage += 1
		base_hp += 4
		recalculate_stats()
		hp = max_hp
		loot_label.text = "PARAGON UP! Paragon level " + str(paragon_level)

func update_hud() -> void:
	super.update_hud()
	if XP_SHOW_DEBUG_IN_HUD and hud_label != null:
		hud_label.text += "\nXP Balance: kills x" + str(XP_KILL_MULTIPLIER) + " | Next: " + str(xp_to_next)

func update_v77a_panels() -> void:
	super.update_v77a_panels()
	if v77a_right_label != null and character_open:
		v77a_right_label.text += "\n\nXP BALANCE\n\n"
		v77a_right_label.text += "Kill XP Multiplier: x" + str(XP_KILL_MULTIPLIER) + "\n"
		v77a_right_label.text += "Next Level XP: " + str(xp_to_next) + "\n"
		v77a_right_label.text += "Quest XP is unscaled."
