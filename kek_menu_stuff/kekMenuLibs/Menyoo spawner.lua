-- Copyright © 2020-2021 Kektram

local menyoo <const> = {version = "2.1.1"}

local language <const> = require("Language")
local lang <const> = language.lang
local essentials <const> = require("Essentials")
local kek_entity <const> = require("Kek's entity functions")
local custom_upgrades <const> = require("Custom upgrades")
local location_mapper <const> = require("Location mapper")
local weapon_mapper <const> = require("Weapon mapper")
local menyoo_saver <const> = require("Menyoo saver")
local enums <const> = require("Enums")
local settings <const> = require("Settings")
local memoize <const> = require("Memoize")

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"

local function new_attachment_check(...)
	local str <const>,
	End <const>,
	initial <const>,
	xml_start <const>,
	xml_end <const> = ...
	if not str then
		return true
	end
	if initial then
		return str:find(initial, 1, true) ~= nil
	elseif End then
		for i = 1, #xml_end do
			if str:find(xml_end[i]) then
				return true
			end
		end
	else
		for i = 1, #xml_start do
			if str:find(xml_start[i]) then
				return true
			end
		end
	end
	return false
end

local function extract_info(...)
	local file <const>, 
	initial <const>,
	xml_start <const>,
	xml_end <const> = ...
	local str = ""
	local info <const> = {}
	local tree_parent = ""
	while str and not new_attachment_check(str, true, initial, xml_start, xml_end) do
		if str:find("<Attachment%s*isAttached=[%w%p]+/*>") then
			info[str:match("%s*([%w%p]+)=")] = str:match("<Attachment%s*isAttached=(.+)/*>") == "\"true\""
		else
			local property <const> = str:match("<.+>(.*)<.+>")
			if property and not new_attachment_check(str, true, initial, xml_start, xml_end) then
				local str_casted_to_right_type = property
				if str_casted_to_right_type == "false" then
					str_casted_to_right_type = false
				elseif str_casted_to_right_type == "true" then
					str_casted_to_right_type = true
				elseif tonumber(str_casted_to_right_type) then
					str_casted_to_right_type = tonumber(str_casted_to_right_type)
				elseif str_casted_to_right_type:find("[%d%-]+,%s*[%d%-]+") then
					str_casted_to_right_type = {tonumber(str_casted_to_right_type:match("([%d%-]+),%s*[%d%-]+")), tonumber(str_casted_to_right_type:match("[%d%-]+,%s*([%d%-]+)"))}
				end
				info[tree_parent..str:match("^%s*<(.+)>.*<.+>%s*$")] = str_casted_to_right_type
			end
			if not str:find("=", 1, true)
			and not str:find("^%s*<(.+)>.*<.+>%s*$") 
			and str:find("^%s*<([%p%w%c]+)>%s*$")  
			and not new_attachment_check(str, true, initial, xml_start, xml_end) then
				tree_parent = str:match("^%s*<([%p%w%c]+)>%s*$")
			end
			if str:find("^%s*</(.+)>%s*$") then
				tree_parent = ""
			end
		end
		str = file:read("*l")
	end
	return info
end

