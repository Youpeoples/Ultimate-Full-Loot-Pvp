--========================================================================--
--                      ULTIMATE FULL LOOT PVP                            --
--========================================================================--

-- Below CFG Block, you will find INDIVIDUAL ZONE OVERRIDES.
-- There, you can override settings on a per-zone basis.
-- Any zone setting not explicitly listed in INDIVIDUAL ZONE OVERRIDES 
-- will inherit the default values defined within CFG.

local CFG = {
    --------------------------------------------------------------------
    -- Master toggle
    --------------------------------------------------------------------
    ENABLE_MOD                 = true,          -- Turn System on/off

    --------------------------------------------------------------------
    -- Map / zone filters           ( _LIST = {}  :: Allow All )
    --------------------------------------------------------------------
    MAP_ALLOWLIST              = {[0]=true},    -- e.g. { [0]=true,},
    MAP_BLOCKLIST              = {},            -- e.g. { [1]=true,},
    ZONE_ALLOWLIST             = {[47]=true},   --[47]Hinterlands
    ZONE_BLOCKLIST             = {[4197]=true}, --[4197]Wintergrasp    

    --------------------------------------------------------------------
    -- Level restrictions
    --------------------------------------------------------------------
    MIN_LEVEL                  = 1,
    MAX_LEVEL                  = 80,
    MIN_LEVEL_DIFF             = 0,       
    MAX_LEVEL_DIFF             = 4,
    --------------------------------------------------------------------
    -- Container inclusion
    --------------------------------------------------------------------
    INCLUDE_EQUIPPED           = true,
    INCLUDE_BACKPACK           = true,     -- bag 0
    INCLUDE_BAGS               = true,     -- bags 1-4
    INCLUDE_BANK_ITEMS         = false,    -- (future)

    --------------------------------------------------------------------
    -- Item-type filters
    --------------------------------------------------------------------
    IGNORE_QUEST_ITEMS         = true,
    IGNORE_CONSUMABLES         = false,
    IGNORE_REAGENTS            = false,
    IGNORE_KEYS                = true,
    IGNORE_PROFESSION_BAG_SLOTS= true,
    IGNORE_HEIRLOOMS           = true,
    IGNORE_UNIQUE_EQUIPPED     = false,
    IGNORE_SOULBOUND           = false,
    IGNORE_QUALITY = {                 
                           [1] = false,    -- ignore common 
                           [2] = false,    -- ignore uncommon
                           [3] = false,    -- ignore rare
                           [4] = false,    -- ignore epic
                           [5] = true,     -- ignore legendary
    },

    IGNORE_BOP                 = false,   -- ignore bind on pickup 

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
    --------------------------------------------------------------------
    -- Gold filters
    --------------------------------------------------------------------
    SPLIT_GOLD_BETWEEN_CHESTS  = true,
    GOLD_PERCENT_MIN           = 100,      -- roll between MIN and MAX %
    GOLD_PERCENT_MAX           = 100,      -- 50-100 % example
    GOLD_CAP_PER_KILL          = 25000000, -- 2500 g cap (0 = no cap)
    --------------------------------------------------------------------
    -- Numeric thresholds
    --------------------------------------------------------------------
    IGNORE_VENDOR_VALUE_BELOW  = 0,        -- copper
    IGNORE_ITEMLEVEL_BELOW     = 0,        -- the hidden rating(NOT RQ.LVL)
    IGNORE_STACK_SIZE_ABOVE    = 0,        -- 0 = off

    --------------------------------------------------------------------
    -- Explicit allow / deny
    --------------------------------------------------------------------
    CUSTOM_IGNORE_IDS          = {[6948]=true,   --Hearthstone
                                  [5976]=true,   --Guild Tabard 
                                 },
    CUSTOM_ALLOW_IDS           = {},       -- overrides all ignore checks
    CUSTOM_IGNORE_CLASSES      = {},       -- e.g. { ["0"]=true,},
   
    --------------------------------------------------------------------
    -- Chest & loot parameters
    --------------------------------------------------------------------
    CHEST_ENTRY               = 2069420,   -- chest template
    ITEM_DROP_PERCENT         = 100,       -- % of victim items to drop
    DESPAWN_SEC               = 60,        -- chest lifetime (seconds)
    CREATE_DEFAULT_CHEST      = true,      -- create initial gameobject SQL

    --------------------------------------------------------------------
    -- Context exclusions
    --------------------------------------------------------------------
    IGNORE_BATTLEGROUND       = true,      -- skip BG kills
    IGNORE_SPIRIT_HEALER_RANGE= true,      -- apply range check below
    SPIRIT_HEALER_RANGE       = 20,        -- metres
    IGNORE_RESS_SICKNESS      = true,      -- skip if victim has aura 15007
    
    --------------------------------------------------------------------
    -- MMR
    --------------------------------------------------------------------
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

    MMR_HONOR_REWARD          = true,  -- Earn honor on kills. Earn more if killer's MMR lower than victim's
    MMR_HONOR_LOSS            = true,  -- Lose honor on death. Lose less if victim's MMR lower than killer's
    MMR_HONOR_RATE            = 10,    -- Reward/lose honor by MMR (delta * rate)
    
    MMR_BREAK_STREAK_REWARD   = true,  -- Reward killer of streak holders with Arena Points
    MMR_BREAK_STREAK_LOSS     = true,  -- Lose arena points if killed while holding streak
    MMR_STREAK_LIMIT          = 3,     -- Streak must be at least X to award break rewards
    MMR_BREAK_STREAK_RATE     = 5,     -- Reward streak breakers (streak * rate) Arena Points
    MMR_BREAK_STREAK_MULTIPL  = 1.3,   -- Exponential multiplier for streak break reward/loss
    MMR_ANNOUNCE_STREAK       = true,  -- Send world messages on new/broken streaks
    
    -- MMR Back-End Setup
    MMR_DB                    = 'acore_eluna',
    MMR_TABLE                 = 'full_loot_pvp',

    --------------------------------------------------------------------
    -- Debug
    --------------------------------------------------------------------
    DEBUG                     = false,
}
local DefaultCFG = CFG     ---do not alter

