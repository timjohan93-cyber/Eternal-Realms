extends "res://scripts/MainV78H.gd"

# Eternal Realms V7.9
# Main Menu + Class Select Foundation
# Adds a pre-game menu inspired by the Eternal Realms visual target.
# This is code/UI only for now: cinematic art/models can be swapped in later as real assets.

var main_menu_panel: Panel
var main_menu_title: Label
var main_menu_subtitle: Label
var main_menu_notice: Label
var main_menu_dev_checkbox: CheckBox
var class_select_panel: Panel
var class_card_buttons := {}
var selected_menu_class: String = "Warrior"
var game_started := false
var development_mode_enabled := true
var menu_fire_time := 0.0
var menu_fire: Polygon2D
var menu_hero_markers := {}

var menu_classes := {
	"Warrior": {
		"role": "MELEE • DURABLE",
		"desc": "Close range fighter with high survivability.",
		"color": Color(0.95, 0.20, 0.14, 1.0),
		"icon": "⚔",
		"gear": "Sword • Shield • Heavy Armor"
	},
	"Rogue": {
		"role": "MELEE • AGILE",
		"desc": "Fast strikes, critical hits and evasion.",
		"color": Color(0.20, 0.90, 0.38, 1.0),
		"icon": "🗡",
		"gear": "Daggers • Bow • Leather Armor"
	},
	"Paladin": {
		"role": "MELEE • SUPPORT",
		"desc": "Holy warrior with powerful aura and healing.",
		"color": Color(1.0, 0.78, 0.22, 1.0),
		"icon": "🛡",
		"gear": "Mace • Shield • Plate Armor"
	},
	"Mage": {
		"role": "RANGED • SPELLCASTER",
		"desc": "Master of the elements and arcane powers.",
		"color": Color(0.72, 0.25, 1.0, 1.0),
		"icon": "✦",
		"gear": "Staff • Orb • Mystic Robes"
	},
	"Ranger": {
		"role": "RANGED • PRECISION",
		"desc": "Long range attacks and nature's companion. Coming later.",
		"color": Color(0.35, 0.85, 0.30, 1.0),
		"icon": "◈",
		"gear": "Bow • Quiver • Hide Armor"
	}
}

func _ready() -> void:
	super._ready()
	create_v79_main_menu()
	show_v79_main_menu()

func _process(delta: float) -> void:
	super._process(delta)
	update_v79_menu_animation(delta)

func create_v79_main_menu() -> void:
	if hud == null:
		return
	if main_menu_panel != null and is_instance_valid(main_menu_panel):
		return

	main_menu_panel = Panel.new()
	main_menu_panel.name = "V79MainMenu"
	main_menu_panel.position = Vector2(0, 0)
	main_menu_panel.size = Vector2(2560, 1440)
	main_menu_panel.z_index = 1000
	main_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	main_menu_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.006, 0.008, 0.011, 0.995), Color(0.28, 0.20, 0.12, 1.0), 0))
	hud.add_child(main_menu_panel)

	create_v79_menu_background()
	create_v79_left_menu()
	create_v79_class_select()
	create_v79_dev_notice()

func create_v79_menu_background() -> void:
	var sky := ColorRect.new()
	sky.position = Vector2(0, 0)
	sky.size = Vector2(2560, 1440)
	sky.color = Color(0.006, 0.009, 0.014, 1.0)
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(sky)

	var fog := ColorRect.new()
	fog.position = Vector2(0, 620)
	fog.size = Vector2(2560, 820)
	fog.color = Color(0.04, 0.035, 0.030, 0.78)
	fog.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(fog)

	for i in range(9):
		var tower := ColorRect.new()
		tower.position = Vector2(160 + i * 280, 240 + (i % 3) * 45)
		tower.size = Vector2(120 + (i % 2) * 50, 620 - (i % 3) * 40)
		tower.color = Color(0.018, 0.021, 0.026, 0.72)
		tower.mouse_filter = Control.MOUSE_FILTER_IGNORE
		main_menu_panel.add_child(tower)

	var ground := ColorRect.new()
	ground.position = Vector2(0, 960)
	ground.size = Vector2(2560, 480)
	ground.color = Color(0.018, 0.014, 0.010, 1.0)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(ground)

	menu_fire = Polygon2D.new()
	menu_fire.position = Vector2(1280, 940)
	menu_fire.polygon = PackedVector2Array([Vector2(-42, 55), Vector2(-18, -45), Vector2(0, -85), Vector2(18, -35), Vector2(42, 55)])
	menu_fire.color = Color(1.0, 0.38, 0.05, 0.95)
	main_menu_panel.add_child(menu_fire)

	var ember := Polygon2D.new()
	ember.position = Vector2(1280, 990)
	ember.polygon = make_circle_polygon(82.0, 36)
	ember.color = Color(1.0, 0.36, 0.05, 0.15)
	main_menu_panel.add_child(ember)

