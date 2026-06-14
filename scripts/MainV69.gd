extends "res://scripts/Main.gd"

# Eternal Realms V6.9
# Skill Book + 6-slot Action Bar Overhaul
# This script extends the current Main.gd so we can keep the stable V6.8 base intact.

var selected_skill_book_index := 0

func _ready() -> void:
	super._ready()
	normalize_v69_action_bar()
	update_hud()
	update_character_ui()

func normalize_v69_action_bar() -> void:
	var defaults := {"RMB": 0, "1": 0, "2": 1, "3": 2, "4": 3, "5": 4}
	for slot in defaults.keys():
		if not combat_skill_slots.has(slot):
			combat_skill_slots[slot] = defaults[slot]
		if not combat_slot_last_used.has(slot):
			combat_slot_last_used[slot] = -999.0
	if not is_skill_book_index_valid(selected_skill_book_index):
		selected_skill_book_index = 0

func handle_input() -> void:
	# Skill Book tab gets its own hotkeys so players can freely assign many abilities.
	if character_open and character_tab == "Skills":
		if key_just_pressed(KEY_ESCAPE):
			toggle_game_menu()
			return

		var select_keys = [KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8]
		for si in range(min(select_keys.size(), get_skill_count())):
			if key_just_pressed(select_keys[si]):
				select_skill_book_index(si)
				return

		if key_just_pressed(KEY_KP_ADD) or key_just_pressed(KEY_EQUAL):
			rank_up_skill(selected_skill_book_index)
			return
		if key_just_pressed(KEY_KP_SUBTRACT) or key_just_pressed(KEY_MINUS):
			rank_down_skill(selected_skill_book_index)
			return

		if key_just_pressed(KEY_Z):
			assign_selected_skill_to_slot("RMB")
			return
		if key_just_pressed(KEY_X):
			assign_selected_skill_to_slot("1")
			return
		if key_just_pressed(KEY_C):
			assign_selected_skill_to_slot("2")
			return
		if key_just_pressed(KEY_V):
			assign_selected_skill_to_slot("3")
			return
		if key_just_pressed(KEY_B):
			assign_selected_skill_to_slot("4")
			return
		if key_just_pressed(KEY_N):
			assign_selected_skill_to_slot("5")
			return

	# Let the stable base handle normal gameplay, UI, vendors, movement and slots 1-4.
	super.handle_input()

	# V6.9 adds the fifth number-key active ability slot.
	if key_just_pressed(KEY_5):
		if not inventory_open and not merchant_open and not blacksmith_open and not mystic_open and not dev_open and not game_menu_open:
			use_combat_slot("5")