--========================================================================--
--                    Individual Zone Overrides Section                   --
--      Your zones will use default settings unless stated otherwise..    --
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
--                       NO TOUCH BEYOND THIS POINT                       --
--========================================================================--
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
local function GetCFGForZone(zoneId)
  local cfg = {}
  -- copy all defaults
  for k,v in pairs(DefaultCFG) do
    cfg[k] = v
  end
  -- layer in any zone-specific tweaks
  local o = ZoneOverrides[zoneId]
  if o then
    for k,v in pairs(o) do
      cfg[k] = v
    end
  end
  return cfg
end
local LootStore = {} 
--------------------------------------------------------
local MAX_CHEST_ITEMS = 16          -- engine shows max 16 loot slots

----------------------------------------------- spirit-healer IDs
local SPIRIT_HEALER_IDS = {[6491]=true,[29259]=true,[32537]=true}

---------------------------------------------------------------- utils + debug
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

-- ------------------------------------------------------------------
-- Cross-Lua bit-and helper
-- ------------------------------------------------------------------
local band
if bit and bit.band then               -- LuaJIT / Lua 5.1 “bit” lib
    band = bit.band
elseif bit32 and bit32.band then       -- Lua 5.2 “bit32” lib
    band = bit32.band
else                                   -- pure-Lua fallback
    ---@param a integer @unsigned
    ---@param b integer @unsigned
    function band(a, b)
        local res, bitval = 0, 1
        while a > 0 or b > 0 do
            if (a % 2 == 1) and (b % 2 == 1) then
                res = res + bitval      -- set this bit
            end
            a     = math.floor(a / 2)
            b     = math.floor(b / 2)
            bitval = bitval * 2
        end
        return res
    end
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
local ChestGold = {}                -- chestGUID → pending gold
local function fmtCoins(c)
    local g,s,co = math.floor(c/10000), math.floor(c/100)%100, c%100
    local t={} if g>0 then t[#t+1]=g.." g" end
    if s>0 then t[#t+1]=s.." s" end
    if co>0 or #t==0 then t[#t+1]=co.." c" end
    return table.concat(t," ")
end
----------------------------------------------------------- helper: spirit range
local function IsNearSpiritHealer(plr, dist)
    dist=dist or 20
    for _,cr in pairs(plr:GetCreaturesInRange(dist)) do
        if SPIRIT_HEALER_IDS[cr:GetEntry()] then return true end
    end
    return false
end

---------------------------------------------------------------- item gatherer
local function ShouldDropItem(it, owner, bagSlot, cfg)
    if not it then return false end                 -- paranoia

    -------------------------------------------------------------
    -- Feature-probe what this core exposes
    -------------------------------------------------------------
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

      -- debug item level
    dbg(string.format("Checking item %d: ItemLevel = %d", entry, ilvl))

    -- unique-equipped flag
    local uniqueEq = false
    if tpl and tpl.IsUniqueEquipped then
        uniqueEq = tpl:IsUniqueEquipped()
    end

      -- debug item level
    dbg(string.format("Checking item %d: uniqueEq = %s", entry,tostring(uniqueEq)))
    -------------------------------------------------------------
    -- explicit allow / deny
    -------------------------------------------------------------
    if cfg.CUSTOM_ALLOW_IDS[entry] then return true end
    if cfg.CUSTOM_IGNORE_IDS[entry] then return false end

    -- soul-bound
    if cfg.IGNORE_SOULBOUND and it:IsSoulBound() then return false end

    -- quest flag (0x0004) – only if flags known
    if cfg.IGNORE_QUEST_ITEMS and band(flags, 0x0004) ~= 0 then return false end

    -- class / subclass based filters
    if cfg.IGNORE_CONSUMABLES     and class == 0                       then return false end
    if cfg.IGNORE_REAGENTS        and (class == 5 or class == 9)       then return false end
    if cfg.IGNORE_KEYS            and class == 13                      then return false end
    if cfg.IGNORE_HEIRLOOMS       and quality == 7                     then return false end
    if cfg.IGNORE_UNIQUE_EQUIPPED and uniqueEq                         then return false end
        -- quality / BoP filters ----------------------------------------
    if cfg.IGNORE_QUALITY[quality] then return false end
    if cfg.IGNORE_BOP and tpl and tpl.GetBonding and tpl:GetBonding() == 1 then
        return false
    end
    -- profession-bag slots (bags 1-4 only) -----------------------------
    if cfg.IGNORE_PROFESSION_BAG_SLOTS and bagSlot and bagSlot > 0 then
        -- inventory slots 19-22 hold the bag containers
        local bag = owner:GetItemByPos(255, bagSlot + 18)
        if BagFamily(bag) ~= 0 then             -- uses helper above
            return false                        -- ignore items in prof bags
        end
    end
    
    dbg(string.format("Checking %s: sellPrice = %d", it:GetItemLink(), sellPrice))
    if cfg.IGNORE_VENDOR_VALUE_BELOW > 0 and sellPrice < cfg.IGNORE_VENDOR_VALUE_BELOW then
        dbg("  → skipped: below threshold of "..cfg.IGNORE_VENDOR_VALUE_BELOW)
        return false
    end
    
    -- numeric thresholds (only if values known)
    if cfg.IGNORE_VENDOR_VALUE_BELOW > 0 and sellPrice < cfg.IGNORE_VENDOR_VALUE_BELOW then
        return false
    end
    if cfg.IGNORE_ITEMLEVEL_BELOW   > 0 and ilvl      < cfg.IGNORE_ITEMLEVEL_BELOW   then
        return false
    end
    if cfg.IGNORE_STACK_SIZE_ABOVE  > 0 and it:GetCount() > cfg.IGNORE_STACK_SIZE_ABOVE then
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

    --------------------------------------------------------------------
    -- 1) EQUIPPED SLOTS 0-18
    --------------------------------------------------------------------
    if cfg.INCLUDE_EQUIPPED then
        for slot = 0, 18 do
            -- skip any slot the user has marked to ignore
            if not cfg.IGNORE_EQUIPPED_SLOTS[slot] then
                add(plr:GetEquippedItemBySlot(slot), "eq ", nil)
            end
        end
    end

    --------------------------------------------------------------------
    -- 2) BACKPACK (bag 0, inv slots 23-38)
    --------------------------------------------------------------------
    if cfg.INCLUDE_BACKPACK then
        for slot = 23, 38 do
            add(plr:GetItemByPos(255, slot), "bp ", 0)         -- bagIndex 0
        end
    end

    --------------------------------------------------------------------
    -- 3) ADDITIONAL BAGS (inventory slots 19-22 → bags 1-4)
    --------------------------------------------------------------------
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
-------------------------------------------------------------- chest open
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

