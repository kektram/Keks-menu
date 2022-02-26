-- Copyright © 2020-2022 Kektram

local essentials <const> = require("Essentials")
local kek_entity <const> = require("Kek's entity functions")
local enums <const> = require("Enums")
local memoize <const> = require("Memoize")
local settings <const> = require("settings")
local language <const> = require("Language")
local lang <const> = language.lang

local menyoo_saver <const> = {version = "1.0.8"}

local function get_properties(...)
	local Entity <const>, initial <const> = ...
	local info <const> = {
		ModelHash = entity.get_entity_model_hash(Entity),
		InitialHandle = Entity,
		IsOnFire = entity.is_entity_on_fire(Entity),
		IsVisible = entity.is_entity_visible(Entity),
		IsInvincible = entity.get_entity_god_mode(Entity),
		OpacityLevel = 255,
		LodDistance = 20000,
		Dynamic = true,
		FrozenPos = false
	}
	if entity.is_entity_a_ped(Entity) then
		info.IsCollisionProof = entity.has_entity_collided_with_anything(Entity)
		info.Type = 1
		info.MaxHealth = ped.get_ped_max_health(Entity)
		info.Health = ped.get_ped_health(Entity)
	elseif entity.is_entity_a_vehicle(Entity) then
		info.IsCollisionProof = initial
		info.Type = 2
	else
		info.IsCollisionProof = entity.has_entity_collided_with_anything(Entity)
		info.Type = 3
	end
	if not initial then
		local is_attached_str <const> = string.format("Attachment isAttached=\"%s\"", entity.is_entity_attached(Entity))
		if entity.is_entity_attached(Entity) then
			info[is_attached_str] = {
				AttachedTo = entity.get_entity_attached_to(Entity),
				BoneIndex = 0,
				Pitch = entity.get_entity_pitch(Entity),
				Roll = entity.get_entity_roll(Entity),
				Yaw = entity.get_entity_rotation(Entity).z,
				X = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(Entity), Entity)).x,
				Y = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(Entity), Entity)).y,
				Z = select(2, entity.get_entity_offset_from_entity(entity.get_entity_attached_to(Entity), Entity)).z
			}
		else
			info[is_attached_str] = essentials.const({})
		end
		local pos <const> = entity.get_entity_coords(Entity)
		info.PositionRotation = {
			X = pos.x,
			Y = pos.y,
			Z = pos.z,
			Pitch = entity.get_entity_pitch(Entity),
			Roll = entity.get_entity_roll(Entity),
			Yaw = entity.get_entity_rotation(Entity).z
		}
	end
	if entity.is_entity_a_ped(Entity) then
		info.PedProperties = {
			CanRagdoll = ped.can_ped_ragdoll(Entity),
			PedProps = {},
			PedComps = {},
			BlendData = ped.get_ped_head_blend_data(Entity),
			FacialFeatures = {},
			PedVehicleSeat = kek_entity.get_seat_ped_is_in(ped.get_vehicle_ped_is_using(Entity), Entity),
			RelationshipGroup = ped.get_ped_relationship_group_hash(Entity),
			RelationshipGroupAltered = true,
			HairColor = ped.get_ped_hair_color(Entity),
			HairHighlightColor = ped.get_ped_hair_highlight_color(Entity),
			EyeColor = ped.get_ped_eye_color(Entity)
		}
		for i = 0, 19 do
			info.PedProperties.FacialFeatures["_"..i] = ped.get_ped_face_feature(Entity, i)
		end
		for i = 0, 9 do
			info.PedProperties.PedProps["_"..i] = string.format("%i,%i", ped.get_ped_prop_index(Entity, i), ped.get_ped_prop_texture_index(Entity, i))
		end
		for i = 0, 11 do
			info.PedProperties.PedComps["_"..i] = string.format("%i,%i", ped.get_ped_texture_variation(Entity, i), ped.get_ped_drawable_variation(Entity, i))
		end
	elseif entity.is_entity_a_vehicle(Entity) then
		local Cust1_R <const>, Cust1_G <const>, Cust1_B <const> = essentials.rgb_to_bytes(vehicle.get_vehicle_custom_primary_colour(Entity))
		local Cust2_R <const>, Cust2_G <const>, Cust2_B <const> = essentials.rgb_to_bytes(vehicle.get_vehicle_custom_secondary_colour(Entity))
		local neon_r <const>, neon_g <const>, neon_b <const> = essentials.rgb_to_bytes(vehicle.get_vehicle_neon_lights_color(Entity))
		info.VehicleProperties = {
			Colours = {
				tyreSmoke_R = math.random(0, 255), 
				tyreSmoke_G = math.random(0, 255), -- No function to get these values 
				tyreSmoke_B = math.random(0, 255),
				Primary = vehicle.get_vehicle_primary_color(Entity),
				Secondary = vehicle.get_vehicle_secondary_color(Entity),
				Pearl = vehicle.get_vehicle_pearlecent_color(Entity),
				Rim = vehicle.get_vehicle_wheel_color(Entity),
				IsPrimaryColourCustom = vehicle.is_vehicle_primary_colour_custom(Entity),
				IsSecondaryColourCustom = vehicle.is_vehicle_secondary_colour_custom(Entity),
				IsPearlColourCustom = vehicle.is_vehicle_primary_colour_custom(Entity) or vehicle.is_vehicle_secondary_colour_custom(Entity),
				Cust1_R = Cust1_R, 
				Cust1_G = Cust1_G, 
				Cust1_B = Cust1_B,
				Cust2_R = Cust2_R, 
				Cust2_G = Cust2_G, 
				Cust2_B = Cust2_B,
				PearlCustom = vehicle.get_vehicle_custom_pearlescent_colour(Entity),
				LrXenonHeadlights = vehicle.get_vehicle_headlight_color(Entity)
			},
			Livery = vehicle.get_vehicle_livery(Entity),
			RpmMultiplier = 1,
			TorqueMultiplier = 1,
			WheelsRenderSize = vehicle.get_vehicle_wheel_render_size(Entity),
			WheelsRenderWidth = vehicle.get_vehicle_wheel_render_width(Entity),
			LandingGearState = vehicle.get_landing_gear_state(Entity),
			ReducedGrip = vehicle.get_vehicle_reduce_grip(Entity),
			MaxGear = vehicle.get_vehicle_max_gear(Entity),
			CurrentGear = vehicle.get_vehicle_current_gear(Entity),
			WheelsCount = vehicle.get_vehicle_wheel_count(Entity),
			WheelType = kek_entity.get_wheel_type(Entity),
			NumberPlateText = settings.in_use["Plate vehicle text"],
			NumberPlateIndex = math.random(0, 3),
			WindowTint = vehicle.get_vehicle_window_tint(Entity),
			Neons = essentials.const({
				R = neon_r,
				G = neon_g,
				B = neon_b,
				Left = vehicle.is_vehicle_neon_light_enabled(Entity, 0, true),
				Right = vehicle.is_vehicle_neon_light_enabled(Entity, 1, true),
				Front = vehicle.is_vehicle_neon_light_enabled(Entity, 2, true),
				Back = vehicle.is_vehicle_neon_light_enabled(Entity, 3, true)
			}),
			Mods = {}
		}
		for i = 0, vehicle.get_vehicle_wheel_count(Entity) - 1 do
			info.VehicleProperties["Wheel_"..i] = essentials.const({
				TireRadius = vehicle.get_vehicle_wheel_tire_radius(Entity, i),
				RimRadius = vehicle.get_vehicle_wheel_rim_radius(Entity, i),
				TireWidth = vehicle.get_vehicle_wheel_tire_width(Entity, i),
				RotationSpeed = vehicle.get_vehicle_wheel_rotation_speed(Entity, i),
				Power = vehicle.get_vehicle_wheel_power(Entity, i),
				Health = vehicle.get_vehicle_wheel_health(Entity, i),
				BrakePressure = vehicle.get_vehicle_wheel_brake_pressure(Entity, i),
				TractionVectorLength = vehicle.get_vehicle_wheel_traction_vector_length(Entity, i),
				xOffset = vehicle.get_vehicle_wheel_x_offset(Entity, i),
				yRotation = vehicle.get_vehicle_wheel_y_rotation(Entity, i),
				Flags = vehicle.get_vehicle_wheel_flags(Entity, i)
			})
		end
		if info.VehicleProperties.Colours.IsPrimaryColourCustom then
			info.VehicleProperties.Colours.Primary = vehicle.get_vehicle_custom_primary_colour(Entity)
		end
		if info.VehicleProperties.Colours.IsSecondaryColourCustom then
			info.VehicleProperties.Colours.Secondary = vehicle.get_vehicle_custom_secondary_colour(Entity)
		end
		for i = 0, 75 do
			if i >= 17 and i <= 22 then
				info.VehicleProperties.Mods["_"..i] = vehicle.is_toggle_mod_on(Entity, i)
			else
				info.VehicleProperties.Mods["_"..i] = vehicle.get_vehicle_mod(Entity, i)..",0"
			end
		end
	end
	return info
