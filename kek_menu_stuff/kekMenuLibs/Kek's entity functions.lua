-- Lib Kek's entity functions version: 1.1.4
-- Copyright © 2020-2021 Kektram

local kek_entity = {}

local location_mapper = require("Location mapper")
local vehicle_mapper = require("Vehicle mapper")
local essentials = require("Essentials")

-- Tables
	local table_of_glitch_entity_models = 
		{
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
		}
	local lang = kek_menu.lang

-- Is entity valid
	function kek_entity.is_entity_valid(Entity)
		return Entity and not entity.is_entity_static(Entity) and entity.is_an_entity(Entity)
	end

-- Teleport entity
	function kek_entity.teleport(Entity, coords, time)
		if type(coords) == "userdata" and kek_menu.get_control_of_entity(Entity, time) then
			entity.set_entity_coords_no_offset(Entity, coords)
			return true
		end
	end

-- Is ai tasks active
	function kek_entity.is_any_tasks_active(Ped, tasks)
		for i, task in pairs(tasks) do
			if ai.is_task_active(Ped, task) then
				return true
			end
		end
	end

-- Checks if target is valid for entity functions
	function kek_entity.is_target_viable(pid, is_a_toggle, feature)
		local had_to_teleport = false
		if player.is_player_valid(pid) and essentials.is_in_vehicle(pid) then
			local time = utils.time_ms() + 1500
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