-------------------------------------------------------------- NEW multi-drop
local function spawnChests(killer, victim, items, cfg)
    local take = math.max(1, math.floor(#items * cfg.ITEM_DROP_PERCENT / 100 + 0.5))
    dbg("Dropping " .. take .. " of " .. #items .. " items (" .. cfg.ITEM_DROP_PERCENT .. "%)")
    local totalChests = math.ceil(take / MAX_CHEST_ITEMS)

    ----------------------------------------------------------------
    -- gold distribution
    ----------------------------------------------------------------
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
end

---------------------------------------------------------------- MMR helper functions
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

local function MMR_ProcessRewardsAndLosses(killer, victim, cfg)
    local mmrDelta = math.abs(victim:GetData("MMR") - killer:GetData("MMR"))

    if mmrDelta < (killer:GetData("MMR") * cfg.MMR_REWARD_THRESHOLD / 100) then return end
    
    if (cfg.MMR_HONOR_REWARD or cfg.MMR_HONOR_LOSS) then -- High MMR targets gain less honor on kill, low MMR targets gain more honor
        local mmrDiff = victim:GetData("MMR") - killer:GetData("MMR")
        local honorChange = math.min(
             math.floor((mmrDiff > 0 and mmrDiff or (mmrDiff < 0 and math.abs(mmrDiff) * 0.1 or 1)) * cfg.MMR_HONOR_RATE), 
            victim:GetHonorPoints()
        )
       
        if honorChange > 0 then
            if cfg.MMR_HONOR_REWARD then
                killer:ModifyHonorPoints(honorChange)
                killer:SendBroadcastMessage("You have earned "..honorChange.." "..GetItemLink(43308)..".") 
            end 
            if cfg.MMR_HONOR_LOSS then
                victim:ModifyHonorPoints(-honorChange)
                victim:SendBroadcastMessage("You have lost "..honorChange.." "..GetItemLink(43308)..".")
            end
        end
    end

    if cfg.MMR_ANNOUNCE_STREAK then
        local gender = "him" if killer:GetGender() == 1 then gender = "her" end
        local newStreakIcon = "|TInterface/ICONS/ability_hunter_markedfordeath:15:15:0:0|t "
        
        if killer:GetData("STREAK") >= CFG.MMR_STREAK_LIMIT then
            SendWorldMessage(newStreakIcon.."Player "..killer:GetName().." has an open-world PvP kill streak of "..killer:GetData("STREAK").."! Kill "..gender.." for extra PvP rewards. "..newStreakIcon)
            killer:SendBroadcastMessage("Careful! Other players can now earn your "..GetItemLink(43307).." if they kill you in open-world PvP.")
        end
       
        local lostStreakIcon = "|TInterface/ICONS/ability_rogue_feigndeath:15:15:0:0|t "
        if victim:GetData("STREAK") >= CFG.MMR_STREAK_LIMIT then
            SendWorldMessage(lostStreakIcon.." Player "..killer:GetName().." just broke "..victim:GetName().."'s streak of "..victim:GetData("STREAK").." kills and earned extra PvP rewards. "..lostStreakIcon)
        end
    end
    
    if (cfg.MMR_BREAK_STREAK_REWARD or cfg.MMR_BREAK_STREAK_LOSS) and victim:GetData("STREAK") >= cfg.MMR_STREAK_LIMIT then -- Award Arena Points reward on breaking streak
        local arenaPointsChange = math.min(math.floor(victim:GetData("STREAK")^cfg.MMR_BREAK_STREAK_MULTIPL * cfg.MMR_BREAK_STREAK_RATE), victim:GetArenaPoints())
        if cfg.MMR_BREAK_STREAK_REWARD then
            killer:ModifyArenaPoints(arenaPointsChange)
            killer:SendBroadcastMessage("You have earned "..arenaPointsChange.." "..GetItemLink(43307)..".")
        end
        if cfg.MMR_BREAK_STREAK_LOSS then
            victim:ModifyArenaPoints(-arenaPointsChange)
            victim:SendBroadcastMessage("You have lost "..arenaPointsChange.." "..GetItemLink(43307)..".")
        end
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

-------------------------------------------------------------- Load/save MMR to persistent storage
if CFG.MMR_ENABLED then
    CharDBExecute("CREATE DATABASE IF NOT EXISTS `"..CFG.MMR_DB.."`") -- Create custom db if it doesn't already exist

    CharDBExecute("CREATE TABLE IF NOT EXISTS `" .. CFG.MMR_DB .. "`.`" .. CFG.MMR_TABLE .. "` (" ..
        "`guid` INT PRIMARY KEY, `mmr` INT, `kills` INT, `deaths` INT, `streak` INT);")

    for _, player in pairs(GetPlayersInWorld()) do MMR_Load(player) end -- Load MMR on reload eluna
    RegisterPlayerEvent(4, function(_, player) MMR_Save(player) end)    -- Save MMR on player save
    RegisterPlayerEvent(26, function(_, player) MMR_Save(player) end)   -- Save MMR on logout
    RegisterPlayerEvent(28, function(_, player) MMR_Load(player)  end)  -- Load MMR on login/map change
end

---------------------------------------------------------------- main callback
local function OnKillPlayer(event, killer, victim)
    -- grab the per-zone config
    local zoneId = victim:GetZoneId()
    local cfg    = GetCFGForZone(zoneId)
    dbg(string.format("--- PvP kill detected in zone %d ---", zoneId))

    -- 0) master switch
    if not cfg.ENABLE_MOD then return end

    -- 2) battleground toggle
    if cfg.IGNORE_BATTLEGROUND and victim:InBattleground() then
        dbg("Battleground – abort")
        return
    end

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
    local mapId = victim:GetMapId()
    if next(cfg.MAP_ALLOWLIST)  and not cfg.MAP_ALLOWLIST[mapId] then return end
    if cfg.MAP_BLOCKLIST[mapId]                             then return end
    if next(cfg.ZONE_ALLOWLIST) and not cfg.ZONE_ALLOWLIST[zoneId] then return end
    if cfg.ZONE_BLOCKLIST[zoneId]                           then return end

    -- 7) spirit-healer proximity
    if cfg.IGNORE_SPIRIT_HEALER_RANGE and IsNearSpiritHealer(victim, cfg.SPIRIT_HEALER_RANGE) then
        dbg("Near spirit healer – abort")
        return
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
    spawnChests(killer, victim, items, cfg)
    dbg("--- done ---")
end

RegisterPlayerEvent(6, OnKillPlayer)
           -- 6 = ON_KILL_PLAYER
