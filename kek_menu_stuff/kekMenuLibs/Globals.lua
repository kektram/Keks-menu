-- Copyright © 2020-2022 Kektram, Sainan

local globals <const> = {version = "1.3.1"}

local essentials <const> = require("Essentials")
local enums <const> = require("Enums")
local settings <const> = require("settings")
local memoize <const> = require("Memoize")

local offsets <const> = essentials.const({
	["MAIN"] = 1853128,
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
	time = 					2810287 + 4628, 	-- NETWORK::GET_NETWORK_TIME()

	current = 				1921036 + 9, 		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))

	previous = 				1921036 + 10		-- Negative framecount * ((joaat(script host name) * cloud time) + random(0, 65534) + random(0, 65534))
})

globals.player_global_indices = essentials.const({
	personal_vehicle = 				{offset = 2703656 + 1 + 187, 		pid_multiplier = 1},

	generic = 						{offset = 1893548 + 1 + 511, 		pid_multiplier = 600}, 		-- Equivalent to global(1921036 + 9) if pid is script host

	organization_associate_hash = 	{offset = 1893548 + 1 + 11 + 2, 	pid_multiplier = 600},		-- Seems to be 1639791091 + (unknown * 3)

	organization_id = 				{offset = 1893548 + 1 + 11, 		pid_multiplier = 600},

	otr_status = 					{offset = 2689156 + 1 + 209, 		pid_multiplier = 453}, 		-- Returns 1 if player is otr

	bounty_status = 				{offset = 1835502 + 1 + 4,			pid_multiplier = 3}, 		-- Returns 1 if player has bounty.
})


local script_event_hashes <const> = essentials.const({
	["Crash 1"] = 							962740265,

	["Crash 2"] = 							-1386010354,

	["Crash 3"] = 							2112408256,

	["Crash 4"] = 							677240627,

	["Disown personal vehicle"] = 			-520925154,

	["Vehicle EMP"] =						-2042927980,

	["Destroy personal vehicle"] = 			-1026787486,

	["Kick out of vehicle"] = 				578856274,

	["Remove wanted level"] = 				-91354030,

	["Give OTR or ghost organization"] =	-391633760,

	["Block passive"] = 					1114091621,

	["Send to mission"] = 					2020588206,

	["Send to Perico island"] = 			-621279188,

	["Send to eclipse"] = 					603406648,

	["Apartment invite"] = 					603406648,

	["CEO ban"] = 							-764524031,

	["Dismiss or terminate from CEO"] = 	248967238,

	["Insurance notification"] = 			802133775,

	["Transaction error"] = 				-1704141512,

	["CEO money"] = 						1890277845,

	["Bounty"] = 							1294995624,
})

function globals.get_script_event_hash(name)
	essentials.assert(script_event_hashes[name], "Failed to get hash from script name:", name)
	return script_event_hashes[name]
end

globals.CRASH_NAMES = {}

for name, _ in pairs(script_event_hashes) do
	if name:find("^Crash %d+$") then
		globals.CRASH_NAMES[#globals.CRASH_NAMES + 1] = name
	end
end

function globals.get_global(global_name)
	essentials.assert(player.player_count() > 0, "Tried to get a global in singleplayer.")
	essentials.assert(globals.global_indices[global_name], "Invalid global name.", global_name)
	return script.get_global_i(globals.global_indices[global_name])
end

function globals.get_player_global(global_name, pid, get_index)
	essentials.assert(player.player_count() > 0, "Tried to get a player global in singleplayer.")
	essentials.assert(globals.player_global_indices[global_name], "Invalid player global name.", global_name)
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
			script.trigger_script_event(globals.get_script_event_hash(name), pid, args)
			return true
		end
	elseif not cant_yield then
		system.yield(0)
	end
	return false
end

function globals.set_bounty(...)
	local script_target <const>,
	friend_relevant <const>,
	anonymous = ...
	if player.player_count() > 0
	and globals.get_player_global("bounty_status", script_target) == 0
	and player.player_id() ~= script.get_host_of_this_script()
	and player.is_player_valid(script_target) 
	and player.is_player_playing(script_target) 
	and (not friend_relevant or essentials.is_not_friend(script_target)) then
		local amount = math.tointeger(settings.in_use["Bounty amount"]) or 10000
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
			globals.send_script_event("Crash 4", pid, parameters)
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