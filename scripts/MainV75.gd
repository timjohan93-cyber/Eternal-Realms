extends "res://scripts/MainV74.gd"

# Eternal Realms V7.5.0
# Keybind Options Menu Foundation
# Adds an Options/Keybinds panel and a safe ARPG default preset.

var keybind_panel: Panel
var keybind_label: Label
var keybind_buttons := {}

var keybinds := {
	"RMB Skill": "RMB",
	"Skill 1": "Q",
	"Skill 2": "W",
	"Skill 3": "E",
	"Ultimate": "R",
	"Health Potion": "1",
	"Mana Potion": "2"
}

func _ready() -> void:
	super._ready()
	apply_v75_default_action_bar()
	create_v75_keybind_panel()
	update_v75_keybind_panel()
	update_hud()
	update_v73_action_bar()

func apply_v75_default_action_bar() -> void:
	# Keep old assignments but expose them through the preferred ARPG layout.
	if not combat_skill_slots.has("Q"):
		combat_skill_slots["Q"] = int(combat_skill_slots.get("1", 0))
	if not combat_skill_slots.has("W"):
		combat_skill_slots["W"] = int(combat_skill_slots.get("2", 1))
	if not combat_skill_slots.has("E"):
		combat_skill_slots["E"] = int(combat_skill_slots.get("3", 2))
	if not combat_skill_slots.has("R"):
		combat_skill_slots["R"] = int(combat_skill_slots.get("4", 3))
	if not combat_slot_last_used.has("Q"):
		combat_slot_last_used["Q"] = -999.0
	if not combat_slot_last_used.has("W"):
		combat_slot_last_used["W"] = -999.0
	if not combat_slot_last_used.has("E"):
		combat_slot_last_used["E"] = -999.0
	if not combat_slot_last_used.has("R"):
		combat_slot_last_used["R"] = -999.0

