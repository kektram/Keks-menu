-- Copyright © 2020-2022 Kektram

local troll_entity <const> = {version = "1.0.7"}

local weapon_mapper <const> = require("Weapon mapper")
local location_mapper <const> = require("Location mapper")
local memoize <const> = require("Memoize")
local vehicle_mapper <const> = require("Vehicle mapper")
local ped_mapper <const> = require("Ped mapper")
local essentials <const> = require("Essentials")
local kek_entity <const> = require("Kek's entity functions")
local enums <const> = require("Enums")
local settings <const> = require("Settings")
local drive_style_mapper <const> = require("Drive style mapper")

local tracker <const> = {}
function troll_entity.spawn_standard(...)
	local f <const>, grief_function <const> = ...
	local value <const> = f.value
	local entities
	for pid in essentials.players(true) do
		if f.on and essentials.is_not_friend(pid) then
			local scid <const> = player.get_player_scid(pid)
			if not tracker[scid] then
				tracker[scid] = essentials.const({time = 0, vehicle = 0})
			end
			if (not entity.is_entity_a_vehicle(tracker[scid].vehicle) or ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(tracker[scid].vehicle, enums.vehicle_seats.driver)))
			and utils.time_ms() > tracker[scid].time
			and essentials.is_not_friend(pid)
			and (not settings.toggle["Exclude yourself from trolling"].on or player.player_id() ~= pid) then
				local Vehicle, Table
				repeat
					system.yield(0)
					Vehicle, Table = grief_function(pid)
				until not player.is_player_valid(pid) or not f.on or f.value ~= value or kek_entity.is_entity_valid(Vehicle) or Vehicle == -1
				if player.is_player_valid(pid) and f.on and f.value == value and kek_entity.is_entity_valid(Vehicle) then
					tracker[scid] = essentials.const({time = utils.time_ms() + 30000, vehicle = Vehicle})
					entities = entities or {} -- Only create table if needed to spare memory
					entities[#entities + 1] = Table or Vehicle
				end
			end
		end
	end
	return entities
end

function troll_entity.spawn_standard_alone(...)
	local f <const>, pid <const>, grief_function <const> = ...
	local scid <const> = player.get_player_scid(pid)
	if not tracker[scid] then
		tracker[scid] = essentials.const({time = 0, vehicle = 0})
	end
	if (not entity.is_entity_a_vehicle(tracker[scid].vehicle) or ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(tracker[scid].vehicle, enums.vehicle_seats.driver)))
	and utils.time_ms() > tracker[scid].time then
		local Vehicle, Table
		repeat
			system.yield(0)
			Vehicle, Table = grief_function(pid)
		until not player.is_player_valid(pid) or not f.on or kek_entity.is_entity_valid(Vehicle) or Vehicle == -1
		if player.is_player_valid(pid) and f.on and kek_entity.is_entity_valid(Vehicle) then
			tracker[scid] = essentials.const({time = utils.time_ms() + 30000, vehicle = Vehicle})
		end
		return Table or Vehicle
	end
	return 0
end

local combat_attributes_put_in_seats <const> = essentials.const(					{
	use_vehicle = true, 
	driveby = true,
	cover = true,
	leave_vehicle = false, 
	unarmed_fight_armed = true, 
	taunt_in_vehicle = true, 
	always_fight = true, 
	ignore_traffic = true, 
	use_fireing_weapons =  true
})

local weapons <const> = essentials.const(weapon_mapper.get_table_of_weapons({
	rifles = true,
	smgs = true
}))

