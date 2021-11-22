-- Copyright © 2020-2021 Kektram, Sainan

kek_menu.lib_versions["Globals"] = "1.2.6"

local globals = {}

local essentials = kek_menu.require("Essentials")

local offsets <const> = {
	["_PLAYER_INFO_MAIN"] = 1590908,
	["_PLAYER_INFO_OFFSET_PER_PLAYER"] = 874,
	["_PLAYER_INFO_OFFSET_TO_INFO"] = 205
}

local stats <const> = { -- Thanks to Sainan for some of these stats
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
	["_PLAYER_INFO_MOST_FAVORITE_STATION"] = 53
}
-- By Sainan
	function globals.get_player_info_offset(pid, info_offset)
		return offsets._PLAYER_INFO_MAIN + (1 + (pid * offsets._PLAYER_INFO_OFFSET_PER_PLAYER)) + offsets._PLAYER_INFO_OFFSET_TO_INFO + info_offset
	end
	function globals.get_player_info_i(pid, info_offset)
		return script.get_global_i(globals.get_player_info_offset(pid, info_offset))
	end
	function globals.get_player_info_f(pid, info_offset)
		return script.get_global_f(globals.get_player_info_offset(pid, info_offset))
	end

-- Stats
	function globals.get_all_stats(...)
		local pid <const> = ...
		local STATS = {}
		for i = 1, offsets._PLAYER_INFO_OFFSET_PER_PLAYER do
			STATS[i] =  globals.get_player_info_i(pid, i)
		end
		return STATS
	end

	function globals.get_player_deaths(pid)
		return globals.get_player_info_i(pid, stats._PLAYER_INFO_DEATHS)
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

	function globals.get_player_all_stats(pid)
		return stats
	end

	function globals.is_player_otr(pid)
		return script.get_global_i(2426865 + (1 + (pid * 449)) + 209) == 1
	end

	function globals.get_player_personal_vehicle(pid)
		return script.get_global_i(2441237 + (614 + pid + 1))
	end

-- Globals used for various script events
	function globals.get_9__10_globals_pair()
		return script.get_global_i(1658176 + 9), script.get_global_i(1658176 + 10)
	end

	function globals.get_time_global()
		return script.get_global_i(2544210 + 4627)
	end

	function globals.generic_player_global(pid)
		return script.get_global_i(1630816 + (1 + (pid * 597) + 508))
	end

