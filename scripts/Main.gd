extends Node2D

const SCREEN_W := 2560
const SCREEN_H := 1440

var player: CharacterBody2D
var player_shape: Polygon2D
var hud: CanvasLayer
var hud_label: Label
var loot_label: Label
var inventory_panel: Panel
var inventory_label: Label
var equipment_label: Label
var potion_belt_label: Label
var boss_panel: Panel
var boss_name_label: Label
var boss_hp_bar: ProgressBar
var portal: Area2D

var pending_portal_interaction := false
var target_pos := Vector2(420, 720)
var selected_enemy = null
var enemies: Array = []
var ground_items: Array = []
var loot_beams: Array = []
var loot_filter_mode := 0
var loot_filter_names := ["Show All", "Hide Common", "Hide Common+Uncommon", "Rare+", "Legendary+"]
var loot_filter_panel: Panel
var loot_filter_label: Label
var game_menu_panel: Panel
var game_menu_label: Label
var game_menu_open := false
var options_panel: Panel
var options_open := false
var floating_texts: Array = []

var inventory: Array = []
var merchant_stock: Array = []
var max_inventory_size := 24
var selected_inventory_index := -1
var health_potions := 3
var mana_potions := 3
var max_health_potions := 20
var max_mana_potions := 20
var potion_capacity_bonus := 0
var potion_effect_bonus := 0.0
var potion_duration_bonus := 0.0
var active_flask_effects: Array = []
var health_regen := 0.0
var mana_regen := 0.0
var regen_timer := 0.0
var gold := 0
var save_path := "user://eternal_realms_save.json"
var merchant_panel: Panel
var merchant_label: Label
var blacksmith_panel: Panel
var blacksmith_label: Label
var mystic_panel: Panel
var mystic_label: Label
var merchant_open := false
var blacksmith_open := false
var mystic_open := false
var dev_panel: Panel
var dev_label: Label
var dev_open := false
var character_panel: Panel
var character_label: Label
var character_open := false
var character_tab := "Equipment"
var character_tab_buttons := {}
var skill_points := 0
var passive_points := 0
var skill_ranks := {"Skill1": 1, "Skill2": 0, "Skill3": 0, "Skill4": 0, "Ultimate": 0}
var passive_ranks := {
	"Damage Training": 0,
	"Armor Training": 0,
	"Movement Training": 0,
	"Attack Speed Training": 0,
	"Cooldown Training": 0,
	"Crit Training": 0
}
var attack_speed_bonus := 0.0
var cooldown_reduction := 0.0
var pickup_radius := 0.0
var inventory_buttons: Array = []
var equipment_buttons := {}
var stat_summary_label: Label
var selected_item_label: Label
var sort_button: Button
var sell_button: Button
var key_memory := {}
var mouse_memory := {}

var equipment := {
	"Weapon": null,
	"Offhand": null,
	"Helmet": null,
	"Chest": null,
	"Gloves": null,
	"Boots": null,
	"Ring1": null,
	"Ring2": null,
	"Amulet": null,
	"Belt": null
}

var current_class := "Warrior"
var classes := ["Warrior", "Rogue", "Paladin", "Mage"]
var class_index := 0

var level := 1
var xp := 0
var xp_to_next := 100
var paragon_level := 0
var paragon_points := 0

var base_hp := 160
var base_mana := 70
var base_damage := 14
var base_armor := 2

var hp := 160
var max_hp := 160
var mana := 70
var max_mana := 70
var damage := 14
var armor := 2
var crit_chance := 0.05
var crit_damage := 1.5
var strength := 10
var dexterity := 10
var intellect := 10
var willpower := 10
var move_speed := 260.0
var attack_range := 55.0
var attack_cooldown := 0.45
var last_attack_time := -999.0

var current_theme := "Town"
var equipped_legendary_powers: Array = []
var magic_find_bonus := 0.0
var gold_find_bonus := 0.0
var skill_last_used := [-999.0, -999.0, -999.0, -999.0]
var combat_slot_last_used := {"RMB": -999.0, "1": -999.0, "2": -999.0, "3": -999.0, "4": -999.0}
var combat_skill_slots := {"RMB": 0, "1": 0, "2": 1, "3": 2, "4": 3}
var inventory_open := false
var active_boss = null

var dungeon_rooms: Array = []
var dungeon_corridors: Array = []
var dungeon_nodes: Array = []
var minimap_panel: Panel
var minimap_label: Label
var exit_portal: Area2D
var dungeon_generated := false
var room_size := Vector2(150, 100)

var rarity_table_normal := [
	{"name": "Common", "weight": 520, "stats": 1, "power": 1.0},
	{"name": "Uncommon", "weight": 280, "stats": 2, "power": 1.2},
	{"name": "Magic", "weight": 140, "stats": 3, "power": 1.6},
	{"name": "Rare", "weight": 50, "stats": 4, "power": 2.2},
	{"name": "Legendary", "weight": 9, "stats": 5, "power": 3.5},
	{"name": "Godlike", "weight": 1, "stats": 7, "power": 7.5}
]

var rarity_table_boss := [
	{"name": "Magic", "weight": 360, "stats": 3, "power": 1.6},
	{"name": "Rare", "weight": 520, "stats": 4, "power": 2.2},
	{"name": "Legendary", "weight": 110, "stats": 5, "power": 3.5},
	{"name": "Godlike", "weight": 10, "stats": 7, "power": 7.5}
]


var legendary_powers := [
	{"id":"chain_lightning", "name":"Chain Lightning", "desc":"15% chance on hit to zap up to 3 nearby enemies."},
	{"id":"vampiric", "name":"Vampiric", "desc":"Heal for 5% of damage dealt."},
	{"id":"berserker", "name":"Berserker", "desc":"+35% damage while below 50% HP."},
	{"id":"explosive", "name":"Explosive", "desc":"Killed enemies explode and damage nearby enemies."},
	{"id":"treasure_hunter", "name":"Treasure Hunter", "desc":"+40% gold drops."},
	{"id":"fortune", "name":"Fortune", "desc":"Improves chance of better loot."},
	{"id":"arcane_echo", "name":"Arcane Echo", "desc":"20% chance for skills to hit twice."},
	{"id":"swift_strikes", "name":"Swift Strikes", "desc":"Basic attacks are faster."},
	{"id":"stone_skin", "name":"Stone Skin", "desc":"+25% armor."},
	{"id":"blood_armor", "name":"Blood Armor", "desc":"+20% health and heal on kill."}
]

var unique_items := {
	"Infernal Warden": [
		{"name":"Warden's Hellblade", "slot":"Weapon", "rarity":"Unique", "power_id":"infernal_explosion", "power_name":"Infernal Explosion", "power_desc":"Kills explode in fire.", "stats":{"Damage":120, "Crit Damage":35}},
		{"name":"Infernal Plate", "slot":"Chest", "rarity":"Unique", "power_id":"infernal_plate", "power_name":"Infernal Plate", "power_desc":"Greatly increases armor and health.", "stats":{"Armor":90, "Health":180}},
		{"name":"Ember Ring", "slot":"Ring", "rarity":"Unique", "power_id":"ember_ring", "power_name":"Ember Ring", "power_desc":"Critical hits may ignite enemies.", "stats":{"Crit Chance":8, "Damage":45}}
	],
	"Frost Titan": [
		{"name":"Titan's Frozen Crown", "slot":"Helmet", "rarity":"Unique", "power_id":"frost_nova_crit", "power_name":"Frozen Crown", "power_desc":"Critical hits may trigger Ice Nova.", "stats":{"Armor":70, "Mana":120}},
		{"name":"Glacier Staff", "slot":"Weapon", "rarity":"Unique", "power_id":"glacier_staff", "power_name":"Glacier Staff", "power_desc":"Skills deal increased damage.", "stats":{"Damage":110, "Mana":160}},
		{"name":"Frozen Heart Pendant", "slot":"Amulet", "rarity":"Unique", "power_id":"frozen_heart", "power_name":"Frozen Heart", "power_desc":"Gain health and mana from elite kills.", "stats":{"Health":100, "Mana":100}}
	],
	"Corrupted Ancient": [
		{"name":"Heart of the Ancient", "slot":"Amulet", "rarity":"Unique", "power_id":"ancient_heart", "power_name":"Ancient Heart", "power_desc":"+50% maximum health.", "stats":{"Health":250}},
		{"name":"Rootbound Armor", "slot":"Chest", "rarity":"Unique", "power_id":"rootbound", "power_name":"Rootbound", "power_desc":"Massive armor but slightly slower movement.", "stats":{"Armor":130, "Health":120}},
		{"name":"Ancient Spirit Charm", "slot":"Ring", "rarity":"Unique", "power_id":"spirit_charm", "power_name":"Spirit Charm", "power_desc":"Skills may echo.", "stats":{"Damage":55, "Crit Chance":6}}
	]
}


func _ready() -> void:
	randomize()
	create_world()
	create_player()
	create_portal()
	create_hud()
	create_inventory_ui()
	create_character_ui()
	create_merchant_ui()
	create_blacksmith_ui()
	create_mystic_ui()
	create_dev_ui()
	create_minimap_ui()
	create_boss_ui()
	create_loot_filter_ui()
	create_game_menu_ui()
	load_game()
	if merchant_stock.size() == 0:
		refresh_merchant_stock()
	apply_class_base_stats()
	recalculate_stats()
	update_hud()
	update_inventory_ui()
	update_character_ui()
	update_merchant_ui()
	update_blacksmith_ui()
	update_mystic_ui()
	update_loot_filter_ui()

func create_world() -> void:
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.size = Vector2(SCREEN_W, SCREEN_H)
	bg.color = Color(0.07, 0.08, 0.09)
	add_child(bg)

	var town_text := Label.new()
	town_text.name = "TownText"
	town_text.position = Vector2(1060, 40)
	town_text.text = "Town Hub - Portal Master in the center"
	town_text.add_theme_font_size_override("font_size", 22)
	add_child(town_text)

	for i in range(5):
		var npc := Label.new()
		npc.position = Vector2(220 + i * 330, 1320)
		npc.text = ["Blacksmith (B)", "Merchant (M)", "Mystic (N)", "Healer", "Storage"][i]
		add_child(npc)

func create_player() -> void:
	player = CharacterBody2D.new()
	player.name = "Player"
	player.position = target_pos
	add_child(player)

	player_shape = Polygon2D.new()
	player_shape.polygon = PackedVector2Array([Vector2(0, -20), Vector2(16, 14), Vector2(-16, 14)])
	player_shape.color = Color(0.2, 0.7, 1.0)
	player.add_child(player_shape)

	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16
	col.shape = circle
	player.add_child(col)

func create_portal() -> void:
	portal = Area2D.new()
	portal.name = "PortalMaster"
	portal.position = Vector2(1280, 720)
	add_child(portal)

	var portal_shape := Polygon2D.new()
	portal_shape.polygon = PackedVector2Array([Vector2(0, -38), Vector2(34, 0), Vector2(0, 38), Vector2(-34, 0)])
	portal_shape.color = Color(0.55, 0.1, 1.0)
	portal.add_child(portal_shape)

	var label := Label.new()
	label.position = Vector2(-80, 45)
	label.text = "Portal Master\nLeft-click or press P"
	portal.add_child(label)

func create_hud() -> void:
	hud = CanvasLayer.new()
	add_child(hud)

	hud_label = Label.new()
	hud_label.position = Vector2(20, 20)
	hud_label.add_theme_font_size_override("font_size", 18)
	hud.add_child(hud_label)

	loot_label = Label.new()
	loot_label.position = Vector2(20, 150)
	loot_label.size = Vector2(560, 360)
	loot_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loot_label.add_theme_font_size_override("font_size", 16)
	hud.add_child(loot_label)

	potion_belt_label = Label.new()
	potion_belt_label.position = Vector2(900, 1360)
	potion_belt_label.size = Vector2(520, 50)
	potion_belt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	potion_belt_label.add_theme_font_size_override("font_size", 18)
	hud.add_child(potion_belt_label)

	var help := Label.new()
	help.position = Vector2(2130, 20)
	help.text = "Controls:\nLMB: Move / Interact / Basic Attack / Pick up
RMB: Core Skill\n1-4: Active Skills\nQ: Health Flask\nE: Mana Flask\nLeft-click Portal Master or P: Portal\nT: Town\nC: Change Class\nI: Inventory\nK: Character / Equipment Screen\nInventory + Character can be open together\nClick inventory item, then click paper doll slot\nInventory: Sort button | Merchant: Sell Selected\nM: Merchant\nB: Blacksmith\nN: Mystic\nF1: Dev Tools (captures test keys while open)\nESC: Game Menu
L: Loot Filter
F5: Save"
	hud.add_child(help)