local function apply_vehicle_modifications(...)
	local Entity <const>, info <const> = ...
	vehicle.set_vehicle_mod_kit_type(Entity, 0)
	for i = 0, 48 do
		local setting <const> = info["Mods_"..i]
		if type(setting) == "table" then
			vehicle.set_vehicle_mod(Entity, setting[1], i, i == 23 or i == 24)
		elseif type(setting) == "boolean" then
			vehicle.toggle_vehicle_mod(Entity, i, setting)
		end
	end
	if type(info.TorqueMultiplier) == "number" and info.TorqueMultiplier ~= 1 then
		custom_upgrades.torque_modifier(Entity, info.TorqueMultiplier)
	end
	if type(info.RpmMultiplier) == "number" and info.RpmMultiplier ~= 1 then
		vehicle.modify_vehicle_top_speed(Entity, info.RpmMultiplier * 100)
		entity.set_entity_max_speed(Entity, 540 * info.RpmMultiplier)
	end
	if math.type(info.ColoursPearl) == "integer" and math.type(info.ColoursRim) == "integer" then
		vehicle.set_vehicle_extra_colors(Entity, info.ColoursPearl, info.ColoursRim)
	end
	if math.type(info.ColoursPrimary) == "integer" and math.type(info.ColoursSecondary) == "integer" then
		vehicle.set_vehicle_colors(Entity, info.ColoursPrimary, info.ColoursSecondary)
		if info.ColoursIsPrimaryColourCustom then
			vehicle.set_vehicle_custom_primary_colour(Entity, info.ColoursPrimary)
			vehicle.set_vehicle_custom_pearlescent_colour(Entity, info.ColoursPearl)
		end
		if info.ColoursIsSecondaryColourCustom then
			vehicle.set_vehicle_custom_secondary_colour(Entity, info.ColoursSecondary)
		end
	end
	if math.type(info.ColourstyreSmoke_R) == "integer" 
	and math.type(info.ColourstyreSmoke_G) == "integer" 
	and math.type(info.ColourstyreSmoke_B) == "integer" then
		vehicle.set_vehicle_tire_smoke_color(Entity, info.ColourstyreSmoke_R, info.ColourstyreSmoke_G, info.ColourstyreSmoke_B)
	end
	if type(info.NumberPlateText) == "string" then
		vehicle.set_vehicle_number_plate_text(Entity, info.NumberPlateText)
	end
	if math.type(info.NumberPlateIndex) == "integer" then
		vehicle.set_vehicle_number_plate_index(Entity, info.NumberPlateIndex)
	end
	if math.type(info.WheelType) == "integer" then
		vehicle.set_vehicle_wheel_type(Entity, info.WheelType)
	end
	if math.type(info.WindowTint) == "integer" then
		vehicle.set_vehicle_window_tint(Entity, info.WindowTint)
	end
	vehicle.set_vehicle_bulletproof_tires(Entity, info.BulletProofTyres == true)
	vehicle.set_vehicle_engine_on(Entity, info.EngineOn == true, true, false)
	if type(info.EngineHealth) == "number" then
		vehicle.set_vehicle_engine_health(Entity, info.EngineHealth)
	end
	vehicle.set_vehicle_neon_light_enabled(Entity, 0, info.NeonsLeft == true)
	vehicle.set_vehicle_neon_light_enabled(Entity, 1, info.NeonsRight == true)
	vehicle.set_vehicle_neon_light_enabled(Entity, 2, info.NeonsFront == true)
	vehicle.set_vehicle_neon_light_enabled(Entity, 3, info.NeonsBack == true)
	if math.type(info.NeonsR) == "integer" 
	and math.type(info.NeonsG) == "integer" 
	and math.type(info.NeonsB) == "integer" then
		vehicle.set_vehicle_neon_lights_color(Entity, info.NeonsR * info.NeonsG * info.NeonsB)
	end
	if math.type(info.Livery) == "integer" and info.Livery ~= -1 then
		vehicle.set_vehicle_livery(Entity, info.Livery)
	end
	if type(info.DoorsOpenFrontLeftDoor) == true then
		vehicle.set_vehicle_door_open(Entity, 0, info.DoorsOpenFrontLeftDoor, info.DoorsOpenFrontLeftDoor)
	end
	if type(info.DoorsOpenFrontRightDoor) == true then
		vehicle.set_vehicle_door_open(Entity, 1, info.DoorsOpenFrontRightDoor, info.DoorsOpenFrontRightDoor)
	end
	if type(info.DoorsOpenBackLeftDoor) == true then
		vehicle.set_vehicle_door_open(Entity, 2, info.DoorsOpenBackLeftDoor, info.DoorsOpenBackLeftDoor)
	end
	if type(info.DoorsOpenBackRightDoor) == true then
		vehicle.set_vehicle_door_open(Entity, 3, info.DoorsOpenBackRightDoor, info.DoorsOpenBackRightDoor)
	end
	if type(info.DoorsOpenHood) == true then
		vehicle.set_vehicle_door_open(Entity, 4, info.DoorsOpenHood, info.DoorsOpenHood)
	end
	if type(info.DoorsOpenTrunk) == true then
		vehicle.set_vehicle_door_open(Entity, 5, info.DoorsOpenTrunk, info.DoorsOpenTrunk)
	end
	if type(info.DoorsOpenTrunk2) == true then
		vehicle.set_vehicle_door_open(Entity, 6, info.DoorsOpenTrunk2, info.DoorsOpenTrunk2)
	end
	if info.TyresBurstedFrontLeft == true then
		vehicle.set_vehicle_tire_burst(Entity, 0, true, 1000)
	end
	if info.TyresBurstedFrontRight == true then
		vehicle.set_vehicle_tire_burst(Entity, 1, true, 1000)
	end
	if info.TyresBursted_2 == true then
		vehicle.set_vehicle_tire_burst(Entity, 2, true, 1000)
	end
	if info.TyresBursted_3 == true then
		vehicle.set_vehicle_tire_burst(Entity, 3, true, 1000)
	end
	if info.TyresBurstedBackLeft == true then
		vehicle.set_vehicle_tire_burst(Entity, 4, true, 1000)
	end
	if info.TyresBurstedBackRight == true then
		vehicle.set_vehicle_tire_burst(Entity, 5, true, 1000)
	end
	if info.TyresBursted_6 == true then
		vehicle.set_vehicle_tire_burst(Entity, 45, true, 1000)
	end
	if info.TyresBursted_7 == true then
		vehicle.set_vehicle_tire_burst(Entity, 47, true, 1000)
	end
	if info.TyresBursted_8 == true then
		vehicle.set_vehicle_tire_burst(Entity, 8, true, 1000)
	end
	if type(info.WheelsRenderSize) == "number" then
		vehicle.set_vehicle_wheel_render_size(Entity, info.WheelsRenderSize)
	end
	if type(info.WheelsRenderWidth) == "number" then
		vehicle.set_vehicle_wheel_render_width(Entity, info.WheelsRenderWidth)
	end
	if math.type(info.LandingGearState) == "integer" then
		vehicle.control_landing_gear(Entity, info.LandingGearState)
	end
	if info.ReducedGrip == true then
		vehicle.set_vehicle_reduce_grip(Entity, true)
	end
	if math.type(info.MaxGear) == "integer" then
		vehicle.set_vehicle_max_gear(Entity, info.MaxGear)
	end
	if math.type(info.CurrentGear) == "integer" then
		vehicle.set_vehicle_current_gear(Entity, info.CurrentGear)
	end
	if math.type(info.WheelsCount) == "integer" then
		for i = 0, info.WheelsCount - 1 do
			if type(info["Wheel_"..i.."TireRadius"]) == "number" then
				vehicle.set_vehicle_wheel_tire_radius(Entity, i, info["Wheel_"..i.."TireRadius"])
			end
			if type(info["Wheel_"..i.."RimRadius"]) == "number" then
				vehicle.set_vehicle_wheel_rim_radius(Entity, i, info["Wheel_"..i.."RimRadius"])
			end
			if type(info["Wheel_"..i.."TireWidth"]) == "number" then
				vehicle.set_vehicle_wheel_tire_width(Entity, i, info["Wheel_"..i.."TireWidth"])
			end
			if type(info["Wheel_"..i.."RotationSpeed"]) == "number" then
				vehicle.set_vehicle_wheel_rotation_speed(Entity, i, info["Wheel_"..i.."RotationSpeed"])
			end
			if type(info["Wheel_"..i.."Power"]) == "number" then
				vehicle.set_vehicle_wheel_power(Entity, i, info["Wheel_"..i.."Power"])
				if info["Wheel_"..i.."Power"] > 0 then
					vehicle.set_vehicle_wheel_is_powered(Entity, i, true)
				end
			end
			if type(info["Wheel_"..i.."Health"]) == "number" then
				vehicle.set_vehicle_wheel_health(Entity, i, info["Wheel_"..i.."Health"])
			end
			if type(info["Wheel_"..i.."BrakePressure"]) == "number" then
				vehicle.set_vehicle_wheel_brake_pressure(Entity, i, info["Wheel_"..i.."BrakePressure"])
			end
			if type(info["Wheel_"..i.."TractionVectorLength"]) == "number" then
				vehicle.set_vehicle_wheel_traction_vector_length(Entity, i, info["Wheel_"..i.."TractionVectorLength"])
			end
			if type(info["Wheel_"..i.."xOffset"]) == "number" then
				vehicle.set_vehicle_wheel_x_offset(Entity, i, info["Wheel_"..i.."xOffset"])
			end
			if type(info["Wheel_"..i.."yRotation"]) == "number" then
				vehicle.set_vehicle_wheel_y_rotation(Entity, i, info["Wheel_"..i.."yRotation"])
			end
			if math.type(info["Wheel_"..i.."Flags"]) == "integer" then
				vehicle.set_vehicle_wheel_flags(Entity, i, info["Wheel_"..i.."Flags"])
			end
		end
	end
