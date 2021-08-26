-- Lib Key mapper version: 1.0.5
-- Copyright © 2020-2021 Kektram
local key_mapper = {}

key_mapper.CONTROLLER_KEYS =
	{
		{"A", 18, 2},
		{"B", 45, 2}, 
		{"X", 22, 2}, 
		{"Y", 23, 2}, 
		{"LB", 37, 2}, 
		{"RB", 44, 2}, 
		{"L2", 10, 2}, 
		{"R2", 11, 2}, 
		{"L3", 28, 2}, 
		{"R3", 29, 2}, 
		{"select", 0, 2}, 
		{"D-Pad left", 15, 2}, 
		{"D-Pad right", 74, 2}, 
		{"D-Pad up", 27, 2}, 
		{"D-Pad down", 19, 2}, 
		{"Right-stick left", 5, 2}, 
		{"Right-stick right", 1, 2}, 
		{"Right-stick up", 3, 2}, 
		{"Right-stick down", 2, 2}, 
		{"Left-stick left", 34, 2}, 
		{"Left-stick right", 9, 2}, 
		{"Left-stick up", 32, 2}, 
		{"Left-stick down", 8, 2}
	}

key_mapper.KEYBOARD_KEYS = 
	{
		{"A", 34, 0},
		{"B", 29, 0},
		{"C", 26, 0},
		{"D", 35, 0},
		{"E", 46, 0},
		{"F", 49, 0},
		{"G", 183, 0},
		{"H", 74, 0},
		{"K", 311, 0},
		{"L", 7, 0},
		{"M", 301, 0},
		{"N", 249, 0},
		{"P", 199, 0},
		{"Q", 44, 0},
		{"R", 45, 0},
		{"S", 33, 0},
		{"T", 245, 0},
		{"U", 303, 0},
		{"V", 0, 0},
		{"W", 32, 0},
		{"X", 252, 0},
		{"Y", 246, 0},
		{"Up", 172, 0},
		{"Down", 173, 0},
		{"Left", 174, 0},
		{"Right", 175, 0},
		{"Alt", 19, 0},
		{"f1", 288, 0},
		{"f2", 289, 0},
		{"f3", 170, 0},
		{"f5", 166, 0},
		{"f6", 167, 0},
		{"f7", 168, 0},
		{"f8", 169, 0},
		{"f9", 56, 0},
		{"f10", 57, 0},
		{"f11", 344, 0},
		{"1", 157, 0},
		{"2", 158, 0},
		{"3", 160, 0},
		{"4", 164, 0},
		{"5", 165, 0},
		{"6", 159, 0},
		{"7", 161, 0},
		{"8", 162, 0},
		{"9", 163, 0},
		{"Shift", 21, 0},
		{"Break", 3, 0},
		{"Scroll down", 14, 0},
		{"Scroll up", 15, 0},
		{"Lmouse", 142, 0},
		{"Rmouse", 114, 0},
		{"Ctrl", 132, 0},
		{"Num 4", 124, 0},
		{"Num 5", 128, 0},
		{"Num 6", 125, 0},
		{"Num 7", 117, 0},
		{"Num 8", 127, 0},
		{"Num 9", 118, 0},
		{"Space", 143, 0},
		{"Insert", 121, 0},
		{"Caps lock", 137, 0},
		{"Delete", 178, 0},
		{"Tab", 192, 0},
		{"Backspace", 194, 0},
		{"Esc", 200, 0},
		{"Page down", 207, 0},
		{"Page up", 208, 0},
		{"Home", 212, 0},
		{"Enter", 215, 0},
		{"Num plus", 314, 0},
		{"Num minus", 315, 0}
	}

local mouse_inputs =
	{
		{"Scroll down", 14, 0},
		{"Scroll up", 15, 0},
		{"Mouse down", 332, 0},
		{"Mouse right", 333, 0},
		{"Lmouse", 142, 0},
		{"Rmouse", 114, 0}
	}

