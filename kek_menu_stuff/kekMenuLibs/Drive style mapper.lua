-- Copyright © 2020-2022 Kektram

local essentials <const> = require("Essentials")
local enums <const> = require("Enums")

local drive_style_mapper <const> = {version = "1.0.4"}

drive_style_mapper.DRIVE_STYLE_FLAGS = essentials.const_all({ -- Entries are tables to get consistent order of indices
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
	for _, properties in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if properties.name == name then
			return properties.flag
		end
	end
	essentials.assert(false, "Failed to get drive style flag from name.")
end

function drive_style_mapper.get_drive_style_property_name_from_int(...)
	local int <const> = ...
	for _, properties in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if properties.flag == int then
			return properties.name
		end
	end
	essentials.assert(false, "Failed to get drive style name from flag.")
end

function drive_style_mapper.get_drive_style_from_list(list)
	local drive_style = 0
	for _, drive_style_property in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
		if list[drive_style_property.name] then
			drive_style = drive_style ~ drive_style_property.flag
		end
	end
	return drive_style
end

return essentials.const_all(drive_style_mapper)