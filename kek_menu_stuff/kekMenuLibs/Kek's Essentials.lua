-- Copyright © 2020-2022 Kektram

local essentials <const> = {version = "1.5.0"}

local language <const> = require("Kek's Language")
local lang <const> = language.lang
local enums <const> = require("Kek's Enums")
local settings <const> = require("Kek's Settings")

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
essentials.number_of_explosion_types = 82
essentials.init_delay = utils.time_ms() + 1000 -- For notifications that should only display if user toggles on the feature (toggles being turned on due to settings and such)

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"

function essentials.is_str(f, str) -- Greatly improves readability
	return f.str_data[f.value + 1] == lang[str]
end

function essentials.assert(bool, msg, ...)
	if not bool then
		local n_args <const> = select("#", ...)
		msg = string.format(
			(n_args > 0 and "%s\nExtra info:\n" or msg)..string.rep("%s\n", n_args), 
			msg, ...
		)
		print(debug.traceback(msg, 2))
		menu.notify(debug.traceback(msg, 2), "Error", 12, 0xff0000ff)
		essentials.log_error(msg)
		error(msg, 2)
	end
end

function essentials.get_time_plus_frametime(num_of_frames)
	return utils.time_ms() + (gameplay.get_frame_time() * 1000 * num_of_frames)
end

function essentials.add_chat_event_listener(callback) -- Fixes crash if someone spams chat
	local tracker <const> = {}
	return event.add_event_listener("chat", function(event)
		if not tracker[event.player] then
			tracker[event.player] = true
			callback(event)
			tracker[event.player] = false
		end
	end)
end

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

do
	function essentials.pack_2_positive_integers(x, y)
		return 0 | x << 31 | y
	end
end

function essentials.get_rgb(r, g, b)
	return (b << 16) | (g << 8) | r
end

function essentials.rgb_to_bytes(uint32_rgb)
	return
		(uint32_rgb << 56 >> 56),
		(uint32_rgb << 48 >> 56),
		(uint32_rgb >> 16)
end

function essentials.get_max_variadic(...)
	local max = math.mininteger
	local t <const> = table.pack(...)
	for i = 1, #t do
		max = t[i] > max and t[i] or max
	end
	return max
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

function essentials.const_all(Table, timeout)
	timeout = timeout or utils.time_ms() + 1000
	essentials.assert(timeout > utils.time_ms(), "Entered recursion loop while setting table to const all.")
	for key, value in pairs(Table) do
		if type(value) == "table" then
			essentials.rawset(Table, key, essentials.const_all(value, timeout))
		end
	end
	return essentials.const(Table)
end

function essentials.make_string_case_insensitive(str)
	str = str:gsub("%a", function(str) -- Done like this to only return the string. Gsub has 2 return values.
		return "["..str:lower()..str:upper().."]"
	end)
	return str
end

function essentials.get_player_coords(pid) -- Allows you to get player coords with accurate z coordinate.
	if pid == player.player_id() then
		return player.get_player_coords(pid)
	else
		return network._network_get_player_coords(pid)
	end
end

