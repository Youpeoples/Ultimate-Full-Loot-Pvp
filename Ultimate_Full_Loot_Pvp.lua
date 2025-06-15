--========================================================================================--
--                                ULTIMATE FULL LOOT PVP                                  --
--========================================================================================--

-- ─────────────────────────────────────────────────────────────────────────────────────────
-- GM-ONLY COMMANDS (always available to GMs regardless of ALLOW_PLAYER_COMMAND)
--                                 GM must be ON
-- .ultpvp reload
--   • Reloads configuration at runtime.
--   • Sends “Config reloaded.” on success or “Reload FAILED: <error>” on failure.
--
-- .ultpvp set <KEY> <VALUE>
--   • Modifies only the base CFG values at runtime; zone and area specific overrides still take precedence.
--   • Converts VALUE to boolean/number/string and validates KEY exists.
--   • Changes are NOT written to disk. These will be lost on script reload or server restart.
--   • Usage message if arguments are missing; error if key is unknown.
--   • Sends “<KEY> → <VALUE>” on successful update.
--
-- Non-GM users invoking these subcommands receive “[Ultimate PvP] GM-only command.”
-- ─────────────────────────────────────────────────────────────────────────────────────────

-- ─────────────────────────────────────────────────────────────────────────────────────────
--  PvP LOOT EVENTHOOK:
--  Lets external scripts listen for PvP loot drops and react to them.
--  
--  To use: another Lua script can register a callback with:
--
--    RegisterPvPLootHook(function(killer, victim, items, gold, cfg, mapId, zoneId, areaId)
--        -- respond to the event, e.g. logging, alerting, custom behavior
--    end)
--
--  ARGUMENTS PASSED TO EACH HOOK:
--      killer     – Eluna player object who got the kill
--      victim     – Eluna player object who died
--      items      – Table of item data selected for drop (via gatherItems)
--      gold       – Amount of copper taken from victim (after cap applied)
--      cfg        – Final, merged config that governed this kill (all overrides/profiles applied)
--      mapId      – Map where the kill occurred
--      zoneId     – Zone where the kill occurred
--      areaId     – Area where the kill occurred
--
--  EXAMPLE:
--      RegisterPvPLootHook(function(killer, victim, items, gold, cfg, mapId, zoneId, areaId)
--          SendWorldMessage(("%s looted %s and %d item(s) from %s in zone %d")
--              :format(killer:GetName(), fmtCoins(gold), #items, victim:GetName(), zoneId))
--      end)

--         PRINT RESULT: Thrall looted 12g 45s 89c and 3 item(s) from Jaina in zone 495
--
--  This system is optional and does not interfere with normal loot operation.
--  Hooks are pcall-wrapped and fail-safe.
-- ──────────────────────────────────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────────────────────────────────
--  OVERRIDE HIERARCHY
--  1. CFG             – global defaults
--  2. ZONE_OVERRIDES  – per-zone tweaks; only listed keys are replaced
--  3. AREA_OVERRIDES  – per-area tweaks; sit *inside* their zone and trump both above
--  4. PROFILE         – optional named preset applied last; overrides all previous layers
--
--  Any key omitted at a given level automatically inherits from the layer above
--  (Area → Zone → CFG). If a PROFILE is defined (from any layer), it is applied last
--  and overwrites all other values.
-- ──────────────────────────────────────────────────────────────────────────────────────────

local CFG = {
    -- ------------------------------------------------------------------
    -- Master toggle
    -- ------------------------------------------------------------------
    ENABLE_MOD                 = true,          -- Turn System on/off

    -- ------------------------------------------------------------------
    -- Webhook Bridge (Discord, etc.)   ---PROLLY NOT PERFECT---
    --  I can only test windows atm. Unsure if linux actually works.
    -- ------------------------------------------------------------------
    ENABLE_WEBHOOK             = false,
    WEBHOOK_URLS = {                       -- may contain many
        "https://Your-API-ADDRESS",
    },
    WEBHOOK_ASYNC              = true,             
    WEBHOOK_USERNAME           = "Ultimate PvP",
    WEBHOOK_ICON_URL           = "https://i.imgur.com/W9VYGc6.png", --a skull
    HOOK_SEND_ITEM_THRESHOLD   = 0,   -- hook if at least this many items drop
    HOOK_SEND_GOLD_THRESHOLD   = 0,   -- hook if at least this much gold drops

     -- ------------------------------------------------------------------
    -- Command toggle. ( Allows players to see exact risk stats of zone)
    -- ------------------------------------------------------------------
    NOTIFY_PLAYER_OF_COMMAND   = true,          -- Login Message on/off
    ALLOW_PLAYER_COMMAND       = true,          -- Turn .ultpvp on/off
    -- ------------------------------------------------------------------
    -- Map / zone filters       ( _LIST = {}  :: Allow All )
    -- ------------------------------------------------------------------
    MAP_ALLOWLIST              = {},             -- e.g. { [0]=true,},
    MAP_BLOCKLIST              = {},             -- e.g. { [1]=true,},
    ZONE_ALLOWLIST             = {},             -- e.g. { [0]=false,},
    ZONE_BLOCKLIST             = {[4197]=true},  --[4197]Wintergrasp    
    AREA_ALLOWLIST             = {},             -- e.g. { [1]=false,},
    AREA_BLOCKLIST             = {[350]=true},             -- e.g. { [0]=true,},

    -- ------------------------------------------------------------------
    -- Level restrictions
    -- ------------------------------------------------------------------
    MIN_LEVEL                  = 1,
    MAX_LEVEL                  = 80,
    MIN_LEVEL_DIFF             = 0,       
    MAX_LEVEL_DIFF             = 4,
    -- ------------------------------------------------------------------
    -- Container inclusion
    -- ------------------------------------------------------------------
    INCLUDE_EQUIPPED           = true,
    INCLUDE_BACKPACK           = true,     -- bag 0
    INCLUDE_BAGS               = true,     -- bags 1-4
    INCLUDE_BANK_ITEMS         = false,    -- (future)

    -- ------------------------------------------------------------------
    -- Item-type filters
    -- ------------------------------------------------------------------
    ITEM_DROP_PERCENT           = 100,     -- % of victim items to drop

    IGNORE_BOP                  = false,   -- ignore bind on pickup
    IGNORE_CONJURED             = false,   -- Soul/Health/Mana stones
    IGNORE_CONSUMABLES          = false,
    IGNORE_ENCHANTED_EQUIPPED   = true,    -- ignores equipped enchanted items
    IGNORE_HEIRLOOMS            = true,
    IGNORE_KEYS                 = true,
    IGNORE_NON_TRADABLE_ITEMS   = true,    -- ignore items that *cannot* be traded
    IGNORE_PROFESSION_BAG_SLOTS = true,    
    IGNORE_QUEST_ITEMS          = true,
    IGNORE_REAGENTS             = false,
    IGNORE_SOULBOUND            = false,
    IGNORE_TRADABLE_ITEMS       = false,   -- ignore items that *can* be traded
    IGNORE_UNIQUE_EQUIPPED      = false,
    IGNORE_QUALITY = {                 
                           [1] = false,    -- ignore common 
                           [2] = false,    -- ignore uncommon
                           [3] = false,    -- ignore rare
                           [4] = false,    -- ignore epic
                           [5] = true,     -- ignore legendary
    },


    IGNORE_EQUIPPED_SLOTS      = {        
                          [0]  = false,   -- Head
                          [1]  = false,   -- Neck
                          [2]  = false,   -- Shoulders
                          [3]  = false,   -- Shirt
                          [4]  = false,   -- Chest
                          [5]  = false,   -- Waist
                          [6]  = false,   -- Legs
                          [7]  = false,   -- Feet
                          [8]  = false,   -- Wrists
                          [9]  = false,   -- Hands
                          [10] = false,   -- Finger 1
                          [11] = false,   -- Finger 2
                          [12] = false,   -- Trinket 1
                          [13] = false,   -- Trinket 2
                          [14] = false,   -- Back
                          [15] = false,   -- Main Hand
                          [16] = false,   -- Off Hand
                          [17] = false,   -- Ranged
                          [18] = false,   -- Tabard
    },
    -- ------------------------------------------------------------------
    -- Gold filters
    -- ------------------------------------------------------------------
    GOLD_CAP_PER_KILL          = 25000000, -- (0 = no cap) MMR mutli affected
    GOLD_PERCENT_MAX           = 100,      -- 50-100 % example
    GOLD_PERCENT_MIN           = 100,      -- roll between MIN and MAX %
    SPLIT_GOLD_BETWEEN_CHESTS  = true,
    -- ------------------------------------------------------------------
    -- Numeric thresholds
    -- ------------------------------------------------------------------
    IGNORE_VENDOR_VALUE_BELOW  = 0,        -- copper
    IGNORE_ITEMLEVEL_BELOW     = 0,        -- hidden power rating
    IGNORE_REQUIREDLEVEL_BELOW = 0,        -- required level to equip
    IGNORE_STACK_SIZE_ABOVE    = 0,        -- 0 = off

    -- ------------------------------------------------------------------
    -- Explicit allow / deny
    -- ------------------------------------------------------------------
    CUSTOM_ALLOW_IDS           = {},       -- overrides all ignore checks
    CUSTOM_IGNORE_IDS          = {[6948]=true,   --Hearthstone
                                  [5976]=true,   --Guild Tabard 
                                 },
    CUSTOM_IGNORE_CLASSES      = {},       -- e.g. { ["0"]=true,},
   
    -- ------------------------------------------------------------------
    -- Chest parameters
    -- ------------------------------------------------------------------
    CHEST_ENTRY               = 2069420,   -- chest template
    DESPAWN_SEC               = 60,        -- chest lifetime (seconds)
    CREATE_DEFAULT_CHEST      = true,      -- create initial gameobject SQL

    -- ------------------------------------------------------------------
    -- Context exclusions
    -- ------------------------------------------------------------------
    IGNORE_AFK_VICTIM         = false,    -- ignore kills if victim is flagged AFK
    IGNORE_AURA_ON_KILLER     = {},       -- ignore on killer aura id check
    IGNORE_AURA_ON_VICTIM     = {},       -- ignore on victim aura id check
    IGNORE_ARENA              = true,     -- skip kills inside arenas 
    IGNORE_BATTLEGROUND       = true,     -- skip BG kills
    IGNORE_CAPITALS           = true,     -- skip kills in faction capitals
    IGNORE_IF_KILLER_DRUNK    = false,    -- why not?
    IGNORE_IF_VICTIM_DRUNK    = false,    -- its only fair.
    IGNORE_VICTIM_ALLIANCE    = false,    -- skip if victim alliance
    IGNORE_VICTIM_HORDE       = false,    -- skip if victim horde
    IGNORE_NEUTRAL_CITIES     = true,     -- skip kills in neutral hubs
    IGNORE_RESS_SICKNESS      = true,     -- skip if victim has aura 15007
    IGNORE_SUICIDE            = false,    -- skip if victim is also killer
    IGNORE_SPIRIT_HEALER_RANGE= true,     -- apply range check below
    SPIRIT_HEALER_RANGE       = 20,       -- metres

    -- ------------------------------------------------------------------
    -- Kill Farming Guard
    -- ------------------------------------------------------------------
    ENABLE_KILL_FARM_PROTECTION = true,   -- add this to your CFG
    KILL_FARM_WINDOW_SEC        = 900,    -- time-window (15 min)
    KILL_FARM_MAX_KILLS         = 3,      -- kills allowed in that window
    KILL_FARM_PUNISH_MSG        = "No loot / rating – farming detected.",

    -- ------------------------------------------------------------------
    -- MMR
    -- ------------------------------------------------------------------
    -- General MMR settings
    MMR_ENABLED               = true,  -- Enable/disable MMR extension
    STARTING_MMR              = 100,   -- Start MMR
    MMR_GAIN                  = 5,     -- Base rate at which players gain MMR
    MMR_LOSS                  = 5,     -- Base rate at which players lose MMR
    MMR_ANNOUNCE_CHANGE       = true,  -- Message players on MMR change
    
    MMR_DIMINISHING_RETURNS   = true,  -- Reduces MMR change if far from base MMR
    MMR_DIM_RETURN_RATE       = 5,     -- Coeff for diminishing return reduction/gain of MMR difference
  
    -- MMR Reward Config
    MMR_REWARDS               = true,  -- True to enable/false to disable MMR rewards/losses
    MMR_REWARD_THRESHOLD      = 10,    -- Min % delta req. for MMR reward/loss
    
    MMR_GOLD_REWARD           = true,  -- Kill high MMR player, earn more gold
    MMR_GOLD_REWARD_RATIO     = 1.1,   -- Reward multiplier, MMR delta x ratio

    MMR_KILL_REWARD           = true,  -- Earn currency on kills. Earn more if killer's MMR lower than victim's
    MMR_KILL_LOSS             = true,  -- Lose currency on death. Lose less if victim's MMR lower than killer's
    MMR_KILL_RATE             = 10,    -- Reward/lose currency by MMR (delta * rate)
    MMR_KILL_ITEM_ID          = 43308, -- Kill reward currency's item ID. Default is honor (43308)
    
    MMR_STREAK_REWARD         = true,  -- Reward killer of streak holders with secondary currency
    MMR_STREAK_LOSS           = true,  -- Lose secondary currency if killed while holding streak
    MMR_STREAK_ITEM_ID        = 43307, -- Streak reward currency's item ID. Default is arena points (43307) 
    MMR_STREAK_LIMIT          = 3,     -- Streak must be at least X to award break rewards
    MMR_STREAK_RATE           = 5,     -- Reward streak breakers (streak * rate) currency
    MMR_STREAK_MULTIPL        = 1.3,   -- Exponential multiplier for streak break reward/loss
    MMR_ANNOUNCE_STREAK       = true,  -- Send world messages on new/broken streaks
    
    -- MMR Back-End Setup
    MMR_DB                    = 'acore_eluna',
    MMR_TABLE                 = 'full_loot_pvp',

    -- ------------------------------------------------------------------
    -- Debug
    -- ------------------------------------------------------------------
    DEBUG                     = false,
}
-- ------------------------------------------------------------------
-- Loot Profiles: Preset or Share your favorite exclusion combinations!
-- Profiles wont trigger without first being applied in an Override.
-- Example for zone/area override:    [47] = {PROFILE = "hardcore"},
-- ------------------------------------------------------------------
local LOOT_PROFILES = {
    ["hardcore"] = {
        INCLUDE_EQUIPPED = true,
        IGNORE_QUALITY = {[0]=false,[1]=false,[2]=false,[3]=false,[4]=false},
    },
    ["softcore"] = {
        INCLUDE_EQUIPPED = false,
        IGNORE_QUALITY = {[0]=true,[1]=true,[2]=true,[3]=true,[4]=false},
    -- add more as you need…
    },
}


--========================================================================--
--                    Individual Zone Overrides Section                   --
--        Your zones will use default config unless stated otherwise..    --
--========================================================================--
local ZoneOverrides = {
  
                                       -- Example:
  [47] = {                             -- Hinterlands zoneId[47] 
      DESPAWN_SEC    = 120,            -- Gets double despawn time
      IGNORE_QUALITY = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,                   -- And Legendary are not protected
      },
    },
  -- add more as needed…
}
--========================================================================--
--                    Individual AREA Override Section                     --
--Areas use ZoneOverrides before default config unless stated otherwise.   --
--========================================================================--
local AreaOverrides = {               -- Example
    [350] = {                         -- Quel'Danil Lodge (in hinterlands)
        DESPAWN_SEC    = 10,          -- Has very short despawn time
    },
    -- add more areas as needed…
}
-- ------------------------------------------------------------------
-- IGNORE_CAPITALS & IGNORE_NEUTRAL_CITIES Granular Tuning
-- ------------------------------------------------------------------
local CAPITAL_AREAS = {
    [1637] = true,  -- Orgrimmar
    [1497] = true,  -- Undercity
    [1638] = true,  -- Thunder Bluff
    [1519] = true,  -- Stormwind
    [1537] = true,  -- Ironforge
    [1657] = true,  -- Darnassus
}
local NEUTRAL_CITY_AREAS = {
     --classic
    [2255] = true,  -- Everlook
    [35]   = true,  -- Booty Bay
    [976]  = true,  -- Gadgetzan
    [2361] = true,  -- Nighthaven
    [392]  = true,  -- Ratchet
    [3425] = true,  -- Cenarion Hold
    [2268] = true,  -- Light's Hope
    [1446] = true,  -- Thorium Point
     --tbc
    [3712] = true,  -- Area 52
    [3786] = true,  -- Ogri'la
    [3565] = true,  -- Cenario Refuge
    [3649] = true,  -- Sporeggar
    [3958] = true,  -- Sha'tari Base Camp
     --wrath
    [4418] = true,  -- K3
    [4501] = true,  -- Argent Vanguard
    [4152] = true,  -- Moaki Harbor
    [3988] = true,  -- Kamagua
    [4113] = true,  -- Unu'pe
    [4161] = true,  -- Wyrmrest Temple
    [4312] = true,  -- Ebonwatch
}  


--========================================================================--
--                       NO TOUCH BEYOND THIS POINT                       --
--========================================================================--
local DefaultCFG = CFG
local PvPLootHooks = {}
function RegisterPvPLootHook(fn)
    table.insert(PvPLootHooks, fn)
end  
-- Ensure chest exists before proceeding
if CFG.ENABLE_MOD then
    local ChestExists = WorldDBQuery("SELECT `name` FROM `gameobject_template` WHERE `entry` = "..CFG.CHEST_ENTRY)
    if not ChestExists then
        if CFG.CREATE_DEFAULT_CHEST then
            WorldDBExecute("INSERT IGNORE INTO `gameobject_template` "..
                "(`entry`, `type`, `displayId`, `name`, `IconName`, `castBarCaption`, `unk1`, `size`, "..
                "`Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`, "..
                "`Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`, "..
                "`Data19`, `Data20`, `Data21`, `Data22`, `Data23`, `AIName`, `ScriptName`, `VerifiedBuild`) "..
                "VALUES ("..CFG.CHEST_ENTRY..", 3, 259, 'Spoils of War', '', '', '', 1, 1634, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', 0)")
            RunCommand("server restart 30 Restarting to load in required resources for [PvPChest] script.")
            error("[PvPChest] - Chest gameobject created. Restart required!") -- Stops further execution
        else
            error("[PvPChest] - Chest gameobject doesn't exist. Create gameobject entry "..CFG.CHEST_ENTRY.."!") -- Stops further execution
        end
    end
end

-- shallow-copy defaults + apply overrides
local function GetCFG(areaId, zoneId)
    local cfg = {}
    -- copy defaults
    for k, v in pairs(DefaultCFG) do cfg[k] = v end
    -- apply zone-level tweaks (if any)
    local z = ZoneOverrides[zoneId]
    if z then for k, v in pairs(z) do cfg[k] = v end end
    -- apply area-level tweaks (if any) – wins over everything
    local a = AreaOverrides[areaId]
    if a then for k, v in pairs(a) do cfg[k] = v end end
    -- check for preset profiles
    if cfg.PROFILE then
        local preset = LOOT_PROFILES[cfg.PROFILE]
        if preset then
            for k, v in pairs(preset) do
                cfg[k] = v
            end
            dbg("Applied profile: " .. cfg.PROFILE)
        else
            dbg("Profile not found: " .. cfg.PROFILE)
        end
    end
    return cfg
end
local LootStore = {} 
local MAX_CHEST_ITEMS = 16  -- engine shows max 16 loot slots
local SPIRIT_HEALER_IDS = {[6491]=true,[29259]=true,[32537]=true}

--========================================================================--
--                           UTILS & DEBUGS                               --
--========================================================================--
--------------------------------------------------------------------Name Getter
local MAP_NAMES = {
  [0] = "Eastern Kingdoms",
  [1] = "Kalimdor",
}

local function getLocationNames(mapId, zoneId, areaId)
  -- map
  local mapName = MAP_NAMES[mapId] or ("Map "..mapId)
  -- zone & area via Eluna’s Global:GetAreaName
  local zoneName = GetAreaName(zoneId) or ("Zone "..zoneId)
  local areaName = GetAreaName(areaId) or ("Area "..areaId)
  return mapName, zoneName, areaName
end
-- ------------------------------------------------------------- kill farm protection
local KillFarm = {}   -- [killer][victim] = {cnt = 0, first = 0}
local function isFarmed(killer, victim, cfg)
    local kg, vg = killer:GetGUIDLow(), victim:GetGUIDLow()
    local now    = os.time()
    KillFarm[kg]           = KillFarm[kg] or {}
    local rec              = KillFarm[kg][vg] or {cnt = 0, first = now}
    if now - rec.first > cfg.KILL_FARM_WINDOW_SEC then
        rec.cnt, rec.first = 0, now                     -- window expired
    end
    rec.cnt = rec.cnt + 1
    KillFarm[kg][vg] = rec
    if rec.cnt > cfg.KILL_FARM_MAX_KILLS then           -- punish
        killer:SendBroadcastMessage("|cffff0000[Ultimate PvP]|r "..cfg.KILL_FARM_PUNISH_MSG)
        return true
    end
    return false
end
-- -------------------------------------------------------------- Gold Format
local ChestGold = {}                -- chestGUID → pending gold
local function fmtCoins(c)
    local g,s,co = math.floor(c/10000), math.floor(c/100)%100, c%100
    local t={} if g>0 then t[#t+1]=g.." g" end
    if s>0 then t[#t+1]=s.." s" end
    if co>0 or #t==0 then t[#t+1]=co.." c" end
    return table.concat(t," ")
end

-- --------------------------------------------------------------- Discord/Web Hook
local function postWebhook(killer, victim, items, gold, cfg, mapId, zoneId, areaId)
    if #cfg.WEBHOOK_URLS == 0 then return end
    local mapName  = (mapId == 0 and "Eastern Kingdoms") or (mapId == 1 and "Kalimdor") or ("Map "..mapId)
    local zoneName = GetAreaName(zoneId)
    local areaName = GetAreaName(areaId)

    local json = string.format([[
    {
      "username":"%s",
      "avatar_url":"%s",
      "embeds":[
        {
          "title":"%s ▸ %s",
          "fields":[
            {"name":"Items Lost","value":"%d","inline":true},
            {"name":"Gold Lost","value":"%s","inline":true},
            {"name":"Map","value":"%s","inline":false},
            {"name":"Zone","value":"%s","inline":true},
            {"name":"Area","value":"%s","inline":true}
          ]
        }
      ]
    }
    ]],
      cfg.WEBHOOK_USERNAME, cfg.WEBHOOK_ICON_URL,
      killer:GetName(), victim:GetName(),
      #items, fmtCoins(gold),
      mapName, zoneName, areaName
    )

    local isWindows = package.config:sub(1,1) == '\\'
    for _, url in ipairs(cfg.WEBHOOK_URLS) do
        if isWindows then
            -- find where this function’s script lives
            local info      = debug.getinfo(postWebhook, "S").source
            local scriptPath= info:sub(2):match("(.+[/\\])") or "./"
            local filePath  = scriptPath .. "ultpvp_webhook.json"

            -- write the JSON beside the script
            local f, err = io.open(filePath, "w")
            if not f then
              print("[Ultimate PvP] ERROR writing to", filePath, "–", err)
            else
              f:write(json)
              f:close()
            end

            -- then curl it
            local cmd = string.format(
              'cmd /C curl -H "Content-Type: application/json" -X POST -d "@%s" "%s"',
              filePath, url
            )
            print("[Ultimate PvP] RAW CMD →", cmd)
            os.execute(cmd)
            os.remove(filePath)
        else
            -- Linux/Unix: direct, backgrounded curl with in-memory JSON
            local cmd = string.format(
              "curl -m 2 -s -H 'Content-Type: application/json' -X POST -d '%s' '%s' > /dev/null 2>&1 &",
              json, url
            )
            os.execute(cmd)
        end  
    end      
end         

-- -------------------------------------------------------------------- Fix Chest Prep
local function OnLootStateChange(event, go, state)
    local guid = go:GetGUIDLow()
    local list = LootStore[guid]
        if CFG.DEBUG then
            print(string.format(
                "[PvPChest][DEBUG] GUID=%d state=%d  stored=%s",
                guid, state, list and #list or 0
            ))
        end
    if not list then return end

    -- catch *any* state other than READY (1)
    if state ~= 1 then
        -- if it's not “just looted” (3), we need to re-add everything
        if state ~= 3 then
            for _, d in ipairs(list) do
                go:AddLoot(d.entry, d.count)
            end
        end
        go:SetLootState(1)
    end
end
RegisterGameObjectEvent(CFG.CHEST_ENTRY, 9, OnLootStateChange)
-- -------------------------------------------------------------------- Local Check for Enabled
local function ModIsActiveHere(player, cfg)
    local mapId  = player:GetMapId()
    local zoneId = player:GetZoneId()
    local areaId = player:GetAreaId()

    if not cfg.ENABLE_MOD                                   then return false end
    if cfg.IGNORE_CAPITALS        and CAPITAL_AREAS[areaId]  then return false end
    if cfg.IGNORE_NEUTRAL_CITIES  and NEUTRAL_CITY_AREAS[areaId] then return false end

    if cfg.MAP_BLOCKLIST[mapId]         then return false end
    if cfg.ZONE_BLOCKLIST[zoneId]       then return false end
    if cfg.AREA_BLOCKLIST[areaId]       then return false end

    if next(cfg.MAP_ALLOWLIST)  and not cfg.MAP_ALLOWLIST[mapId]   then return false end
    if next(cfg.ZONE_ALLOWLIST) and not cfg.ZONE_ALLOWLIST[zoneId] then return false end
    if next(cfg.AREA_ALLOWLIST) and not cfg.AREA_ALLOWLIST[areaId] then return false end

    return true
end

-- ------------------------------------------------------------------
-- Return bag-family mask for an item if the build supports it
--  0  = regular bag
-- >0 = profession-specific
-- ------------------------------------------------------------------

local function BagFamily(item)
    if not item then return 0 end
    if item.GetBagFamily then                     -- newer cores
        return item:GetBagFamily()
    end
    if item.GetTemplate then                      -- fallback via template
        local tpl = item:GetTemplate()
        if tpl and tpl.GetBagFamily then
            return tpl:GetBagFamily()
        end
    end
    return 0                                      -- unknown ⇒ treat as normal bag
end

local function dbg(msg) if CFG.DEBUG then print("[PvPChest] "..msg) end end

local function link(it)
    return string.format("|cffffffff|Hitem:%d|h[%s]|h|r",
        it:GetEntry(), it:GetItemLink():match("%[(.-)%]") or "item")
end
-- --------------------------------------------------------- spirit range helper
local function IsNearSpiritHealer(plr, dist)
    dist=dist or 20
    for _,cr in pairs(plr:GetCreaturesInRange(dist)) do
        if SPIRIT_HEALER_IDS[cr:GetEntry()] then return true end
    end
    return false
end

-- ------------------------------------------------------------enchanted helper
local function isEnchanted(it)
    for slot = 0, 15 do
        local ok, id = pcall(it.GetEnchantmentId, it, slot)
        if ok and id and id > 0 then return true end
    end
    return false
end
-- -------------------------------------------------------------- item gatherer
local function ShouldDropItem(it, owner, bagSlot, cfg)
    if not it then return false end    
    -- grab template if available
    local tpl = (it.GetTemplate and it:GetTemplate()) or nil

    -- entry ID
    local entry = it:GetEntry()

    -- flags
    local flags = 0
    if it.GetFlags then
        flags = it:GetFlags()
    elseif tpl and tpl.GetFlags then
        flags = tpl:GetFlags()
    end

    -- class & subclass
    local class, subClass = 0, 0
    if it.GetClass then
        class = it:GetClass()
        if it.GetSubClass then
            subClass = it:GetSubClass()
        end
    elseif tpl and tpl.GetClass then
        class = tpl:GetClass()
        if tpl.GetSubClass then
            subClass = tpl:GetSubClass()
        end
    end

      -- debug item level
    dbg(string.format("Checking item %d: class = %d: and subclass = %d", entry, class, subClass))


    -- quality
    local quality = 0
    if it.GetQuality then
        quality = it:GetQuality()
    elseif tpl and tpl.GetQuality then
        quality = tpl:GetQuality()
    end

    -- sell price
    local sellPrice = 0
    if it.GetSellPrice then
        sellPrice = it:GetSellPrice()
    elseif tpl and tpl.GetSellPrice then
        sellPrice = tpl:GetSellPrice()
    end

    -- item level
    local ilvl = 0
    if it.GetItemLevel then
        ilvl = it:GetItemLevel()
    elseif tpl and tpl.GetItemLevel then
        ilvl = tpl:GetItemLevel()
    end

    --required level
    local reqLvl = 0
    if it.GetRequiredLevel then
        reqLvl = it:GetRequiredLevel()
    elseif tpl and tpl.GetRequiredLevel then
        reqLvl = tpl:GetRequiredLevel()
    end

    local tradable = it.CanBeTraded and it:CanBeTraded() or false  

      -- debug item level
    dbg(string.format("Checking item %d: ItemLevel = %d", entry, ilvl))

    -- unique-equipped flag
    local uniqueEq = false
    if tpl and tpl.IsUniqueEquipped then
        uniqueEq = tpl:IsUniqueEquipped()
    end

      -- debug item level
    dbg(string.format("Checking item %d: uniqueEq = %s", entry,tostring(uniqueEq)))
    -- -----------------------------------------------------------
    -- explicit allow / deny
    -- -----------------------------------------------------------
    if cfg.CUSTOM_ALLOW_IDS[entry] then
        dbg(("Allow – item %d is in CUSTOM_ALLOW_IDS"):format(entry))
        return true
    end

    if cfg.CUSTOM_IGNORE_IDS[entry] then
        dbg(("Abort – item %d is in CUSTOM_IGNORE_IDS"):format(entry))
        return false
    end
    -- conjured ------------------------------------------------------------
    if cfg.IGNORE_CONJURED and it:IsConjuredConsumable() then
        dbg("  → skipped: conjured consumable") return false
    end
    -- soul-bound ----------------------------------------------------------
    if cfg.IGNORE_SOULBOUND and it:IsSoulBound() then
        dbg("Abort – soul-bound item, IGNORE_SOULBOUND=true")
        return false
    end

    -- quest item ----------------------------------------------------------
    if cfg.IGNORE_QUEST_ITEMS and tpl and tpl.GetBonding then
        local b = tpl:GetBonding()
        if b == 4 or b == 5 then
            dbg(("Abort – quest item (bonding %d), IGNORE_QUEST_ITEMS=true"):format(b))
            return false
        end
    end

    -- class / subclass–based filters -------------------------------------
    if cfg.IGNORE_CONSUMABLES and class == 0 then
        dbg("Abort – consumable, IGNORE_CONSUMABLES=true")
        return false
    end

    if cfg.IGNORE_REAGENTS and (class == 5 or class == 9) then
        dbg(("Abort – reagent class %d, IGNORE_REAGENTS=true"):format(class))
        return false
    end

    if cfg.IGNORE_KEYS and class == 13 then
        dbg("Abort – key item, IGNORE_KEYS=true")
        return false
    end

    if cfg.IGNORE_HEIRLOOMS and quality == 7 then
        dbg("Abort – heirloom, IGNORE_HEIRLOOMS=true")
        return false
    end

    if cfg.IGNORE_UNIQUE_EQUIPPED and uniqueEq then
        dbg("Abort – unique-equipped item, IGNORE_UNIQUE_EQUIPPED=true")
        return false
    end

    if cfg.IGNORE_ENCHANTED_EQUIPPED and isEnchanted(it) then
        dbg("Abort – enchanted item, IGNORE_ENCHANTED_EQUIPPED=true")
        return false
    end

    if cfg.IGNORE_TRADABLE_ITEMS and tradable then
        dbg("Abort – tradable item, IGNORE_TRADABLE_ITEMS=true")
        return false
    end

    if cfg.IGNORE_NON_TRADABLE_ITEMS and not tradable then
        dbg("Abort – non-tradable item, IGNORE_NON_TRADABLE_ITEMS=true")
        return false
    end

    -- quality / BoP filters ----------------------------------------------
    if cfg.IGNORE_QUALITY[quality] then
        dbg(("Abort – quality %d ignored via IGNORE_QUALITY"):format(quality))
        return false
    end

    if cfg.IGNORE_BOP and tpl and tpl.GetBonding and tpl:GetBonding() == 1 then
        dbg("Abort – Bind-on-Pickup item, IGNORE_BOP=true")
        return false
    end

    -- profession-bag slots (bags 1-4 only) --------------------------------
    if cfg.IGNORE_PROFESSION_BAG_SLOTS and bagSlot and bagSlot > 0 then
        local bag = owner:GetItemByPos(255, bagSlot + 18)        -- 19-22 container slots
        if bag and BagFamily(bag) ~= 0 then                      -- non-generic bag family
            dbg(("Abort – item in profession bag (slot %d)"):format(bagSlot))
            return false
        end
    end
    
    dbg(string.format("Checking %s: sellPrice = %d", it:GetItemLink(), sellPrice))
    if cfg.IGNORE_VENDOR_VALUE_BELOW > 0 and sellPrice < cfg.IGNORE_VENDOR_VALUE_BELOW then
        dbg("  → skipped: below threshold of "..cfg.IGNORE_VENDOR_VALUE_BELOW)
        return false
    end
    
    -- numeric thresholds (only if values known)

    -- vendor price
    if cfg.IGNORE_VENDOR_VALUE_BELOW > 0 and sellPrice < cfg.IGNORE_VENDOR_VALUE_BELOW then
        dbg(("Abort – vendor value %d < %d"):format(sellPrice, cfg.IGNORE_VENDOR_VALUE_BELOW))
        return false
    end

    -- item level
    if cfg.IGNORE_ITEMLEVEL_BELOW > 0 and ilvl < cfg.IGNORE_ITEMLEVEL_BELOW then
        dbg(("Abort – item level %d < %d"):format(ilvl, cfg.IGNORE_ITEMLEVEL_BELOW))
        return false
    end

    -- required level
    if cfg.IGNORE_REQUIREDLEVEL_BELOW > 0 and reqLvl < cfg.IGNORE_REQUIREDLEVEL_BELOW then
        dbg(("Abort – required level %d < %d"):format(reqLvl, cfg.IGNORE_REQUIREDLEVEL_BELOW))
        return false
    end

    -- stack size
    local stack = it:GetCount()
    if cfg.IGNORE_STACK_SIZE_ABOVE > 0 and stack > cfg.IGNORE_STACK_SIZE_ABOVE then
        dbg(("Abort – stack size %d > %d"):format(stack, cfg.IGNORE_STACK_SIZE_ABOVE))
        return false
    end

    -- table-driven class / subclass ignore
    if cfg.CUSTOM_IGNORE_CLASSES[tostring(class)]
    or cfg.CUSTOM_IGNORE_CLASSES[class.."."..subClass] then
        return false
    end

    return true
end

-- ------------------------------------------------------------
-- Collect every candidate item according to CFG container flags
-- ------------------------------------------------------------
local function gatherItems(plr, cfg)
    local list, total = {}, 0

    -- internal helper --------------------------------------------------
    local function add(it, where, bagIndex)
        if it and ShouldDropItem(it, plr, bagIndex, cfg) then
            total = total + 1
            -- snapshot ↓
            list[#list+1] = {
                entry  = it:GetEntry(),
                count  = it:GetCount(),
                pretty = link(it),
            }
            dbg(string.format("  %s %s x%d", where, it:GetItemLink(), it:GetCount()))
        end
    end

    -- ------------------------------------------------------------------
    -- 1) EQUIPPED SLOTS 0-18
    -- ------------------------------------------------------------------
    if cfg.INCLUDE_EQUIPPED then
        for slot = 0, 18 do
            -- skip any slot the user has marked to ignore
            if not cfg.IGNORE_EQUIPPED_SLOTS[slot] then
                add(plr:GetEquippedItemBySlot(slot), "eq ", nil)
            end
        end
    end

    -- ------------------------------------------------------------------
    -- 2) BACKPACK (bag 0, inv slots 23-38)
    -- ------------------------------------------------------------------
    if cfg.INCLUDE_BACKPACK then
        for slot = 23, 38 do
            add(plr:GetItemByPos(255, slot), "bp ", 0)         -- bagIndex 0
        end
    end

    -- ------------------------------------------------------------------
    -- 3) ADDITIONAL BAGS (inventory slots 19-22 → bags 1-4)
    -- ------------------------------------------------------------------
    if cfg.INCLUDE_BAGS then
        for invSlot = 19, 22 do
            local bagItem = plr:GetItemByPos(255, invSlot)
            if bagItem then
                local bagIndex = invSlot - 18                 -- 1-4
                for slot = 0, bagItem:GetBagSize() - 1 do
                    add(plr:GetItemByPos(invSlot, slot),
                        "bag"..bagIndex.." ", bagIndex)
                end
            end
        end
    end

    dbg("Collected "..total.." items from "..plr:GetName())
    return list
