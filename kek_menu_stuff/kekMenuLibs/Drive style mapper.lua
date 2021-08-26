-- Lib Drive style mapper version: 1.0.0
-- Copyright © 2020-2021 Kektram

local kek_drive_style_mapper = {}

local drive_style_properties = 
	{
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
		{"Avoid highways", 1 << 29},
		{"Unknown", 1 << 6},
		{"Unknown", 1 << 23},
		{"Unknown", 1 << 11},
		{"Unknown", 1 << 12},
		{"Unknown", 1 << 13},
		{"Unknown", 1 << 14},
		{"Unknown", 1 << 15},
		{"Unknown", 1 << 16},
		{"Unknown", 1 << 17},
		{"Unknown", 1 << 20},
		{"Unknown", 1 << 21},
		{"Unknown", 1 << 25},
		{"Unknown", 1 << 26},
		{"Unknown", 1 << 27},
		{"Unknown", 1 << 28},
		{"Unknown", 1 << 30}
	}

function kek_drive_style_mapper.get_drive_style_property_from_name(name)
	for i, drive_style_property in pairs(drive_style_properties) do
		if drive_style_property[1] == name then
			return drive_style_property[2]
		end
	end
end

function kek_drive_style_mapper.get_drive_style_property_name_from_int(int)
	for i, drive_style_property in pairs(drive_style_properties) do
		if drive_style_property[2] == int then
			return drive_style_property[1]
		end
	end
end

function kek_drive_style_mapper.get_drive_style_table()
	return drive_style_properties
end

return kek_drive_style_mapper