-- Copyright © 2020-2022 Kektram, Sainan

local globals <const> = {version = "1.3.5"}

local essentials <const> = require("Kek's Essentials")
local enums <const> = require("Kek's Enums")
local settings <const> = require("Kek's settings")
local memoize <const> = require("Kek's Memoize")

local offsets <const> = essentials.const({
	["MAIN"] = 1853131,
	["OFFSET_PER_PLAYER"] = 888,
	["OFFSET_TO_INFO"] = 205
})

local stats <const> = essentials.const({ -- Thanks to Sainan for some of these stats
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

function globals.get_player_info_offset(pid, info_offset) -- By Sainan
	return offsets.MAIN + (1 + (pid * offsets.OFFSET_PER_PLAYER)) + offsets.OFFSET_TO_INFO + info_offset
end
function globals.get_player_info_i(pid, info_offset) -- By Sainan
	return script.get_global_i(globals.get_player_info_offset(pid, info_offset))
end
function globals.get_player_info_f(pid, info_offset) -- By Sainan
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
	time = 					2810701 + 4624, 	-- NETWORK::GET_NETWORK_TIME()

	transition = 			1574988, -- Is 66 if fully loaded into session

	current = 				1921039 + 9, 		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))

	previous = 				1921039 + 10		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))
})

