-- Copyright © 2020-2022 Kektram

local enums <const> = require("Kek's Enums")
local language <const> = require("Kek's Language")
local lang <const> = language.lang
local essentials <const> = require("Kek's Essentials")
local vehicle_mapper <const> = require("Kek's Vehicle mapper")
local object_mapper <const> = require("Kek's Object mapper")
local ped_mapper <const> = require("Kek's Ped mapper")

local keys_and_input <const> = {version = "1.0.7"}

keys_and_input.CONTROLLER_KEYS = essentials.const_all({
	{name = "A", key_id = 18, group_id = 2},
	{name = "B", key_id = 45, group_id = 2}, 
	{name = "X", key_id = 22, group_id = 2}, 
	{name = "Y", key_id = 23, group_id = 2}, 
	{name = "LB", key_id = 37, group_id = 2}, 
	{name = "RB", key_id = 44, group_id = 2}, 
	{name = "L2", key_id = 10, group_id = 2}, 
	{name = "R2", key_id = 11, group_id = 2}, 
	{name = "L3", key_id = 28, group_id = 2}, 
	{name = "R3", key_id = 29, group_id = 2}, 
	{name = "select", key_id = 0, group_id = 2}, 
	{name = "D-Pad left", key_id = 15, group_id = 2}, 
	{name = "D-Pad right", key_id = 74, group_id = 2}, 
	{name = "D-Pad up", key_id = 42, group_id = 2}, 
	{name = "D-Pad down", key_id = 19, group_id = 2}, 
	{name = "Right-stick left", key_id = 5, group_id = 2}, 
	{name = "Right-stick right", key_id = 1, group_id = 2}, 
	{name = "Right-stick up", key_id = 3, group_id = 2}, 
	{name = "Right-stick down", key_id = 2, group_id = 2}, 
	{name = "Left-stick left", key_id = 34, group_id = 2}, 
	{name = "Left-stick right", key_id = 9, group_id = 2}, 
	{name = "Left-stick up", key_id = 32, group_id = 2}, 
	{name = "Left-stick down", key_id = 8, group_id = 2}
})