func get_class_skill_book() -> Array:
	var books = {
		"Warrior": [
			{"name":"Cleave", "cost":8, "cooldown":1.0, "mult":1.8, "range":80, "type":"damage", "category":"Basic"},
			{"name":"Charge", "cost":12, "cooldown":3.0, "mult":2.4, "range":180, "type":"dash", "category":"Core"},
			{"name":"Ground Slam", "cost":18, "cooldown":5.0, "mult":3.0, "range":120, "type":"damage", "category":"Core"},
			{"name":"Ragnarok", "cost":35, "cooldown":10.0, "mult":6.0, "range":220, "type":"ultimate", "category":"Ultimate"},
			{"name":"Whirlwind", "cost":16, "cooldown":2.0, "mult":2.2, "range":110, "type":"damage", "category":"Core"},
			{"name":"Leap", "cost":14, "cooldown":4.0, "mult":2.6, "range":190, "type":"dash_damage", "category":"Mobility"},
			{"name":"War Cry", "cost":20, "cooldown":8.0, "mult":0.0, "range":0, "type":"buff_damage", "category":"Buff"},
			{"name":"Execute", "cost":22, "cooldown":5.0, "mult":4.2, "range":75, "type":"damage", "category":"Finisher"}
		],
		"Rogue": [
			{"name":"Poison Arrow", "cost":8, "cooldown":1.0, "mult":1.9, "range":260, "type":"damage", "category":"Basic"},
			{"name":"Dash", "cost":10, "cooldown":2.5, "mult":1.2, "range":200, "type":"dash", "category":"Mobility"},
			{"name":"Fan of Knives", "cost":18, "cooldown":4.0, "mult":2.8, "range":130, "type":"damage", "category":"Core"},
			{"name":"Endless Barrage", "cost":32, "cooldown":9.0, "mult":5.5, "range":300, "type":"ultimate", "category":"Ultimate"},
			{"name":"Quick Shot", "cost":7, "cooldown":0.8, "mult":1.5, "range":260, "type":"damage", "category":"Basic"},
			{"name":"Shadow Step", "cost":14, "cooldown":3.5, "mult":2.5, "range":220, "type":"dash_damage", "category":"Mobility"},
			{"name":"Rain of Arrows", "cost":24, "cooldown":6.0, "mult":3.8, "range":320, "type":"damage", "category":"Core"},
			{"name":"Smoke Bomb", "cost":18, "cooldown":7.0, "mult":0.0, "range":0, "type":"buff_speed", "category":"Utility"}
		],
		"Paladin": [
			{"name":"Smite", "cost":8, "cooldown":1.0, "mult":1.8, "range":100, "type":"damage", "category":"Basic"},
			{"name":"Heal", "cost":16, "cooldown":5.0, "mult":0.0, "range":0, "type":"heal", "category":"Holy"},
			{"name":"Consecration", "cost":22, "cooldown":5.0, "mult":3.0, "range":150, "type":"damage", "category":"Core"},
			{"name":"Final Judgment", "cost":36, "cooldown":10.0, "mult":6.2, "range":240, "type":"ultimate", "category":"Ultimate"},
			{"name":"Holy Shield", "cost":18, "cooldown":7.0, "mult":0.0, "range":0, "type":"buff_armor", "category":"Defense"},
			{"name":"Blessed Hammer", "cost":18, "cooldown":3.0, "mult":2.7, "range":160, "type":"damage", "category":"Core"},
			{"name":"Judgement", "cost":20, "cooldown":4.5, "mult":3.5, "range":220, "type":"damage", "category":"Core"},
			{"name":"Radiant Charge", "cost":16, "cooldown":4.0, "mult":2.8, "range":190, "type":"dash_damage", "category":"Mobility"}
		],
		"Mage": [
			{"name":"Fireball", "cost":10, "cooldown":1.0, "mult":2.1, "range":300, "type":"damage", "category":"Basic"},
			{"name":"Teleport", "cost":14, "cooldown":3.0, "mult":0.0, "range":200, "type":"dash", "category":"Mobility"},
			{"name":"Ice Nova", "cost":22, "cooldown":5.0, "mult":3.2, "range":160, "type":"damage", "category":"Core"},
			{"name":"Apocalypse", "cost":42, "cooldown":11.0, "mult":7.0, "range":330, "type":"ultimate", "category":"Ultimate"},
			{"name":"Lightning Bolt", "cost":11, "cooldown":1.2, "mult":2.0, "range":330, "type":"damage", "category":"Basic"},
			{"name":"Meteor", "cost":28, "cooldown":6.0, "mult":4.3, "range":320, "type":"damage", "category":"Core"},
			{"name":"Arcane Nova", "cost":20, "cooldown":4.0, "mult":2.9, "range":175, "type":"damage", "category":"Core"},
			{"name":"Mana Surge", "cost":0, "cooldown":8.0, "mult":0.0, "range":0, "type":"buff_mana", "category":"Buff"}
		]
	}
	return books[current_class]

func get_skill(index: int) -> Dictionary:
	var book = get_class_skill_book()
	if book.size() == 0:
		return {"name":"Missing Skill", "cost":0, "cooldown":1.0, "mult":1.0, "range":80, "type":"damage", "category":"Unknown"}
	index = clamp(index, 0, book.size() - 1)
	return book[index]

func get_skill_count() -> int:
	return get_class_skill_book().size()

func is_skill_book_index_valid(index: int) -> bool:
	return index >= 0 and index < get_skill_count()

func get_skill_key(index: int) -> String:
	return "Skill_" + str(index)

func get_skill_rank(index: int) -> int:
	var key = get_skill_key(index)
	if skill_ranks.has(key):
		return int(skill_ranks[key])
	if index == 0:
		return 1
	return 0

