-- Copyright © 2020-2021 Kektram

local essentials <const> = {version = "1.3.8"}

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

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"

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

function essentials.assert(bool, msg, ...)
	if not bool then
		local format_str <const> = {msg, ...}
		for i = 1, #format_str do
			format_str[i] = tostring(format_str[i])
		end
		msg = string.format(table.concat(format_str, ", "), ...)
		print(debug.traceback(msg, 2))
		menu.notify(debug.traceback(msg, 2), "Error", 6, 0xff0000ff)
		essentials.log_error(msg)
		error(debug.traceback(msg, 2))
	end
end

--[[
	Why would you store numbers this way? [Refering to incoming functions]
	It's far cheaper. A table with 3 (not enumerated) items will take up roughly 112 bytes. [https://wowwiki-archive.fandom.com/wiki/Lua_object_memory_sizes]
	Packing numbers can save over 100 bytes per table. One 64 bit number takes up 8 bytes.
	Now, accessing values from these packed numbers will be more expensive. 17x slower. However, we're talking 9 million accesses in 1 second vs 153 million.
	The spared memory far outweighs the lost performance. The packing of numbers is about 60% slower than creating a table. [9.4 million in one sec vs 4.3 million]
	Another use case is mapping multiple numbers to one index.
--]]
do 
	local sign_bit_x <const> = 1 << 62
	local sign_bit_y <const> = 1 << 61
	local sign_bit_z <const> = 1 << 60
	local max_20_bit_num <const> = 1048575
	function essentials.pack_3_nums(x, y, z)
        local xi = x * 100 // 1
        local yi = y * 100 // 1
        local zi = z * 100 // 1
		essentials.assert(
			xi >= -max_20_bit_num 
			and xi <= max_20_bit_num 
			and yi >= -max_20_bit_num 
			and yi <= max_20_bit_num 
			and zi >= -max_20_bit_num
			and zi <= max_20_bit_num, "Number is too big to be packed.",
			x, y, z
		)

		local signs = 0
		if xi < 0 then
			xi = xi * -1
			signs = signs | sign_bit_x
		end
		if yi < 0 then
			yi = yi * -1
			signs = signs | sign_bit_y
		end
		if zi < 0 then
			zi = zi * -1
			signs = signs | sign_bit_z
		end
		return signs | xi << 40 | yi << 20 | zi
	end
end

do
	local sign_bit_x <const> = 1 << 62
	local sign_bit_y <const> = 1 << 61
	local max_30_bit_num <const> = 1073741823
	function essentials.pack_2_nums(x, y)
        local xi = x * 100 // 1
        local yi = y * 100 // 1
		essentials.assert(
			xi >= -max_30_bit_num 
			and xi <= max_30_bit_num 
			and yi >= -max_30_bit_num 
			and yi <= max_30_bit_num,
			"Number is too big to be packed.",
			x, y
		)

		local signs = 0
		if xi < 0 then
			xi = xi * -1
			signs = signs | sign_bit_x
		end
		if yi < 0 then
			yi = yi * -1
			signs = signs | sign_bit_y
		end
		return signs | xi << 30 | yi
	end
end

function essentials.unpack_3_nums(packed_num)
	local sign_bit_1, sign_bit_2, sign_bit_3 = 1, 1, 1
	if packed_num & 1 << 60 ~= 0 then sign_bit_1 = -1 end
	if packed_num & 1 << 61 ~= 0 then sign_bit_2 = -1 end
	if packed_num & 1 << 62 ~= 0 then sign_bit_3 = -1 end
	
	-- Clear sign bits
	packed_num = packed_num & (packed_num ~ (1 << 60))
	packed_num = packed_num & (packed_num ~ (1 << 61))
	packed_num = packed_num & (packed_num ~ (1 << 62))
	
	return
		(packed_num >> 40) / 100 * sign_bit_3,
		(packed_num << 24 >> 44) / 100 * sign_bit_2,
		(packed_num << 44 >> 44) / 100 * sign_bit_1
end