keys_and_input.KEYBOARD_KEYS = essentials.const_all({
	{name = "A", key_id = 34, group_id = 0},
	{name = "B", key_id = 29, group_id = 0},
	{name = "C", key_id = 26, group_id = 0},
	{name = "D", key_id = 35, group_id = 0},
	{name = "E", key_id = 46, group_id = 0},
	{name = "F", key_id = 49, group_id = 0},
	{name = "G", key_id = 183, group_id = 0},
	{name = "H", key_id = 74, group_id = 0},
	{name = "K", key_id = 311, group_id = 0},
	{name = "L", key_id = 7, group_id = 0},
	{name = "M", key_id = 301, group_id = 0},
	{name = "N", key_id = 249, group_id = 0},
	{name = "P", key_id = 199, group_id = 0},
	{name = "Q", key_id = 44, group_id = 0},
	{name = "R", key_id = 45, group_id = 0},
	{name = "S", key_id = 33, group_id = 0},
	{name = "T", key_id = 245, group_id = 0},
	{name = "U", key_id = 303, group_id = 0},
	{name = "V", key_id = 0, group_id = 0},
	{name = "W", key_id = 32, group_id = 0},
	{name = "X", key_id = 252, group_id = 0},
	{name = "Y", key_id = 246, group_id = 0},
	{name = "Up", key_id = 172, group_id = 0},
	{name = "Down", key_id = 173, group_id = 0},
	{name = "Left", key_id = 174, group_id = 0},
	{name = "Right", key_id = 175, group_id = 0},
	{name = "Alt", key_id = 19, group_id = 0},
	{name = "f1", key_id = 288, group_id = 0},
	{name = "f2", key_id = 289, group_id = 0},
	{name = "f3", key_id = 170, group_id = 0},
	{name = "f5", key_id = 166, group_id = 0},
	{name = "f6", key_id = 167, group_id = 0},
	{name = "f7", key_id = 168, group_id = 0},
	{name = "f8", key_id = 169, group_id = 0},
	{name = "f9", key_id = 56, group_id = 0},
	{name = "f10", key_id = 57, group_id = 0},
	{name = "f11", key_id = 344, group_id = 0},
	{name = "1", key_id = 157, group_id = 0},
	{name = "2", key_id = 158, group_id = 0},
	{name = "3", key_id = 160, group_id = 0},
	{name = "4", key_id = 164, group_id = 0},
	{name = "5", key_id = 165, group_id = 0},
	{name = "6", key_id = 159, group_id = 0},
	{name = "7", key_id = 161, group_id = 0},
	{name = "8", key_id = 162, group_id = 0},
	{name = "9", key_id = 163, group_id = 0},
	{name = "Shift", key_id = 21, group_id = 0},
	{name = "Break", key_id = 3, group_id = 0},
	{name = "Scroll down", key_id = 14, group_id = 0},
	{name = "Scroll up", key_id = 15, group_id = 0},
	{name = "Lmouse", key_id = 142, group_id = 0},
	{name = "Rmouse", key_id = 114, group_id = 0},
	{name = "Ctrl", key_id = 132, group_id = 0},
	{name = "Num 4", key_id = 124, group_id = 0},
	{name = "Num 5", key_id = 128, group_id = 0},
	{name = "Num 6", key_id = 125, group_id = 0},
	{name = "Num 7", key_id = 117, group_id = 0},
	{name = "Num 8", key_id = 127, group_id = 0},
	{name = "Num 9", key_id = 118, group_id = 0},
	{name = "Space", key_id = 143, group_id = 0},
	{name = "Insert", key_id = 121, group_id = 0},
	{name = "Caps lock", key_id = 137, group_id = 0},
	{name = "Delete", key_id = 178, group_id = 0},
	{name = "Tab", key_id = 192, group_id = 0},
	{name = "Backspace", key_id = 194, group_id = 0},
	{name = "Esc", key_id = 200, group_id = 0},
	{name = "Page down", key_id = 207, group_id = 0},
	{name = "Page up", key_id = 208, group_id = 0},
	{name = "Home", key_id = 212, group_id = 0},
	{name = "Enter", key_id = 215, group_id = 0},
	{name = "Num plus", key_id = 314, group_id = 0},
	{name = "Num minus", key_id = 315, group_id = 0}
})

local mouse_inputs <const> = essentials.const_all({
	{name = "Scroll down", key_id = 14, group_id = 0},
	{name = "Scroll up", key_id = 15, group_id = 0},
	{name = "Mouse down", key_id = 332, group_id = 0},
	{name = "Mouse right", key_id = 333, group_id = 0},
	{name = "Lmouse", key_id = 142, group_id = 0},
	{name = "Rmouse", key_id = 114, group_id = 0}
})