func get_combat_slot_skill_index(slot_name: String) -> int:
	normalize_v69_action_bar()
	var idx = int(combat_skill_slots.get(slot_name, 0))
	if not is_skill_book_index_valid(idx):
		return 0
	return idx

func use_combat_slot(slot_name: String) -> void:
	var index = get_combat_slot_skill_index(slot_name)
	if not is_skill_book_index_valid(index):
		return

	if get_skill_rank(index) <= 0:
		loot_label.text = slot_name + " skill has rank 0. Open Skills tab and invest a skill point."
		return

	var now := Time.get_ticks_msec() / 1000.0
	var cd = get_skill_cooldown(index)
	var last = float(combat_slot_last_used.get(slot_name, -999.0))
	if now - last < cd:
		return

	combat_slot_last_used[slot_name] = now
	use_skill(index)

func assign_skill_to_combat_slot(skill_index: int, slot_name: String) -> void:
	if not is_skill_book_index_valid(skill_index):
		return
	normalize_v69_action_bar()
	if not combat_skill_slots.has(slot_name):
		return
	combat_skill_slots[slot_name] = skill_index
	loot_label.text = "Assigned " + get_skill(skill_index)["name"] + " to " + slot_name + "."
	update_hud()
	update_character_ui()
	save_game()

func select_skill_book_index(index: int) -> void:
	if not is_skill_book_index_valid(index):
		return
	selected_skill_book_index = index
	var skill = get_skill(index)
	loot_label.text = "Selected skill: " + skill["name"] + ". Use assignment hotkeys in Skills tab."
	update_character_ui()

func assign_selected_skill_to_slot(slot_name: String) -> void:
	if not is_skill_book_index_valid(selected_skill_book_index):
		return
	assign_skill_to_combat_slot(selected_skill_book_index, slot_name)

func get_slot_assignment_text() -> String:
	var text := "ACTION BAR ASSIGNMENTS\n"
	var slots = ["RMB", "1", "2", "3", "4", "5"]
	for slot in slots:
		var idx = get_combat_slot_skill_index(slot)
		if is_skill_book_index_valid(idx):
			text += slot + " = " + get_skill(idx)["name"] + "\n"
		else:
			text += slot + " = Empty\n"
	return text

func use_skill(index: int) -> void:
	if get_skill_rank(index) <= 0:
		loot_label.text = "Skill has rank 0. Open Skills tab and invest a skill point."
		return

	var skill := get_skill(index)
	if mana < get_skill_cost(index):
		return

	mana -= get_skill_cost(index)

	if skill["type"] == "dash":
		player.position = player.position.move_toward(get_global_mouse_position(), 160)
	elif skill["type"] == "dash_damage":
		player.position = player.position.move_toward(get_global_mouse_position(), 170)
	elif skill["type"] == "heal":
		hp = min(max_hp, hp + int(max_hp * 0.35))
		spawn_floating_text("HEAL", player.position + Vector2(0, -35), true)
	elif skill["type"] == "buff_damage":
		active_flask_effects.append({"kind": "Berserker", "time": 5.0})
		spawn_floating_text("WAR CRY", player.position + Vector2(0, -35), true)
	elif skill["type"] == "buff_armor":
		active_flask_effects.append({"kind": "Iron Skin", "time": 5.0})
		spawn_floating_text("SHIELD", player.position + Vector2(0, -35), true)
	elif skill["type"] == "buff_speed":
		active_flask_effects.append({"kind": "Shadow", "time": 5.0})
		spawn_floating_text("SPEED", player.position + Vector2(0, -35), true)
	elif skill["type"] == "buff_mana":
		mana = min(max_mana, mana + int(max_mana * 0.35))
		spawn_floating_text("MANA", player.position + Vector2(0, -35), true)
	else:
		var echo = has_power("arcane_echo") or has_power("spirit_charm")
		for e in enemies.duplicate():
			if is_instance_valid(e["body"]) and player.position.distance_to(e["body"].position) <= skill["range"]:
				var result = calculate_damage_result(get_skill_mult(index))
				damage_enemy(e, result["amount"], result["crit"])
				if echo and randf() < 0.20:
					var result2 = calculate_damage_result(get_skill_mult(index) * 0.75)
					damage_enemy(e, result2["amount"], result2["crit"])

	loot_label.text = "Used skill: " + skill["name"]
	update_hud()