function essentials.unpack_2_nums(packed_num)
	local sign_bit_1, sign_bit_2 = 1, 1
	if packed_num & 1 << 61 ~= 0 then sign_bit_1 = -1 end
	if packed_num & 1 << 62 ~= 0 then sign_bit_2 = -1 end
	
	-- Clear sign bits
	packed_num = packed_num & (packed_num ~ (1 << 61))
	packed_num = packed_num & (packed_num ~ (1 << 62))
	
	return
		(packed_num >> 30) / 1000 * sign_bit_2,
		(packed_num << 34 >> 34) / 1000 * sign_bit_1
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

do
	local _ENV <const> = { -- 12% faster, 20% less garbage created
		essentials = essentials,
		getmetatable = getmetatable, 
		setmetatable = setmetatable, 
		assert = essentials.assert,
		__newindex = function()
			essentials.assert(false, "Tried to modify a read-only table.")
		end,
		__pairs = function(Table)
			return next, getmetatable(Table).__index
		end,
		__len = function(Table)
			return #getmetatable(Table).__index
		end
	}

	function essentials.const(Table)
		assert(not getmetatable(Table) or getmetatable(Table).__is_const, "Tried to overwrite a non-const metatable while changing the table to const.")
		if not getmetatable(Table) then
			return setmetatable({}, {
				__is_const = true,
				__index = Table,
				__newindex = __newindex,
				__pairs = __pairs,
				__len = __len
			})
		else
			return Table
		end
	end
end

function essentials.const_all(Table, seen)
	seen = seen or {}
	for key, value in pairs(Table) do
		essentials.assert(not seen[value], "Tried to set const_all to a table with a reference to itself.")
		if not seen[value] and type(value) == "table" then
			seen[value] = true
			essentials.rawset(Table, key, essentials.const_all(value, seen))
		end
	end
	return essentials.const(Table)
end

function essentials.make_string_case_insensitive(str)
    str = str:gsub("%a", function(str)
        return "["..str:lower()..str:upper().."]"
    end)
	return str
end

