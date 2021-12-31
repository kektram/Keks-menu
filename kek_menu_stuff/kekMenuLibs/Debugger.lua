-- Copyright © 2020-2021 Kektram
-- Version 1.0.0
--[[
	This tool will detect invalid use of 2take1 api functions.
	The invalid uses this tool raises errors for aren't by default.
	Passing a ped to a vehicle function might cause a crash, might cause nothing to happen, you don't know.
--]]
local function deep_copy(Table, keep_meta, seen)
	local new_copy <const> = {}
	seen = seen or {}
	for key, value in pairs(Table) do
		if type(value) == "table" then
			assert(not seen[value], "Tried to deep copy a table with a reference to itself.")
			seen[value] = true
			new_copy[key] = deep_copy(value, keep_meta, seen)
			if keep_meta and type(getmetatable(value)) == "table" then
				assert(not seen[getmetatable(value)], "Tried to deep copy a table with a reference to one of its own member's metatable.")
				seen[getmetatable(value)] = true
				setmetatable(new_copy[key], deep_copy(getmetatable(value), true, seen))
			end
		else
			new_copy[key] = value
		end
	end
	if keep_meta and type(getmetatable(Table)) == "table" then
		assert(not seen[getmetatable(Table)], "Tried to deep copy a table with a reference to its own metatable.")
		seen[getmetatable(Table)] = true
		setmetatable(new_copy, deep_copy(getmetatable(Table), true, seen))
	end
	return new_copy
end

local originals_newindexes <const> = {
	menu = getmetatable(menu).__newindex,
	event = getmetatable(event).__newindex,
	input = getmetatable(input).__newindex,
	player = getmetatable(player).__newindex,
	ped = getmetatable(ped).__newindex,
	vehicle = getmetatable(vehicle).__newindex,
	entity = getmetatable(entity).__newindex,
	object = getmetatable(object).__newindex,
	weapon = getmetatable(weapon).__newindex,
	streaming = getmetatable(streaming).__newindex,
	ui = getmetatable(ui).__newindex,
	gameplay = getmetatable(gameplay).__newindex,
	fire = getmetatable(fire).__newindex,
	network = getmetatable(network).__newindex,
	graphics = getmetatable(graphics).__newindex,
	ai = getmetatable(ai).__newindex,
	decorator = getmetatable(decorator).__newindex,
	script = getmetatable(script).__newindex,
	utils = getmetatable(utils).__newindex
}

local originals <const> = deep_copy({
	menu = menu,
	event = event,
	input = input,
	player = player,
	ped = ped,
	vehicle = vehicle,
	entity = entity,
	object = object,
	weapon = weapon,
	streaming = streaming,
	ui = ui,
	gameplay = gameplay,
	fire = fire,
	network = network,
	graphics = graphics,
	ai = ai,
	decorator = decorator,
	script = script,
	utils = utils,
	system = system
})

for name, value in pairs(_G) do
	if originals_newindexes[name] then
		getmetatable(_G[name]).__newindex = nil
	end
end

-- Event functions
do
	function event.add_event_listener(eventName, id)
		assert(eventName == "chat" 
		or eventName == "exit"
		or eventName == "player_leave"
		or eventName == "player_join"
		or eventName == "script", "Invalid event listener type.")
		return originals.event.add_event_listener(eventName, id)
	end

	function event.remove_event_listener(eventName, id)
		assert(eventName == "chat" 
		or eventName == "exit"
		or eventName == "player_leave"
		or eventName == "player_join"
		or eventName == "script", "Invalid event listener type.")
		return originals.event.remove_event_listener(eventName, id)
	end
end

-- Player functions
do
	for name, func in pairs(player) do
		player[name] = function(...)
			local pid <const> = ...
			assert(pid >= 0 and pid <= 31, "Invalid pid.")
			return originals.player[name](...)
		end
	end

	local function_names <const> = {
		"player_id",
		"get_personal_vehicle",
		"set_local_player_visible_locally",
		"player_count",
		"get_host",
		"get_modder_flag_text",
		"get_modder_flag_ends",
		"add_modder_flag",
		"set_player_targeting_mode"
	}

	for _, func_name in pairs(function_names) do
		player[func_name] = originals.player[func_name]
	end

	function player.set_player_model(hash)
		assert(streaming.is_model_valid(hash), "Tried to set player model to invalid hash.")
		originals.player.set_player_model(hash)
	end

	function player.get_player_from_ped(Ped)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		return originals.player.get_player_from_ped(Ped)
	end

	function script.trigger_script_event(eventId, pid, params)
		assert(pid >= 0 and pid <= 31, "Invalid pid.")
		originals.script.trigger_script_event(eventId, pid, params)
	end
end

