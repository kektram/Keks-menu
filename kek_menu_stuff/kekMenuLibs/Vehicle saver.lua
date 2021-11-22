-- Copyright © 2020-2021 Kektram

kek_menu.lib_versions["Vehicle saver"] = "1.0.7"

local essentials = kek_menu.require("Essentials")
local kek_entity = kek_menu.require("Kek's entity functions")
local vehicle_saver = {}

local function get_properties(...)
	local Entity <const>, initial <const> = ...
	local info = {
		["ModelHash"] = entity.get_entity_model_hash(Entity),
		["InitialHandle"] = Entity,
		["IsOnFire"] = entity.is_entity_on_fire(Entity),
		["IsVisible"] = entity.is_entity_visible(Entity),
		["IsInvincible"] = entity.get_entity_god_mode(Entity),
		["MaxHealth"] = ped.get_ped_max_health(Entity),
		["OpacityLevel"] = 255,
		["LodDistance"] = 20000,
		["Dynamic"] = true,
		["FrozenPos"] = false,
		["Health"] = ped.get_ped_health(Entity)
	}
	if entity.is_entity_a_ped(Entity) then
		info["IsCollisionProof"] = entity.has_entity_collided_with_anything(Entity)
		info["Type"] = 1
	elseif entity.is_entity_a_vehicle(Entity) then
		info["IsCollisionProof"] = initial
		info["Type"] = 2
	else
		info["IsCollisionProof"] = entity.has_entity_collided_with_anything(Entity)
		info["Type"] = 3
	end
	if not initial then
		info["Attachment isAttached=\"true\""] = {
			["AttachedTo"] = entity.get_entity_attached_to(Entity),
			["BoneIndex"] = 0,
			["Pitch"] = entity.get_entity_pitch(Entity),
			["Roll"] = entity.get_entity_roll(Entity),
			["Yaw"] = entity.get_entity_rotation(Entity).z,
			["X"] = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(Entity), Entity)).x,
			["Y"] = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(Entity), Entity)).y,
			["Z"] = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(Entity), Entity)).z
		}
		info["PositionRotation"] = {
			["X"] = entity.get_entity_coords(Entity).x,
			["Y"] = entity.get_entity_coords(Entity).y,
			["Z"] = entity.get_entity_coords(Entity).z,
			["Pitch"] = entity.get_entity_pitch(Entity),
			["Roll"] = entity.get_entity_roll(Entity),
			["Yaw"] = entity.get_entity_rotation(Entity).z
		}
	end
	if entity.is_entity_a_ped(Entity) then
		info["PedProperties"] = {
			["CanRagdoll"] = ped.can_ped_ragdoll(Entity),
			["PedProps"] = {},
			["PedComps"] = {},
			["BlendData"] = ped.get_ped_head_blend_data(Entity) or {},
			["FacialFeatures"] = {},
			["HeadOverlay"] = {},
			["PedVehicleSeat"] = kek_entity.get_seat_ped_is_in(ped.get_vehicle_ped_is_using(Entity), Entity),
			["RelationshipGroup"] = ped.get_ped_relationship_group_hash(Entity),
			["HairColor"] = ped.get_ped_hair_color(Entity),
			["HairHighlightColor"] = ped.get_ped_hair_highlight_color(Entity),
			["EyeColor"] = ped.get_ped_eye_color(Entity)
		}
		for i = 0, 11 do 
			info["PedProperties"]["HeadOverlay"]["_"..i] = {
				["Value"] = ped.get_ped_head_overlay_value(Entity, i),
				["Opacity"] = ped.get_ped_head_overlay_opacity(Entity, i),
				["ColorType"] = ped.get_ped_head_overlay_color_type(Entity, i),
				["Color"] = ped.get_ped_head_overlay_color(Entity, i),
				["HighlightColor"] = ped.get_ped_head_overlay_highlight_color(Entity, i)
			}
		end
		for i = 0, 19 do
			info["PedProperties"]["FacialFeatures"]["_"..i] = ped.get_ped_face_feature(Entity, i)
		end
		for i = 0, 9 do
			info["PedProperties"]["PedProps"]["_"..i] = ped.get_ped_prop_index(Entity, i)..","..ped.get_ped_prop_texture_index(Entity, i)
		end
		for i = 0, 11 do
			info["PedProperties"]["PedComps"]["_"..i] = ped.get_ped_texture_variation(Entity, i)..","..ped.get_ped_drawable_variation(Entity, i)
		end
		if not ped.is_ped_in_any_vehicle(Entity) then
			info["PedProperties"]["CurrentWeapon"] = ped.get_current_ped_weapon(Entity)
		end
	elseif entity.is_entity_a_vehicle(Entity) then
		info["VehicleProperties"] = {
			["Colours"] = {
				["Primary"] = vehicle.get_vehicle_primary_color(Entity),
				["Secondary"] = vehicle.get_vehicle_secondary_color(Entity),
				["Pearl"] = vehicle.get_vehicle_pearlecent_color(Entity),
				["Rim"] = vehicle.get_vehicle_wheel_color(Entity),
				["IsPrimaryColourCustom"] = vehicle.is_vehicle_primary_colour_custom(Entity),
				["IsSecondaryColourCustom"] = vehicle.is_vehicle_secondary_colour_custom(Entity)
			},
			["Livery"] = vehicle.get_vehicle_livery(Entity),
			["RpmMultiplier"] = 1,
			["TorqueMultiplier"] = 1,
			["WheelsRenderSize"] = vehicle.get_vehicle_wheel_render_size(Entity),
			["WheelsRenderWidth"] = vehicle.get_vehicle_wheel_render_width(Entity),
			["LandingGearState"] = vehicle.get_landing_gear_state(Entity),
			["ReducedGrip"] = vehicle.get_vehicle_reduce_grip(Entity),
			["MaxGear"] = vehicle.get_vehicle_max_gear(Entity),
			["CurrentGear"] = vehicle.get_vehicle_current_gear(Entity),
			["WheelsCount"] = vehicle.get_vehicle_wheel_count(Entity),
			["WheelType"] = math.random(0, 11),
			["NumberPlateText"] = kek_menu.settings["Plate vehicle text"],
			["NumberPlateIndex"] = math.random(0, 3),
			["WindowTint"] = vehicle.get_vehicle_window_tint(Entity),
			["Neons"] = {
				["R"] = vehicle.get_vehicle_neon_lights_color(Entity),
				["G"] = 1,
				["B"] = 1,
				["Left"] = vehicle.is_vehicle_neon_light_enabled(Entity, 0, true),
				["Right"] = vehicle.is_vehicle_neon_light_enabled(Entity, 1, true),
				["Front"] = vehicle.is_vehicle_neon_light_enabled(Entity, 2, true),
				["Back"] = vehicle.is_vehicle_neon_light_enabled(Entity, 3, true)
			},
			["Mods"] = {}
		}
		for i = 0, vehicle.get_vehicle_wheel_count(Entity) - 1 do
			info["VehicleProperties"]["Wheel_"..i] = {
				["TireRadius"] = vehicle.get_vehicle_wheel_tire_radius(Entity, i),
				["RimRadius"] = vehicle.get_vehicle_wheel_rim_radius(Entity, i),
				["TireWidth"] = vehicle.get_vehicle_wheel_tire_width(Entity, i),
				["RotationSpeed"] = vehicle.get_vehicle_wheel_rotation_speed(Entity, i),
				["Power"] = vehicle.get_vehicle_wheel_power(Entity, i),
				["Health"] = vehicle.get_vehicle_wheel_health(Entity, i),
				["BrakePressure"] = vehicle.get_vehicle_wheel_brake_pressure(Entity, i),
				["TractionVectorLength"] = vehicle.get_vehicle_wheel_traction_vector_length(Entity, i),
				["xOffset"] = vehicle.get_vehicle_wheel_x_offset(Entity, i),
				["yRotation"] = vehicle.get_vehicle_wheel_y_rotation(Entity, i),
				["Flags"] = vehicle.get_vehicle_wheel_flags(Entity, i)
			}
		end
		if info["VehicleProperties"]["Colours"]["IsPrimaryColourCustom"] then
			info["VehicleProperties"]["Colours"]["Primary"] = vehicle.get_vehicle_custom_primary_colour(Entity)
			info["VehicleProperties"]["Colours"]["Pearl"] = vehicle.get_vehicle_custom_pearlescent_colour(Entity)
		end
		if info["VehicleProperties"]["Colours"]["IsSecondaryColourCustom"] then
			info["VehicleProperties"]["Colours"]["Secondary"] = vehicle.get_vehicle_custom_secondary_colour(Entity)
		end
		for i = 0, 48 do
			if i >= 17 and i <= 22 then
				info["VehicleProperties"]["Mods"]["_"..i] = vehicle.is_toggle_mod_on(Entity, i)
			else
				info["VehicleProperties"]["Mods"]["_"..i] = vehicle.get_vehicle_mod(Entity, i)..",0"
			end
		end
	end
	return info
