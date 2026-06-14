ETERNAL REALMS V4 - TOWN PROGRESSION

HOW TO OPEN:
1. Open Godot 4.6.
2. Click Import.
3. Select this folder's project.godot.
4. Open the project.
5. Press Play.

CONTROLS:
Left Click: Move / Attack / Pick up loot
1-4: Skills, or buy/equip/upgrade/reroll when a town window is open
P near portal: Enter random dungeon
T: Return to town
C: Change class
I: Inventory
M: Merchant
B: Blacksmith
N: Mystic
F5: Manual save

NEW IN V4:
- Save/load character progress
- Gold drops from enemies, elites and bosses
- Merchant NPC with purchasable gear
- Merchant refreshes after returning to town
- Blacksmith upgrades inventory items up to +5
- Mystic rerolls one random stat on an inventory item
- Better class-based item bases
- Skill unlock progression:
  Skill 1: Level 1
  Skill 2: Level 5
  Skill 3: Level 10
  Skill 4: Level 20

NOTE:
This is still a prototype. UI uses text panels so systems can be tested quickly.


V4.1 DEV TOOLS:
Press F1 to open/close the developer test panel.

DEV CONTROLS:
Q: +1 level
W: +5 levels
E: set level 40
A: +500 XP
S: +1000 gold
D: add random item
Z: add legendary item
X: add godlike item
J: spawn normal enemy
K: spawn elite
L: spawn boss
DELETE: reset save
F5: save


V5 PROCEDURAL DUNGEON + MINIMAP:
- Portal now creates a procedural dungeon layout.
- Dungeons contain connected rooms and corridors.
- Room types: Start, Combat, Treasure, Elite, Boss.
- Boss is placed in the boss room.
- Treasure room contains free loot.
- Minimap shows explored and unexplored rooms.
- Press T to return to town from the dungeon.


V6.1 REAL LEGENDARY LOOT UPDATE:
- Visible loot beams added:
  Rare = yellow beam
  Legendary = orange beam
  Godlike = purple beam
  Unique = violet beam
- Legendary powers now roll on Legendary and Godlike items.
- Equipped powers can affect gameplay:
  Chain Lightning, Vampiric, Berserker, Explosive, Treasure Hunter,
  Fortune, Arcane Echo, Swift Strikes, Stone Skin, Blood Armor.
- Bosses can drop unique boss-exclusive items.
- Dev tools:
  G = spawn random unique item
  H = spawn current/random boss unique item


V6.2 EQUIPMENT + POTIONS UPDATE:
- Inventory now uses select-then-equip:
  Open inventory with I.
  Press item number to select.
  Press E to equip selected item.
- Health potions added.
  Q = use health potion.
- Mana potions added.
  W = use mana potion.
- Enemies can drop potions directly into your potion count.
- Merchant sells potions:
  M = merchant.
  Y = buy health potion.
  U = buy mana potion.
- Health Regen and Mana Regen added as item stats.
- Regen ticks once per second.
- Dev tools:
  F inside dev panel grants 5 health and 5 mana potions.


V6.3 CHARACTER SCREEN + SAFER INPUT:
- Fixed overly sensitive key presses by changing actions to just-pressed input.
- Added character/equipment screen.
- K opens character screen.
- I opens inventory.
- Press number in inventory to select an item.
- Open character screen with K and click the matching equipment slot.
- E still equips selected item as a shortcut.
- Wrong item slots are rejected with an explanation.


V6.4 BELT + INVENTORY GRID + FLASK FOUNDATION:
- Built from the working V6.3 branch.
- Q is now Health Flask.
- E is now Mana Flask.
- Removed E as equip shortcut.
- Inventory now displays as a 4x6 grid.
- Inventory slots can be clicked with the mouse.
- Character screen is now treated as the paper doll equipment screen.
- New Belt equipment slot.
- Belts can roll Potion Capacity, Potion Effect, Potion Duration, Gold Find and Magic Find.
- Potion belt UI added at bottom center.
- Utility flask framework added:
  Iron Skin, Lucky, Berserker and Shadow effects are supported internally.
- Health and mana flasks scale with Potion Effect.


V6.4.1 INPUT FIX:
- Fixed Godot error caused by invalid Input.is_key_just_pressed and Input.is_mouse_button_just_pressed calls.
- Added custom key/mouse just-pressed helper functions.
- Q = Health Flask, E = Mana Flask remain active.


V6.4.2 QUALITY OF LIFE UPDATE:
- Increased project resolution to 1600x900.
- Repositioned UI panels for the larger screen.
- Inventory and character screen can now be open at the same time.
- Equipment flow now works properly:
  1. Press I to open inventory.
  2. Press K to open character screen.
  3. Click an inventory item.
  4. Click the matching paper doll slot.
- Holding left mouse button continuously moves toward the cursor.
- Q remains Health Flask.
- E remains Mana Flask.


V6.4.3 UI CLICK BLOCKER:
- Open UI panels now block world mouse clicks.
- Clicking inventory/character/merchant/blacksmith/mystic/dev windows no longer moves the character underneath.
- Holding left mouse to move stops while the cursor is over an open UI window.