end

function menyoo_saver.save_vehicle(...)
	local Vehicle, file_path <const> = ...
	essentials.assert(not utils.file_exists(file_path), "Tried to overwrite a file without intent to do so.", file_path)
	if entity.is_an_entity(Vehicle) then
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle from argument \"Vehicle\".")
		Vehicle = kek_entity.get_parent_of_attachment(Vehicle)
		local attachments <const> = kek_entity.get_all_attached_entities(Vehicle)
		local clear_tasks
		if #attachments > 0 then
			clear_tasks = player.is_player_in_any_vehicle(player.player_id())
			if clear_tasks then
				ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
			end
			entity.freeze_entity(Vehicle, true)
			system.yield(0)
			entity.set_entity_rotation(Vehicle, memoize.v3())
			system.yield(0)
		end
		local file <close> = io.open(file_path, "w+")
		local str <const> = {
			"<?xml version=\"1.0\" encoding=\"UTF-8\" kek_menu_version=\""..__kek_menu_version.."\"?>",
			"<Vehicle menyoo_ver=\"0.9998b\">",
			essentials.table_to_xml(get_properties(Vehicle, true), 1, nil, {}, true)
		}
		if #attachments > 0 then
			local is_attached_str <const> = string.format("Attachment isAttached=\"%s\"", true)
			str[#str + 1] = "\9<SpoonerAttachments SetAttachmentsPersistentAndAddToSpoonerDatabase=\"false\">"
			for Entity in essentials.entities(attachments) do
				local info <const> = {Attachment = get_properties(Entity)}
				str[#str + 1] = essentials.table_to_xml(info, 2, nil, {}, true)
			end
			str[#str + 1] = "\9</SpoonerAttachments>"
		end
		str[#str + 1] = "</Vehicle>"
		str[#str + 1] = ""
		file:write(table.concat(str, "\n"))
		file:flush()
		entity.freeze_entity(Vehicle, false)
		rope.activate_physics(Vehicle)
		if entity.is_entity_a_vehicle(Vehicle) and clear_tasks and #attachments > 0 then
			ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Vehicle, -1)
		end
	end
end

function menyoo_saver.save_map(...)
	local file_path <const> = ...
	essentials.assert(not utils.file_exists(file_path), "Tried to overwrite a file without intent to do so.", file_path)
	local file <close> = io.open(file_path, "w+")
	local ref <const> = player.get_player_coords(player.player_id())
	local xml_string <const> = {
		"<?xml version=\"1.0\" encoding=\"UTF-8\" kek_menu_version=\""..__kek_menu_version.."\"?>",
		"<SpoonerPlacements>",
		essentials.table_to_xml({
			ReferenceCoords = essentials.const({
				X = ref.x,
				Y = ref.y,
				Z = ref.z
			})
		}, 1, nil, {}, true)
	}
	local is_attached_str <const> = string.format("Attachment isAttached=\"%s\"", true)
	for _, entities in pairs({
		ped.get_all_peds(),
		vehicle.get_all_vehicles(),
		object.get_all_objects()
	}) do
		for Entity in essentials.entities(entities) do
			if entity.is_entity_visible(Entity) 
			and not entity.is_entity_attached(Entity)
			and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
				local info <const> = {Placement = get_properties(Entity)}
				info.Placement.FrozenPos = entity.is_entity_an_object(Entity)
				xml_string[#xml_string + 1] = essentials.table_to_xml(info, 1, nil, {}, true)
				local attached_entities <const> = kek_entity.get_all_attached_entities(Entity)
				for attachment in essentials.entities(attached_entities) do
					if entity.is_entity_visible(attachment) then
						local info2 <const> = info
						local info <const> = {Placement = get_properties(attachment)}
						info.Placement[is_attached_str].Pitch = info.Placement[is_attached_str].Pitch - info2.Placement.PositionRotation.Pitch
						info.Placement[is_attached_str].Roll = info.Placement[is_attached_str].Roll - info2.Placement.PositionRotation.Roll
						info.Placement[is_attached_str].Yaw = info.Placement[is_attached_str].Yaw - info2.Placement.PositionRotation.Yaw
						xml_string[#xml_string + 1] = essentials.table_to_xml(info, 1, nil, {}, true)
					end
				end
			end
		end
	end
	xml_string[#xml_string + 1] = "</SpoonerPlacements>"
	xml_string[#xml_string + 1] = ""
	file:write(table.concat(xml_string, "\n"))
	file:flush()
	essentials.msg(lang["Saved map."], "green", true, 6)
end

return essentials.const_all(menyoo_saver)