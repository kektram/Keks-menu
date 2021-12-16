-- Copyright © 2020-2021 Kektram

local kek_entity <const> = {version = "1.1.8"}

local language <const> = require("Language")
local lang <const> = language.lang
local location_mapper <const> = require("Location mapper")
local vehicle_mapper <const> = require("Vehicle mapper")
local essentials <const> = require("Essentials")
local enums <const> = require("Enums")
local keys_and_input <const> = require("Keys and input")
local object_mapper <const> = require("Object mapper")
local ped_mapper <const> = require("Ped mapper")
local settings <const> = require("Settings")

kek_entity.user_vehicles = {}

kek_entity.entity_manager = {
	entities = {},
	counts = {
		ped = 0.0, 
		object = 0.0, 
		vehicle = 0.0
	},
	limits = essentials.const({
		ped = 50.0,
		vehicle = 50.0,
		object = 210.0
	}),
	type_strings = essentials.const({
		[3] = "vehicle",
		[4] = "ped",
		[5] = "object"
	}),
	entity_type_to_return_type = setmetatable({
		[3] = "is_vehicle_limit_not_breached",
		[4] = "is_ped_limit_not_breached",
		[5] = "is_object_limit_not_breached"
	}, {
		__index = function()
			return "is_misc_limit_not_breached"
		end
	})
}
--[[
	The indices in type_strings & entity_type_to_return_type are based on entity.get_entity_model_hash.
	Entities have different weights, peds usually have 1.5, vehicle and objects 1.
	The count is incremented by these weights.
--]]

function kek_entity.entity_manager:update()
	for Entity, properties in pairs(self.entities) do
		if not entity.is_an_entity(Entity) then
			self.counts[properties.type] = self.counts[properties.type] - properties.weight
			self.entities[Entity] = nil
		end
	end
	return {
		is_ped_limit_not_breached = self.counts.ped <= self.limits.ped and #ped.get_all_peds() < 135.0,
		is_object_limit_not_breached = self.counts.object < self.limits.object and #object.get_all_objects() < 850.0, 
		is_vehicle_limit_not_breached = self.counts.vehicle < self.limits.vehicle and #vehicle.get_all_vehicles() < 135.0,
		is_misc_limit_not_breached = self.counts.ped + self.counts.vehicle + self.counts.object <= self.limits.ped + self.limits.vehicle,
		ped_count = self.counts.ped
	}
end

setmetatable(kek_entity.entity_manager, {
	__newindex = function(Table, Entity, weight)
		if entity.is_an_entity(Entity)
		and not Table.entities[Entity]
		and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity))
		and player.get_player_vehicle(player.player_id()) ~= Entity then
			local properties = {weight = weight}
			properties.type = Table.type_strings[entity.get_entity_type(Entity)] or "object"
			Table.counts[properties.type] = Table.counts[properties.type] + properties.weight
			Table.entities[Entity] = properties
		end
	end
})

function kek_entity.get_control_of_entity(...)
	local Entity <const>, time_to_wait <const>, no_condition <const> = ...
	if not network.has_control_of_entity(Entity) 
	and entity.is_an_entity(Entity) 
	and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) 
	and utils.time_ms() > essentials.new_session_timer
	and (no_condition or kek_entity.entity_manager:update()[kek_entity.entity_manager.entity_type_to_return_type[entity.get_entity_type(Entity)]]) then
		local time <const> = utils.time_ms() + (time_to_wait or 450)
		network.request_control_of_entity(Entity, true)
		while not network.has_control_of_entity(Entity) and entity.is_an_entity(Entity) and time > utils.time_ms() do
			system.yield(0)
		end
	end
	return network.has_control_of_entity(Entity)
end

local spawn_timer = 0
function kek_entity.spawn_entity(...)
	local hash <const>, 
	coords_and_heading <const>, 
	give_godmode <const>, 
	max_vehicle <const>, 
	ped_type <const>, 
	dont_disregard_hash_after_spawn <const>, 
	weight <const>, 
	not_dynamic_object <const>, 
	not_networked <const> = ...
	local Entity = 0
	essentials.assert(streaming.is_model_valid(hash), "Tried to use an invalid model hash.")
	essentials.assert(not object_mapper.BLACKLISTED_OBJECTS[hash], "Tried to spawn a blacklisted object.")
	essentials.assert(not ped_mapper.BLACKLISTED_PEDS[hash], "Tried to spawn a blacklisted ped.")
	if utils.time_ms() > essentials.new_session_timer then
		if not streaming.is_model_an_object(hash) then
			repeat
				system.yield(0)
			until utils.time_ms() >= spawn_timer or utils.time_ms() < essentials.new_session_timer
		end
		if utils.time_ms() > essentials.new_session_timer and (streaming.is_model_an_object(hash) or utils.time_ms() >= spawn_timer) then
			local status <const>, had_to_request_hash <const> = kek_entity.request_model(hash)
			if status then
				if not streaming.is_model_an_object(hash) then
					spawn_timer = utils.time_ms() + 2500
				end
				local coords <const>, dir <const> = coords_and_heading()
				essentials.assert(type(coords) == "userdata", "Invalid coordinates.")
				if streaming.is_model_a_vehicle(hash) then
					Entity = vehicle.create_vehicle(hash, coords, dir, not_networked ~= true, not_networked == true, weight)
					if max_vehicle then
						kek_entity.max_car(Entity)
					end	
					decorator.decor_set_int(Entity, "MPBitset", 1 << 10)
					system.yield(0)
				elseif streaming.is_model_a_ped(hash) then
					essentials.assert(ped_type >= -1 and ped_type <= 29, "Invalid ped type.")
					Entity = ped.create_ped(ped_type, hash, coords, dir, not_networked ~= true, not_networked == true, weight)
					system.yield(0)
				elseif streaming.is_model_a_world_object(hash) then
					Entity = object.create_world_object(hash, coords, not not_networked, not not_dynamic_object, weight)
				elseif streaming.is_model_an_object(hash) then
					Entity = object.create_object(hash, coords, not not_networked, not not_dynamic_object, weight)
				end
				if give_godmode then
					entity.set_entity_god_mode(Entity, true)
				end
				if had_to_request_hash and not dont_disregard_hash_after_spawn then
					streaming.set_model_as_no_longer_needed(hash)
				end
				if not streaming.is_model_an_object(hash) then
					spawn_timer = 0
				end
			end
		end
	end
	return Entity