function troll_entity.setup_peds_and_put_in_seats(...)
	local seats <const>,
	hash <const>,
	Vehicle <const>,
	pid <const>,
	dont_clear_vehicle <const>,
	entity_table <const> = ...
	if not entity.is_entity_a_vehicle(Vehicle) then
		return
	end
	vehicle.set_vehicle_doors_locked_for_all_players(Vehicle, true)
	vehicle.set_vehicle_can_be_locked_on(Vehicle, false, true)
	local peds <const> = entity_table or {}
	for i = 1, #seats do
		if seats[i] <= vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(Vehicle)) - 2 and not entity.is_entity_a_ped(vehicle.get_ped_in_vehicle_seat(Vehicle, seats[i])) then
			menu.create_thread(function(Ped)
				peds[#peds + 1] = Ped
				local weapon_hash <const> = weapons[math.random(1, #weapons)]
				weapon.give_delayed_weapon_to_ped(Ped, weapon_hash, 0, 1)
				weapon_mapper.set_ped_weapon_attachments(Ped, true, weapon_hash)
				kek_entity.set_combat_attributes(
					Ped, 
					false, 
					combat_attributes_put_in_seats
				)
				ped.set_ped_can_ragdoll(Ped, false)
				if not ped.set_ped_into_vehicle(Ped, Vehicle, seats[i]) then
					kek_entity.clear_entities({Ped})
					return
				end
				local time <const> = utils.time_ms() + 240000
				if seats[i] == -1 then
					while time > utils.time_ms() and kek_entity.is_entity_valid(Ped) and not entity.is_entity_dead(Ped) and kek_entity.is_entity_valid(Vehicle) and not entity.is_entity_dead(Vehicle) and player.is_player_valid(pid) do
						vehicle.set_heli_blades_full_speed(Vehicle)
						ai.task_vehicle_follow(Ped, Vehicle, player.get_player_ped(pid), 150, settings.in_use["Drive style"], 6)
						system.yield(500)
						ai.task_combat_ped(Ped, player.get_player_ped(pid), 0, 16)
						essentials.wait_conditional(15000, function()
							return time > utils.time_ms() and kek_entity.is_entity_valid(Ped) and not entity.is_entity_dead(Ped) and kek_entity.is_entity_valid(Vehicle) and not entity.is_entity_dead(Vehicle) and player.is_player_valid(pid)
						end)
					end
					if dont_clear_vehicle then
						entity.detach_entity(ped.get_vehicle_ped_is_using(Ped) or 0)
						kek_entity.clear_entities({Ped})
					else
						kek_entity.clear_entities({Ped})
						kek_entity.hard_remove_entity_and_its_attachments(Vehicle)
					end
				else
					while time > utils.time_ms() and kek_entity.is_entity_valid(Ped) and not entity.is_entity_dead(Ped) and not entity.is_entity_dead(Vehicle) and player.is_player_valid(pid) do
						essentials.wait_conditional(15000, function()
							return time > utils.time_ms() and kek_entity.is_entity_valid(Ped) and not entity.is_entity_dead(Ped) and not entity.is_entity_dead(Vehicle) and player.is_player_valid(pid)
						end)
						ai.task_combat_ped(Ped, player.get_player_ped(pid), 0, 16)
					end
					kek_entity.clear_entities({Ped, Vehicle})
				end
			end, kek_entity.spawn_ped_or_vehicle(hash, function()
				return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + memoize.v3(0, 0, 20), 0
			end, false, false, enums.ped_types.civmale, 15))
		end
	end
	return peds
end

local seats_army <const> = essentials.const_all({
	valkyrie = {
		enums.vehicle_seats.driver, 
		enums.vehicle_seats.left_rear, 
		enums.vehicle_seats.right_rear
	},
	half_track = {
		enums.vehicle_seats.driver, 
		enums.vehicle_seats.left_rear
	},
	driver = {enums.vehicle_seats.driver}
})

function troll_entity.send_army(...)
	local pid <const> = ...
	local update <const> = kek_entity.entity_manager:update()
	if not update.is_vehicle_limit_not_breached 
	or not update.is_ped_limit_not_breached 
	or kek_entity.entity_manager.counts.ped > settings.valuei["Ped limit"].value - 90 then
		return -2
	end
	local entities <const> = {}
	entities.valkyrie = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("valkyrie2"), function()
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true) + memoize.v3(0, 0, 35), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(entities.valkyrie) then
		return -2
	end
	troll_entity.setup_peds_and_put_in_seats(seats_army.valkyrie, gameplay.get_hash_key("s_m_y_swat_01"), entities.valkyrie, pid, false, entities)

	entities.half_track = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("halftrack"), function()
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(entities.half_track) then
		return entities.valkyrie, entities
	end
	troll_entity.setup_peds_and_put_in_seats(seats_army.half_track, gameplay.get_hash_key("s_m_y_swat_01"), entities.half_track, pid, false, entities)

	entities.thruster = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("thruster"), function()
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true) + memoize.v3(0, 0, 35), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(entities.thruster) then
		return entities.half_track, entities
	end
	troll_entity.setup_peds_and_put_in_seats(seats_army.driver, gameplay.get_hash_key("s_m_y_swat_01"), entities.thruster, pid, false, entities)

	entities.khanjali = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("khanjali"), function()
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(entities.khanjali) then
		return entities.thruster, entities
	end
	vehicle.set_vehicle_mod(entities.khanjali, 10, 1)
	troll_entity.setup_peds_and_put_in_seats(seats_army.driver, gameplay.get_hash_key("s_m_y_swat_01"), entities.khanjali, pid, false, entities)
	return entities.khanjali, entities
end

local combat_attributes_attack_chopper <const> = essentials.const(		{
	use_vehicle = true, 
	driveby = true,
	cover = false,
	leave_vehicle = false, 
	unarmed_fight_armed = true, 
	taunt_in_vehicle = true, 
	always_fight = true, 
	ignore_traffic = true, 
	use_fireing_weapons =  true
})

local seats_attack_chopper <const> = essentials.const({
	enums.vehicle_seats.passenger, 
	enums.vehicle_seats.left_rear, 
	enums.vehicle_seats.right_rear, 
	enums.vehicle_seats.extra_seat_1
})

function troll_entity.send_attack_chopper(...)
	local pid <const> = ...
	local update <const> = kek_entity.entity_manager:update()
	if not update.is_vehicle_limit_not_breached 
	or not update.is_ped_limit_not_breached 
	or kek_entity.entity_manager.counts.ped > settings.valuei["Ped limit"].value - 15 then
		return -2
	end
	local hash <const> = vehicle_mapper.HELICOPTERS[math.random(1, #vehicle_mapper.HELICOPTERS)]
	local chopper <const> = kek_entity.spawn_ped_or_vehicle(hash, function()
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true) + memoize.v3(0, 0, 35), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(chopper) then
		return -2
	end
	vehicle.control_landing_gear(chopper, 3)
	vehicle.set_vehicle_can_be_locked_on(chopper, false, true)
	vehicle.set_vehicle_doors_locked_for_all_players(chopper, true)
	local pilot <const> = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("a_f_y_topless_01"), function() 
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid)) + memoize.v3(0, 0, 10), 0
	end, false, false, enums.ped_types.civmale, 15)
	if not ped.set_ped_into_vehicle(pilot, chopper, enums.vehicle_seats.driver) then
		kek_entity.clear_entities({pilot, chopper})
		return -2
	end
	kek_entity.set_combat_attributes(
		pilot, 
		false, 
		combat_attributes_attack_chopper
	)
	menu.create_thread(function()
		local timer = 0
		local time <const> = utils.time_ms() + 240000
		while time > utils.time_ms() and kek_entity.is_entity_valid(pilot) and kek_entity.is_entity_valid(chopper) and not entity.is_entity_dead(chopper) and player.is_player_valid(pid) do
			vehicle.set_heli_blades_full_speed(chopper)
			ai.task_vehicle_follow(pilot, chopper, player.get_player_ped(pid), 150, settings.in_use["Drive style"], 6)
			system.yield(250)
			ai.task_combat_ped(pilot, player.get_player_ped(pid), 0, 16)
			system.yield(250)
			if utils.time_ms() > timer and memoize.get_distance_between(player.get_player_ped(pid), chopper) < 120 then
				ai.task_vehicle_shoot_at_ped(pilot, player.get_player_ped(pid), 2000)
				timer = utils.time_ms() + 5000
				system.yield(250)
			end
		end
		kek_entity.clear_entities({pilot, chopper})
	end, nil)
	troll_entity.setup_peds_and_put_in_seats(seats_attack_chopper, gameplay.get_hash_key("s_m_y_swat_01"), chopper, pid)
	return chopper