-- Ped functions
do
	for name, func in pairs(ped) do
		ped[name] = function(...)
			local Ped <const> = ...
			assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
			return originals.ped[name](...)
		end
	end

	local function_names <const> = {
		"set_group_formation",
		"get_group_size",
		"set_ped_density_multiplier_this_frame",
		"set_scenario_ped_density_multiplier_this_frame",
		"get_all_peds",
		"create_group",
		"remove_group",
		"set_group_formation_spacing",
		"reset_group_formation_default_spacing",
		"does_group_exist",
		"set_create_random_cops",
		"can_create_random_cops",
		"clear_relationship_between_groups",
		"set_relationship_between_groups"
	}
	
	for _, func_name in pairs(function_names) do
		ped[func_name] = originals.ped[func_name]
	end

	function ped.set_ped_into_vehicle(Ped, Vehicle, seat)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected ped from argument Ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected vehicle from argument Vehicle.")
		assert(seat >= -2, seat <= vehicle.get_vehicle_max_number_of_passengers(Vehicle) - 2, "Invalid seat.")
		return originals.ped.set_ped_into_vehicle(Ped, Vehicle, seat)
	end

	function ped.is_ped_in_vehicle(Ped, Vehicle)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected ped from argument Ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected vehicle from argument Vehicle.")
		return originals.ped.is_ped_in_vehicle(Ped, Vehicle)
	end

	function ped.create_ped(type, model, pos, heading, isNetworked, unk1)
		assert(type >= -1 and type <= 29, "Invalid ped type.")
		assert(streaming.is_model_a_ped(model), "Tried to spawn ped with invalid hash.")
		return originals.ped.create_ped(type, model, pos, heading, isNetworked, unk1)
	end
end

-- Vehicle functions
do
	for name, func in pairs(vehicle) do
		vehicle[name] = function(...)
			local Vehicle <const> = ...
			assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
			return originals.vehicle[name](...)
		end
	end

	local function_names <const> = {
		"set_vehicle_density_multipliers_this_frame",
		"set_random_vehicle_density_multiplier_this_frame",
		"set_parked_vehicle_density_multiplier_this_frame",
		"set_ambient_vehicle_range_multiplier_this_frame",
		"has_vehicle_phone_explosive_device",
		"detonate_vehicle_phone_explosive_device",
		"get_all_vehicle_model_hashes",
		"get_all_vehicles"
	}

	for _, func_name in pairs(function_names) do
		vehicle[func_name] = originals.vehicle[func_name]
	end

	function vehicle.create_vehicle(model, pos, heading, networked, alwaysFalse)
		assert(streaming.is_model_a_vehicle(model), "Invalid hash for creating a vehicle.")
		return originals.vehicle.create_vehicle(model, pos, heading, networked, alwaysFalse)
	end

	function vehicle.get_vehicle_model_number_of_seats(modelHash)
		assert(streaming.is_model_a_vehicle(modelHash), "Expected a vehicle & valid model hash.")
		return originals.vehicle.get_vehicle_model_number_of_seats(modelHash)
	end

	function vehicle.set_vehicle_timed_explosion(Vehicle, Ped, toggle)
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		originals.vehicle.set_vehicle_timed_explosion(Vehicle, Ped, toggle)
	end
end

-- Weapon functions
do
	local function_names <const> = {
		"give_delayed_weapon_to_ped",
		"get_ped_weapon_tint_index",
		"set_ped_weapon_tint_index",
		"give_weapon_component_to_ped",
		"remove_all_ped_weapons",
		"remove_weapon_from_ped",
		"get_max_ammo",
		"set_ped_ammo",
		"remove_weapon_component_from_ped",
		"has_ped_got_weapon_component",
		"get_ped_ammo_type_from_weapon",
		"set_ped_ammo_by_type",
		"has_ped_got_weapon"
	}

	for _, func_name in pairs(function_names) do
		weapon[func_name] = function(...)
			local Ped <const> = ...
			assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
			return originals.weapon[func_name](...)
		end
	end
end

-- Fire functions
do
	function fire.add_explosion(pos, type, isAudible, isInvis, fCamShake, Ped)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(type >= 0 and type <= 83, "Invalid explosion type.")
		return originals.fire.add_explosion(pos, type, isAudible, isInvis, fCamShake, Ped)
	end

	function gameplay.shoot_single_bullet_between_coords(start, End, damage, weapon, Ped, audible, invisible, speed)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		return originals.gameplay.shoot_single_bullet_between_coords(start, End, damage, weapon, Ped, audible, invisible, speed)
	end
end

-- Network functions
do
	function network.network_session_kick_player(pid)
		assert(pid >= 0 and pid <= 31, "Invalid pid.")
		originals.network.network_session_kick_player(pid)
	end
	function network.network_hash_from_player(pid)
		assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return originals.network.network_hash_from_player(pid)
	end

	function network.get_entity_player_is_spectating(pid)
		assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return originals.network.get_entity_player_is_spectating(pid)
	end

	function network.get_player_player_is_spectating(pid)
		assert(pid >= 0 and pid <= 31, "Invalid pid.")
		return originals.network.get_player_player_is_spectating(pid)
	end