func update_character_ui() -> void:
	if character_label == null:
		return

	normalize_v69_action_bar()

	for tab in character_tab_buttons.keys():
		var btn: Button = character_tab_buttons[tab]
		btn.text = ("* " if tab == character_tab else "") + tab

	for slot in equipment_buttons.keys():
		var btn: Button = equipment_buttons[slot]
		btn.visible = character_tab == "Equipment"
		var item = equipment.get(slot, null)
		if item == null:
			btn.text = display_slot_name(slot) + "\nEmpty"
			btn.tooltip_text = display_slot_name(slot) + " empty"
		else:
			btn.text = display_slot_name(slot) + "\n" + item["name"].substr(0, 14)
			btn.tooltip_text = item_to_text(item)

	if selected_item_label != null:
		selected_item_label.visible = character_tab == "Equipment"
		if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
			var selected = inventory[selected_inventory_index]
			selected_item_label.text = "Selected: " + selected["name"] + " [" + selected["rarity"] + "] | Slot: " + selected["slot"]
		else:
			selected_item_label.text = "Selected: None"

	var text := ""
	if character_tab == "Equipment":
		text = "Equipment: click inventory item, then matching slot.\nHold SHIFT and click equipped slot to unequip."

	elif character_tab == "Skills":
		if not is_skill_book_index_valid(selected_skill_book_index):
			selected_skill_book_index = 0
		text += "SKILL BOOK - V6.9\n"
		text += "Skill Points: " + str(skill_points) + "\n"
		text += "Selected: " + get_skill(selected_skill_book_index)["name"] + "\n\n"
		text += "Select skill: F1-F8\n"
		text += "Rank selected: + / refund with -\n"
		text += "Assign selected: Z=RMB, X=1, C=2, V=3, B=4, N=5\n\n"

		var book = get_class_skill_book()
		for i in range(book.size()):
			var sk = book[i]
			var rank = get_skill_rank(i)
			var marker = "> " if i == selected_skill_book_index else "  "
			text += marker + "F" + str(i + 1) + " " + sk["name"] + " [" + sk["category"] + "] Rank " + str(rank) + "/20\n"
			text += "    Mana " + str(get_skill_cost(i)) + " | CD " + str(get_skill_cooldown(i)) + "s | Power " + str(int(get_skill_mult(i) * 100)) + "%\n"

		text += "\n" + get_slot_assignment_text()

	elif character_tab == "Passives":
		text += "PASSIVES\n"
		text += "Passive Points: " + str(passive_points) + "\n"
		text += "Press Q/W/E/R/T/Y to rank passives.\n"
		text += "Hold SHIFT + key to refund.\n\n"
		var keys = ["Q", "W", "E", "R", "T", "Y"]
		var names = passive_ranks.keys()
		for i in range(names.size()):
			var name = names[i]
			text += keys[i] + ") " + name + " " + str(passive_ranks[name]) + "/10\n"

	elif character_tab == "Paragon":
		text += "PARAGON\n"
		if level < 40:
			text += "Locked. Reach level 40 to unlock Paragon.\n"
		else:
			text += "Paragon Level: " + str(paragon_level) + "\n"
			text += "Paragon Points: " + str(paragon_points) + "\n\n"
			text += "Future constellations:\nStorm | Fire | Blood | Shadow | Holy | Nature\n"

	elif character_tab == "Build":
		text += get_build_analysis()

	character_label.text = text

	if stat_summary_label != null:
		stat_summary_label.visible = character_tab in ["Equipment", "Build"]
		var stats_text := "STAT SUMMARY\n"
		stats_text += "STR %d | DEX %d | INT %d | WIL %d\n" % [strength, dexterity, intellect, willpower]
		stats_text += "Damage %d | Armor %d | Crit %d%% | Crit Dmg %d%%\n" % [damage, armor, int(crit_chance * 100), int(crit_damage * 100)]
		stats_text += "Atk Spd +%d%% | CDR %d%% | Move %d | Pickup +%d\n" % [int(attack_speed_bonus * 100), int(cooldown_reduction * 100), int(move_speed), int(pickup_radius)]
		stats_text += "HP %d/%d (+%d/s) | Mana %d/%d (+%d/s)\n" % [hp, max_hp, int(health_regen), mana, max_mana, int(mana_regen)]
		stats_text += "Magic Find %d%% | Gold Find %d%%" % [int(magic_find_bonus * 100), int(gold_find_bonus * 100)]
		stat_summary_label.text = stats_text