end

local function apply_ped_modifications(...)
	local Entity <const>, info <const>, entities <const> = ...
	if info.IsStill == true then
		ped.set_ped_config_flag(Entity, enums.ped_config_flags.DisablePedConstraints, 1)
	end
	if info.CanRagdoll == true then
		ped.set_ped_config_flag(Entity, enums.ped_config_flags.cantRagdoll, 0)
	end
	if math.type(info.CurrentWeapon) == "integer" and info.CurrentWeapon ~= gameplay.get_hash_key("weapon_unarmed") then
		weapon.give_delayed_weapon_to_ped(Entity, info.CurrentWeapon, 0, 1)
		weapon_mapper.set_ped_weapon_attachments(Entity, true, info.CurrentWeapon)
		kek_entity.set_combat_attributes(Entity, true, {})
	end
	for i = 0, 9 do
		if type(info["PedProps_"..i]) == "table" then
			ped.set_ped_prop_index(Entity, info["PedProps_"..i][1], 1, info["PedProps_"..i][2], 0)
		end
	end
	for i = 0, 11 do
		if type(info["PedComps_"..i]) == "table" then
			ped.set_ped_component_variation(Entity, info["PedComps_"..i][1], 1, info["PedComps_"..i][2], 1)
		end
	end
	if math.type(info.HairColor) == "integer" and math.type(info.HairHighlightColor) == "integer" then
		ped.set_ped_hair_colors(Entity, info.HairColor, info.HairHighlightColor)
	end
	if math.type(info.EyeColor) == "integer" then
		ped.set_ped_eye_color(Entity, info.EyeColor)
	end
	if math.type(info.BlendDatashape_first) == "integer"
	and math.type(info.BlendDatashape_second) == "integer"
	and math.type(info.BlendDatashape_third) == "integer"
	and math.type(info.BlendDataskin_first) == "integer"
	and math.type(info.BlendDataskin_second) == "integer"
	and math.type(info.BlendDataskin_third) == "integer"
	and type(info.BlendDatamix_shape) == "number"
	and type(info.BlendDatamix_skin) == "number"
	and type(info.BlendDatamix_third) == "number" then
		ped.set_ped_head_blend_data(Entity, 
			info.BlendDatashape_first, 
			info.BlendDatashape_second,
			info.BlendDatashape_third,
			info.BlendDataskin_first,
			info.BlendDataskin_second,
			info.BlendDataskin_third,
			info.BlendDatamix_shape,
			info.BlendDatamix_skin,
			info.BlendDatamix_third
		)
	end
	for i = 0, 11 do
		if type(info["HeadOverlay_"..i.."Value"]) == "number" and type(info["HeadOverlay_"..i.."Opacity"]) == "number" then
			ped.set_ped_head_overlay(Entity, i, info["HeadOverlay_"..i.."Value"], info["HeadOverlay_"..i.."Opacity"])
		end
		if math.type(info["HeadOverlay_"..i.."ColorType"]) == "integer" 
		and math.type(info["HeadOverlay_"..i.."Color"]) == "integer" 
		and math.type(info["HeadOverlay_"..i.."highlightColor"]) == "integer" then
			ped.set_ped_head_overlay_color(Entity, i, info["HeadOverlay_"..i.."ColorType"], info["HeadOverlay_"..i.."Color"], info["HeadOverlay_"..i.."highlightColor"])
		end
	end
	for i = 0, 19 do
		if math.type(info["FacialFeatures"..i]) == "integer" then
			ped.set_ped_face_feature(Entity, i, info["FacialFeatures"..i])
		end
	end
	if type(info.RelationshipGroupAltered) == true and math.type(info.RelationshipGroup) == "integer" then
		ped.set_ped_relationship_group_hash(Entity, info.RelationshipGroup)
	end
	if type(info.MaxHealth) == "number" then
		ped.set_ped_max_health(Entity, info.MaxHealth)
	end
	if type(info.Health) == "number" then
		ped.set_ped_health(Entity, info.Health)
	end
	if math.type(info.PedVehicleSeat) == "integer"
	and info.PedVehicleSeat ~= -2
	and math.type(entities[info.AttachedTo]) == "integer" 
	and entity.is_entity_a_ped(entities[info.AttachedTo]) then
		ped.set_ped_into_vehicle(Entity, entities[info.AttachedTo], info.PedVehicleSeat)
		if info.Seat == -1 then
			ai.task_vehicle_drive_wander(Entity, entities[info.AttachedTo], 150, settings.in_use["Drive style"])
		end
	end
	if info.ScenarioActive == true and type(info.ScenarioName) == "string" then
		ai.task_start_scenario_in_place(Entity, info.ScenarioName, 0, true)
	end
	if info.AnimActive == true and type(info.AnimDict) == "string" and type(info.AnimName) == "string" and essentials.request_anim_dict(info.AnimDict) then
		ai.task_play_anim(Entity, info.AnimDict, info.AnimName, 8.0, 1.0, -1, 1, 1.0, false, false, false)
		streaming.remove_anim_dict(info.AnimDict)
	end
	if info.MovementGroupName and type(info.MovementGroupName) == "string" and essentials.request_anim_set(info.MovementGroupName) then
		ped.set_ped_movement_clipset(Entity, info.MovementGroupName)
		streaming.remove_anim_set(info.MovementGroupName)
	end
