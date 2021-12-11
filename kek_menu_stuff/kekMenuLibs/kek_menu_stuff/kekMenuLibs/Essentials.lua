-- Copyright © 2020-2021 Kektram

local essentials <const> = {version = "1.3.4"}

local language <const> = require("Language")
local lang <const> = language.lang
local enums <const> = require("Enums")
local settings <const> = require("Settings")

do 
--[[
	This sets the __close metamethod for all files.
	When local variables storing a file object goes out of scope,
	the file is automatically closed with this metamethod.
--]]
	local file <close> = io.open(debug.getinfo(1).source:sub(2, -1))
	assert(io.type(file) == "file", "Failed to get file metatable.")
	getmetatable(file).__close = function(file)
		if io.type(file) == "file" then
			file:close()
		end
	end
end

essentials.listeners = {
	player_leave = {},
	player_join = {},
	chat = {},
	exit = {}
}
essentials.nethooks = {}
essentials.feats = {}
essentials.player_feats = {}

local home <const> = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"
local kek_menu_stuff_path <const> = home.."scripts\\kek_menu_stuff\\"

essentials.new_session_timer = utils.time_ms()
do
	local my_pid = player.player_id()
	essentials.listeners["player_leave"]["timer"] = event.add_event_listener("player_leave", function(event)
		if my_pid == event.player then
			essentials.new_session_timer = utils.time_ms() + 15000
			my_pid = player.player_id()
		end
	end)
end

--[[
	These functions replicates exactly what the originals did with one exception; they won't work on protected metatables.
	A protected metatable have its __metatable set to something that isn't nil.
--]]
function essentials.rawset(...)
	local Table <const>, 
	index <const>, 
	value <const> = ...
	local metatable <const> = getmetatable(Table)
	local __newindex
	if metatable then
		__newindex = metatable.__newindex
		metatable.__newindex = nil
	end
	Table[index] = value
	if __newindex then
		metatable.__newindex = __newindex
	end
end

function essentials.rawget(...)
	local Table <const>,
	index <const> = ...
	local __index
	local metatable <const> = getmetatable(Table)
	if metatable then
		__index = metatable.__index
		metatable.__index = nil
	end
	local value <const> = Table[index]
	if metatable then
		metatable.__index = __index
	end
	return value
end

function essentials.assert(bool, msg)
	if not bool then
		essentials.log_error(msg)
		error(msg)
	end
end

function essentials.delete_feature(id)
	essentials.assert(essentials.feats[id], "Tried to delete a feature that was already deleted.")
	essentials.assert(menu.delete_feature(id), "Failed to delete feature.")
	essentials.feats[id] = nil
	return true
end

function essentials.delete_player_feature(id)
	essentials.assert(essentials.player_feats[id], "Attempted to delete player feature that was already deleted.")
	essentials.assert(menu.delete_player_feature(id), "Failed to delete player feature.")
	essentials.player_feats[id] = nil
	return true
end

do
	local originals <const> = {
		add_feature = menu.add_feature,
		add_player_feature = menu.add_player_feature,
		menu_newindex = getmetatable(menu).__newindex
	}
	getmetatable(menu).__newindex = nil

	menu.add_feature = function(...)
		local name <const>,
		Type <const>,
		parent <const>,
		func <const> = ...
		local feat
		if type(func) == "function" then
			feat = originals.add_feature(name, Type, parent, function(f, data)
				if type(f) == "userdata" and func(f, data) == HANDLER_CONTINUE then
					return HANDLER_CONTINUE
				end
			end)
		else
			feat = originals.add_feature(name, Type, parent)
		end
		essentials.assert(feat, "Failed to create feature: "..tostring(name))
		essentials.feats[feat.id] = feat
		return feat
	end
	menu.add_player_feature = function(...)
		local name <const>,
		Type <const>,
		parent <const>,
		func <const> = ...
		local feat
		if type(func) == "function" then
			feat = originals.add_player_feature(name, Type, parent, function(f, pid, data)
				if type(f) == "userdata" and func(f, pid, data) == HANDLER_CONTINUE then
					return HANDLER_CONTINUE
				end
			end)
		else
			feat = originals.add_player_feature(name, Type, parent)
		end
		essentials.assert(feat, "Failed to create player feature: "..tostring(name))
		essentials.player_feats[feat.id] = feat.id
		return feat
	end
	getmetatable(menu).__newindex = originals.menu_newindex
end

