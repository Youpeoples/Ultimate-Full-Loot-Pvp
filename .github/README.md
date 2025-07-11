# Ultimate Full Loot Pvp Script
![image](https://github.com/user-attachments/assets/b63cce31-c911-414f-9a30-c88727b19da0)

<table>
  <tr>
    <td style="vertical-align: top; padding-right: 20px; max-width: 400px;">
      Transform every open-world PvP kill into a dynamic ‘spoils of war’ encounter. Victims’ gear and gold are instantly pulled into free-for-all loot chests around their corpse. No core edits required. Configure global defaults for drop rates, quality filters, despawn timers, and gold splits, then dial in per-zone and per-area overrides for surgical control over your world-PvP loot experience.
    </td>
    <td>
      <img src="https://github.com/user-attachments/assets/e19b466f-a7aa-4ce3-bb13-c06d1cf71c7f" alt="Centered Image" />
    </td>
  </tr>
</table>

## Key Features
* **Multi-chest logic** – up to 16 items per chest, unlimited overflow.

* **Discord/Webhook Integration** – send  notifications to Discord (or any webhook) with embeds showing items looted, gold amounts, and kill location, complete with threshold controls for volume.
  
* **Gold cuts & caps** – percent roll, optional hard cap, and even splitting across chests.
  
* **Granular filters** – map/zone allow- & block-lists, level gates, spirit-healer range checks, Battleground ignore, and res-sick skip.
  
* **Per‐zone overrides** – Maintain a single default configuration while customizing behavior on a per-zone basis.
  
* **Per-area overrides** – Configure each individual area inside a zone. Letting every sub-region behave exactly the way you want.
  
* **Fine-grained item rules** – precisely manage drops with layered filters and overrides for virtually any item attribute.
  
* **Equipped & bag scanning** – includes equipped slots, backpack, and extra bags; bank support planned.
  
* **Simple and Extensive configurability** – all behaviour lives in one `CFG` table at the top of the script.

* **Loot Profile Presets** – Named, easily sharable and reusable configs that override all settings.

* **Script Hook** – External scripts can register to react to loot events.

* **Matchmaking Rating (MMR) System** – Track player performance and adjust rewards based on MMR differences.
  
* **GM Commands** - instantly apply test configuration changes in-game without restarting the server or reloading scripts.
  
* **Full DEBUG mode** – verbose console output for every step.
---

## Installation
1. Copy `Ultimate_Full_Loot_Pvp.lua` into your server’s `lua_scripts/` folder.
2. Restart `worldserver`.  
3. Kill another player in the open world to see chests spawn.
   
_No Database edits, recompiles or patches required._

---

## Configuration
Open the script and edit the `CFG` block. Every option is inline-documented. Key toggles:  

| Option | Purpose |
|--------|---------|
| `ENABLE_MOD` | Master on/off switch |
|  |  |
|  |  |
| `ALLOW_PLAYER_COMMAND ` | Player access to info regarding standing location |
| `NOTIFY_PLAYER_OF_COMMAND ` | Login message on/off |
|  |  |
|  |  |
| `AREA_ALLOWLIST / AREA_BLOCKLIST` | Restrict to area |
| `MAP_ALLOWLIST / MAP_BLOCKLIST` | Restrict to specific maps (use IDs) |
| `ZONE_ALLOWLIST / ZONE_BLOCKLIST` | Restrict to zones |
|  |  |
|  |  |
| `MIN_LEVEL / MAX_LEVEL` | Victim level range |
| `MIN_LEVEL_DIFF / MAX_LEVEL_DIFF` | Allowed level difference killer↔victim |
|  |  |
|  |  |
| `IGNORE_EQUIPPED_SLOTS[0]-[18]` | Skip any particular item slot  |
| `INCLUDE_BACKPACK` | Include backpack (bag 0) contents |
| `INCLUDE_BAGS` | Include bags 1-4 contents |
| `INCLUDE_BANK_ITEMS` | Include bank items(NYI) |
| `INCLUDE_EQUIPPED` | 	Include equipped slots 0-18 |
|  |  |
|  |  |
| `ITEM_DROP_PERCENT` | % of eligible items to drop |
| `IGNORE_BOP` | Skip Bind-on-Pickup items |
| `IGNORE_CONJURED` | Skip conjured items |
| `IGNORE_CONSUMABLES` | Skip consumables |
| `IGNORE_ENCHANTED_EQUIPPED` | Skip enchanted equipped items |
| `IGNORE_HEIRLOOMS` | Skip heirloom items |
| `IGNORE_ITEMLEVEL_BELOW` | 	Skip items below this item level |
| `IGNORE_KEYS` | Skip key items |
| `IGNORE_NON_TRADABLE_ITEMS` | Skip non-tradable items |
| `IGNORE_QUALITY` | Per-rarity toggle table |
| `IGNORE_QUEST_ITEMS` | Skip quest-flagged items |
| `IGNORE_REAGENTS` | Skip reagents & trade goods |
| `IGNORE_REQUIREDLEVEL_BELOW` | Skip items below this required level |
| `IGNORE_SOULBOUND` | Skip soul-bound items |
| `IGNORE_STACK_SIZE_ABOVE` | Skip stacks larger than this size |
| `IGNORE_TRADABLE_ITEMS` |  Skip tradable items |
| `IGNORE_UNIQUE_EQUIPPED` | Skip unique-equipped items  |
| `IGNORE_VENDOR_VALUE_BELOW` | Skip items under this vendor value |
|  |  |
|  |  |
| `GOLD_CAP_PER_KILL` | Hard copper cap (0 = no cap) |
| `GOLD_PERCENT_MIN / MAX` | Random % window of gold to steal |
| `SPLIT_GOLD_BETWEEN_CHESTS` | Evenly divide stolen gold across chests |
|  |  |
|  |  |
| `CHEST_STACK_STYLE` | 4 Options for Chest Spawn Style |
| `RANDOM_CHEST_ORIENTATION` | On/Off Uniform Chest Facing Direction |
|  |  |
|  |  |
| `CUSTOM_ALLOW_IDS` | Item IDs to always drop |
| `CUSTOM_IGNORE_CLASSES` | Item class/subclass strings to ignore |
| `CUSTOM_IGNORE_IDS` | 	Item IDs to always ignore ||  |  |
|  |  |
|  |  |
| `ENABLE_KILL_FARM_PROTECTION` | Toggle on/off protection |
| `KILL_FARM_WINDOW_SEC` | Checked time window |
| `KILL_FARM_MAX_KILLS` | Kills allowed in that windows |
| `KILL_FARM_PUNISH_MSG` | Msg to send upon limit met |
|  |  |
|  |  |
| `IGNORE_AFK_VICTIM` | Skip AFK victims |
| `IGNORE_ARENA` | 	Disable in Arena |
| `IGNORE_AURA_ON_KILLER` | Skip if killer has listed aura  |
| `IGNORE_AURA_ON_VICTIM` | Skip if victim has listed aura |
| `IGNORE_BATTLEGROUND` | 	Disable in Battlegrounds |
| `IGNORE_CAPITALS` | Skip Faction Capitals |
| `IGNORE_IF_KILLER_DRUNK` | Skip if killer is drunk |
| `IGNORE_IF_VICTIM_DRUNK` | Skip if victim is drunk |
| `IGNORE_NEUTRAL_CITIES` | Skip Neutral Cities|
| `IGNORE_PROFESSION_BAG_SLOTS` | Skip items inside profession-specific bags |
| `IGNORE_RESS_SICKNESS` | Skip resurrection-sick victims |
| `IGNORE_SUICIDE` | Skip if victim is also killer |
| `IGNORE_PLAYER_VICTIM_RACE` | Skip if victim is particular race |
| `IGNORE_PLAYER_VICTIM_CLASS` | Skip if victim is particular class |
| `IGNORE_PLAYER_KILLER_RACE` | Skip if killer is particular race |
| `IGNORE_PLAYER_KILLER_CLASS` | Skip if killer is particular class |
|  |  |
|  |  |
| `IGNORE_SPIRIT_HEALER_RANGE` | 	Skip victims near spirit healer |
| `SPIRIT_HEALER_RANGE` | 	Range for spirit-healer check (m) |
|  |  |
|  |  |
| `IGNORE_VICTIM_ALLIANCE` | Skip if victim horde |
| `IGNORE_VICTIM_HORDE` | Skip if victim alliance |
|  |  |
|  |  |
| `CHEST_ENTRY` | GameObject entry of your chest display ID |
| `DESPAWN_SEC` | Chest lifetime in seconds |
|  |  |
|  |  |
| `ENABLE_WEBHOOK` | Send Kill Feed to Discord or Similar |
| `HOOK_SEND_ITEM_THRESHOLD` | Limit send based on items dropped | 
| `HOOK_SEND_GOLD_THRESHOLD` | Limit send based on gold dropped |
|  |  |
|  |  |
| `MMR_ENABLED` | Enable/disable MMR extension |
| `MMR_GAIN` | Base rate at which players gain MMR |
| `MMR_LOSS` | Base rate at which players lose MMR |
| `MMR_GOLD_REWARD` | Enable/disable gold reward based on MMR |
| `MMR_GOLD_REWARD_RATIO` | Multiplier for gold reward based on MMR difference |
| `MMR_KILL_ITEM_ID` | Item ID for kill reward currency |
| `MMR_STREAK_ITEM_ID` | Item ID for streak reward currency |
| | |
| | |
| `DEBUG` | `true` for chatty console logs |



---


## How It Works
1. **Kill detection** – `ON_KILL_PLAYER` event fires.  
2. **Safety checks** – level, map/zone, Battleground, spirit healer range, etc.  
3. **MMR** - Calculate MMR, kill streak change, and optional currency rewards.
4. **Inventory sweep** – equipped slots → backpack → extra bags.  
5. **Item & gold selection** – filtered list shuffled; gold % rolled & capped.  
6. **Chest spawn** – chests arranged in a circle around the corpse.  
7. **Looting** – any player can loot.
8. **Gold** - configurable to drop from a single chest or split across all chests.

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