end

local function apply_entity_modifications(...)
	local Entity <const>,
	info <const>, 
	entities <const>,
	pid <const> = ...
	if entity.is_an_entity(Entity or 0) then
		if entity.is_entity_a_vehicle(Entity) then
			apply_vehicle_modifications(Entity, info)
		elseif entity.is_entity_a_ped(Entity) then
			apply_ped_modifications(Entity, info, entities)
		elseif pid == player.player_id() 
			and entity.get_entity_model_hash(Entity) == gameplay.get_hash_key("p_rcss_folded") -- Is object turret? 
			and info.isAttached 
			and entities[info.AttachedTo] then
				local offset = v3()
			if type(info.X) == "number" then
				offset.x = info.X
			end
			if type(info.Y) == "number" then
				offset.y = info.Y
			end
			if type(info.Z) == "number" then
				offset.z = info.Z
			end
			custom_upgrades.vehicle_turret(entities[info.AttachedTo], Entity, offset)
		end
		if type(info.OpacityLevel) == "number" then
			entity.set_entity_alpha(Entity, info.OpacityLevel, 1)
		end
		if info.IsVisible == false then
			entity.set_entity_visible(Entity, false)
		end
		if info.HasGravity == false then
			entity.set_entity_gravity(Entity, false)
		end
		if info.IsOnFire then
			fire.start_entity_fire(Entity)
		end
		entity.set_entity_god_mode(Entity, info.IsInvincible == true)
		entity.freeze_entity(Entity, info.FrozenPos == true)
	end