function essentials.const(Table)
	essentials.assert(not getmetatable(Table) or getmetatable(Table).__is_const, "Tried to overwrite the metatable while changing the table to const.")
	if not getmetatable(Table) or not getmetatable(Table).__is_const then
		return setmetatable({}, {
			__is_const = true,
			__index = setmetatable(Table, {__index = function(Table, index)
				if index == nil then
					error(debug.traceback("Index is nil.", 2))
				end
				return essentials.rawget(Table, index)
			end}),
			__newindex = function()
				error(debug.traceback("Tried to modify a read-only table.", 2))
			end,
			__pairs = function(Table)
				return next, getmetatable(Table).__index
			end,
			__len = function(Table)
				return #getmetatable(Table).__index
			end,
		})
	else
		return Table
	end
end

function essentials.const_all(Table)
	for key, value in pairs(Table) do
		if type(value) == "table" then
			essentials.rawset(Table, key, essentials.const_all(value))
		end
	end
	return essentials.const(Table)
end

function essentials.deep_copy(Table, keep_meta, seen)
	local new_copy <const> = {}
	seen = seen or {}
	for key, value in pairs(Table) do
		if type(value) == "table" then
			essentials.assert(not seen[value], "Tried to deep copy a table with a reference to itself.")
			seen[value] = true
			new_copy[key] = essentials.deep_copy(value, keep_meta, seen)
			if keep_meta and type(getmetatable(value)) == "table" then
				essentials.assert(not seen[getmetatable(value)], "Tried to deep copy a table with a reference to one of its own member's metatable.")
				seen[getmetatable(value)] = true
				setmetatable(new_copy[key], essentials.deep_copy(getmetatable(value), true, seen))
			end
		else
			new_copy[key] = value
		end
	end
	if keep_meta and type(getmetatable(Table)) == "table" then
		essentials.assert(not seen[getmetatable(Table)], "Tried to deep copy a table with a reference to its own metatable.")
		seen[getmetatable(Table)] = true
		setmetatable(new_copy, essentials.deep_copy(getmetatable(Table), true, seen))
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

essentials.FEATURE_ID_MAP = essentials.const({ -- The table keys are derived from the Feat.type property.
	-- Regular types --
	[512]   = "action",
	[1]     = "toggle",
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
	-- Regular types --

	[2048]  = "parent", -- Both player and regular feats .type returns 2048

	-- Player types --
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
	-- Player types --
})

function essentials.get_safe_feat_name(...)
	local name = ...
	local pattern <const> = name:gsub("[A-Za-z0-9%s%p]", "")
	if #pattern > 0 then
		name = name:gsub("["..pattern.."]", "")
	end
	return name
end

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

local last_error_time = 0
local last_error = ""
function essentials.log_error(...)
	local str <const>, yield <const>, file_path = ...
	file_path = file_path or kek_menu_stuff_path.."kekMenuLogs\\kek_menu_log.log"
	if utils.time_ms() > last_error_time and last_error ~= debug.traceback(str, 2) then
		last_error_time = utils.time_ms() + 100
		last_error = debug.traceback(str, 2)
		local file <close> = io.open(file_path, "a+")
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
		local header = ""
		if __kek_menu_version then
			header = " [Kek's menu version: "..__kek_menu_version.."]"
		end
		file:write(debug.traceback("["..os.date().."]: "..str..header, 2)..additional_info)
	end
	if yield then
		system.yield(0)
	end
end

function essentials.is_z_coordinate_correct(pos)
	return pos.z ~= -50 and pos.z ~= -180 and pos.z ~= -190
end

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

function essentials.msg(...)
	local text <const>,
	color <const>,
	notifyOn <const>,
	duration <const>,
	header = ...
	essentials.assert(type(text) == "string" and math.type(color) == "integer", "Failed to send a notification.")
	if notifyOn then
		header = header or ""
		if header == "" and __kek_menu_version then
			header = "Kek's "..__kek_menu_version
		end
		menu.notify(text, header, duration or 3, color)
	end
end