end

function kek_entity.is_entity_valid(Entity)
	return entity.is_an_entity(Entity)
	and not entity.is_entity_static(Entity)
	and (not entity.is_entity_a_vehicle(Entity) or not vehicle.is_vehicle_stuck_on_roof(Entity))
	and (not entity.is_entity_a_ped(Entity) or not ai.is_task_active(Entity, enums.ctasks.DoNothing))
end

function kek_entity.teleport(...)
	local Entity <const>,
	coords <const>,
	time <const> = ...
	if kek_entity.get_control_of_entity(Entity, time) then
		entity.set_entity_coords_no_offset(Entity, coords)
		return true
	end
end

function kek_entity.is_any_tasks_active(...)
	local Ped <const>, tasks <const> = ...
	essentials.assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped from argument \"Ped\".")
	for _, task in pairs(tasks) do
		if ai.is_task_active(Ped, task) then
			return true
		end
	end
end

function kek_entity.is_target_viable(...)
	local pid <const>,
	is_a_toggle <const>,
	feature <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local had_to_teleport = false
	if player.is_player_valid(pid) and essentials.is_in_vehicle(pid) then
		local time <const> = utils.time_ms() + 1500
		while time > utils.time_ms() and essentials.is_in_vehicle(pid) do
			system.yield(0)
			if player.is_player_in_any_vehicle(pid) then
				return true, had_to_teleport
			else
				had_to_teleport = true
				kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), location_mapper.get_ground_z(player.get_player_coords(pid)) + v3(0, 0, 45))
			end
			if is_a_toggle and not feature.on then
				return false, had_to_teleport
			end
		end
	end
	return false, had_to_teleport
end