end

-- simple Fisher-Yates --------------------------------------------------
local function shuffle(t)
    for i = #t, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end
-- ------------------------------------------------------------ chest open
local function OnChestUse(event, go, player)
    local guid = go:GetGUIDLow()
    local gold = ChestGold[guid]
    if gold and gold > 0 then
        player:ModifyMoney(gold)
        ChestGold[guid] = nil
        -- just tell the looter
        player:SendAreaTriggerMessage(string.format("You looted %s from the spoils chest!", fmtCoins(gold)))
    end
end
RegisterGameObjectEvent(CFG.CHEST_ENTRY, 14, OnChestUse)

-- ------------------------------------------------------------ Multi-drop
local function spawnChests(killer, victim, items, cfg)
    local take = math.max(1, math.floor(#items * cfg.ITEM_DROP_PERCENT / 100 + 0.5))
    dbg("Dropping " .. take .. " of " .. #items .. " items (" .. cfg.ITEM_DROP_PERCENT .. "%)")
    local totalChests = math.ceil(take / MAX_CHEST_ITEMS)

    -- --------------------------------------------------------------
    -- gold distribution
    -- --------------------------------------------------------------
    local victimGold = victim:GetCoinage()
    local pct = math.random(cfg.GOLD_PERCENT_MIN, cfg.GOLD_PERCENT_MAX)
    local rawGive = math.floor(victimGold * pct / 100)
    if cfg.GOLD_CAP_PER_KILL > 0 and rawGive > cfg.GOLD_CAP_PER_KILL then
        rawGive = cfg.GOLD_CAP_PER_KILL
    end
    
    if rawGive > 0 then
        if cfg.MMR_GOLD_REWARD then 
            local mmrDelta = killer:GetData("MMR") - victim:GetData("MMR")
            if mmrDelta > 0 then
                local multiplier = math.max(1.0, 1 + (mmrDelta / 100) * (cfg.MMR_GOLD_REWARD_RATIO - 1))
                rawGive = math.min(math.floor(rawGive * multiplier), victimGold)
            end
        end
        victim:ModifyMoney(-rawGive)
    end

    local perChest, remainder = 0, 0
    if rawGive > 0 then
        if cfg.SPLIT_GOLD_BETWEEN_CHESTS then
            perChest  = math.floor(rawGive / totalChests)
            remainder = rawGive - (perChest * totalChests)
        else
            remainder = rawGive
        end
    end

    dbg("Spawning " .. totalChests .. " chest(s)")
    local baseX, baseY, baseZ, baseO = victim:GetX(), victim:GetY(), victim:GetZ(), victim:GetO()
    local radius = 2.5
    local angleStep = (2 * math.pi) / totalChests
    local idx = 1

    for c = 1, totalChests do
        local angle = angleStep * (c - 1)
        local cx = baseX + math.cos(angle) * radius
        local cy = baseY + math.sin(angle) * radius

        local chest = killer:SummonGameObject(cfg.CHEST_ENTRY, cx, cy, baseZ, baseO, cfg.DESPAWN_SEC)
        if not chest then
            dbg("Chest spawn FAILED (" .. c .. ")")
            break
        end

        local guid = chest:GetGUIDLow()
        dbg("Chest #" .. c .. " GUID " .. guid)

        -- free-for-all
        pcall(function() chest:SetLootRecipient(nil) end)

        -- record and fill items
        LootStore[guid] = {}
        for slot = 1, MAX_CHEST_ITEMS do
            if idx > take then break end
            local data = items[idx]
            idx = idx + 1

            chest:AddLoot(data.entry, data.count)
            victim:RemoveItem(data.entry, data.count)
            dbg(string.format("    + %s x%d", data.pretty, data.count))

            table.insert(LootStore[guid], {
                entry  = data.entry,
                count  = data.count,
                pretty = data.pretty,
            })
        end

        -- stash gold
        if rawGive > 0 and cfg.SPLIT_GOLD_BETWEEN_CHESTS then
            local gold = perChest
            if c == 1 then gold = gold + remainder end
            if gold > 0 then
                ChestGold[guid] = gold
                dbg(string.format("    + %s → gold", fmtCoins(gold)))
            end
        end

        -- force chest into READY
        chest:SetLootState(1)
    end
    return rawGive
end

-- -------------------------------------------------------------- MMR helper functions
local function MMR_Load(player)
    if player:GetData("MMR") then return end
    local guid = player:GetGUIDLow()
    local name = player:GetName()
    CharDBQueryAsync(("SELECT `mmr`, `kills`, `deaths`, `streak` FROM `"..CFG.MMR_DB.."`.`"..CFG.MMR_TABLE.."` WHERE `guid` = "..guid), function(query)
        local player = GetPlayerByName(name) -- Hack to re-fetch player object in callback
        player:SetData("MMR", (query and query:GetUInt32(0)) or CFG.STARTING_MMR)
        player:SetData("KILLS", (query and query:GetUInt32(1)) or 0)
        player:SetData("DEATHS", (query and query:GetUInt32(2)) or 0)
        player:SetData("STREAK", (query and query:GetUInt32(3)) or 0)
    end)
end

local function MMR_Save(player)
    CharDBExecute(string.format(
        "INSERT INTO `%s`.`%s` VALUES (%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE "..
        "mmr=VALUES(mmr),kills=VALUES(kills),deaths=VALUES(deaths),streak=VALUES(streak)",
        CFG.MMR_DB, CFG.MMR_TABLE, player:GetGUIDLow(),
        player:GetData("MMR"), player:GetData("KILLS"),
        player:GetData("DEATHS"), player:GetData("STREAK")
    ))
end


local function MMR_GetCurrencyCount(player, itemId)
    if itemId == 43308 then return player:GetHonorPoints()
    elseif itemId == 43307 then return player:GetArenaPoints()
    else return player:GetItemCount(itemId, true) end
end

local function MMR_RemoveItem(victim, itemId, actualGained)
    if itemId == 43308 then victim:ModifyHonorPoints(-actualGained)
    elseif itemId == 43307 then victim:ModifyArenaPoints(-actualGained)
    else victim:RemoveItem(itemId, actualGained) end
    victim:SendBroadcastMessage("You have lost "..actualGained.." "..GetItemLink(itemId)..".")
end

local function MMR_CurrencyTransactions(killer, victim, rewardFlag, lossFlag, itemId, amount)
    if rewardFlag then
        local initialCount = MMR_GetCurrencyCount(killer, itemId)
        
        if itemId == 43308 then killer:ModifyHonorPoints(amount)
        elseif itemId == 43307 then killer:ModifyArenaPoints(amount)
        else killer:AddItem(itemId, amount) end
        
        local actualGained = MMR_GetCurrencyCount(killer, itemId) - initialCount
        
        if actualGained > 0 then
            killer:SendBroadcastMessage("You have earned "..actualGained.." "..GetItemLink(itemId)..".")
            if lossFlag then MMR_RemoveItem(victim, itemId, actualGained) end
        end
    elseif lossFlag then MMR_RemoveItem(victim, itemId, amount) end
end

local function MMR_ProcessRewardsAndLosses(killer, victim, cfg)
    local mmrDelta = math.abs(victim:GetData("MMR") - killer:GetData("MMR"))
    if mmrDelta < (killer:GetData("MMR") * cfg.MMR_REWARD_THRESHOLD / 100) then return end
    
    if (cfg.MMR_KILL_REWARD or cfg.MMR_KILL_LOSS) then -- High MMR killers earn less, low MMR killers earn more
        local mmrDiff = victim:GetData("MMR") - killer:GetData("MMR")
        local KillItemIDChange = math.min(
            math.floor((mmrDiff > 0 and mmrDiff or (mmrDiff < 0 and math.abs(mmrDiff) * 0.1 or 1)) * cfg.MMR_KILL_RATE), 
            MMR_GetCurrencyCount(victim, cfg.MMR_KILL_ITEM_ID)
        )
        
        MMR_CurrencyTransactions(killer, victim, cfg.MMR_KILL_REWARD, cfg.MMR_KILL_LOSS, cfg.MMR_KILL_ITEM_ID, KillItemIDChange)
    end

    if cfg.MMR_ANNOUNCE_STREAK then
        local gender = "him" if killer:GetGender() == 1 then gender = "her" end
        local newStreakIcon = "|TInterface/ICONS/ability_hunter_markedfordeath:15:15:0:0|t "
        
        if killer:GetData("STREAK") >= CFG.MMR_STREAK_LIMIT then
            SendWorldMessage(newStreakIcon.."Player "..killer:GetName().." has an open-world PvP kill streak of "..killer:GetData("STREAK").."! Kill "..gender.." for extra PvP rewards. "..newStreakIcon)
            killer:SendBroadcastMessage("Careful! Other players can now earn your "..GetItemLink(cfg.MMR_STREAK_ITEM_ID).." if they kill you in open-world PvP.")
        end
       
        local lostStreakIcon = "|TInterface/ICONS/ability_rogue_feigndeath:15:15:0:0|t "
        if victim:GetData("STREAK") >= CFG.MMR_STREAK_LIMIT then
            SendWorldMessage(lostStreakIcon.." Player "..killer:GetName().." just broke "..victim:GetName().."'s streak of "..victim:GetData("STREAK").." kills and earned extra PvP rewards. "..lostStreakIcon)
        end
    end
    
    if (cfg.MMR_STREAK_REWARD or cfg.MMR_STREAK_LOSS) and victim:GetData("STREAK") >= cfg.MMR_STREAK_LIMIT then
        local StreakItemIDChange = math.min(
            math.floor(victim:GetData("STREAK")^cfg.MMR_STREAK_MULTIPL * cfg.MMR_STREAK_RATE), 
            MMR_GetCurrencyCount(victim, cfg.MMR_STREAK_ITEM_ID)
        )
            
        MMR_CurrencyTransactions(killer, victim, cfg.MMR_STREAK_REWARD, cfg.MMR_STREAK_LOSS, cfg.MMR_STREAK_ITEM_ID, StreakItemIDChange)
    end

    dbg(string.format("MMR Rewards/losses processed for killer %s, victim %s", killer:GetName(), victim:GetName()))
end

local function MMR_Update(killer, victim, cfg)
    local killerMMR = killer:GetData("MMR")
    local victimMMR = victim:GetData("MMR")
    
    local mmrGain = cfg.MMR_GAIN
    local mmrLoss = cfg.MMR_LOSS
    
    if cfg.MMR_REWARDS then MMR_ProcessRewardsAndLosses(killer, victim, cfg) end
    
    if cfg.MMR_DIMINISHING_RETURNS then
        local mmrDifference = victimMMR - killerMMR
        local intervals = math.floor(math.abs(mmrDifference) / CFG.STARTING_MMR)
        
        if mmrDifference > 0 then -- Killing higher MMR = more reward
            mmrGain = mmrGain + (intervals * cfg.MMR_DIM_RETURN_RATE)
            mmrLoss = mmrLoss + (intervals * cfg.MMR_DIM_RETURN_RATE)
        else -- Killing lower MMR = less reward
            mmrGain = math.max(1, mmrGain - (intervals * cfg.MMR_DIM_RETURN_RATE))
            mmrLoss = math.max(1, mmrLoss - (intervals * cfg.MMR_DIM_RETURN_RATE))
        end
    end
    
    killer:SetData("MMR", killerMMR + mmrGain)
    killer:SetData("KILLS", killer:GetData("KILLS") + 1)
    killer:SetData("STREAK", killer:GetData("STREAK") + 1)
    victim:SetData("MMR", math.max(0, victimMMR - mmrLoss))
    victim:SetData("DEATHS", victim:GetData("DEATHS") + 1)
    victim:SetData("STREAK", 0)
  
    if cfg.MMR_ANNOUNCE_CHANGE then 
        local icon = "|TInterface/ICONS/achievement_pvp_a_h:15:15:0:0|t "
        victim:SendBroadcastMessage(icon.."Your open-world PvP MMR has decreased by "..mmrLoss.." to "..victim:GetData("MMR")..". "..icon)
        killer:SendBroadcastMessage(icon.."Your open-world PvP MMR has increased by "..mmrGain.." to "..killer:GetData("MMR")..". "..icon)
    end
    
    dbg(string.format("MMR UPDATE: Killer "..killer:GetName()..", GUIDLow "..killer:GetGUIDLow()..", updated MMR from "..killerMMR.." to "..killer:GetData("MMR")))
    dbg(string.format("MMR UPDATE: Victim "..victim:GetName()..", GUIDLow "..victim:GetGUIDLow()..", updated MMR from "..victimMMR.." to "..victim:GetData("MMR")))
end

-- ------------------------------------------------------------ Load/save MMR to persistent storage
if CFG.MMR_ENABLED then
    CharDBExecute("CREATE DATABASE IF NOT EXISTS `"..CFG.MMR_DB.."`") -- Create custom db if it doesn't already exist

    CharDBExecute("CREATE TABLE IF NOT EXISTS `" .. CFG.MMR_DB .. "`.`" .. CFG.MMR_TABLE .. "` (" ..
        "`guid` INT PRIMARY KEY, `mmr` INT, `kills` INT, `deaths` INT, `streak` INT);")

    for _, player in pairs(GetPlayersInWorld()) do MMR_Load(player) end -- Load MMR on reload eluna
    RegisterPlayerEvent(4, function(_, player) MMR_Save(player) end)    -- Save MMR on player save
    RegisterPlayerEvent(26, function(_, player) MMR_Save(player) end)   -- Save MMR on logout
    RegisterPlayerEvent(28, function(_, player) MMR_Load(player)  end)  -- Load MMR on login/map change
end

-- -------------------------------------------------------------- main callback
local function OnKillPlayer(event, killer, victim)
    -- grab the per-zone config
    local mapId = victim:GetMapId()
    local areaId = victim:GetAreaId()
    local zoneId = victim:GetZoneId()
    local cfg    = GetCFG(areaId, zoneId)

    --suicide check
    if IGNORE_SUICIDE then
        if killer:GetGUIDLow() == victim:GetGUIDLow() then
            dbg("Abort – self-kill detected")
            return
        end
    end
    dbg(string.format("--- PvP kill detected in zone %d ---", zoneId))

    -- 0) master switch
    if not cfg.ENABLE_MOD then
        dbg("Abort – mod disabled (ENABLE_MOD=false)")
        return
    end
    if cfg.ENABLE_KILL_FARM_PROTECTION then
        -- .5) farming guard
        if isFarmed(killer, victim, cfg) then
            dbg("Abort – farming guard triggered")
            return
        end
    end

    -- 1) silly ones
    if cfg.IGNORE_IF_KILLER_DRUNK and killer:GetDrunkValue() > 0 then
    dbg("Abort – killer drunk stage " .. killer:GetDrunkValue())
        return
    end

    if cfg.IGNORE_IF_VICTIM_DRUNK and victim:GetDrunkValue() > 0 then
        dbg("Abort – victim drunk stage " .. victim:GetDrunkValue())
        return
    end

    if cfg.IGNORE_AFK_VICTIM and victim:IsAFK() then
        dbg("Abort – victim is AFK")
        return
    end

    if cfg.IGNORE_VICTIM_ALLIANCE and victim:IsAlliance() then
        dbg("Abort – victim is Alliance, IGNORE_VICTIM_ALLIANCE=true")
        return
    end

    if cfg.IGNORE_VICTIM_HORDE and victim:IsHorde() then
        dbg("Abort – victim is Horde, IGNORE_VICTIM_HORDE=true")
        return
    end
    -- 2) battleground & arena toggle
    if cfg.IGNORE_BATTLEGROUND and victim:InBattleground() then
        dbg("Battleground – abort")
        return
    end
    if cfg.IGNORE_ARENA           and (killer:InArena() or victim:InArena()) then return end

    -- 4) level gates
    if victim:GetLevel() < cfg.MIN_LEVEL or victim:GetLevel() > cfg.MAX_LEVEL then
        dbg("Outside level gate – abort")
        return
    end

    -- 5) level-difference window
    local diff = math.abs(killer:GetLevel() - victim:GetLevel())
    if diff < cfg.MIN_LEVEL_DIFF or diff > cfg.MAX_LEVEL_DIFF then
        dbg("Level diff "..diff.." outside window – abort")
        return
    end

    -- 6) map / zone filters 
    if next(cfg.MAP_ALLOWLIST) and not cfg.MAP_ALLOWLIST[mapId] then
        dbg("Abort – mapId " .. mapId .. " not in allow-list")
        return
    end
    if cfg.MAP_BLOCKLIST[mapId] then
        dbg("Abort – mapId " .. mapId .. " is block-listed")
        return
    end

    if next(cfg.ZONE_ALLOWLIST) and not cfg.ZONE_ALLOWLIST[zoneId] then
        dbg("Abort – zoneId " .. zoneId .. " not in allow-list")
        return
    end
    if cfg.ZONE_BLOCKLIST[zoneId] then
        dbg("Abort – zoneId " .. zoneId .. " is block-listed")
        return
    end

    if next(cfg.AREA_ALLOWLIST) and not cfg.AREA_ALLOWLIST[areaId] then
        dbg("Abort – areaId " .. areaId .. " not in allow-list")
        return
    end
    if cfg.AREA_BLOCKLIST[areaId] then
        dbg("Abort – areaId " .. areaId .. " is block-listed")
        return
    end

    -- 7) spirit-healer proximity
    if cfg.IGNORE_SPIRIT_HEALER_RANGE and IsNearSpiritHealer(victim, cfg.SPIRIT_HEALER_RANGE) then
        dbg("Near spirit healer – abort")
        return
    end

    -- 8) capital / neutral city gates
    if cfg.IGNORE_CAPITALS and CAPITAL_AREAS[areaId] then
        dbg("Inside capital city – abort")
        return
    end
    if cfg.IGNORE_NEUTRAL_CITIES and NEUTRAL_CITY_AREAS[areaId] then
        dbg("Inside neutral city – abort")
        return
    end

    -- 9) Custom Aura Checks for both Victim/Killer
    for spellId in pairs(cfg.IGNORE_AURA_ON_VICTIM) do
        if victim:HasAura(spellId) then
            dbg("Abort – victim has ignored aura " .. spellId)
            return
        end
    end

    for spellId in pairs(cfg.IGNORE_AURA_ON_KILLER) do
        if killer:HasAura(spellId) then
            dbg("Abort – killer has ignored aura " .. spellId)
            return
        end
    end

    dbg("Killer "..killer:GetName().." ("..killer:GetLevel()..") / Victim "
        ..victim:GetName().." ("..victim:GetLevel()..")")

    -- resurrection sickness
    if cfg.IGNORE_RESS_SICKNESS and victim:HasAura(15007) then
        dbg("Resurrection sickness – abort")
        return
    end

    if CFG.MMR_ENABLED then -- Consider moving this below "spawnChests" to bar MMR changes from killing players without a single item
        MMR_Update(killer, victim, cfg) -- Update MMR in cache only if requirements are fulfilled
    end
    
    local items = gatherItems(victim, cfg)
    if #items == 0 then
        dbg("No items to drop")
        return
    end

    shuffle(items)
    local rawGive = spawnChests(killer, victim, items, cfg)

    ---------------------------------------------Hook for cross script/web compatability
        if cfg.ENABLE_WEBHOOK and #cfg.WEBHOOK_URLS > 0 then
            -- schedule the webhook to fire 50 ms later,
            -- letting the kill-handler finish without blocking
            local kGUID = killer:GetGUIDLow()
            local vGUID = victim:GetGUIDLow()

            CreateLuaEvent(function()
                local killer2 = GetPlayerByGUID(kGUID)
                local victim2 = GetPlayerByGUID(vGUID)
                if not killer2 or not victim2 then
                    return  -- they logged out or object expired
                end
                if #items >= cfg.HOOK_SEND_ITEM_THRESHOLD
                and rawGive >= cfg.HOOK_SEND_GOLD_THRESHOLD then
                    postWebhook(killer2, victim2, items, rawGive, cfg, mapId, zoneId, areaId)
                end
            end, 50, 1)
        end

    for _, fn in ipairs(PvPLootHooks) do
        pcall(fn, killer, victim, items, rawGive, cfg, mapId, zoneId, areaId)
    end
    dbg("--- done ---")