func create_v79_left_menu() -> void:
	main_menu_title = Label.new()
	main_menu_title.position = Vector2(60, 85)
	main_menu_title.size = Vector2(520, 170)
	main_menu_title.text = "ETERNAL\nREALMS"
	main_menu_title.add_theme_font_size_override("font_size", 62)
	main_menu_title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.42, 1.0))
	main_menu_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(main_menu_title)

	main_menu_subtitle = Label.new()
	main_menu_subtitle.position = Vector2(75, 295)
	main_menu_subtitle.size = Vector2(470, 32)
	main_menu_subtitle.text = "RISE. FIGHT. BECOME LEGEND."
	main_menu_subtitle.add_theme_font_size_override("font_size", 18)
	main_menu_subtitle.add_theme_color_override("font_color", Color(0.78, 0.66, 0.44, 1.0))
	main_menu_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(main_menu_subtitle)

	var buttons := [
		{"name": "PLAY", "callback": Callable(self, "show_v79_class_select")},
		{"name": "SETTINGS", "callback": Callable(self, "show_v79_settings_placeholder")},
		{"name": "CREDITS", "callback": Callable(self, "show_v79_credits_placeholder")},
		{"name": "EXIT GAME", "callback": Callable(self, "quit_v79_game")}
	]

	for i in range(buttons.size()):
		var data: Dictionary = buttons[i]
		var btn := Button.new()
		btn.position = Vector2(65, 470 + i * 82)
		btn.size = Vector2(380, 64)
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = str(data["name"])
		btn.add_theme_font_size_override("font_size", 22)
		btn.add_theme_stylebox_override("normal", make_v78a_button_style(Color(0.06, 0.046, 0.038, 0.96), Color(0.50, 0.38, 0.20, 1.0), 2))
		btn.add_theme_stylebox_override("hover", make_v78a_button_style(Color(0.24, 0.055, 0.035, 1.0), Color(1.0, 0.72, 0.28, 1.0), 2))
		btn.add_theme_color_override("font_color", Color(0.92, 0.84, 0.70, 1.0))
		btn.pressed.connect(data["callback"])
		main_menu_panel.add_child(btn)

func create_v79_class_select() -> void:
	class_select_panel = Panel.new()
	class_select_panel.name = "V79ClassSelect"
	class_select_panel.position = Vector2(540, 95)
	class_select_panel.size = Vector2(1820, 1180)
	class_select_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	class_select_panel.add_theme_stylebox_override("panel", make_v78a_panel_style(Color(0.0, 0.0, 0.0, 0.0), Color(0.0, 0.0, 0.0, 0.0), 0))
	main_menu_panel.add_child(class_select_panel)

	var header := Label.new()
	header.position = Vector2(0, 20)
	header.size = Vector2(1820, 48)
	header.text = "CHOOSE YOUR CLASS"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 34)
	header.add_theme_color_override("font_color", Color(1.0, 0.84, 0.55, 1.0))
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	class_select_panel.add_child(header)

	var class_order := ["Warrior", "Rogue", "Paladin", "Mage", "Ranger"]
	for i in range(class_order.size()):
		var class_name := str(class_order[i])
		create_v79_class_card(class_name, Vector2(50 + i * 350, 660), i)
		create_v79_hero_marker(class_name, Vector2(145 + i * 350, 320), i)

