-- Copyright © 2020-2021 Kektram, Sainan

local globals <const> = {version = "1.2.8"}

local essentials <const> = require("Essentials")
local enums <const> = require("Enums")
local settings <const> = require("settings")

local offsets <const> = essentials.const({
	["_PLAYER_INFO_MAIN"] = 1853128,
	["_PLAYER_INFO_OFFSET_PER_PLAYER"] = 888,
	["_PLAYER_INFO_OFFSET_TO_INFO"] = 205
})

local stats <const> = essentials.const({ -- Thanks to Sainan for some of these stats
	["_PLAYER_INFO_WALLET"] = 3,
	["_PLAYER_INFO_RANK"] = 6,
	["_PLAYER_INFO_KD"] = 26,
	["_PLAYER_INFO_KILLS"] = 28,
	["_PLAYER_INFO_DEATHS"] = 29,
	["_PLAYER_INFO_TOTALMONEY"] = 56,                                                            
	["_PLAYER_INFO_TOTAL_RACES_WON"] = 15,                              
	["_PLAYER_INFO_TOTAL_RACES_LOST"] = 16,                             
	["_PLAYER_INFO_TIMES_FINISH_RACE_TOP_3"] = 17,                      
	["_PLAYER_INFO_TIMES_FINISH_RACE_LAST"] = 18,                       
	["_PLAYER_INFO_TIMES_RACE_BEST_LAP"] = 19,                          
	["_PLAYER_INFO_TOTAL_DEATHMATCH_WON"] = 20,                         
	["_PLAYER_INFO_TOTAL_DEATHMATCH_LOST"] = 21,                        
	["_PLAYER_INFO_TOTAL_TDEATHMATCH_WON"] = 22,                        
	["_PLAYER_INFO_TOTAL_TDEATHMATCH_LOST"] = 23,                       
	["_PLAYER_INFO_TIMES_FINISH_DM_TOP_3"] = 30,                        
	["_PLAYER_INFO_TIMES_FINISH_DM_LAST"] = 31,                         
	["_PLAYER_INFO_DARTS_TOTAL_WINS"] = 32,                             
	["_PLAYER_INFO_DARTS_TOTAL_MATCHES"] = 33,                          
	["_PLAYER_INFO_ARMWRESTLING_TOTAL_WINS"] = 34,                      
	["_PLAYER_INFO_ARMWRESTLING_TOTAL_MATCH"] = 35,                     
	["_PLAYER_INFO_TENNIS_MATCHES_WON"] = 36,                           
	["_PLAYER_INFO_TENNIS_MATCHES_LOST"] = 37,                          
	["_PLAYER_INFO_BJ_WINS"] = 38,                                      
	["_PLAYER_INFO_BJ_LOST"] = 39,                                      
	["_PLAYER_INFO_GOLF_WINS"] = 40,                                    
	["_PLAYER_INFO_GOLF_LOSSES"] = 41,                                  
	["_PLAYER_INFO_SHOOTINGRANGE_WINS"] = 42,                           
	["_PLAYER_INFO_SHOOTINGRANGE_LOSSES"] = 43,                         
	["_PLAYER_INFO_Unknown_stat"] = 44,                                       
	["_PLAYER_INFO_HORDEWINS"] = 47,                                    
	["_PLAYER_INFO_CRHORDE"] = 48,                                      
	["_PLAYER_INFO_MCMWIN"] = 45,                                       
	["_PLAYER_INFO_CRMISSION"] = 46,                                    
	["_PLAYER_INFO_MISSIONS_CREATED"] = 50,                             
	["_PLAYER_INFO_DROPOUTRATE"] = 27,                                  
	["_PLAYER_INFO_MOST_FAVORITE_STATION"] = 53,
	["_PLAYER_INFO_CAN_SPECTATE"] = 52,
	-- Freemode script doesn't explicitly define these, but it seems highly likely they are correct.
	["_PLAYER_INFO_IS_BAD_SPORT"] = 51,
	["_PLAYER_INFO_GLOBALXP"] = 5
	-- Freemode script doesn't explicitly define these, but it seems highly likely they are correct.
})

