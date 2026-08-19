
require("scripts/autotracking/item_mapping")
require("scripts/autotracking/location_mapping")

CUR_INDEX = -1
--SLOT_DATA = nil

ALL_LOCATIONS = {}
SLOT_DATA = {}
POACH_DB = {}
EXCLUDED_MONSTER_NAMES = {}

if Highlight then
    HIGHTLIGHT_LEVEL= {
        [0] = Highlight.Unspecified,
        [10] = Highlight.NoPriority,
        [20] = Highlight.Avoid,
        [30] = Highlight.Priority,
        [40] = Highlight.None,
    }
end

function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ','
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function ForceUpdate()
    local update = Tracker:FindObjectForCode("update")
    if update == nil then
        return
    end
    update.Active = not update.Active
end

function onClearHandler(slot_data)
    local clear_timer = os.clock()
    
    ScriptHost:RemoveWatchForCode("StateChange")
    -- Disable tracker updates.
    Tracker.BulkUpdate = true
    -- Use a protected call so that tracker updates always get enabled again, even if an error occurred.
    local ok, err = pcall(onClear, slot_data)
    -- Enable tracker updates again.
    if ok then
        -- Defer re-enabling tracker updates until the next frame, which doesn't happen until all received items/cleared
        -- locations from AP have been processed.
        local handlerName = "AP onClearHandler"
        local function frameCallback()
            ScriptHost:AddWatchForCode("StateChange", "*", StateChanged)
            ScriptHost:RemoveOnFrameHandler(handlerName)
            Tracker.BulkUpdate = false
            ForceUpdate()
            print(string.format("Time taken total: %.2f", os.clock() - clear_timer))
        end
        ScriptHost:AddOnFrameHandler(handlerName, frameCallback)
    else
        Tracker.BulkUpdate = false
        print("Error: onClear failed:")
        print(err)
    end
end