func create_v79_hero_marker(class_name: String, pos: Vector2, index: int) -> void:
	var data: Dictionary = menu_classes[class_name]
	var color: Color = data["color"]
	var hero := Button.new()
	hero.name = "Hero" + class_name
	hero.position = pos
	hero.size = Vector2(190, 320)
	hero.focus_mode = Control.FOCUS_NONE
	hero.text = str(data["icon"]) + "\n\n" + class_name.to_upper()
	hero.add_theme_font_size_override("font_size", 28)
	hero.add_theme_stylebox_override("normal", make_v78a_button_style(Color(color.r * 0.08, color.g * 0.08, color.b * 0.08, 0.35), color.darkened(0.20), 2))
	hero.add_theme_stylebox_override("hover", make_v78a_button_style(Color(color.r * 0.16, color.g * 0.16, color.b * 0.16, 0.55), color.lightened(0.25), 3))
	hero.add_theme_color_override("font_color", color.lightened(0.25))
	hero.pressed.connect(func(): select_v79_menu_class(class_name))
	class_select_panel.add_child(hero)
	menu_hero_markers[class_name] = hero

func create_v79_class_card(class_name: String, pos: Vector2, index: int) -> void:
	var data: Dictionary = menu_classes[class_name]
	var color: Color = data["color"]
	var btn := Button.new()
	btn.name = "ClassCard" + class_name
	btn.position = pos
	btn.size = Vector2(300, 250)
	btn.focus_mode = Control.FOCUS_NONE
	btn.text = str(data["icon"]) + "\n" + class_name.to_upper() + "\n" + str(data["role"]) + "\n\n" + str(data["desc"]) + "\n\n" + str(data["gear"])
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_stylebox_override("normal", make_v78a_button_style(Color(0.022, 0.020, 0.018, 0.84), color.darkened(0.25), 2))
	btn.add_theme_stylebox_override("hover", make_v78a_button_style(Color(color.r * 0.13, color.g * 0.13, color.b * 0.13, 0.96), color.lightened(0.22), 3))
	btn.add_theme_color_override("font_color", color.lightened(0.25))
	btn.pressed.connect(func(): select_v79_menu_class(class_name))
	class_select_panel.add_child(btn)
	class_card_buttons[class_name] = btn

func create_v79_dev_notice() -> void:
	main_menu_notice = Label.new()
	main_menu_notice.position = Vector2(2140, 90)
	main_menu_notice.size = Vector2(330, 140)
	main_menu_notice.text = "DEVELOPMENT BUILD\n\nThis is a work in progress.\nEverything you see is subject\nto change."
	main_menu_notice.add_theme_font_size_override("font_size", 17)
	main_menu_notice.add_theme_color_override("font_color", Color(0.82, 0.72, 0.62, 1.0))
	main_menu_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(main_menu_notice)

	main_menu_dev_checkbox = CheckBox.new()
	main_menu_dev_checkbox.position = Vector2(1990, 1225)
	main_menu_dev_checkbox.size = Vector2(470, 70)
	main_menu_dev_checkbox.text = "DEVELOPMENT MODE\nEnable class change in-game (Press C)"
	main_menu_dev_checkbox.button_pressed = development_mode_enabled
	main_menu_dev_checkbox.add_theme_font_size_override("font_size", 16)
	main_menu_dev_checkbox.add_theme_color_override("font_color", Color(0.72, 0.68, 0.60, 1.0))
	main_menu_dev_checkbox.toggled.connect(func(enabled: bool): development_mode_enabled = enabled)
	main_menu_panel.add_child(main_menu_dev_checkbox)

	var version := Label.new()
	version.position = Vector2(55, 1325)
	version.size = Vector2(220, 32)
	version.text = "v0.7.9"
	version.add_theme_color_override("font_color", Color(0.60, 0.56, 0.50, 1.0))
	version.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_menu_panel.add_child(version)

