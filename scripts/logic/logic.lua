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
    return Has("progressiveshoplevel", 0, count)
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

easy_poach_job_battle_levels = {0, nil, 2, nil, nil, 5, nil, nil, 8, 8}
normal_poach_job_battle_levels = {0, nil, 2, nil, nil, 4, nil, nil, 5, 5}
difficult_poach_job_battle_levels = {0, nil, 2, nil, nil, 3, nil, nil, 4, 4}
extreme_poach_job_battle_levels = {0, nil, 1, nil, nil, 1, nil, nil, 1, 1}

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
	shop_accessibility = checkpoachshoplevel(poach_shop_battle_levels[level + 1])
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
