-- Author      : nihilianth
-- Create Date : 4/11/2021 9:31:39 PM

State = State or true
CityFilter = CityFilter or true

local tarSpell = {993943, "Titan Scroll: Norgannon"}
-- local tarSpell = {27269, "Fire Shield"}

local majorCities = 
{
  "Stormwind City",
  "Darnassus",
  "Ironforge",
  "Exodar",
  "Orgrimmar",
  "Thunder Bluff",
  "Undercity",
  "Silvermoon City",
  "Dalaran",
  "Shattrath City"
}

local function RemoveNorg()
  if UnitAura("player", tarSpell[2]) == nil then
    return
  end
  if CityFilter == true then
    local isInCity = false
    local zoneText = GetZoneText()
    -- TODO: Use the zone change event instead
    for _, name in pairs(majorCities) do
      if zoneText == name then
        isInCity = true
        -- print("Player is in "..zoneText)
        break
      end
    end

    if isInCity == false then return end
  end
  print("Removing "..tarSpell[2])
  CancelUnitBuff("player", tarSpell[2])
end

local function CheckNorg(self, event, ...)
  if State == false then return end

  if event == "ZONE_CHANGED_NEW_AREA" then
    -- print("New zone: "..GetZoneText())
    RemoveNorg()
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    -- _, subevent, _, sourceGUID, _, destGUID, _, _, spellID, spellName, _, _, _
    
    local subevent = select(2, ...)
    local destGUID = select(6, ...)
    local spellID = select(9, ...)
    local spellName = select(10, ...)

    if destGUID == UnitGUID("player") then
      -- print(spellName, spellID, subevent)
    end
    if subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH" then  
      if spellID == tarSpell[1] and destGUID == UnitGUID("player") then
        RemoveNorg()
      end
    end
  end
  
end

local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", CheckNorg)

local function SetState(newState)
  State = newState
  print("NorgAway: "..(State and "on" or "off"))
  if State == true then
    RemoveNorg()
  end
end

print("NorgAway: "..(State and "on" or "off"))

local function NorgCommands(msg, editbox)
  if msg == 'off' then
    SetState(false)
  elseif msg == 'city' then
    CityFilter = not CityFilter
    print("NorgAway: City Filter turned ".. (CityFilter and "on" or "off"))
    if State == true then
      RemoveNorg()
    end
  elseif msg == 'on' then
    SetState(true)
  else
    print("unknown command. Available commands: \n/norg off\n/norg on\n/norg city")
  end
end

SLASH_NORG1 = '/norg'

SlashCmdList["NORG"] = NorgCommands