function onClear(slot_data)
    ScriptHost:RemoveWatchForCode("StateChanged")
    ScriptHost:RemoveOnLocationSectionHandler("location_section_change_handler")
    --SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, location_array in pairs(LOCATION_MAPPING) do
        for _, location in pairs(location_array) do
            if location then
                local location_obj = Tracker:FindObjectForCode(location)
                if location_obj then
                    if location:sub(1, 1) == "@" then
                        location_obj.AvailableChestCount = location_obj.ChestCount
                    else
                        location_obj.Active = false
                    end
                end
            end
        end
    end
    -- reset items
    for _, item_array in pairs(ITEM_MAPPING) do
        for _, item_pair in pairs(item_array) do
            item_code = item_pair[1]
            item_type = item_pair[2]
            -- print("on clear", item_code, item_type)
            local item_obj = Tracker:FindObjectForCode(item_code)
            if item_obj then
                if item_obj.Type == "toggle" then
                    item_obj.Active = false
                elseif item_obj.Type == "progressive" then
                    item_obj.CurrentStage = 0
                elseif item_obj.Type == "consumable" then
                    if item_obj.MinCount then
                        item_obj.AcquiredCount = item_obj.MinCount
                    else
                        item_obj.AcquiredCount = 0
                    end
                elseif item_obj.Type == "progressive_toggle" then
                    item_obj.CurrentStage = 0
                    item_obj.Active = false
                end
            end
        end
    end
    PLAYER_ID = Archipelago.PlayerNumber or -1
    TEAM_NUMBER = Archipelago.TeamNumber or 0
    SLOT_DATA = slot_data
    autoFill(slot_data)
    if Archipelago.PlayerNumber > -1 then
        if #ALL_LOCATIONS > 0 then
            ALL_LOCATIONS = {}
        end
        for _, value in pairs(Archipelago.MissingLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        for _, value in pairs(Archipelago.CheckedLocations) do
            table.insert(ALL_LOCATIONS, #ALL_LOCATIONS + 1, value)
        end

        HINTS_ID = "_read_hints_"..TEAM_NUMBER.."_"..PLAYER_ID
        Archipelago:SetNotify({HINTS_ID})
        Archipelago:Get({HINTS_ID})
    end
    ScriptHost:AddOnFrameHandler("load handler", OnFrameHandler)
end

function onItem(index, item_id, item_name, player_number)
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local item = ITEM_MAPPING[item_id]
    if not item or not item[1] then
        --print(string.format("onItem: could not find item mapping for id %s", item_id))
        return
    end
    for _, item_pair in pairs(item) do
        item_code = item_pair[1]
        item_type = item_pair[2]
        local item_obj = Tracker:FindObjectForCode(item_code)
        if item_obj then
            if item_obj.Type == "toggle" then
                -- print("toggle")
                item_obj.Active = true
            elseif item_obj.Type == "progressive" then
                -- print("progressive")
                item_obj.CurrentStage = item_obj.CurrentStage + 1
            elseif item_obj.Type == "consumable" then
                -- print("consumable")
                item_obj.AcquiredCount = item_obj.AcquiredCount + item_obj.Increment * (tonumber(item_pair[3]) or 1)
            elseif item_obj.Type == "progressive_toggle" then
                -- print("progressive_toggle")
                if item_obj.Active then
                    item_obj.CurrentStage = item_obj.CurrentStage + 1
                else
                    item_obj.Active = true
                end
            end
        else
            print(string.format("onItem: could not find object for code %s", item_code[1]))
        end
    end
end

--called when a location gets cleared
function onLocation(location_id, location_name)
    local location_array = LOCATION_MAPPING[location_id]
    if not location_array or not location_array[1] then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
        return
    end

    for _, location in pairs(location_array) do
        local location_obj = Tracker:FindObjectForCode(location)
        -- print(location, location_obj)
        if location_obj then
            if location:sub(1, 1) == "@" then
                location_obj.AvailableChestCount = location_obj.AvailableChestCount - 1
            else
                location_obj.Active = true
            end
        else
            print(string.format("onLocation: could not find location_object for code %s", location))
        end
    end
end

function onEvent(key, value, old_value)
    updateEvents(value)
end

function onEventsLaunch(key, value)
    updateEvents(value)
end

-- this Autofill function is meant as an example on how to do the reading from slotdata and mapping the values to 
-- your own settings
function autoFill()
    if SLOT_DATA == nil  then
        print("its fucked")
        return
    end
    if true then
        for settings_name, settings_value in pairs(SLOT_DATA) do
            if settings_name == "logical_difficulty" then
			    item = Tracker:FindObjectForCode("easydifficulty")
			    item.CurrentStage = settings_value
			end
			if settings_name == "zodiac_stones_required" then
			    item = Tracker:FindObjectForCode("requiredstones")
			    item.AcquiredCount = settings_value
			end
			if settings_name == "final_battles" then
			    item = Tracker:FindObjectForCode("altimaonly")
				item.Active = false
				if settings_value > 0 then
				    item = Tracker:FindObjectForCode("altimaonly")
					item.Active = true
		        end
			end
			if settings_name == "sidequest_battles" then
			    item = Tracker:FindObjectForCode("sidequests")
				item.Active = false
				if settings_value > 0 then
				    item = Tracker:FindObjectForCode("sidequests")
					item.Active = true
		        end
			end
			if settings_name == "rare_battles" then
			    item = Tracker:FindObjectForCode("rarebattles")
				item.Active = false
			    if settings_value > 0 then
				    item = Tracker:FindObjectForCode("rarebattles")
					item.Active = true
		        end
			end
			if settings_name == "job_unlocks" then
			    item = Tracker:FindObjectForCode("jobunlocks")
				item.Active = false
			    if settings_value > 0 then
				    item = Tracker:FindObjectForCode("jobunlocks")
					item.Active = true
		        end
			end
			if settings_name == "poach_locations" then
			    item = Tracker:FindObjectForCode("poaches")
				item.Active = false
			    if settings_value > 0 then
				    item = Tracker:FindObjectForCode("poaches")
					item.Active = true
		        end
			end
			if settings_name == "enemy_randomizer" then
				item = Tracker:FindObjectForCode("enemyrandodisabled")
			    item.CurrentStage = settings_value
			end
			if settings_name == "move_find_item_locations" then
			    item = Tracker:FindObjectForCode("mfienabled")
				item.Active = false
				if settings_value > 0 then
				    item = Tracker:FindObjectForCode("mfienabled")
					item.Active = true
				end
			end
			if settings_name == "move_find_item_location_logic" then
			    item = Tracker:FindObjectForCode("mfilogicdefault")
			    item.CurrentStage = settings_value
			end
			if settings_name == "poach_database" then
				POACH_DB = settings_value
			end
			if settings_name == "excluded_monster_locations" then
				EXCLUDED_MONSTER_NAMES = {}
				for index, name in ipairs(settings_value) do
					EXCLUDED_MONSTER_NAMES[name] = name
				end
			end
        end
    end
end

function onNotify(key, value, old_value)
    print("onNotify", key, value, old_value)
    if value ~= old_value and key == HINTS_ID then
        Tracker.BulkUpdate = true
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if not hint.found then
                    updateHints(hint.location, hint.status)
                elseif hint.found then
                    updateHints(hint.location, hint.status)
                end
            end
        end
        Tracker.BulkUpdate = false
    end
end

function onNotifyLaunch(key, value)
    if key == HINTS_ID then
        Tracker.BulkUpdate = true
        for _, hint in ipairs(value) do
            if hint.finding_player == Archipelago.PlayerNumber then
                if not hint.found then
                    updateHints(hint.location, hint.status)
                else if hint.found then
                    updateHints(hint.location, hint.status)
                end end
            end
        end
        Tracker.BulkUpdate = false
    end
end

function updateHints(locationID, status) -->
    if Highlight then
        print(locationID, status)
        local location_table = LOCATION_MAPPING[locationID]
        for _, location in ipairs(location_table) do
            if location:sub(1, 1) == "@" then
                local obj = Tracker:FindObjectForCode(location)

                if obj then
                    obj.Highlight = HIGHTLIGHT_LEVEL[status]
                else
                    print(string.format("No object found for code: %s", location))
                end
            end
        end
    end
end

MAP_MAPPING = {
	[-1] = "World Map",
	[2] = "Lesalia City",
	[3] = "Murond Temple Hall",
	[5] = "Riovanes Castle Rooftop",
	[6] = "Riovanes Castle Gate",
	[7] = "Riovanes Castle Inside",
	[10] = "Igros Castle",
	[12] = "Lionel Castle Gate",
	[13] = "Lionel Castle Inside",
	[16] = "Limberry Castle Inside",
	[17] = "Limberry Underground Cemetery",
	[19] = "Limberry Castle Gate",
	[22] = "World Map",
	[25] = "Yardow",
	[27] = "Goland Coal City",
	[28] = "Goland Colliery First Floor",
	[29] = "Goland Colliery Second Floor",
	[30] = "Goland Colliery Third Floor",
	[31] = "Dorter Trade City",
	[32] = "Dorter Slums",
	[34] = "Sand Rat Cellar",
	[35] = "Zaland",
	[36] = "Zeltennia Castle",
	[39] = "Goland Underground Passage",
	[40] = "Goug",
	[44] = "Bervenia City",
	[47] = "Zarghidas",
	[49] = "Fort Zeakden",
	[50] = "Murond Temple Outside",
	[52] = "Murond Temple Chapel",
	[54] = "Lost Sacred Precincts",
	[55] = "Graveyard of Airships",
	[57] = "Underground Book Storage 1",
	[58] = "Underground Book Storage 2",
	[59] = "Underground Book Storage 3",
	[60] = "Underground Book Storage 4",
	[61] = "Underground Book Storage 5",
	[63] = "Golgorand Execution Site",
	[64] = "Bethla Sluice",
	[66] = "Bethla Garrison South Wall",
	[67] = "Bethla Garrison North Wall",
	[69] = "Murond Death City",
	[70] = "Nelveska Temple",
	[71] = "Dolbodar Swamp",
	[72] = "Fovoham Plains",
	[74] = "Sweegy Woods",
	[75] = "Bervenia Volcano",
	[76] = "Zeklaus Desert",
	[77] = "Lenalia Plateau",
	[78] = "Zigolis Swamp",
	[79] = "Yuguo Woods",
	[80] = "Araguay Woods",
	[81] = "Grog Hill",
	[82] = "Bed Desert",
	[83] = "Zirekile Falls",
	[84] = "Bariaus Hill",
	[85] = "Mandalia Plains",
	[86] = "Doguola Pass",
	[87] = "Bariaus Valley",
	[88] = "Finath River",
	[89] = "Poeskas Lake",
	[90] = "Germinas Peak",
	[91] = "Thieves' Fort",
	[103] = "Windmill Shed",
	[105] = "TERMINATE",
	[106] = "DELTA",
	[107] = "NOGIAS",
	[108] = "VOYAGE",
	[109] = "BRIDGE",
	[110] = "VALKYRIES",
	[111] = "MLAPAN",
	[112] = "TIGER",
	[113] = "HORROR",
	[114] = "END"
}

REGION_MAPPING = {
	[-1] = "World Map",
	[2] = "Lesalia",
	[3] = "Murond",
	[5] = "Fovoham",
	[6] = "Fovoham",
	[7] = "Fovoham",
	[10] = "Gallione",
	[12] = "Lionel",
	[13] = "Lionel",
	[16] = "Limberry",
	[17] = "Limberry",
	[19] = "Limberry",
	[22] = "World Map",
	[25] = "Fovoham",
	[27] = "Lesalia",
	[28] = "Lesalia",
	[29] = "Lesalia",
	[30] = "Lesalia",
	[31] = "Gallione",
	[32] = "Gallione",
	[34] = "Lesalia",
	[35] = "Lionel",
	[36] = "Zeltennia",
	[39] = "Lesalia",
	[40] = "Murond",
	[44] = "Zeltennia",
	[47] = "Zeltennia",
	[49] = "Gallione",
	[50] = "Murond",
	[52] = "Murond",
	[54] = "Murond",
	[55] = "Murond",
	[57] = "Murond",
	[58] = "Murond",
	[59] = "Murond",
	[60] = "Murond",
	[61] = "Murond",
	[63] = "Lionel",
	[64] = "Limberry",
	[66] = "Limberry",
	[67] = "Limberry",
	[69] = "Murond",
	[70] = "Zeltennia",
	[71] = "Limberry",
	[72] = "Fovoham",
	[74] = "Gallione",
	[75] = "Lesalia",
	[76] = "Lesalia",
	[77] = "Gallione",
	[78] = "Lionel",
	[79] = "Fovoham",
	[80] = "Lesalia",
	[81] = "Fovoham",
	[82] = "Limberry",
	[83] = "Lesalia",
	[84] = "Lionel",
	[85] = "Gallione",
	[86] = "Zeltennia",
	[87] = "Lionel",
	[88] = "Zeltennia",
	[89] = "Limberry",
	[90] = "Zeltennia",
	[91] = "Gallione",
	[103] = "Fovoham",
	[105] = "Murond",
	[106] = "Murond",
	[107] = "Murond",
	[108] = "Murond",
	[109] = "Murond",
	[110] = "Murond",
	[111] = "Murond",
	[112] = "Murond",
	[113] = "Murond",
	[114] = "Murond"
}

function onMap(value)
    if value ~= nil and value["data"] ~= nil then
		if Tracker:FindObjectForCode("mfienabled").Active then
			local current_map = value["data"]["current_map"]
			
			local region_tab = REGION_MAPPING[current_map]
			local tab = MAP_MAPPING[current_map]
			if region_tab ~= nil and tab ~= nil then
				if current_map == -1 then
					Tracker:UiHint("ActivateTab", "World Map")
				else
					Tracker:UiHint("ActivateTab", "Move-Find Items")
					Tracker:UiHint("ActivateTab", region_tab)
					Tracker:UiHint("ActivateTab", tab)
				end
			end
		end
    end
end


-- ScriptHost:AddWatchForCode("settings autofill handler", "autofill_settings", autoFill)
-- Archipelago:AddClearHandler("clear handler", onClearHandler)
-- Archipelago:AddItemHandler("item handler", onItem)
-- Archipelago:AddLocationHandler("location handler", onLocation)
Archipelago:AddBouncedHandler("map handler", onMap)

Archipelago:AddSetReplyHandler("notify handler", onNotify)
Archipelago:AddRetrievedHandler("notify launch handler", onNotifyLaunch)



--doc
--hint layout
-- {
--     ["receiving_player"] = 1,
--     ["class"] = Hint,
--     ["finding_player"] = 1,
--     ["location"] = 67361,
--     ["found"] = false,
--     ["item_flags"] = 2,
--     ["entrance"] = ,
--     ["item"] = 66062,
-- } 