func create_v75_keybind_panel() -> void:
	if hud == null:
		return
	if keybind_panel != null and is_instance_valid(keybind_panel):
		return

	keybind_panel = Panel.new()
	keybind_panel.name = "V75KeybindOptions"
	keybind_panel.position = Vector2(900, 210)
	keybind_panel.size = Vector2(760, 620)
	keybind_panel.visible = false
	keybind_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	keybind_panel.z_index = 120
	hud.add_child(keybind_panel)

	var title := Label.new()
	title.position = Vector2(30, 18)
	title.size = Vector2(700, 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "OPTIONS - KEYBINDS"
	title.add_theme_font_size_override("font_size", 22)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	keybind_panel.add_child(title)

	keybind_label = Label.new()
	keybind_label.position = Vector2(40, 70)
	keybind_label.size = Vector2(680, 270)
	keybind_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	keybind_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	keybind_panel.add_child(keybind_label)

	var preset_btn := Button.new()
	preset_btn.position = Vector2(230, 365)
	preset_btn.size = Vector2(300, 55)
	preset_btn.text = "Apply ARPG Default"
	preset_btn.focus_mode = Control.FOCUS_NONE
	preset_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	preset_btn.pressed.connect(apply_arpg_default_keybinds)
	keybind_panel.add_child(preset_btn)
	keybind_buttons["preset"] = preset_btn

	var close_btn := Button.new()
	close_btn.position = Vector2(230, 440)
	close_btn.size = Vector2(300, 55)
	close_btn.text = "Close Options"
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	close_btn.pressed.connect(func(): keybind_panel.visible = false)
	keybind_panel.add_child(close_btn)
	keybind_buttons["close"] = close_btn

func apply_arpg_default_keybinds() -> void:
	keybinds["RMB Skill"] = "RMB"
	keybinds["Skill 1"] = "Q"
	keybinds["Skill 2"] = "W"
	keybinds["Skill 3"] = "E"
	keybinds["Ultimate"] = "R"
	keybinds["Health Potion"] = "1"
	keybinds["Mana Potion"] = "2"
	apply_v75_default_action_bar()
	loot_label.text = "Applied ARPG default keybinds."
	update_v75_keybind_panel()
	update_hud()
	update_v73_action_bar()
	save_game()

func update_v75_keybind_panel() -> void:
	if keybind_label == null:
		return
	var text := "Current Eternal Realms keybind preset:\n\n"
	text += "LMB = Move / Interact / Basic Attack\n"
	text += "RMB = " + str(keybinds["RMB Skill"]) + " Main Skill\n"
	text += "Q = Skill 1\n"
	text += "W = Skill 2\n"
	text += "E = Skill 3\n"
	text += "R = Ultimate / Skill 4\n"
	text += "1 = Health Potion\n"
	text += "2 = Mana Potion\n\n"
	text += "This is the first safe keybind menu.\nNext version: click an action, then press any key to rebind it."
	keybind_label.text = text

func toggle_v75_keybind_options() -> void:
	if keybind_panel == null:
		return
	keybind_panel.visible = not keybind_panel.visible
	if keybind_panel.visible:
		keybind_panel.move_to_front()
		update_v75_keybind_panel()

func handle_input() -> void:
	if keybind_panel != null and keybind_panel.visible:
		if key_just_pressed(KEY_ESCAPE):
			keybind_panel.visible = false
			return
		# Panel buttons handle mouse themselves; block gameplay input behind the panel.
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if get_panel_rect_global(keybind_panel).has_point(get_viewport().get_mouse_position()):
				return

	# F10 opens keybind options for now.
	if key_just_pressed(KEY_F10):
		toggle_v75_keybind_options()
		return

	# Potion keys are moved away from Q/E so QWER can become skill keys.
	if key_just_pressed(KEY_1):
		use_health_potion()
		return
	if key_just_pressed(KEY_2):
		use_mana_potion()
		return

	# New ARPG skill keys.
	if key_just_pressed(KEY_Q):
		use_combat_slot("Q")
		return
	if key_just_pressed(KEY_W):
		use_combat_slot("W")
		return
	if key_just_pressed(KEY_E):
		use_combat_slot("E")
		return
	if key_just_pressed(KEY_R):
		use_combat_slot("R")
		return

	super.handle_input()

func is_mouse_over_open_ui(mouse_pos: Vector2) -> bool:
	if keybind_panel != null and keybind_panel.visible and get_panel_rect_global(keybind_panel).has_point(mouse_pos):
		return true
	return super.is_mouse_over_open_ui(mouse_pos)

func update_v73_action_bar() -> void:
	if action_bar_panel == null or not is_instance_valid(action_bar_panel):
		return

	set_action_slot_text("LMB", "M\nMove")
	var slots = ["RMB", "Q", "W", "E", "R"]
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

func create_v73_action_bar() -> void:
	if hud == null:
		return
	if action_bar_panel != null and is_instance_valid(action_bar_panel):
		return

	action_bar_panel = Panel.new()
	action_bar_panel.name = "V75ActionBar"
	action_bar_panel.position = Vector2(830, 1265)
	action_bar_panel.size = Vector2(900, 125)
	action_bar_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.add_child(action_bar_panel)

	var slots = ["LMB", "RMB", "Q", "W", "E", "R"]
	for i in range(slots.size()):
		var slot_name = slots[i]
		var btn := Button.new()
		btn.position = Vector2(20 + i * 145, 16)
		btn.size = Vector2(122, 92)
		btn.focus_mode = Control.FOCUS_NONE
		btn.disabled = true
		action_bar_panel.add_child(btn)
		action_bar_slots[slot_name] = btn

		var key_label := Label.new()
		key_label.position = Vector2(20 + i * 145, 96)
		key_label.size = Vector2(122, 22)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.text = slot_name
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		action_bar_panel.add_child(key_label)
		action_bar_labels[slot_name] = key_label

func update_potion_belt_ui() -> void:
	if potion_belt_label == null:
		return
	potion_belt_label.text = "Potions: 1 Health " + str(health_potions) + "/" + str(max_health_potions) + "    2 Mana " + str(mana_potions) + "/" + str(max_mana_potions) + "    F10 Keybinds"
