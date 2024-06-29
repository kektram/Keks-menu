-- Copyright © 2020-2022 Kektram

local globals <const> = {version = "1.4.5"}

local essentials <const> = require("Kek's Essentials")
local settings <const> = require("Kek's Settings")
local memoize <const> = require("Kek's Memoize")

local offsets <const> = essentials.const({
	["MAIN"] = 1845281,
	["OFFSET_PER_PLAYER"] = 883,
	["OFFSET_TO_INFO"] = 206
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

function globals.all_stats_to_clipboard(pid)
	local str <const> = {}
	for name, offset in pairs(stats) do
		str[#str + 1] = name..": "..script.get_global_i(globals.get_player_info_offset(pid, offset))
	end
	utils.to_clipboard(table.concat(str, "\n"))
end

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
	time = 					2738934 + 4676, 	-- NETWORK::GET_NETWORK_TIME()

	transition = 			1575011, -- Is 66 if fully loaded into session

	current = 				1916617 + 9, 		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))

	previous = 				1916617 + 10		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))
})

globals.player_global_indices = essentials.const({
	personal_vehicle = 				{offset = 2672855 + 1 + 198, 		pid_multiplier = 1},

	generic = 						{offset = 1887305 + 1 + 512, 		pid_multiplier = 610}, 		-- Equivalent to global(1921036 + 9) if pid is script host

	organization_associate_hash = 	{offset = 1887305 + 1 + 10 + 2, 	pid_multiplier = 610},		-- Seems to be 1639791091 + (unknown * 3)

	organization_id = 				{offset = 1887305 + 1 + 10, 		pid_multiplier = 610},		-- Is -1 if no organization

	otr_status = 					{offset = 2657971 + 1 + 211, 		pid_multiplier = 465}, 		-- Returns 1 if player is otr

	bounty_status = 				{offset = 1835505 + 1 + 4,			pid_multiplier = 3}, 		-- Returns 1 if player has bounty.

	is_player_typing = 				{offset = 1668667 + 2 + 241 + 136 --[[+ ((16 // 32) * 33)--]], pid_multiplier = 1} -- < this > & 1 << 16 ~= 0 if they're typing.
})

local script_event_hashes <const> = essentials.const({
	["Disown personal vehicle"] = 			-1353750176,

	["Vehicle EMP"] =						1872545935,

	["Destroy personal vehicle"] = 			109434679,

	["Kick out of vehicle"] = 				-503325966,

	["Give OTR or ghost organization"] =	57493695,

	["Block passive"] = 					949664396,

	["Apartment invite"] = 					-1321657966,

	["CEO money"] = 						-337848027,

	["Bounty"] = 							1517551547,

	["Generic event"] = 					800157557,

	["Notifications"] = 					-642704387,

	["Bail kick"] = 						-901348601
})

globals.GENERIC_ARG_HASHES = essentials.const({ -- Includes all cases (switch statement) with something interesting
	clear_wanted = -914973885,
	move_camera = gameplay.get_hash_key("pats_horse_right") -- Removes godmode for a frame
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES = essentials.const({
	cash_added_bank = 94410750,
	cash_stolen = -295926414,
	cash_removed = -242911964,
	vehicle_kill_list_will_explode_in_x = 1206358365
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES_RAW = essentials.const({
	1964206081,
	-- -124923592,
	-- 1681501530,
	-- 1334380224,
	-- -153984855,
	1685756725,
	1920532265,
	-2088366475,
	-1362893813,
	-2045676423,
	270407371,
	-185190021,
	2092359122,
	-1279215969,
	-1117941225,
	-267741801,
	1141680977,
	94410750,
	-295926414,
	-242911964,
	-1374270823,
	2087589787,
	1498778633,
	-2023231970,
	-46427861,
	-1707786097,
	-537443435,
	1657385274,
	654590235,
	1269083963,
	2132210459,
	-631514137,
	67449837,
	1992801007,
	2115283476,
	-- -274141694, Can cause player to get kicked
	-1369501940,
	700755157,
	-1110346671,
	-1147871280,
	1286242155,
	566326167,
	1562851728,
	1698144520,
	175357111,
	-1178382538,
	519603574,
	25909718,
	-1569748362,
	-537988351,
	-52851778,
	-589496483,
	-1297578857,
	1206358365,
	1267106989,
	-659682088,
	211288551,
	-506771808,
	-1528989704,
	162649603,
	1549986304,
	1156367985,
	1745717132,
	-1774258313,
	-123622067,
	crash_notification = 782258655,
	595566634,
	333252100,
	-915107409,
	-185531943,
	-1397371731,
	-2067421797,
	2122635939,
	1294354544,
	2076814537,
	1653008132,
	-1957780196,
	-424891290,
	1919354072,
	-1624215847,
	-1862640534,
	-953119221,
	1537935777,
	726383212,
	1892011737,
	-908435400,
	253112446,
	-804372901,
	-1269736344,
	-1496102984,
	1242824391,
	-1655353383,
	1481401191,
	-232274478,
	-1190864176,
	-484919611,
	1851947159,
	-364374038,
	387266354,
	1873087566,
	-1825342546,
	357634101,
	-1532850163,
	-1027120231,
	-1349748149,
	-263823283,
	-220827101,
	244166737,
	-2145992078,
	1478734661,
	-469990501,
	-336031718,
	141644746,
	-512168382,
	108239599,
	2002419216,
	1328709869,
	89161948,
	-136196471,
	438579306,
	-266556338,
	-62711246,
	992057563,
	-274941786,
	-920137029,
	-1224230215,
	-30226546,
	-2070880806,
	1999203482,
	660101052,
	-1365920592,
	87330564,
	-1854450559,
	508279757,
	1771687713,
	-1791283050,
	-2122605143,
	692289645,
	633054128,
	-729642880,
	-555185917,
	-1079941038,
	-578453253,
	1590597533,
	-1209401092,
	1840946429,
	2073500011,
	-1496350145,
	1119717573,
	-798284174,
	688031806,
	-1853142904,
	-180954442,
	1063231237,
	611829658,
	-416870648,
	466505354,
	-154142402,
	509575003,
	-994541138,
	-466069025,
	1879493586,
	-246319824,
	514341487,
	1601625667,
	-1995714668,
	-196790853,
	-657909624,
	65771285,
	-1612031558,
	-749778730,
	1511668108,
	1588930412,
	-721023931,
	1102524542,
	-1871052553,
	110435988,
	49800390,
	1603709302,
	1010866129,
	-1294527261,
	-1235125723,
	1566953145,
	-753304341,
	-376947579,
	-264328576,
	-1135093486,
	-1233120647,
	677413145,
	-690370280
})

function globals.get_script_event_hash(name)
	essentials.assert(script_event_hashes[name], "Failed to get hash from script name:", name)
	return script_event_hashes[name]
end

function globals.get_global(global_name)
	essentials.assert(globals.global_indices[global_name], "Invalid global name.", global_name)
	return script.get_global_i(globals.global_indices[global_name])
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
					player.player_id(), 0, ...
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

function globals.kick_player(pid)
	essentials.assert(pid ~= player.player_id(), "Tried to kick yourself.")
	if network.network_is_host() then
		network.network_session_kick_player(pid)
	else
		-- globals.send_script_event(pid, "Bail kick", nil, globals.get_player_global("generic", pid))
		network.force_remove_player(pid)
	end
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

function globals.script_event_crash(...) -- Has been unstable in the past, might crash your game. Yet to crash myself with it.
	local pid <const> = ...
	for i = 1, 25 do
		local rand_pid <const> = essentials.get_random_player_except({[player.player_id()] = true})
		script.trigger_script_event_2(1 << pid, globals.get_script_event_hash("Notifications"), 
			player.player_id(), 
			0,
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