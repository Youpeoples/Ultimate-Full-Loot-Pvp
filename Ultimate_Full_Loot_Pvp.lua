-- PvP Loot Chest 

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
    ZONE_ALLOWLIST        = {[47]=true},
    ZONE_BLOCKLIST        = {},

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
    GOLD_PERCENT          = 100,         -- % of gold to drop
    DESPAWN_SEC           = 60,         -- chest lifetime (seconds)

    --------------------------------------------------------------------
    -- Context exclusions
    --------------------------------------------------------------------
    IGNORE_BATTLEGROUND       = true,    -- skip BG kills
    IGNORE_SPIRIT_HEALER_RANGE= true,    -- apply range check below
    SPIRIT_HEALER_RANGE       = 20,      -- metres
    IGNORE_RESS_SICKNESS      = true,    -- skip if victim has aura 15007

    --------------------------------------------------------------------
    -- Item rarity & BoP filters
    --------------------------------------------------------------------
    IGNORE_QUALITY = {                  -- 0 poor, 1 common, 2 uncommon,
        [1] = false,                    -- 3 rare, 4 epic, 5 legendary
        [2] = false,
        [3] = false,
        [4] = false,
        [5] = true,   -- ignore legendaries
    },
    IGNORE_BOP              = false,

    --------------------------------------------------------------------
    -- Debug
    --------------------------------------------------------------------
    DEBUG                   = false,
}
-------------------------------------------------------- build fast lookup sets 
local IGNORE_ID = CFG.CUSTOM_IGNORE_IDS
local ALLOW_ID  = CFG.CUSTOM_ALLOW_IDS

local IGNORE_CLASS = CFG.CUSTOM_IGNORE_CLASSES  -- ["class"] or "class.sub"
local MAX_CHEST_ITEMS = 16          -- engine shows max 16 loot slots

----------------------------------------------- spirit-healer IDs
local SPIRIT_HEALER_IDS = {[6491]=true,[29259]=true,[32537]=true}

---------------------------------------------------------------- utils + debug

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
---------------------------------------------------- helper: item-filter checks
local function shouldSkipItem(it)
    if not it then return true end  -- safeguard
    if CFG.IGNORE_QUALITY[it:GetQuality()] then return true end
    if CFG.IGNORE_BOP then
        local tpl = it:GetTemplate()
        if tpl and tpl:GetBonding() == 1 then return true end
    end
    return false
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
local function ShouldDropItem(it, owner, bagSlot)
    if not it then return false end                 -- paranoia

    -------------------------------------------------------------
    -- Feature-probe what this core exposes
    -------------------------------------------------------------
    local hasItemMeta   = (it.GetFlags   and it.GetClass)           -- “new” item API
    local hasTemplateFn = (it.GetTemplate ~= nil)                  -- older cores
    local tpl           = hasTemplateFn and it:GetTemplate() or nil

    -- Accessors with graceful fallback --------------------------
    local function IFN(obj, fn,  ...) return (obj and obj[fn]) and obj[fn](obj, ...) end
    local function GET(obj, fn, d)    return (obj and obj[fn]) and obj[fn](obj) or d end

    local entry     = it:GetEntry()
    local flags     = hasItemMeta and GET(it,  "GetFlags",   0)
                   or tpl         and GET(tpl, "GetFlags",   0) or 0
    local class     = hasItemMeta and GET(it,  "GetClass",   0)
                   or tpl         and GET(tpl, "GetClass",   0) or 0
    local subClass  = hasItemMeta and GET(it,  "GetSubClass",0)
                   or tpl         and GET(tpl, "GetSubClass",0) or 0
    local quality = 0
    if it.GetQuality then                       -- best source
        quality = it:GetQuality()
    elseif tpl and tpl.GetQuality then          -- fallback
        quality = tpl:GetQuality()
    end

    local sellPrice = hasItemMeta and GET(it,  "GetSellPrice",0)
                   or tpl         and GET(tpl, "GetSellPrice",0) or 0
    local ilvl      = hasItemMeta and GET(it,  "GetItemLevel",0)
                   or tpl         and GET(tpl, "GetItemLevel",0) or 0
    local uniqueEq  = tpl and IFN(tpl,"IsUniqueEquipped")          -- boolean or nil

    -------------------------------------------------------------
    -- explicit allow / deny
    -------------------------------------------------------------
    if ALLOW_ID[entry]  then return true  end
    if IGNORE_ID[entry] then return false end

    -- soul-bound
    if CFG.IGNORE_SOULBOUND and it:IsSoulBound() then return false end

    -- quest flag (0x0004) – only if flags known
    if CFG.IGNORE_QUEST_ITEMS and band(flags, 0x0004) ~= 0 then return false end

    -- class / subclass based filters
    if CFG.IGNORE_CONSUMABLES     and class == 0                       then return false end
    if CFG.IGNORE_REAGENTS        and (class == 5 or class == 9)       then return false end
    if CFG.IGNORE_KEYS            and class == 13                      then return false end
    if CFG.IGNORE_HEIRLOOMS       and quality == 7                     then return false end
    if CFG.IGNORE_UNIQUE_EQUIPPED and uniqueEq                         then return false end
        -- quality / BoP filters ----------------------------------------
    if CFG.IGNORE_QUALITY[quality] then return false end
    if CFG.IGNORE_BOP and tpl and tpl.GetBonding and tpl:GetBonding() == 1 then
        return false
    end
    -- profession-bag slots (bags 1-4 only) -----------------------------
    if CFG.IGNORE_PROFESSION_BAG_SLOTS and bagSlot and bagSlot > 0 then
        -- inventory slots 19-22 hold the bag containers
        local bag = owner:GetItemByPos(255, bagSlot + 18)
        if BagFamily(bag) ~= 0 then             -- uses helper above
            return false                        -- ignore items in prof bags
        end
    end

    -- numeric thresholds (only if values known)
    if CFG.IGNORE_VENDOR_VALUE_BELOW > 0 and sellPrice < CFG.IGNORE_VENDOR_VALUE_BELOW then
        return false
    end
    if CFG.IGNORE_ITEMLEVEL_BELOW   > 0 and ilvl      < CFG.IGNORE_ITEMLEVEL_BELOW   then
        return false
    end
    if CFG.IGNORE_STACK_SIZE_ABOVE  > 0 and it:GetCount() > CFG.IGNORE_STACK_SIZE_ABOVE then
        return false
    end

    -- table-driven class / subclass ignore
    if IGNORE_CLASS[tostring(class)] or IGNORE_CLASS[class.."."..subClass] then
        return false
    end

    return true