-- Script events
	local script_event_hashes <const> = {
		["Netbail kick"] = 2092565704,
		["Kick 1"] = 1964309656,
		["Kick 2"] = 696123127,
		["Kick 3"] = 43922647,
		["Kick 4"] = 600486780,
		["Kick 5"] = 1954846099,
		["Kick 6"] = 153488394,
		["Kick 7"] = 1249026189,
		["Kick 8"] = 515799090,
		["Kick 9"] = 1463355688,
		["Kick 10"] = -1382676328,
		["Kick 11"] = 1256866538,
		["Kick 12"] = 515799090,
		["Kick 13"] = -1813981910,
		["Kick 14"] = 202252150,
		["Kick 15"] = -19131151,
		["Kick 16"] = -635501849,
		["Kick 17"] = 1964309656,
		["Crash 1"] = -988842806,
		["Crash 2"] = -2043109205,
		["Crash 3"] = 1926582096,
		["Crash 4"] = 153488394,
		["Script host crash 1"] = 315658550,
		["Script host crash 2"] = -877212109,
		["Disown personal vehicle"] = -2072214082,
		["Vehicle EMP"] = 975723848,
		["Destroy personal vehicle"] = 1229338575,
		["Kick out of vehicle"] = -1005623606,
		["Remove wanted level"] = 1187364773,
		["Give OTR or ghost organization"] = -397188359,
		["Block passive"] = 1472357458,
		["Send to mission"] = -1147284669,
		["Send to Perico island"] = -1479371259,
		["Apartment invite"] = 1249026189,
		["CEO ban"] = 1355230914,
		["Dismiss or terminate from CEO"] = -316948135,
		["Insurance notification"] = 299217086,
		["Transaction error"] = -2041535807,
		["CEO money"] = 1152266822,
		["Bounty"] = -1906146218,
		["Banner"] = 1659915470,
		["Sound 1"] = 1537221257,
		["Sound 2"] = -1162153263,
		["Bribe authorities"] = -151720011
	}	

	function globals.get_full_arg_table(...)
		local pid <const> = ...
		local args = {pid}
		for i = 2, 39 do
			args[i] = math.random(-2147483647, 2147483647)
		end
		return args
	end

	function globals.get_script_event_hash(...)
		local name <const> = ...
		local hash <const> = script_event_hashes[name]
		if math.type(hash) == "integer" then
			return hash
		else
			essentials.log_error("Failed to hash from script name: "..name or "")
			return 0
		end
	end

	function globals.get_kick_hashes()
		local names = {}
		local hashes = {}
		for name, hash in pairs(script_event_hashes) do
			if name:find("^Kick %d+$") then
				names[#names + 1] = name
				hashes[#hashes + 1] = hash
			end
		end
		return names, hashes
	end

	function globals.get_crash_hashes()
		local names = {}
		local hashes = {}
		for name, hash in pairs(script_event_hashes) do
			if name:find("^Crash %d+$") then
				names[#names + 1] = name
				hashes[#hashes + 1] = hash
			end
		end
		return names, hashes
	end

	local SE_send_limiter = {}
	function globals.send_script_event(...)
		local name <const>,
		pid <const>,
		args <const>,
		friend_condition <const> = ...
		if player.is_player_valid(pid) and pid ~= player.player_id()
		and (not friend_condition or essentials.is_not_friend(pid)) then
			if math.type(pid) == "integer" then 
				for i = 1, #args do
					if math.type(args[i]) ~= "integer" then
						essentials.log_error("Invalid parameter to script event", true)
						return
					end
				end
			else
				essentials.log_error("Invalid parameter to script event", true)
				return
			end
			repeat
				local temp = {}
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
			local amount <const> = math.tointeger(kek_menu.settings["Bounty amount"]) or 10000
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
			globals.send_script_event("Kick out of vehicle", pid, {pid, 0, 0, 0, 0, 1, pid, gameplay.get_frame_count()}, friend_condition)
		end
	end

	function globals.kick(...)
		local pid <const> = ...
		system.yield(0)
		if player.is_player_valid(pid) and pid ~= player.player_id() then
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
			local parameters = {
				pid
			}
			for i = 2, 23 do
				parameters[i] = math.random(-2147483647, -10)
			end
			globals.send_script_event("Kick 5", pid, parameters)
			for i, k in pairs({-1726396442, 154008137, 428882541, -1714354434}) do
				globals.send_script_event("Kick 6", pid, {
					pid, 
					k, 
					i, 
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
			for i, script_name in pairs(globals.get_kick_hashes()) do
				globals.send_script_event(script_name, pid, globals.get_full_arg_table(pid))
			end
		end
	end

	function globals.script_event_crash(...)
		local pid <const> = ...
		system.yield(0)
		if player.is_player_valid(pid) then
			for i = 1, 19 do
				local parameters = {
					pid, 
					-1139568479, 
					math.random(0, 4), 
					math.random(0, 1)
				}
				for i = 5, 13 do
					parameters[i] = math.random(-2147483647, 2147483647)
				end
				parameters[10] = pid
				globals.send_script_event("Crash 4", pid, parameters)
			end
			if script.get_host_of_this_script() == pid then
				for i = 0, 14 do
					globals.send_script_event("Script host crash 1", pid, {pid, i})
				end
				local parameters = {
					pid
				}
				for i = 2, 26 do
					parameters[i] = math.random(-10000, 10000)
				end
				globals.send_script_event("Script host crash 2", pid, parameters)
			end
			for i, script_name in pairs(globals.get_crash_hashes()) do
				local parameters = {
					pid
				}
				for i = 2, 10 do
					parameters[i] = math.random(-2147483647, 2147483647)
				end
				globals.send_script_event(script_name, pid, parameters)
			end
		end
	end

return globals