func show_v79_main_menu() -> void:
	game_started = false
	if main_menu_panel != null:
		main_menu_panel.visible = true
		main_menu_panel.move_to_front()
	select_v79_menu_class(selected_menu_class)
	set_v79_gameplay_visible(false)

func show_v79_class_select() -> void:
	# Play currently means confirm selected class and enter world.
	start_v79_game()

func start_v79_game() -> void:
	if selected_menu_class == "Ranger":
		loot_label.text = "Ranger is a future class. Starting as Rogue for now."
		selected_menu_class = "Rogue"

	current_class = selected_menu_class
	apply_class_base_stats()
	recalculate_stats()
	hp = max_hp
	mana = max_mana
	update_hud()
	update_character_ui()
	update_inventory_ui()
	game_started = true
	if main_menu_panel != null:
		main_menu_panel.visible = false
	set_v79_gameplay_visible(true)
	loot_label.text = "Welcome to Eternal Realms, " + current_class + "."

func set_v79_gameplay_visible(show: bool) -> void:
	# Keep the world itself rendered behind the menu, but hide core gameplay UI until Play.
	if hud_label != null:
		hud_label.visible = show
	if action_bar_panel != null:
		action_bar_panel.visible = show
	if inventory_panel != null:
		inventory_panel.visible = false
	if character_preview_panel != null:
		character_preview_panel.visible = false
	if passive_tree_panel != null:
		passive_tree_panel.visible = false
	if vendor_panel != null:
		vendor_panel.visible = false
	if blacksmith_panel != null:
		blacksmith_panel.visible = false
	if mystic_panel != null:
		mystic_panel.visible = false

func select_v79_menu_class(class_name: String) -> void:
	selected_menu_class = class_name
	for key in class_card_buttons.keys():
		var data: Dictionary = menu_classes[key]
		var color: Color = data["color"]
		var btn: Button = class_card_buttons[key]
		if btn == null or not is_instance_valid(btn):
			continue
		var active := key == selected_menu_class
		btn.add_theme_stylebox_override("normal", make_v78a_button_style(Color(color.r * (0.18 if active else 0.05), color.g * (0.18 if active else 0.05), color.b * (0.18 if active else 0.05), 0.96), color.lightened(0.28) if active else color.darkened(0.25), 4 if active else 2))
		btn.add_theme_color_override("font_color", Color(1.0, 0.88, 0.58, 1.0) if active else color.lightened(0.16))
	for key in menu_hero_markers.keys():
		var hero: Button = menu_hero_markers[key]
		if hero != null and is_instance_valid(hero):
			hero.modulate = Color(1, 1, 1, 1) if key == selected_menu_class else Color(0.55, 0.55, 0.60, 0.78)

func update_v79_menu_animation(delta: float) -> void:
	if main_menu_panel == null or not main_menu_panel.visible:
		return
	menu_fire_time += delta
	if menu_fire != null and is_instance_valid(menu_fire):
		var pulse := 1.0 + sin(menu_fire_time * 6.0) * 0.08
		menu_fire.scale = Vector2(pulse, 1.0 + sin(menu_fire_time * 4.0) * 0.12)
		menu_fire.color = Color(1.0, 0.30 + abs(sin(menu_fire_time * 4.0)) * 0.24, 0.04, 0.78 + abs(sin(menu_fire_time * 5.0)) * 0.18)

func show_v79_settings_placeholder() -> void:
	loot_label.text = "Settings menu comes in a later pass."

func show_v79_credits_placeholder() -> void:
	loot_label.text = "Eternal Realms - prototype by Tim Berge with AI-assisted development."

func quit_v79_game() -> void:
	get_tree().quit()

func toggle_character_screen() -> void:
	if not game_started:
		return
	super.toggle_character_screen()

func toggle_inventory() -> void:
	if not game_started:
		return
	super.toggle_inventory()

func change_class() -> void:
	if not development_mode_enabled:
		loot_label.text = "Class change is disabled outside Development Mode."
		return
	super.change_class()