function essentials.split_string(str, size)
	local strings <const> = {}
	local pos = 1
	repeat
		strings[#strings + 1] = str:sub(pos, pos + size)
		pos = pos + size + 1
	until pos > #str
	return strings
end

function essentials.date_to_int(date)
	local day <const> = tonumber(date:match("^%d+/(%d+)/%d+$"))
	local month <const> = tonumber(date:match("^(%d+)/%d+/%d+$")) * 30
	local year <const> = tonumber(date:match("^%d+/%d+/(%d+)$")) * 365
	return day + month + year
end

function essentials.time_to_float(time)
    local hours <const> = tonumber(time:match("^(%d+):%d+:%d+$")) * 60^2
	local minutes <const> = tonumber(time:match("^%d+:(%d+):%d+$")) * 60
	local seconds <const> = tonumber(time:match("^%d+:%d+:(%d+)$"))
	return (hours + minutes + seconds) / (60^2 * 24)
end

function essentials.create_empty_file(file_path)
	essentials.assert(not utils.file_exists(file_path), "Tried to overwrite existing file:", file_path)
	local file <close> = io.open(file_path, "w+")
end

function essentials.are_all_lines_pattern_valid(str, pattern)
	local line_num = 1
	for line in str:gmatch(pattern) do
		if not pcall(function()
			return str:find(line)
		end) then
			return false, line_num
		end
		line_num = line_num + 1
	end
	return true
end

function essentials.delete_feature(id)
	essentials.assert(essentials.feats[id], "Tried to delete a feature that was already deleted.")
	essentials.assert(menu.delete_feature(id), "Failed to delete feature.", essentials.feats[id].name)
	essentials.feats[id] = nil
	return true
end

function essentials.delete_player_feature(id)
	essentials.assert(essentials.player_feats[id], "Attempted to delete player feature that was already deleted.")
	essentials.assert(menu.delete_player_feature(id), "Failed to delete player feature.", menu.get_player_feature(id).feats[0].name)
	essentials.player_feats[id] = nil
	return true
end

function essentials.delete_thread(id)
	essentials.assert(not menu.has_thread_finished(id) and menu.delete_thread(id), "Attempted to delete a finished thread.")
end

do
	local originals <const> = essentials.const({
		add_feature = menu.add_feature,
		add_player_feature = menu.add_player_feature,
		menu_newindex = getmetatable(menu).__newindex
	})
	getmetatable(menu).__newindex = nil

	menu.add_feature = function(...)
		local name <const>,
		Type <const>,
		parent <const>,
		func <const> = ...
		local feat
		local type <const> = type
		if type(func) == "function" then
			feat = originals.add_feature(name, Type, parent, function(f, data)
				if type(f) == "userdata" then
					if func(f, data) == HANDLER_CONTINUE then
						return HANDLER_CONTINUE
					end
				end
			end)
		else
			feat = originals.add_feature(name, Type, parent)
		end
		essentials.assert(feat, "Failed to create feature:", name)
		essentials.feats[feat.id] = feat
		return feat
	end
	menu.add_player_feature = function(...)
		local name <const>,
		Type <const>,
		parent <const>,
		func <const> = ...
		local feat
		local type <const> = type
		if type(func) == "function" then
			feat = originals.add_player_feature(name, Type, parent, function(f, pid, data)
				if type(f) == "userdata" then
					if func(f, pid, data) == HANDLER_CONTINUE then
						return HANDLER_CONTINUE
					end
				end
			end)
		else
			feat = originals.add_player_feature(name, Type, parent)
		end
		essentials.assert(feat, "Failed to create player feature:", name)
		essentials.player_feats[feat.id] = feat.id
		return feat
	end
	getmetatable(menu).__newindex = originals.menu_newindex
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

do
	local memoized <const> = {}
	function essentials.players(me)
		local pid = -1
		if not me then
			me = player.player_id()
		end
		if #memoized == 0 then
			local func
			func = function()
				repeat
					pid = pid + 1
				until pid == 32 or (me ~= pid and player.is_player_valid(pid))
				if pid ~= 32 then
					return pid
				end
				table.insert(memoized, func)
			end
			return func
		else
			local i <const> = #memoized
			local func <const> = memoized[i]
			table.remove(memoized, i)
			essentials.assert(debug.getupvalue(func, 2) == "me" and debug.setupvalue(func, 2, me), "FAILED TO SET UPVALUE")
			essentials.assert(debug.getupvalue(func, 1) == "pid" and debug.setupvalue(func, 1, -1), "FAILED TO SET UPVALUE")
			return func
		end
	end
end

do
	local memoized <const> = {}
	function essentials.entities(Table)
		local mt <const> = getmetatable(Table)
		if mt and mt.__is_const then
			Table = mt.__index
		end
		local key
		if #memoized == 0 then
			local func
			func = function()
				local Entity
				repeat
					key, Entity = next(Table, key)
				until not key 
				or (math.type(Entity) == "integer" and entity.is_an_entity(Entity)) 
				or (math.type(key) == "integer" and entity.is_an_entity(key))
				if key == nil then
					table.insert(memoized, func)
				end
				return Entity, key
			end
			return func
		else
			local i <const> = #memoized
			local func <const> = memoized[i]
			table.remove(memoized, i)
			essentials.assert(debug.getupvalue(func, 3) == "Table" and debug.setupvalue(func, 3, Table), "FAILED TO SET UPVALUE")
			return func
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

function essentials.get_safe_feat_name(name)
	local str <const> = name:gsub("[^A-Za-z0-9%s%p%c]", "")
	return str
end

function essentials.rename_file(...)
	local file_path <const>, 
	original_file_name <const>, 
	new_file_name <const>, 
	file_extension = ...
	file_extension = "."..file_extension
	local original_file_path <const> = file_path..original_file_name..file_extension
	local new_file_path <const> = file_path..new_file_name..file_extension
	essentials.assert(not new_file_name:find("[<>:\"/\\|%?%*]"), "Tried to rename file to a name containing illegal characters:", new_file_name)
	essentials.assert(utils.file_exists(original_file_path), "Tried to rename a file that doesn't exist.", original_file_path)
	essentials.assert(not utils.file_exists(new_file_path), "Tried to overwrite an existing file while attempting to rename a file.", original_file_path, new_file_path)
	local file_string <const> = essentials.get_file_string(original_file_path, "*a")
	io.remove(original_file_path)
	local file <close> = io.open(new_file_path, "w+")
	file:write(file_string)
	file:flush()
end

function essentials.wait_conditional(duration, func, ...)
	local duration <const> = duration
	local func <const> = func
	essentials.assert(duration > 0, "Duration must be longer than 0.", duration)
	local time <const> = utils.time_ms() + duration
	repeat -- Must guarantee one yield or else there's a possibility of loops without yield
		system.yield(0)
	until not func(...) or utils.time_ms() > time
end

function essentials.table_to_xml(...)
	local Table <const>,
	tabs,
	name <const>,
	lines <const>,
	_return = ...
	if name then
		lines[#lines + 1] = string.format("%s<%s>", ("\9"):rep(tabs - 1), name)
	end
	local tab_string <const> = ("\9"):rep(tabs)
	for property_name, property in pairs(Table) do
		if type(property) == "table" then
			tabs = tabs + 1
			essentials.table_to_xml(property, tabs, property_name, lines)
			tabs = tabs - 1
		else
			lines[#lines + 1] = string.format("%s<%s>%s</%s>", tab_string, property_name, tostring(property), property_name)
		end
	end
	if name then
		lines[#lines + 1] = string.format("%s</%s>", ("\9"):rep(tabs - 1), name)
	end
	if _return then
		return table.concat(lines, "\n")
	end
end

local last_error_time = 0
local last_error = ""
function essentials.log_error(...)
	local error_message <const>, yield <const>, file_path = ...
	file_path = file_path or paths.kek_menu_stuff.."kekMenuLogs\\kek_menu_log.log"
	if utils.time_ms() > last_error_time and last_error ~= debug.traceback(error_message, 2) then
		last_error_time = utils.time_ms() + 100
		last_error = debug.traceback(error_message, 2)
		local file <close> = io.open(file_path, "a+")
		local additional_info <const> = {""}
		for i2 = 2, 1000 do
			if pcall(function() 
				return debug.getlocal(i2 + 2, 1)
			end) then
				additional_info[#additional_info + 1] = string.format("\9Locals at level %i:", i2)
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
						additional_info[#additional_info + 1] = string.format("\9\9[%s] = %s (%s)", name, tostring(value):sub(1, 100), Type)
					end
				end
			else
				break
			end
		end
		file:write(debug.traceback(
			string.format("\n\n[%s]: < %s > [Kek's menu version: %s]\n%s\n",
				os.date(), 
				error_message, 
				__kek_menu_version, 
				table.concat(additional_info, "\n")), 2))
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

essentials.notif_colors = essentials.const({
	red = 0xff0000ff,
	yellow = 0xff00ffff,
	blue = 0xffff0000,
	green = 0xff00ff00,
	purple = 0xff800080,
	orange = 0xff0080ff,
	brown = 0xff336699,
	pink = 0xffff00ff
})

function essentials.msg(...)
	local text <const>,
	color <const>,
	notifyOn <const>,
	duration <const>,
	header = ...
	essentials.assert(essentials.notif_colors[color], "Invalid color to notification.", color)
	essentials.assert(type(text) == "string", "Failed to send a notification.", text)
	if notifyOn then
		header = header or ""
		if header == "" and __kek_menu_version then
			header = lang["Kek's menu"].." "..__kek_menu_version
		end
		menu.notify(text, header, duration or 3, essentials.notif_colors[color])
	end
end

function essentials.is_in_vehicle(pid)
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

function essentials.request_anim_dict(dict)
	local time <const> = utils.time_ms() + 500
	streaming.request_anim_dict(dict)
	while time > utils.time_ms() and not streaming.has_anim_dict_loaded(dict) do
		system.yield(0)
	end
	return streaming.has_anim_dict_loaded(dict)
end

function essentials.request_anim_set(anim_set)
	local time <const> = utils.time_ms() + 500
	streaming.request_anim_set(anim_set)
	while time > utils.time_ms() and not streaming.has_anim_set_loaded(anim_set) do
		system.yield(0)
	end
	return streaming.has_anim_set_loaded(anim_set)
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
	return not settings.toggle["Exclude friends from attacks"].on or not network.is_scid_friend(player.get_player_scid(pid))
end

function essentials.get_most_relevant_entity(...)
	local pid <const> = ...
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
		essentials.assert(type(text) == "string", "Tried to send a chat message with a non string value.", text, type(text))
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

function essentials.binary_search(Table, value) -- Only use if table is sorted in ascending numbers.
    local left, mid, right = 1, 0, #Table
    while left <= right do
        local mid <const> = (left + right) // 2
        if Table[mid] < value then
            left = mid + 1
        elseif Table[mid] > value then
            right = mid - 1
        else
            return mid
        end
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
	essentials.assert(select(2, next(exclusions)) == true, "Invalid exclusions table.")
	local pids <const> = {}
	for pid in essentials.players(true) do
		if not exclusions[pid] then
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
	local special_char_map <const> = essentials.const({
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

function essentials.get_file_string(...)
	local file_path <const>, type <const> = ...
	local file <close> = io.open(file_path)
	if file and io.type(file) == "file" then
		return file:read(type) or ""
	else
		return ""
	end
end

function essentials.get_descendants(...)
	local parent <const>,
	Table,
	add_parent_of_descendants <const> = ...
	for _, feat in pairs(parent.children) do
		if feat.type == 2048 and feat.child_count > 0 then
			essentials.get_descendants(feat, Table)
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
			essentials.get_player_descendants(menu.get_player_feature(feat.id), Table)
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

function essentials.how_many_people_named(pid)
	local name <const> = player.get_player_name(pid)
	local scid <const> = player.get_player_scid(pid)
	local ip <const> = player.get_player_ip(pid)
	local count = 0
	for pid in essentials.players(true) do
		if name == player.get_player_name(pid) 
		or scid == player.get_player_scid(pid) 
		or ip == player.get_player_ip(pid) then
			count = count + 1
		end
	end
	return count
end

function essentials.get_ped_closest_to_your_pov()
	local spectate_target <const> = network.get_player_player_is_spectating(player.player_id())
	if spectate_target then
		return player.get_player_ped(spectate_target)
	else
		return player.get_player_ped(player.player_id())
	end
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

function essentials.random_real(...)
	local a, b <const> = ...
	local power <const> = math.min(18 - #tostring(a), 17 - #tostring(b))
	a = math.random(a * 10^power, b * 10^power)
	return a / 10^power
end

function essentials.random_wait(...)
	local range <const> = ...
	essentials.assert(math.type(range) == "integer" and range > 0, "Random wait range must be bigger than 0.", range)
	if math.random(1, range) == 1 then
		system.yield(0)
	end
end

function essentials.set_all_player_feats_except(...)
	local player_feat_id <const>,
	bool <const>,
	exclusions <const> = ...
	essentials.assert(select(2, next(exclusions)) == true, "Invalid exclusions table.")
	for pid = 0, 31 do
		if not exclusions[pid] then
			menu.get_player_feature(player_feat_id).feats[pid].on = bool == true
		end
	end
end

function essentials.dec_to_ipv4(ip)
	return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
end

function essentials.ipv4_to_dec(...)
	local ip <const> = ...
	local dec = 0
	for octet in ip:gmatch("%d+") do 
		dec = octet + dec << 8 
	end
	return math.ceil(dec)
end

function essentials.get_position_of_previous_newline(str, str_pos)
	repeat
		str_pos = str_pos - 1
	until str_pos <= 1 or str:sub(str_pos, str_pos) == '\n'
	return math.max(str_pos, 1)
end

function essentials.search_for_match_and_get_line(...)
	local file_path <const>,
	search <const>,
	exact <const> = ... -- Whether the existing text check must be identical to an entire line or a substring of a line.
	local str <const> = essentials.get_file_string(file_path, "*a")
	for i = 1, #search do
		local str_pos
		if exact then
			str_pos = str:find(string.format("\n%s\n", search[i]), 1, true) 
			or str:find(string.format("^%s\n", search[i])) 
			or str:find(string.format("\n%s$", search[i]))
			or str:find(string.format("^%s$", search[i]))
		else
			str_pos = str:find(search[i], 1, true)
		end
		if str_pos then
			str_pos = essentials.get_position_of_previous_newline(str, str_pos) + 1
			return str:sub(str_pos, (str:find("\n", str_pos, true) or #str + 1) - 1), search[i]
		end
	end
end

do
	local ad_strings <const> = essentials.const({
		"%.com",
		"%.net",
		"%.org",
		"http",
		"www%.",
		"%.tk",
		"%.ru",
		"%.info",
		"%.cn",
		"%.uk",
		"%.biz",
		"%.xyz",
		"qq",
		"%.gg",
		"#%d%d%d%d", -- Discord ig tag
		"%d%d%d%d%d", -- tencent qq codes are 5 - 12 digits
		"gta%d%d"
	})
	function essentials.contains_advert(str)
		local str <const> = str:lower()
		for i = 1, #ad_strings do
			if str:find(ad_strings[i]) then
				return true
			end
		end
	end
end

function essentials.log(...)
	local file_path <const>,
	text_to_log <const>,
	search <const>, -- Whether to check if text_to_log appears in the file already or not
	exact <const> = ... -- Whether the existing text check must be identical to an entire line or a substring of a line.
	if search then
		local str <const> = essentials.search_for_match_and_get_line(file_path, search, exact)
		if str then
			return str
		end
	end
	local file <close> = io.open(file_path, "r+")
	file:seek("end", -1)
	local last_char <const> = file:read("*L") -- *L keeps the newline char, unlike *l.
	if last_char ~= "\n" then
		file:write("\n")
	end
	file:write(text_to_log)
	file:write("\n")
end

function essentials.add_to_timeout(pid)
	essentials.log(paths.home.."cfg\\scid.cfg", 
		string.format("%s:%x:c", player.get_player_name(pid), player.get_player_scid(pid)), 
		{string.format("%x", player.get_player_scid(pid)), player.get_player_name(pid)})
end

function essentials.send_pattern_guide_msg(...)
	local part <const>, Type <const> = ...
	local parts <const> = {
		["Chat judger"] = {
			"There are 2 special texts for the chat judger: [BLACKLIST] = Add people to the blacklist\n[JOIN TIMEOUT] = Add people to 2take1's join timeout.",
			"Examples of how to use:\nmoney[BLACKLIST] -- This will add anyone saying the word money in a sentence to the blacklist",
			"money[JOIN TIMEOUT][BLACKLIST] -- This will add anyone saying money to the timeout and blacklist."
		},
		["Chatbot"] = {
			"There are 3 special texts for the chatbot:\n[PLAYER_NAME] -- This grabs the player sending the message's name.",
			"[MY_NAME] -- This gets your name\n[RANDOM_NAME] -- This gets a random player's name."
		},
		regular = {
			"When adding entries, it's important to know about patterns. A pattern could look like this: %s+money%s+. This would look for people using money in the middle of a sentence.",
			"Note that these characters: \"*\", \"+\", \"-\", \"^\", \"$\", \".\", \"?\", \"[\", \"]\", \"(\" & \")\" have special meanings. Google \"Lua magic characters\" to find out what they mean.",
			"For further assistance, join the Kek's menu discord. An invite comes with the script. It is in a file called \"Discord invite.txt\"."
		}

	}
	table.move(parts.regular, 1, #parts.regular, #parts[Type] + 1, parts[Type])
	for i = 1, #parts[Type] do
		if part + 1 == i then
			essentials.msg(lang[parts[Type][i]], "blue", true, 12)
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
			essentials.msg(string.format("%s %s.\n%s", 
				lang["Warning: missing \"%\" before any of these characters;"],
				"\".\", \"+\", \"-\", \"*\", \"?\", \"^\", \"$\"",
				lang["This is fine, just note that if you don't put the \"%\" before those characters, they mean something else."]), 
			"red", true, 12)
		end
	end
	local status <const> = pcall(function() 
		return text:find(text)
	end)
	if not status then
		essentials.msg(lang["Invalid pattern. Most likely missing a \"[\", \"]\", \"(\", \")\" or a \"%\" somewhere. Could also be \"[]\", having \"[]\" causes an error."], "red", msg, 12)
		return true
	end
end

do
	local mod_flag_memoize <const> = {}
	function essentials.modder_flags_to_text(...)
		local mod_flags <const> = ...
		if not mod_flag_memoize[mod_flags] then
			local all_flags <const> = {}
			for i = 0, 63 do
				local flag <const> = 1 << i
				if flag == player.get_modder_flag_ends() then
					break
				end
				if mod_flags & flag ~= 0 then
					all_flags[#all_flags + 1] = player.get_modder_flag_text(flag)
				end
			end
			mod_flag_memoize[mod_flags] = table.concat(all_flags, ", ")
		end
		return mod_flag_memoize[mod_flags]
	end
end

do
	local modder_text_to_flags_map <const> = {}
	for i = 0, 63 do
		if 1 << i == player.get_modder_flag_ends() then
			break
		end
		modder_text_to_flags_map[player.get_modder_flag_text(1 << i)] = 1 << i
	end

	function essentials.modder_text_to_flags(modder_text)
		local flags = 0
		for flag in modder_text:gmatch("%a[^,]+") do
			flags = flags | (modder_text_to_flags_map[flag] or 0)
		end
		return flags
	end
end

function essentials.replace_lines_in_file_exact(...)
	local file_path <const>,
	what_to_be_replaced <const>,
	replacement <const> = ...
	local new_string <const> = {}
	local found_what_to_be_replaced = false
	for line in io.lines(file_path) do
		if not found_what_to_be_replaced and line == what_to_be_replaced then
			new_string[#new_string + 1] = replacement
			found_what_to_be_replaced = true
		else
			new_string[#new_string + 1] = line
		end
	end
	local file <close> = io.open(file_path, "w+")
	new_string[#new_string + 1] = ""
	file:write(table.concat(new_string, "\n"))
	file:flush()
	return found_what_to_be_replaced
end

function essentials.replace_lines_in_file_substring(...)
	local file_path <const>,
	what_to_be_replaced <const>,
	replacement <const>,
	use_regex <const> = ...
	local new_string <const> = {}
	local found_what_to_be_replaced = false
	for line in io.lines(file_path) do
		if not found_what_to_be_replaced and line:find(what_to_be_replaced, 1, not use_regex) then
			new_string[#new_string + 1] = replacement
			found_what_to_be_replaced = true
		else
			new_string[#new_string + 1] = line
		end
	end
	local file <close> = io.open(file_path, "w+")
	new_string[#new_string + 1] = ""
	file:write(table.concat(new_string, "\n"))
	file:flush()
	return found_what_to_be_replaced
end

function essentials.remove_lines_from_file_exact(...)
	local file_path <const>,
	what_to_be_removed <const> = ...
	local new_string <const> = {}
	local found_what_to_be_removed = false
	for line in io.lines(file_path) do
		if found_what_to_be_removed or line ~= what_to_be_removed then
			new_string[#new_string + 1] = line
		else
			found_what_to_be_removed = true
		end
	end
	local file <close> = io.open(file_path, "w+")
	new_string[#new_string + 1] = ""
	file:write(table.concat(new_string, "\n"))
	file:flush()
	return found_what_to_be_removed
end

function essentials.remove_lines_from_file_substring(...)
	local file_path <const>,
	what_to_be_removed <const>,
	use_regex <const> = ...
	local new_string <const> = {}
	local found_what_to_be_removed = false
	for line in io.lines(file_path) do
		if found_what_to_be_removed or not line:find(what_to_be_removed, 1, not use_regex) then
			new_string[#new_string + 1] = line
		else
			found_what_to_be_removed = true
		end
	end
	local file <close> = io.open(file_path, "w+")
	new_string[#new_string + 1] = ""
	file:write(table.concat(new_string, "\n"))
	file:flush()
	return found_what_to_be_removed
end

return essentials