local menu_keys_to_vk = {
	["NUM5"] = 0x65,
	["RETURN"] = 0x0D,
	["CLEAR"] = 0xC,
	["NUM0"] = 0x60,
	["NUM1"] = 0x61,
	["NUM2"] = 0x62,
	["NUM3"] = 0x63,
	["NUM4"] = 0x64,
	["NUM6"] = 0x66,
	["NUM7"] = 0x67,
	["NUM8"] = 0x68,
	["NUM9"] = 0x69,
	["NUM+"] = 0xBB,
	["NUM-"] = 0xBD,
	["0"] = 0x30,
	["1"] = 0x31,
	["2"] = 0x32,
	["3"] = 0x33,
	["4"] = 0x34,
	["5"] = 0x35,
	["6"] = 0x36,
	["7"] = 0x37,
	["8"] = 0x38,
	["9"] = 0x39,
	["A"] = 0x41,
	["B"] = 0x42,
	["C"] = 0x43,
	["D"] = 0x44,
	["E"] = 0x45,
	["F"] = 0x46,
	["G"] = 0x47,
	["H"] = 0x48,
	["I"] = 0x49,
	["J"] = 0x4A,
	["K"] = 0x4B,
	["L"] = 0x4C,
	["M"] = 0x4D,
	["N"] = 0x4E,
	["O"] = 0x4F,
	["P"] = 0x50,
	["Q"] = 0x51,
	["R"] = 0x52,
	["S"] = 0x53,
	["T"] = 0x54,
	["U"] = 0x55,
	["V"] = 0x56,
	["W"] = 0x57,
	["X"] = 0x58,
	["Y"] = 0x59,
	["Z"] = 0x5A,
	["END"] = 0x23,
	["F1"] = 0x70,
	["F2"] = 0x71,
	["F3"] = 0x72,
	["F4"] = 0x73,
	["F5"] = 0x74,
	["F6"] = 0x75,
	["F7"] = 0x76,
	["F8"] = 0x77,
	["F9"] = 0x78,
	["F10"] = 0x79,
	["F11"] = 0x7A,
	["F12"] = 0x7B,
	["LSHIFT"] = 0xA0,
	["RSHIFT"] = 0xA1,
	["LCONTROL"] = 0xA2,
	["RCONTROL"] = 0xA3,
	["NUMLOCK"] = 0x90,
	["SCROLLLOCK"] = 0x91,
	["BACKSPACE"] = 0x08,
	["TAB"] = 0x09,
	["ALT"] = 0x12,
	["PAUSE"] = 0x13,
	["PRINTSCREEN"] = 0x2C,
	["INSERT"] = 0x2D,
	["DELETE"] = 0x2E,
	["PERIOD"] = 0xBE,
	["COMMA"] = 0xBC,
	["CAPSLOCK"] = 0x14,
	["HOME"] = 0x24,
	["QUESTIONMARK"] = 0xBF,
	["~"] = 0xC0,
	["ESCAPESEQ"] = 0xDC,
	["APOSTROPHE"] = 0xDE,
	["Æ"] = 0x28,
	["Ø"] = 0x27,
	["Å"] = 0x1A

}

function key_mapper.is_table_of_virtual_keys_all_pressed(keys)
	for i = 1, #keys do
		local Key = MenuKey()
		Key:push_vk(keys[i])
		if not Key:is_down_stepped() then
			return false
		end
	end
	return true
end

function key_mapper.is_table_of_gta_keys_all_pressed(keys, controller_type)
	for i = 1, #keys do
		if not controls.is_disabled_control_pressed(controller_type, keys[i]) then
			return false
		end
	end
	return true
end

function key_mapper.do_table_of_gta_keys(keys, controller_type, time)
	local time = utils.time_ms() + time
	while key_mapper.is_table_of_gta_keys_all_pressed(keys, controller_type) and time > utils.time_ms() do
		system.yield(0)
	end
end

function key_mapper.get_virtual_key_of_2take1_bind(bind_name)
	local file = io.open(utils.get_appdata_path("PopstarDevs", "").."\\2Take1Menu\\2Take1Menu.ini")
	if file then
		local Key = file:read("*a")
		file:close()
		if Key then
			Key = Key:match(bind_name.."=([%w_%+]+)\n")
		end
		if Key then
			local keys = {}
			for key in Key:gmatch("([_%w]+)%+?") do
				local Key = -1
				for name, vk in pairs(menu_keys_to_vk) do
					if name:upper() == key:upper() then
						keys[#keys + 1] = menu_keys_to_vk[key:upper()]
						break
					end
				end
			end
			return keys
		end
	end
	return {}
end

function key_mapper.is_2take1_menu_hotkey_pressed(bind_name)
	return key_mapper.is_table_of_virtual_keys_all_pressed(key_mapper.get_virtual_key_of_2take1_bind(bind_name))
end

function key_mapper.do_key(group, key, t)
	system.yield(0)
	local time = utils.time_ms() + t
	while controls.is_disabled_control_pressed(group, key) and time > utils.time_ms() do
		system.yield(0)
	end
end

function key_mapper.do_vk(t, virtual_keys)
	local time = utils.time_ms() + t
	while key_mapper.is_table_of_virtual_keys_all_pressed(virtual_keys) and time > utils.time_ms() do
		system.yield(0)
	end
end

function key_mapper.get_keyboard_key_from_name(key)
	for i, key_name in pairs(key_mapper.KEYBOARD_KEYS) do
		if key_name[1] == key then
			return key_name[2], key_name[3]
		end
	end
	return -1
end

function key_mapper.get_controller_key_from_name(key)
	for i, key_name in pairs(key_mapper.CONTROLLER_KEYS) do
		if key_name[1] == key then
			return key_name[2], key_name[3]
		end
	end
	return -1
end

function key_mapper.get_keyboard_key_name_from_control_int(key)
	for i, key_name in pairs(key_mapper.KEYBOARD_KEYS) do
		if key_name[2] == key then
			return key_name[1]
		end
	end
	return "off"
end

function key_mapper.get_controller_key_name_from_control_int(key)
	for i, key_name in pairs(key_mapper.CONTROLLER_KEYS) do
		if key_name[2] == key then
			return key_name[1]
		end
	end
	return "off"
end

function key_mapper.get_keyboard_key_control_int_from_name(key)
	for i, key_name in pairs(key_mapper.KEYBOARD_KEYS) do
		if key_name[1] == key then
			return key_name[2]
		end
	end
	return -1
end

function key_mapper.get_controller_key_control_int_from_name(key)
	for i, key_name in pairs(key_mapper.CONTROLLER_KEYS) do
		if key_name[1] == key then
			return key_name[2]
		end
	end
	return -1
end

return key_mapper
