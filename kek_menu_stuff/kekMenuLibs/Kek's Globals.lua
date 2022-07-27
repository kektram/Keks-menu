-- Copyright © 2020-2022 Kektram

local globals <const> = {version = "1.3.8"}

local essentials <const> = require("Kek's Essentials")
local enums <const> = require("Kek's Enums")
local settings <const> = require("Kek's Settings")
local memoize <const> = require("Kek's Memoize")

local offsets <const> = essentials.const({
	["MAIN"] = 1853348,
	["OFFSET_PER_PLAYER"] = 834,
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
	time = 					2815059 + 4624, 	-- NETWORK::GET_NETWORK_TIME()

	transition = 			1574991, -- Is 66 if fully loaded into session

	current = 				1920255 + 9, 		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))

	previous = 				1920255 + 10		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))
})

globals.player_global_indices = essentials.const({
	personal_vehicle = 				{offset = 2703735 + 1 + 173, 		pid_multiplier = 1},

	generic = 						{offset = 1892703 + 1 + 510, 		pid_multiplier = 599}, 		-- Equivalent to global(1921036 + 9) if pid is script host

	organization_associate_hash = 	{offset = 1892703 + 1 + 10 + 2, 	pid_multiplier = 599},		-- Seems to be 1639791091 + (unknown * 3)

	organization_id = 				{offset = 1892703 + 1 + 10, 		pid_multiplier = 599},

	otr_status = 					{offset = 2689235 + 1 + 208, 		pid_multiplier = 453}, 		-- Returns 1 if player is otr

	bounty_status = 				{offset = 1835502 + 1 + 4,			pid_multiplier = 3}, 		-- Returns 1 if player has bounty.

	is_player_typing = 				{offset = 1648034 + 2 + 241 + 136 --[[+ ((16 // 32) * 33)--]], pid_multiplier = 1} -- < this > & 1 << 16 ~= 0 if they're typing.
})

--[[ Vaulted script events I won't actively update
** FREEMODE used was obtained 27-04-2022 [GTA V build 2628 (GTA Online 1.60)]
	995853474, -- Collectibles [10 collectible unlocks, 7.5k cash each]
		f_1 == player.player_id(), 
		f_2 == 1, -- What type of collectible to give
		f_3 == 0-9, -- What stat hash to get from index 0 to 9; stat ids: 30241 - 30250
		f_4 == 1, -- bool 
		f_5 == 0, -- bool
		f_6 == 1 -- bool

--]]

local script_event_hashes <const> = essentials.const({
	["Force player into vehicle"] = 		-555356783, -- Par 4 - 35 are network hashes. par 3 is how many of those hashes to check. par 2 & 36 are bools.

	["Infinite while loop crash"] = 		526822748,

	["Disown personal vehicle"] = 			-306558546,

	["Vehicle EMP"] =						-1427892428,

	["Destroy personal vehicle"] = 			-2126830022,

	["Kick out of vehicle"] = 				-714268990,

	["Give OTR or ghost organization"] =	-1973627888,

	["Block passive"] = 					65268844,

	["Send to Perico island"] = 			1361475530,

	["Apartment invite"] = 					-1390976345,

	["CEO ban"] = 							1240068495,

	["Dismiss or terminate from CEO"] = 	-1425016400,

	["Transaction error"] = 				-768108950,

	["CEO money"] = 						547083265,

	["Bounty"] = 							1915499503,

	["Generic event"] = 					-1388926377,

	["Notifications"] = 					-1529596656
})

globals.GENERIC_ARG_HASHES = essentials.const({ -- Includes all cases (switch statement) with something interesting
	clear_wanted = 125033661
	--[[ OUTDATED. FROM: [GTA V build 2628 (GTA Online 1.60)] 27-04-2022
		unk1 = -1107912593,
		unk2 = 441439430,
		cop_timer = -2117950499,
		crook_timer = -1428782697,
		tunable_smt = 537560473,
		hud_removeitem = -480053738,
		hud_removeitem_2 = -873921503,
		smt_todo_with_player_team = 156817356,
		looks_like_timer = 809872998,
		camera = 869796886
	--]]
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES = essentials.const({
	cash_added_bank = -849958015,
	cash_stolen = -1640162684,
	cash_removed = -290070531,
	vehicle_kill_list_will_explode_in_x = 948261434
}) -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES

globals.NOTIFICATION_HASHES_RAW = essentials.const({ -- THESE NEEDS TO GET UPDATED ON MAJOR GTA UPDATES
	-798666348,
	-- 2045988930,
	-- 1023106342,
	-- 687717091,
	-- -545984491,
	-1048629566,
	1181306847,
	1347513268,
	1862353529,
	1289157788,
	1165399431,
	-1739317812,
	-579901295,
	-1559779014,
	-1337074122,
	1837020641,
	-1158837686,
	-849958015,
	-1640162684,
	-290070531,
	1486755921,
	387297028,
	-631411114,
	191881921,
	647151840,
	131526974,
	-1643558145,
	1405242665,
	-1241621212,
	1236510126,
	-957912558,
	1895157572,
	1445830269,
	-282974408,
	-1526812039,
	-- -1223820331, Can cause player to get kicked
	1338180443,
	-762167709,
	-834923907,
	-1747140958,
	-208885833,
	990698863,
	1584592718,
	1884920006,
	613904624,
	-134157105,
	1359375186,
	624887500,
	-1110361554,
	1389707492,
	-1934096369,
	-1951068930,
	42043832,
	948261434,
	-1324280291,
	253422435,
	-29110861,
	-1825847691,
	1895117223,
	-1173679408,
	954790247,
	-1230145718,
	1570493520,
	1237679061,
	238216506,
	-- -547323955, Can cause player to get crashed
	-1978767900,
	51281702,
	-1435009097,
	-1448651733,
	3618049,
	922865935,
	1096157875,
	-1544466956,
	-977704342,
	-1423230718,
	-1022474524,
	-97742300,
	-1619346917,
	598067554,
	-1113992458,
	1031974379,
	-1482084718,
	1093368079,
	-1401188087,
	2016040430,
	1591843457,
	1123536029,
	-1774148053,
	-900992998,
	642905839,
	60196880,
	107890679,
	1331875651,
	-1346244703,
	-1774527360,
	1112123527,
	-1514817568,
	-1135881253,
	585200513,
	1559122458,
	1046868867,
	-126299893,
	652868691,
	-1903994744,
	-1955511189,
	1298149895,
	-581668973,
	1846859874,
	-1900627347,
	-167623065,
	-480184639,
	-293038417,
	284048987,
	996671670,
	460728128,
	1953804132,
	-338312328,
	1644144667,
	1663631674,
	-751505045,
	-97512675,
	659568732,
	1411579008,
	1958000582,
	2141857158,
	-38157870,
	-481169383,
	-544350095,
	670826302,
	-1766566591,
	-1553408327,
	-157526016,
	-1195445472,
	1270194308,
	653626137,
	-35892297,
	-1173993894,
	-686394896,
	1212517035,
	-1394652000,
	-1296682161,
	199776836,
	1036580915,
	-250941162,
	-2131157870,
	-230148856,
	806692428,
	-1619652234,
	227459735,
	-1637241198,
	-83571472,
	-1269535056,
	-765247904,
	-877646868,
	-455218537,
	-1111422293,
	-951694168,
	-1003961910,
	838576761,
	-1975643673,
	720553595,
	1535844061,
	-144028007,
	-1693023939,
	-1874451036,
	1789320243,
	-1863580758,
	-1248118654,
	584090642,
	-1914651041,
	-1571508379,
	621721745,
	-160157873,
	-888400040,
	224702245,
	1685857344,
	48937991,
	-1138299166,
	1394615985,
	1353526176,
	-1798575258,
	1285823202,
	2056072755,
	64135927,
	1218886043,
	-1903866482,
	560987145,
	1823970438
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
			-547323955, 
			math.random(-2147483647, 2147483647),
			1, 0, 0, 0, 0, 0, pid, 
			player.player_id(), 
			rand_pid, 
			essentials.get_random_player_except({[player.player_id()] = true, [rand_pid] = true})
		)
	end
end

return globals