function kek_entity.remove_player_entities(...)
	local table_of_entities <const> = ...
	local new <const> = {}
	for _, Entity in pairs(table_of_entities) do
		if entity.is_an_entity(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
			local status = true
			if entity.is_entity_a_vehicle(Entity) then
				for pid in essentials.players(true) do
					if player.get_player_vehicle(pid) == Entity then
						status = false
						break
					end
				end
			end
			if status then
				new[#new + 1] = Entity
			end
		end
	end
	return new
end

function kek_entity.get_all_attached_entities(...)
	local Entity <const> = ...
	local entities <const> = {}
	local all_entities <const> = essentials.const(kek_entity.get_table_of_close_entity_type(6))
	for i = 1, #all_entities do
		if entity.get_entity_attached_to(all_entities[i]) == Entity and (not entity.is_entity_a_ped(all_entities[i]) or not ped.is_ped_a_player(all_entities[i])) then
			entities[#entities + 1] = all_entities[i]
			local attached_entities <const> = kek_entity.get_all_attached_entities(all_entities[i])
			table.move(attached_entities, 1, #attached_entities, #entities + 1, entities)
		end
	end
	return entities
end

function kek_entity.get_parent_of_attachment(...)
	local Entity <const> = ...
	if entity.is_entity_attached(Entity) then
		return kek_entity.get_parent_of_attachment(entity.get_entity_attached_to(Entity))
	else
		return Entity
	end
end

function kek_entity.hard_remove_entity_and_its_attachments(...)
	local Entity = ...
	if entity.is_an_entity(Entity) then
		Entity = kek_entity.get_parent_of_attachment(Entity)
		if entity.is_an_entity(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
			kek_entity.clear_entities(kek_entity.get_all_attached_entities(Entity))
			kek_entity.clear_entities({Entity})
		end
	end
end

function kek_entity.get_table_of_close_entity_type(...)
	local type <const> = ...
	if type == 1 then
		return vehicle.get_all_vehicles()
	elseif type == 2 then
		return ped.get_all_peds()
	elseif type == 3 then
		return object.get_all_objects()
	elseif type == 4 then
		return object.get_all_pickups()
	elseif type == 5 then
		return essentials.merge_tables(vehicle.get_all_vehicles(), {ped.get_all_peds()})
	elseif type == 6 then
		return essentials.merge_tables(vehicle.get_all_vehicles(), {ped.get_all_peds(), object.get_all_pickups(), object.get_all_objects()})
	else
		essentials.assert(false, "Invalid entity type.")
	end
end

function kek_entity.clear_entities(...)
	local table_of_entities = ...
	for i = 1, 2 do
		local count = 0
		local removed_entities = 0
		for i, Entity in pairs(table_of_entities) do
			essentials.assert(not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity), "Tried to delete a player ped.")
			network.request_control_of_entity(Entity)
			count = count + 1
			if network.has_control_of_entity(Entity) then
				ui.remove_blip(ui.get_blip_from_entity(Entity))
				entity.set_entity_as_mission_entity(Entity, false, true)
				entity.delete_entity(Entity)
				if not entity.is_an_entity(Entity) then
					removed_entities = removed_entities + 1
					table_of_entities[i] = nil
				end
			end
			if count % 16 == 15 then
				system.yield(0)
			end
		end
		if i == 1 and removed_entities ~= count then
			system.yield(0)
		end
	end
end			

function kek_entity.get_number_of_passengers(...)
	local car <const> = ...
	essentials.assert(not entity.is_an_entity(car) or entity.is_entity_a_vehicle(car), "Expected a vehicle from argument \"car\".")
	local passengers <const>, is_there_a_player_in_the_vehicle = {}
	for i = -1, vehicle.get_vehicle_max_number_of_passengers(car) - 2 do
		local Ped <const> = vehicle.get_ped_in_vehicle_seat(car, i)
		if entity.is_an_entity(Ped) then
			passengers[#passengers + 1] = Ped
			if ped.is_ped_a_player(Ped) and player.get_player_from_ped(Ped) ~= player.player_id() then
				is_there_a_player_in_the_vehicle = true
			end
		end
	end
	return passengers, is_there_a_player_in_the_vehicle
end

function kek_entity.is_player_in_vehicle(...)
	local Vehicle <const> = ...
	local player_in_vehicle, friend_in_vehicle
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		for i = -1, vehicle.get_vehicle_max_number_of_passengers(Vehicle) - 2 do
			local Ped <const> = vehicle.get_ped_in_vehicle_seat(Vehicle, i)
			if ped.is_ped_a_player(Ped) and network.is_scid_friend(player.get_player_scid(player.get_player_from_ped(Ped))) then
				friend_in_vehicle = true
			end
			if ped.is_ped_a_player(Ped) then
				player_in_vehicle = true
			end
		end
	end
	return player_in_vehicle, friend_in_vehicle
end

function kek_entity.request_model(...)
	local model_hash <const> = ...
	local is_hash_already_loaded <const> = not streaming.has_model_loaded(model_hash)
	essentials.assert(streaming.is_model_valid(model_hash), "Tried to request invalid model hash.")
	if is_hash_already_loaded then
		streaming.request_model(model_hash)
		local time <const> = utils.time_ms() + 450
		while not streaming.has_model_loaded(model_hash) and time > utils.time_ms() do
			system.yield(0)
		end
	end
	return streaming.has_model_loaded(model_hash), is_hash_already_loaded
end

function kek_entity.get_rotated_heading(...)
	local Entity <const>,
	angle <const>,
	pid <const>,
	heading = ...
	essentials.assert(not pid or (pid >= 0 and pid <= 31), "Invalid pid.")
	if not heading then
		if pid then
			heading = player.get_player_heading(pid)
		else
			heading = entity.get_entity_heading(Entity)
		end
	end
	heading = heading + angle
	if heading > 179.99999 then
		heading = -179.99999 + (math.abs(heading) - 179.99999)
	elseif heading < -179.99999 then
		heading = 179.99999 - (math.abs(heading) - 179.99999)
	end
	return heading
end

function kek_entity.get_vector_relative_to_entity(...)
	local Entity <const>,
	distance_from_entity <const>,
	angle <const>,
	get_z_axis <const>,
	pid <const> = ...
	essentials.assert(not pid or (pid >= 0 and pid <= 31), "Invalid pid.")
	local rot, heading = v3(), 0
	if pid then
		heading = kek_entity.get_rotated_heading(Entity, angle or 0, pid)
	else
		heading = entity.get_entity_heading(Entity)
	end
	local pos = entity.get_entity_coords(Entity)
	if get_z_axis then
		rot = entity.get_entity_rotation(Entity)
		rot.z = kek_entity.get_rotated_heading(Entity, angle or 0, nil, rot.z)
        rot:transformRotToDir()
		pos = pos + (rot * distance_from_entity)
	else
		heading = math.rad((heading - 180) * -1)
		pos.x = pos.x + (math.sin(heading) * -distance_from_entity)
		pos.y = pos.y + (math.cos(heading) * -distance_from_entity)
	end
	return pos
end

function kek_entity.get_vector_in_front_of_me(...)
	local Entity <const>, distance_from_entity <const> = ...
	local rot = cam.get_gameplay_cam_rot()
    rot:transformRotToDir()
	return cam.get_gameplay_cam_pos() + (rot * distance_from_entity)
end

function kek_entity.get_empty_seats(...)
	local Vehicle <const> = ...
	local seats <const> = {}
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		for i = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(Vehicle)) - 2 do
			if not entity.is_an_entity(vehicle.get_ped_in_vehicle_seat(Vehicle, i)) then
				seats[#seats + 1] = i
			end
		end
	end
	return seats 	
end

function kek_entity.get_entity_altitude(...)
	local Entity <const> = ...
	if entity.is_an_entity(Entity) then
		local pos <const> = entity.get_entity_coords(Entity)
		return pos.z - location_mapper.get_ground_z(pos).z
	end
	return 0
end

function kek_entity.get_seat_ped_is_in(...)
	local Vehicle <const>, Ped <const> = ...
	if entity.is_an_entity(Vehicle) and entity.is_an_entity(Ped) then
		essentials.assert(entity.is_entity_a_ped(Ped), "Expected a ped from argument \"Ped\".")
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		for i = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(Vehicle)) - 2 do
			if vehicle.get_ped_in_vehicle_seat(Vehicle, i) == Ped then
				return i
			end
		end
	end
	return -2
end

-- Ped is kicked out then put back into vehicle in the same frame, causing the illusion he never left the vehicle
function kek_entity.clear_tasks_without_leaving_vehicle(...)
	local Ped <const>, Vehicle <const> = ...
	if entity.is_an_entity(Ped) and entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_ped(Ped), "Expected a ped from argument \"Ped\".")
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		essentials.assert(Ped == player.get_player_ped(player.player_id()) or not ped.is_ped_a_player(Ped), "Expected your player ped or a non-player ped.")
		if ped.is_ped_in_any_vehicle(Ped) then
			local seat <const> = kek_entity.get_seat_ped_is_in(Vehicle, Ped)
			ped.clear_ped_tasks_immediately(Ped)
			ped.set_ped_into_vehicle(Ped, Vehicle, seat)
		else
			ped.clear_ped_tasks_immediately(Ped)
		end
	end
end

function kek_entity.modify_entity_godmode(...)
	local Entity <const>, toggle_on_god <const> = ...
	essentials.assert(not entity.is_an_entity(Entity) or entity.is_entity_a_ped(Entity) or entity.is_entity_a_vehicle(Entity), "Expected a vehicle or ped from argument \"Entity\".")
	if kek_entity.get_control_of_entity(Entity) then
		entity.set_entity_god_mode(Entity, toggle_on_god)
		if entity.is_entity_a_vehicle(Entity) then
			vehicle.set_vehicle_can_be_visibly_damaged(Entity, false)
		end
		return entity.get_entity_god_mode(Entity)
	end
end

function kek_entity.repair_car(...)
	local car <const>, preserve_velocity <const> = ...
	essentials.assert(not entity.is_an_entity(car) or entity.is_entity_a_vehicle(car), "Expected a vehicle from argument \"car\".")
	if kek_entity.get_control_of_entity(car) then
		vehicle.set_vehicle_undriveable(car, false)
		local velocity <const> = entity.get_entity_velocity(car)
		if entity.is_entity_on_fire(car) then
			fire.stop_entity_fire(car)
		end
		vehicle.set_vehicle_fixed(car)
		vehicle.set_vehicle_engine_health(car, 1000)
		vehicle.set_vehicle_engine_on(car, true, true, true)
		if preserve_velocity and velocity ~= v3() then
			entity.set_entity_velocity(car, velocity)
		end
	end
end

do
	local toggle_vehicle_mods <const> = essentials.const({
		unk1 = 17,
		unk2 = 19, 
		unk3 = 21,
		turbo = 18, 
		tire_smoke = 20, 
		xenon_lights = 22
	})
	local performance_mods <const> = essentials.const({
		engine = 11,
		brakes = 12,
		transmission = 13,
		suspension = 15,
		armor = 16
	})

	function kek_entity.max_car(...)
		local Vehicle <const>,
		only_performance_upgrades <const>,
		preserve_velocity <const> = ...
		essentials.assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		if not kek_entity.get_control_of_entity(Vehicle) then
			return
		end
		local velocity <const> = entity.get_entity_velocity(Vehicle)
		vehicle.set_vehicle_mod_kit_type(Vehicle, 0)
		if not only_performance_upgrades then
			if type(settings.in_use["Plate vehicle text"]) == "string" then -- Crashes if plate text is nil
				vehicle.set_vehicle_number_plate_text(Vehicle, settings.in_use["Plate vehicle text"])
			end
			if settings.toggle["Always f1 wheels on #vehicle#"].on then
				vehicle.set_vehicle_wheel_type(Vehicle, enums.wheel_types.f1_wheels)
			else
				vehicle.set_vehicle_wheel_type(Vehicle, math.random(0, 12))
			end
			vehicle.set_vehicle_neon_light_enabled(Vehicle, math.random(-1, 4), true)
			vehicle.set_vehicle_tire_smoke_color(Vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255))
			vehicle.set_vehicle_number_plate_index(Vehicle, math.random(0, 3))
			vehicle.set_vehicle_fullbeam(Vehicle, true)
			vehicle.set_vehicle_custom_wheel_colour(Vehicle, math.random(10^8, 10^10))
			vehicle.set_vehicle_neon_lights_color(Vehicle, math.random(10^8, 10^10))
			vehicle.set_vehicle_custom_primary_colour(Vehicle, math.random(10^8, 10^10))
			vehicle.set_vehicle_custom_secondary_colour(Vehicle, math.random(10^8, 10^10))
			vehicle.set_vehicle_extra_colors(Vehicle, math.random(10^8, 10^10), math.random(10^8, 10^10))
			if math.random(1, 3) == 1 then
				vehicle.set_vehicle_custom_pearlescent_colour(Vehicle, math.random(0, math.random(10^8, 10^10)))
			end
			if math.random(1, 10) == 1 then -- Set livery
				if vehicle.get_num_vehicle_mods(Vehicle, 48) > 0 then
					vehicle.set_vehicle_mod(Vehicle, 48, math.random(1, vehicle.get_num_vehicle_mods(Vehicle, 48) - 1))
				end
			end
			for i = 0, 65 do
				if vehicle.get_num_vehicle_mods(Vehicle, i) > 0 then
					vehicle.set_vehicle_mod(Vehicle, i, math.random(0, vehicle.get_num_vehicle_mods(Vehicle, i) - 1))
				end
			end
			if not streaming.is_model_a_heli(entity.get_entity_model_hash(Vehicle)) then -- Prevent removal of heli rotors
				for i = 1, 9 do
					if vehicle.does_extra_exist(Vehicle, i) then
						vehicle.set_vehicle_extra(Vehicle, i, math.random(0, 1) == 1)
					end
				end
			end
			for _, mod in pairs(toggle_vehicle_mods) do
				vehicle.toggle_vehicle_mod(Vehicle, mod, true)
			end
		end
		vehicle.set_vehicle_bulletproof_tires(Vehicle, true)
		for _, mod in pairs(performance_mods) do
			vehicle.set_vehicle_mod(Vehicle, mod, vehicle.get_num_vehicle_mods(Vehicle, mod) - 1)
		end
		if vehicle.get_num_vehicle_mods(Vehicle, 10) == 1 then
		--[[ 
			Sets best vehicle weapon, not guaranteed to work for every vehicle. 
			Main intention is for oppressor mk1 & mk2.
		--]]
			vehicle.set_vehicle_mod(Vehicle, 10, 0)
		else
			vehicle.set_vehicle_mod(Vehicle, 10, 1)
		end
		if preserve_velocity and velocity ~= v3() then
			entity.set_entity_velocity(Vehicle, velocity)
		end
		return
	end
end

-- Gets the position on a surface the player is looking at.
function kek_entity.get_collision_vector(...)
	local pid <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local rot = cam.get_gameplay_cam_rot()
    rot:transformRotToDir()
    return select(2, worldprobe.raycast(player.get_player_coords(pid), rot * 1000 + cam.get_gameplay_cam_pos(), -1, player.get_player_ped(pid)))
end

--[[
	Applies modifications to one or more tables of entities.
	Does not support enums.
	- Remove player entities
	- Remove all entities outside of range
	- Sort entities from closest to farthest away
	- Limit number of entities
	Each table has its own set of properties to apply.
	Returns the tables merged into one table.
--]]
function kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(...)
	local entity_tables <const>, Ped <const> = ...
	essentials.assert(not entity.is_an_entity(Ped) or ped.is_ped_a_player(Ped), "Expected a player ped from argument \"Ped\".")
	local new_sorted_tables <const> = {}
	for _, entity_table in pairs(entity_tables) do
		if entity_table.remove_player_entities then
			entity_table.entities = kek_entity.remove_player_entities(entity_table.entities)
		end
		if entity_table.max_range then
			local temp <const> = {}
			for i = 1, #entity_table.entities do
				if essentials.get_distance_between(Ped, entity_table.entities[i]) < entity_table.max_range then
					temp[#temp + 1] = entity_table.entities[i]
				end
			end
			entity_table.entities = temp
		end
		if entity_table.sort_by_closest then
			table.sort(entity_table.entities, function(a, b) 
				return (essentials.get_distance_between(a, Ped) < essentials.get_distance_between(b, Ped)) 
			end)
		end
		if entity_table.max_number_of_entities then
			for _ = entity_table.max_number_of_entities, #entity_table.entities do
				entity_table.entities[#entity_table.entities] = nil
			end
		end
		new_sorted_tables[#new_sorted_tables + 1] = entity_table.entities
	end
	return essentials.merge_tables({}, new_sorted_tables)
end

function kek_entity.remove_player_vehicle(...)
	local pid <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local initial_pos <const> = player.get_player_coords(player.player_id())
	local status <const>, had_to_teleport <const> = kek_entity.is_target_viable(pid)
	if status then
		local time <const> = utils.time_ms() + 2000
		while player.is_player_in_any_vehicle(pid) and time > utils.time_ms() do
			system.yield(0)
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
		end
		if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
			kek_entity.hard_remove_entity_and_its_attachments(player.get_player_vehicle(pid))
		end
	end
	if had_to_teleport then
		kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
	end
	return not entity.is_an_entity(player.get_player_vehicle(pid))
end

function kek_entity.spawn_and_push_a_vehicle_in_direction(...)
	local pid <const>,
	clear_vehicle_after_ram <const>,
	distance_from_target,
	hash_or_entity <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local speed
	if math.random(0, 1) == 1 then -- Whether vehicle is pushed from behind or front of player
		speed = 140
		distance_from_target = -math.abs(distance_from_target)
	else
		speed = -140
	end
	if not entity.is_entity_dead(player.get_player_ped(pid)) then
		if player.is_player_in_any_vehicle(pid) then
			kek_entity.get_control_of_entity(player.get_player_vehicle(pid), 0)
		end
		local car = hash_or_entity
		local spawn_pos
		if not entity.is_an_entity(hash_or_entity) then
			essentials.assert(streaming.is_model_a_vehicle(hash_or_entity), "Expected a valid vehicle hash.")
			car = kek_entity.spawn_entity(hash_or_entity, function()
				spawn_pos = kek_entity.get_vector_relative_to_entity(essentials.get_most_relevant_entity(pid), distance_from_target, nil, nil, pid)
				spawn_pos.z = select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f1, v3())).z
				return spawn_pos, player.get_player_heading(pid)
			end)
		else
			essentials.assert(not entity.is_an_entity(hash_or_entity) or entity.is_entity_a_vehicle(hash_or_entity), "Expected a vehicle from argument \"hash_or_entity\".")
		end
		entity.set_entity_max_speed(car, 45000)
		if entity.is_an_entity(car) then
			vehicle.set_vehicle_out_of_control(car, false, true)
			vehicle.set_vehicle_forward_speed(car, speed)
			entity.set_entity_as_no_longer_needed(car)
			if clear_vehicle_after_ram then
				system.yield(300)
				kek_entity.clear_entities({car})
			end
			return car
		end
	end
	return 0
end

function kek_entity.set_combat_attributes(...)
	local Ped <const>, 
	set_all_attributes_to_true <const>,
	attributes <const> = ...
	essentials.assert(not entity.is_an_entity(Ped) or entity.is_entity_a_ped(Ped), "Expected a ped from argument \"Ped\".")
	essentials.assert(not ped.is_ped_a_player(Ped), "Expected a non-player ped.")
	for attribute_id, is_on in pairs({
		[0] = attributes.cover or false,
		[1] = attributes.use_vehicle or false,
		[2] = attributes.driveby or false,
		[3] = attributes.leave_vehicle or false,
		[5] = attributes.unarmed_fight_armed or false, 
		[20] = attributes.taunt_in_vehicle or false,
		[46] = attributes.always_fight or false,
		[52] = attributes.ignore_traffic or false,
		[1424] = attributes.use_fireing_weapons or false
	}) do
		ped.set_ped_combat_attributes(Ped, attribute_id, set_all_attributes_to_true or is_on == true)
	end
	ped.set_ped_combat_ability(Ped, 100)
	ped.set_ped_combat_range(Ped, enums.combat_range.CR_Far)
	ped.set_ped_combat_movement(Ped, enums.combat_movement.offensive)
	ped.set_ped_relationship_group_hash(Ped, gameplay.get_hash_key("HATES_PLAYER"))
end

function kek_entity.create_cage(...)
	local pid <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
	system.yield(250)
	local temp_ped <const> = kek_entity.spawn_entity(gameplay.get_hash_key("a_f_y_tourist_02"), function() 
		return select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x3779, v3())), 0
	end, true, false, enums.ped_types.civmale)
	if entity.is_entity_a_ped(temp_ped) then
		entity.set_entity_visible(temp_ped, false)
		ped.set_ped_config_flag(temp_ped, enums.ped_config_flags.InVehicle, 1)
		entity.freeze_entity(temp_ped, true)
		local cage <const> = kek_entity.spawn_entity(gameplay.get_hash_key("prop_test_elevator"), function()
			return player.get_player_coords(pid) + v3(0, 0, 10), 0
		end)
		local cage_2 <const> = kek_entity.spawn_entity(gameplay.get_hash_key("prop_test_elevator"), function()
			return player.get_player_coords(pid) + v3(0, 0, 10), 0
		end)
		entity.set_entity_visible(temp_ped, true)
		entity.attach_entity_to_entity(cage, temp_ped, 0, v3(), v3(), false, true, true, 0, true)
		entity.attach_entity_to_entity(cage_2, cage, 0, v3(), v3(0, 0, 90), false, true, false, 0, true)
		entity.set_entity_visible(temp_ped, false)
		menu.create_thread(function()
			while player.is_player_valid(pid) and entity.is_an_entity(temp_ped) do
				kek_entity.get_control_of_entity(temp_ped, 0)
				ped.clear_ped_tasks_immediately(temp_ped)
				system.yield(0)
			end
			kek_entity.hard_remove_entity_and_its_attachments(temp_ped)
		end, nil)
		return temp_ped
	end
	return 0
end

local function get_prefered_vehicle_pos(...)
	local hash <const> = ...
	essentials.assert(streaming.is_model_a_vehicle(hash), "Expected a valid vehicle hash.")
	if settings.toggle["Air #vehicle# spawn mid-air"].on and settings.toggle["Spawn inside of spawned #vehicle#"].on and streaming.is_model_a_heli(hash) then
		return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 10), true) + v3(0, 0, 100 - kek_entity.get_entity_altitude(essentials.get_most_relevant_entity(player.player_id())))
	elseif settings.toggle["Air #vehicle# spawn mid-air"].on and settings.toggle["Spawn inside of spawned #vehicle#"].on and streaming.is_model_a_plane(hash) then
		return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 25), true) + v3(0, 0, 250 - kek_entity.get_entity_altitude(essentials.get_most_relevant_entity(player.player_id())))
	else
		return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8), true)
	end