func update_hud() -> void:
	normalize_v69_action_bar()
	var skill_text := "LMB:Interact/Move  "
	var rmb_index = get_combat_slot_skill_index("RMB")
	skill_text += "RMB:" + get_skill(rmb_index)["name"] + (" " if get_skill_rank(rmb_index) > 0 else " R0 ") + "  "
	for i in range(5):
		var slot_name = str(i + 1)
		var skill_index = get_combat_slot_skill_index(slot_name)
		var skill = get_skill(skill_index)
		skill_text += slot_name + ":" + skill["name"] + (" " if get_skill_rank(skill_index) > 0 else " R0 ") + "  "

	var flask_text := ""
	for f in active_flask_effects:
		flask_text += f["kind"] + " " + str(int(f["time"])) + "s  "

	hud_label.text = "Class: %s | Theme: %s | Gold: %d\nLevel: %d | XP: %d/%d | Paragon: %d | Points: %d | SkillPts: %d | PassivePts: %d\nHP: %d/%d (+%d/s) | Mana: %d/%d (+%d/s) | Damage: %d | Armor: %d | Crit: %d%% | AtkSpd: %d%% | CDR: %d%% | Pickup: +%d\n%s\n%s" % [
		current_class,
		current_theme,
		gold,
		level,
		xp,
		xp_to_next,
		paragon_level,
		paragon_points,
		skill_points,
		passive_points,
		hp,
		max_hp,
		int(health_regen),
		mana,
		max_mana,
		int(mana_regen),
		damage,
		armor,
		int(crit_chance * 100),
		int(attack_speed_bonus * 100),
		int(cooldown_reduction * 100),
		int(pickup_radius),
		skill_text,
		flask_text
	]
	update_potion_belt_ui()

func update_potion_belt_ui() -> void:
	if potion_belt_label == null:
		return
	normalize_v69_action_bar()
	var hp_slots = min(health_potions, 4 + potion_capacity_bonus)
	var mp_slots = min(mana_potions, 4 + potion_capacity_bonus)
	var belt_text := "Q "
	for i in range(hp_slots):
		belt_text += "[HP]"
	if hp_slots == 0:
		belt_text += "[--]"
	belt_text += "     "

	var rmb_skill = get_skill(get_combat_slot_skill_index("RMB"))
	belt_text += "[RMB " + rmb_skill["name"].substr(0, 5) + "]"
	for i in range(5):
		var slot_name = str(i + 1)
		var skill = get_skill(get_combat_slot_skill_index(slot_name))
		belt_text += "[" + slot_name + " " + skill["name"].substr(0, 5) + "]"

	belt_text += "     "
	for i in range(mp_slots):
		belt_text += "[MP]"
	if mp_slots == 0:
		belt_text += "[--]"
	belt_text += " E"
	potion_belt_label.text = belt_text

func change_class() -> void:
	class_index = (class_index + 1) % classes.size()
	current_class = classes[class_index]
	selected_skill_book_index = 0
	combat_skill_slots = {"RMB": 0, "1": 0, "2": 1, "3": 2, "4": 3, "5": 4}
	apply_class_base_stats()
	recalculate_stats()
	loot_label.text = "Changed class to " + current_class
	update_hud()
	update_inventory_ui()
	update_character_ui()
	save_game()

func load_game() -> void:
	super.load_game()
	normalize_v69_action_bar()

func reset_save() -> void:
	super.reset_save()
	combat_skill_slots = {"RMB": 0, "1": 0, "2": 1, "3": 2, "4": 3, "5": 4}
	selected_skill_book_index = 0
	update_hud()
	update_character_ui()
	save_game()
