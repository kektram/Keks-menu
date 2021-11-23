-- Copyright © 2020-2021 Kektram

kek_menu.lib_versions["Drive style mapper"] = "1.0.2"
local essentials = kek_menu.require("Essentials")

local drive_style_mapper = {}

drive_style_mapper.DRIVE_STYLE_FLAGS = {
	{"Stop before vehicles", 1 << 0},
	{"Stop before peds", 1 << 1},
	{"Avoid vehicles", 1 << 2},
	{"Avoid empty vehicles", 1 << 3},
	{"Avoid peds", 1 << 4},
	{"Avoid objects", 1 << 5},
	{"Stop at traffic lights", 1 << 7},
	{"Use blinkers", 1 << 8},
	{"Allow going wrong way", 1 << 9},
	{"Drive in reverse", 1 << 10},
	{"Take shortest path", 1 << 18},
	{"Allow overtaking vehicles", 1 << 19},
	{"Ignore roads", 1 << 22},
	{"Ignore all pathing", 1 << 24},
	{"Avoid highways", 1 << 29}
}
setmetatable(drive_style_mapper.DRIVE_STYLE_FLAGS, essentials.get_read_only_meta())

function drive_style_mapper.get_drive_style_property_from_name(...)
	local name <const> = ...
	for i, drive_style_property in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if drive_style_property[1] == name then
			return drive_style_property[2]
		end
	end
end

function drive_style_mapper.get_drive_style_property_name_from_int(...)
	local int <const> = ...
	for i, drive_style_property in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if drive_style_property[2] == int then
			return drive_style_property[1]
		end
	end
end

return drive_style_mapper