-- By Sainan
	function globals.get_player_info_offset(pid, info_offset)
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return offsets._PLAYER_INFO_MAIN + (1 + (pid * offsets._PLAYER_INFO_OFFSET_PER_PLAYER)) + offsets._PLAYER_INFO_OFFSET_TO_INFO + info_offset
	end
	function globals.get_player_info_i(pid, info_offset)
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return script.get_global_i(globals.get_player_info_offset(pid, info_offset))
	end
	function globals.get_player_info_f(pid, info_offset)
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return script.get_global_f(globals.get_player_info_offset(pid, info_offset))
	end

function globals.get_all_stats(...)
	local pid <const> = ...
	local STATS <const> = {}
	for i = 1, offsets._PLAYER_INFO_OFFSET_PER_PLAYER do
		STATS[i] =  globals.get_player_info_i(pid, i)
	end
	return STATS
end

function globals.get_player_dart_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_DARTS_TOTAL_WINS)
end

function globals.get_player_dart_matches(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_DARTS_TOTAL_MATCHES)
end

function globals.get_player_arm_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_ARMWRESTLING_TOTAL_WINS)
end

function globals.get_player_arm_matches(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_ARMWRESTLING_TOTAL_MATCH)
end

function globals.get_player_tennis_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TENNIS_MATCHES_WON)
end

function globals.get_player_tennis_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TENNIS_MATCHES_LOST)
end

function globals.get_player_BJ_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_BJ_WINS)
end

function globals.get_player_bj_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_BJ_LOST)
end

function globals.get_player_golf_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_GOLF_WINS)
end

function globals.get_player_golf_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_GOLF_LOSSES)
end

function globals.get_player_golf_winrate(pid)
	return globals.get_player_golf_wins(pid) / globals.get_player_golf_losses(pid)
end

function globals.get_player_shoot_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_SHOOTINGRANGE_WINS)
end

function globals.get_player_shoot_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_SHOOTINGRANGE_LOSSES)
end

function globals.get_player_unknown_stat(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_Unknown_stat)
end

function globals.get_player_horde_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_HORDEWINS)
end

function globals.get_player_c_horde(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_CRHORDE)
end

function globals.get_player_mc_win(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_MCMWIN)
end

function globals.get_player_cr_mission(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_CRMISSION)
end

function globals.get_player_missions_created(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_MISSIONS_CREATED)
end

function globals.get_player_drop_out_rate(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_DROPOUTRATE)
end

function globals.get_player_favorite_radio_station(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_MOST_FAVORITE_STATION)
end

function globals.get_player_team_deathmatch_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTAL_TDEATHMATCH_WON)
end

function globals.get_player_team_deathmatch_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTAL_TDEATHMATCH_LOST)
end

function globals.get_player_team_deathmatch_winrate(pid)
	return globals.get_player_team_deathmatch_wins(pid) / globals.get_player_team_deathmatch_losses(pid)
end

function globals.get_player_deathmatch_top3(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TIMES_FINISH_DM_TOP_3)
end

function globals.get_player_deathmatch_last(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TIMES_FINISH_DM_LAST)
end

function globals.get_player_race_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTAL_RACES_WON)
end

function globals.get_player_race_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTAL_RACES_LOST)
end

function globals.get_player_race_winrate(pid)
	return globals.get_player_race_wins(pid) / globals.get_player_race_losses(pid)
end

function globals.get_player_race_top3(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TIMES_FINISH_RACE_TOP_3)
end

function globals.get_player_race_last(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TIMES_FINISH_RACE_LAST)
end

function globals.get_player_race_best_laps(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TIMES_RACE_BEST_LAP)
end

function globals.get_player_deathmatch_wins(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTAL_DEATHMATCH_WON)
end

function globals.get_player_deathmatch_losses(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTAL_DEATHMATCH_LOST)
end

function globals.get_player_deathmatch_winrate(pid)
	return globals.get_player_deathmatch_wins(pid) / globals.get_player_deathmatch_losses(pid)
end

function globals.get_player_rank(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_RANK)
end