function essentials.split_string(str, size) 
--[[
	Strings may be up to 4 bytes smaller than requested size if unicode is present. (alternative would be up to 3 bytes bigger, which cause more problems)
	This happens if it finds a unicode character that needs more space than requested size. (at the end of the string)
	Performance: split a 46k byte string (with chinese and ascii characters) by size 255 9,000 times in one second. (110 micro seconds per iteration).
	Returns a table with 1 empty string if str is empty.
	Have applied every micro-optimization in the book. They yield 15% improved performance.
--]]
	essentials.assert(size >= 4, "Failed to split string. Split size must be 4 or more.", str, size) -- Infinite loop (only if unicode is present). For consistency, 4 or more is required.
	local strings <const> = {}
	local pos, i, len <const> = 0, 1, #str
	local find <const>, sub <const> = string.find, string.sub
	local found_no_more_unicode = false
	local start_pos, end_pos = math.mininteger, math.mininteger
	repeat
		local posz <const> = pos + size
		if not found_no_more_unicode and posz > end_pos then -- Makes sure all bytes in the string is searched no more than once.
			start_pos, end_pos = find(str, "[\0-\x7F\xC2-\xFD][\x80-\xBF]+", posz > 4 and posz - 4 or 1) -- This will cause no unicode strings to be slower. Many smaller string.finds is much cheaper than one massive string.find.
			if not start_pos then
				found_no_more_unicode, end_pos, start_pos = true, math.mininteger, math.mininteger
			end
		end
		strings[i] = sub(
			str,
			pos + 1, 
			end_pos >= posz - 4 and end_pos <= posz and end_pos -- Found unicode char that fits in the requested size?
			or start_pos >= posz - 4 and start_pos <= posz and start_pos - 1 -- Found uni char, but it doesn't fit the requested size?
			or posz -- No unicode interference.
		)
		pos = pos + #strings[i]
		i = i + 1
	until pos >= len
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
			return (""):find(line)
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

	local feat_err_msg <const> = "This error might be related to your script, not necessarily Kek's menu. Either the parent id or feature type specified is incorrect."
	menu.add_feature = function(...)
		local name <const>,
		Type <const>,
		parent <const>,
		func <const> = ...
		local feat
		local type <const> = type
		if type(func) == "function" then
			essentials.assert(utf8.len(name), "Tried to create a feature with invalid utf8 for its name. YOU WOULD HAVE CRASHED IF THIS CHECK WASN'T HERE.")
			feat = originals.add_feature(name, Type, parent, function(f, data)
				if type(f) ~= "number" then
					if func(f, data) == HANDLER_CONTINUE then
						return HANDLER_CONTINUE
					end
				end
			end)
		else
			feat = originals.add_feature(name, Type, parent)
		end
		essentials.assert(
			feat, "Failed to create feature:",
			feat_err_msg,
			"Feature name: ",
			name, 
			debug.getinfo(2, "S").source, 
			"line:",
			debug.getinfo(2, "l").currentline
		)
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
			essentials.assert(utf8.len(name), "Tried to create a player feature with invalid utf8 for its name. YOU WOULD HAVE CRASHED IF THIS CHECK WASN'T HERE.")
			feat = originals.add_player_feature(name, Type, parent, function(f, pid, data)
				if type(f) ~= "number" then -- Must check if not a number, custom UIs pass table instead of userdata.
					if func(f, pid, data) == HANDLER_CONTINUE then
						return HANDLER_CONTINUE
					end
				end
			end)
		else
			feat = originals.add_player_feature(name, Type, parent)
		end
		essentials.assert(
			feat, "Failed to create player feature:", 
			feat_err_msg,
			"Feature name: ",
			name,
			debug.getinfo(2, "S").source, 
			"line:",
			debug.getinfo(2, "l").currentline
		)
		essentials.player_feats[feat.id] = feat.id
		return feat
	end
	getmetatable(menu).__newindex = originals.menu_newindex
end

function essentials.deep_copy(Table, keep_meta, timeout)
	local new_copy <const> = {}
	timeout = timeout or utils.time_ms() + 1000 -- Far cheaper than using a seen table.
	for key, value in pairs(Table) do
		if type(value) == "table" then
			new_copy[key] = essentials.deep_copy(value, keep_meta, timeout)
			if keep_meta and type(getmetatable(value)) == "table" then
				setmetatable(new_copy[key], essentials.deep_copy(getmetatable(value), true, timeout))
			end
		else
			new_copy[key] = value
		end
	end
	if keep_meta and type(getmetatable(Table)) == "table" then
		setmetatable(new_copy, essentials.deep_copy(getmetatable(Table), true, timeout))
	end
	essentials.assert(timeout > utils.time_ms(), "Entered recursion loop while attempting to deep copy table.")
	return new_copy
end

do
	local is_valid <const> = player.is_player_valid
	function essentials.players(me)
		local pid = -1
		if not me then
			me = player.player_id()
		end
		return function()
			repeat
				pid = pid + 1
			until pid == 32 or (me ~= pid and is_valid(pid))
			if pid ~= 32 then
				return pid
			end
		end
	end
end

