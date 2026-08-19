function altimaonlyon()
    return Has("altimaonly") == AccessibilityLevel.Normal
end

function altimaonlyoff()
    return Has("altimaonly") == AccessibilityLevel.None
end

function sidequestson()
    return Has("sidequests") == AccessibilityLevel.Normal
end

function sidequestsoff()
    return Has("sidequests") == AccessibilityLevel.None
end

function rarebattleson()
    return Has("rarebattles") == AccessibilityLevel.Normal
end

function rarebattlesoff()
    return Has("rarebattles") == AccessibilityLevel.None
end

function jobunlockson()
    return Has("jobunlocks") == AccessibilityLevel.Normal
end

function jobunlocksoff()
    return Has("jobunlocks") == AccessibilityLevel.None
end

function poacheson()
    return Has("poaches") == AccessibilityLevel.Normal
end

function poachesoff()
    return Has("poaches") == AccessibilityLevel.None
end

function enemyrandoon()
	return Has("enemyrandorandomized") == AccessibilityLevel.Normal
end

function enemyrandooff()
	return Has("enemyrandorandomized") == AccessibilityLevel.None
end

function canreachmonster(location)
    return CanReach(location) == AccessibilityLevel.Normal
end

function jobcount()
    local count = 0
    if Has("squire") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("knight") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("archer") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("monk") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("thief") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("lancer") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("geomancer") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("samurai") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("ninja") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("dancer") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("chemist") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("priest") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("wizard") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("oracle") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("timemage") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("mediator") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("summoner") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("calculator") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("bard") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("mime") == AccessibilityLevel.Normal then
        count = count + 1
    end
	return count
end

function checkshoplevel(count)
    return Has("progressiveshoplevel", 0, tonumber(count))
end

function checkpoachshoplevel(count)
    return Has("progressiveshoplevel", count, count)
end

function checkjobcount(count)
    if jobcount() >= count then
	    return AccessibilityLevel.Normal
	end
    return AccessibilityLevel.SequenceBreak
end

easy_battle_levels = {0, 1, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 14, 14}
normal_battle_levels = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}
difficult_battle_levels = {0, 1, 1, 2, 3, 4, 5, 5, 6, 6, 7, 8, 9, 10, 11}
extreme_battle_levels = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

easy_job_battle_levels = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
normal_job_battle_levels = {1, 1, 2, 3, 3, 4, 4, 5, 6, 7, 7, 8, 9, 10, 10}
difficult_job_battle_levels = {1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7}
extreme_job_battle_levels = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

poach_battle_levels = {0, nil, 2, nil, nil, 5, nil, nil, 8, 8}

easy_poach_job_battle_levels = {0, nil, 2, nil, nil, 5, nil, nil, 8, 8, 10, nil, 12, nil, 14}
normal_poach_job_battle_levels = {0, nil, 2, nil, nil, 4, nil, nil, 5, 5, 7, nil, 8, nil, 10}
difficult_poach_job_battle_levels = {0, nil, 2, nil, nil, 3, nil, nil, 4, 4, 5, nil, 6, nil, 7}
extreme_poach_job_battle_levels = {0, nil, 1, nil, nil, 1, nil, nil, 1, 1, 1, nil, 1, nil, 1}

function getdifficulty()
	return Tracker:FindObjectForCode("easydifficulty").CurrentStage
end

function checkbattlelevel(level)
    shop_battle_levels = {}
	job_battle_levels = {}
	if getdifficulty() == 0 then
	    shop_battle_levels = easy_battle_levels
		job_battle_levels = easy_job_battle_levels
	end
	if getdifficulty() == 1 then
	    shop_battle_levels = normal_battle_levels
		job_battle_levels = normal_job_battle_levels
	end
	if getdifficulty() == 2 then
	    shop_battle_levels = difficult_battle_levels
		job_battle_levels = difficult_job_battle_levels
	end
	if getdifficulty() == 3 then
	    shop_battle_levels = extreme_battle_levels
		job_battle_levels = extreme_job_battle_levels
	end
	shop_accessibility = checkshoplevel(shop_battle_levels[level + 1])
	job_accessibility = checkjobcount(job_battle_levels[level + 1])
	if shop_accessibility == AccessibilityLevel.Normal then
	    return job_accessibility
	end
	return shop_accessibility
end