-- Remove players from entity table
	function kek_entity.remove_player_entities(table_of_entities)
		local new = {}
		for i, Entity in pairs(table_of_entities) do
			if entity.is_an_entity(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
				local status = true
				if entity.is_entity_a_vehicle(Entity) then
					for pid = 0, 31 do
						if player.get_player_vehicle(pid) == Entity then
							status = nil
							break
						end
					end
				end
				if status then
					new[#new + 1] = Entity
				end
			end
		end
		table_of_entities = new
		return table_of_entities
	end

-- Get all attached entities
	function kek_entity.get_all_attached_entities(Entity)
		local entities = {}
		local all_entities = kek_entity.get_table_of_close_entity_type(6)
		for i = 1, #all_entities do
			if entity.get_entity_attached_to(all_entities[i]) == Entity and (not entity.is_entity_a_ped(all_entities[i]) or not ped.is_ped_a_player(all_entities[i])) then
				entities[#entities + 1] = all_entities[i]
				local attached_entities = kek_entity.get_all_attached_entities(all_entities[i])
				table.move(attached_entities, 1, #attached_entities, #entities + 1, entities)
			end
		end
		return entities
	end

	function kek_entity.get_parent_of_attachment(Entity)
		if entity.is_entity_attached(Entity) then
			return kek_entity.get_parent_of_attachment(entity.get_entity_attached_to(Entity))
		else
			return Entity
		end
	end

	function kek_entity.hard_remove_entity_and_its_attachments(Entity)
		if entity.is_an_entity(Entity) then
			Entity = kek_entity.get_parent_of_attachment(Entity)
			if entity.is_an_entity(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
				kek_entity.clear_entities(kek_entity.get_all_attached_entities(Entity))
				kek_entity.clear_entities({Entity})
			end
		end
	end

-- Get table of entity type
	function kek_entity.get_table_of_close_entity_type(type)
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
			return {}
		end
	end

-- Clear entities
	function kek_entity.clear_entities(table_of_entities)
		for i = 1, 2 do
			local count = 0
			for i, Entity in pairs(table_of_entities) do
				if not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity) then
					network.request_control_of_entity(Entity)
					count = count + 1
					if network.has_control_of_entity(Entity) then
						ui.remove_blip(ui.get_blip_from_entity(Entity))
						if entity.is_entity_a_ped(Entity) or entity.is_entity_a_vehicle(Entity) then
							entity.set_entity_as_mission_entity(Entity, false, true)
						end
						entity.delete_entity(Entity)
						if not entity.is_an_entity(Entity) then
							table_of_entities[i] = nil
						end
					end
				else
					table_of_entities[i] = nil
				end
				if count % 15 == 0 then
					system.yield(0)
				end
			end
		end
	end			

-- Get number of peds in a vehicle
	function kek_entity.get_number_of_passengers(car)
		local passengers, is_there_a_player_in_the_vehicle = {}
		for i = -1, vehicle.get_vehicle_max_number_of_passengers(car) - 2 do
			local Ped = vehicle.get_ped_in_vehicle_seat(car, i)
			if entity.is_an_entity(Ped) then
				passengers[#passengers + 1] = Ped
				if ped.is_ped_a_player(Ped) and player.get_player_from_ped(Ped) ~= player.player_id() then
					is_there_a_player_in_the_vehicle = true
				end
			end
		end
		return passengers, is_there_a_player_in_the_vehicle
	end

-- Is there a friend in vehicle
	function kek_entity.is_player_in_vehicle(Vehicle)
		local player_in_vehicle, friend_in_vehicle
		if entity.is_an_entity(Vehicle) and entity.is_entity_a_vehicle(Vehicle) then
			for i = -1, vehicle.get_vehicle_max_number_of_passengers(Vehicle) - 2 do
				if network.is_scid_friend(player.get_player_scid(player.get_player_from_ped(vehicle.get_ped_in_vehicle_seat(Vehicle, i)))) then
					friend_in_vehicle = true
				end
				if ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(Vehicle, i)) then
					player_in_vehicle = true
				end
			end
		end
		return player_in_vehicle, friend_in_vehicle
	end

-- Request model
	function kek_entity.request_model(model_hash)
		local requested_hash
		if tonumber(model_hash) and streaming.is_model_valid(model_hash) then 
			if not streaming.has_model_loaded(model_hash) then
				requested_hash = true
   				streaming.request_model(model_hash)
    			local time = utils.time_ms() + 450
    			while not streaming.has_model_loaded(model_hash) and time > utils.time_ms() do
       				system.yield(0)
   				end
			end
			return streaming.has_model_loaded(model_hash), requested_hash
		end
	end

-- Rotate entity
	function kek_entity.get_rotated_heading(Entity, angle, pid, heading)
		if not heading then
			if pid then
				heading = player.get_player_heading(pid)
			else
				heading = entity.get_entity_heading(Entity)
			end
		end
		local heading = heading + angle
		if heading > 179.99999 then
			heading = -179.99999 + (math.abs(heading) - 179.99999)
		elseif heading < -179.99999 then
			heading = 179.99999 - (math.abs(heading) - 179.99999)
		end
		return heading
	end

-- Get vector relative to entity
	function kek_entity.get_vector_relative_to_entity(Entity, distance_from_entity, angle, get_z_axis, pid)
		if not angle then
			angle = 0
		end
		local rot, heading = v3(), 0
		if pid then
			heading = kek_entity.get_rotated_heading(Entity, angle, pid)
		else
			heading = entity.get_entity_heading(Entity)
		end
		local pos = entity.get_entity_coords(Entity)
		if get_z_axis then
			local rot = entity.get_entity_rotation(Entity)
			rot.z = kek_entity.get_rotated_heading(Entity, angle, nil, rot.z)
	        rot:transformRotToDir()
			pos = pos + (rot * distance_from_entity)
		else
			local heading = math.rad((heading - 180) * -1)
			pos.x = pos.x + (math.sin(heading) * -distance_from_entity)
			pos.y = pos.y + (math.cos(heading) * -distance_from_entity)
		end
		return pos
	end

-- Get vector in front
	function kek_entity.get_vector_in_front_of_me(Entity, distance_from_entity)
		local rot = cam.get_gameplay_cam_rot()
        rot:transformRotToDir()
		return cam.get_gameplay_cam_pos() + (rot * distance_from_entity)
	end

	function kek_entity.get_empty_seats(Vehicle)
		local seats = {}
		if entity.is_entity_a_vehicle(Vehicle) then
			for i = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(Vehicle)) - 2 do
				if not entity.is_an_entity(vehicle.get_ped_in_vehicle_seat(Vehicle, i)) then
					seats[#seats + 1] = i
				end
			end
		end
		return seats 	
	end

-- Get altitude of entity
	function kek_entity.get_entity_altitude(Entity)
		if entity.is_an_entity(Entity) then
			local pos = entity.get_entity_coords(Entity)
			return pos.z - location_mapper.get_ground_z(pos).z
		end
		return 0
	end

-- Get seat ped is in
	function kek_entity.get_seat_ped_is_in(Vehicle, Ped)
		if entity.is_an_entity(Vehicle) and entity.is_an_entity(Ped) then
			for i = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(Vehicle)) - 2 do
				if vehicle.get_ped_in_vehicle_seat(Vehicle, i) == Ped then
					return i
				end
			end
		end
		return -2
	end

-- Clear tasks without leaving vehicle
	function kek_entity.clear_tasks_without_leaving_vehicle(Ped, Vehicle)
		if ped.is_ped_in_any_vehicle(Ped) then
			local seat = kek_entity.get_seat_ped_is_in(Vehicle, Ped)
			ped.clear_ped_tasks_immediately(Ped)
			ped.set_ped_into_vehicle(Ped, Vehicle, seat)
		else
			ped.clear_ped_tasks_immediately(Ped)
		end
	end

-- Give entity godmode
	function kek_entity.modify_entity_godmode(target_entity, toggle_on_god)
		if kek_menu.get_control_of_entity(target_entity) then
			entity.set_entity_god_mode(target_entity, toggle_on_god)
			if entity.is_entity_a_vehicle(target_entity) then
				vehicle.set_vehicle_can_be_visibly_damaged(target_entity, false)
			end
			return entity.get_entity_god_mode(target_entity)
		end
	end

-- Repair vehicle
	function kek_entity.repair_car(car, preserve_velocity)
		if kek_menu.get_control_of_entity(car) then
			vehicle.set_vehicle_undriveable(car, false)
			local velocity = entity.get_entity_velocity(car)
			if entity.is_entity_on_fire(car) then
				fire.stop_entity_fire(car)
			end
			vehicle.set_vehicle_fixed(car)
			vehicle.set_vehicle_engine_health(car, 1000)
			vehicle.set_vehicle_engine_on(car, true, true, true)
			if preserve_velocity then
				entity.set_entity_velocity(car, velocity)
			end
		end
	end

-- Max vehicle
	function kek_entity.max_car(car, only_performance_upgrades, preserve_velocity)
		if entity.is_entity_dead(car) or not kek_menu.get_control_of_entity(car) then
			return 0
		end
		local velocity = entity.get_entity_velocity(car)
		vehicle.set_vehicle_mod_kit_type(car, 0)
		if not only_performance_upgrades then
			local e = {}
			for i = 1, 8 do
				local num = math.ceil(math.maxinteger / math.random(1000000, 2000000000))
				e[i] = math.random(num - 4000000000, num)
			end
			if type(kek_menu.settings["Plate vehicle text"]) == "string" then
				vehicle.set_vehicle_number_plate_text(car, kek_menu.settings["Plate vehicle text"])
			end
			if kek_menu.toggle["Always f1 wheels on #vehicle#"].on then
				vehicle.set_vehicle_wheel_type(car, 10)
			else
				vehicle.set_vehicle_wheel_type(car, math.random(0, 11))
			end
			vehicle.set_vehicle_neon_light_enabled(car, math.random(-1, 4), true)
			vehicle.set_vehicle_tire_smoke_color(car, math.random(0, 255), math.random(0, 255), math.random(0, 255))
			vehicle.set_vehicle_number_plate_index(car, math.random(0, 3))
			vehicle.set_vehicle_fullbeam(car, true)
			vehicle.set_vehicle_custom_wheel_colour(car, e[2])
			vehicle.set_vehicle_neon_lights_color(car, e[3])
			vehicle.set_vehicle_custom_primary_colour(car, e[4])
			vehicle.set_vehicle_custom_secondary_colour(car, e[5])
			vehicle.set_vehicle_extra_colors(car, e[6], e[7])
			if math.random(1, 3) == 1 then
				vehicle.set_vehicle_custom_pearlescent_colour(car, math.random(0, e[7]))
			end
			if math.random(1, 20) == 1 then
				local e = vehicle.get_num_vehicle_mods(car, 48)
				if e > 0 then
					vehicle.set_vehicle_mod(car, 48, math.random(1, e))
				end
			end
			for mod_index = 0, 65 do
				local e = vehicle.get_num_vehicle_mods(car, mod_index)
				local num = math.random(0, e)
				if e > 0 and vehicle.get_vehicle_mod(car, mod_index) ~= num then
					vehicle.set_vehicle_mod(car, mod_index, num)
				end
			end
			if not streaming.is_model_a_heli(entity.get_entity_model_hash(car)) then
				for i = 1, 9 do
					if vehicle.does_extra_exist(car, i) then
						vehicle.set_vehicle_extra(car, i, math.random(0, 1) == 1)
					end
				end
			end
		end
		for i, mod in pairs({17, 18, 19, 20, 21, 22}) do
			vehicle.toggle_vehicle_mod(car, mod, true)
		end
		vehicle.set_vehicle_bulletproof_tires(car, true)
		if vehicle.get_vehicle_mod(car, 11) ~= vehicle.get_num_vehicle_mods(car, 11) - 1 then
			vehicle.set_vehicle_mod(car, 11, vehicle.get_num_vehicle_mods(car, 11) - 1)
		end
		if vehicle.get_vehicle_mod(car, 12) ~= vehicle.get_num_vehicle_mods(car, 12) - 1 then
			vehicle.set_vehicle_mod(car, 12, vehicle.get_num_vehicle_mods(car, 12) - 1)
		end
		if vehicle.get_vehicle_mod(car, 13) ~= vehicle.get_num_vehicle_mods(car, 13) - 1 then
			vehicle.set_vehicle_mod(car, 13, vehicle.get_num_vehicle_mods(car, 13) - 1)
		end
		if vehicle.get_vehicle_mod(car, 15) ~= vehicle.get_num_vehicle_mods(car, 15) - 1 then
			vehicle.set_vehicle_mod(car, 15, vehicle.get_num_vehicle_mods(car, 15) - 1)
		end
		if vehicle.get_vehicle_mod(car, 16) ~= vehicle.get_num_vehicle_mods(car, 16) - 1 then
			vehicle.set_vehicle_mod(car, 16, vehicle.get_num_vehicle_mods(car, 16) - 1)
		end
		if vehicle.get_num_vehicle_mods(car, 10) == 1 then
			vehicle.set_vehicle_mod(car, 10, 0)
		else
			vehicle.set_vehicle_mod(car, 10, 1)
		end
		if preserve_velocity then
			entity.set_entity_velocity(car, velocity)
		end
		return 0
	end

-- Get vector where collision
	function kek_entity.get_collision_vector(pid)
		local rot = cam.get_gameplay_cam_rot()
        rot:transformRotToDir()
        return select(2, worldprobe.raycast(player.get_player_coords(pid), rot * 1000 + cam.get_gameplay_cam_pos(), -1, player.get_player_ped(pid)))
    end

-- Get table of entities with respect to distance on each entity type
	function kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(entity_tables, ped)
		local new_sorted_tables = {}
		for i, entity_table in pairs(entity_tables) do
			if entity_table[3] then
				entity_table[1] = kek_entity.remove_player_entities(entity_table[1])
			end
			if entity_table[4] then
				local temp = {}
				for i = 1, #entity_table[1] do
					if essentials.get_distance_between(ped, entity_table[1][i]) < entity_table[4] then
						temp[#temp + 1] = entity_table[1][i]
					end
				end
				entity_table[1] = temp
			end
			if entity_table[5] then
				table.sort(entity_table[1], function(a, b) return (essentials.get_distance_between(a, ped) < essentials.get_distance_between(b, ped)) end)
			end
			if entity_table[2] then
				for i = entity_table[2], #entity_table[1] do
					entity_table[1][#entity_table[1]] = nil
				end
			end
			new_sorted_tables[#new_sorted_tables + 1] = entity_table[1]
		end
		return essentials.merge_tables({}, new_sorted_tables)
	end

-- Removes player vehicle
	function kek_entity.remove_player_vehicle(pid)
		local initial_pos = player.get_player_coords(player.player_id())
		local status, had_to_teleport = kek_entity.is_target_viable(pid)
		if status then
			local time = utils.time_ms() + 2000
			while player.is_player_in_any_vehicle(pid) and time > utils.time_ms() do
				system.yield(0)
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			end
			if kek_menu.get_control_of_entity(player.get_player_vehicle(pid)) then
				kek_entity.hard_remove_entity_and_its_attachments(player.get_player_vehicle(pid))
			end
		end
		if had_to_teleport then
			kek_entity.teleport(essentials.get_most_relevant_entity(player.player_id()), initial_pos)
		end
		return not entity.is_an_entity(player.get_player_vehicle(pid))
	end
	
-- Ram function
	function kek_entity.spawn_and_push_a_vehicle_in_direction(pid, clear_vehicle_after_ram, distance_from_target, hash_or_entity)
		local speed
		if math.random(0, 1) == 1 then
			speed = 140
			distance_from_target = -math.abs(distance_from_target)
		else
			speed = -140
		end
		if not entity.is_entity_dead(player.get_player_ped(pid)) then
			if player.is_player_in_any_vehicle(pid) then
				kek_menu.get_control_of_entity(player.get_player_vehicle(pid), 0)
			end
			local car = hash_or_entity
			local spawn_pos = v3()
			if not entity.is_an_entity(hash_or_entity) then
				car = kek_menu.spawn_entity(hash_or_entity, function()
					local pos = kek_entity.get_vector_relative_to_entity(essentials.get_most_relevant_entity(pid), distance_from_target, nil, nil, pid)
					pos.z = select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f1, v3())).z
					spawn_pos = pos
					return pos, player.get_player_heading(pid)
				end)
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

-- Max ped's combat attributes
	function kek_entity.set_combat_attributes(Ped, god, all_true, use_vehicle, driveby, cover, leave_vehicle, unarmed_fight_armed, taunt_in_vehicle, always_fight, ignore_traffic, use_fireing_weapons)
		kek_entity.modify_entity_godmode(Ped, god)
		local attributes = 
			{
				{0, cover}, {1, use_vehicle}, {2, driveby}, {3, leave_vehicle}, {5, unarmed_fight_armed}, {20, taunt_in_vehicle},
				{46, always_fight}, {52, ignore_traffic}, {1424, use_fireing_weapons} 
			}
		for i, attribute in pairs(attributes) do
			ped.set_ped_combat_attributes(Ped, attribute[1], (all_true or attribute) and true)
		end
		ped.set_ped_combat_ability(Ped, 100)
		ped.set_ped_combat_range(Ped, 2)
		ped.set_ped_combat_movement(Ped, 2)
		ped.set_ped_relationship_group_hash(Ped, gameplay.get_hash_key("HATES_PLAYER"))
	end

	function kek_entity.create_cage(pid)
		ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
		system.yield(250)
		local temp_ped = kek_menu.spawn_entity(gameplay.get_hash_key("a_f_y_tourist_02"), function() 
			return select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x3779, v3())), 0
		end, true, true, false, 4)
		if entity.is_an_entity(temp_ped) then
			entity.set_entity_visible(temp_ped, false)
			ped.set_ped_config_flag(temp_ped, 62, 1)
			entity.freeze_entity(temp_ped, true)
			local cage = kek_menu.spawn_entity(gameplay.get_hash_key("prop_test_elevator"), function()
				return player.get_player_coords(pid) + v3(0, 0, 10), 0
			end, false, true)
			local cage_2 = kek_menu.spawn_entity(gameplay.get_hash_key("prop_test_elevator"), function()
				return player.get_player_coords(pid) + v3(0, 0, 10), 0
			end, false, true)
			entity.set_entity_visible(temp_ped, true)
			entity.attach_entity_to_entity(cage, temp_ped, 0, v3(), v3(), false, true, true, 0, true)
			entity.attach_entity_to_entity(cage_2, cage, 0, v3(), v3(0, 0, 90), false, true, false, 0, true)
			entity.set_entity_visible(temp_ped, false)
			kek_menu.create_thread(function()
				while player.is_player_valid(pid) and entity.is_an_entity(temp_ped) do
					kek_menu.get_control_of_entity(temp_ped, 0)
					ped.clear_ped_tasks_immediately(temp_ped)
					system.yield(0)
				end
				kek_entity.hard_remove_entity_and_its_attachments(temp_ped)
			end, nil)
			return temp_ped
		end
		return 0, 0, 0
	end

-- Setup spawned vehicle
	local function get_prefered_vehicle_pos(hash)
		if kek_menu.toggle["Air #vehicle# spawn mid-air"].on and kek_menu.toggle["Spawn inside of spawned #vehicle#"].on and streaming.is_model_a_heli(hash) then
			return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 10), true) + v3(0, 0, 100 - kek_entity.get_entity_altitude(essentials.get_most_relevant_entity(player.player_id())))
		elseif kek_menu.toggle["Air #vehicle# spawn mid-air"].on and kek_menu.toggle["Spawn inside of spawned #vehicle#"].on and streaming.is_model_a_plane(hash) then
			return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 25), true) + v3(0, 0, 250 - kek_entity.get_entity_altitude(essentials.get_most_relevant_entity(player.player_id())))
		else
			return location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8), true)
		end
	end

	function kek_entity.vehicle_preferences(Vehicle, teleport)
		if kek_menu.toggle["Delete old #vehicle#"].on then
			for i, Entity in pairs(kek_menu.your_vehicle_entity_ids) do
				kek_entity.hard_remove_entity_and_its_attachments(Entity)
			end
			kek_menu.your_vehicle_entity_ids = {}
		end
		if entity.is_an_entity(Vehicle) then
			local hash = entity.get_entity_model_hash(Vehicle)
			if teleport then
				kek_entity.teleport(Vehicle, get_prefered_vehicle_pos(hash))
			end
			if kek_menu.toggle["Spawn inside of spawned #vehicle#"].on then
				if streaming.is_model_a_heli(hash) then
					vehicle.set_heli_blades_full_speed(Vehicle)
				elseif streaming.is_model_a_plane(hash) then
					vehicle.set_vehicle_forward_speed(Vehicle, 100)
				end
				ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Vehicle, -1)
			end
		end
	end

	function kek_entity.set_blip(Entity, sprite_id, color)
		local blip = ui.add_blip_for_entity(Entity)
		ui.set_blip_sprite(blip, sprite_id or 0)
		ui.set_blip_colour(blip, color or 0)
		kek_menu.create_thread(function()
			local pv = Entity
			local original_blip = blip
			while entity.is_an_entity(Entity) and Entity == pv do
				system.yield(0)
			end
			ui.remove_blip(original_blip)
		end, nil)
		return blip
	end

	function kek_entity.spawn_car()
		kek_menu.your_vehicle_entity_ids[#kek_menu.your_vehicle_entity_ids + 1] = player.get_player_vehicle(player.player_id())
		if kek_menu.toggle["Always ask what #vehicle#"].on then
			local input, status = essentials.get_input(lang["Type in what car to use §"], "", 128, 0)
			if status == 2 then
				return
			end
			kek_menu.what_vehicle_model_in_use = input
		end
		if kek_menu.toggle["Delete old #vehicle#"].on then
			for i, Entity in pairs(kek_menu.your_vehicle_entity_ids) do
				kek_entity.hard_remove_entity_and_its_attachments(Entity)
			end
			kek_menu.your_vehicle_entity_ids = {}
		end
		local hash = vehicle_mapper.get_hash_from_name_or_model(kek_menu.what_vehicle_model_in_use)
		local velocity = entity.get_entity_velocity(essentials.get_most_relevant_entity(player.player_id()))
		local Vehicle = kek_menu.spawn_entity(hash, function()
			return get_prefered_vehicle_pos(hash), player.get_player_heading(player.player_id())
		end, kek_menu.toggle["Spawn #vehicle# in godmode"].on, false, kek_menu.toggle["Spawn #vehicle# maxed"].on)
		if kek_menu.toggle["Always f1 wheels on #vehicle#"].on then
			vehicle.set_vehicle_wheel_type(Vehicle, 10)
		end
		kek_entity.vehicle_preferences(Vehicle)
		vehicle.set_vehicle_engine_on(Vehicle, true, true, false)
		kek_menu.your_vehicle_entity_ids[#kek_menu.your_vehicle_entity_ids + 1] = Vehicle
	end

-- Glitch vehicle
	function kek_entity.glitch_vehicle(Vehicle)
		local seat = vehicle.get_free_seat(Vehicle)
		if seat ~= -2 and entity.is_an_entity(Vehicle) then
			local Ped = kek_menu.spawn_entity(0x9CF26183, function() 
				return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + v3(0, 0, 10), 0
			end, true, true, false, 4)
			entity.set_entity_collision(Ped, false, false, false)
			entity.set_entity_visible(Ped, false)
			ped.set_ped_into_vehicle(Ped, Vehicle, seat)
			Entity = kek_menu.spawn_entity(gameplay.get_hash_key(table_of_glitch_entity_models[math.random(1, #table_of_glitch_entity_models)]), function()
				return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + v3(0, 0, 10), 0
			end, true, true, false, 4)
			entity.set_entity_visible(Entity, false)
			entity.attach_entity_to_entity(Entity, Ped, 0, v3(), v3(math.random(0, 180), math.random(0, 180), math.random(0, 180)), true, true, entity.is_entity_a_ped(Entity), 0, false)
		end
	end

-- Teleport player to position
	function kek_entity.teleport_player_and_vehicle_to_position(pid, pos, teleport_you_back_to_original_pos, is_show_message, is_a_toggle, f)
		local initial_pos = player.get_player_coords(player.player_id())
		local status, had_to_teleport = kek_entity.is_target_viable(pid, is_a_toggle, f)
		if status then
			local time = utils.time_ms() + 2000
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

	function kek_entity.teleport_session(pos, f)
		local pids = {}
		for pid = 0, 31 do
			if player.is_player_valid(pid) 
			and (player.is_player_in_any_vehicle(pid) or player.get_player_coords(pid).z == -50) 
			and player.player_id() ~= pid 
			and essentials.get_distance_between(player.get_player_coords(pid), pos) > 35 
			and essentials.is_not_friend(pid) then
				pids[#pids + 1] = pid
			end
		end
		local value = f.value
		while #pids > 0 and f.on and f.value == value do
			system.yield(0)
			table.sort(pids, function(a, b) return (essentials.get_distance_between(player.get_player_ped(a), player.get_player_ped(player.player_id())) < essentials.get_distance_between(player.get_player_ped(b), player.get_player_ped(player.player_id()))) end)
			kek_entity.teleport_player_and_vehicle_to_position(pids[1], pos)
			table.remove(pids, 1)
		end
	end

-- Generate vehicle list
do
	local list_of_end_vehicles = {
		2485144969,
		3505073125,
		4289813342,
		2351681756,
		2049897956,
		970598228,
		3612858749,
		822018448,
		2198148358,
		1353720154,
		3417488910,
		219613597,
		3061159916,
		3251507587,
		2623428164,
		2621610858,
		3039269212,
		1127131465,
		2014313426,
		2157618379,
		184361638,
		1492612435
	}

	local vehicle_category_info = {
		{lang["Compacts §"], 0},
		{lang["Sedans §"], 0},
		{lang["SUVs §"], 0},
		{lang["Coupes §"], 0},
		{lang["Muscle §"], 0},
		{lang["Sports classics §"], 0},
		{lang["Sports §"], 0},
		{lang["Super §"], 0},
		{lang["Motorcycles §"], 0},
		{lang["Off-Road §"], 0},
		{lang["Industrial §"], 0},
		{lang["Utility §"], 0},
		{lang["Vans §"], 0},
		{lang["Cycles §"], 0},
		{lang["Boats §"], 0},
		{lang["Helicopters §"], 0},
		{lang["Planes §"], 0},
		{lang["Service §"], 0},
		{lang["Emergency §"], 0},
		{lang["Military §"], 0},
		{lang["Commercial §"], 0},
		{lang["Trains §"], 0},
		{lang["Open Wheel §"], 0}
	}

	local index = 1
	for i, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
		if hash == list_of_end_vehicles[index] then
			index = index + 1
		end
		vehicle_category_info[index][2] = vehicle_category_info[index][2] + 1
	end

	function kek_entity.generate_vehicle_list(feat_type, feat_str, parent, value_i_func, func)
		local hashes = vehicle.get_all_vehicle_model_hashes()
		for i2, info in pairs(vehicle_category_info) do
			local count = 0
			for i = 1, i2 do
				count = count + vehicle_category_info[i][2]
			end
			local parent = kek_menu.add_feature(info[1], "parent", parent.id, function(f)
				if f.child_count == 0 then
					for i = count - info[2] + 1, count do
						local feature = kek_menu.add_feature(vehicle_mapper.get_translated_vehicle_name(hashes[i]), feat_type, f.id, func)
						feature.data = hashes[i]
						feature:set_str_data(feat_str)
						feature.value = value_i_func(hashes[i])
					end
				end
			end)
		end
	end

	function kek_entity.generate_player_vehicle_list(feature_info, parent, func, initial_name)
		local hashes = vehicle.get_all_vehicle_model_hashes()
		for i2, info in pairs(vehicle_category_info) do
			local count = 0
			for i = 1, i2 do
				count = count + vehicle_category_info[i][2]
			end
			local parent = kek_menu.add_player_feature(info[1], "parent", parent, function(f, pid)
				if f.child_count == 0 then
					for i = count - info[2] + 1, count do
						local feature_id = kek_menu.add_player_feature(vehicle_mapper.get_translated_vehicle_name(hashes[i])..initial_name, feature_info[1], f.id, func).id
						if feature_info[1]:find("value_i", 1, true) then
							menu.get_player_feature(feature_id).max = feature_info[2]
							menu.get_player_feature(feature_id).min = feature_info[3]
							menu.get_player_feature(feature_id).mod = feature_info[4]
							menu.get_player_feature(feature_id).value = feature_info[5]
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

return kek_entity