do
	local is_entity <const> = entity.is_an_entity
	local math_type <const> = math.type
	local next <const> = next
	function essentials.entities(Table)
		local mt <const> = getmetatable(Table)
		if mt and mt.__is_const then
			Table = mt.__index
		end
		local key, Entity
		return function()
			repeat
				key, Entity = next(Table, key)
			until key == nil 
			or (math_type(Entity) == "integer" and is_entity(Entity)) 
			or (math_type(key) == "integer" and is_entity(key))
			return Entity, key
		end
	end
end

essentials.FEATURE_ID_MAP = essentials.const({ -- The table keys are derived from the Feat.type property.
-- Regular feat types
	[1 << 9] = "action",
	[1 << 0] = "toggle",
	[1 << 1 | 1 << 7 | 1 << 9 ] = "action_value_f",
	[1 << 0 | 1 << 1 | 1 << 7 ] = "value_f",
	[1 << 1 | 1 << 2 | 1 << 9 ] = "action_slider",
	[1 << 0 | 1 << 1 | 1 << 2 ] = "slider",
	[1 << 1 | 1 << 5 | 1 << 10] = "autoaction_value_str",
	[1 << 1 | 1 << 2 | 1 << 10] = "autoaction_slider",
	[1 << 1 | 1 << 3 | 1 << 9 ] = "action_value_i",
	[1 << 0 | 1 << 1 | 1 << 3 ] = "value_i",
	[1 << 1 | 1 << 7 | 1 << 10] = "autoaction_value_f",
	[1 << 1 | 1 << 3 | 1 << 10] = "autoaction_value_i",
	[1 << 1 | 1 << 5 | 1 << 9 ] = "action_value_str",
	[1 << 0 | 1 << 1 | 1 << 5 ] = "value_str",
-- Regular feat types

	[1 << 11] = "parent", -- Both player feat & regular feat type have same id

-- Player feat types
	[1 << 9 | 1 << 15] = "action",
	[1 << 0 | 1 << 15] = "toggle",
	[1 << 1 | 1 << 7 | 1 << 9  | 1 << 15] = "action_value_f",
	[1 << 0 | 1 << 1 | 1 << 7  | 1 << 15] = "value_f",
	[1 << 1 | 1 << 2 | 1 << 9  | 1 << 15] = "action_slider",
	[1 << 0 | 1 << 1 | 1 << 2  | 1 << 15] = "slider",
	[1 << 1 | 1 << 5 | 1 << 10 | 1 << 15] = "autoaction_value_str",
	[1 << 1 | 1 << 2 | 1 << 10 | 1 << 15] = "autoaction_slider",
	[1 << 1 | 1 << 3 | 1 << 9  | 1 << 15] = "action_value_i",
	[1 << 0 | 1 << 1 | 1 << 3  | 1 << 15] = "value_i",
	[1 << 1 | 1 << 7 | 1 << 10 | 1 << 15] = "autoaction_value_f",
	[1 << 1 | 1 << 3 | 1 << 10 | 1 << 15] = "autoaction_value_i",
	[1 << 1 | 1 << 5 | 1 << 9  | 1 << 15] = "action_value_str",
	[1 << 0 | 1 << 1 | 1 << 5  | 1 << 15] = "value_str"
-- Player feat types

--[[
	1 << 0 == toggle flag
	1 << 1 == Not a parent, toggle or regular action feature?
	1 << 2 == slider flag
	1 << 3 == value_i flag
	1 << 5 == value_str flag
	1 << 7 == value_f flag
	1 << 9 == action flag
	1 << 10 == autoaction flag
	1 << 11 == parent flag
	1 << 15 == player_feat flag
--]]

})

function essentials.sub_unicode(str, start, End)
	return str:sub(utf8.offset(str, start), utf8.offset(str, End + 1) - 1)
end

function essentials.sub_unicode_byte_len(str, start, End)
	return utf8.char(utf8.codepoint(str, start, End))
end

