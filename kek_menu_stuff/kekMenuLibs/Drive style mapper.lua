-- Copyright © 2020-2021 Kektram

kek_menu.lib_versions["Drive style mapper"] = "1.0.3"
local essentials <const> = kek_menu.require("Essentials")
local enums <const> = kek_menu.require("Enums")

local drive_style_mapper <const> = {}

drive_style_mapper.DRIVE_STYLE_FLAGS = table.const_all({
	{name = "Stop before vehicles", flag = 1 << 0},
	{name = "Stop before peds", flag = 1 << 1},
	{name = "Avoid vehicles", flag = 1 << 2},
	{name = "Avoid empty vehicles", flag = 1 << 3},
	{name = "Avoid peds", flag = 1 << 4},
	{name = "Avoid objects", flag = 1 << 5},
	{name = "Stop at traffic lights", flag = 1 << 7},
	{name = "Use blinkers", flag = 1 << 8},
	{name = "Allow going wrong way", flag = 1 << 9},
	{name = "Drive in reverse", flag = 1 << 10},
	{name = "Take shortest path", flag = 1 << 18},
	{name = "Allow overtaking vehicles", flag = 1 << 19},
	{name = "Ignore roads", flag = 1 << 22},
	{name = "Ignore all pathing", flag = 1 << 24},
	{name = "Avoid highways", flag = 1 << 29}
})

function drive_style_mapper.get_drive_style_property_from_name(...)
	local name <const> = ...
	for _, drive_style_property in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if drive_style_property.name == name then
			return drive_style_property.flag
		end
	end
	essentials.assert(false, "Failed to get drive style flag from name.")
end

function drive_style_mapper.get_drive_style_property_name_from_int(...)
	local int <const> = ...
	for _, drive_style_property in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if drive_style_property.flag == int then
			return drive_style_property.name
		end
	end
	essentials.assert(false, "Failed to get drive style name from flag.")
end

return drive_style_mapper