function checkpoachbattlelevel(level)
    poach_shop_battle_levels = poach_battle_levels
	poach_job_battle_levels = {}
	if getdifficulty() == 0 then
		poach_job_battle_levels = easy_poach_job_battle_levels
	end
	if getdifficulty() == 1 then
		poach_job_battle_levels = normal_poach_job_battle_levels
	end
	if getdifficulty() == 2 then
		poach_job_battle_levels = difficult_poach_job_battle_levels
	end
	if getdifficulty() == 3 then
		poach_job_battle_levels = extreme_poach_job_battle_levels
	end
	if tonumber(level) < 10 then
		shop_accessibility = checkpoachshoplevel(poach_shop_battle_levels[level + 1])
	else
		shop_accessibility = AccessibilityLevel.SequenceBreak
	end
	job_accessibility = checkjobcount(poach_job_battle_levels[level + 1])
	if shop_accessibility == AccessibilityLevel.Normal then
	    return job_accessibility
	end
	return shop_accessibility
end

function checkrarebattlelevel()
    return checkpoachbattlelevel(8)
end

function stonecount()
    local count = 0
    if Has("aries") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("taurus") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("gemini") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("cancer") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("leo") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("virgo") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("libra") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("scorpio") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("sagittarius") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("capricorn") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("aquarius") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("pisces") == AccessibilityLevel.Normal then
        count = count + 1
    end
    if Has("serpentarius") == AccessibilityLevel.Normal then
        count = count + 1
	end
	return count
end

function checkstonecount()
    return stonecount() >= Tracker:ProviderCountForCode('requiredstones')
end

region_to_item_mapping = {
	Gariland="@Gariland",
	Igros="@Igros",
	Mandalia="@Mandalia",
	Sweegy="@Sweegy",
	Dorter="@Dorter",
	Lenalia="@Lenalia",
	Zeakden="@Zeakden",
	
	Grog="@Grog",
	Yardow="@Yardow",
	Yuguo="@Yuguo",
	Riovanes="@Riovanes",
	Fovoham="@Fovoham Plains",
	
	Araguay="@Araguay",
	Zirekile="@Zirekile",
	Zeklaus="@Zeklaus",
	Lesalia="@Lesalia City",
	Goland="@Goland",
	
	Zaland="@Zaland",
	Lionel="@Lionel Castle",
	Zigolis="@Zigolis",
	Golgorand="@Golgorand",
	Warjilis="@Warjilis",
	
	Finath="@Finath",
	Zeltennia="@Zeltennia City",
	Nelveska="@Nelveska",
	Zarghidas="@Zarghidas",
	Germinas="@Germinas",
	Doguola="@Doguola",
	
	Bethla="@Bethla",
	Bed="@Bed",
	Dolbodar="@Dolbodar",
	Limberry="@Limberry Castle",
	Poeskas="@Poeskas",
	
	Murond="@Murond Temple",
	Orbonne="@Orbonne",
	Goug="@Goug"
}

local ThievesFort = "Thieves' Fort"
local BerveniaVolcano = "Bervenia Volcano"
local BariausHill = "Bariaus Hill"
local BariausValley = "Bariaus Valley"
local BerveniaCity = "Bervenia City"
local DeepDungeon = "Deep Dungeon"
local MurondDeathCity = "Murond Death City"

region_to_item_mapping[ThievesFort] = "@Thieves' Fort"
region_to_item_mapping[BerveniaVolcano] = "@Bervenia Volcano"
region_to_item_mapping[BariausHill] = "@Bariaus Hill"
region_to_item_mapping[BariausValley] = "@Bariaus Valley"
region_to_item_mapping[BerveniaCity] = "@Bervenia City"
region_to_item_mapping[DeepDungeon] = "@Deep Dungeon"
region_to_item_mapping[MurondDeathCity] = "@Murond Death City"

function check_poach_logic(monster_name)
	local total_region_access = AccessibilityLevel.None
	for entry_index, entry in pairs(POACH_DB[monster_name]) do
		for field, value in pairs(entry) do
			local region_access = nil
			if field == "Regions" then
				for index, region_name in pairs(value) do
					if region_to_item_mapping[region_name] ~= nil then
						local new_region_access = Tracker:FindObjectForCode(region_to_item_mapping[region_name]).AccessibilityLevel
						if region_access == nil then
							region_access = new_region_access
						else
							region_access = math.min(region_access, new_region_access)
						end
					end
				end
				local new_region_access = AccessibilityLevel.None
				if entry["Story"] == true then
					new_region_access = checkbattlelevel(entry["BattleLevel"])
				else
					new_region_access = checkpoachbattlelevel(entry["BattleLevel"])
				end
				region_access = math.min(region_access, new_region_access)
				total_region_access = math.max(total_region_access, region_access)
			end
		end
	end
	return total_region_access
