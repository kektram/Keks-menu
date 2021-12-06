-- Copyright © 2020-2021 Kektram

kek_menu.lib_versions["Essentials"] = "1.3.3"

local essentials <const> = {}
local key_mapper <const> = kek_menu.require("Key mapper")
local enums <const> = kek_menu.require("Enums")

local home <const> = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"
local kek_menu_stuff_path <const> = home.."scripts\\kek_menu_stuff\\"

function essentials.assert(bool, msg)
	if not bool then
		essentials.log_error(msg)
		error(msg)
	end
end

function essentials.deep_copy(Table, keep_meta)
	local new_copy <const> = {}
	for key, value in pairs(Table) do
		if type(value) == "table" then
			new_copy[key] = essentials.deep_copy(value, keep_meta)
		else
			new_copy[key] = value
		end
	end
	if keep_meta then
		setmetatable(new_copy, getmetatable(Table))
	end
	return new_copy
end

function essentials.players(...)
	local dont_ignore_me <const> = ...
	local pid, me = -1
	if not dont_ignore_me then
		me = player.player_id()
	end
	return function()
		if pid < 31 then
			local is_valid
			repeat
				pid = pid + 1
				is_valid = player.is_player_valid(pid) and (dont_ignore_me or me ~= pid)
			until pid == 31 or is_valid
			if is_valid then
				return pid
			end
		end
	end
end

-- Feature type ids
	essentials.FEATURE_ID_MAP = table.const({
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
	})

-- Is feature name valid
	function essentials.get_safe_feat_name(...)
		local name = ...
		local pattern <const> = name:gsub("[A-Za-z0-9%s%p]", "")
		if #pattern > 0 then
			name = name:gsub("["..pattern.."]", "")
		end
		return name
	end

-- Interact with file
	function essentials.file(...)
		local file <const>,
		Type <const>,
		str <const> = ...
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
						local file_string <const> = essentials.get_file_string(file, "*a")
						io.remove(home..file)
						local file <close> = io.open(home..str, "w+")
						essentials.file(file, "write", file_string)
						essentials.file(file, "flush")
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
		local duration <const> = duration
		local func <const> = func
		essentials.assert(duration > 0, "Duration must be longer than 0.")
		local time <const> = utils.time_ms() + duration
		repeat
			system.yield(0)
		until not func(...) or utils.time_ms() > time
	end

-- Write xml
	function essentials.write_xml(...)
		local file <const>,
		Table <const>,
		tabs <const>,
		name <const> = ...
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
	function essentials.log_error(...)
		local str <const>, yield <const> = ...
		if utils.time_ms() > last_error_time and last_error ~= debug.traceback(str, 2) then
			last_error_time = utils.time_ms() + 100
			last_error = debug.traceback(str, 2)
			local file <close> = io.open(kek_menu_stuff_path.."kekMenuLogs\\kek_menu_log.log", "a+")
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
						local name <const>, value <const> = debug.getlocal(i2, i)
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
		end
		if yield then
			system.yield(0)
		end
	end

	function essentials.is_z_coordinate_correct(pos)
		return pos.z ~= -50 and pos.z ~= -180 and pos.z ~= -190
	end

