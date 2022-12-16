-- Copyright © 2020-2022 Kektram

local essentials <const> = require("Kek's Essentials")

local drive_style_mapper <const> = {version = "1.0.5"}

-- Comments with * were from a Rockstar developer.
drive_style_mapper.DRIVE_STYLE_FLAGS = essentials.const_all({ -- Entries are tables to get consistent order of indices
	{name = "Stop before vehicles", flag = 1 << 0},
	{name = "Stop before peds", flag = 1 << 1},
	{name = "Avoid vehicles", flag = 1 << 2},
	{name = "Avoid empty vehicles", flag = 1 << 3},
	{name = "Avoid peds", flag = 1 << 4},
	{name = "Avoid objects", flag = 1 << 5},
	{name = "Avoid player peds", flag = 1 << 6},
	{name = "Stop at traffic lights", flag = 1 << 7},
	{name = "Allow offroad when avoiding", flag = 1 << 8},
	{name = "Allow driving into traffic", flag = 1 << 9},
	{name = "Drive in reverse", flag = 1 << 10},
	{name = "Wander randomly if pathing fails", flag = 1 << 11},
	{name = "Avoid restricted areas", flag = 1 << 12},

	-- These only work on MISSION_CRUISE *
	--{name = "DF_PreventBackgroundPathfinding", flag = 1 << 13},
	--{name = "DF_AdjustCruiseSpeedBasedOnRoadSpeed", flag = 1 << 14},

	{name = "Take shortest path", flag = 1 << 18},
	{name = "Allow overtaking vehicles", flag = 1 << 19}, -- Only works for planes using MISSION_GOTO, will cause them to drive along the ground instead of fly *
	-- {name = "Use switched off nodes", flag = 1 << 21}, cruise tasks ignore this anyway--only used for goto's *
	{name = "Ignore roads", flag = 1 << 22},
	{name = "Ignore all pathing", flag = 1 << 24},
	{name = "Use string pulling at junctions", flag = 1 << 25},
	{name = "Avoid highways", flag = 1 << 29},
	{name = "Force join in road direction", flag = 1 << 30}
})

function drive_style_mapper.get_drive_style_from_list(list)
--[[
	An example of a list:
	{
		"Drive in reverse",
		"Avoid objects",
		"Avoid vehicles"
	}
--]]

	local drive_style = 0
	for i = 1, #list do
		for i2 = 1, #drive_style_mapper.DRIVE_STYLE_FLAGS do
			if list[i] == drive_style_mapper.DRIVE_STYLE_FLAGS[i2].name then
				drive_style = drive_style ~ drive_style_mapper.DRIVE_STYLE_FLAGS[i2].flag
			end
		end
	end
	return drive_style
end

return essentials.const_all(drive_style_mapper)