function globals.get_player_money(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_TOTALMONEY)
end
function globals.get_player_wallet(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_WALLET)
end
function globals.get_player_bank(pid)
	return globals.get_player_money(pid) - globals.get_player_wallet(pid)
end

function globals.get_player_kd(pid)
	return globals.get_player_info_f(pid, stats._PLAYER_INFO_KD)
end
function globals.get_player_kills(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_KILLS)
end
function globals.get_player_deaths(pid)
	return globals.get_player_info_i(pid, stats._PLAYER_INFO_DEATHS)
end

function globals.is_player_otr(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	return script.get_global_i(2689156 + (1 + (pid * 453)) + 209) == 1
end

function globals.get_player_personal_vehicle(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	return script.get_global_i(2703656 + (187 + pid + 1))
end

function globals.get_9__10_globals_pair()
	return script.get_global_i(1921036 + 9), script.get_global_i(1921036 + 10)
end

function globals.get_time_global()
	return script.get_global_i(2810287 + 4628)
end

function globals.generic_player_global(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	return script.get_global_i(1893548 + (1 + (pid * 600) + 511))
end

local script_event_hashes <const> = essentials.const({
	["Netbail kick"] = 1228916411,
	["Kick 1"] = 1246667869,
	["Kick 2"] = 1757755807,
	["Kick 3"] = -1125867895,
	["Kick 4"] = -1991317864,
	["Kick 5"] = -614457627,
	["Kick 6"] = 603406648,
	["Kick 7"] = -1970125962,
	["Kick 8"] = 998716537,
	["Kick 9"] = 163598572,
	["Kick 10"] = -1308840134,
	["Kick 11"] = -1501164935,
	["Kick 12"] = 436475575,
	["Kick 13"] = -290218924,
	["Kick 14"] = -368423380,
	["Crash 1"] = 962740265,
	["Crash 2"] = -1386010354,
	["Crash 3"] = 2112408256,
	["Crash 4"] = 677240627,
	["Script host crash 1"] = -1205085020,
	["Script host crash 2"] = 1258808115,
	["Disown personal vehicle"] = -520925154,
	["Vehicle EMP"] = -2042927980,
	["Destroy personal vehicle"] = -1026787486,
	["Kick out of vehicle"] = 578856274,
	["Remove wanted level"] = -91354030,
	["Give OTR or ghost organization"] = -391633760,
	["Block passive"] = 1114091621,
	["Send to mission"] = 2020588206,
	["Send to Perico island"] = -621279188,
	["Apartment invite"] = 603406648,
	["CEO ban"] = -764524031,
	["Dismiss or terminate from CEO"] = 248967238,
	["Insurance notification"] = 802133775,
	["Transaction error"] = -1704141512,
	["CEO money"] = 1890277845,
	["Bounty"] = 1294995624,
	["Banner"] = 1572255940,
	["Sound 1"] = 1132878564,
	["Bribe authorities"] = 1722873242
})

globals.KICK_NAMES = {}
globals.CRASH_NAMES = {}

for name, _ in pairs(script_event_hashes) do
	if name:find("^Kick %d+$") then
		globals.KICK_NAMES[#globals.KICK_NAMES + 1] = name
	end
	if name:find("^Crash %d+$") then
		globals.CRASH_NAMES[#globals.CRASH_NAMES + 1] = name
	end
end

function globals.get_full_arg_table(...)
	local pid <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local args <const> = {pid}
	for i = 2, 39 do
		args[#args + 1] = math.random(-2147483647, 2147483647)
	end
	return args
end

function globals.get_script_event_hash(name)
	essentials.assert(script_event_hashes[name], "Failed to get hash from script name: "..name)
	return script_event_hashes[name]
end

local SE_send_limiter = {}
function globals.send_script_event(...)
	local name <const>,
	pid <const>,
	args <const>,
	friend_condition <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	if player.is_player_valid(pid) and pid ~= player.player_id()
	and (not friend_condition or essentials.is_not_friend(pid)) then
		essentials.assert(args[1] == pid, "First argument of script event wasn't the same as the pid value.")
		for i = 1, #args do
			essentials.assert(math.type(args[i]) == "integer", "Tried to use a non integer value for a script event. Arg "..i)
			essentials.assert(math.abs(args[i]) <= 2147483647, "Tried to use an integer bigger than signed 32 bit max as argument for script event. Arg "..i)
		end
		repeat
			local temp <const> = {}
			for i = 1, #SE_send_limiter do
				if SE_send_limiter[i] > utils.time_ms() then
					temp[#temp + 1] = SE_send_limiter[i]
				end
			end
			SE_send_limiter = temp
			if #temp >= 10 then
				system.yield(0)
			end
		until #temp < 10
		if player.is_player_valid(pid) then
			SE_send_limiter[#SE_send_limiter + 1] = utils.time_ms() + (1 // gameplay.get_frame_time())
			script.trigger_script_event(globals.get_script_event_hash(name), pid, args)
		end
	else
		system.yield(0)
	end
end

function globals.set_bounty(...)
	local script_target <const>,
	friend_relevant <const>,
	anonymous = ...
	if player.is_player_valid(script_target) and player.player_id() ~= script.get_host_of_this_script() and (not friend_relevant or essentials.is_not_friend(script_target)) then
		local amount <const> = math.tointeger(settings.in_use["Bounty amount"]) or 10000
		if anonymous then
			anonymous = 1
		else
			anonymous = 0
		end
		for pid in essentials.players() do
			globals.send_script_event("Bounty", pid, {pid, script_target, 3, amount, 1, anonymous, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals.get_9__10_globals_pair()})
		end
	end
end

function globals.disable_vehicle(...)
	local pid <const>, friend_condition <const> = ...
	if player.get_player_coords(pid).z == -50 or player.is_player_in_any_vehicle(pid) then
		globals.send_script_event("Destroy personal vehicle", pid, {pid, pid}, friend_condition)
		globals.send_script_event("Kick out of vehicle", pid, {pid, 0, 0, 0, 0, 1, pid, math.min(2147483647, gameplay.get_frame_count())}, friend_condition)
	end
end

function globals.kick(...)
	local pid <const> = ...
	if player.is_player_valid(pid) and player.player_id() ~= pid then
		if network.network_is_host() then
			network.network_session_kick_player(pid)
			return
		end
		local args = globals.get_full_arg_table(pid)
		args[2] = math.random(-2147483647, -1)
		args[24] = globals.generic_player_global(pid)
		globals.send_script_event("Kick 1", pid, args)
		globals.send_script_event("Kick 2", pid, {pid, math.random(-2147483647, 2147483647), pid})
		globals.send_script_event("Kick 3", pid, {pid, math.random(-2147483647, 2147483647)})
		globals.send_script_event("Kick 4", pid, {pid, -1, -1, -1, -1})
		local parameters <const> = {
			pid
		}
		for i = 2, 23 do
			parameters[#parameters + 1] = math.random(-2147483647, -10)
		end
		globals.send_script_event("Kick 5", pid, parameters)
		for arg, hash in pairs({1880156910, -890479893, 155406806, 1059917272}) do
			globals.send_script_event("Kick 6", pid, {
				pid, 
				hash, 
				arg, 
				1,
				math.random(-2147483647, -10),
				math.random(-2147483647, -10),
				math.random(-2147483647, -10),
				math.random(-2147483647, -10),
				math.random(-2147483647, -10),
				pid,
				math.random(-2147483647, -10),
				math.random(-2147483647, -10),
				math.random(-2147483647, -10)
			})
		end
		for _, script_name in pairs(globals.KICK_NAMES) do
			globals.send_script_event(script_name, pid, globals.get_full_arg_table(pid))
		end
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
		if script.get_host_of_this_script() == pid then
			for i = 0, 14 do
				globals.send_script_event("Script host crash 1", pid, {pid, i})
			end
			local parameters <const> = {
				pid
			}
			for i = 2, 26 do
				parameters[#parameters + 1] = math.random(-10000, 10000)
			end
			globals.send_script_event("Script host crash 2", pid, parameters)
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

return essentials.const_all(globals)