end

-- Ai functions
do
	for name, func in pairs(ai) do
		ai[name] = function(...)
			local Ped <const> = ...
			assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
			return originals.ai[name](...)
		end
	end

	local function_names <const> = {
		"task_shoot_at_entity",
		"task_goto_entity",
		"does_scenario_group_exist",
		"is_scenario_group_enabled",
		"set_scenario_group_enabled",
		"reset_scenario_groups_enabled",
		"set_exclusive_scenario_group",
		"reset_exclusive_scenario_group",
		"is_scenario_type_enabled",
		"set_scenario_type_enabled",
		"reset_scenario_types_enabled"
	}

	for _, func_name in pairs(function_names) do
		ai[func_name] = originals.ai[func_name]
	end

	function ai.task_vehicle_follow(Ped, Vehicle, Entity, speed, int, minDistance)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		assert(minDistance > 0, "Minimum distance must be more than 0.")
		originals.ai.task_vehicle_follow(Ped, Vehicle, Entity, speed, int, minDistance)
	end

	function ai.task_vehicle_drive_wander(Ped, Vehicle, speed, driveStyle)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		originals.ai.task_vehicle_drive_wander(Ped, Vehicle, speed, driveStyle)
	end

	function ai.task_vehicle_shoot_at_ped(Ped1, Ped2, a3)
		assert(not entity.is_an_entity(Ped1) or entity.is_entity_a_ped(Ped1), "Expected ped from argument Ped1.")
		assert(not entity.is_an_entity(Ped2) or entity.is_entity_a_ped(Ped2), "Expected ped from argument Ped2.")
		originals.ai.task_vehicle_shoot_at_ped(Ped1, Ped2, a3)
	end

	function ai.task_vehicle_aim_at_ped(Ped1, Ped2) 
		assert(not entity.is_an_entity(Ped1) or entity.is_entity_a_ped(Ped1), "Expected ped from argument Ped1.")
		assert(not entity.is_an_entity(Ped2) or entity.is_entity_a_ped(Ped2), "Expected ped from argument Ped2.")
		originals.ai.task_vehicle_aim_at_ped(Ped1, Ped2)
	end

	function ai.task_vehicle_drive_to_coord_longrange(Ped, Vehicle, pos, speed, mode, stopRange)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		originals.ai.task_vehicle_drive_to_coord_longrange(Ped, Vehicle, pos, speed, mode, stopRange)
	end

	function ai.task_vehicle_escort(Ped, Vehicle, Vehicle2, mode, speed, drivingStyle, minDistance, a8, noRoadsDistance)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		assert(not entity.is_an_entity(Vehicle2) or entity.is_entity_a_vehicle(Vehicle2), "Expected a vehicle.")
		originals.ai.task_vehicle_escort(Ped, Vehicle, Vehicle2, mode, speed, drivingStyle, minDistance, a8, noRoadsDistance)
	end

	function ai.task_vehicle_follow(Ped, Vehicle, targetEntity, speed, drivingStyle, minDistance)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		originals.ai.task_vehicle_follow(Ped, Vehicle, targetEntity, speed, drivingStyle, minDistance)
	end

	function ai.task_vehicle_drive_to_coord(Ped, Vehicle, coord, speed, a5, vehicleModel, driveMode, stopRange, a9)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		assert(streaming.is_model_a_vehicle(vehicleModel), "Expected a valid vehicle model.")
		originals.ai.task_vehicle_drive_to_coord(Ped, Vehicle, coord, speed, a5, vehicleModel, driveMode, stopRange, a9)
	end

	function ai.task_open_vehicle_door(Ped, Vehicle, timeOut, doorIndex, speed)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		originals.ai.task_open_vehicle_door(Ped, Vehicle, timeOut, doorIndex, speed)
	end

	function ai.task_enter_vehicle(Ped, Vehicle, timeout, seat, speed, flag, p6)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		originals.ai.task_enter_vehicle(Ped, Vehicle, timeout, seat, speed, flag, p6)
	end

	function ai.task_leave_vehicle(Ped, Vehicle, flag)
		assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped.")
		assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		originals.ai.task_leave_vehicle(Ped, Vehicle, flag)
	end
end

-- Misc functions
	function system.yield(ms)
		assert(math.type(ms) == "integer", "Expected integer.")
		originals.system.yield(ms)
	end

	function system.wait(ms)
		assert(math.type(ms) == "integer", "Expected integer.")
		originals.system.wait(ms)
	end

	function utils.get_all_files_in_directory(path, extension)
		assert(utils.dir_exists(path), "Tried to get all files from a directory that doesn't exist.")
		return originals.utils.get_all_files_in_directory(path, extension)
	end

-- Exceptions
	player.is_player_valid = originals.player.is_player_valid

for name, value in pairs(_G) do
	if originals_newindexes[name] then
		getmetatable(_G[name]).__newindex = originals_newindexes[name]
	end
end