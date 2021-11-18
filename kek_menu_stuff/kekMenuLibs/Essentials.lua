-- Lib Essentials version: 1.3.1
-- Copyright © 2020-2021 Kektram

local essentials = {}
local key_mapper = require("Key mapper")

local home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"
local kek_menu_stuff_path = home.."scripts\\kek_menu_stuff\\"

-- Feature type ids
	essentials.FEATURE_ID_MAP = {
		[512]   = "action",
		[1]     = "toggle",
		[2048]  = "parent",
		[11]    = "value_i",
		[131]   = "value_f",
		[7]     = "slider",
		[35]    = "value_str",
		[522]   = "action_value_i",
		[642]   = "action_value_f",
		[518]   = "action_slider",
		[546]   = "action_value_str",
		[1034]  = "autoaction_value_i",
		[1154]  = "autoaction_value_f",
		[1030]  = "autoaction_slider",
		[1058]  = "autoaction_value_str",
		[33280] = "action",
		[32769] = "toggle",
		[2048]  = "parent",
		[32779] = "value_i",
		[32899] = "value_f",
		[32775] = "slider",
		[32803] = "value_str",
		[33290] = "action_value_i",
		[33410] = "action_value_f",
		[33286] = "action_slider",
		[33314] = "action_value_str",
		[33802] = "autoaction_value_i",
		[33922] = "autoaction_value_f",
		[33798] = "autoaction_slider",
		[33826] = "autoaction_value_str"
	}

-- Is feature name valid
	function essentials.get_safe_feat_name(name)
		local pattern = name:gsub("[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz%d%s%p]", "")
		if #pattern > 0 then
			name = name:gsub("["..pattern.."]", "")
		end
		return name
	end

-- Get all features from all luas
	function essentials.get_all_features()
		local feat_map = {feats = {}, player_feats = {}}
		local i, feat = 1, 0
		while i < 15000 do
			if i % 1000 == 0 then
				system.yield(0)
			end
			feat = menu.add_feature("", "action", i)
			if feat then
				local id = feat.id
				local parent = feat.parent
				while parent do
					feat = parent
					parent = feat.parent
				end
				feat_map.feats[feat.id] = feat
				menu.delete_feature(id)
			end
			i = i + 1
		end
		i = 0
		while i < 10 or menu.get_player_feature(i) do
			if menu.get_player_feature(i) then
				local parent = i
				while parent ~= 4294967295 
				and menu.get_player_feature(parent) 
				and menu.get_player_feature(parent).parent_id ~= 4294967295 do
					parent = menu.get_player_feature(parent).parent_id
				end
				feat_map.player_feats[parent] = menu.get_player_feature(parent)
			end
			i = i + 1
		end
		return feat_map
	end

-- Interact with file
	function essentials.file(file, Type, str)
		if io.type(file) == "file" or (type(file) == "string" and Type == "rename") then
			if Type == "close" then
				file:close()
			elseif Type == "read" and type(str) == "string" then
				return file:read(str)
			elseif Type == "flush" then
				file:flush()
			elseif Type == "write" and type(str) == "string" then
				file:write(str)
			elseif Type == "rename" and type(str) == "string" and type(file) == "string" then
				if not tostring(str:match(".+\\(.-)$")):find("[<>:\"/\\|%?%*]") then
					if utils.file_exists(home..file) then
						local file_string = essentials.get_file_string(file, "*a")
						io.remove(home..file)
						local file = io.open(home..str, "w+")
						essentials.file(file, "write", file_string)
						essentials.file(file, "flush")
						essentials.file(file, "close")
						return true
					else
						return false 
					end
				else
					return false
				end
			end
		else
			essentials.log_error("Failed to interact with a file.")
		end
	end

	function essentials.wait_conditional(duration, func, ...)
		system.yield(0)
		local time = utils.time_ms() + duration
		while func(...) and time > utils.time_ms() do
			system.yield(0)
		end
	end