do -- This function is making it so unicode character lead bytes aren't confused as regular characters.
	local gsub <const> = string.gsub
	local sub  <const> = string.sub
	local byte <const> = string.byte
	local char <const> = string.char
	local find <const> = string.find

	local conversion_callback <const> = function(str)
		local byte <const> = byte(sub(str, 1, 1))
		local lead_byte <const> = char(byte < 128 and byte + 128 or byte)
		return lead_byte..sub(str, 2, -1)
	end
	function essentials.unicode_find_2(str, pattern, pos, plain) -- Converts pattern & string's unicode into codepoint.
		return find(
			gsub(str, "[\0-\x7F\xC2-\xFD][\x80-\xBF]+", conversion_callback),
			gsub(pattern, "[\0-\x7F\xC2-\xFD][\x80-\xBF]+", conversion_callback),
			pos, 
			plain
		)
	end -- Converts lead bytes into characters that doesnt interfere with patterns
end

function essentials.get_safe_feat_name(name) -- Checks if valid utf8 code, removes corrupted bytes if not
	local str = name
	if not utf8.len(name) then
		str = name:gsub("[^A-Za-z0-9%s%p%c]", "")
	end
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
	local file_string <const> = essentials.get_file_string(original_file_path, "rb"):gsub("\r", "")
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
	_return,
	timeout = ...
	timeout = timeout or utils.time_ms() + 1000 -- In case of recursion loop
	if name then
		lines[#lines + 1] = string.format("%s<%s>", ("\t"):rep(tabs - 1), name)
	end
	local tab_string <const> = ("\t"):rep(tabs)
	for property_name, property in pairs(Table) do
		if type(property) == "table" then
			tabs = tabs + 1
			essentials.table_to_xml(property, tabs, property_name, lines, nil, timeout)
			tabs = tabs - 1
		else
			lines[#lines + 1] = string.format("%s<%s>%s</%s>", tab_string, property_name, tostring(property), property_name)
		end
	end
	if name then
		local line
		if (type(name) == "string" and name or tostring(name)):find("=", 1, true) then
			line = string.format("%s</%s>", ("\t"):rep(tabs - 1), name:match("^%S+"))
		else
			line = string.format("%s</%s>", ("\t"):rep(tabs - 1), name)
		end
		lines[#lines + 1] = line
	end
	essentials.assert(timeout > utils.time_ms(), "Entered recursion loop while attempting to convert table to xml.")
	if _return then
		return table.concat(lines, "\n")
	end
end

function essentials.cast_value(value, parse_type)
	if parse_type == "xml" and value:find(",", 1, true) then
		local values = {}
		for value in value:gmatch("([^,%s]+)") do
			values[#values + 1] = essentials.cast_value(value, "xml")
		end
		return values
	else
		if value == "false" then
			return false
		else
			return
				value == "true"
				or tonumber(value)
				or tonumber(value, 16)
				or tonumber("0x"..value) -- The former tonumber doesn't support hexadecimal with fractions.
				or value
		end
	end
end

local function parse_attribute(str)
	local name <const>, where <const> = str:match("^<([^\32>]+)()")
	local values
	if str:find("=", where + 1, true) then
		values = {}
		for index, value in str:gmatch("([^=]+)=[\"']([^=]+)[\"'][\32>]", where + 1) do
			values[index] = essentials.cast_value(value, "xml")
		end
	end
	return name, values
end

--[[
	DOM XML parser. Read only.
	Supports:
		Fundamentals
		Multi-line elements. Such as a paragraph. Tabs at start of each line are also removed.
		Multi-line elements must start its value on the same line as the same. <name>\n would have it ignore its content.
		Multiple values in a element separated by comma
		Ignore single line & multi line comment, empty lines & nodes with no values
		Escape sequences
		Attributes, but only for node parents & tags
		Multiple roots, if the roots have different names
		Duplicate parent and child names. They are converted to a new node & split up into nodes, starting from 1, 2, 3...
	
	Does not support:
		Defining types (schema)
		DOCTYPE declaration
		CSS
		Loading files

	This parser is meant to be as fast as possible.
	Prologue is info.prologue
	Performance: Parsed a 15k lines menyoo vehicle in 28ms.
	Parses are remembered until garbage collector is collecting.
--]]

local __is_table_mt = {__index = {__is_table = true}}

local accepted_whitespace <const> = "[\t\n\r]"
local escape_seq_map <const> = {
	["&quot;"] = "\"",
	["&apos;"] = "'",
	["&lt;"] = "<",
	["&gt;"] = ">",
	["&amp;"] = "&"
}

local memoized <const> = setmetatable({}, {__mode = "vk"})
function essentials.parse_xml(str)
	if memoized[str] then
		return memoized[str]
	else
		memoized[str] = {}
	end
	local find <const> = string.find
	local gsub <const> = string.gsub
	local match <const> = string.match
	local setmetatable <const> = setmetatable
	local parse_attribute <const> = parse_attribute
	local cast_value <const> = essentials.cast_value

	local info = memoized[str]

	if not str:find(accepted_whitespace, -1) then
		str = str.."\n" -- This is extremely expensive, but adapting the entire parser is worse
	end -- Completely fails to parse anything if last char isn't whitespace.
	-- Must have both \r and \n. Missing \r will make certain files like BIGHEAD AngryDoggo unparseable.

	local memoized <const> = {}
	local parent_tree <const> = {}
	if pcall(function()
		local end_of_first_line <const> = select(2, find(str, "\n", 1, true))
		local first_line <const> = str:sub(1, end_of_first_line - 1)
		info.prologue = select(2, parse_attribute(first_line:gsub("%?", "")))
	end) then

		for line in str:gmatch("<.->%f"..accepted_whitespace) do
			memoized[line] = memoized[line] or {
				new_value_find = find(line, "^<.+>.+</.+>$"),
				is_comment = find(line, "^<!%-%-"),
				index = false,
				value = false
			}
			local memoized <const> = memoized[line]
			if memoized.is_comment then
				goto continue
			end
			if memoized.new_value_find then
				if not memoized.index then
					local value = gsub(match(line, ">([^<>]+)</"), "\n\t*", "\n")
					value = gsub(value, "&%a%a%a?%a?;", escape_seq_map)
					memoized.index = match(line, "^<([^>]+)>")
					memoized.value = cast_value(value, "xml")
				end
				local parent <const> = parent_tree[#parent_tree][memoized.index]
				if parent then
					if parent.__is_table then
						parent[#parent + 1] = memoized.value
					else
						parent_tree[#parent_tree][memoized.index] = setmetatable({parent, memoized.value}, __is_table_mt)
					end
				else
					parent_tree[#parent_tree][memoized.index] = memoized.value
				end
				goto continue
			end

			memoized.new_tag_find = memoized.new_tag_find or find(line, "^<.+\32/>$")
			if memoized.new_tag_find then
				local name <const>, attributes <const> = parse_attribute(line)
				parent_tree[#parent_tree][name] = {__attributes = attributes}
				goto continue
			end

			memoized.new_parent_find = memoized.new_parent_find or find(line, "^<[^/?][^<>]+>$")
			if memoized.new_parent_find then
				local name <const>, attributes <const> = parse_attribute(line) -- Each set of attributes must have its own unique table so it can be modified without affecting others.
				parent_tree[#parent_tree + 1] = {__attributes = attributes}
				parent_tree[#parent_tree].__name = name
				goto continue
			end

			memoized.parent_end = memoized.parent_end or (#parent_tree > 0 and find(line, "</"..parent_tree[#parent_tree].__name..">", 1, true))
			if memoized.parent_end then
				local child <const> = parent_tree[#parent_tree]
				local parent <const> = parent_tree[#parent_tree - 1]
				if #parent_tree == 1 then
					info[child.__name] = child
				else
					local value <const> = parent[child.__name]
					if value then
						if value.__is_table then
							value[#value + 1] = child
						else
							parent[child.__name] = setmetatable({parent[child.__name], child}, __is_table_mt)
						end
					else
						parent[child.__name] = child
					end
				end
				child.__name = nil
				parent_tree[#parent_tree] = nil
			end
			::continue::
		end
	end
	return info
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

function essentials.kick_player(pid)
	essentials.assert(pid ~= player.player_id(), "Tried to kick yourself.")
	return network.force_remove_player(pid)
end

do
	local msg_queue <const> = {}
	local id = 0
	function essentials.send_message(...)
		local text, team <const> = ...
		if not utf8.len(text) then -- split_string requires valid utf8
			text = text:gsub("[\0-\x7F\xC2-\xFD][\x80-\xBF]+", "")
			text = text:gsub("[\x80-\xFF]", "")
		end
		local local_id = id + 1
		id = local_id
		msg_queue[#msg_queue + 1] = local_id
		while msg_queue[1] ~= local_id do
			system.yield(0)
		end
		local strings <const> = essentials.split_string(text, 255)
		for i = 1, math.min(#strings, 50) do
			network.send_chat_message(strings[i], team == true)
			system.yield(100)
		end
		table.remove(msg_queue, 1)
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

function essentials.get_file_string(file_path, mode)
	local file <close> = io.open(file_path, mode or "r")
	if file and io.type(file) == "file" then
		return file:read("*a") or ""
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

function essentials.name_to_pid(name)
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

function essentials.parse_files_from_html(str, extension)
	local files <const> = {}
	for file_name in str:gmatch("title=\"([^\"]+%."..extension..")\"") do
		local system_file_name <const> = file_name:gsub("&#39;", "'")
		local web_file_name <const> = system_file_name:gsub("\32", "%%20")
		files[#files + 1] = {
			system_file_name = system_file_name,
			web_file_name = web_file_name
		}
	end
	return files
end

function essentials.show_changelog()
	menu.create_thread(function()
		local github_branch_name <const> = __kek_menu_participate_in_betas and "beta" or "main"
		local status <const>, str <const> = web.get("https://raw.githubusercontent.com/kektram/Keks-menu/"..github_branch_name.."/Changelog.md")
		if enums.html_response_codes[status] ~= "OK" then
			return
		end
		local max_lines_before_shrinking <const> = 50
		local number_of_lines = 0
		for line in str:gmatch("[^\n]+") do
			number_of_lines = number_of_lines + 1
		end
		local start_y_pos <const> = math.max(0, 0.5 - (number_of_lines * 0.01))
		while not controls.is_control_pressed(0, 143) and not controls.is_disabled_control_pressed(0, 143) do
			local y_offset_from_top = 0
			for line in str:gmatch("[^\n]+") do
				ui.set_text_color(255, 255, 255, 255)
				ui.set_text_scale(number_of_lines <= max_lines_before_shrinking and 0.275 or 0.275 / (number_of_lines / max_lines_before_shrinking))
				ui.set_text_font(0)
				ui.set_text_outline(true)
				ui.draw_text(line, v2(0.3, start_y_pos + y_offset_from_top))
				y_offset_from_top = y_offset_from_top + (number_of_lines <= max_lines_before_shrinking and 0.018 or 0.018 / (number_of_lines / max_lines_before_shrinking))
			end
			ui.set_text_color(255, 0, 0, 255)
			ui.set_text_scale(0.4)
			ui.set_text_font(0)
			ui.set_text_outline(true)
			ui.draw_text(lang["Press space to remove this message."], v2(0.3, start_y_pos + y_offset_from_top + 0.005))
			system.yield(0)
		end
	end, nil)
end

function essentials.update_keks_menu()
	local github_branch_name <const> = __kek_menu_participate_in_betas and "beta" or "main"
	local base_path <const> = "https://raw.githubusercontent.com/kektram/Keks-menu/"..github_branch_name.."/"
	local version_check_status <const>, script_version = web.get(base_path.."VERSION.txt")
	local script_version <const> = script_version:gsub("[^%w\32.]", "")
	local
		update_status,
		current_file_num,
		lib_file_strings, 
		language_file_strings, 
		current_file,
		html_page_info,
		kek_menu_file_string,
		updated_lib_files, 
		updated_language_files = true, 0, {}, {}

	if enums.html_response_codes[version_check_status] ~= "OK" then
		essentials.msg(lang["Failed to check what the latest version of the script is."], "red", true, 6)
		return "failed to check what is the latest version"
	end
	if __kek_menu_version == script_version then
		essentials.msg(lang["You have the latest version of Kek's menu."], "green", true, 3)
		return "is latest version"
	else
		while controls.is_control_pressed(0, 215) 
		or controls.is_disabled_control_pressed(0, 215)
		or controls.is_control_pressed(0, 143) 
		or controls.is_disabled_control_pressed(0, 143) do
			system.yield(0)
		end
		local time <const> = utils.time_ms() + 25000
		while not controls.is_control_pressed(0, 143) 
		and not controls.is_disabled_control_pressed(0, 143) 
		and not controls.is_control_pressed(0, 215) 
		and not controls.is_disabled_control_pressed(0, 215)
		and time > utils.time_ms() do
			system.yield(0)
			ui.set_text_color(255, 140, 0, 255)
			ui.set_text_scale(0.6)
			ui.set_text_font(0)
			ui.set_text_centre(true)
			ui.set_text_outline(true)
			ui.draw_text(
				lang["There's a new update for Kek's menu available. Press enter to install it, space to not."], 
				v2(0.5, 0.45)
			)
			ui.set_text_color(0, 255, 255, 255)
			ui.set_text_scale(0.6)
			ui.set_text_font(0)
			ui.set_text_centre(true)
			ui.set_text_outline(true)
			ui.draw_text(
				lang["This message will disappear in 25 seconds and will assume you don't want the update."], 
				v2(0.5, 0.5)
			)
			if utils.time_ms() > time or controls.is_control_pressed(0, 143) or controls.is_disabled_control_pressed(0, 143) then
				return "Cancelled update"		
			end
		end
		menu.create_thread(function()
			while update_status ~= "done" do
				ui.set_text_color(255, 255, 255, 255)
				ui.set_text_scale(0.8)
				ui.set_text_font(0)
				ui.set_text_centre(true)
				ui.set_text_outline(true)
				ui.draw_text(
					updated_lib_files and updated_language_files and string.format(
						"%i / %i "..lang["files downloaded"].."\n%s", 
						current_file_num, 
						#updated_lib_files + #updated_language_files + 1, 
						current_file
					) or lang["Obtaining update information..."], 
					v2(0.5, 0.445)
				)
				ui.draw_rect(0.5, 0.5, 0.35, 0.12, 0, 0, 120, 255)
				system.yield(0)
			end
		end, nil)
		do
			if __kek_menu_debug_mode then
				essentials.msg(lang["Turn off debug mode to use auto-updater."], "red", true, 6)
				update_status = "done"
				return "tried to update with debug mode on"
			end
			local status <const>, str <const> = web.get("https://github.com/kektram/Keks-menu/tree/"..github_branch_name.."/kek_menu_stuff/kekMenuLibs")
			update_status = enums.html_response_codes[status] == "OK"
			if not update_status then
				goto exit
			end
			updated_lib_files = essentials.parse_files_from_html(str, "lua")
		end

		do
			local status <const>, str <const> = web.get("https://github.com/kektram/Keks-menu/tree/"..github_branch_name.."/kek_menu_stuff/kekMenuLibs/Languages")
			update_status = enums.html_response_codes[status] == "OK"
			if not update_status then
				goto exit
			end
			updated_language_files = essentials.parse_files_from_html(str, "txt")
		end
	end
	do
		current_file = "Kek's menu.lua" -- Download updated files
		local status <const>, str <const> = web.get(base_path.."Kek's%20menu.lua")
		update_status = enums.html_response_codes[status] == "OK"
		if not update_status then
			goto exit
		end
		kek_menu_file_string = str
		current_file_num = current_file_num + 1
	end

	for _, properties in pairs(updated_lib_files) do
		current_file = properties.system_file_name
		local status <const>, str <const> = web.get(base_path.."kek_menu_stuff/kekMenuLibs/"..properties.web_file_name)
		update_status = enums.html_response_codes[status] == "OK"
		if not update_status then
			goto exit
		end
		lib_file_strings[properties.system_file_name] = str
		current_file_num = current_file_num + 1
	end

	for _, properties in pairs(updated_language_files) do
		current_file = properties.system_file_name
		local status <const>, str <const> = web.get(base_path.."kek_menu_stuff/kekMenuLibs/Languages/"..properties.web_file_name)
		update_status = enums.html_response_codes[status] == "OK"
		if not update_status then
			goto exit
		end
		language_file_strings[properties.system_file_name] = str
		current_file_num = current_file_num + 1
	end
	::exit::
	if __kek_menu_version ~= script_version then
		if update_status then
			__kek_menu_version = script_version
			essentials.msg(lang["Update successfully installed."], "green", true, 6)

			-- Remove old files & undo all changes to the global space
			for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."kekMenuLibs", "lua")) do
				package.loaded[file_name:gsub("%.lua", "")] = nil
				io.remove(paths.kek_menu_stuff.."kekMenuLibs\\"..file_name)
			end
			for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."kekMenuLibs\\Languages", "txt")) do
				io.remove(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\"..file_name)
			end
			local file <close> = io.open(paths.home.."scripts\\Kek's menu.lua", "w+b")
			file:write(kek_menu_file_string)
			file:flush()

			-- Copy new files to their desired locations
			for file_name in pairs(lib_file_strings) do
				local file <close> = io.open(paths.kek_menu_stuff.."kekMenuLibs\\"..file_name, "w+b")
				file:write(lib_file_strings[file_name])
				file:flush()
			end

			for file_name in pairs(language_file_strings) do
				local file <close> = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\"..file_name, "w+b")
				file:write(language_file_strings[file_name])
				file:flush()
			end

			update_status = "done"
			essentials.show_changelog()
			system.yield(0) -- show_changelog creates a thread
			__kek_menu_version = nil
			__kek_menu_debug_mode = nil
			__kek_menu_participate_in_betas = nil
			__kek_menu_check_for_updates = nil
			dofile(paths.home.."scripts\\Kek's menu.lua")
			return "has updated"
		else
			update_status = "done"
			essentials.msg(lang["Update failed. No files are changed."], "green", true, 6)
			return "failed update"
		end
	end
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
	local current_char = str:sub(str_pos, str_pos)
	while str_pos > 1 and current_char ~= '\n' and current_char ~= '\r' do
		str_pos = str_pos - 1
		current_char = str:sub(str_pos, str_pos)
	end
	return str_pos > 1 and str_pos + 1 or 1
end

function essentials.search_for_match_and_get_line(...)
	local file_path <const>,
	search <const>,
	exact <const> = ...
	local str <const> = essentials.get_file_string(file_path, "rb")
	for i = 1, #search do
		local str_pos
		if exact then
			str_pos = str:find(string.format("[\r\n]%s[\r\n]", search[i]))
			or str:find(string.format("^%s[\r\n]", search[i])) -- These 3 extra checks are super fast no matter size of string. Anchors make sure #search[i] is max number of characters searched.
			or str:find(string.format("[\r\n]%s$", search[i]))
			or str:find(string.format("^%s$", search[i]))
		else
			str_pos = str:find(search[i], 1, true)
		end
		if str_pos then
			str_pos = essentials.get_position_of_previous_newline(str, str_pos)
			local End = str:find("[\n\r]", str_pos)
			if End then
				End = End - 1
			else
				End = #str
			end
			return str:sub(str_pos, End), search[i]
		end
	end
end

do
	local get_start <const> = essentials.get_position_of_previous_newline
	local find <const> = string.find
	local match <const> = string.match
	local sub <const> = string.sub

	function essentials.get_all_matches(str, pattern, match_pattern)
		essentials.assert(#pattern > 0, "Tried to get all matches with an empty pattern.")
		local End, start = 1
		local i = 1
		local matches <const> = {}
		while true do
			start, End = find(str, pattern, End, true)
			if start then
				local str_pos <const> = get_start(str, start)
				End = find(str, "[\r\n]", End) or (#str + 1)
				matches[i] = sub(str, str_pos, End - 1)
				End = End + 1
				if match_pattern then
					matches[i] = match(matches[i], match_pattern)
				end
				i = i + 1
			else
				break
			end
		end
		return matches
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
	local file <close> = io.open(file_path, "a+b")
	file:seek("end", -1)
	local last_char <const> = file:read("*L") -- *L keeps the newline char, unlike *l.
	if last_char ~= "\n" and last_char ~= "\r" and file:seek("end") ~= 0 then
		file:write("\n")
	end
	file:seek("end")
	file:write(text_to_log)
	file:write("\n")
end

function essentials.add_to_timeout(pid)
	essentials.assert(pid ~= player.player_id(), "Tried to add yourself to join timeout.")
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
		if text:find("[.+-*?^$]") and not text:find("%%[.+-*?^$]") then
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