end

local drive_style_kek_chopper <const> = drive_style_mapper.get_drive_style_from_list({
	["Allow going wrong way"] = true,
	["Take shortest path"] = true,
	["Ignore all pathing"] = true
})

local combat_attributes_kek_pilot <const> = essentials.const(		{
	use_vehicle = true, 
	driveby = false,
	cover = false,
	leave_vehicle = false, 
	unarmed_fight_armed = true, 
	taunt_in_vehicle = true, 
	always_fight = true, 
	ignore_traffic = true, 
	use_fireing_weapons =  true
})

function troll_entity.send_kek_chopper(...)
	local pid <const> = ...
	local update <const> = kek_entity.entity_manager:update()
	if not update.is_vehicle_limit_not_breached 
	or not update.is_ped_limit_not_breached
	or kek_entity.entity_manager.counts.ped > settings.valuei["Ped limit"].value - 45 then
		return -2
	end
	local chopper <const> = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("havok"), function() 
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid)) + v3(math.random(-50, 50), math.random(-50, 50), 30), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(chopper) then
		return -2
	end
	vehicle.control_landing_gear(chopper, 3)
	local pilot <const> = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("s_m_y_swat_01"), function()
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid)) + memoize.v3(0, 0, 20), 0
	end, false, false, enums.ped_types.civmale, 20)
	kek_entity.set_combat_attributes(
		pilot, 
		false, 
		combat_attributes_kek_pilot
	)
	if not ped.set_ped_into_vehicle(pilot, chopper, enums.vehicle_seats.driver) then
		kek_entity.clear_entities({pilot, chopper})
		return -2
	end
	menu.create_thread(function()
		local time <const> = utils.time_ms() + 240000
		while time > utils.time_ms() 
		and player.is_player_valid(pid) 
		and kek_entity.is_entity_valid(pilot) 
		and kek_entity.is_entity_valid(chopper) 
		and not entity.is_entity_dead(pilot)
		and not entity.is_entity_dead(chopper) do
			vehicle.set_heli_blades_full_speed(chopper)
			ai.task_vehicle_follow(pilot, chopper, player.get_player_ped(pid), 300, drive_style_kek_chopper, 50)
			system.yield(250)
		end
		kek_entity.clear_entities({pilot, chopper})
	end, nil)

	menu.create_thread(function()
		local time <const> = utils.time_ms() + 240000
		local vehicles = {}
		while time > utils.time_ms() 
		and player.is_player_valid(pid) 
		and kek_entity.is_entity_valid(pilot) 
		and kek_entity.is_entity_valid(chopper)
		and not entity.is_entity_dead(pilot)
		and not entity.is_entity_dead(chopper) do
			system.yield(0)
			if memoize.get_distance_between(chopper, player.get_player_ped(pid)) < 170 and not entity.is_entity_dead(player.get_player_ped(pid)) then
				for i = 1, 4 do
					if not entity.is_entity_a_vehicle(vehicles[i] or 0) then
						local hash <const> = vehicle_mapper.get_random_vehicle()
						vehicles[i] = kek_entity.spawn_ped_or_vehicle(hash, function()
							return kek_entity.vehicle_get_vec_rel_to_dims(hash, chopper), entity.get_entity_heading(chopper)
						end)
					else
						kek_entity.repair_car(vehicles[i], true)
						entity.set_entity_no_collsion_entity(vehicles[i], chopper, false)
						for i2 = 1, 4 do
							if vehicles[i2] ~= vehicles[i] and entity.is_entity_a_vehicle(vehicles[i]) and entity.is_entity_a_vehicle(vehicles[i2]) and kek_entity.get_control_of_entity(vehicles[i]) then
								entity.set_entity_no_collsion_entity(vehicles[i], vehicles[i2], false)
							end
						end
						kek_entity.teleport(vehicles[i], kek_entity.vehicle_get_vec_rel_to_dims(entity.get_entity_model_hash(vehicles[i]), chopper))
						kek_entity.set_entity_heading(vehicles[i], entity.get_entity_heading(chopper))
					end
					kek_entity.set_entity_rotation(vehicles[i], entity.get_entity_rotation(chopper))
					vehicle.set_vehicle_forward_speed(vehicles[i], 100)
					essentials.use_ptfx_function(vehicle.set_vehicle_out_of_control, vehicles[i], false, true)
				end
				system.yield(1750)
			end
		end
		kek_entity.clear_entities(vehicles)
	end, nil)
	return chopper