end

local function update_spawn_counter(entities, hash, Entity)
	if streaming.is_model_an_object(hash) then
		if entity.is_entity_an_object(Entity) then
			entities.objects.successful_spawns = entities.objects.successful_spawns + 1
		else
			entities.objects.failed_spawns = entities.objects.failed_spawns + 1
		end
	elseif streaming.is_model_a_ped(hash) then
		if entity.is_entity_a_ped(Entity) then
			entities.peds.successful_spawns = entities.peds.successful_spawns + 1
		else
			entities.peds.failed_spawns = entities.peds.failed_spawns + 1
		end
	elseif streaming.is_model_a_vehicle(hash) then
		if entity.is_entity_a_vehicle(Entity) then
			entities.vehicles.successful_spawns = entities.vehicles.successful_spawns + 1
		else
			entities.vehicles.failed_spawns = entities.vehicles.failed_spawns + 1
		end
	else
		entities.invalid = entities.invalid + 1
	end
end

local function send_spawn_counter_msg(entities)
	essentials.msg(string.format("%s:\n%i/%i %s\n%i/%i %s\n%i/%i %s\n%i %s", 
		lang["Spawned"], 
		entities.peds.successful_spawns,
		entities.peds.successful_spawns + entities.peds.failed_spawns,
		lang["Peds"]:lower(),
		entities.vehicles.successful_spawns,
		entities.vehicles.successful_spawns + entities.vehicles.failed_spawns,
		lang["Vehicles"]:lower(),
		entities.objects.successful_spawns,
		entities.objects.successful_spawns + entities.objects.failed_spawns,
		lang["Objects"]:lower(),
		entities.invalid,
		lang["invalid models"]),
		"green", 
		true,
		6
	)
end

local function spawn_entity(info, entities, is_not_networked)
	if not streaming.is_model_valid(info.ModelHash) then
		update_spawn_counter(entities, 0, 0)
		return 0
	end
	local Entity
	if streaming.is_model_an_object(info.ModelHash) then
		Entity = kek_entity.spawn_object(info.ModelHash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, -50)
		end, true, info.Dynamic == false, is_not_networked, 6)
	else
		Entity = kek_entity.spawn_ped_or_vehicle(info.ModelHash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, -50), 0
		end, false, false, enums.ped_types.civmale, true, 6, is_not_networked)
	end
	update_spawn_counter(entities, info.ModelHash, Entity)
	return Entity
end

local function clear_entities(entities)
	local buf <const> = {}
	for _, Entity in pairs(entities) do
		if math.type(Entity) == "integer" then
			buf[1] = Entity
			kek_entity.clear_entities(buf)
		end
	end
end

local function clear_hash_cache(hash_cache)
	for _, hash in pairs(hash_cache) do
		streaming.set_model_as_no_longer_needed(hash)
	end
end