end

function kek_entity.vehicle_preferences(...)
	local Vehicle <const>, teleport <const> = ...
	essentials.assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
	if settings.toggle["Delete old #vehicle#"].on then
		for _, Entity in pairs(kek_entity.user_vehicles) do
			kek_entity.hard_remove_entity_and_its_attachments(Entity)
		end
		kek_entity.user_vehicles = {}
	end
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		local hash <const> = entity.get_entity_model_hash(Vehicle)
		if teleport then
			kek_entity.teleport(Vehicle, get_prefered_vehicle_pos(hash))
		end
		if settings.toggle["Spawn inside of spawned #vehicle#"].on then
			if streaming.is_model_a_heli(hash) then
				vehicle.set_heli_blades_full_speed(Vehicle)
			elseif streaming.is_model_a_plane(hash) then
				vehicle.set_vehicle_forward_speed(Vehicle, 100)
			end
			ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Vehicle, enums.vehicle_seats.driver)
		end
	end
end

function kek_entity.set_blip(...)
	local Entity <const>,
	sprite_id <const>,
	color <const> = ...
	if entity.is_an_entity(Entity) then
		local blip <const> = ui.add_blip_for_entity(Entity)
		ui.set_blip_sprite(blip, sprite_id or 0)
		ui.set_blip_colour(blip, color or 0)
		menu.create_thread(function()
			local personal_vehicle <const> = Entity
			while entity.is_an_entity(Entity) and Entity == personal_vehicle do
				system.yield(0)
			end
			ui.remove_blip(blip)
		end, nil)
		return blip
	else
		return -1
	end