func create_inventory_ui() -> void:
	inventory_panel = Panel.new()
	inventory_panel.position = Vector2(1880, 140)
	inventory_panel.size = Vector2(650, 760)
	inventory_panel.visible = false
	hud.add_child(inventory_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "INVENTORY - Left-click item to select"
	title.add_theme_font_size_override("font_size", 18)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_panel.add_child(title)

	inventory_label = Label.new()
	inventory_label.position = Vector2(20, 535)
	inventory_label.size = Vector2(610, 200)
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inventory_panel.add_child(inventory_label)

	equipment_label = Label.new()
	equipment_label.visible = false
	inventory_panel.add_child(equipment_label)

	sort_button = Button.new()
	sort_button.position = Vector2(390, 18)
	sort_button.size = Vector2(120, 32)
	sort_button.text = "Sort"
	sort_button.focus_mode = Control.FOCUS_NONE
	sort_button.pressed.connect(sort_inventory)
	inventory_panel.add_child(sort_button)

	inventory_buttons.clear()
	for i in range(max_inventory_size):
		var btn := Button.new()
		var cols := 4
		var cell := Vector2(145, 65)
		var gap := Vector2(8, 8)
		var x = i % cols
		var y = i / cols
		btn.position = Vector2(20 + x * (cell.x + gap.x), 65 + y * (cell.y + gap.y))
		btn.size = cell
		btn.text = "Empty"
		btn.tooltip_text = "Empty inventory slot"
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(select_inventory_item.bind(i))
		inventory_panel.add_child(btn)
		inventory_buttons.append(btn)


func create_character_ui() -> void:
	character_panel = Panel.new()
	character_panel.position = Vector2(1280, 140)
	character_panel.size = Vector2(560, 760)
	character_panel.visible = false
	hud.add_child(character_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "CHARACTER"
	title.add_theme_font_size_override("font_size", 20)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_panel.add_child(title)

	character_tab_buttons.clear()
	var tabs = ["Equipment", "Skills", "Passives", "Paragon", "Build"]
	for i in range(tabs.size()):
		var tab_name = tabs[i]
		var tab_btn := Button.new()
		tab_btn.position = Vector2(20 + i * 102, 50)
		tab_btn.size = Vector2(98, 32)
		tab_btn.text = tab_name
		tab_btn.focus_mode = Control.FOCUS_NONE
		tab_btn.pressed.connect(set_character_tab.bind(tab_name))
		character_panel.add_child(tab_btn)
		character_tab_buttons[tab_name] = tab_btn

	selected_item_label = Label.new()
	selected_item_label.position = Vector2(20, 88)
	selected_item_label.size = Vector2(520, 42)
	selected_item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_item_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_panel.add_child(selected_item_label)

	character_label = Label.new()
	character_label.position = Vector2(20, 500)
	character_label.size = Vector2(520, 55)
	character_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	character_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_panel.add_child(character_label)

	equipment_buttons.clear()
	var rects = get_equipment_slot_rects()
	for slot in rects.keys():
		var btn := Button.new()
		var local_rect: Rect2 = rects[slot]
		local_rect.position -= character_panel.position
		btn.position = local_rect.position
		btn.size = local_rect.size
		btn.text = display_slot_name(slot) + "\nEmpty"
		btn.tooltip_text = display_slot_name(slot)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(equip_selected_to_slot.bind(slot))
		character_panel.add_child(btn)
		equipment_buttons[slot] = btn

	stat_summary_label = Label.new()
	stat_summary_label.position = Vector2(20, 565)
	stat_summary_label.size = Vector2(520, 175)
	stat_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stat_summary_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	character_panel.add_child(stat_summary_label)

	update_character_ui()


func create_merchant_ui() -> void:
	merchant_panel = Panel.new()
	merchant_panel.position = Vector2(1880, 140)
	merchant_panel.size = Vector2(540, 560)
	merchant_panel.visible = false
	hud.add_child(merchant_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "MERCHANT - Buy gear, potions, or sell selected inventory item"
	title.add_theme_font_size_override("font_size", 18)
	merchant_panel.add_child(title)

	sell_button = Button.new()
	sell_button.position = Vector2(360, 18)
	sell_button.size = Vector2(150, 32)
	sell_button.text = "Sell Selected"
	sell_button.focus_mode = Control.FOCUS_NONE
	sell_button.pressed.connect(sell_selected_item)
	merchant_panel.add_child(sell_button)

	merchant_label = Label.new()
	merchant_label.position = Vector2(20, 55)
	merchant_label.size = Vector2(500, 480)
	merchant_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	merchant_panel.add_child(merchant_label)

func create_blacksmith_ui() -> void:
	blacksmith_panel = Panel.new()
	blacksmith_panel.position = Vector2(1880, 140)
	blacksmith_panel.size = Vector2(540, 420)
	blacksmith_panel.visible = false
	hud.add_child(blacksmith_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "BLACKSMITH - Press item number to upgrade equipped/inventory gear"
	title.add_theme_font_size_override("font_size", 17)
	blacksmith_panel.add_child(title)

	blacksmith_label = Label.new()
	blacksmith_label.position = Vector2(20, 55)
	blacksmith_label.size = Vector2(500, 330)
	blacksmith_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blacksmith_panel.add_child(blacksmith_label)

func create_mystic_ui() -> void:
	mystic_panel = Panel.new()
	mystic_panel.position = Vector2(1880, 140)
	mystic_panel.size = Vector2(540, 420)
	mystic_panel.visible = false
	hud.add_child(mystic_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "MYSTIC - Press item number to reroll one random stat"
	title.add_theme_font_size_override("font_size", 17)
	mystic_panel.add_child(title)

	mystic_label = Label.new()
	mystic_label.position = Vector2(20, 55)
	mystic_label.size = Vector2(500, 330)
	mystic_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mystic_panel.add_child(mystic_label)


func create_dev_ui() -> void:
	dev_panel = Panel.new()
	dev_panel.position = Vector2(930, 180)
	dev_panel.size = Vector2(610, 540)
	dev_panel.visible = false
	hud.add_child(dev_panel)

	var title := Label.new()
	title.position = Vector2(20, 15)
	title.text = "DEV TOOLS / ADMIN TEST PANEL"
	title.add_theme_font_size_override("font_size", 20)
	dev_panel.add_child(title)

	dev_label = Label.new()
	dev_label.position = Vector2(20, 55)
	dev_label.size = Vector2(560, 450)
	dev_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dev_panel.add_child(dev_label)

	update_dev_ui()


func create_minimap_ui() -> void:
	minimap_panel = Panel.new()
	minimap_panel.position = Vector2(2310, 140)
	minimap_panel.size = Vector2(220, 220)
	minimap_panel.visible = false
	hud.add_child(minimap_panel)

	var title := Label.new()
	title.position = Vector2(15, 8)
	title.text = "MINIMAP"
	title.add_theme_font_size_override("font_size", 16)
	minimap_panel.add_child(title)

	minimap_label = Label.new()
	minimap_label.position = Vector2(15, 35)
	minimap_label.size = Vector2(190, 170)
	minimap_label.add_theme_font_size_override("font_size", 14)
	minimap_panel.add_child(minimap_label)

func create_boss_ui() -> void:
	boss_panel = Panel.new()
	boss_panel.position = Vector2(1020, 20)
	boss_panel.size = Vector2(520, 70)
	boss_panel.visible = false
	hud.add_child(boss_panel)

	boss_name_label = Label.new()
	boss_name_label.position = Vector2(20, 8)
	boss_name_label.size = Vector2(480, 22)
	boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_panel.add_child(boss_name_label)

	boss_hp_bar = ProgressBar.new()
	boss_hp_bar.position = Vector2(20, 35)
	boss_hp_bar.size = Vector2(480, 24)
	boss_hp_bar.min_value = 0
	boss_hp_bar.max_value = 100
	boss_hp_bar.value = 100
	boss_panel.add_child(boss_hp_bar)

func create_loot_filter_ui() -> void:
	loot_filter_panel = Panel.new()
	loot_filter_panel.position = Vector2(20, 1260)
	loot_filter_panel.size = Vector2(420, 92)
	loot_filter_panel.visible = true
	hud.add_child(loot_filter_panel)

	loot_filter_label = Label.new()
	loot_filter_label.position = Vector2(15, 12)
	loot_filter_label.size = Vector2(390, 70)
	loot_filter_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loot_filter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	loot_filter_panel.add_child(loot_filter_label)

	update_loot_filter_ui()

func update_loot_filter_ui() -> void:
	if loot_filter_label == null:
		return
	loot_filter_label.text = "LOOT FILTER [L]\nMode: " + loot_filter_names[loot_filter_mode] + "\nGodlike, Unique and Legendary beams are always highlighted."

func cycle_loot_filter() -> void:
	loot_filter_mode = (loot_filter_mode + 1) % loot_filter_names.size()
	loot_label.text = "Loot filter changed to: " + loot_filter_names[loot_filter_mode]
	update_loot_filter_ui()
	update_game_menu_ui()
	update_all_ground_item_visibility()
	save_game()

func should_show_loot(item: Dictionary) -> bool:
	var rarity = str(item.get("rarity", "Common"))

	if rarity in ["Godlike", "Unique"]:
		return true

	match loot_filter_mode:
		0:
			return true
		1:
			return rarity != "Common"
		2:
			return not rarity in ["Common", "Uncommon"]
		3:
			return rarity in ["Rare", "Legendary", "Godlike", "Unique"]
		4:
			return rarity in ["Legendary", "Godlike", "Unique"]

	return true

func update_ground_item_visibility(ground_item) -> void:
	if ground_item == null:
		return
	if not ground_item.has("item"):
		return
	var show := should_show_loot(ground_item["item"])
	if ground_item.has("body") and is_instance_valid(ground_item["body"]):
		ground_item["body"].visible = show

func update_all_ground_item_visibility() -> void:
	for ground_item in ground_items:
		update_ground_item_visibility(ground_item)


func create_game_menu_ui() -> void:
	game_menu_panel = Panel.new()
	game_menu_panel.position = Vector2(920, 250)
	game_menu_panel.size = Vector2(720, 760)
	game_menu_panel.visible = false
	hud.add_child(game_menu_panel)

	var title := Label.new()
	title.position = Vector2(30, 25)
	title.size = Vector2(660, 45)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "ETERNAL REALMS"
	title.add_theme_font_size_override("font_size", 30)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_menu_panel.add_child(title)

	var resume_btn := Button.new()
	resume_btn.position = Vector2(230, 90)
	resume_btn.size = Vector2(260, 45)
	resume_btn.text = "Resume"
	resume_btn.focus_mode = Control.FOCUS_NONE
	resume_btn.pressed.connect(close_game_menu)
	game_menu_panel.add_child(resume_btn)

	var options_btn := Button.new()
	options_btn.position = Vector2(230, 145)
	options_btn.size = Vector2(260, 45)
	options_btn.text = "Options"
	options_btn.focus_mode = Control.FOCUS_NONE
	options_btn.pressed.connect(toggle_options_panel)
	game_menu_panel.add_child(options_btn)

	var loot_title := Label.new()
	loot_title.position = Vector2(40, 220)
	loot_title.size = Vector2(640, 30)
	loot_title.text = "Loot Filter"
	loot_title.add_theme_font_size_override("font_size", 22)
	loot_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_menu_panel.add_child(loot_title)

	for i in range(loot_filter_names.size()):
		var b := Button.new()
		b.position = Vector2(70, 265 + i * 48)
		b.size = Vector2(580, 40)
		b.text = loot_filter_names[i]
		b.focus_mode = Control.FOCUS_NONE
		b.pressed.connect(set_loot_filter_mode.bind(i))
		game_menu_panel.add_child(b)

	game_menu_label = Label.new()
	game_menu_label.position = Vector2(70, 520)
	game_menu_label.size = Vector2(580, 80)
	game_menu_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game_menu_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_menu_panel.add_child(game_menu_label)

	var quit_btn := Button.new()
	quit_btn.position = Vector2(230, 645)
	quit_btn.size = Vector2(260, 45)
	quit_btn.text = "Quit Game"
	quit_btn.focus_mode = Control.FOCUS_NONE
	quit_btn.pressed.connect(quit_game)
	game_menu_panel.add_child(quit_btn)

	options_panel = Panel.new()
	options_panel.position = Vector2(1660, 250)
	options_panel.size = Vector2(520, 420)
	options_panel.visible = false
	hud.add_child(options_panel)

	var opt_title := Label.new()
	opt_title.position = Vector2(25, 20)
	opt_title.size = Vector2(470, 35)
	opt_title.text = "OPTIONS"
	opt_title.add_theme_font_size_override("font_size", 24)
	opt_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	options_panel.add_child(opt_title)

	var opt_text := Label.new()
	opt_text.position = Vector2(25, 70)
	opt_text.size = Vector2(470, 280)
	opt_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opt_text.text = "Options placeholder.\n\nFuture settings:\n- Resolution\n- Fullscreen\n- Master volume\n- Music volume\n- Effects volume\n- Keybinds\n- Graphics quality"
	opt_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	options_panel.add_child(opt_text)

	var close_opt := Button.new()
	close_opt.position = Vector2(160, 350)
	close_opt.size = Vector2(200, 42)
	close_opt.text = "Close Options"
	close_opt.focus_mode = Control.FOCUS_NONE
	close_opt.pressed.connect(toggle_options_panel)
	options_panel.add_child(close_opt)

	update_game_menu_ui()

func toggle_game_menu() -> void:
	game_menu_open = not game_menu_open
	game_menu_panel.visible = game_menu_open
	if not game_menu_open:
		options_open = false
		if options_panel != null:
			options_panel.visible = false
	update_game_menu_ui()

func close_game_menu() -> void:
	game_menu_open = false
	options_open = false
	game_menu_panel.visible = false
	if options_panel != null:
		options_panel.visible = false

func toggle_options_panel() -> void:
	options_open = not options_open
	options_panel.visible = options_open

func set_loot_filter_mode(mode: int) -> void:
	loot_filter_mode = clamp(mode, 0, loot_filter_names.size() - 1)
	loot_label.text = "Loot filter set to: " + loot_filter_names[loot_filter_mode]
	update_loot_filter_ui()
	update_game_menu_ui()
	update_all_ground_item_visibility()
	save_game()

func update_game_menu_ui() -> void:
	if game_menu_label == null:
		return
	game_menu_label.text = "Current Loot Filter: " + loot_filter_names[loot_filter_mode] + "\n\nTip: Press L in-game to cycle quickly, or use this menu for exact selection."

func quit_game() -> void:
	save_game()
	get_tree().quit()

func _process(delta: float) -> void:
	handle_input()
	update_flask_effects(delta)
	update_regen(delta)
	update_player(delta)
	try_complete_portal_interaction()
	update_enemies(delta)
	update_floating_texts(delta)
	update_loot_beams(delta)
	try_auto_attack()
	update_enemy_health_bars()
	update_boss_ui()
	update_minimap()


func key_just_pressed(keycode: int) -> bool:
	var is_down := Input.is_key_pressed(keycode)
	var was_down := bool(key_memory.get(keycode, false))
	key_memory[keycode] = is_down
	return is_down and not was_down

func mouse_button_just_pressed(button: int) -> bool:
	var is_down := Input.is_mouse_button_pressed(button)
	var was_down := bool(mouse_memory.get(button, false))
	mouse_memory[button] = is_down
	return is_down and not was_down


func get_panel_rect(panel: Control) -> Rect2:
	if panel == null:
		return Rect2()
	return Rect2(panel.position, panel.size)

func is_mouse_over_open_ui(mouse_pos: Vector2) -> bool:
	var panels = [
		inventory_panel,
		character_panel,
		merchant_panel,
		blacksmith_panel,
		mystic_panel,
		dev_panel,
		minimap_panel,
		boss_panel,
		loot_filter_panel,
		game_menu_panel,
		options_panel
	]

	for panel in panels:
		if panel != null and panel.visible and get_panel_rect(panel).has_point(mouse_pos):
			return true

	return false

func is_click_on_portal_master(pos: Vector2) -> bool:
	if current_theme != "Town":
		return false
	if portal == null or not is_instance_valid(portal):
		return false
	return portal.position.distance_to(pos) <= 85.0

func start_portal_interaction() -> void:
	if current_theme != "Town":
		return
	pending_portal_interaction = true
	selected_enemy = null
	target_pos = portal.position
	loot_label.text = "Moving to Portal Master..."

func try_complete_portal_interaction() -> void:
	if not pending_portal_interaction:
		return
	if current_theme != "Town":
		pending_portal_interaction = false
		return
	if portal == null or not is_instance_valid(portal):
		pending_portal_interaction = false
		return
	if player.position.distance_to(portal.position) <= 120:
		pending_portal_interaction = false
		enter_random_dungeon()

func handle_input() -> void:
	var screen_mouse := get_viewport().get_mouse_position()
	var world_mouse := get_global_mouse_position()
	var left_clicked := mouse_button_just_pressed(MOUSE_BUTTON_LEFT)
	var mouse_over_ui := is_mouse_over_open_ui(screen_mouse)
	var right_clicked := mouse_button_just_pressed(MOUSE_BUTTON_RIGHT)

	if right_clicked and not mouse_over_ui and not game_menu_open:
		use_combat_slot("RMB")
		return

	if key_just_pressed(KEY_ESCAPE):
		toggle_game_menu()
		return

	if game_menu_open:
		return

	# UI buttons handle their own clicks through signals.
	# When mouse is over UI, block ONLY world mouse actions.
	# Do NOT return from handle_input here, because keyboard/dev controls still need to work.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not mouse_over_ui:
		if left_clicked:
			if is_click_on_portal_master(world_mouse):
				start_portal_interaction()
				return

			var clicked_item = get_ground_item_at_position(world_mouse)
			if clicked_item != null:
				pending_portal_interaction = false
				pickup_ground_item(clicked_item)
				return

			var clicked_enemy = get_enemy_at_position(world_mouse)
			if clicked_enemy != null:
				pending_portal_interaction = false
				selected_enemy = clicked_enemy
				target_pos = selected_enemy["body"].position
				return

		if selected_enemy == null:
			if left_clicked:
				pending_portal_interaction = false
			target_pos = world_mouse
		elif not is_instance_valid(selected_enemy["body"]):
			selected_enemy = null
			target_pos = world_mouse

	if key_just_pressed(KEY_P):
		if current_theme == "Town":
			if player.position.distance_to(portal.position) < 130:
				enter_random_dungeon()
			else:
				start_portal_interaction()

	if key_just_pressed(KEY_T):
		return_to_town()

	if key_just_pressed(KEY_C):
		change_class()

	if key_just_pressed(KEY_I):
		toggle_inventory()

	if key_just_pressed(KEY_K):
		toggle_character_screen()

	if key_just_pressed(KEY_M):
		toggle_merchant()

	if key_just_pressed(KEY_B):
		toggle_blacksmith()

	if key_just_pressed(KEY_N):
		toggle_mystic()

	if key_just_pressed(KEY_F1):
		toggle_dev_panel()

	if key_just_pressed(KEY_Q):
		use_health_potion()

	if key_just_pressed(KEY_E):
		use_mana_potion()

	if key_just_pressed(KEY_F5):
		save_game()
		loot_label.text = "Game saved."

	if key_just_pressed(KEY_L):
		cycle_loot_filter()
		update_game_menu_ui()

	if dev_open:
		handle_dev_input()
		return

	if character_open and character_tab == "Skills":
		for si in range(4):
			if key_just_pressed(KEY_1 + si):
				if Input.is_key_pressed(KEY_SHIFT):
					rank_down_skill(si)
				else:
					rank_up_skill(si)
				return

	if character_open and character_tab == "Passives":
		var p_names = passive_ranks.keys()
		var p_keys = [KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y]
		for pi in range(min(p_names.size(), p_keys.size())):
			if key_just_pressed(p_keys[pi]):
				if Input.is_key_pressed(KEY_SHIFT):
					rank_down_passive(p_names[pi])
				else:
					rank_up_passive(p_names[pi])
				return

	for i in range(4):
		if key_just_pressed(KEY_1 + i):
			if merchant_open and i < merchant_stock.size():
				buy_merchant_item(i)
			elif blacksmith_open:
				upgrade_inventory_item(i)
			elif mystic_open:
				reroll_inventory_item(i)
			elif inventory_open and i < inventory.size():
				select_inventory_item(i)
			else:
				use_combat_slot(str(i + 1))

	var keys = [KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]
	for k in range(keys.size()):
		if key_just_pressed(keys[k]):
			var index = k + 4
			if merchant_open and index < merchant_stock.size():
				buy_merchant_item(index)
			elif blacksmith_open:
				upgrade_inventory_item(index)
			elif mystic_open:
				reroll_inventory_item(index)
			elif inventory_open and index < inventory.size():
				select_inventory_item(index)

	if merchant_open and key_just_pressed(KEY_Y):
		buy_potion("Health")
	if merchant_open and key_just_pressed(KEY_U):
		buy_potion("Mana")

	if merchant_open and key_just_pressed(KEY_R):
		if gold >= 50:
			gold -= 50
			refresh_merchant_stock()
			loot_label.text = "Merchant stock refreshed for 50 gold."
			update_hud()
			update_merchant_ui()
		else:
			loot_label.text = "Not enough gold to refresh merchant stock."

func toggle_inventory() -> void:
	inventory_open = not inventory_open
	inventory_panel.visible = inventory_open
	if inventory_open:
		# Inventory can stay open together with character screen.
		close_vendor_windows()
	update_inventory_ui()
	update_character_ui()

func toggle_character_screen() -> void:
	character_open = not character_open
	character_panel.visible = character_open
	if character_open:
		# Character screen can stay open together with inventory.
		close_vendor_windows()
	update_inventory_ui()
	update_character_ui()

func toggle_merchant() -> void:
	if current_theme != "Town":
		loot_label.text = "Merchant is only available in town."
		return
	merchant_open = not merchant_open
	merchant_panel.visible = merchant_open
	if merchant_open:
		close_town_windows_except("merchant")
	update_merchant_ui()

func toggle_blacksmith() -> void:
	if current_theme != "Town":
		loot_label.text = "Blacksmith is only available in town."
		return
	blacksmith_open = not blacksmith_open
	blacksmith_panel.visible = blacksmith_open
	if blacksmith_open:
		close_town_windows_except("blacksmith")
	update_blacksmith_ui()

func toggle_mystic() -> void:
	if current_theme != "Town":
		loot_label.text = "Mystic is only available in town."
		return
	mystic_open = not mystic_open
	mystic_panel.visible = mystic_open
	if mystic_open:
		close_town_windows_except("mystic")
	update_mystic_ui()

func close_town_windows_except(which: String) -> void:
	if which != "inventory":
		inventory_open = false
		inventory_panel.visible = false
	if which != "character":
		character_open = false
		character_panel.visible = false
	if which != "merchant":
		merchant_open = false
		merchant_panel.visible = false
	if which != "blacksmith":
		blacksmith_open = false
		blacksmith_panel.visible = false
	if which != "mystic":
		mystic_open = false
		mystic_panel.visible = false
	if which != "dev":
		dev_open = false
		dev_panel.visible = false


func close_vendor_windows() -> void:
	merchant_open = false
	blacksmith_open = false
	mystic_open = false
	dev_open = false
	merchant_panel.visible = false
	blacksmith_panel.visible = false
	mystic_panel.visible = false
	dev_panel.visible = false





func get_inventory_slot_rect(index: int) -> Rect2:
	var cols := 4
	var cell := Vector2(145, 65)
	var gap := Vector2(8, 8)
	var origin = inventory_panel.position + Vector2(20, 65)
	var x = index % cols
	var y = index / cols
	return Rect2(origin + Vector2(x * (cell.x + gap.x), y * (cell.y + gap.y)), cell)


func handle_inventory_grid_click(mouse_pos: Vector2) -> bool:
	if not inventory_panel.visible:
		return false
	for i in range(max_inventory_size):
		if get_inventory_slot_rect(i).has_point(mouse_pos):
			if i < inventory.size():
				select_inventory_item(i)
			else:
				selected_inventory_index = -1
				update_inventory_ui()
				update_character_ui()
			return true
	return false

func get_equipment_slot_rects() -> Dictionary:
	var origin = character_panel.position if character_panel != null else Vector2(1280, 140)
	return {
		"Helmet": Rect2(origin + Vector2(200, 95), Vector2(160, 50)),
		"Amulet": Rect2(origin + Vector2(200, 155), Vector2(160, 50)),
		"Ring1": Rect2(origin + Vector2(40, 155), Vector2(140, 50)),
		"Ring2": Rect2(origin + Vector2(380, 155), Vector2(140, 50)),
		"Chest": Rect2(origin + Vector2(200, 220), Vector2(160, 62)),
		"Gloves": Rect2(origin + Vector2(40, 300), Vector2(140, 52)),
		"Weapon": Rect2(origin + Vector2(40, 370), Vector2(140, 62)),
		"Offhand": Rect2(origin + Vector2(380, 370), Vector2(140, 62)),
		"Boots": Rect2(origin + Vector2(200, 370), Vector2(160, 52)),
		"Belt": Rect2(origin + Vector2(200, 440), Vector2(160, 52))
	}


func handle_character_screen_click(mouse_pos: Vector2) -> bool:
	var rects = get_equipment_slot_rects()
	for slot in rects.keys():
		if rects[slot].has_point(mouse_pos):
			equip_selected_to_slot(slot)
			return true
	return false

func display_slot_name(slot: String) -> String:
	if slot == "Ring1":
		return "Ring 1"
	if slot == "Ring2":
		return "Ring 2"
	return slot

func can_item_go_in_slot(item: Dictionary, slot: String) -> bool:
	if not item.has("slot"):
		return false
	if slot in ["Ring1", "Ring2"]:
		return item["slot"] == "Ring"
	return item["slot"] == slot

func equip_item_to_specific_slot(index: int, slot: String) -> void:
	if index < 0 or index >= inventory.size():
		return
	if not equipment.has(slot):
		return

	var item = inventory[index]
	if not can_item_go_in_slot(item, slot):
		loot_label.text = "Wrong slot. " + item["name"] + " is a " + item["slot"] + ", not " + display_slot_name(slot) + "."
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
	save_game()

func unequip_slot(slot: String) -> void:
	if not equipment.has(slot):
		return
	if equipment[slot] == null:
		return
	if inventory.size() >= max_inventory_size:
		loot_label.text = "Inventory full. Cannot unequip."
		return

	var item = equipment.get(slot, null)
	equipment[slot] = null
	inventory.append(item)
	recalculate_stats()
	loot_label.text = "Unequipped from " + display_slot_name(slot) + ":\n" + item_to_text(item)
	update_hud()
	update_inventory_ui()
	update_character_ui()
	save_game()

func equip_selected_to_slot(slot: String) -> void:
	if selected_inventory_index < 0 or selected_inventory_index >= inventory.size():
		if equipment.has(slot) and equipment[slot] != null:
			if Input.is_key_pressed(KEY_SHIFT):
				unequip_slot(slot)
			else:
				loot_label.text = display_slot_name(slot) + " already has an item. Hold SHIFT and click to unequip."
		else:
			loot_label.text = "Select an inventory item first, then click the correct equipment slot."
		return

	var item = inventory[selected_inventory_index]
	if not can_item_go_in_slot(item, slot):
		loot_label.text = "Wrong slot. " + item["name"] + " is a " + item["slot"] + ", not " + display_slot_name(slot) + "."
		return

	equip_item_to_specific_slot(selected_inventory_index, slot)
	selected_inventory_index = -1
	update_inventory_ui()
	update_character_ui()


func set_character_tab(tab_name: String) -> void:
	character_tab = tab_name
	update_character_ui()

func get_skill_key(index: int) -> String:
	if index >= 0 and index <= 3:
		return "Skill" + str(index + 1)
	return "Ultimate"

func get_skill_rank(index: int) -> int:
	return int(skill_ranks.get(get_skill_key(index), 0))

func rank_up_skill(index: int) -> void:
	var key = get_skill_key(index)
	var current = int(skill_ranks.get(key, 0))
	if current >= 20:
		loot_label.text = "Skill is already rank 20."
		return
	if skill_points <= 0:
		loot_label.text = "No skill points available."
		return
	skill_points -= 1
	skill_ranks[key] = current + 1
	loot_label.text = "Ranked up " + get_skill(index)["name"] + " to rank " + str(skill_ranks[key]) + "."
	update_hud()
	update_character_ui()
	save_game()

func rank_down_skill(index: int) -> void:
	var key = get_skill_key(index)
	var current = int(skill_ranks.get(key, 0))
	if current <= 0:
		return
	skill_ranks[key] = current - 1
	skill_points += 1
	loot_label.text = "Refunded one rank from " + get_skill(index)["name"] + "."
	update_hud()
	update_character_ui()
	save_game()

func rank_up_passive(name: String) -> void:
	var current = int(passive_ranks.get(name, 0))
	if current >= 10:
		loot_label.text = name + " is already rank 10."
		return
	if passive_points <= 0:
		loot_label.text = "No passive points available."
		return
	passive_points -= 1
	passive_ranks[name] = current + 1
	recalculate_stats()
	loot_label.text = "Passive upgraded: " + name + " " + str(passive_ranks[name]) + "/10."
	update_hud()
	update_character_ui()
	save_game()

func rank_down_passive(name: String) -> void:
	var current = int(passive_ranks.get(name, 0))
	if current <= 0:
		return
	passive_ranks[name] = current - 1
	passive_points += 1
	recalculate_stats()
	loot_label.text = "Refunded passive: " + name + "."
	update_hud()
	update_character_ui()
	save_game()

func get_build_analysis() -> String:
	var clear_score = int(move_speed / 20.0) + int(attack_speed_bonus * 100.0) + int(magic_find_bonus * 100.0)
	var boss_score = damage + int(crit_chance * 100.0) + int(crit_damage * 25.0) + int(cooldown_reduction * 100.0)
	var tank_score = max_hp / 10 + armor + int(health_regen * 5.0)

	var build_type := "Hybrid"
	if clear_score > boss_score and clear_score > tank_score:
		build_type = "Speed Farmer"
	elif boss_score > clear_score and boss_score > tank_score:
		build_type = "Boss Killer"
	elif tank_score > clear_score and tank_score > boss_score:
		build_type = "Tank"

	var primary := "Strength"
	if dexterity >= strength and dexterity >= intellect and dexterity >= willpower:
		primary = "Dexterity"
	elif intellect >= strength and intellect >= dexterity and intellect >= willpower:
		primary = "Intellect"
	elif willpower >= strength and willpower >= dexterity and willpower >= intellect:
		primary = "Willpower"

	var text := "BUILD ANALYSIS\n"
	text += "Build Type: " + build_type + "\n"
	text += "Primary Stat: " + primary + "\n\n"
	text += "Clear Speed Score: " + str(clear_score) + "\n"
	text += "Boss Damage Score: " + str(boss_score) + "\n"
	text += "Survival Score: " + str(tank_score) + "\n\n"
	text += "Movement Speed: " + str(int(move_speed)) + "\n"
	text += "Attack Speed Bonus: " + str(int(attack_speed_bonus * 100)) + "%\n"
	text += "Cooldown Reduction: " + str(int(cooldown_reduction * 100)) + "%\n"
	text += "Pickup Radius: +" + str(int(pickup_radius)) + "\n"
	return text

func update_character_ui() -> void:
	if character_label == null:
		return

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
		text += "SKILLS\n"
		text += "Skill Points: " + str(skill_points) + "\n"
		text += "Press 1-4 while this tab is open to rank up skills.\n"
		text += "Hold SHIFT + 1-4 to refund one rank.\n\n"
		for i in range(4):
			var sk = get_skill(i)
			var rank = get_skill_rank(i)
			text += str(i + 1) + ") " + sk["name"] + " Rank " + str(rank) + "/20\n"
			text += "   Damage: " + str(int(sk["mult"] * 100 * max(1, rank) / 1.0)) + "% | Mana: " + str(get_skill_cost(i)) + " | CD: " + str(get_skill_cooldown(i)) + "s\n"
		text += "\nCombat Bar:\nRMB = " + get_skill(get_combat_slot_skill_index("RMB"))["name"] + "\n1-4 = Active skill slots\nFuture: manual assignment buttons and ultimate slot."

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

func select_inventory_item(index: int) -> void:
	if index < 0 or index >= inventory.size():
		selected_inventory_index = -1
		loot_label.text = "Empty inventory slot."
		update_inventory_ui()
		update_character_ui()
		return

	selected_inventory_index = index
	loot_label.text = "Selected item:\n" + item_to_text(inventory[index]) + "\nNow click the matching equipment slot."
	update_inventory_ui()
	update_character_ui()


func equip_selected_inventory_item() -> void:
	if selected_inventory_index < 0 or selected_inventory_index >= inventory.size():
		loot_label.text = "No inventory item selected."
		return
	equip_item_from_inventory(selected_inventory_index)
	selected_inventory_index = -1
	update_inventory_ui()

func use_health_potion() -> void:
	if health_potions <= 0:
		loot_label.text = "No health potions."
		return
	if hp >= max_hp:
		loot_label.text = "Health is already full."
		return
	health_potions -= 1
	var amount = int(max_hp * (0.45 + potion_effect_bonus))
	hp = min(max_hp, hp + amount)
	spawn_floating_text("+" + str(amount) + " HP", player.position + Vector2(0, -50), true)
	loot_label.text = "Used health potion."
	update_hud()
	save_game()

func use_mana_potion() -> void:
	if mana_potions <= 0:
		loot_label.text = "No mana potions."
		return
	if mana >= max_mana:
		loot_label.text = "Mana is already full."
		return
	mana_potions -= 1
	var amount = int(max_mana * (0.45 + potion_effect_bonus))
	mana = min(max_mana, mana + amount)
	spawn_floating_text("+" + str(amount) + " Mana", player.position + Vector2(0, -50), true)
	loot_label.text = "Used mana potion."
	update_hud()
	save_game()


func activate_utility_flask(kind: String) -> void:
	var duration := 10.0 * (1.0 + potion_duration_bonus)
	var effect := {"kind": kind, "time": duration}
	active_flask_effects.append(effect)
	if kind == "Iron Skin":
		loot_label.text = "Iron Skin Flask active: +40% Armor."
	elif kind == "Lucky":
		loot_label.text = "Lucky Flask active: +20% Magic Find."
	elif kind == "Berserker":
		loot_label.text = "Berserker Flask active: +25% Damage."
	elif kind == "Shadow":
		loot_label.text = "Shadow Flask active: +20% Movement Speed."
	recalculate_stats()
	update_hud()

func update_flask_effects(delta: float) -> void:
	var changed := false
	for f in active_flask_effects.duplicate():
		f["time"] -= delta
		if f["time"] <= 0:
			active_flask_effects.erase(f)
			changed = true
	if changed:
		recalculate_stats()
		update_hud()

func has_flask(kind: String) -> bool:
	for f in active_flask_effects:
		if f["kind"] == kind:
			return true
	return false

func add_potion(kind: String, amount: int = 1) -> void:
	if kind == "Health":
		health_potions = min(max_health_potions, health_potions + amount)
	elif kind == "Mana":
		mana_potions = min(max_mana_potions, mana_potions + amount)
	update_hud()
	save_game()

func update_regen(delta: float) -> void:
	regen_timer += delta
	if regen_timer < 1.0:
		return
	regen_timer = 0.0
	if health_regen > 0 and hp < max_hp:
		hp = min(max_hp, hp + int(health_regen))
	if mana_regen > 0 and mana < max_mana:
		mana = min(max_mana, mana + int(mana_regen))
	update_hud()

func update_player(_delta: float) -> void:
	if selected_enemy != null and is_instance_valid(selected_enemy["body"]):
		target_pos = selected_enemy["body"].position

	var dist := player.position.distance_to(target_pos)
	if dist > 8:
		var dir := player.position.direction_to(target_pos)
		player.velocity = dir * move_speed
	else:
		player.velocity = Vector2.ZERO
	player.move_and_slide()

func update_enemies(_delta: float) -> void:
	for e in enemies.duplicate():
		if not is_instance_valid(e["body"]):
			enemies.erase(e)
			continue

		var body: CharacterBody2D = e["body"]
		var dist := body.position.distance_to(player.position)

		if dist < e["aggro"] and dist > 45:
			body.velocity = body.position.direction_to(player.position) * e["speed"]
		else:
			body.velocity = Vector2.ZERO
		body.move_and_slide()

		if dist <= 45:
			var now := Time.get_ticks_msec() / 1000.0
			if now - e["last_attack"] >= e["attack_speed"]:
				e["last_attack"] = now
				take_player_damage(e["damage"])

func try_auto_attack() -> void:
	if selected_enemy == null:
		return
	if not is_instance_valid(selected_enemy["body"]):
		selected_enemy = null
		return
	if player.position.distance_to(selected_enemy["body"].position) > attack_range:
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < attack_cooldown:
		return

	last_attack_time = now
	var result = calculate_damage_result(1.0)
	damage_enemy(selected_enemy, result["amount"], result["crit"])

func get_enemy_at_position(pos: Vector2):
	for e in enemies:
		if is_instance_valid(e["body"]) and e["body"].position.distance_to(pos) < e["click_radius"]:
			return e
	return null

func get_ground_item_at_position(pos: Vector2):
	for item in ground_items:
		if is_instance_valid(item["body"]) and item["body"].visible and item["body"].position.distance_to(pos) < 32:
			return item
	return null


func has_power(power_id: String) -> bool:
	return equipped_legendary_powers.has(power_id)

func trigger_chain_lightning(source_enemy, pos: Vector2) -> void:
	var hits := 0
	spawn_floating_text("CHAIN", pos + Vector2(0, -60), true)
	for enemy in enemies.duplicate():
		if hits >= 3:
			return
		if enemy == source_enemy:
			continue
		if is_instance_valid(enemy["body"]) and enemy["body"].position.distance_to(pos) < 180:
			if not enemy.get("is_dead", false):
				hits += 1
				damage_enemy(enemy, int(damage * 0.65), false)

func trigger_enemy_explosion(pos: Vector2) -> void:
	spawn_floating_text("BOOM", pos + Vector2(0, -45), true)
	for enemy in enemies.duplicate():
		if is_instance_valid(enemy["body"]) and enemy["body"].position.distance_to(pos) < 110:
			if not enemy.get("is_dead", false):
				damage_enemy(enemy, int(damage * 1.2), false)

func calculate_damage_result(mult: float) -> Dictionary:
	var d := float(damage)
	if has_power("berserker") and hp < max_hp * 0.5:
		d *= 1.35
	var is_crit := false
	if randf() < crit_chance:
		d *= crit_damage
		is_crit = true
	return {"amount": int(d * mult), "crit": is_crit}

func damage_enemy(e, amount: int, is_crit: bool) -> void:
	if e == null:
		return
	if e.has("is_dead") and e["is_dead"]:
		return
	if not e.has("body") or not is_instance_valid(e["body"]):
		return

	e["hp"] -= amount
	var hit_pos = e["body"].position
	spawn_floating_text(str(amount) + (" CRIT!" if is_crit else ""), hit_pos + Vector2(0, -35), is_crit)

	if has_power("vampiric"):
		hp = min(max_hp, hp + max(1, int(amount * 0.05)))
	if is_crit and has_power("frost_nova_crit"):
		trigger_enemy_explosion(hit_pos)
	if has_power("chain_lightning") and randf() < 0.15:
		trigger_chain_lightning(e, hit_pos)

	if e.has("shape") and is_instance_valid(e["shape"]):
		e["shape"].color = Color(1.0, 0.45, 0.45)

	await get_tree().create_timer(0.07).timeout

	if e == null:
		return
	if e.has("is_dead") and e["is_dead"]:
		return

	if e.has("shape") and is_instance_valid(e["shape"]):
		e["shape"].color = e["color"]

	if e["hp"] <= 0:
		kill_enemy(e)

func kill_enemy(e) -> void:
	if e == null:
		return
	if e.has("is_dead") and e["is_dead"]:
		return
	e["is_dead"] = true

	var drop_pos := Vector2.ZERO
	if e.has("body") and is_instance_valid(e["body"]):
		drop_pos = e["body"].position
		e["body"].queue_free()
	else:
		return

	if e == active_boss:
		active_boss = null
		boss_panel.visible = false

	enemies.erase(e)
	gain_xp(e["xp"])
	var gold_drop = randi_range(5, 18) * max(1, e["level"])
	if e["is_elite"]:
		gold_drop *= 3
	if e["is_boss"]:
		gold_drop *= 10
	if has_power("treasure_hunter"):
		gold_drop = int(gold_drop * 1.4)
	gold += gold_drop
	spawn_floating_text("+" + str(gold_drop) + " Gold", drop_pos + Vector2(0, -55), true)

	if randf() < 0.18:
		if randf() < 0.5:
			add_potion("Health", 1)
			spawn_floating_text("+Health Potion", drop_pos + Vector2(0, -75), true)
		else:
			add_potion("Mana", 1)
			spawn_floating_text("+Mana Potion", drop_pos + Vector2(0, -75), true)

	var drops := 1
	if e["is_elite"]:
		drops = 2
	if e["is_boss"]:
		drops = 3

	for i in range(drops):
		if e["is_boss"] or randf() < 0.75:
			var item := generate_item(e["is_boss"])
			spawn_ground_item(item, drop_pos + Vector2(randf_range(-35, 35), randf_range(-35, 35)))
			loot_label.text = "Item dropped:\n" + item_to_text(item)

	if e["is_boss"]:
		try_unique_boss_drop(e["name"], drop_pos)
		loot_label.text = "BOSS DEFEATED!\n" + loot_label.text

	if has_power("explosive") or has_power("infernal_explosion"):
		trigger_enemy_explosion(drop_pos)
	if has_power("blood_armor"):
		hp = min(max_hp, hp + int(max_hp * 0.05))

	update_hud()

func take_player_damage(amount: int) -> void:
	var final_damage = max(1, amount - armor)
	hp = max(0, hp - final_damage)
	spawn_floating_text(str(final_damage), player.position + Vector2(0, -35), false)
	if hp <= 0:
		hp = max_hp
		mana = max_mana
		player.position = Vector2(420, 720)
		target_pos = player.position
		loot_label.text = "You died and respawned in town."
	update_hud()

func spawn_floating_text(text: String, pos: Vector2, crit: bool) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", 18 if not crit else 24)
	label.modulate = Color(1.0, 0.95, 0.35) if crit else Color(1.0, 1.0, 1.0)
	add_child(label)
	floating_texts.append({"node": label, "time": 0.0})

func update_floating_texts(delta: float) -> void:
	for f in floating_texts.duplicate():
		if not is_instance_valid(f["node"]):
			floating_texts.erase(f)
			continue
		f["time"] += delta
		f["node"].position.y -= 40 * delta
		f["node"].modulate.a = max(0.0, 1.0 - f["time"])
		if f["time"] >= 1.0:
			f["node"].queue_free()
			floating_texts.erase(f)

func get_skill_cost(index: int) -> int:
	var skill := get_skill(index)
	var rank = max(1, get_skill_rank(index))
	return max(1, int(float(skill["cost"]) * (1.0 + float(rank - 1) * 0.04)))

func get_skill_cooldown(index: int) -> float:
	var skill := get_skill(index)
	var cd = float(skill["cooldown"]) * (1.0 - cooldown_reduction)
	return max(0.1, snapped(cd, 0.01))

func get_skill_mult(index: int) -> float:
	var skill := get_skill(index)
	var rank = max(1, get_skill_rank(index))
	return float(skill["mult"]) * (1.0 + float(rank - 1) * 0.05)

func get_combat_slot_skill_index(slot_name: String) -> int:
	return int(combat_skill_slots.get(slot_name, 0))

func use_combat_slot(slot_name: String) -> void:
	var index = get_combat_slot_skill_index(slot_name)
	if index < 0 or index > 3:
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
	if skill_index < 0 or skill_index > 3:
		return
	if not combat_skill_slots.has(slot_name):
		return
	combat_skill_slots[slot_name] = skill_index
	loot_label.text = "Assigned " + get_skill(skill_index)["name"] + " to " + slot_name + "."
	update_hud()
	update_character_ui()
	save_game()

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
	elif skill["type"] == "heal":
		hp = min(max_hp, hp + int(max_hp * 0.35))
		spawn_floating_text("HEAL", player.position + Vector2(0, -35), true)
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

func is_skill_unlocked(index: int) -> bool:
	var unlock_levels := [1, 5, 10, 20]
	return level >= unlock_levels[index]

func get_skill(index: int) -> Dictionary:
	var sets = {
		"Warrior": [
			{"name":"Cleave", "cost":8, "cooldown":1.0, "mult":1.8, "range":80, "type":"damage"},
			{"name":"Charge", "cost":12, "cooldown":3.0, "mult":2.4, "range":180, "type":"dash"},
			{"name":"Ground Slam", "cost":18, "cooldown":5.0, "mult":3.0, "range":120, "type":"damage"},
			{"name":"Ragnarok", "cost":35, "cooldown":10.0, "mult":6.0, "range":220, "type":"damage"}
		],
		"Rogue": [
			{"name":"Poison Arrow", "cost":8, "cooldown":1.0, "mult":1.9, "range":260, "type":"damage"},
			{"name":"Dash", "cost":10, "cooldown":2.5, "mult":1.2, "range":200, "type":"dash"},
			{"name":"Fan of Knives", "cost":18, "cooldown":4.0, "mult":2.8, "range":130, "type":"damage"},
			{"name":"Endless Barrage", "cost":32, "cooldown":9.0, "mult":5.5, "range":300, "type":"damage"}
		],
		"Paladin": [
			{"name":"Smite", "cost":8, "cooldown":1.0, "mult":1.8, "range":100, "type":"damage"},
			{"name":"Heal", "cost":16, "cooldown":5.0, "mult":0.0, "range":0, "type":"heal"},
			{"name":"Consecration", "cost":22, "cooldown":5.0, "mult":3.0, "range":150, "type":"damage"},
			{"name":"Final Judgment", "cost":36, "cooldown":10.0, "mult":6.2, "range":240, "type":"damage"}
		],
		"Mage": [
			{"name":"Fireball", "cost":10, "cooldown":1.0, "mult":2.1, "range":300, "type":"damage"},
			{"name":"Teleport", "cost":14, "cooldown":3.0, "mult":0.0, "range":200, "type":"dash"},
			{"name":"Ice Nova", "cost":22, "cooldown":5.0, "mult":3.2, "range":160, "type":"damage"},
			{"name":"Apocalypse", "cost":42, "cooldown":11.0, "mult":7.0, "range":330, "type":"damage"}
		]
	}
	return sets[current_class][index]

func change_class() -> void:
	class_index = (class_index + 1) % classes.size()
	current_class = classes[class_index]
	apply_class_base_stats()
	recalculate_stats()
	loot_label.text = "Changed class to " + current_class
	update_hud()
	update_inventory_ui()
	update_character_ui()

func apply_class_base_stats() -> void:
	match current_class:
		"Warrior":
			base_hp = 160 + level * 12
			base_mana = 70 + level * 3
			base_damage = 14 + level * 3
			base_armor = 4 + level
			player_shape.color = Color(0.2, 0.7, 1.0)
		"Rogue":
			base_hp = 115 + level * 9
			base_mana = 95 + level * 4
			base_damage = 13 + level * 3
			base_armor = 2 + level
			player_shape.color = Color(0.1, 0.9, 0.35)
		"Paladin":
			base_hp = 150 + level * 11
			base_mana = 100 + level * 4
			base_damage = 12 + level * 2
			base_armor = 6 + level
			player_shape.color = Color(1.0, 0.85, 0.25)
		"Mage":
			base_hp = 90 + level * 7
			base_mana = 160 + level * 7
			base_damage = 17 + level * 4
			base_armor = 1 + int(level * 0.5)
			player_shape.color = Color(0.65, 0.25, 1.0)

func recalculate_stats() -> void:
	max_hp = base_hp
	max_mana = base_mana
	damage = base_damage
	armor = base_armor
	crit_chance = 0.05
	crit_damage = 1.5
	strength = 10
	dexterity = 10
	intellect = 10
	willpower = 10
	move_speed = 260.0
	attack_speed_bonus = 0.0
	cooldown_reduction = 0.0
	pickup_radius = 0.0
	health_regen = 0.0
	mana_regen = 0.0
	potion_capacity_bonus = 0
	potion_effect_bonus = 0.0
	potion_duration_bonus = 0.0
	equipped_legendary_powers.clear()
	magic_find_bonus = 0.0
	gold_find_bonus = 0.0

	for slot in equipment.keys():
		var item = equipment.get(slot, null)
		if item == null:
			continue
		for stat in item["stats"].keys():
			var value = item["stats"][stat]
			match stat:
				"Health":
					max_hp += value
				"Mana":
					max_mana += value
				"Damage":
					damage += value
				"Armor":
					armor += value
				"Crit Chance":
					crit_chance += float(value) / 100.0
				"Crit Damage":
					crit_damage += float(value) / 100.0
				"Movement Speed", "Attack Speed", "Cooldown Reduction", "Pickup Radius":
					move_speed += float(value)
				"Health Regen":
					health_regen += float(value)
				"Mana Regen":
					mana_regen += float(value)
				"Potion Capacity":
					potion_capacity_bonus += int(value)
				"Potion Effect":
					potion_effect_bonus += float(value) / 100.0
				"Potion Duration":
					potion_duration_bonus += float(value) / 100.0
				"Gold Find":
					gold_find_bonus += float(value) / 100.0
				"Magic Find":
					magic_find_bonus += float(value) / 100.0
				"Strength":
					strength += int(value)
				"Dexterity":
					dexterity += int(value)
				"Intellect":
					intellect += int(value)
				"Willpower":
					willpower += int(value)
				"Attack Speed":
					attack_speed_bonus += float(value) / 100.0
				"Cooldown Reduction":
					cooldown_reduction += float(value) / 100.0
				"Pickup Radius":
					pickup_radius += float(value)
		if item.has("power_id") and item["power_id"] != "":
			equipped_legendary_powers.append(item["power_id"])

	if has_power("stone_skin"):
		armor = int(armor * 1.25)
	if has_power("ancient_heart"):
		max_hp = int(max_hp * 1.5)
	if has_power("rootbound"):
		move_speed -= 25.0
	if has_power("swift_strikes"):
		attack_cooldown = 0.32
	else:
		attack_cooldown = 0.45
	if has_power("fortune"):
		magic_find_bonus += 0.15
	if has_power("treasure_hunter"):
		gold_find_bonus += 0.40

	attack_cooldown = max(0.12, attack_cooldown / (1.0 + attack_speed_bonus))

	if has_flask("Iron Skin"):
		armor = int(armor * 1.4)
	if has_flask("Lucky"):
		magic_find_bonus += 0.20
	if has_flask("Berserker"):
		damage = int(damage * 1.25)
	if has_flask("Shadow"):
		move_speed *= 1.2

	# Passive tree bonuses
	damage += int(passive_ranks.get("Damage Training", 0)) * 2
	armor += int(passive_ranks.get("Armor Training", 0)) * 3
	move_speed += float(passive_ranks.get("Movement Training", 0)) * 8.0
	attack_speed_bonus += float(passive_ranks.get("Attack Speed Training", 0)) * 0.03
	cooldown_reduction += float(passive_ranks.get("Cooldown Training", 0)) * 0.02
	crit_chance += float(passive_ranks.get("Crit Training", 0)) * 0.01
	cooldown_reduction = min(cooldown_reduction, 0.75)

	max_health_potions = 20 + potion_capacity_bonus
	max_mana_potions = 20 + potion_capacity_bonus
	health_potions = min(health_potions, max_health_potions)
	mana_potions = min(mana_potions, max_mana_potions)

	max_hp += strength * 2
	max_mana += intellect * 2
	damage += int(strength * 0.5) + int(intellect * 0.5)
	crit_chance += float(dexterity) / 1000.0
	health_regen += float(willpower) * 0.05
	mana_regen += float(willpower) * 0.05

	hp = min(hp, max_hp)
	mana = min(mana, max_mana)

func gain_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		level_up()
	update_hud()

func level_up() -> void:
	if level < 40:
		level += 1
		skill_points += 1
		passive_points += 1
		xp_to_next = int(xp_to_next * 1.18)
		apply_class_base_stats()
		recalculate_stats()
		hp = max_hp
		mana = max_mana
		loot_label.text = "LEVEL UP! You are now level " + str(level)
	else:
		paragon_level += 1
		paragon_points += 1
		base_damage += 1
		base_hp += 4
		recalculate_stats()
		hp = max_hp
		loot_label.text = "PARAGON UP! Paragon level " + str(paragon_level)

func enter_random_dungeon() -> void:
	pending_portal_interaction = false
	var themes := ["Hell", "Frozen Land", "Dark Forest"]
	current_theme = themes.pick_random()

	clear_enemies()
	clear_ground_items()
	clear_dungeon_geometry()
	clear_dungeon_geometry()

	var bg: ColorRect = $Background
	match current_theme:
		"Hell":
			bg.color = Color(0.09, 0.015, 0.01)
		"Frozen Land":
			bg.color = Color(0.015, 0.06, 0.09)
		"Dark Forest":
			bg.color = Color(0.01, 0.055, 0.025)

	generate_dungeon_layout()
	build_dungeon_geometry()
	populate_dungeon_rooms()

	if dungeon_rooms.size() > 0:
		player.position = dungeon_rooms[0]["center"]
		target_pos = player.position

	minimap_panel.visible = true
	loot_label.text = "Entered procedural dungeon: " + current_theme + "\nFind the boss room, defeat the boss, then return to town."
	update_hud()
	update_minimap()

func return_to_town() -> void:
	pending_portal_interaction = false
	current_theme = "Town"
	active_boss = null
	dungeon_generated = false
	boss_panel.visible = false
	minimap_panel.visible = false
	var bg: ColorRect = $Background
	bg.color = Color(0.07, 0.08, 0.09)

	clear_enemies()
	clear_ground_items()

	player.position = Vector2(420, 720)
	target_pos = player.position
	refresh_merchant_stock()
	save_game()
	loot_label.text = "Returned to town. Merchant stock refreshed and game saved."
	update_hud()
	update_merchant_ui()

func clear_enemies() -> void:
	for e in enemies.duplicate():
		if is_instance_valid(e["body"]):
			e["body"].queue_free()
	enemies.clear()

func clear_ground_items() -> void:
	for item in ground_items.duplicate():
		if is_instance_valid(item["body"]):
			item["body"].queue_free()
	ground_items.clear()
	loot_beams.clear()


func clear_dungeon_geometry() -> void:
	for n in dungeon_nodes:
		if is_instance_valid(n):
			n.queue_free()
	dungeon_nodes.clear()
	dungeon_rooms.clear()
	dungeon_corridors.clear()
	if exit_portal != null and is_instance_valid(exit_portal):
		exit_portal.queue_free()
	exit_portal = null

func generate_dungeon_layout() -> void:
	dungeon_generated = true
	var count := randi_range(8, 12)
	var grid_positions := []
	var current := Vector2i(0, 0)
	grid_positions.append(current)

	var directions := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	for i in range(count - 1):
		var tries := 0
		var next := current
		while tries < 30:
			next = current + directions.pick_random()
			if not grid_positions.has(next):
				break
			tries += 1
		grid_positions.append(next)
		current = next

	# recentre layout to screen
	var min_x = grid_positions[0].x
	var max_x = grid_positions[0].x
	var min_y = grid_positions[0].y
	var max_y = grid_positions[0].y
	for p in grid_positions:
		min_x = min(min_x, p.x)
		max_x = max(max_x, p.x)
		min_y = min(min_y, p.y)
		max_y = max(max_y, p.y)

	var spacing := Vector2(190, 135)
	var map_width = (max_x - min_x) * spacing.x
	var map_height = (max_y - min_y) * spacing.y
	var origin := Vector2(SCREEN_W / 2.0 - map_width / 2.0, SCREEN_H / 2.0 - map_height / 2.0)

	for i in range(grid_positions.size()):
		var gp = grid_positions[i]
		var room_type := "combat"
		if i == 0:
			room_type = "start"
		elif i == grid_positions.size() - 1:
			room_type = "boss"
		elif i == grid_positions.size() / 2:
			room_type = "treasure"
		elif i == int(grid_positions.size() * 0.7):
			room_type = "elite"

		var center = origin + Vector2((gp.x - min_x) * spacing.x, (gp.y - min_y) * spacing.y)
		dungeon_rooms.append({
			"grid": gp,
			"center": center,
			"type": room_type,
			"visited": false
		})

	for i in range(dungeon_rooms.size() - 1):
		dungeon_corridors.append({
			"from": dungeon_rooms[i]["center"],
			"to": dungeon_rooms[i + 1]["center"]
		})

func build_dungeon_geometry() -> void:
	for c in dungeon_corridors:
		create_corridor(c["from"], c["to"])

	for r in dungeon_rooms:
		create_room_rect(r["center"], r["type"])

	var boss_room = null
	for r in dungeon_rooms:
		if r["type"] == "boss":
			boss_room = r
			break

	if boss_room != null:
		create_exit_portal(boss_room["center"] + Vector2(0, 65))

func create_room_rect(center: Vector2, room_type: String) -> void:
	var rect := ColorRect.new()
	rect.position = center - room_size / 2.0
	rect.size = room_size

	match current_theme:
		"Hell":
			rect.color = Color(0.28, 0.045, 0.025)
		"Frozen Land":
			rect.color = Color(0.05, 0.17, 0.24)
		"Dark Forest":
			rect.color = Color(0.035, 0.16, 0.06)

	if room_type == "start":
		rect.color = Color(0.12, 0.12, 0.12)
	elif room_type == "treasure":
		rect.color = Color(0.22, 0.18, 0.04)
	elif room_type == "elite":
		rect.color = Color(0.04, 0.06, 0.22)
	elif room_type == "boss":
		rect.color = Color(0.25, 0.02, 0.02)

	add_child(rect)
	move_child(rect, 1)
	dungeon_nodes.append(rect)

	var label := Label.new()
	label.position = center + Vector2(-55, -10)
	label.text = room_type.to_upper()
	add_child(label)
	move_child(label, 2)
	dungeon_nodes.append(label)

func create_corridor(a: Vector2, b: Vector2) -> void:
	var mid := (a + b) / 2.0
	var rect := ColorRect.new()

	if abs(a.x - b.x) > abs(a.y - b.y):
		rect.position = Vector2(min(a.x, b.x), mid.y - 18)
		rect.size = Vector2(abs(a.x - b.x), 36)
	else:
		rect.position = Vector2(mid.x - 18, min(a.y, b.y))
		rect.size = Vector2(36, abs(a.y - b.y))

	rect.color = Color(0.09, 0.09, 0.09)
	add_child(rect)
	move_child(rect, 1)
	dungeon_nodes.append(rect)

func create_exit_portal(pos: Vector2) -> void:
	exit_portal = Area2D.new()
	exit_portal.name = "ExitPortal"
	exit_portal.position = pos
	add_child(exit_portal)
	dungeon_nodes.append(exit_portal)

	var shape := Polygon2D.new()
	shape.polygon = PackedVector2Array([Vector2(0, -24), Vector2(22, 0), Vector2(0, 24), Vector2(-22, 0)])
	shape.color = Color(0.2, 1.0, 0.75)
	exit_portal.add_child(shape)

	var label := Label.new()
	label.position = Vector2(-70, 28)
	label.text = "Exit Portal\nPress T"
	exit_portal.add_child(label)

func populate_dungeon_rooms() -> void:
	for r in dungeon_rooms:
		match r["type"]:
			"start":
				pass
			"treasure":
				for i in range(3):
					var item := generate_item(false)
					spawn_ground_item(item, r["center"] + Vector2(randf_range(-45, 45), randf_range(-25, 25)))
			"elite":
				for i in range(3):
					spawn_enemy(r["center"] + Vector2(randf_range(-45, 45), randf_range(-25, 25)), true, false)
			"boss":
				spawn_enemy(r["center"], false, true)
			_:
				var enemy_count := randi_range(3, 6)
				for i in range(enemy_count):
					var elite := randf() < 0.08
					spawn_enemy(r["center"] + Vector2(randf_range(-55, 55), randf_range(-35, 35)), elite, false)

func update_minimap() -> void:
	if minimap_label == null or current_theme == "Town" or dungeon_rooms.size() == 0:
		return

	for r in dungeon_rooms:
		if player.position.distance_to(r["center"]) < 120:
			r["visited"] = true

	var min_x = dungeon_rooms[0]["grid"].x
	var max_x = dungeon_rooms[0]["grid"].x
	var min_y = dungeon_rooms[0]["grid"].y
	var max_y = dungeon_rooms[0]["grid"].y
	for r in dungeon_rooms:
		min_x = min(min_x, r["grid"].x)
		max_x = max(max_x, r["grid"].x)
		min_y = min(min_y, r["grid"].y)
		max_y = max(max_y, r["grid"].y)

	var lines := []
	for y in range(min_y, max_y + 1):
		var line := ""
		for x in range(min_x, max_x + 1):
			var map_char := "·"
			for r in dungeon_rooms:
				if r["grid"] == Vector2i(x, y):
					if player.position.distance_to(r["center"]) < 120:
						map_char = "@"
					elif not r["visited"]:
						map_char = "?"
					elif r["type"] == "start":
						map_char = "S"
					elif r["type"] == "treasure":
						map_char = "$"
					elif r["type"] == "elite":
						map_char = "E"
					elif r["type"] == "boss":
						map_char = "B"
					else:
						map_char = "□"
					break
			line += map_char + " "
		lines.append(line)

	minimap_label.text = "\n".join(lines) + "\n\n@: You  S: Start\n$: Treasure  E: Elite\nB: Boss  ?: Unknown"

func spawn_enemy(pos: Vector2, is_elite := false, is_boss := false) -> void:
	var body := CharacterBody2D.new()
	body.position = pos
	add_child(body)

	var shape := Polygon2D.new()
	var size := 16
	if is_boss:
		size = 34
	elif is_elite:
		size = 22

	shape.polygon = PackedVector2Array([Vector2(0, -size), Vector2(size, 0), Vector2(0, size), Vector2(-size, 0)])

	var color := Color(0.9, 0.1, 0.1)
	if current_theme == "Frozen Land":
		color = Color(0.3, 0.8, 1.0)
	elif current_theme == "Dark Forest":
		color = Color(0.2, 0.75, 0.2)
	if is_elite:
		color = Color(0.25, 0.45, 1.0)
	if is_boss:
		color = Color(1.0, 0.2, 0.05)

	shape.color = color
	body.add_child(shape)

	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = size
	col.shape = circle
	body.add_child(col)

	var hp_bar := ProgressBar.new()
	hp_bar.position = Vector2(-32 if not is_boss else -55, -42 if not is_boss else -70)
	hp_bar.size = Vector2(64 if not is_boss else 110, 8)
	hp_bar.min_value = 0
	hp_bar.max_value = 100
	hp_bar.value = 100
	body.add_child(hp_bar)

	var name_label := Label.new()
	name_label.position = Vector2(-45 if not is_boss else -80, -62 if not is_boss else -94)
	name_label.size = Vector2(100 if not is_boss else 170, 18)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(name_label)

	var enemy_level = max(1, level + randi_range(-1, 2))
	var base_enemy_hp = 50 + enemy_level * 18
	var base_enemy_damage = 6 + enemy_level * 3
	var enemy_name = get_normal_enemy_name()

	if is_elite:
		base_enemy_hp *= 3
		base_enemy_damage *= 2
		enemy_name = get_elite_prefix() + " " + enemy_name

	if is_boss:
		base_enemy_hp *= 10
		base_enemy_damage *= 5
		enemy_name = get_boss_name()
		active_boss = null

	var enemy = {
		"body": body,
		"shape": shape,
		"hp_bar": hp_bar,
		"name_label": name_label,
		"color": color,
		"name": enemy_name,
		"level": enemy_level,
		"hp": base_enemy_hp,
		"max_hp": base_enemy_hp,
		"damage": base_enemy_damage,
		"speed": 95.0 + enemy_level if not is_boss else 70.0,
		"xp": 35 + enemy_level * 8,
		"last_attack": -999.0,
		"attack_speed": 1.0 if not is_boss else 1.4,
		"aggro": 350 if not is_boss else 500,
		"click_radius": size + 12,
		"is_elite": is_elite,
		"is_boss": is_boss,
		"is_dead": false
	}

	if is_elite:
		enemy["xp"] *= 3
	if is_boss:
		enemy["xp"] *= 10
		active_boss = enemy

	name_label.text = enemy_name + " Lv." + str(enemy_level)
	enemies.append(enemy)

func spawn_boss() -> void:
	var boss_pos := Vector2(randf_range(750, 1050), randf_range(180, 620))
	spawn_enemy(boss_pos, false, true)

func get_normal_enemy_name() -> String:
	match current_theme:
		"Hell":
			return ["Demon", "Imp", "Hell Knight", "Ash Fiend"].pick_random()
		"Frozen Land":
			return ["Frost Wolf", "Ice Witch", "Frozen Guard", "Snow Beast"].pick_random()
		"Dark Forest":
			return ["Corrupted Treant", "Spider", "Werewolf", "Rot Stalker"].pick_random()
	return "Enemy"

func get_elite_prefix() -> String:
	return ["Frozen", "Burning", "Vampiric", "Arcane", "Brutal", "Cursed"].pick_random()

func get_boss_name() -> String:
	match current_theme:
		"Hell":
			return "Infernal Warden"
		"Frozen Land":
			return "Frost Titan"
		"Dark Forest":
			return "Corrupted Ancient"
	return "Dungeon Boss"

func update_enemy_health_bars() -> void:
	for e in enemies:
		if not is_instance_valid(e["body"]):
			continue
		var percent = clamp(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
		e["hp_bar"].value = percent * 100.0
		e["hp_bar"].visible = percent < 1.0 or e["is_boss"] or e["is_elite"]

func update_boss_ui() -> void:
	if active_boss == null or not is_instance_valid(active_boss["body"]):
		boss_panel.visible = false
		return

	boss_panel.visible = true
	boss_name_label.text = active_boss["name"] + " Lv." + str(active_boss["level"])
	boss_hp_bar.value = clamp(float(active_boss["hp"]) / float(active_boss["max_hp"]), 0.0, 1.0) * 100.0

func spawn_ground_item(item: Dictionary, pos: Vector2) -> void:
	var body := Node2D.new()
	body.position = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
	add_child(body)

	var shape := Polygon2D.new()
	shape.polygon = PackedVector2Array([Vector2(0, -10), Vector2(12, 0), Vector2(0, 10), Vector2(-12, 0)])
	shape.color = get_rarity_color(item["rarity"])
	body.add_child(shape)

	var label := Label.new()
	label.position = Vector2(-65, 15)
	label.text = item["name"]
	label.modulate = get_rarity_color(item["rarity"])
	body.add_child(label)

	if item["rarity"] in ["Rare", "Legendary", "Godlike", "Unique"]:
		create_loot_beam(body, item["rarity"])

	var ground_item = {
		"body": body,
		"shape": shape,
		"label": label,
		"item": item
	}
	ground_items.append(ground_item)
	update_ground_item_visibility(ground_item)


func create_loot_beam(parent: Node2D, rarity: String) -> void:
	var beam := ColorRect.new()
	var width := 8
	var height := 95
	if rarity == "Legendary":
		width = 12
		height = 130
	elif rarity == "Godlike" or rarity == "Unique":
		width = 16
		height = 165

	beam.position = Vector2(-width / 2, -height)
	beam.size = Vector2(width, height)
	beam.color = get_rarity_color(rarity)
	beam.color.a = 0.55
	parent.add_child(beam)
	loot_beams.append({"node": beam, "time": randf() * 10.0})

func update_loot_beams(delta: float) -> void:
	for b in loot_beams.duplicate():
		if not is_instance_valid(b["node"]):
			loot_beams.erase(b)
			continue
		b["time"] += delta
		var pulse = 0.35 + abs(sin(b["time"] * 4.0)) * 0.45
		b["node"].color.a = pulse

func pickup_ground_item(ground_item) -> void:
	if inventory.size() >= max_inventory_size:
		loot_label.text = "Inventory full."
		return

	inventory.append(ground_item["item"])
	if is_instance_valid(ground_item["body"]):
		ground_item["body"].queue_free()
	ground_items.erase(ground_item)
	var item = ground_item["item"]
	if item["rarity"] in ["Legendary", "Godlike", "Unique"]:
		loot_label.text = item["rarity"].to_upper() + " PICKED UP!\n" + item_to_text(item)
	else:
		loot_label.text = "Picked up:\n" + item_to_text(item)
	update_inventory_ui()
	save_game()

func equip_item_from_inventory(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return

	var item = inventory[index]
	var slot = item["slot"]

	if slot == "Ring":
		if equipment.get("Ring1", null) == null:
			equip_item_to_specific_slot(index, "Ring1")
		else:
			equip_item_to_specific_slot(index, "Ring2")
		return

	if equipment.has(slot):
		equip_item_to_specific_slot(index, slot)



func make_unique_item(boss_name: String = "") -> Dictionary:
	var boss = boss_name
	if boss == "" or not unique_items.has(boss):
		boss = unique_items.keys().pick_random()
	var base = unique_items[boss].pick_random().duplicate(true)
	base["level"] = level
	base["special"] = base["power_name"] + ": " + base["power_desc"]
	base["price"] = 1000 + level * 50
	base["upgrade"] = 0
	return base

func try_unique_boss_drop(boss_name: String, drop_pos: Vector2) -> bool:
	if not unique_items.has(boss_name):
		return false
	if randf() <= 0.35:
		var unique = make_unique_item(boss_name)
		spawn_ground_item(unique, drop_pos + Vector2(randf_range(-45, 45), randf_range(-45, 45)))
		loot_label.text = "UNIQUE BOSS ITEM FOUND!\n" + item_to_text(unique)
		return true
	return false

func roll_rarity(use_boss_table := false) -> Dictionary:
	var table = rarity_table_boss if use_boss_table else rarity_table_normal
	var total := 0
	for r in table:
		total += int(r["weight"])

	var roll := randi_range(1, total)
	var cursor := 0
	for r in table:
		cursor += int(r["weight"])
		if roll <= cursor:
			return r
	return table[0]

func generate_item(use_boss_table := false) -> Dictionary:
	var rarity := roll_rarity(use_boss_table)

	var slot_table := {
		"Weapon": {
			"Warrior": ["Iron Sword", "Steel Axe", "Warhammer", "Executioner Blade", "Battle Mace"],
			"Rogue": ["Assassin Dagger", "Hunting Bow", "Shadow Blade", "Twin Knife", "Silent Edge"],
			"Paladin": ["Blessed Hammer", "Templar Mace", "Holy Sword", "Judicator Scepter", "Crusader Blade"],
			"Mage": ["Apprentice Wand", "Archmage Staff", "Void Rod", "Crystal Wand", "Spellblade"]
		},
		"Offhand": {
			"Warrior": ["Round Shield", "War Buckler", "Iron Guard"],
			"Rogue": ["Parrying Dagger", "Smoke Focus", "Throwing Quiver"],
			"Paladin": ["Templar Shield", "Sacred Relic", "Blessed Guard"],
			"Mage": ["Arcane Tome", "Crystal Orb", "Mana Focus"]
		},
		"Helmet": ["Helmet", "Helm", "Crown", "Hood", "Mask", "Greathelm"],
		"Chest": ["Chestplate", "Armor", "Robe", "Breastplate", "Cuirass", "Vestment"],
		"Gloves": ["Gloves", "Gauntlets", "Handwraps", "Grips", "Claws"],
		"Boots": ["Boots", "Greaves", "Sabatons", "Treads", "Footguards"],
		"Ring": ["Ring", "Band", "Loop", "Signet", "Seal"],
		"Amulet": ["Amulet", "Pendant", "Charm", "Talisman", "Medallion"],
		"Belt": ["Cloth Belt", "Adventurer Belt", "War Belt", "Champion Belt", "Alchemist Belt", "Eternal Belt"]
	}

	var slot_stats := {
		"Weapon": ["Damage", "Damage", "Crit Chance", "Crit Damage"],
		"Offhand": ["Armor", "Health", "Mana", "Crit Chance"],
		"Helmet": ["Armor", "Health", "Mana"],
		"Chest": ["Armor", "Armor", "Health", "Health"],
		"Gloves": ["Damage", "Crit Chance", "Crit Damage", "Armor"],
		"Boots": ["Movement Speed", "Attack Speed", "Cooldown Reduction", "Pickup Radius", "Armor", "Health"],
		"Ring": ["Crit Chance", "Crit Damage", "Damage", "Mana", "Health"],
		"Amulet": ["Damage", "Mana", "Health", "Crit Damage", "Crit Chance"],
		"Belt": ["Health", "Armor", "Potion Capacity", "Potion Effect", "Potion Duration", "Gold Find", "Magic Find"]
	}

	var prefixes := ["Ancient", "Blood", "Doom", "Storm", "Frozen", "Burning", "Shadow", "Holy", "Savage", "Eternal"]
	var slots := slot_table.keys()
	var slot = slots.pick_random()

	var base_name = ""
	if slot in ["Weapon", "Offhand"]:
		base_name = slot_table[slot][current_class].pick_random()
	else:
		base_name = slot_table[slot].pick_random()

	var item_name = "%s %s" % [prefixes.pick_random(), base_name]
	var stats := {}
	var possible_stats: Array = []
	possible_stats.append_array(slot_stats[slot])

	if current_class == "Mage":
		possible_stats.append_array(["Mana", "Mana", "Damage", "Crit Damage"])
	elif current_class == "Rogue":
		possible_stats.append_array(["Crit Chance", "Crit Chance", "Crit Damage", "Movement Speed", "Attack Speed", "Cooldown Reduction", "Pickup Radius"])
	elif current_class == "Warrior":
		possible_stats.append_array(["Health", "Armor", "Damage"])
	elif current_class == "Paladin":
		possible_stats.append_array(["Health", "Armor", "Mana", "Damage"])

	for i in range(int(rarity["stats"])):
		var stat = possible_stats.pick_random()
		var value = int(randf_range(2, 8) * max(1, level) * float(rarity["power"]))

		if stat in ["Health Regen", "Mana Regen"]:
			value = int(randf_range(1, 4) * float(rarity["power"]))
		elif stat == "Potion Capacity":
			value = int(randf_range(1, 3) * float(rarity["power"]))
		elif stat in ["Potion Effect", "Potion Duration", "Gold Find", "Magic Find"]:
			value = int(randf_range(5, 15) * float(rarity["power"]))
		elif stat == "Damage" and slot == "Weapon":
			value = int(randf_range(4, 11) * max(1, level) * float(rarity["power"]))
		elif stat == "Armor" and slot in ["Chest", "Helmet", "Offhand"]:
			value = int(randf_range(4, 10) * max(1, level) * float(rarity["power"]))
		elif stat in ["Crit Chance", "Movement Speed", "Attack Speed", "Cooldown Reduction", "Pickup Radius"]:
			value = int(randf_range(1, 4) * float(rarity["power"]))
		elif stat == "Crit Damage":
			value = int(randf_range(5, 12) * float(rarity["power"]))

		stats[stat] = stats.get(stat, 0) + value

	var special := ""
	var power_id := ""
	var power_name := ""
	var power_desc := ""
	if rarity["name"] == "Legendary":
		var p = legendary_powers.pick_random()
		power_id = p["id"]
		power_name = p["name"]
		power_desc = p["desc"]
		special = power_name + ": " + power_desc
	elif rarity["name"] == "Godlike":
		var p = legendary_powers.pick_random()
		power_id = p["id"]
		power_name = "Godlike " + p["name"]
		power_desc = p["desc"] + " Power is greatly amplified."
		special = power_name + ": " + power_desc

	var price = int((25 + level * 12) * float(rarity["power"]))

	return {
		"name": item_name,
		"slot": slot,
		"rarity": rarity["name"],
		"level": level,
		"stats": stats,
		"special": special,
		"power_id": power_id,
		"power_name": power_name,
		"power_desc": power_desc,
		"price": price,
		"upgrade": 0
	}

func item_to_text(item: Dictionary) -> String:
	var upgrade_text = ""
	if item.has("upgrade") and int(item["upgrade"]) > 0:
		upgrade_text = " +" + str(item["upgrade"])
	var text := "%s%s [%s]\nSlot: %s | Lv.%d | Value: %d gold\n" % [
		item["name"],
		upgrade_text,
		item["rarity"],
		item["slot"],
		item["level"],
		get_item_price(item)
	]

	for stat in item["stats"].keys():
		text += "+%s %s\n" % [str(item["stats"][stat]), stat]

	if item.has("power_name") and item["power_name"] != "":
		text += "POWER: %s\n%s\n" % [item["power_name"], item.get("power_desc", "")]
	elif item["special"] != "":
		text += "Special: %s\n" % item["special"]

	return text

func get_rarity_color(rarity: String) -> Color:
	match rarity:
		"Common":
			return Color(0.8, 0.8, 0.8)
		"Uncommon":
			return Color(0.2, 1.0, 0.2)
		"Magic":
			return Color(0.25, 0.55, 1.0)
		"Rare":
			return Color(1.0, 0.9, 0.2)
		"Legendary":
			return Color(1.0, 0.45, 0.05)
		"Godlike":
			return Color(1.0, 0.1, 1.0)
		"Unique":
			return Color(0.75, 0.35, 1.0)
	return Color.WHITE


func get_item_price(item: Dictionary) -> int:
	if item.has("price"):
		return int(item["price"])
	return 25 + int(item["level"]) * 10

func refresh_merchant_stock() -> void:
	merchant_stock.clear()
	for i in range(8):
		var item := generate_item(false)
		item["price"] = int(get_item_price(item) * 1.5)
		merchant_stock.append(item)


func get_rarity_rank(rarity: String) -> int:
	match rarity:
		"Common":
			return 1
		"Uncommon":
			return 2
		"Magic":
			return 3
		"Rare":
			return 4
		"Legendary":
			return 5
		"Unique":
			return 6
		"Godlike":
			return 7
	return 0

func get_slot_rank(slot: String) -> int:
	match slot:
		"Weapon":
			return 1
		"Offhand":
			return 2
		"Helmet":
			return 3
		"Chest":
			return 4
		"Gloves":
			return 5
		"Boots":
			return 6
		"Ring":
			return 7
		"Amulet":
			return 8
		"Belt":
			return 9
	return 99

func compare_inventory_items(a: Dictionary, b: Dictionary) -> bool:
	var ar = get_slot_rank(str(a.get("slot", "")))
	var br = get_slot_rank(str(b.get("slot", "")))
	if ar != br:
		return ar < br

	var rr_a = get_rarity_rank(str(a.get("rarity", "")))
	var rr_b = get_rarity_rank(str(b.get("rarity", "")))
	if rr_a != rr_b:
		return rr_a > rr_b

	var lvl_a = int(a.get("level", 0))
	var lvl_b = int(b.get("level", 0))
	if lvl_a != lvl_b:
		return lvl_a > lvl_b

	return str(a.get("name", "")) < str(b.get("name", ""))

func sort_inventory() -> void:
	inventory.sort_custom(compare_inventory_items)
	selected_inventory_index = -1
	loot_label.text = "Inventory sorted by slot, rarity, level, and name."
	update_inventory_ui()
	update_character_ui()
	save_game()

func sell_selected_item() -> void:
	if not merchant_open:
		loot_label.text = "Open the Merchant to sell items."
		return
	if selected_inventory_index < 0 or selected_inventory_index >= inventory.size():
		loot_label.text = "Select an inventory item first, then press Sell Selected at the Merchant."
		return

	var item = inventory[selected_inventory_index]
	var value = get_item_price(item)
	gold += value
	inventory.remove_at(selected_inventory_index)
	selected_inventory_index = -1
	loot_label.text = "Sold item for " + str(value) + " gold:\n" + item["name"]
	update_hud()
	update_inventory_ui()
	update_character_ui()
	update_merchant_ui()
	save_game()

func buy_potion(kind: String) -> void:
	var cost := 25
	if gold < cost:
		loot_label.text = "Not enough gold for potion."
		return
	gold -= cost
	add_potion(kind, 1)
	loot_label.text = "Bought " + kind + " Potion for 25 gold."
	update_hud()
	update_merchant_ui()
	save_game()

func buy_merchant_item(index: int) -> void:
	if index < 0 or index >= merchant_stock.size():
		return
	if inventory.size() >= max_inventory_size:
		loot_label.text = "Inventory full."
		return
	var item = merchant_stock[index]
	var price = get_item_price(item)
	if gold < price:
		loot_label.text = "Not enough gold."
		return
	gold -= price
	inventory.append(item)
	merchant_stock.remove_at(index)
	loot_label.text = "Bought:\n" + item_to_text(item)
	update_hud()
	update_inventory_ui()
	update_merchant_ui()
	save_game()

func upgrade_inventory_item(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item = inventory[index]
	var current_upgrade = int(item.get("upgrade", 0))
	if current_upgrade >= 5:
		loot_label.text = "Item is already max upgraded."
		return
	var cost = 75 * (current_upgrade + 1)
	if gold < cost:
		loot_label.text = "Not enough gold. Upgrade costs " + str(cost) + "."
		return
	gold -= cost
	item["upgrade"] = current_upgrade + 1
	item["price"] = get_item_price(item) + cost
	var keys = item["stats"].keys()
	if keys.size() > 0:
		var stat = keys.pick_random()
		item["stats"][stat] = int(item["stats"][stat]) + max(1, int(level * 2))
	loot_label.text = "Blacksmith upgraded:\n" + item_to_text(item)
	recalculate_stats()
	update_hud()
	update_inventory_ui()
	update_blacksmith_ui()
	save_game()

func reroll_inventory_item(index: int) -> void:
	if index < 0 or index >= inventory.size():
		return
	var item = inventory[index]
	var cost = 100 + level * 10
	if gold < cost:
		loot_label.text = "Not enough gold. Mystic reroll costs " + str(cost) + "."
		return
	if item["stats"].keys().size() == 0:
		return
	gold -= cost
	var old_stat = item["stats"].keys().pick_random()
	item["stats"].erase(old_stat)
	var stat_pool = ["Health", "Mana", "Damage", "Armor", "Crit Chance", "Crit Damage", "Movement Speed", "Attack Speed", "Cooldown Reduction", "Pickup Radius", "Health Regen", "Mana Regen", "Strength", "Dexterity", "Intellect", "Willpower"]
	var new_stat = stat_pool.pick_random()
	var value = int(randf_range(2, 8) * max(1, level))
	if new_stat in ["Crit Chance", "Movement Speed", "Attack Speed", "Cooldown Reduction", "Pickup Radius"]:
		value = randi_range(1, 5)
	elif new_stat == "Crit Damage":
		value = randi_range(5, 15)
	item["stats"][new_stat] = value
	loot_label.text = "Mystic rerolled " + old_stat + " into " + new_stat + ":\n" + item_to_text(item)
	recalculate_stats()
	update_hud()
	update_inventory_ui()
	update_mystic_ui()
	save_game()

func update_merchant_ui() -> void:
	if merchant_label == null:
		return
	var text := "Gold: %d\nHealth Potions: %d/%d | Mana Potions: %d/%d\nY: Buy Health Potion 25g | U: Buy Mana Potion 25g\nSelect item in inventory, then press Sell Selected.\n\n" % [gold, health_potions, max_health_potions, mana_potions, max_mana_potions]
	for i in range(merchant_stock.size()):
		var item = merchant_stock[i]
		text += "%d) %s [%s] - %d gold\n   %s Lv.%d\n" % [
			i + 1,
			item["name"],
			item["rarity"],
			get_item_price(item),
			item["slot"],
			item["level"]
		]
	if merchant_stock.size() == 0:
		text += "Sold out. Press R to refresh for 50 gold.\n"
	merchant_label.text = text

func update_blacksmith_ui() -> void:
	if blacksmith_label == null:
		return
	var text := "Gold: %d\nUpgrade inventory item. Cost: 75/150/225/300/375 gold.\n\n" % gold
	for i in range(min(inventory.size(), 10)):
		var item = inventory[i]
		var key = str(i + 1) if i < 9 else "0"
		text += "%s) %s [%s] +%d\n" % [key, item["name"], item["rarity"], int(item.get("upgrade", 0))]
	if inventory.size() == 0:
		text += "Inventory empty.\n"
	blacksmith_label.text = text

func update_mystic_ui() -> void:
	if mystic_label == null:
		return
	var text := "Gold: %d\nReroll one random stat on inventory item. Cost: %d gold.\n\n" % [gold, 100 + level * 10]
	for i in range(min(inventory.size(), 10)):
		var item = inventory[i]
		var key = str(i + 1) if i < 9 else "0"
		text += "%s) %s [%s]\n" % [key, item["name"], item["rarity"]]
	if inventory.size() == 0:
		text += "Inventory empty.\n"
	mystic_label.text = text

func save_game() -> void:
	var data := {
		"current_class": current_class,
		"class_index": class_index,
		"level": level,
		"xp": xp,
		"xp_to_next": xp_to_next,
		"paragon_level": paragon_level,
		"paragon_points": paragon_points,
		"skill_points": skill_points,
		"passive_points": passive_points,
		"skill_ranks": skill_ranks,
		"passive_ranks": passive_ranks,
		"combat_skill_slots": combat_skill_slots,
		"gold": gold,
		"health_potions": health_potions,
		"mana_potions": mana_potions,
		"active_flask_effects": active_flask_effects,
		"inventory": inventory,
		"equipment": equipment,
		"loot_filter_mode": loot_filter_mode
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file = FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		return
	current_class = data.get("current_class", current_class)
	class_index = int(data.get("class_index", class_index))
	level = int(data.get("level", level))
	xp = int(data.get("xp", xp))
	xp_to_next = int(data.get("xp_to_next", xp_to_next))
	paragon_level = int(data.get("paragon_level", paragon_level))
	paragon_points = int(data.get("paragon_points", paragon_points))
	skill_points = int(data.get("skill_points", skill_points))
	passive_points = int(data.get("passive_points", passive_points))
	skill_ranks = data.get("skill_ranks", skill_ranks)
	passive_ranks = data.get("passive_ranks", passive_ranks)
	combat_skill_slots = data.get("combat_skill_slots", combat_skill_slots)
	gold = int(data.get("gold", gold))
	health_potions = int(data.get("health_potions", health_potions))
	mana_potions = int(data.get("mana_potions", mana_potions))
	loot_filter_mode = int(data.get("loot_filter_mode", loot_filter_mode))
	loot_filter_mode = clamp(loot_filter_mode, 0, loot_filter_names.size() - 1)
	active_flask_effects = data.get("active_flask_effects", active_flask_effects)
	inventory = data.get("inventory", inventory)
	var loaded_equipment = data.get("equipment", equipment)
	for slot in equipment.keys():
		equipment[slot] = loaded_equipment.get(slot, null)
	# Save migration: old versions used one "Ring" slot.
	if loaded_equipment.has("Ring"):
		if equipment.has("Ring1") and equipment["Ring1"] == null:
			equipment["Ring1"] = loaded_equipment.get("Ring", null)


func toggle_dev_panel() -> void:
	dev_open = not dev_open
	dev_panel.visible = dev_open
	if dev_open:
		close_town_windows_except("dev")
	update_dev_ui()

func handle_dev_input() -> void:
	if key_just_pressed(KEY_Q):
		dev_add_level(1)
	if key_just_pressed(KEY_W):
		dev_add_level(5)
	if key_just_pressed(KEY_E):
		dev_set_level(40)
	if key_just_pressed(KEY_A):
		gain_xp(500)
		loot_label.text = "DEV: Added 500 XP."
	if key_just_pressed(KEY_S):
		gold += 1000
		loot_label.text = "DEV: Added 1000 gold."
		update_hud()
	if key_just_pressed(KEY_F):
		add_potion("Health", 5)
		add_potion("Mana", 5)
		loot_label.text = "DEV: Added 5 health and 5 mana potions."
	if key_just_pressed(KEY_D):
		dev_spawn_item("Random")
	if key_just_pressed(KEY_Z):
		dev_spawn_item("Legendary")
	if key_just_pressed(KEY_X):
		dev_spawn_item("Godlike")
	if key_just_pressed(KEY_G):
		dev_spawn_unique_item("")
	if key_just_pressed(KEY_H):
		var boss_name := ""
		if active_boss != null:
			boss_name = active_boss["name"]
		dev_spawn_unique_item(boss_name)
	if key_just_pressed(KEY_J):
		spawn_enemy(player.position + Vector2(160, 0), false, false)
		loot_label.text = "DEV: Spawned enemy."
	if key_just_pressed(KEY_K):
		spawn_enemy(player.position + Vector2(180, 0), true, false)
		loot_label.text = "DEV: Spawned elite."
	if key_just_pressed(KEY_L):
		spawn_enemy(player.position + Vector2(230, 0), false, true)
		loot_label.text = "DEV: Spawned boss."
	if key_just_pressed(KEY_DELETE):
		reset_save()
	update_dev_ui()

func dev_add_level(amount: int) -> void:
	for i in range(amount):
		if level < 40:
			level += 1
			skill_points += 1
			passive_points += 1
		else:
			paragon_level += 1
			paragon_points += 1
	apply_class_base_stats()
	recalculate_stats()
	hp = max_hp
	mana = max_mana
	loot_label.text = "DEV: Added " + str(amount) + " level(s)."
	update_hud()
	save_game()

func dev_set_level(target: int) -> void:
	level = clamp(target, 1, 40)
	xp = 0
	apply_class_base_stats()
	recalculate_stats()
	hp = max_hp
	mana = max_mana
	loot_label.text = "DEV: Set level to " + str(level) + "."
	update_hud()
	save_game()

func dev_spawn_item(force_rarity: String) -> void:
	if inventory.size() >= max_inventory_size:
		loot_label.text = "Inventory full."
		return

	var item := generate_item(force_rarity in ["Legendary", "Godlike"])
	if force_rarity in ["Legendary", "Godlike"]:
		item["rarity"] = force_rarity
		var p = legendary_powers.pick_random()
		item["power_id"] = p["id"]
		item["power_name"] = ("Godlike " if force_rarity == "Godlike" else "") + p["name"]
		item["power_desc"] = p["desc"]
		item["special"] = item["power_name"] + ": " + item["power_desc"]

	inventory.append(item)
	loot_label.text = "DEV: Added item:\n" + item_to_text(item)
	update_inventory_ui()
	save_game()


func dev_spawn_unique_item(boss_name: String) -> void:
	if inventory.size() >= max_inventory_size:
		loot_label.text = "Inventory full."
		return
	var item := make_unique_item(boss_name)
	inventory.append(item)
	loot_label.text = "DEV: Added UNIQUE item:\n" + item_to_text(item)
	update_inventory_ui()
	save_game()

func reset_save() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	level = 1
	xp = 0
	xp_to_next = 100
	paragon_level = 0
	paragon_points = 0
	skill_points = 0
	passive_points = 0
	skill_ranks = {"Skill1": 1, "Skill2": 0, "Skill3": 0, "Skill4": 0, "Ultimate": 0}
	combat_skill_slots = {"RMB": 0, "1": 0, "2": 1, "3": 2, "4": 3}
	for p in passive_ranks.keys():
		passive_ranks[p] = 0
	gold = 0
	health_potions = 3
	mana_potions = 3
	active_flask_effects.clear()
	selected_inventory_index = -1
	loot_filter_mode = 0
	inventory.clear()
	merchant_stock.clear()
	for slot in equipment.keys():
		equipment[slot] = null
	apply_class_base_stats()
	recalculate_stats()
	hp = max_hp
	mana = max_mana
	refresh_merchant_stock()
	loot_label.text = "DEV: Save reset."
	update_hud()
	update_inventory_ui()
	update_character_ui()
	update_merchant_ui()
	update_blacksmith_ui()
	update_mystic_ui()
	update_dev_ui()

func update_dev_ui() -> void:
	if dev_label == null:
		return
	dev_label.text = "Current Level: %d | Paragon: %d | Gold: %d\n\nLEVEL / PROGRESSION\nQ: +1 Level\nW: +5 Levels\nE: Set Level 40\nA: +500 XP\nS: +1000 Gold\nF: +5 Health and Mana Potions\n\nITEM TESTING\nD: Add Random Item\nZ: Add Legendary Item\nX: Add Godlike Item\nG: Add Random Unique\nH: Add Current Boss Unique\n\nSPAWN TESTING\nJ: Spawn Normal Enemy near player\nK: Spawn Elite near player\nL: Spawn Boss near player\n\nSAVE\nESC: Game Menu
L: Loot Filter
F5: Save Game\nDELETE: Reset Save\n\nSkill unlock test levels:\nSkill 1 = Level 1\nSkill 2 = Level 5\nSkill 3 = Level 10\nSkill 4 = Level 20" % [
		level,
		paragon_level,
		gold
	]

func update_hud() -> void:
	var skill_text := "LMB:Interact/Basic  "
	var rmb_index = get_combat_slot_skill_index("RMB")
	skill_text += "RMB:" + get_skill(rmb_index)["name"] + (" " if get_skill_rank(rmb_index) > 0 else " R0 ") + "  "
	for i in range(4):
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
	for i in range(4):
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

func update_inventory_ui() -> void:
	if inventory_label == null:
		return

	for i in range(inventory_buttons.size()):
		var btn: Button = inventory_buttons[i]
		if i < inventory.size():
			var item = inventory[i]
			var mark = "> " if i == selected_inventory_index else ""
			btn.text = mark + item["name"].substr(0, 12) + "\n" + item["rarity"]
			btn.tooltip_text = item_to_text(item)
			btn.disabled = false
		else:
			btn.text = "Empty"
			btn.tooltip_text = "Empty inventory slot"
			btn.disabled = false

	var inv_text := ""
	if selected_inventory_index >= 0 and selected_inventory_index < inventory.size():
		inv_text += "TOOLTIP:\n" + item_to_text(inventory[selected_inventory_index]) + "\nSell Value: " + str(get_item_price(inventory[selected_inventory_index])) + " gold"
	else:
		inv_text += "Select an item, then click matching equipment slot."

	inventory_label.text = inv_text
	update_potion_belt_ui()