end

RegisterPlayerEvent(6, OnKillPlayer)
           -- 6 = ON_KILL_PLAYER




--========================================================================--
--                            COMMANDS                                    --
--========================================================================--
if(CFG.NOTIFY_PLAYER_OF_COMMAND) then
    -- ON_LOGIN 
    RegisterPlayerEvent(3, function(_, player)
        if not CFG.ENABLE_MOD then return end  

        player:SendBroadcastMessage("|cffff0000Ultimate PvP|r is active on this realm.")
        player:SendBroadcastMessage("Type |cff00ff00.ultpvp|r at any time to see the full-loot rules for the zone you’re in.")
        player:SendBroadcastMessage("Type |cff00ff00.ultpvprisk|r to show exactly what you risk, if applicable.")

    end)
end

------------------------------------------------------------------------
--  GM-only maintenance + regular player info in one handler
------------------------------------------------------------------------

-- helpers -------------------------------------------------------------
local function boolify(s)
    if s == "true" or s == "1" then return true
    elseif s == "false" or s == "0" then return false end
end

local function reloadCfg(plr)                 -- plr may be nil!
    if plr then
        plr:SendBroadcastMessage("|cffffff00[Ultimate PvP]|r Reloading Eluna scripts …")
    else
        SendWorldMessage("|cffffff00[Ultimate PvP]|r Reloading Eluna scripts …")
    end
    ReloadEluna()