end

function kek_entity.spawn_car()
	if settings.toggle["Always ask what #vehicle#"].on then
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in what car to use §"], "", 128, 0)
		if status == 2 then
			return
		end
		settings.in_use["Default vehicle"] = input
	end
	local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["Default vehicle"])
	if streaming.is_model_a_vehicle(hash) then
		if not kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			essentials.msg(lang["Failed to spawn vehicle. Vehicle limit was reached §"], 6, true, 6)
			return -1
		end
		kek_entity.user_vehicles[#kek_entity.user_vehicles + 1] = player.get_player_vehicle(player.player_id())
		if settings.toggle["Delete old #vehicle#"].on then
			for _, Entity in pairs(kek_entity.user_vehicles) do
				kek_entity.hard_remove_entity_and_its_attachments(Entity)
			end
			kek_entity.user_vehicles = {}
		end
		local velocity <const> = entity.get_entity_velocity(essentials.get_most_relevant_entity(player.player_id()))
		local Vehicle <const> = kek_entity.spawn_entity(hash, function()
			return get_prefered_vehicle_pos(hash), player.get_player_heading(player.player_id())
		end, settings.toggle["Spawn #vehicle# in godmode"].on, settings.toggle["Spawn #vehicle# maxed"].on)
		if settings.toggle["Always f1 wheels on #vehicle#"].on then
			vehicle.set_vehicle_wheel_type(Vehicle, enums.wheel_types.f1_wheels)
		end
		kek_entity.vehicle_preferences(Vehicle)
		vehicle.set_vehicle_engine_on(Vehicle, true, true, false)
		kek_entity.user_vehicles[#kek_entity.user_vehicles + 1] = Vehicle
	else
		essentials.msg(lang["Failed to spawn vehicle. Invalid vehicle hash. §"], 6, true, 6)
		return -1
	end
end

do
	local table_of_glitch_entity_models <const> = essentials.const({
		"prop_ld_dstcover_02",
		"prop_torture_ch_01",
		"prop_ld_farm_rail01",
		"prop_ld_ferris_wheel",
		"prop_alien_egg_01",
		"prop_cs_dildo_01",
		"prop_sh_bong_01",
		"banshee2",
		"molotok",
		"moonbeam2",
		"sanctus",
		"bmx",
		"buzzard2",
		"swift2",
		"a_f_y_hiker_01",
		"a_m_m_genfat_01",
		"a_c_killerwhale",
		"a_c_cat_01",
		"a_c_humpback",
		"a_c_crow"
	})

	function kek_entity.glitch_vehicle(...)
		local Vehicle <const> = ...
		essentials.assert(not entity.is_an_entity(Vehicle) or entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		local seat <const> = vehicle.get_free_seat(Vehicle)
		if seat ~= -2 and entity.is_an_entity(Vehicle) then
			local Ped <const> = kek_entity.spawn_entity(gameplay.get_hash_key("a_f_y_topless_01"), function() 
				return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + v3(0, 0, 10), 0
			end, true, false, enums.ped_types.civmale)
			if entity.is_entity_a_ped(Ped) then
				entity.set_entity_collision(Ped, false, false, false)
				entity.set_entity_visible(Ped, false)
				ped.set_ped_into_vehicle(Ped, Vehicle, seat)
				local Entity <const> = kek_entity.spawn_entity(gameplay.get_hash_key(table_of_glitch_entity_models[math.random(1, #table_of_glitch_entity_models)]), function()
					return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + v3(0, 0, 10), 0
				end, true, false, enums.ped_types.civmale) -- This can spawn an object, ped or vehicle.
				if entity.is_an_entity(Entity) then
					entity.set_entity_visible(Entity, false)
					entity.attach_entity_to_entity(Entity, Ped, 0, v3(), v3(math.random(0, 180), math.random(0, 180), math.random(0, 180)), false, true, entity.is_entity_a_ped(Entity), 0, false)
				else
					kek_entity.clear_entities({Ped, Entity})
				end
			end
		end
	end
end

function kek_entity.teleport_player_and_vehicle_to_position(...)
	local pid <const>,
	pos <const>,
	teleport_you_back_to_original_pos <const>,
	is_show_message <const>,
	is_a_toggle <const>,
	f <const> = ...
	essentials.assert(pid >= 0 and pid <= 31, "Invalid pid.")
	local initial_pos <const> = player.get_player_coords(player.player_id())
	local status <const>, had_to_teleport <const> = kek_entity.is_target_viable(pid, is_a_toggle, f)
	if status then
		local time <const> = utils.time_ms() + 2000
		repeat
			kek_entity.teleport(player.get_player_vehicle(pid), pos)
			system.yield(100)
		until not entity.is_an_entity(player.get_player_vehicle(pid)) or utils.time_ms() > time or network.has_control_of_entity(player.get_player_vehicle(pid)) or not player.is_player_in_any_vehicle(pid)
	elseif is_show_message then
		essentials.msg(player.get_player_name(pid).." "..lang["is not in a vehicle. §"], 6, true)
	end
	if teleport_you_back_to_original_pos and had_to_teleport then
		kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
	end
	return status
end

function kek_entity.teleport_session(...)
	local pos <const>, f <const> = ...
	local pids <const> = {}
	for pid in essentials.players() do
		if (player.is_player_in_any_vehicle(pid) or player.get_player_coords(pid).z == -50)
		and essentials.get_distance_between(player.get_player_coords(pid), pos) > 35
		and essentials.is_not_friend(pid) then
			pids[#pids + 1] = pid
		end
	end
	local value <const> = f.value
	while #pids > 0 and f.on and f.value == value do
		system.yield(0)
		table.sort(pids, function(a, b) -- Makes sure closest player is teleported at all times. Needs to be updated on each iteration.
			return (essentials.get_distance_between(player.get_player_ped(a), player.get_player_ped(player.player_id())) < essentials.get_distance_between(player.get_player_ped(b), player.get_player_ped(player.player_id()))) 
		end)
		kek_entity.teleport_player_and_vehicle_to_position(pids[1], pos)
		table.remove(pids, 1)
	end
end

--[[
	List of end vehicles is the first vehicle in each class except compacts, because compacts is the first class.
	Using vehicle.get_all_vehicle_model_hashes().
--]]
do
	local vehicle_category_info <const> = essentials.const({
		{class_name = lang["Compacts §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Sedans §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["SUVs §"], 			 num_of_vehicles_in_class = 0},
		{class_name = lang["Coupes §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Muscle §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Sports classics §"], num_of_vehicles_in_class = 0},
		{class_name = lang["Sports §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Super §"], 			 num_of_vehicles_in_class = 0},
		{class_name = lang["Motorcycles §"], 	 num_of_vehicles_in_class = 0},
		{class_name = lang["Off-Road §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Industrial §"], 	 num_of_vehicles_in_class = 0},
		{class_name = lang["Utility §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Vans §"], 			 num_of_vehicles_in_class = 0},
		{class_name = lang["Cycles §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Boats §"], 			 num_of_vehicles_in_class = 0},
		{class_name = lang["Helicopters §"], 	 num_of_vehicles_in_class = 0},
		{class_name = lang["Planes §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Service §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Emergency §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Military §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Commercial §"], 	 num_of_vehicles_in_class = 0},
		{class_name = lang["Trains §"], 		 num_of_vehicles_in_class = 0},
		{class_name = lang["Open Wheel §"],		 num_of_vehicles_in_class = 0}
	})

do
	local list_of_end_vehicles <const> = essentials.const({
		2485144969, -- Asea
		629969764, -- Astron
		4289813342, -- Exemplar
		2351681756, -- Nightshade
		2049897956, -- Rapid_GT_Classic
		970598228, -- Sultan
		3612858749, -- Zorrusso
		822018448, -- Defiler
		2198148358, -- Technical
		1353720154, -- Flatbed
		3417488910, -- Trailer
		219613597, -- Speedo_Custom
		3061159916, -- Endurex_Race_Bike
		3251507587, -- Marquis
		2623428164, -- SuperVolito_Carbon
		2621610858, -- Velum
		3039269212, -- Trashmaster
		1127131465, -- FIB
		2014313426, -- Vetir
		2157618379, -- Phantom
		184361638, -- Freight_Train
		1492612435 -- BR8
	})
	local i = 1
	for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
		if hash == list_of_end_vehicles[i] then
			i = i + 1
		end
		vehicle_category_info[i].num_of_vehicles_in_class = vehicle_category_info[i].num_of_vehicles_in_class + 1
	end
end

	function kek_entity.generate_vehicle_list(...)
		local feat_type <const>,
		feat_str <const>,
		parent <const>,
		value_i_func <const>,
		func <const> = ...
		local hashes <const> = vehicle.get_all_vehicle_model_hashes()
		for i2, info in pairs(vehicle_category_info) do
			local count = 0 -- Iteration ends at next end vehicle
			for i = 1, i2 do
				count = count + vehicle_category_info[i].num_of_vehicles_in_class
			end
			local parent <const> = menu.add_feature(info.class_name, "parent", parent.id, function(f)
				if f.child_count == 0 then
					for i = count - info.num_of_vehicles_in_class + 1, count do -- Iterates until reaching class end vehicle. Starts at previous class's end vehicle or index 1.
						local feature <const> = menu.add_feature(vehicle_mapper.get_translated_vehicle_name(hashes[i]), feat_type, f.id, func)
						feature.data = hashes[i]
						feature:set_str_data(feat_str)
						feature.value = value_i_func(hashes[i])
					end
				end
			end)
		end
	end

	function kek_entity.generate_player_vehicle_list(...)
		local feature_info <const>,
		parent <const>,
		func <const>,
		initial_name <const> = ...
		local hashes <const> = vehicle.get_all_vehicle_model_hashes()
		for i2, info in pairs(vehicle_category_info) do
			local count = 0 -- Iteration ends at next end vehicle
			for i = 1, i2 do
				count = count + vehicle_category_info[i].num_of_vehicles_in_class
			end
			local parent <const> = menu.add_player_feature(info.class_name, "parent", parent, function(f, pid)
				if f.child_count == 0 then
					for i = count - info.num_of_vehicles_in_class + 1, count do -- Iterates until reaching class end vehicle. Starts at previous class's end vehicle or index 1.
						local feature_id <const> = menu.add_player_feature(vehicle_mapper.get_translated_vehicle_name(hashes[i])..initial_name, feature_info.type, f.id, func).id
						if feature_info.type:find("value_i", 1, true) then
							menu.get_player_feature(feature_id).max = feature_info.max
							menu.get_player_feature(feature_id).min = feature_info.min
							menu.get_player_feature(feature_id).mod = feature_info.mod
							menu.get_player_feature(feature_id).value = feature_info.value
						end
						for pid = 0, 31 do
							menu.get_player_feature(feature_id).feats[pid].data = hashes[i]
						end
					end
				end
			end).id
		end
	end
end

return kek_entity -- Not a const table, certain members need write permission.