end

local weapons <const> = essentials.const((function() -- Is a function to be able to be a read-only <const> table
	local temp <const> = weapon_mapper.get_table_of_weapons({
		rifles = true,
		smgs = true,
		heavy = true
	})
	table.sort(temp, function(a, b) -- So that binary search works
		return a < b
	end)
	return temp
end)())

local close_range <const> = essentials.const((function() -- Is a function to be able to be a read-only <const> table
	local temp <const> = essentials.deep_copy(weapon_mapper.melee_hashes)
	temp[#temp + 1] = gameplay.get_hash_key("weapon_stungun")
	temp[#temp + 1] = gameplay.get_hash_key("weapon_raypistol")
	table.sort(temp, function(a, b) -- So that binary search works
		return a < b
	end)
	return temp
end)())

local combat_attributes_clown <const> = essentials.const(		{
	use_vehicle = true, 
	driveby = true,
	cover = false,
	leave_vehicle = false, 
	unarmed_fight_armed = true, 
	taunt_in_vehicle = true, 
	always_fight = true, 
	ignore_traffic = true, 
	use_fireing_weapons =  true
})
local clown_spawn_weapons <const> = essentials.const({
	gameplay.get_hash_key("weapon_appistol"), 
	gameplay.get_hash_key("weapon_combatmg_mk2"),
	gameplay.get_hash_key("weapon_combatmg_mk2") -- clown vans get 1 to 3 passengers. passenger 2 & 3 gets the combat mg.
})

local clown_relationship_group
local function create_clown_relationship_group()
	if not clown_relationship_group or not ped.does_relationship_group_exist(clown_relationship_group) then
		clown_relationship_group = ped.add_relationship_group("clown_van")
		local ids <const> = enums.relationship_relation_ids
		local hashes <const> = enums.relationship_group_hashes
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.PLAYER)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.FIREMAN)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.MEDIC)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.COP)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.ARMY)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.GANG_1)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.GANG_2)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.GANG_9)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.GANG_10)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.AMBIENT_GANG_LOST)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.AMBIENT_GANG_MEXICAN)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.AMBIENT_GANG_FAMILY)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.AMBIENT_GANG_BALLAS)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.AMBIENT_GANG_MARABUNTE)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.AMBIENT_GANG_CULT)
		ped.set_relationship_between_groups(ids.Companion, clown_relationship_group, hashes.AMBIENT_GANG_SALVA)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.AMBIENT_GANG_WEICHENG)
		ped.set_relationship_between_groups(ids.Hate, clown_relationship_group, hashes.AMBIENT_GANG_HILLBILLY)

		return clown_relationship_group
	end
