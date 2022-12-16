-- Copyright © 2020-2022 Kektram

local globals <const> = {version = "1.4.0"}

local essentials <const> = require("Kek's Essentials")
local settings <const> = require("Kek's Settings")
local memoize <const> = require("Kek's Memoize")

local offsets <const> = essentials.const({
	["MAIN"] = 1853910,
	["OFFSET_PER_PLAYER"] = 862,
	["OFFSET_TO_INFO"] = 205
})

local stats <const> = essentials.const({
	["WALLET"] = 3,
	["RANK"] = 6,
	["CREW_TITLE"] = 7,
	["KD"] = 26,
	["KILLS"] = 28,
	["DEATHS"] = 29,
	["TOTALMONEY"] = 56,
	["FAVOURITE_WEAPON_HASH"] = 59,
	["TOTAL_RACES_WON"] = 15,
	["TOTAL_RACES_LOST"] = 16, 
	["TIMES_FINISH_RACE_TOP_3"] = 17, 
	["TIMES_FINISH_RACE_LAST"] = 18,
	["TIMES_RACE_BEST_LAP"] = 19,
	["TOTAL_DEATHMATCH_WON"] = 20,
	["TOTAL_DEATHMATCH_LOST"] = 21, 
	["TOTAL_TDEATHMATCH_WON"] = 22, 
	["TOTAL_TDEATHMATCH_LOST"] = 23,
	["TIMES_FINISH_DM_TOP_3"] = 30, 
	["TIMES_FINISH_DM_LAST"] = 31,
	["DARTS_TOTAL_WINS"] = 32, 
	["DARTS_TOTAL_MATCHES"] = 33,
	["ARMWRESTLING_TOTAL_WINS"] = 34, 
	["ARMWRESTLING_TOTAL_MATCH"] = 35,
	["TENNIS_MATCHES_WON"] = 36, 
	["TENNIS_MATCHES_LOST"] = 37,
	["BJ_WINS"] = 38,
	["BJ_LOST"] = 39,
	["GOLF_WINS"] = 40,
	["GOLF_LOSSES"] = 41,
	["SHOOTINGRANGE_WINS"] = 42, 
	["SHOOTINGRANGE_LOSSES"] = 43,
	["Unknown_stat"] = 44,
	["HORDEWINS"] = 47,
	["CRHORDE"] = 48,
	["MCMWIN"] = 45,
	["CRMISSION"] = 46,
	["MISSIONS_CREATED"] = 50, 
	["DROPOUTRATE"] = 27,
	["MOST_FAVORITE_STATION"] = 53,
	["CAN_SPECTATE"] = 52,
	-- Freemode script doesn't explicitly define these, but it seems highly likely they are correct.
	["IS_BAD_SPORT"] = 51,
	["GLOBALXP"] = 5
	-- Freemode script doesn't explicitly define these, but it seems highly likely they are correct.
})

function globals.get_player_info_offset(pid, info_offset)
	return offsets.MAIN + (1 + (pid * offsets.OFFSET_PER_PLAYER)) + offsets.OFFSET_TO_INFO + info_offset
end
function globals.get_player_info_i(pid, info_offset)
	return script.get_global_i(globals.get_player_info_offset(pid, info_offset))
end
function globals.get_player_info_f(pid, info_offset)
	return script.get_global_f(globals.get_player_info_offset(pid, info_offset))
end

function globals.get_player_rank(pid)
	return globals.get_player_info_i(pid, stats.RANK)
end

function globals.get_player_money(pid)
	return globals.get_player_info_i(pid, stats.TOTALMONEY)
end

function globals.get_player_wallet(pid)
	return globals.get_player_info_i(pid, stats.WALLET)
end

function globals.get_player_bank(pid)
	return globals.get_player_money(pid) - globals.get_player_wallet(pid)
end

function globals.get_player_kd(pid)
	return globals.get_player_info_f(pid, stats.KD)
end

function globals.get_player_kills(pid)
	return globals.get_player_info_i(pid, stats.KILLS)
end

function globals.get_player_deaths(pid)
	return globals.get_player_info_i(pid, stats.DEATHS)
end

globals.global_indices = essentials.const({
	time = 					2793044 + 4654, 	-- NETWORK::GET_NETWORK_TIME()

	transition = 			1574993, -- Is 66 if fully loaded into session

	current = 				1923597 + 9, 		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))

	previous = 				1923597 + 10		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))
})

