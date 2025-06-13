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
    ENABLE_MOD            = true,        -- turn the whole system on/off

    --------------------------------------------------------------------
    -- Map / zone filters
    --------------------------------------------------------------------
    MAP_ALLOWLIST         = {[0]=true},      -- e.g. [0]=true,[571]=true
    MAP_BLOCKLIST         = {},
    ZONE_ALLOWLIST        = {[47]=true},--Hinterlands Only.Remove for All
    ZONE_BLOCKLIST        = {},           -- [4197]=true, :Wintergrasp    

    --------------------------------------------------------------------
    -- Level restrictions
    --------------------------------------------------------------------
    MIN_LEVEL             = 1,
    MAX_LEVEL             = 80,
    MIN_LEVEL_DIFF        = 0,
    MAX_LEVEL_DIFF        = 4,
    --------------------------------------------------------------------
    -- Container inclusion
    --------------------------------------------------------------------
    INCLUDE_EQUIPPED           = true,
    INCLUDE_BACKPACK           = true,   -- bag 0
    INCLUDE_BAGS               = true,   -- bags 1-4
    INCLUDE_BANK_ITEMS         = false,  -- (future)

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
    IGNORE_QUALITY = {                  -- 0 poor, 1 common, 2 uncommon,
        [1] = false,                    -- 3 rare, 4 epic, 5 legendary
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = true,   -- ignore legendaries
    },
    IGNORE_BOP              = false,
    --------------------------------------------------------------------
    -- Gold filters
    --------------------------------------------------------------------
    SPLIT_GOLD_BETWEEN_CHESTS = true,
    GOLD_PERCENT_MIN         = 100,     -- roll between MIN and MAX %
    GOLD_PERCENT_MAX         = 100,    -- 50-100 % example
    GOLD_CAP_PER_KILL        = 25000000, -- 2500 g cap (0 = no cap)
    --------------------------------------------------------------------
    -- Numeric thresholds
    --------------------------------------------------------------------
    IGNORE_VENDOR_VALUE_BELOW  = 0,      -- copper
    IGNORE_ITEMLEVEL_BELOW     = 0,
    IGNORE_STACK_SIZE_ABOVE    = 0,      -- 0 = off

    --------------------------------------------------------------------
    -- Explicit allow / deny
    --------------------------------------------------------------------
    CUSTOM_IGNORE_IDS          = {},     -- { [19019]=true, [17182]=true }
    CUSTOM_ALLOW_IDS           = {},     -- overrides all ignore checks
    CUSTOM_IGNORE_CLASSES      = {},     -- e.g. { ["0"]=true, ["4.6"]=true },
   
    --------------------------------------------------------------------
    -- Chest & loot parameters
    --------------------------------------------------------------------
    CHEST_ENTRY           = 2069420,     -- chest template
    ITEM_DROP_PERCENT     = 100,         -- % of victim items to drop
    DESPAWN_SEC           = 60,          -- chest lifetime (seconds)
    CREATE_DEFAULT_CHEST  = true,        -- create initial gameobject SQL

    --------------------------------------------------------------------
    -- Context exclusions
    --------------------------------------------------------------------
    IGNORE_BATTLEGROUND       = true,    -- skip BG kills
    IGNORE_SPIRIT_HEALER_RANGE= true,    -- apply range check below
    SPIRIT_HEALER_RANGE       = 20,      -- metres
    IGNORE_RESS_SICKNESS      = true,    -- skip if victim has aura 15007

    --------------------------------------------------------------------
    -- Debug
    --------------------------------------------------------------------
    DEBUG                   = false,
}
local DefaultCFG = CFG     ---do not alter

--========================================================================--
--                    Individual Zone Overrides Section                   --
--      Your zones will use default settings unless stated otherwise..    --
--========================================================================--
local ZoneOverrides = {
  -- Hinterlands (zoneId = 47) gets double despawn time
  --    and legendaries are flagged to drop.
  [47] = {
      DESPAWN_SEC    = 120,
      IGNORE_QUALITY = {
        [1] = false,
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = false,  
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

local function dbg(msg)  if CFG.DEBUG then print("[PvPChest] "..msg) end end
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
            add(plr:GetEquippedItemBySlot(slot), "eq ", nil)   -- nil bagIndex
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
local function spawnChests(killer, victim, items,cfg)
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