local function update_xml_string(xml_start, xml_end, tabs)
	xml_start[1] = string.format("^%s<Attachment>$", tabs)
	xml_start[2] = string.format("^%s<Placement>$", tabs)
	xml_end[1] = string.format("^%s</Attachment>$", tabs)
	xml_end[2] = string.format("^%s</Placement>$", tabs)
end

local function get_info_containers()
	return
		{ -- xml_start
			"^%s*<Attachment>$",
			"^%s*<Placement>$"
		},
		{ -- xml_end
			"^%s*</Attachment>$",
			"^%s*</Placement>$"
		},
		{ -- entities
			peds = {
				failed_spawns = 0, 
				successful_spawns = 0
			},
			vehicles = {
				failed_spawns = 0, 
				successful_spawns = 0
			},
			objects = {
				failed_spawns = 0, 
				successful_spawns = 0
			},
			invalid = 0
		}
end

local function check_entity_limits(entities, hash_cache)
	if streaming.is_model_a_ped(hash_cache[#hash_cache]) and kek_entity.entity_manager.counts.ped >= settings.valuei["Ped limit"].value then
		clear_entities(entities)
		clear_hash_cache(hash_cache)
		essentials.msg(lang["Reached ped spawn limit. Cancelling menyoo spawn."], "red", true, 6)
		return true
	end
	if streaming.is_model_a_vehicle(hash_cache[#hash_cache]) and kek_entity.entity_manager.counts.vehicle >= settings.valuei["Vehicle limit"].value then
		clear_entities(entities)
		clear_hash_cache(hash_cache)
		essentials.msg(lang["Reached vehicle spawn limit. Cancelling menyoo spawn."], "red", true, 6)
		return true
	end
	if streaming.is_model_an_object(hash_cache[#hash_cache]) and kek_entity.entity_manager.counts.object >= settings.valuei["Object limit"].value then
		clear_entities(entities)
		clear_hash_cache(hash_cache)
		essentials.msg(lang["Reached object spawn limit. Cancelling menyoo spawn."], "red", true, 6)
		return true
	end
	return false
end

local function decrement_counter(Entity, entities)
	if entity.is_entity_a_ped(Entity) then
		entities.peds.successful_spawns = entities.peds.successful_spawns - 1
		entities.peds.failed_spawns = entities.peds.failed_spawns + 1
	elseif entity.is_entity_a_vehicle(Entity) then
		entities.vehicles.successful_spawns = entities.vehicles.successful_spawns - 1
		entities.vehicles.failed_spawns = entities.vehicles.failed_spawns + 1
	else
		entities.objects.successful_spawns = entities.objects.successful_spawns - 1
		entities.objects.failed_spawns = entities.objects.failed_spawns + 1
	end
end

local function attach(...)
	local Entity <const>,
	info <const>,
	entities <const> = ...
	if info.isAttached 
	and (math.type(info.PedVehicleSeat) ~= "integer" or info.PedVehicleSeat == -2)
	and entity.is_an_entity(Entity or 0) 
	and entity.is_an_entity(entities[info.AttachedTo] or 0)
	and type(info.X) == "number"
	and type(info.Y) == "number"
	and type(info.Y) == "number"
	and type(info.Z) == "number"
	and type(info.Pitch) == "number"
	and type(info.Roll) == "number"
	and type(info.Yaw) == "number" then
		local rot <const> = v3()
		local offset <const> = v3()
		offset.x = info.X
		offset.y = info.Y
		offset.z = info.Z
		rot.x = info.Pitch
		rot.y = info.Roll
		rot.z = info.Yaw
		entity.attach_entity_to_entity(Entity, entities[info.AttachedTo], info.BoneIndex or 0, offset, rot, false, info.IsCollisionProof == false, entity.get_entity_type(Entity) == 4, 0, true)
		essentials.assert(entity.is_entity_attached(Entity), "Failed to attach entity.")
	else
		decrement_counter(Entity, entities)
		kek_entity.clear_entities({Entity})
	end
end

local function spawn_vehicle(...)
	local file <const>,
	entities <const>,
	pid <const>,
	parent_entity <const>,
	xml_start <const>,
	xml_end <const> = ...
	local info <const> = extract_info(file, nil, xml_start, xml_end)
	local Entity <const> = spawn_entity(info, entities, false)
	if not entity.is_an_entity(Entity) then
		return info.ModelHash
	end
	if math.type(info.AttachedTo) ~= "integer" then
		info.AttachedTo = parent_entity
		entities[info.AttachedTo] = parent_entity
	end
	entities[info.InitialHandle] = Entity
	apply_entity_modifications(Entity, info, entities, pid)
	if info.isAttached then
		attach(Entity, info, entities)
	end
	return info.ModelHash
end

local function spawn_map_object(...)
	local file <const>,
	entities <const>,
	pid <const>,
	xml_start <const>,
	xml_end <const> = ...
	local info <const> = extract_info(file, nil, xml_start, xml_end)
	if type(info.PositionRotationX) == "number" 
	and type(info.PositionRotationY) == "number" 
	and type(info.PositionRotationZ) == "number" then
		local Entity <const> = spawn_entity(info, entities, true)
		if not entity.is_an_entity(Entity) then
			return info.ModelHash
		end
		entities[info.InitialHandle] = Entity
		apply_entity_modifications(Entity, info, entities, pid)
		if info.isAttached then
			attach(Entity, info, entities)
		elseif type(info.PositionRotationPitch) == "number" and type(info.PositionRotationRoll) == "number" and type(info.PositionRotationYaw) == "number" then
			essentials.assert(entity.set_entity_rotation(Entity, v3(info.PositionRotationPitch, info.PositionRotationRoll, info.PositionRotationYaw)), "Failed to set entity rotation.")
			essentials.assert(entity.set_entity_coords_no_offset(Entity, v3(info.PositionRotationX, info.PositionRotationY, info.PositionRotationZ)), "Failed to set entity position.")
		else
			decrement_counter(Entity, entities)
			kek_entity.clear_entities({clear_entities})
		end
	end
	return info.ModelHash
end

function menyoo.spawn_custom_vehicle(...)
	local file_path <const>,
	pid <const>,
	teleport <const> = ...
	essentials.assert(file_path:find("%.xml$"), "Tried to spawn a menyoo map with a non xml file.", file_path)
	essentials.assert(utils.file_exists(file_path), "Tried to read from a file that doesn't exist.", file_path)
	if not player.is_player_valid(pid) then
		return 0
	end
	local xml_start <const>, xml_end <const>, entities <const> = get_info_containers()
	local parent_entity = 0
	local hash_cache <const> = {} -- To not repeatedly request & discard the same hashes
	local file <close> = io.open(file_path)
	do
		local str
		repeat
			str = file:read("*l")
		until not str or str:find("SpoonerAttachments", 1, true) or str:find("SpoonerPlacements", 1, true)
		if str and str:find("SpoonerPlacements", 1, true) then
			essentials.msg(lang["Expected Menyoo vehicle, got Menyoo map. Put Menyoo maps in Menyoo maps folder."], "red", true, 6)
			return 0
		end
	end
	file:seek("set")
	local first_line <const> = file:read("*l")
	local current_line = file:read("*l")
	if not current_line or current_line == "" then
		essentials.msg(string.format("[%s: %s]: %s", lang["File name"], tostring(file_path:match("\\.+\\(.-)%.xml$")), lang["Xml file is empty."]), "red", true, 8)
		return 0
	end
	if not first_line:lower():find("?xml version=\"1.0\"", 1, true) or current_line:lower():find("map", 1, true) then
		essentials.msg(lang["Unsupported file format."], "red", true)
		return 0
	end
	local info <const> = extract_info(file, "SpoonerAttachments", xml_start, xml_end)
	if streaming.is_model_valid(info.ModelHash) then
		parent_entity = kek_entity.spawn_ped_or_vehicle(info.ModelHash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, -50), player.get_player_heading(pid)
		end, false, false, enums.ped_types.civmale, true)
		update_spawn_counter(entities, info.ModelHash, parent_entity)
		kek_entity.max_car(parent_entity, true)
		if entity.is_entity_a_vehicle(parent_entity) then
			hash_cache[#hash_cache + 1] = info.ModelHash
			entities[info.InitialHandle or 0] = parent_entity
			apply_entity_modifications(parent_entity, info, entities, pid)
			entity.freeze_entity(parent_entity, true)
		else
			essentials.msg(lang["Failed to spawn driver vehicle for unknown reason."], "red", true, 6)
			return 0
		end
	else
		essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
		return 0
	end
	current_line = ""
	kek_entity.entity_manager:update()
	while current_line do
		if new_attachment_check(current_line, nil, nil, xml_start, xml_end) then
			update_xml_string(xml_start, xml_end, current_line:match("^(%s*)[%w%p]+"))
			local hash <const> = spawn_vehicle(file, entities, pid, parent_entity, xml_start, xml_end)
			if streaming.is_model_valid(hash) then
				hash_cache[#hash_cache + 1] = hash
				if check_entity_limits(entities, hash_cache) then
					return 0
				end
			end
		end
		current_line = file:read("*l")
	end
	entity.freeze_entity(parent_entity, info.FrozenPos == true)
	clear_hash_cache(hash_cache)
	if teleport then
		kek_entity.teleport(parent_entity, location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 8)))
	end
	send_spawn_counter_msg(entities)
	return parent_entity
end

function menyoo.spawn_map(...)
	local file_path <const>,
	pid <const>,
	teleport_to_map <const> = ...
	essentials.assert(file_path:find("%.xml$"), "Tried to spawn a menyoo map with a non xml file.", file_path)
	essentials.assert(utils.file_exists(file_path), "Tried to read from a file that doesn't exist.", file_path)
	if not player.is_player_valid(pid) then
		return
	end
	local xml_start <const>, xml_end <const>, entities <const> = get_info_containers()
	local hash_cache <const> = {} -- To not repeatedly request & discard the same hashes
	local file <close> = io.open(file_path)
	do
		local str
		repeat
			str = file:read("*l")
		until not str or str:find("SpoonerPlacements", 1, true) or str:find("SpoonerAttachments", 1, true)
		if str and str:find("SpoonerAttachments", 1, true) then
			essentials.msg(lang["Expected Menyoo map, got Menyoo vehicle. Put Menyoo vehicles in Menyoo vehicles folder."], "red", true, 6)
			return
		end
	end
	file:seek("set")
	local current_line = file:read("*l")
	if not current_line or current_line == "" then
		essentials.msg(string.format("[%s: %s]: %s", lang["File name"], file_path:match("\\.+\\(.-)%.xml$"), lang["Xml file is empty."]), "red", true, 8)
		return
	end
	if not current_line:lower():find("?xml version=\"1.0\"", 1, true) then
		essentials.msg(lang["Unsupported file format."], "red", true)
		return
	end
	local reference_pos <const> = v3()
	repeat
		if current_line:find("<ReferenceCoords>", 1, true) then
			for i = 1, 3 do
				local line <const> = file:read("*l") or ""
				if line:find("</X>", 1, true) then
					reference_pos.x = tonumber(line:match(">(.-)<"))
				elseif line:find("</Y>", 1, true) then
					reference_pos.y = tonumber(line:match(">(.-)<"))
				elseif line:find("</Z>", 1, true) then
					reference_pos.z = tonumber(line:match(">(.-)<"))
				end
			end
		end
		if current_line:find("<WeatherToSet>", 1, true) and current_line:find(">[^</>]+</") and enums.weather[current_line:match(">([^</>]+)</")] then
			gameplay.set_override_weather(enums.weather[current_line:match(">([^</>]+)</")])
		end
		current_line = file:read("*l")
	until new_attachment_check(current_line, nil, nil, xml_start, xml_end)
	kek_entity.entity_manager:update()
	while current_line do
		if new_attachment_check(current_line, nil, nil, xml_start, xml_end) then
			update_xml_string(xml_start, xml_end, current_line:match("^(%s*)[%w%p]+"))
			local hash <const> = spawn_map_object(file, entities, pid, xml_start, xml_end)
			if streaming.is_model_valid(hash) then
				hash_cache[#hash_cache + 1] = hash
				if check_entity_limits(entities, hash_cache) then
					return
				end
			end
		end
		current_line = file:read("*l")
	end
	clear_hash_cache(hash_cache)
	if teleport_to_map then
		if reference_pos then
			kek_entity.teleport(essentials.get_most_relevant_entity(pid), reference_pos)
		else
			essentials.msg(lang["Failed to find reference coordinates."], "red", true, 6)
		end
	end
	send_spawn_counter_msg(entities)
end

function menyoo.clone_vehicle(...)
	local Vehicle, pos <const> = ...
	if entity.is_an_entity(Vehicle) then
		Vehicle = kek_entity.get_parent_of_attachment(Vehicle)
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		local num <const> = math.random(1, math.maxinteger)
		local tmp_path <const> = paths.kek_menu_stuff.."kekMenuData\\temp_vehicle"..num..".xml"
		menyoo_saver.save_vehicle(Vehicle, tmp_path)
		local car
		local status <const>, err <const> = pcall(function() -- So that file is removed even in case of errors
			car = menyoo.spawn_custom_vehicle(tmp_path, player.player_id())
		end)
		io.remove(tmp_path)
		essentials.assert(status, err)
		if pos and entity.is_entity_a_vehicle(car) then
			kek_entity.teleport(car, pos)
		end
		return car
	else
		return 0
	end
end

return essentials.const_all(menyoo)