end

function vehicle_saver.save_vehicle(...)
	local Entity, file_path <const> = ...
	Entity = kek_entity.get_parent_of_attachment(Entity)
	local attachments <const> = kek_entity.get_all_attached_entities(Entity)
	local clear_tasks
	if #attachments > 0 then
		clear_tasks = player.is_player_in_any_vehicle(player.player_id())
		if clear_tasks then
			ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
		end
		entity.freeze_entity(Entity, true)
		system.yield(0)
		entity.set_entity_rotation(Entity, v3())
		system.yield(0)
	end
	local file <close> = io.open(file_path, "w+")
	essentials.file(file, "write", "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n")
	essentials.file(file, "write", "<Vehicle menyoo_ver=\"0.9998b\">\n")
	essentials.write_xml(file, get_properties(Entity, true), "	")
	if #attachments > 0 then
		essentials.file(file, "write", "	<SpoonerAttachments SetAttachmentsPersistentAndAddToSpoonerDatabase=\"false\">\n")
		for i = 1, #attachments do
			essentials.write_xml(file, {["Attachment"] = get_properties(attachments[i])}, "		")
		end
		essentials.file(file, "write", "	</SpoonerAttachments>\n")
	end
	essentials.file(file, "write", "</Vehicle>\n")
	essentials.file(file, "flush")
	entity.freeze_entity(Entity, false)
	if clear_tasks and #attachments > 0 then
		ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Entity, -1)
	end
end

return vehicle_saver