globals.player_global_indices = essentials.const({
	personal_vehicle = 				{offset = 2672505 + 1 + 187, 		pid_multiplier = 1},

	generic = 						{offset = 1894573 + 1 + 510, 		pid_multiplier = 608}, 		-- Equivalent to global(1921036 + 9) if pid is script host

	organization_associate_hash = 	{offset = 1894573 + 1 + 10 + 2, 	pid_multiplier = 608},		-- Seems to be 1639791091 + (unknown * 3)

	organization_id = 				{offset = 1894573 + 1 + 10, 		pid_multiplier = 608},		-- Is -1 if no organization

	otr_status = 					{offset = 2657589 + 1 + 210, 		pid_multiplier = 466}, 		-- Returns 1 if player is otr

	bounty_status = 				{offset = 1835504 + 1 + 4,			pid_multiplier = 3}, 		-- Returns 1 if player has bounty.

	is_player_typing = 				{offset = 1653913 + 2 + 241 + 136 --[[+ ((16 // 32) * 33)--]], pid_multiplier = 1} -- < this > & 1 << 16 ~= 0 if they're typing.
})

local script_event_hashes <const> = essentials.const({
	["Force player into vehicle"] = 		879177392, -- Par 4 - 35 are network hashes. par 3 is how many of those hashes to check. par 2 & 36 are bools.

	["Infinite while loop crash"] = 		-904555865,

	["Disown personal vehicle"] = 			49863291,

	["Vehicle EMP"] =						267489225,

	["Destroy personal vehicle"] = 			-513394492,

	["Kick out of vehicle"] = 				-852914485,

	["Give OTR or ghost organization"] =	-162943635,

	["Block passive"] = 					1920583171,

	["Send to Perico island"] = 			-910497748,

	["Apartment invite"] = 					-168599209,

	["Transaction error"] = 				-492741651,

	["CEO money"] = 						245065909,

	["Bounty"] = 							1370461707,

	["Generic event"] = 					113023613,

	["Notifications"] = 					548471420
})

globals.GENERIC_ARG_HASHES = essentials.const({ -- Includes all cases (switch statement) with something interesting
	clear_wanted = 615048532,
	move_camera = gameplay.get_hash_key("pats_horse_right") -- Removes godmode for a frame
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES = essentials.const({
	cash_added_bank = -1032040118,
	cash_stolen = -28878294,
	cash_removed = -1197151915,
	vehicle_kill_list_will_explode_in_x = 925621380
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES_RAW = essentials.const({ -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES
	-421898791,
	--1111057133,
	--1717006433,
	-- -1632266006,
	--1467941802,
	2017408112,
	79966559,
	-1764855587,
	-1316587068,
	1724500641,
	1497062168,
	1130071994,
	-2004889829,
	1559364338,
	-133974622,
	-406997534,
	686299542,
	-1032040118,
	-28878294,
	-1197151915,
	1480097843,
	-344016925,
	-374020833,
	-1178166860,
	572419745,
	433001113,
	729651888,
	651491550,
	53100515,
	-1495761793,
	1856797497,
	-1131682040,
	-1947106202,
	908559907,
	1234308928,
	-- -1824270533, Can cause player to get kicked
	1940316911,
	-1265189073,
	-1791264630,
	-1875928609,
	-1379183386,
	-616828629,
	959808021,
	1510188247,
	134169308,
	928249011,
	-851799902,
	1358494362,
	390906319,
	373093524,
	-1433716817,
	1571819430,
	415967752,
	925621380,
	-1344240446,
	-1115664940,
	119705347,
	745744060,
	625977929,
	-1082301749,
	414496857,
	1769325206,
	2045065996,
	-1446607779,
	1757484042,
	-763952994,
	623198296,
	1751618454,
	2074119471,
	-2097031143,
	-432820279,
	1026229251,
	-812302864,
	1236709979,
	-1649806549,
	1770436139,
	2090123118,
	147071210,
	-677967046,
	-16645639,
	-1477239291,
	1322243116,
	-949779244,
	722107191,
	569076623,
	-360151775,
	-726825496,
	-388488748,
	1226355894,
	-1234628868,
	-841117686,
	-1446766503,
	1531912042,
	38375853,
	533603904,
	1550688975,
	288496205,
	125882680,
	1553561736,
	1504396077,
	-1387992064,
	-1610627141,
	264759403,
	229228123,
	-1838317397,
	1820622972,
	262753545,
	-162075004,
	218989605,
	-1075366243,
	-10456022,
	1882629798,
	-1891794136,
	704297910,
	-743620634,
	290596041,
	1239547822,
	111871813,
	-1162167396,
	1938205474,
	174278207,
	1704939268,
	-1434267229,
	654956208,
	-1884420507,
	-366858328,
	1587558688,
	-542998813,
	2124591694,
	496463391,
	-461983386,
	945692125,
	-2047135236,
	-1141159588,
	-1722940144,
	2095657940,
	-214249287,
	-1596713841,
	-507553632,
	-1346808195,
	532932991,
	-1218457646,
	1821738714,
	-832016399,
	-1903870031,
	-1288982703,
	1468751170,
	1891062979,
	1932093787,
	-974704311,
	-1606049106,
	631934828,
	-1719710261,
	-1786829919,
	-888530285,
	-1086641017,
	-319775187,
	-308331670,
	-1347981670,
	-2055268782,
	-586004863,
	1760415236,
	-503120183,
	1598143475,
	-1849487674,
	-599783702,
	-413897054,
	791844146,
	1446634808,
	-1388743393,
	1342908091,
	1991583693,
	-1308083776,
	-670839658,
	-833603091,
	-1339853976,
	-2006673237,
	-1969780944,
	1595722774,
	1378566556,
	1123367201,
	1827723759,
	1182963148,
	204738037,
	-2027497059,
	-1651984795,
	2016713093,
	-1356793128,
	413033397,
	crash_notification = 804923209
})

function globals.get_script_event_hash(name)
	essentials.assert(script_event_hashes[name], "Failed to get hash from script name:", name)
	return script_event_hashes[name]
end

function globals.get_global(global_name)
	essentials.assert(globals.global_indices[global_name], "Invalid global name.", global_name)
	return script.get_global_i(globals.global_indices[global_name])
end

function globals.force_player_into_vehicle(pid, timeout) -- Creds to RulyPancake the 5th#1345 for logging this from stand menu
	local time <const> = utils.time_ms() + 15000
	while player.is_player_dead(pid) and player.is_player_valid(pid) and time > utils.time_ms() do
		system.yield(0)
	end
	local was_player_already_in_god <const> = player.is_player_god(pid)
	if not player.is_player_dead(pid) then
		globals.send_script_event(pid, "Force player into vehicle", nil, 1, 1, network.network_hash_from_player(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
		local time <const> = utils.time_ms() + (timeout or 15000)
		system.yield(was_player_already_in_god and 8000 or 6000)
		while not player.is_player_dead(pid) 
		and player.is_player_valid(pid)
		and ((not was_player_already_in_god and player.is_player_god(pid)) or not essentials.is_in_vehicle(pid))
		and time > utils.time_ms() do
			system.yield(0)
		end
	end
end

function globals.get_player_global(global_name, pid, get_index)
	essentials.assert(globals.player_global_indices[global_name], "Invalid player global name.", global_name)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.", global_name, pid) -- Invalid pids can cause access violation crash
	local pid_offset <const> = pid * globals.player_global_indices[global_name].pid_multiplier
	if get_index == true then
		return globals.player_global_indices[global_name].offset + pid_offset
	else
		return script.get_global_i(globals.player_global_indices[global_name].offset + pid_offset)
	end
end

globals.script_event_tracker = setmetatable({count = 0, id = 0}, {
	__index = {},
	__newindex = function(Table, index, value)
		if value ~= nil then
			Table.count = Table.count + 1
			Table.id = Table.id + 1
			getmetatable(Table).__index[Table.id] = value
		else
			getmetatable(Table).__index[index] = nil
			Table.count = Table.count - 1
		end
	end,
	__pairs = function(Table)
		return next, getmetatable(Table).__index
	end
})

do
	local empty_table <const> = essentials.const({})
	function globals.send_script_event(pid_or_bits, script_hash_name, properties, ...)
		-- Priority: Some script events like emp will not work if delayed too much. 12 se in one frame is far below the the dangerous threshold of 20.
		-- Can't yield: Like priority events, this can send if current count is under 12. This allows for most events of this kind to send immediately.
		-- You need to specify if it's bits by passing send_to_multiple_people to true in the properties table
		properties = properties or empty_table
		if (properties.send_to_multiple_people or player.is_player_valid(pid_or_bits))
		and (not properties.friend_condition or essentials.is_not_friend(pid_or_bits)) then
			repeat
				for i, time in pairs(globals.script_event_tracker) do
					if time < utils.time_ms() then
						globals.script_event_tracker[i] = nil
					end
				end
				if not properties.cant_yield 
				and (
					globals.script_event_tracker.count >= 10 
					and (not properties.priority or globals.script_event_tracker.count < 12)
				) then
					system.yield(0)
				end
			until properties.cant_yield 
			or (globals.script_event_tracker.count < 10 
			or (properties.priority and globals.script_event_tracker.count < 12))

			if (properties.send_to_multiple_people or player.is_player_valid(pid_or_bits)) and globals.script_event_tracker.count < 12 then
				globals.script_event_tracker[true] = utils.time_ms() + math.ceil(2000 * gameplay.get_frame_time())
				for i = 1, select("#", ...) do -- Passing floats to script events doesn't work like you'd think.
					essentials.assert(math.type(select(i, ...)) == "integer", "Tried to pass a non-integer value as arguments to script event.", script_hash_name, player.player_id(), ...)
				end
				script.trigger_script_event_2(
					properties.send_to_multiple_people and pid_or_bits or 1 << pid_or_bits, 
					globals.get_script_event_hash(script_hash_name), 
					player.player_id(), ...
				)
				return true
			end
		elseif not properties.cant_yield then
			system.yield(0)
		end
		return false
	end
end

function globals.is_fully_transitioned_into_session()
	return globals.get_global("transition") == 66 or player.is_player_control_on(player.player_id()) -- For some people, the global doesn't return 66 while in singleplayer.
end

function globals.set_bounty(...)
	local script_target <const>,
	friend_relevant <const>,
	anonymous,
	amount = ...
	if player.player_count() > 0
	and globals.get_player_global("bounty_status", script_target) == 0
	and player.is_player_valid(script_target) 
	and player.is_player_playing(script_target) 
	and (not friend_relevant or essentials.is_not_friend(script_target)) then
		amount = amount or math.tointeger(settings.in_use["Bounty amount"]) or 10000
		local bits = 0
		for pid in essentials.players(true) do
			bits = bits | 1 << pid
		end
		globals.send_script_event(
			bits, 
			"Bounty",
			{send_to_multiple_people = true},
			script_target, 
			3, 
			amount >= 0 and amount or 10000, 
			1,
			anonymous and 1 or 0, 
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
			globals.get_global("current"), globals.get_global("previous")
			
		)
	end
end

function globals.disable_vehicle(...)
	local pid <const>, friend_condition <const> = ...
	if memoize.get_player_coords(pid).z == -50 or player.is_player_in_any_vehicle(pid) then
		globals.send_script_event(pid, "Destroy personal vehicle", {friend_condition = friend_condition}, pid)
		globals.send_script_event(pid, "Kick out of vehicle", {friend_condition = friend_condition}, 0, 0, 0, 0, 1, pid, math.min(2147483647, gameplay.get_frame_count()))
	end
end

function globals.script_event_crash(...)
	local pid <const> = ...
	if player.is_player_valid(pid) and player.player_id() ~= pid then
		globals.send_script_event(pid, "Force player into vehicle", nil, 1, math.random(2000000000, 2147483647)) -- Crash due to 2 billion+ iterations in a for loop
		globals.send_script_event(pid, "Infinite while loop crash", nil, 0, math.random(2000000000, 2147483647)) -- Crash due to 2 billion+ iterations in a for loop
	end
end

function globals.script_event_crash_2(...) -- Has been unstable in the past, might crash your game. Yet to crash myself with it.
	local pid <const> = ...
	for i = 1, 25 do
		local rand_pid <const> = essentials.get_random_player_except({[player.player_id()] = true})
		script.trigger_script_event_2(1 << pid, globals.get_script_event_hash("Notifications"), 
			player.player_id(), 
			globals.NOTIFICATION_HASHES_RAW.crash_notification, 
			math.random(-2147483647, 2147483647),
			1, 0, 0, 0, 0, 0, pid, 
			player.player_id(), 
			rand_pid, 
			essentials.get_random_player_except({[player.player_id()] = true, [rand_pid] = true})
		)
	end
end

return globals