function essentials.is_in_vehicle(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	return player.is_player_in_any_vehicle(pid) or player.get_player_coords(pid).z == -50
end

--[[
	The purpose of counting and limiting the ptfx is to prevent crashes.
	Spamming ptfx will always lead to a crash.
--]]
essentials.ptfx_in_use = {}
local function ptfx_count()
	repeat
		local status = true
		for i = 1, #essentials.ptfx_in_use do
			if utils.time_ms() > essentials.ptfx_in_use[i] then
				table.remove(essentials.ptfx_in_use, i)
				status = false
				break
			end
		end
	until status
	return #essentials.ptfx_in_use <= 180
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

local ptfx_cost_exceptions <const> = essentials.const({
	[gameplay.shoot_single_bullet_between_coords] = 1000,
	[graphics.start_networked_ptfx_looped_on_entity] = 6000
})

function essentials.use_ptfx_function(func, ...)
	local func <const> = func
	if ptfx_count() then
		essentials.ptfx_in_use[#essentials.ptfx_in_use + 1] = utils.time_ms() + (ptfx_cost_exceptions[func] or 3000)
		return func(...)
	end
end

function essentials.is_not_friend(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	return not settings.toggle["Exclude friends from attacks #malicious#"].on or not network.is_scid_friend(player.get_player_scid(pid))
end

function essentials.get_most_relevant_entity(...)
	local pid <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	if player.is_player_in_any_vehicle(pid) then
		return player.get_player_vehicle(pid)
	else
		return player.get_player_ped(pid)
	end
end

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

function essentials.get_index_of_value(...)
	local Table <const>, value_to_find_index_of <const> = ...
	for i, value in pairs(Table) do
		if value_to_find_index_of == value then
			return i
		end
	end
end

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

do
	local special_char_map <const> = {
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
	}
	
	function essentials.remove_special(text)
		local str <const> = text:gsub("[%%%[%]%(%)%-%+%?%*%^%$%.]", special_char_map)
		return str
	end
end

function essentials.get_file_string(...)
	local path <const>,
	type <const>,
	not_wait <const> = ...
	local file <close> = io.open(home..path)
	return essentials.file(file, "read", type) or ""
end

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

function essentials.get_ped_closest_to_your_pov()
	local spectate_target <const> = network.get_player_player_is_spectating(player.player_id())
	if spectate_target then
		return player.get_player_ped(spectate_target)
	else
		return player.get_player_ped(player.player_id())
	end
end

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

function essentials.is_player_completely_valid(pid)
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	return player.is_player_valid(pid)
	and not player.is_player_modder(pid, -1) 
	and player.is_player_playing(pid)
	and entity.is_an_entity(player.get_player_ped(pid))
	and essentials.is_z_coordinate_correct(player.get_player_coords(pid))
	and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0 
end

function essentials.is_any_true(...)
	local Table <const>, conditions <const> = ...
	for i = 1, #Table do
		if conditions(Table[i]) then
			return true
		end
	end
	return false
end

function essentials.is_all_true(...)
	local Table <const>, conditions <const> = ...
	for i = 1, #Table do
		if not conditions(Table[i]) then
			return false
		end
	end
	return true
end

function essentials.round(...)
	local num <const> = ...
	local floor <const> = math.floor(num)
	if floor >= num - 0.4999999999 then
		return floor
	else
		return math.ceil(num)
	end
end

function essentials.get_random_offset(...)
	local min_random_range <const>,
	max_random_range <const>,
	min_magnitude <const>,
	max_magnitude <const> = ...
	essentials.assert(max_random_range * 0.8 >= min_random_range, "Max random range must be at least 20% bigger than min random range.")
	essentials.assert(max_magnitude * 0.8 > min_magnitude, "Max magnitude must be at least 20% bigger than min magnitude.")
	essentials.assert(max_magnitude > 0 and min_magnitude > 0, "Min and max magnitude must be a positive number.")
	local min_absolute_number = min_random_range
	if min_absolute_number < 0 and max_random_range > 0 then
		min_absolute_number = 0
	elseif min_absolute_number < 0 and max_random_range < 0 then
		min_absolute_number = math.abs(math.max(min_random_range, max_random_range))
	end
	local max_absolute_number <const> = math.max(math.abs(min_random_range), math.abs(max_random_range))
	essentials.assert(
		v3(
			min_absolute_number,
			min_absolute_number,
			0
		):magnitude() < max_magnitude * 0.8,
		"Min random range is too big."
	)
	essentials.assert(
		v3(
			max_absolute_number, 
			max_absolute_number, 
			0
		):magnitude() > min_magnitude * 1.2, 
		"Max random range is too small."
	)
	local offset
	repeat 
	--[[
		Any combination of arguments that could cause infinite loop will raise error.
		The random range is required to be reasonable and will raise error if it's too small.
	--]]
		offset = v3(
			essentials.random_real(min_random_range, max_random_range),
			essentials.random_real(min_random_range, max_random_range), 
			0
		)
		local dist <const> = offset:magnitude()
	until dist >= min_magnitude and dist <= max_magnitude
	return offset
end

function essentials.random_real(...)
	local a, b <const> = ...
	local power <const> = math.min(18 - #tostring(a), 17 - #tostring(b))
	a = math.random(a * 10^power, b * 10^power)
	return a / 10^power
end

function essentials.random_wait(...)
	local range <const> = ...
	essentials.assert(math.type(range) == "integer" and range > 0, "Random wait range must be bigger than 0.")
	if math.random(1, range) == 1 then
		system.yield(0)
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

function essentials.dec_to_ipv4(...)
	local ip <const> = ...
	essentials.assert(math.type(ip) == "integer", "Tried to convert non integer value to ipv4 address.")
	return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
end

function essentials.ipv4_to_dec(...)
	local ip <const> = ...
	essentials.assert(ip:find(".", 1, true), "Tried to convert decimal ip to decimal ip.")
	local dec = 0
	for octet in ip:gmatch("%d+") do 
		dec = octet + dec << 8 
	end
	return math.ceil(dec)
end

function essentials.search_for_match_and_get_line(...)
	local file_name <const>,
	search <const>,
	exact <const>, -- Whether the existing text check must be identical to an entire line or a substring of a line.
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

do
	local ad_strings <const> = essentials.const({
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
end

function essentials.log(...)
	local file_name <const>,
	text_to_log <const>,
	search <const>, -- Whether to check if text_to_log appears in the file already or not
	exact <const>, -- Whether the existing text check must be identical to an entire line or a substring of a line.
	yield <const> = ... -- Whether to yield every 500th line of checking if text exists in file or not
	if search then
		local str <const> = essentials.search_for_match_and_get_line(file_name, search, exact, yield)
		if str then
			return str
		end
	end
	local file <close> = io.open(home..file_name, "a+")
	essentials.file(file, "write", text_to_log.."\n")
end

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
			essentials.msg(lang[parts[Type][i]], 6, true, 12)
			break
		end
	end
end

--[[
	Checks if a string can be used with regex functions.
	Warns if string contains special characters that has an other meaning in patterns.
--]]
function essentials.invalid_pattern(...)
	local text <const>,
	msg <const>,
	warn <const> = ...
	if warn then
		if text:find("[%.%+%-%*%?%^%$]") and not text:find("%%[%.%+%-%*%?%^%$]") then
			essentials.msg(lang["Warning: missing \"%\" before any of these characters; §"].." \".\", \"+\", \"-\", \"*\", \"?\", \"^\", \"$\".\n"..lang["This is fine, just note that if you don't put the \"%\" before those characters, they mean something else. §"], 6, true, 12)
		end
	end
	local status <const> = pcall(function() 
		return text:find(text)
	end)
	if not status then
		essentials.msg(lang["Invalid pattern. Most likely missing a \"[\", \"]\", \"(\", \")\" or a \"%\" somewhere. Could also be \"[]\", having \"[]\" causes an error. §"], 6, msg, 12)
		return true
	end
end

function essentials.merge_tables(...)
	local parent_table, children_tables <const> = ...
	for _, children_table in pairs(children_tables) do
		table.move(children_table, 1, #children_table, #parent_table + 1, parent_table)
	end
	return parent_table
end

function essentials.modify_entry(...)
	local file_name <const>,
	input <const>,
	exact <const>, -- Whether the existing text check must be identical to an entire line or a substring of a line.
	replace_text <const>, -- Whether to replace a set of lines with a set of other lines or not
	yield <const> = ... -- Whether to yield every 500th line of checking if text exists in file or not
	if utils.file_exists(home..file_name) then
		if essentials.search_for_match_and_get_line(file_name, input, exact, yield) then -- Checks if input already exists in the file
			local random_file_name <const> = "temp_"..math.random(1, 2^62)..".log"
			local file = io.open(kek_menu_stuff_path.."kekMenuData\\"..random_file_name, "w+")
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
			essentials.file(file, "close")
			local file <close> = io.open(home..file_name, "w+")
			essentials.file(file, "write", essentials.get_file_string("scripts\\kek_menu_stuff\\kekMenuData\\"..random_file_name, "*a"))
			io.remove(kek_menu_stuff_path.."kekMenuData\\"..random_file_name)
			return 1 -- Success
		else
			return 2 -- Didn't find entry to modify
		end
	else
		essentials.log_error("Couldn't modify file, it doesn't exist: "..file_name)
		return 3 -- File doesnt exist
	end
end

return essentials