-- Write xml
	function essentials.write_xml(file, Table, tabs, name)
		if name then
			essentials.file(file, "write", tabs:sub(2, #tabs).."<"..name..">\n")
		end
		for property_name, property in pairs(Table) do
			if type(property) == "table" then
				essentials.write_xml(file, property, tabs.."	", property_name)
			else
				essentials.file(file, "write", tabs.."<"..property_name..">"..tostring(property).."</"..property_name..">\n")
			end
		end
		if name then
			essentials.file(file, "write", tabs:sub(2, #tabs).."</"..name:match("^([%w%p]+)")..">\n")
		end
	end

-- Log errors
	local last_error_time = 0
	local last_error = ""
	function essentials.log_error(str, yield)
		if utils.time_ms() > last_error_time and last_error ~= debug.traceback(str, 2) then
			last_error_time = utils.time_ms() + 100
			last_error = debug.traceback(str, 2)
			local file = io.open(kek_menu_stuff_path.."kekMenuLogs\\kek_menu_log.log", "a+")
			local additional_info = ""
			for i2 = 2, 1000 do
				if pcall(function() 
					return debug.getlocal(i2 + 2, 1)
				end) then
					if i2 == 2 then
						additional_info = additional_info.."\nLocals triggering the error:\n"
					else
						additional_info = additional_info.."\nLocals at level "..i2..":\n"
					end
					for i = 1, 200 do
						local name, value = debug.getlocal(i2, i)
						if not name then
							break
						end
						if name ~= "(temporary)" then
							local Type = type(value)
							if Type == "number" then
								Type = math.type(value)
							end
							additional_info = additional_info .. "	["..name.."] = "..tostring(value):sub(1, 50).." ("..Type..")".."\n"
						end
					end
				else
					break
				end
			end
			file:write(debug.traceback("["..os.date().."]: "..str.." [Kek's menu version: "..kek_menu.version.."]", 2)..additional_info)
			file:close()
		end
		if yield then
			system.yield(0)
		end
	end

	function essentials.is_z_coordinate_correct(pos)
		return pos.z ~= -50 and pos.z ~= -180 and pos.z ~= -190
	end

-- Get randomized string
	function essentials.get_random_string(rand_min, rand_max, max)
		local vecu64_table = {}
		for i = 1, math.random(rand_min or 1, rand_max or 12) do
			vecu64_table[#vecu64_table + 1] = math.random(1, max or math.max_integer)
		end
		return utils.vecu64_to_str(vecu64_table)
	end

-- Messager function
	function essentials.msg(text, color, notifyOn, duration)
		if type(text) == "string" and math.type(color) == "integer" then
			if notifyOn then
				if math.type(duration) ~= "integer" then
					duration = 3
				end
				menu.notify(text, "Kek's "..kek_menu.version, duration, color)
			end
		else
			essentials.log_error("Failed to send notification.")
		end
	end

-- Is player in vehicle
	function essentials.is_in_vehicle(pid)
		return player.is_player_in_any_vehicle(pid) or player.get_player_coords(pid).z == -50
	end

-- Request ptfx
	local function ptfx_count()
		local count = 0
		local status
		repeat
			status = true
			count = count + 1
			for i = 1, #kek_menu.ptfx do
				if utils.time_ms() > kek_menu.ptfx[i] then
					table.remove(kek_menu.ptfx, i)
					status = false
					break
				end
			end
		until status or count > 200
		return #kek_menu.ptfx <= kek_menu.PTFX_LIMIT
	end
	function essentials.request_ptfx(str_asset)
		if ptfx_count() then
			graphics.request_named_ptfx_asset(str_asset)
			local time = utils.time_ms() + 400
			while not graphics.has_named_ptfx_asset_loaded(str_asset) and time > utils.time_ms() do
				system.yield(0)
			end
			if graphics.has_named_ptfx_asset_loaded(str_asset) then
				graphics.set_next_ptfx_asset(str_asset)
				return true
			end
		end
	end

	local ptfx_cost_exceptions = {
		[gameplay.shoot_single_bullet_between_coords] = 1000,
		[graphics.start_networked_ptfx_looped_on_entity] = 6000
	}

	function essentials.use_ptfx_function(func, ...)
		if ptfx_count() then
			kek_menu.ptfx[#kek_menu.ptfx + 1] = utils.time_ms() + (ptfx_cost_exceptions[func] or 3000)
			return func(...)
		end
	end

-- Is friend
	function essentials.is_not_friend(pid)
		return not kek_menu.toggle["Exclude friends from attacks #malicious#"].on or not network.is_scid_friend(player.get_player_scid(pid))
	end

-- Get most relevant player entity
	function essentials.get_most_relevant_entity(pid)
		if player.is_player_in_any_vehicle(pid) then
			return player.get_player_vehicle(pid)
		else
			return player.get_player_ped(pid)
		end
	end

-- Message spam disconnect prevention
do
	local last_message_sent = 0
	local number_of_active_messages = 0
	function essentials.send_message(text, team)
		if number_of_active_messages > 30 then
			return
		end
		if type(text) == "string" then
			number_of_active_messages = number_of_active_messages + 1
			local time = utils.time_ms() + 2000
			repeat
				system.yield(0)
			until utils.time_ms() > last_message_sent or utils.time_ms() > time
			if time > utils.time_ms() then
				local time = utils.time_ms() + 5000
				repeat
					network.send_chat_message(text:sub(1, 255), team == true)
					text = text:sub(256, -1)
					system.yield(150)
				until #text == 0 or utils.time_ms() > time
				last_message_sent = utils.time_ms() + 150
			end
			number_of_active_messages = number_of_active_messages - 1
		end
	end
end

-- Get index of table value
	function essentials.get_index_of_value(Table, value_to_find_index_of)
		for i, value in pairs(Table) do
			if value_to_find_index_of == value then
				return i
			end
		end
	end

-- Get random player except
	function essentials.get_random_player_except(exclusions)
		local pids = {}
		for pid = 0, 31 do
			if player.is_player_valid(pid) and not essentials.get_index_of_value(exclusions, pid) then
				pids[#pids + 1] = pid
			end
		end
		if #pids > 0 then
			return pids[math.random(1, #pids)]
		else
			return player.player_id()
		end
	end

-- Remove special characters
	function essentials.remove_special(text)
		if type(text) == "string" then
			text = text:gsub("%%", "%%%%")
			text = text:gsub("%[", "%%[")
			text = text:gsub("%]", "%%]")
			text = text:gsub("%(", "%%(")
			text = text:gsub("%)", "%%)")
			text = text:gsub("%-", "%%-")
			text = text:gsub("%+", "%%+")
			text = text:gsub("%?", "%%?")
			text = text:gsub("%*", "%%*")
			text = text:gsub("%^", "%%^")
			text = text:gsub("%$", "%%$")
			text = text:gsub("%.", "%%.")
			return text
		else
			return ""
		end
	end

-- File open-read-close
	function essentials.get_file_string(path, type, not_wait)
		if utils.file_exists(home..path) then
			local file = io.open(home..path)
			if file then
				local str = essentials.file(file, "read", type) or ""
				essentials.file(file, "close")
				return str
			else
				essentials.log_error("FAILED TO OPEN "..path)
				return ""
			end
		end
		return ""
	end

-- Search for file
	function essentials.get_file(path, file_extension, str)
		for i, file_name in pairs(utils.get_all_files_in_directory(home..path, file_extension)) do
			if file_name ~= "autoexec.lua" and file_name:lower():find(str:lower(), 1, true) then
				return home..path..file_name, file_name
			end
		end
		return "", ""
	end

-- Get a parent's decendants
	function essentials.get_descendants(parent, Table, add_parent_of_descendants)
		for i, feat in pairs(parent.children) do
			if feat.type == 2048 and feat.child_count > 0 then
				essentials.get_descendants(feat, Table, true)
			end
			Table[#Table + 1] = feat
		end
		if add_parent_of_descendants then
			Table[#Table + 1] = parent
		end
		return Table
	end

-- Get a parent's decendants
	function essentials.get_player_descendants(parent, Table, add_parent_of_descendants)
		for i, feat in pairs(parent.feats[0].children) do
			feat = menu.get_player_feature(feat.id)
			if feat.feats[0].type == 2048 and feat.feats[0].child_count > 0 then
				essentials.get_player_descendants(menu.get_player_feature(feat.id), Table, true)
			end
			Table[#Table + 1] = menu.get_player_feature(feat.id)
		end
		if add_parent_of_descendants then
			Table[#Table + 1] = parent
		end
		return Table
	end

-- Get pid from name
	function essentials.name_to_pid(name)
		if type(name) == "string" then
			name = name:lower()
			for pid = 0, 31 do
				if player.is_player_valid(pid) and player.get_player_name(pid):lower():find(name, 1, true) then
					return pid
				end
			end
		end
		return 32
	end

-- Get ped depending on spectate
	function essentials.get_ped_closest_to_your_pov()
		local spectate_target = network.get_player_player_is_spectating(player.player_id())
		if spectate_target then
			return player.get_player_ped(spectate_target)
		else
			return player.get_player_ped(player.player_id())
		end
	end

-- Distance between 2 entities
	function essentials.get_distance_between(entity_or_position_1, entity_or_position_2)
		if type(entity_or_position_1) == "userdata" and type(entity_or_position_2) == "userdata" then
			return entity_or_position_1:magnitude(entity_or_position_2)
		else
			if math.type(entity_or_position_1) == "integer" then
				if not entity.is_an_entity(entity_or_position_1) then
					return 500000
				end
				entity_or_position_1 = entity.get_entity_coords(entity_or_position_1)
			end
			if math.type(entity_or_position_2) == "integer" then 
				if not entity.is_an_entity(entity_or_position_2) then
					return 500000
				end
				entity_or_position_2 = entity.get_entity_coords(entity_or_position_2)
			end
			if type(entity_or_position_1) == "userdata" and type(entity_or_position_2) == "userdata" then
				return entity_or_position_1:magnitude(entity_or_position_2)
			else
				return 0
			end
		end
	end

-- Check if player is valid
	function essentials.is_player_completely_valid(pid)
		return player.is_player_valid(pid)
		and not player.is_player_modder(pid, -1) 
		and player.is_player_playing(pid)
		and entity.is_an_entity(player.get_player_ped(pid))
		and essentials.is_z_coordinate_correct(player.get_player_coords(pid))
		and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 
	end

-- Is any true
	function essentials.is_any_true(Table, conditions)
		for i = 1, #Table do
			if conditions(Table[i]) then
				return true
			end
		end
	end

-- Is all true
	function essentials.is_all_true(Table, conditions)
		for i = 1, #Table do
			if not conditions(Table[i]) then
				return
			end
		end
		return true
	end

-- Sort a table from highest to lowest
	function essentials.sort_numbers(t)
		table.sort(t, function(a, b) return (tonumber(a:match("[%d]+")) or 0) > (tonumber(b:match("[%d]+")) or 0) end)
		return t
	end

-- Round a number
	function essentials.round(num)
		if tonumber(num) then
			local floor = math.floor(num)
			if floor >= num - 0.4999999999 then
				return floor
			else
				return math.ceil(num)
			end
		else
			return 0
		end
	end

-- Get pos with minimum offset 
	function essentials.get_offset(pos, a, b, min, max)
		local offset
		for i = 1, 50 do
			offset = v3(essentials.random_real(a, b), essentials.random_real(a, b), 0)
			local dist = essentials.get_distance_between(pos, pos + offset)
			if dist >= min and dist <= max then
				break
			end
		end
		return offset
	end

-- Get random real
	function essentials.random_real(a, b)
		local power = math.min(18 - #tostring(a), 17 - #tostring(b))
		local a = a * 10^power
		local b = b * 10^power
		local c = math.random(a, b)
		return c / 10^power
	end

-- Random wait for intense loops
	function essentials.random_wait(t)
		local t = math.ceil(t)
		if t < 1 then
			t = 1
		end
		if math.random(1, t) == 1 then
			system.yield(0)
		end
	end 

-- Input function
	function essentials.get_input(title, default, len, Type)
		if type(title) ~= "string" then
			title = ""
		end
		if type(default) ~= "string" and math.type(default) ~= "integer" then
			default = ""
		end
		if math.type(len) == "integer" and math.type(Type) == "integer" then
			local Keys = key_mapper.get_virtual_key_of_2take1_bind("MenuSelect")
			key_mapper.do_vk(10000, Keys)
			local input_status, text = nil, ""
			repeat
				input_status, text = input.get(title, default, len, Type)
				system.yield(0)
			until input_status ~= 1
			key_mapper.do_vk(10000, Keys)
			if not text or #text:gsub("%s", "") == 0 or input_status == 2 then
				essentials.msg(kek_menu.lang["Cancelled. §"], 6, true)
				return "", 2
			else
				return text, 0
			end
		else
			essentials.log_error("Failed to get input.", true)
			return "", 2
		end
	end

-- Slider I/O
	function essentials.value_i_setup(feature, input_title, input_type)
		local input, status = essentials.get_input(input_title, "", #tostring(feature.max), input_type or 3)
		if status == 2 then
			return
		end
		local value_i_int = tonumber(input)
		if type(value_i_int) == "number" then 
			if value_i_int < feature.min then
				feature.value = feature.min
			elseif feature.max >= value_i_int then
				feature.value = value_i_int
			else
				feature.value = feature.max
			end
		end
	end

	function essentials.set_all_player_feats_except(player_feat_id, bool, exclusions)
		if math.type(player_feat_id) == "integer" then
			for pid = 0, 31 do
				if not essentials.get_index_of_value(exclusions, pid) then
					menu.get_player_feature(player_feat_id).feats[pid].on = bool == true
				end
			end
		else
			essentials.log_error("Failed to toggle player feat.")
		end
	end

-- Get IP: Creds to Proddy
	function essentials.get_ip_in_ipv4(pid)
		local ip = player.get_player_ip(pid)
		return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
	end

-- Ipv4 to dec
	function essentials.ipv4_to_dec(ip)
		if ip:find("%.") then
			return ip
		end
		local dec = 0
		for octet in string.gmatch(ip, "%d+") do 
			dec = octet + dec << 8 
		end
		if not math.ceil(dec) then 
			return ""
		else
			return math.ceil(dec) 
		end
	end

-- Search for match in file
	function essentials.search_for_match_and_get_line(file_name, search, exact, yield)
		local str = essentials.get_file_string(file_name, "*a")
		if yield then
			for i = 1, #search do
				for line in str:gmatch("([^\n]*)\n?") do
					if search[i] == line or (not exact and line:find(search[i], 1, true)) then
						return line, search[i]
					end
					essentials.random_wait(500)
				end
			end
		else
			for i = 1, #search do
				for line in str:gmatch("([^\n]*)\n?") do
					if search[i] == line or (not exact and line:find(search[i], 1, true)) then
						return line, search[i]
					end
				end
			end
		end
	end

-- Check if string contains advert
	function essentials.contains_advert(str)
		local ads = {
			".com",
			".net",
			".org",
			"http",
			"www.",
			".tk",
			".ru",
			".info",
			".cn",
			".uk",
			".biz",
			".xyz",
			"qq"
		}
		for i = 1, #ads do
			if str:find(ads[i], 1, true) then
				return true
			end
		end
	end

-- Log / check if already in file
	function essentials.log(file_name, text_to_log, search, exact, yield)
		if search then
			local str = essentials.search_for_match_and_get_line(file_name, search, exact, yield)
			if str then
				return str
			end
		end
		local file = io.open(home..file_name, "a+")
    	essentials.file(file, "write", text_to_log.."\n")
    	essentials.file(file, "close")
    end

-- Add to join timeout
	function essentials.add_to_timeout(pid)
		essentials.log("cfg\\scid.cfg", player.get_player_name(pid)..":"..select(1, string.format("%x", player.get_player_scid(pid)))..":c", {select(1, string.format("%x", player.get_player_scid(pid))), player.get_player_name(pid)}, false, true)
	end

	function essentials.send_pattern_guide_msg(part, Type)
		local parts = {
			["Chat judger"] = {
				"There are 2 special texts for the chat judger: [BLACKLIST] = Add people to the blacklist\\n[JOIN TIMEOUT] = Add people to 2take1's join timeout. §",
				"Examples of how to use:\\nmoney[BLACKLIST] -- This will add anyone saying the word money in a sentence to the blacklist §",
				"money[JOIN TIMEOUT][BLACKLIST] -- This will add anyone saying money to the timeout and blacklist. §"
			},
			["Chatbot"] = {
				"There are 3 special texts for the chatbot:\\n[PLAYER_NAME] -- This grabs the player sending the message's name. §",
				"[MY_NAME] -- This gets your name\\n[RANDOM_NAME] -- This gets a random player's name. §"
			},
			regular = {
				"When adding entries, it's important to know about patterns. A pattern could look like this: %s+money%s+. This would look for people using money in the middle of a sentence. §",
				"Note that these characters: \"*\", \"+\", \"-\", \"^\", \"$\", \".\", \"?\", \"[\", \"]\", \"(\" & \")\" have special meanings. Google \"Lua magic characters\" to find out what they mean. §",
				"For further assistance, join the Kek's menu discord. An invite comes with the script. It is in a file called \"Discord invite.txt\". §"
			}

		}
		table.move(parts.regular, 1, #parts.regular, #parts[Type] + 1, parts[Type])
		for i = 1, #parts[Type] do
			if part + 1 == i then
				essentials.msg(kek_menu.lang[parts[Type][i]], 6, true, 12)
				break
			end
		end
	end

    function essentials.invalid_pattern(text, msg, warn)
    	if warn then
    		if text:find("[%.%+%-%*%?%^%$]") and not text:find("%%[%.%+%-%*%?%^%$]") then
    			essentials.msg(kek_menu.lang["Warning: missing \"%\" before any of these characters; §"].." \".\", \"+\", \"-\", \"*\", \"?\", \"^\", \"$\".\n"..kek_menu.lang["This is fine, just note that if you don't put the \"%\" before those characters, they mean something else. §"], 6, true, 12)
    		end
    	end
    	local status = pcall(function() 
			return text:find(text)
		end)
		if not status then
			essentials.msg(kek_menu.lang["Invalid pattern. Most likely missing a \"[\", \"]\", \"(\", \")\" or a \"%\" somewhere. Could also be \"[]\", having \"[]\" causes an error. §"], 6, msg, 12)
			return true
		end
    end

-- Merge tables 
	function essentials.merge_tables(parent_table, children_tables)
		for table_index, children_table in pairs(children_tables) do
			table.move(children_table, 1, #children_table, #parent_table + 1, parent_table)
		end
		return parent_table
	end

-- Remove / replace a value from file
	function essentials.modify_entry(file_name, input, exact, replace_text, yield)
		if utils.file_exists(home..file_name) then
			if essentials.search_for_match_and_get_line(file_name, input, exact, yield) then
				local rand = "temp_"..math.random(1, 2^62)..".log"
				local file = io.open(kek_menu_stuff_path.."kekMenuData\\"..rand, "w+")
				local input_count = #input
				if not file then
					essentials.log_error("Failed to open file despite it existing.")
					return 3
				end
				for line in essentials.get_file_string(file_name, "*a"):gmatch("([^\n]*)\n?") do
					for i = 1, input_count do
						if not replace_text and (line == input[i] or (not exact and line:find(input[i], 1, true))) then
							goto skip
						elseif replace_text and i // 2 ~= i / 2 and (line == input[i] or (not exact and line:find(input[i], 1, true))) then
							file:write(input[i + 1].."\n")
							goto skip
						end
					end
					file:write(line.."\n")
					::skip::;
				end
				essentials.file(file, "flush")
				essentials.file(file, "close")
				local file = io.open(home..file_name, "w+")
				essentials.file(file, "write", essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\"..rand, "*a"))
				essentials.file(file, "close")
				io.remove(kek_menu_stuff_path.."kekMenuData\\"..rand)
				return 1
			else
				return 2
			end
		else
			essentials.log_error("Couldn't modify file, it doesn't exist: "..file_name)
			return 3
		end
	end

return essentials