globals.player_global_indices = essentials.const({
	personal_vehicle = 				{offset = 2703660 + 1 + 173, 		pid_multiplier = 1},

	generic = 						{offset = 1893551 + 1 + 510, 		pid_multiplier = 599}, 		-- Equivalent to global(1921036 + 9) if pid is script host

	organization_associate_hash = 	{offset = 1893551 + 1 + 10 + 2, 	pid_multiplier = 599},		-- Seems to be 1639791091 + (unknown * 3)

	organization_id = 				{offset = 1893551 + 1 + 10, 		pid_multiplier = 599},

	otr_status = 					{offset = 2689224 + 1 + 207, 		pid_multiplier = 451}, 		-- Returns 1 if player is otr

	bounty_status = 				{offset = 1835502 + 1 + 4,			pid_multiplier = 3}, 		-- Returns 1 if player has bounty.

	is_player_typing = 				{offset = 1644218 + 2 + 241 + 136 --[[+ ((16 // 32) * 33)--]], pid_multiplier = 1} -- < this > & 1 << 16 ~= 0 if they're typing.
})


local script_event_hashes <const> = essentials.const({
	["Force player into vehicle"] = 		962740265,

	["Crash 2"] = 							-1386010354,

	["Crash 3"] = 							2112408256,

	["Disown personal vehicle"] = 			-520925154,

	["Vehicle EMP"] =						-2042927980,

	["Destroy personal vehicle"] = 			-1026787486,

	["Kick out of vehicle"] = 				578856274,

	["Give OTR or ghost organization"] =	-391633760,

	["Block passive"] = 					1114091621,

	["Send to Perico island"] = 			-621279188,

	["Apartment invite"] = 					603406648,

	["CEO ban"] = 							-764524031,

	["Dismiss or terminate from CEO"] = 	248967238,

	["Transaction error"] = 				-1704141512,

	["CEO money"] = 						1890277845,

	["Bounty"] = 							1294995624,

	["Generic event"] = 					801199324,

	["Notifications"] = 					677240627
})

globals.GENERIC_ARG_HASHES = essentials.const({ -- Includes all cases (switch statement) with something interesting
	clear_wanted = -1685043744,
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
})

globals.NOTIFICATION_HASHES = essentials.const({
	cash_added_bank = 1990572980,
	cash_stolen = -2106994199,
	cash_removed = 689178114,
	vehicle_kill_list_will_explode_in_x = -1476617592
})

globals.NOTIFICATION_HASHES_RAW = essentials.const({
	-1020918645,
	--[[ Reliant on local script to be running
		-744062923,
		-1402204478,
		-979388144,
		521727704,
	--]]
	699524808,
	-1946063584,
	1178629347,
	1358311090,
	1154852585,
	1310986203,
	-40847318,
	643078607,
	1992208603,
	1752574721,
	912885596,
	1381048616,
	1990572980,
	-2106994199,
	689178114,
	1138171492,
	1704029734,
	-264140477,
	7194932,
	1724437687,
	-936043730,
	1246736526,
	-1830601824,
	-1081859810,
	1916687397,
	645964512,
	1280286772,
	-319623026,
	-1774948616,
	-1692385791,
	---890479893, -- Causes player to be kicked
	-209964813,
	1849048398,
	1821665681,
	1523360013,
	-134517492,
	809515035,
	-848503500,
	637726153,
	1435588721,
	-1530876828,
	1241563604,
	1997868686,
	1204422451,
	1690141969,
	592859285,
	-1233326488,
	-1370555350,
	-1476617592,
	-1488135877,
	1014637718,
	-164715828,
	-1355397705,
	391530867,
	721389992,
	1903175301,
	54080196,
	1843011800,
	-1344943948,
	-1530692143,
	-- -1774405356, Can cause crash
	1323418434,
	-769497109,
	1339791014,
	-866448721,
	318737562,
	1101934106,
	1086826029,
	-2143357669,
	-523143632,
	682666916,
	-286082734,
	-1317931763,
	-853229590,
	1705697128,
	-1538398747,
	-1013675809,
	-1636931911,
	686041060,
	-775323166,
	53185293,
	312888440,
	-1048310207,
	1289803407,
	1880156910,
	-354370119,
	155406806,
	-1678006840,
	1059917272,
	-803052325,
	1914235728,
	1201782980,
	1062837153,
	-2072347577,
	-781928854,
	-931565749,
	-1408108046,
	165771741,
	-1321780445,
	-22225512,
	-2129584942,
	-1868112058,
	218552651,
	1985746964,
	1080374994,
	1567211575,
	-1127630859,
	1240089509,
	577690197,
	-1498220699,
	1806910878,
	1977077611,
	1359589585,
	1171104057,
	1010044380,
	-118624111,
	-198990709,
	-1269681122,
	-393294977,
	-142117497,
	-591557771,
	939590342,
	1240053611,
	-542572166,
	2004413818,
	-1249576871,
	-1081059626,
	1702541153,
	160832359,
	869574944,
	1812609806,
	1742672561,
	-854233377,
	-223879883,
	-1973346552,
	-615536014,
	-155076576,
	1758833487,
	-1163995160,
	91922191,
	-1113591308,
	-2079521652,
	1010148135,
	-1603758683,
	-1564027124,
	2025562671,
	434620279,
	1787604077,
	-453322515,
	-1777438880,
	-439985365,
	-1267886285,
	882590859,
	1187511629,
	453765971,
	-1248267178,
	-113171830,
	-1809326806,
	1728435622,
	-1496601475,
	1788863165,
	-1643758344,
	980511777,
	1541697920,
	-293236205,
	-2045628228,
	-1469019744,
	-616977148,
	-1269285510,
	1937950826,
	-19244849,
	1610198713,
	1131952305,
	-543685796,
	1457441188,
	1848443186,
	-1483156346,
	-1988274527,
	-1771709808,
	1459767362,
	517318842,
	288774761,
	866966274,
	-449255008
})

function globals.get_script_event_hash(name)
	essentials.assert(script_event_hashes[name], "Failed to get hash from script name:", name)
	return script_event_hashes[name]
end

globals.CRASH_NAMES = {"Force player into vehicle"}

for name, _ in pairs(script_event_hashes) do
	if name:find("^Crash %d+$") then
		globals.CRASH_NAMES[#globals.CRASH_NAMES + 1] = name
	end
end

function globals.get_global(global_name)
	essentials.assert(globals.global_indices[global_name], "Invalid global name.", global_name)
	return script.get_global_i(globals.global_indices[global_name])
end

function globals.force_player_into_vehicle(pid) -- Creds to RulyPancake the 5th#1345 for logging this from stand menu
	globals.send_script_event("Force player into vehicle", pid, {pid, 1, 32, network.network_hash_from_player(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1})
	local time <const> = utils.time_ms() + 15000
	system.yield(5000)
	while not player.is_player_dead(pid) and (player.is_player_god(pid) or not essentials.is_in_vehicle(pid)) and time > utils.time_ms() do
		system.yield(0)
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
function globals.send_script_event(...)
	local name <const>,
	pid <const>,
	args <const>,
	friend_condition <const>,
	priority <const>, -- Some script events like emp will not work if delayed too much. 12 se in one frame is far below the the dangerous threshold of 20.
	cant_yield <const> = ... -- Like priority events, this can send if current count is under 12. This allows for most events of this kind to send immediately.
	if player.is_player_valid(pid)
	and (not friend_condition or essentials.is_not_friend(pid)) then
		repeat
			for i, time in pairs(globals.script_event_tracker) do
				if time < utils.time_ms() then
					globals.script_event_tracker[i] = nil
				end
			end
			if not cant_yield and (globals.script_event_tracker.count >= 10 and (not priority or globals.script_event_tracker.count < 12)) then
				system.yield(0)
			end
		until cant_yield or (globals.script_event_tracker.count < 10 or (priority and globals.script_event_tracker.count < 12))
		if player.is_player_valid(pid) and globals.script_event_tracker.count < 12 then
			globals.script_event_tracker[true] = utils.time_ms() + math.ceil(2000 * gameplay.get_frame_time())
			script.trigger_script_event_2(1 << pid, globals.get_script_event_hash(name), table.unpack(args))
			return true
		end
	elseif not cant_yield then
		system.yield(0)
	end
	return false
end

function globals.is_fully_transitioned_into_session()
	return globals.get_global("transition") == 66
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
		for pid in essentials.players(true) do
			globals.send_script_event(
				"Bounty", 
				pid, 
				{
					pid, 
					script_target, 
					3, 
					amount > 0 and amount or 10000, 
					1,
					anonymous and 1 or 0, 
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
					globals.get_global("current"), globals.get_global("previous")
				}
			)
		end
	end
end

function globals.disable_vehicle(...)
	local pid <const>, friend_condition <const> = ...
	if memoize.get_player_coords(pid).z == -50 or player.is_player_in_any_vehicle(pid) then
		globals.send_script_event("Destroy personal vehicle", pid, {pid, pid}, friend_condition)
		globals.send_script_event("Kick out of vehicle", pid, {pid, 0, 0, 0, 0, 1, pid, math.min(2147483647, gameplay.get_frame_count())}, friend_condition)
	end
end

function globals.script_event_crash(...)
	local pid <const> = ...
	if player.is_player_valid(pid) and player.player_id() ~= pid then
		for i = 1, 19 do
			local parameters <const> = {
				pid, 
				-1774405356, 
				math.random(0, 4), 
				math.random(0, 1)
			}
			for i = 5, 13 do
				parameters[#parameters + 1] = math.random(-2147483647, 2147483647)
			end
			parameters[10] = pid
			globals.send_script_event("Notifications", pid, parameters)
		end
		for _, script_name in pairs(globals.CRASH_NAMES) do
			local parameters <const> = {
				pid
			}
			for i = 2, 10 do
				parameters[#parameters + 1] = math.random(-2147483647, 2147483647)
			end
			globals.send_script_event(script_name, pid, parameters)
		end
	end
end

return globals