function keys_and_input.get_input(...)
	local title <const>,
	default <const>,
	len <const>,
	Type <const> = ...
	
	essentials.assert(math.type(len) == "integer"
	and math.type(Type) == "integer"
	and type(title) == "string"
	and (type(default) == "string" or default == nil),
		"Invalid arguments to get_input.", len, Type, title, default)

	essentials.assert(utf8.len(title or ""), "Invalid utf8 in input title.")
	essentials.assert(utf8.len(default or ""), "Invalid utf8 in input default.")

	local Keys <const> = essentials.const(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect"))
	keys_and_input.do_vk(10000, Keys)
	local input_status, text = nil, ""
	repeat
		input_status, text = input.get(title, default or "", len, Type)
		system.yield(0)
	until input_status ~= 1
	keys_and_input.do_vk(10000, Keys)
	if not text or input_status == 2 then
		essentials.msg(lang["Cancelled."], "blue", true)
		return "", 2
	else
		return text, 0
	end
end

do
	local get_info <const> = essentials.const({
		vehicle = {
			hash = vehicle_mapper.get_hash_from_user_input,
			name = vehicle_mapper.get_english_name_regardless_of_game_language
		},
		ped = {
			hash = ped_mapper.get_hash_from_user_input,
			name = ped_mapper.get_model_from_hash
		},
		object = {
			hash = object_mapper.get_hash_from_user_input,
			name = object_mapper.GetModelFromHash
		}
	})

	function keys_and_input.input_user_entity(Type)
		local input, status, default, hash
		repeat
			input, status = keys_and_input.get_input(lang["Type in name of entity."], default or "", 128, 0)
			hash = get_info[Type].hash(input:lower())
			if input ~= "?" and not streaming.is_model_valid(hash) then
				default = input
				essentials.msg(lang["Invalid model name."], "red", true, 6)
			end
		until status == 2 or streaming.is_model_valid(hash) or input == "?"
		if status == 2 then -- Getting model from hash raises error if invalid hash.
			return nil, status
		elseif input ~= "?" then
			return get_info[Type].name(hash), status
		else
			return input, status
		end
	end
end

do
	function keys_and_input.input_number_for_feat(...)
		local feature <const>, input_title <const> = ...
		local input_type = 3 -- Integer input type
		if essentials.FEATURE_ID_MAP[feature.type]:find("_f", 1, true) 
		or essentials.FEATURE_ID_MAP[feature.type]:find("slider", 1, true) then
			input_type = 5 -- Float input type
		end
		local input <const>, status <const> = keys_and_input.get_input(input_title, "", #tostring(feature.max) + (feature.min < 0 and 1 or 0), input_type)
		if status == 2 then
			return
		end
		local value <const> = tonumber(input)
		essentials.assert(type(value) == "number", "Attempt to change value property to a non number value.", value, type(value))
		if value <= feature.min then
			feature.value = feature.min
		elseif feature.max >= value then
			feature.value = value
		else
			feature.value = feature.max
		end
	end
end

function keys_and_input.is_table_of_virtual_keys_all_pressed(...)
	local keys <const> = ...
	for i = 1, #keys do
		local Key <const> = MenuKey()
		Key:push_vk(keys[i])
		if not Key:is_down_stepped() then
			return false
		end
	end
	return true
end

function keys_and_input.is_table_of_gta_keys_all_pressed(keys, controller_type)
	for i = 1, #keys do
		if not keys_and_input.is_key_pressed(controller_type, keys[i]) then
			return false
		end
	end
	return true
end

function keys_and_input.is_key_pressed(group, key)
	return controls.is_control_pressed(group, key) or controls.is_disabled_control_pressed(group, key)
end

function keys_and_input.do_table_of_gta_keys(...)
	local keys <const>,
	controller_type <const>,
	time <const> = ...
	local time <const> = utils.time_ms() + time
	while keys_and_input.is_table_of_gta_keys_all_pressed(keys, controller_type) and time > utils.time_ms() do
		system.yield(0)
	end
end

function keys_and_input.get_virtual_key_of_2take1_bind(...)
	local bind_name <const> = ...
	local file <close> = io.open(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\2Take1Menu.ini")
	essentials.assert(io.type(file) == "file", "Failed to open 2Take1Menu.ini")
	local Key = file:read("*a")
	essentials.assert(Key, "Failed to obtain virtual key from 2Take1Menu.ini.", Key)
	Key = Key:match(bind_name.."=([%w_%+]+)\n")
	local keys <const> = {}
	for key in Key:gmatch("([_%w]+)%+?") do
		for name, _ in pairs(enums.menu_keys_to_vk) do
			if name:upper() == key:upper() then
				keys[#keys + 1] = enums.menu_keys_to_vk[key:upper()]
				break
			end
		end
	end
	return keys
end

function keys_and_input.is_2take1_menu_hotkey_pressed(bind_name)
	local keys <const> = keys_and_input.get_virtual_key_of_2take1_bind(bind_name)
	return keys_and_input.is_table_of_virtual_keys_all_pressed(keys)
end

function keys_and_input.do_key(...)
	local controller_type <const>,
	key <const>,
	t <const> = ...
	local time <const> = utils.time_ms() + t
	while keys_and_input.is_key_pressed(controller_type, key) and time > utils.time_ms() do
		system.yield(0)
	end
end

function keys_and_input.do_vk(...)
	local time, virtual_keys <const> = ...
	time = utils.time_ms() + time
	while keys_and_input.is_table_of_virtual_keys_all_pressed(virtual_keys) and time > utils.time_ms() do
		system.yield(0)
	end
end

return essentials.const_all(keys_and_input)