end

-- ------------------------------------------------------------
-- Collect every candidate item according to CFG container flags
-- ------------------------------------------------------------
local function gatherItems(plr)
    local list, total = {}, 0

    -- internal helper --------------------------------------------------
    local function add(it, where, bagIndex)
        if it and ShouldDropItem(it, plr, bagIndex) then
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
    if CFG.INCLUDE_EQUIPPED then
        for slot = 0, 18 do
            add(plr:GetEquippedItemBySlot(slot), "eq ", nil)   -- nil bagIndex
        end
    end

    --------------------------------------------------------------------
    -- 2) BACKPACK (bag 0, inv slots 23-38)
    --------------------------------------------------------------------
    if CFG.INCLUDE_BACKPACK then
        for slot = 23, 38 do
            add(plr:GetItemByPos(255, slot), "bp ", 0)         -- bagIndex 0
        end
    end

    --------------------------------------------------------------------
    -- 3) ADDITIONAL BAGS (inventory slots 19-22 → bags 1-4)
    --------------------------------------------------------------------
    if CFG.INCLUDE_BAGS then
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
local function spawnChests(killer,victim,items)
    local take=math.max(1,math.floor(#items*CFG.ITEM_DROP_PERCENT/100+0.5))
    dbg("Dropping "..take.." of "..#items.." items ("..CFG.ITEM_DROP_PERCENT.."%)")
    local totalChests=math.ceil(take/MAX_CHEST_ITEMS)
    ----------------------------------------------------------------
    -- gold distribution
    ----------------------------------------------------------------
    local victimGold = victim:GetCoinage()
    -- roll percentage inside configured window ------------------------
    local pct = math.random(CFG.GOLD_PERCENT_MIN, CFG.GOLD_PERCENT_MAX)
    local rawGive = math.floor(victimGold * pct / 100)
    dbg(string.format("Gold roll: %d%% → %s (cap %s)",
    pct, fmtCoins(rawGive),
    CFG.GOLD_CAP_PER_KILL > 0 and fmtCoins(CFG.GOLD_CAP_PER_KILL) or "none"))
    -- apply hard cap --------------------------------------------------
    if CFG.GOLD_CAP_PER_KILL > 0 and rawGive > CFG.GOLD_CAP_PER_KILL then
        rawGive = CFG.GOLD_CAP_PER_KILL
    end

    if rawGive > 0 then
        victim:ModifyMoney(-rawGive)               -- take it once
    end

    local perChest, remainder = 0, 0
    if rawGive > 0 then
        if CFG.SPLIT_GOLD_BETWEEN_CHESTS then
            perChest  = math.floor(rawGive / totalChests)
            remainder = rawGive - (perChest * totalChests)     -- keep exact total
        else
            remainder = rawGive    -- all gold goes in chest #1
        end
    end    
    dbg("Spawning "..totalChests.." chest(s)")
    local baseX,baseY,baseZ,baseO=victim:GetX(),victim:GetY(),victim:GetZ(),victim:GetO()
    local radius=2.5
    local angleStep=6.28318530718/totalChests   -- 2π
    local idx=1
    for c=1,totalChests do
        local angle=angleStep*(c-1)
        local cx,cy=baseX+math.cos(angle)*radius, baseY+math.sin(angle)*radius
        local chest=killer:SummonGameObject(CFG.CHEST_ENTRY,cx,cy,baseZ,baseO,CFG.DESPAWN_SEC)
        if chest then
            dbg("Chest #"..c.." GUID "..chest:GetGUIDLow())
            pcall(function() chest:SetLootRecipient(nil) end)  -- FFA
            chest:SetLootState(0)
            for slot = 1, MAX_CHEST_ITEMS do
                if idx > take then break end
                local data = items[idx]; idx = idx + 1      -- table, not userdata

                chest:AddLoot(data.entry, data.count, data.count)
                victim:RemoveItem(data.entry, data.count)
                dbg(string.format("    + %s x%d", data.pretty, data.count))
            end
           -- stash the appropriate gold in this chest --------------
            if rawGive > 0 then
                local gold = perChest
                if c == 1 then gold = gold + remainder end
                if gold > 0 then
                    ChestGold[chest:GetGUIDLow()] = gold
                    dbg(string.format("    + %s → gold", fmtCoins(gold)))
                end
            end
            chest:SetLootState(1)
        else
            dbg("Chest spawn FAILED ("..c..")")
        end
    end
end

---------------------------------------------------------------- main callback
local function OnKillPlayer(event,killer,victim)
    dbg("--- PvP kill detected ---")
    -- 0) master switch
    if not CFG.ENABLE_MOD then return end

    -- 2) battleground toggle
    if CFG.IGNORE_BATTLEGROUND and victim:InBattleground() then
        dbg("Battleground – abort"); return
    end

    -- 4) level gates
    if victim:GetLevel() < CFG.MIN_LEVEL or victim:GetLevel() > CFG.MAX_LEVEL then
        dbg("Outside level gate – abort"); return
    end

    -- 5) level-difference window
    local diff = math.abs(killer:GetLevel() - victim:GetLevel())
    if diff < CFG.MIN_LEVEL_DIFF or diff > CFG.MAX_LEVEL_DIFF then
        dbg("Level diff "..diff.." outside window – abort"); return
    end

    -- 6) map / zone filters
    local mapId  = victim:GetMapId()
    local zoneId = victim:GetZoneId()
    if next(CFG.MAP_ALLOWLIST)  and not CFG.MAP_ALLOWLIST[mapId]  then return end
    if CFG.MAP_BLOCKLIST[mapId]                             then return end
    if next(CFG.ZONE_ALLOWLIST) and not CFG.ZONE_ALLOWLIST[zoneId] then return end
    if CFG.ZONE_BLOCKLIST[zoneId]                           then return end

    -- 7) spirit-healer proximity
    if CFG.IGNORE_SPIRIT_HEALER_RANGE and IsNearSpiritHealer(victim, CFG.SPIRIT_HEALER_RANGE) then
        dbg("Near spirit healer – abort"); return
    end

    dbg("Killer "..killer:GetName().." ("..killer:GetLevel()..") / Victim "
        ..victim:GetName().." ("..victim:GetLevel()..")")

   if CFG.IGNORE_RESS_SICKNESS and victim:HasAura(15007) then
        dbg("Resurrection sickness – abort"); return
    end

    local items=gatherItems(victim)
    if #items==0 then dbg("No items to drop"); return end
    shuffle(items)
    spawnChests(killer,victim,items)
    dbg("--- done ---")
end
RegisterPlayerEvent(6,OnKillPlayer)           -- 6 = ON_KILL_PLAYER


