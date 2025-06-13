# Ultimate Full Loot Pvp Script
![image](https://github.com/user-attachments/assets/b63cce31-c911-414f-9a30-c88727b19da0)

Transform every open-world PvP kill into a dynamic ‘spoils of war’ encounter. Victims’ gear and gold are instantly pulled into free-for-all loot chests around their corpse. No core edits required. Configure global defaults for drop rates, quality filters, despawn timers, and gold splits, then dial in per-zone overrides for surgical control over your world-PvP loot experience.

---

## Key Features
* **Multi-chest logic** – up to 16 items per chest, unlimited overflow.
  
* **Gold cuts & caps** – percent roll, optional hard cap, and even splitting across chests.
  
* **Granular filters** – map/zone allow- & block-lists, level gates, spirit-healer range checks, Battleground ignore, and resurrection-sickness skip.
  
* **Fine-grained item rules** – drop only what you want (quality, BoP, quest, consumables, reagents, profession-bag contents, vendor value, item-level, stack size, explicit allow/deny lists).
  
* **Equipped & bag scanning** – includes equipped slots, backpack, and extra bags; bank support planned.
  
* **Simple config file** – all behaviour lives in one `CFG` table at the top of the script.
  
* **Per‐zone overrides** – Maintain a single default configuration while customizing behavior (despawn timers, quality filters, gold cuts, etc.) on a per-zone basis.
  
* **Per-area overrides** – Want even more control? Keep a single default setup, tweak per-zone overrides, then go deeper by configuring each individual area inside a zone. Letting every sub-region behave exactly the way you want.
  
* **Full DEBUG mode** – verbose console output for every step.

---

## Installation
1. Copy `variable_pvp_loot_drop.lua` into your server’s `lua_scripts/` folder.
2. Restart `worldserver`.  
3. Kill another player in the open world to see chests spawn.
_No Database edits, recompiles or patches required._

---

## Configuration
Open the script and edit the `CFG` block. Every option is inline-documented. Key toggles:  

| Option | Purpose |
|--------|---------|
| `ENABLE_MOD` | Master on/off switch |
| `ALLOW_PLAYER_COMMAND ` | Player access to info regarding standing location |
| `MAP_ALLOWLIST / MAP_BLOCKLIST` | Restrict to specific maps (use IDs) |
| `ZONE_ALLOWLIST / ZONE_BLOCKLIST` | Restrict to zones |
| `AREA_ALLOWLIST / AREA_BLOCKLIST` | Restrict to area |
| `MIN_LEVEL / MAX_LEVEL` | Victim level range |
| `MIN_LEVEL_DIFF / MAX_LEVEL_DIFF` | Allowed level difference killer↔victim |
| `INCLUDE_EQUIPPED` | 	Include equipped slots 0-18 |
| `IGNORE_EQUIPPED_SLOTS[0]-[18]` | Skip any particular item slot  |
| `INCLUDE_BACKPACK` | Include backpack (bag 0) contents |
| `INCLUDE_BAGS` | Include bags 1-4 contents |
| `INCLUDE_BANK_ITEMS` | Include bank items(NYI) |
| `IGNORE_QUEST_ITEMS` | Skip quest-flagged items |
| `IGNORE_CONSUMABLES` | Skip consumables |
| `IGNORE_REAGENTS` | Skip reagents & trade goods |
| `IGNORE_KEYS` | Skip key items |
| `IGNORE_PROFESSION_BAG_SLOTS` | Skip items inside profession-specific bags |
| `IGNORE_HEIRLOOMS` | Skip heirloom items |
| `IGNORE_UNIQUE_EQUIPPED` | Skip unique-equipped items  |
| `IGNORE_SOULBOUND` | Skip soul-bound items |
| `IGNORE_CONJURED` | Skip conjured items |
| `SPLIT_GOLD_BETWEEN_CHESTS` | Evenly divide stolen gold across chests |
| `IGNORE_VENDOR_VALUE_BELOW` | Skip items under this vendor value |
| `IGNORE_ITEMLEVEL_BELOW` | 	Skip items below this item level |
| `IGNORE_STACK_SIZE_ABOVE` | Skip stacks larger than this size |
| `CUSTOM_IGNORE_IDS` | 	Item IDs to always ignore |
| `CUSTOM_ALLOW_IDS` | Item IDs to always drop |
| `CUSTOM_IGNORE_CLASSES` | Item class/subclass strings to ignore |
| `ITEM_DROP_PERCENT` | % of eligible items to drop |
| `IGNORE_CAPITALS` | Skip Faction Capitals |
| `IGNORE_NEUTRAL_CITIES` | Skip Neutral Cities|
| `IGNORE_BATTLEGROUND` | 	Disable in Battlegrounds |
| `IGNORE_SPIRIT_HEALER_RANGE` | 	Skip victims near spirit healer |
| `SPIRIT_HEALER_RANGE` | 	Range for spirit-healer check (m) |
| `IGNORE_RESS_SICKNESS` | Skip resurrection-sick victims |
| `IGNORE_QUALITY` | Per-rarity toggle table |
| `IGNORE_BOP` | Skip Bind-on-Pickup items |
| `ITEM_DROP_PERCENT` | % of victim items to pick before packaging |
| `GOLD_PERCENT_MIN / MAX` | Random % window of gold to steal |
| `GOLD_CAP_PER_KILL` | Hard copper cap (0 = no cap) |
| `CHEST_ENTRY` | GameObject entry of your chest display ID |
| `DESPAWN_SEC` | Chest lifetime in seconds |
| `DEBUG` | `true` for chatty console logs |


---


## How It Works
1. **Kill detection** – `ON_KILL_PLAYER` event fires.  
2. **Safety checks** – level, map/zone, Battleground, spirit healer range, etc.  
3. **Inventory sweep** – equipped slots → backpack → extra bags.  
4. **Item & gold selection** – filtered list shuffled; gold % rolled & capped.  
5. **Chest spawn** – chests arranged in a circle around the corpse.  
6. **Looting** – any player can loot.
7. **Gold** - configurable to drop from a single chest or split across all chests.

DEBUG mode echoes every action, GUID, and item removed to the server console for painless troubleshooting.

---

## Roadmap
* **Bank & guild-bank scanning** (disabled for safety by default).  

Pull requests are welcome.

---

## Contributing
1. Fork the repo.  
2. Create a feature branch.  
3. Submit a PR with clear commit messages.  
Coding style: keep line length ≤ 120 chars, use 4-space indents, no trailing whitespace.

---


## 🙏 Credits & License

* **Author**: Stephen Kania
* **License**: MIT License (see `LICENSE`)
* **Based on**: AzerothCore, TrinityCore, and Eluna

