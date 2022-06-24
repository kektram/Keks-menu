-- Copyright © 2020-2022 Kektram

local custom_upgrades <const> = {version = "1.0.2"}

local essentials <const> = require("Essentials")
local kek_entity <const> = require("Kek's entity functions")
local weapon_mapper <const> = require("Weapon mapper")
local enums <const> = require("Enums")

function custom_upgrades.create_combat_ped(...)
	local Vehicle <const> = ...
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		if vehicle.get_free_seat(Vehicle) ~= -2 then
			local Ped <const> = kek_entity.spawn_networked_ped(gameplay.get_hash_key("a_f_y_topless_01"), function()
				return kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8), player.get_player_heading(player.player_id())
			end)
			kek_entity.set_combat_attributes(Ped, true, {})
			local weapon_hash <const> = weapon.get_all_weapon_hashes()[math.random(1, #weapon.get_all_weapon_hashes())]
			weapon.give_delayed_weapon_to_ped(Ped, weapon_hash, 0, 1)
			weapon_mapper.set_ped_weapon_attachments(Ped, true, weapon_hash)
			ped.set_ped_into_vehicle(Ped, Vehicle, vehicle.get_free_seat(Vehicle))
		end
	end
end

function custom_upgrades.vehicle_turret(...)
	local Vehicle <const>,
	turret <const>,
	offset <const> = ...
	essentials.assert(Vehicle ~= turret, "Attempted to attach entity to itself.")
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		menu.create_thread(function()
			while entity.is_entity_an_object(turret) and entity.is_entity_a_vehicle(Vehicle) do
				if player.get_player_vehicle(player.player_id()) == Vehicle and player.is_player_in_any_vehicle(player.player_id()) then
					entity.attach_entity_to_entity(turret, Vehicle, 0, offset, cam.get_gameplay_cam_rot() + v3(cam.get_gameplay_cam_rot().x * -2, 0, 180), false, true, false, 0, false)
					if controls.is_disabled_control_pressed(0, enums.inputs["RIGHT MOUSE BUTTON A"]) then
						gameplay.shoot_single_bullet_between_coords(kek_entity.get_vector_in_front_of_me(0.5), kek_entity.get_vector_in_front_of_me(2000), 100, gameplay.get_hash_key("weapon_heavysniper_mk2"), player.get_player_ped(player.player_id()), true, false, 3000)
					end
					if controls.is_disabled_control_pressed(0, enums.inputs["LEFT MOUSE BUTTON RT"]) then
						essentials.use_ptfx_function(
							gameplay.shoot_single_bullet_between_coords, 
							kek_entity.get_vector_in_front_of_me(8), 
							kek_entity.get_vector_in_front_of_me(2000), 
							100, 
							gameplay.get_hash_key("weapon_airstrike_rocket"), 
							player.get_player_ped(player.player_id()), 
							true, 
							false, 
							3000
						)
					end
				end
				system.yield(0)
			end
			kek_entity.clear_entities({turret})
		end, nil)
	end
end

function custom_upgrades.torque_modifier(...)
	local Vehicle <const>, multiplier <const> = ...
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		menu.create_thread(function()
			while entity.is_entity_a_vehicle(Vehicle) and player.get_player_from_ped(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver)) == player.player_id() do
				kek_entity.get_control_of_entity(Vehicle, 0)
				vehicle.set_vehicle_engine_torque_multiplier_this_frame(Vehicle, multiplier)
				system.yield(0)
			end
		end, nil)
	end
end

return essentials.const_all(custom_upgrades)