V6.5.1 CHARACTER PAPER DOLL + STATS:
- Improved character screen with clear equipment slot boxes/list.
- Inventory and character screen can be open together.
- Left-click inventory item to select.
- Left-click matching paper doll slot to equip.
- Ring slot split into Ring 1 and Ring 2.
- Click equipped slot with no selected item to unequip.
- Added stat summary:
  Strength, Dexterity, Intellect, Willpower, Damage, Armor,
  Crit Chance, Crit Damage, HP/Mana Regen, Magic Find, Gold Find.
- Primary attributes now contribute to derived stats.


V6.5.2 CHARACTER UI FIX:
- Fixed outdated Ring slot reference.
- Equipment summary now uses Ring 1 and Ring 2.
- Equipment summary now safely reads equipment slots.
- Added old-save migration from Ring -> Ring1.
- Character panel widened so paper doll slot coordinates fit better.


V6.5.3 RING REFERENCE FIX:
- Fixed remaining old Ring reference in update_inventory_ui.
- Replaced direct equipment[slot] reads with safe equipment.get(slot, null).
- Equipment summary now fully uses Ring1 and Ring2.
- Added/kept old save migration Ring -> Ring1.
- Cleaned several warnings:
  - integer division in inventory grid
  - local variable char renamed to map_char


V6.5.4 REAL EQUIPMENT SLOTS + CLICK FIX:
- Inventory now has visible clickable Button slots.
- Character screen now has visible clickable equipment Button slots.
- Fixed custom mouse click memory so repeated clicks work correctly.
- Selected item is now clearly shown.
- Stat summary is separated from equipment slots.
- Tooltips show item details when hovering inventory/equipment buttons.


V6.5.5 INPUT + 2560 RESOLUTION FIX:
- Game resolution changed to 2560x1440.
- UI panels moved outward to use widescreen space.
- Inventory buttons enlarged.
- Character equipment buttons enlarged.
- Fixed double-click/double-action issue:
  UI buttons now handle UI clicks; world mouse handler ignores open UI panels.
- Unequip changed to SHIFT + click equipped slot to avoid accidental unequipping.


V6.5.6 INVENTORY SORT + VENDOR SELL:
- Added Sort button to inventory.
- Sorting order: slot -> rarity -> level -> name.
- Added Sell Selected button to Merchant.
- Select an inventory item, open Merchant, press Sell Selected.
- Item sell value appears in inventory tooltip.
- Stash is still planned for later.


V6.6 CHARACTER PROGRESSION & BUILDCRAFTING:
- Added character tabs: Equipment, Skills, Passives, Paragon, Build.
- Leveling now grants +1 Skill Point and +1 Passive Point.
- Skills now have rank framework: Rank 0-20.
- Skill tab: press 1-4 to rank up, SHIFT+1-4 to refund.
- Passive tab: press Q/W/E/R/T/Y to rank passives, SHIFT+key to refund.
- Added new core stats:
  Attack Speed
  Cooldown Reduction
  Pickup Radius
- Added build analysis tab.
- Save/load support for skill points, passive points, skill ranks, passive ranks.


V6.6.1 INPUT RELIABILITY FIX:
- Fixed UI input blocking too much.
- Mouse over UI now blocks only world mouse actions, not keyboard/dev controls.
- Dev panel now captures its own test keys and prevents conflicts with flasks/passive keys.
- Mouse click detection is called every frame for more reliable repeated clicks.
- Project window set to maximized mode while keeping 2560x1440 viewport.


V6.7.1 LOOT FILTER:
- Added loot filter panel.
- Press L to cycle loot filter modes.
- Modes:
  1. Show All
  2. Hide Common
  3. Hide Common + Uncommon
  4. Rare+
  5. Legendary+
- Godlike and Unique items always show.
- Hidden loot cannot be picked up by accidental left-click.
- Loot filter setting saves/loads.
- Next planned V6.7 step: LMB/RMB combat bar and skill specialization foundation.


V6.7.2 ESCAPE MENU + LOOT FILTER OPTIONS:
- Press ESC to open/close the in-game menu.
- Menu includes:
  Resume
  Options placeholder
  Loot Filter buttons
  Quit Game
- Loot filter can now be selected directly like an ARPG options/filter menu.
- Game menu blocks gameplay input while open.
- Press L still cycles loot filter quickly during gameplay.


V6.7.3 CLICKABLE PORTAL MASTER:
- Left-click Portal Master in town to move to him and enter a random dungeon.
- Press P still works.
- If too far away, P now moves toward the Portal Master first.
- Clicking elsewhere cancels pending portal interaction.


V6.8 COMBAT BAR FOUNDATION:
- Added Diablo-style combat bar foundation.
- LMB remains interact/move/basic attack/pickup.
- RMB now casts the core assigned skill.
- 1-4 use assigned active skills.
- Combat slots:
  RMB -> Skill 1
  1 -> Skill 1
  2 -> Skill 2
  3 -> Skill 3
  4 -> Skill 4
- Separate cooldown tracking per combat slot.
- Combat slot assignments save/load.
- Future: manual skill assignment UI and ultimate slot.