end

-- main command hook ---------------------------------------------------
RegisterPlayerEvent(42, function(_, player, msg)
    if not msg:match("^ultpvp") then return end

    local args = {}
    for w in msg:gmatch("%S+") do args[#args + 1] = w end
    local sub = args[2]

    --------------------------------------------------------------------
    -- GM-ONLY BRANCH (always allowed for GMs)
    --------------------------------------------------------------------
    if sub == "reload" or sub == "set" then
        if not player:IsGM() then
            player:SendBroadcastMessage("|cffffff00[Ultimate PvP]|r GM-only command.")
            return false
        end

        if sub == "reload" then                               -- .ultpvp reload
            local ok, err = pcall(reloadCfg)
            player:SendBroadcastMessage(ok
                and "|cffffff00[Ultimate PvP]|r Config reloaded."
                or "|cffffff00[Ultimate PvP]|r Reload FAILED: "..err)
            return false
        end

        if sub == "set" then                                  -- .ultpvp set K V
            local key, raw = args[3], args[4]
            if not key or not raw then
                player:SendBroadcastMessage("|cffffff00Usage:|r .ultpvp set <KEY> <VALUE>")
                return false
            end
            if CFG[key] == nil then
                player:SendBroadcastMessage("|cffffff00[Ultimate PvP]|r Unknown key: "..key)
                return false
            end
            local val = boolify(raw) or tonumber(raw) or raw
            CFG[key] = val
            player:SendBroadcastMessage(("|cffffff00[Ultimate PvP]|r %s → %s"):format(key, tostring(val)))
            return false
        end
    end

    --------------------------------------------------------------------
    -- PLAYER-VISIBLE BRANCH (gated by CFG.ALLOW_PLAYER_COMMAND)
    --------------------------------------------------------------------
    if not CFG.ALLOW_PLAYER_COMMAND then return end

    local zoneId = player:GetZoneId()
    local areaId = player:GetAreaId()
    local cfg    = GetCFG(areaId, zoneId)

    local function yesNo(v) return v and "|cff00ff00Yes|r" or "|cffff0000No|r" end
    local zoneActive = not cfg.ZONE_BLOCKLIST[zoneId] and
                       (next(cfg.ZONE_ALLOWLIST) == nil or cfg.ZONE_ALLOWLIST[zoneId])
    local areaActive = not cfg.AREA_BLOCKLIST[areaId] and
                       (next(cfg.AREA_ALLOWLIST) == nil or cfg.AREA_ALLOWLIST[areaId])
 
    -- ".ultpvp"
    if sub == nil then
        player:SendBroadcastMessage(
            ("|cffffff00[Ultimate PvP]|r  Zone %d active: %s  |  Area %d active: %s"):format(
            zoneId, yesNo(zoneActive), areaId, yesNo(areaActive)))

        if areaActive then
            player:SendBroadcastMessage(" • Your possessions |cffff0000ARE|r at risk!")

            local flags = {}

            if cfg.INCLUDE_EQUIPPED           then table.insert(flags, "Equipped Items")      end
            if cfg.INCLUDE_BACKPACK           then table.insert(flags, "Backpack")            end
            if cfg.INCLUDE_BAGS               then table.insert(flags, "Bags 1-4")            end
            if cfg.INCLUDE_BANK_ITEMS         then table.insert(flags, "Bank")                end

            if not cfg.IGNORE_CONSUMABLES     then table.insert(flags, "Consumables")         end
            if not cfg.IGNORE_REAGENTS        then table.insert(flags, "Reagents")            end
            if not cfg.IGNORE_KEYS            then table.insert(flags, "Keys")                end
            if not cfg.IGNORE_CONJURED        then table.insert(flags, "Conjured Items")      end
            if not cfg.IGNORE_HEIRLOOMS       then table.insert(flags, "Heirlooms")           end
            if not cfg.IGNORE_SOULBOUND       then table.insert(flags, "Soulbound Items")     end
            if not cfg.IGNORE_UNIQUE_EQUIPPED then table.insert(flags, "Unique-Equipped")     end
            if not cfg.IGNORE_ENCHANTED_EQUIPPED then table.insert(flags, "Enchanted Items")  end
            if not cfg.IGNORE_TRADABLE_ITEMS  then table.insert(flags, "Tradable Items")      end
            if not cfg.IGNORE_NON_TRADABLE_ITEMS then table.insert(flags, "Non-Tradable")     end

            local qualityNames = { [0]="Poor",[1]="Common",[2]="Uncommon",[3]="Rare",
                                    [4]="Epic",[5]="Legendary",[6]="Artifact",[7]="Heirloom" }
            for q = 0,7 do
                if cfg.IGNORE_QUALITY[q] == false then
                    table.insert(flags, qualityNames[q].." Items")
                end
            end

            if #flags > 0 then
                player:SendBroadcastMessage(" • |cffffff00Risk Factors Active:|r")
                for _, f in ipairs(flags) do
                    player:SendBroadcastMessage("   – "..f..": |cff00ff00YES|r")
                end
            end
        else
            player:SendBroadcastMessage(" • Your possessions |cff00ff00ARE NOT|r at risk.")
        end
        return false
    end

    -- ".ultpvp risk"  (or legacy ".ultpvprisk")
    if sub == "risk" or msg == "ultpvprisk" then
        if not areaActive then
            player:SendBroadcastMessage("|cffffff00[Ultimate PvP]|r No items at risk — Area inactive.")
            return false
        end
        local inv = gatherItems(player, cfg, true)
        player:SendBroadcastMessage("|cffffff00[Ultimate PvP]|r PvP Loot Risk Preview")
        if not inv or #inv == 0 then
            player:SendBroadcastMessage(" • No items currently eligible for PvP drop.")
        else
            for _, data in ipairs(inv) do
                player:SendBroadcastMessage("   - "..data.pretty)
            end
            player:SendBroadcastMessage((" • Eligible Items: |cffffff00%d|r"):format(#inv))
        end
        return false
    end
end)