end

function check_poach_visibility(monster_name)
	if EXCLUDED_MONSTER_NAMES[monster_name] == nil then
		return true
	end
	return false
end

function check_four_jump_jobs()
	if Has("monk") == AccessibilityLevel.Normal then
		return true
	end
	if Has("thief") == AccessibilityLevel.Normal then
		return true
	end
	if Has("lancer") == AccessibilityLevel.Normal then
		return true
	end
	if Has("ninja") == AccessibilityLevel.Normal then
		return true
	end
	return false
end

function check_spike_shoes()
	return checkshoplevel(4) == AccessibilityLevel.Normal
end

function check_mfi_not_default()
	return Has("mfilogicchemistinnate") == AccessibilityLevel.Normal or Has("mfilogicblueteaminnate") == AccessibilityLevel.Normal
end

function check_mfi_not_default()
	return Has("mfilogicblueteaminnate") == AccessibilityLevel.Normal
end

function check_archer()
	return Has("archer") == AccessibilityLevel.Normal
end

function check_movement_ability_jobs()
	if Has("timemage") == AccessibilityLevel.Normal then
		return true
	end
	if Has("lancer") == AccessibilityLevel.Normal then
		return true
	end
	if Has("bard") == AccessibilityLevel.Normal then
		return true
	end
	if Has("dancer") == AccessibilityLevel.Normal then
		return true
	end
	return false
end

function check_large_monsters()
	if check_poach_logic("Morbol") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Ochu") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Great Morbol") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Behemoth") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("King Behemoth") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Dark Behemoth") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Dragon") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Blue Dragon") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Red Dragon") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Hyudra") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Hydra") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Tiamat") == AccessibilityLevel.Normal then
		return true
	end
	return false
end

function check_flying_ability_monsters()
	if check_poach_logic("Yellow Chocobo") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Black Chocobo") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Red Chocobo") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Red Panther") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Cuar") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Vampire") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Ghoul") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Gust") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Revnant") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Flotiball") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Ahriman") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Plague") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Steel Hawk") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Juravis") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Cocatoris") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Hyudra") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Hydra") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Tiamat") == AccessibilityLevel.Normal then
		return true
	end
	return false
end

function check_lava_monsters()
	if check_poach_logic("Ghoul") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Gust") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Revnant") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Bomb") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Grenade") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Explosive") == AccessibilityLevel.Normal then
		return true
	end
	return false
end

function check_chocobo()
	if check_poach_logic("Yellow Chocobo") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Black Chocobo") == AccessibilityLevel.Normal then
		return true
	end
	if check_poach_logic("Red Chocobo") == AccessibilityLevel.Normal then
		return true
	end
	return false
end

function filter_mfi_not_default(rule)
	return rule() and check_mfi_not_default()
end

function filter_mfi_innate(rule)
	return rule() and check_mfi_innate()
end

function filter_mfi_not_innate(rule)
	return rule() and ~check_mfi_innate()
end

function filter_monster_rule(result)
	return result and Has("mediator") == AccessibilityLevel.Normal
end

function four_jump_rule()
	local spike_shoes = check_spike_shoes()
	local four_jump_jobs = check_four_jump_jobs()
	local archer = filter_mfi_not_default(check_archer)
	local movement_ability = filter_mfi_not_default(check_movement_ability_jobs)
	local flying_monster = filter_monster_rule(check_flying_ability_monsters)
	movement_ability = movement_ability or flying_monster
	return spike_shoes or four_jump_jobs or archer or movement_ability
end

function four_jump_plus_one_rule()
	return check_four_jump_jobs() and (check_spike_shoes() or filter_mfi_innate(check_archer))
end

function three_jump_plus_two_rule()
	return check_spike_shoes() and filter_mfi_not_default(check_archer)
end

function five_jump_rule()
	local movement_ability = filter_mfi_not_default(check_movement_ability_jobs)
	local flying_monster = filter_monster_rule(check_flying_ability_monsters)
	movement_ability = movement_ability or flying_monster
	return three_jump_plus_two_rule() or four_jump_plus_one_rule() or movement_ability
end

function lava_movement_rule()
	return Has("geomancer") == AccessibilityLevel.Normal or Has("timemage") == AccessibilityLevel.Normal
end