-- Get randomized string
	function essentials.get_random_string(...)
		local rand_min <const>,
		rand_max <const>,
		max <const> = ...
		local vecu64_table <const> = {}
		for i = 1, math.random(rand_min or 1, rand_max or 12) do
			vecu64_table[#vecu64_table + 1] = math.random(1, max or math.maxinteger)
		end
		return utils.vecu64_to_str(vecu64_table)
	end

-- Messager function
	function essentials.msg(...)
		local text <const>,
		color <const>,
		notifyOn <const>,
		duration <const> = ...
		essentials.assert(type(text) == "string" and math.type(color) == "integer", "Failed to send a notification.")
		if notifyOn then
			menu.notify(text, "Kek's "..kek_menu.version, duration or 3, color)
		end
	end

-- Is player in vehicle
	function essentials.is_in_vehicle(pid)
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return player.is_player_in_any_vehicle(pid) or player.get_player_coords(pid).z == -50
	end

-- Request ptfx
	local function ptfx_count()
		repeat
			local status = true
			for i = 1, #kek_menu.ptfx do
				if utils.time_ms() > kek_menu.ptfx[i] then
					table.remove(kek_menu.ptfx, i)
					status = false
					break
				end
			end
		until status
		return #kek_menu.ptfx <= kek_menu.PTFX_LIMIT
	end
	function essentials.request_ptfx(...)
		local str_asset <const> = ...
		if ptfx_count() then
			graphics.request_named_ptfx_asset(str_asset)
			local time <const> = utils.time_ms() + 400
			while not graphics.has_named_ptfx_asset_loaded(str_asset) and time > utils.time_ms() do
				system.yield(0)
			end
			if graphics.has_named_ptfx_asset_loaded(str_asset) then
				graphics.set_next_ptfx_asset(str_asset)
				return true
			end
		end
	end

	local ptfx_cost_exceptions <const> = table.const({
		[gameplay.shoot_single_bullet_between_coords] = 1000,
		[graphics.start_networked_ptfx_looped_on_entity] = 6000
	})

	function essentials.use_ptfx_function(func, ...)
		local func <const> = func
		if ptfx_count() then
			kek_menu.ptfx[#kek_menu.ptfx + 1] = utils.time_ms() + (ptfx_cost_exceptions[func] or 3000)
			return func(...)
		end
	end

-- Is friend
	function essentials.is_not_friend(pid)
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return not kek_menu.toggle["Exclude friends from attacks #malicious#"].on or not network.is_scid_friend(player.get_player_scid(pid))
	end

-- Get most relevant player entity
	function essentials.get_most_relevant_entity(...)
		local pid <const> = ...
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
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
	function essentials.send_message(...)
		local text, team <const> = ...
		if number_of_active_messages > 30 then
			return
		end
		essentials.assert(type(text) == "string", "Tried to send a chat message with a non string value")
		number_of_active_messages = number_of_active_messages + 1
		local time <const> = utils.time_ms() + 2000
		repeat
			system.yield(0)
		until utils.time_ms() > last_message_sent or utils.time_ms() > time
		if time > utils.time_ms() then
			local time <const> = utils.time_ms() + 5000
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

-- Get index of table value
	function essentials.get_index_of_value(...)
		local Table <const>, value_to_find_index_of <const> = ...
		for i, value in pairs(Table) do
			if value_to_find_index_of == value then
				return i
			end
		end
	end

-- Get random player except
	function essentials.get_random_player_except(...)
		local exclusions <const> = ...
		local pids <const> = {}
		for pid in essentials.players(true) do
			if not essentials.get_index_of_value(exclusions, pid) then
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
do
	local special_char_map <const> = table.const({
		["%"] = "%%",
		["["] = "%[",
		["]"] = "%]",
		["("] = "%(",
		[")"] = "%)",
		["-"] = "%-",
		["+"] = "%+",
		["?"] = "%?",
		["*"] = "%*",
		["^"] = "%^",
		["$"] = "%$",
		["."] = "%."
	})

	function essentials.remove_special(text)
		local str <const> = text:gsub("[%%%[%]%(%)%-%+%?%*%^%$%.]", special_char_map)
		return str
	end
end

-- File open-read-close
	function essentials.get_file_string(...)
		local path <const>,
		type <const>,
		not_wait <const> = ...
		local file <close> = io.open(home..path)
		return essentials.file(file, "read", type) or ""
	end

-- Search for file
	function essentials.get_file(...)
		local path <const>,
		file_extension <const>,
		str <const> = ...
		for _, file_name in pairs(utils.get_all_files_in_directory(home..path, file_extension)) do
			if file_name ~= "autoexec.lua" and file_name:lower():find(str:lower(), 1, true) then
				return home..path..file_name, file_name
			end
		end
		return "", ""
	end

-- Get a parent's decendants
	function essentials.get_descendants(...)
		local parent <const>,
		Table,
		add_parent_of_descendants <const> = ...
		for _, feat in pairs(parent.children) do
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
	function essentials.get_player_descendants(...)
		local parent <const>,
		Table,
		add_parent_of_descendants <const> = ...
		for _, feat in pairs(parent.feats[0].children) do
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
	function essentials.name_to_pid(...)
		local name = ...
		if type(name) == "string" then
			name = name:lower()
			for pid in essentials.players(true) do
				if player.get_player_name(pid):lower():find(name, 1, true) then
					return pid
				end
			end
		end
		return 32
	end

-- Get ped depending on spectate
	function essentials.get_ped_closest_to_your_pov()
		local spectate_target <const> = network.get_player_player_is_spectating(player.player_id())
		if spectate_target then
			return player.get_player_ped(spectate_target)
		else
			return player.get_player_ped(player.player_id())
		end
	end

-- Distance between 2 entities
	function essentials.get_distance_between(...)
		local entity_or_position_1, 
		entity_or_position_2 = ...
		if math.type(entity_or_position_1) == "integer" then
			entity_or_position_1 = entity.get_entity_coords(entity_or_position_1)
		end
		if math.type(entity_or_position_2) == "integer" then 
			entity_or_position_2 = entity.get_entity_coords(entity_or_position_2)
		end
		return entity_or_position_1:magnitude(entity_or_position_2)
	end

-- Check if player is valid
	function essentials.is_player_completely_valid(pid)
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return player.is_player_valid(pid)
		and not player.is_player_modder(pid, -1) 
		and player.is_player_playing(pid)
		and entity.is_an_entity(player.get_player_ped(pid))
		and essentials.is_z_coordinate_correct(player.get_player_coords(pid))
		and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 
	end

-- Is any true
	function essentials.is_any_true(...)
		local Table <const>, conditions <const> = ...
		for i = 1, #Table do
			if conditions(Table[i]) then
				return true
			end
		end
		return false
	end

-- Is all true
	function essentials.is_all_true(...)
		local Table <const>, conditions <const> = ...
		for i = 1, #Table do
			if not conditions(Table[i]) then
				return false
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
	function essentials.round(...)
		local num <const> = ...
		local floor <const> = math.floor(num)
		if floor >= num - 0.4999999999 then
			return floor
		else
			return math.ceil(num)
		end
	end

-- Get pos with minimum offset 
	function essentials.get_offset(...)
		local pos <const>,
		a <const>,
		b <const>,
		min <const>,
		max <const> = ...
		local offset
		for i = 1, 150 do
			offset = v3(essentials.random_real(a, b), essentials.random_real(a, b), 0)
			local dist <const> = offset:magnitude()
			if dist >= min and dist <= max then
				return offset
			end
		end
		return offset
	end

-- Get random real
	function essentials.random_real(...)
		local a, b <const> = ...
		local power <const> = math.min(18 - #tostring(a), 17 - #tostring(b))
		a = math.random(a * 10^power, b * 10^power)
		return a / 10^power
	end

-- Random wait for intense loops
	function essentials.random_wait(...)
		local range <const> = ...
		essentials.assert(math.type(range) == "integer" and range > 0, "Random wait range must be bigger than 0.")
		if math.random(1, range) == 1 then
			system.yield(0)
		end
	end 

-- Input function
	function essentials.get_input(...)
		local title <const>,
		default <const>,
		len <const>,
		Type <const> = ...
		essentials.assert(math.type(len) == "integer"
		and math.type(Type) == "integer"
		and type(title) == "string",
			"Invalid arguments to get_input.")
		local Keys <const> = table.const(key_mapper.get_virtual_key_of_2take1_bind("MenuSelect"))
		key_mapper.do_vk(10000, Keys)
		local input_status, text = nil, ""
		repeat
			input_status, text = input.get(title, default or "", len, Type)
			system.yield(0)
		until input_status ~= 1
		key_mapper.do_vk(10000, Keys)
		if not text or input_status == 2 then
			essentials.msg(kek_menu.lang["Cancelled. §"], 6, true)
			return "", 2
		else
			return text, 0
		end
	end

-- Slider I/O
	function essentials.value_i_setup(...)
		local feature,
		input_title <const>,
		input_type <const> = ...
		local input <const>, status <const> = essentials.get_input(input_title, "", #tostring(feature.max), input_type or 3)
		if status == 2 then
			return
		end
		local value <const> = tonumber(input)
		essentials.assert(type(value) == "number", "Attempt to change value property to a non number value.")
		if value <= feature.min then
			feature.value = feature.min
		elseif feature.max >= value then
			feature.value = value
		else
			feature.value = feature.max
		end
	end

	function essentials.set_all_player_feats_except(...)
		local player_feat_id <const>,
		bool <const>,
		exclusions <const> = ...
		for pid = 0, 31 do
			if not essentials.get_index_of_value(exclusions, pid) then
				menu.get_player_feature(player_feat_id).feats[pid].on = bool == true
			end
		end
	end

-- Dec to ipv4
	function essentials.dec_to_ipv4(...)
		local ip <const> = ...
		essentials.assert(math.type(ip) == "integer", "Tried to convert non integer value to ipv4 address.")
		return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
	end

-- Ipv4 to dec
	function essentials.ipv4_to_dec(...)
		local ip <const> = ...
		essentials.assert(ip:find(".", 1, true), "Tried to convert decimal ip to decimal ip.")
		local dec = 0
		for octet in ip:gmatch("%d+") do 
			dec = octet + dec << 8 
		end
		return math.ceil(dec)
	end

-- Search for match in file
	function essentials.search_for_match_and_get_line(...)
		local file_name <const>,
		search <const>,
		exact <const>,
		yield <const> = ...
		local str <const> = essentials.get_file_string(file_name, "*a")
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
	local ad_strings <const> = table.const({
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
	})
	function essentials.contains_advert(...)
		local str <const> = ...
		for i = 1, #ad_strings do
			if str:find(ad_strings[i], 1, true) then
				return true
			end
		end
	end

-- Log / check if already in file
	function essentials.log(...)
		local file_name <const>,
		text_to_log <const>,
		search <const>,
		exact <const>,
		yield <const> = ...
		if search then
			local str <const> = essentials.search_for_match_and_get_line(file_name, search, exact, yield)
			if str then
				return str
			end
		end
		local file <close> = io.open(home..file_name, "a+")
    	essentials.file(file, "write", text_to_log.."\n")
    end

-- Add to join timeout
	function essentials.add_to_timeout(...)
		local pid <const> = ...
		essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
		essentials.log("cfg\\scid.cfg", player.get_player_name(pid)..":"..select(1, string.format("%x", player.get_player_scid(pid)))..":c", {select(1, string.format("%x", player.get_player_scid(pid))), player.get_player_name(pid)}, false, true)
	end

	function essentials.send_pattern_guide_msg(...)
		local part <const>, Type <const> = ...
		local parts <const> = {
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

    function essentials.invalid_pattern(...)
    	local text <const>,
    	msg <const>,
    	warn <const> = ...
    	if warn then
    		if text:find("[%.%+%-%*%?%^%$]") and not text:find("%%[%.%+%-%*%?%^%$]") then
    			essentials.msg(kek_menu.lang["Warning: missing \"%\" before any of these characters; §"].." \".\", \"+\", \"-\", \"*\", \"?\", \"^\", \"$\".\n"..kek_menu.lang["This is fine, just note that if you don't put the \"%\" before those characters, they mean something else. §"], 6, true, 12)
    		end
    	end
    	local status <const> = pcall(function() 
			return text:find(text)
		end)
		if not status then
			essentials.msg(kek_menu.lang["Invalid pattern. Most likely missing a \"[\", \"]\", \"(\", \")\" or a \"%\" somewhere. Could also be \"[]\", having \"[]\" causes an error. §"], 6, msg, 12)
			return true
		end
    end

-- Merge tables 
	function essentials.merge_tables(...)
		local parent_table, children_tables <const> = ...
		for _, children_table in pairs(children_tables) do
			table.move(children_table, 1, #children_table, #parent_table + 1, parent_table)
		end
		return parent_table
	end

-- Remove / replace a value from file
	function essentials.modify_entry(...)
		local file_name <const>,
		input <const>,
		exact <const>,
		replace_text <const>,
		yield <const> = ...
		if utils.file_exists(home..file_name) then
			if essentials.search_for_match_and_get_line(file_name, input, exact, yield) then
				local random_file_name <const> = "temp_"..math.random(1, 2^62)..".log"
				local file <close> = io.open(kek_menu_stuff_path.."kekMenuData\\"..random_file_name, "w+")
				local input_len <const> = #input
				if io.type(file) ~= "file" then
					essentials.log_error("Failed to open file despite it existing.")
					return 3
				end
				for line in essentials.get_file_string(file_name, "*a"):gmatch("([^\n]*)\n?") do
					for i = 1, input_len do
						if not replace_text and (line == input[i] or (not exact and line:find(input[i], 1, true))) then
							goto skip
						elseif replace_text and i // 2 ~= i / 2 and (line == input[i] or (not exact and line:find(input[i], 1, true))) then
							file:write(input[i + 1].."\n")
							goto skip
						end
					end
					file:write(line.."\n")
					::skip::
				end
				essentials.file(file, "flush")
				local file <close> = io.open(home..file_name, "w+")
				essentials.file(file, "write", essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\"..random_file_name, "*a"))
				io.remove(kek_menu_stuff_path.."kekMenuData\\"..random_file_name)
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