end

function troll_entity.send_clown_van(...)
	local pid <const> = ...
	local update <const> = kek_entity.entity_manager:update()
	if not update.is_vehicle_limit_not_breached 
	or not update.is_ped_limit_not_breached
	or kek_entity.entity_manager.counts.ped > settings.valuei["Ped limit"].value - 60 then
		return -2
	end
	create_clown_relationship_group()
	local clown_van <const> = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("speedo2"), function() 
		return location_mapper.get_most_accurate_position(memoize.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true), 0
	end, false, true)
	if not entity.is_entity_a_vehicle(clown_van) then
		return -2
	end
	vehicle.set_vehicle_mod(clown_van, 14, 2)
	local driver <const> = kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key("s_m_y_clown_01"), function()
		return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + memoize.v3(0, 0, 20), 0
	end, false, false, enums.ped_types.civmale, 15)
	if not ped.set_ped_into_vehicle(driver, clown_van, enums.vehicle_seats.driver) then
		kek_entity.clear_entities({driver, clown_van})
		return -2
	end
	weapon.give_delayed_weapon_to_ped(driver, gameplay.get_hash_key("weapon_appistol"), 0, 1)
	weapon_mapper.set_ped_weapon_attachments(driver, false, gameplay.get_hash_key("weapon_appistol"))
	kek_entity.set_combat_attributes(
		driver, 
		false, 
		combat_attributes_clown
	)
	ped.set_ped_relationship_group_hash(driver, clown_relationship_group)
	ped.set_can_attack_friendly(driver, false, false)
	local time <const> = utils.time_ms() + 240000
	local ai_follow_tracker = 0
	local driver_thread <const> = menu.create_thread(function()
		while time > utils.time_ms() and player.is_player_valid(pid) and kek_entity.is_entity_valid(clown_van) and not entity.is_entity_dead(clown_van) and kek_entity.is_entity_valid(driver) do
			if not ped.is_ped_in_vehicle(driver, clown_van) then
				ped.clear_ped_tasks_immediately(vehicle.get_ped_in_vehicle_seat(clown_van, enums.vehicle_seats.driver))
				ped.set_ped_into_vehicle(driver, clown_van, enums.vehicle_seats.driver)
				system.yield(500)
			end
			if ped.is_ped_in_vehicle(driver, clown_van) and utils.time_ms() > ai_follow_tracker then
				ai.task_vehicle_follow(driver, clown_van, player.get_player_ped(pid), 120, settings.in_use["Drive style"], 10)
				ai_follow_tracker = utils.time_ms() + 8000
			end
			if entity.is_entity_dead(driver) then
				system.yield(math.random(500, 1500))
				if essentials.request_ptfx("scr_rcbarry2") then
					essentials.use_ptfx_function(graphics.start_networked_particle_fx_non_looped_at_coord, "scr_clown_death", entity.get_entity_coords(driver), memoize.v3(), 1, true, true, true)
				end
				ped.resurrect_ped(driver)
				ped.clear_ped_tasks_immediately(driver)
				system.yield(250)
				ped.set_ped_into_vehicle(driver, clown_van, enums.vehicle_seats.driver)
			end
			if math.abs(entity.get_entity_pitch(clown_van)) > 40 then
				entity.set_entity_rotation(clown_van, memoize.v3())
			end
			system.yield(250)
		end
		kek_entity.clear_entities({clown_van, driver})
	end, nil)

	for i = 1, math.random(1, 3) do
		menu.create_thread(function(clown)
			local clown_weapon = clown_spawn_weapons[i]
			weapon.give_delayed_weapon_to_ped(clown, clown_weapon, 0, 1)
			weapon_mapper.set_ped_weapon_attachments(clown, true, clown_weapon)
			kek_entity.set_combat_attributes(
				clown, 
				false, 
				combat_attributes_clown
			)
			ped.set_ped_relationship_group_hash(clown, clown_relationship_group)
			ped.set_can_attack_friendly(clown, false, false)
			ped.set_ped_into_vehicle(clown, clown_van, enums.vehicle_seats.first_free_seat)
			local Ped = player.get_player_ped(pid) -- To reapply combat ai if their ped id changes
			ai.task_combat_ped(clown, player.get_player_ped(pid), 0, 16)
			while kek_entity.is_entity_valid(clown) and not menu.has_thread_finished(driver_thread) do
				if entity.is_entity_dead(clown) then
					system.yield(math.random(1000, 2500))
					if essentials.request_ptfx("scr_rcbarry2") then
						essentials.use_ptfx_function(graphics.start_networked_particle_fx_non_looped_at_coord, "scr_clown_death", entity.get_entity_coords(clown), memoize.v3(), 1, true, true, true)
					end
					ped.resurrect_ped(clown)
					ped.clear_ped_tasks_immediately(clown)
					ped.set_ped_into_vehicle(clown, clown_van, enums.vehicle_seats.first_free_seat)
					system.yield(250)
					ai.task_combat_ped(clown, player.get_player_ped(pid), 0, 16)
				end
				if not ped.is_ped_in_vehicle(clown, clown_van) then
					if player.is_player_in_any_vehicle(pid) or memoize.get_distance_between(player.get_player_ped(pid), clown) > 40 then
						if not essentials.binary_search(weapons, clown_weapon) then
							if weapon.has_ped_got_weapon(clown, clown_weapon) then
								weapon.remove_weapon_from_ped(clown, clown_weapon)
							end
							clown_weapon = weapons[math.random(1, #weapons)]
							weapon.give_delayed_weapon_to_ped(clown, clown_weapon, 0, 1)
							weapon_mapper.set_ped_weapon_attachments(clown, true, clown_weapon)
						end
					elseif not essentials.binary_search(close_range, clown_weapon) then
						if weapon.has_ped_got_weapon(clown, clown_weapon) then
							weapon.remove_weapon_from_ped(clown, clown_weapon)
						end
						clown_weapon = close_range[math.random(1, #close_range)]
						weapon.give_delayed_weapon_to_ped(clown, clown_weapon, 0, 1)
						weapon_mapper.set_ped_weapon_attachments(clown, true, clown_weapon)
					end
				end
				if not ped.is_ped_in_vehicle(clown, clown_van) and memoize.get_distance_between(player.get_player_ped(pid), clown) > 70 then
					ped.set_ped_into_vehicle(clown, clown_van, enums.vehicle_seats.first_free_seat)
				elseif ped.is_ped_in_vehicle(clown, clown_van) 
				and not entity.is_entity_dead(player.get_player_ped(pid)) 
				and memoize.get_distance_between(clown_van, player.get_player_ped(pid)) < 30 then
					ai.task_leave_vehicle(clown, clown_van, 256)
					system.yield(250)
					ai.task_combat_ped(clown, player.get_player_ped(pid), 0, 16)
				end
				system.yield(250)
				if Ped ~= player.get_player_ped(pid) then
					Ped = player.get_player_ped(pid)
					ai.task_combat_ped(clown, player.get_player_ped(pid), 0, 16)
				end
			end
			kek_entity.clear_entities({clown})
		end, kek_entity.spawn_ped_or_vehicle(gameplay.get_hash_key(ped_mapper.LIST_OF_SPECIAL_PEDS[math.random(1, #ped_mapper.LIST_OF_SPECIAL_PEDS)]), function()
			return entity.get_entity_coords(essentials.get_ped_closest_to_your_pov()) + memoize.v3(0, 0, 20), 0
		end, false, false, enums.ped_types.civmale, 15))
	end
	return clown_van
end

return essentials.const_all(troll_entity)