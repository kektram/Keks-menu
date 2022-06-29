-- Copyright © 2020-2022 Kektram

local menyoo <const> = {version = "2.2.5"}

local language <const> = require("Kek's Language")
local lang <const> = language.lang
local essentials <const> = require("Kek's Essentials")
local kek_entity <const> = require("Kek's entity functions")
local custom_upgrades <const> = require("Kek's Custom upgrades")
local location_mapper <const> = require("Kek's Location mapper")
local weapon_mapper <const> = require("Kek's Weapon mapper")
local menyoo_saver <const> = require("Kek's Menyoo saver")
local enums <const> = require("Kek's Enums")
local settings <const> = require("Kek's Settings")
local memoize <const> = require("Kek's Memoize")

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"

local function get_entity_counts_from_xml_parse(xml_table)
	local is_model_an_object <const>, -- Tons of iterations below
	is_model_a_vehicle <const>,
	is_model_a_ped <const> = streaming.is_model_an_object, streaming.is_model_a_vehicle, streaming.is_model_a_ped

	local counts <const> = {
		object = 0,
		ped = 0,
		vehicle = 0
	}
	for i = 1, #xml_table do
		local hash <const> = xml_table[i].ModelHash or xml_table[i].Hash
		if is_model_an_object(hash) then
			counts.object = counts.object + 1
		elseif is_model_a_vehicle(hash) then
			counts.vehicle = counts.vehicle + 1
		elseif is_model_a_ped(hash) then
			counts.ped = counts.ped + 1
		end
	end
	return counts
end

local function get_entity_counts_from_ini_parse(...)
	local info <const> = ...
	local is_model_an_object <const>, -- Tons of iterations below
	is_model_a_vehicle <const>,
	is_model_a_ped <const> = streaming.is_model_an_object, streaming.is_model_a_vehicle, streaming.is_model_a_ped

	local counts <const> = {
		object = 0,
		ped = 0,
		vehicle = 0
	}
	for i = 1, #info do
		local info <const> = info[i]
		local hash <const> = 
			math.tointeger(info.Hash)
			or math.tointeger(info.hash)
			or math.tointeger(info.Model)
			or math.tointeger(info.model)
			or math.tointeger(type(info.Vehicle) == "table" and info.Vehicle.Model)
			or math.tointeger(type(info.VEHICLE) == "table" and info.VEHICLE.hash)
			or math.tointeger(type(info.Model) == "table" and info.Model.Hash)
			or 0

		if is_model_an_object(hash) then
			counts.object = counts.object + 1
		elseif is_model_a_vehicle(hash) then
			counts.vehicle = counts.vehicle + 1
		elseif is_model_a_ped(hash) then
			counts.ped = counts.ped + 1
		end
	end


	return counts
end

local function apply_vehicle_modifications(...)
	local Entity <const>, info <const> = ...

	local hash <const> = info.ModelHash
	local info <const> = info.VehicleProperties
	local colours <const> = info.Colours
	local doors_open <const> = info.DoorsOpen
	local tyres_bursted <const> = info.TyresBursted

	vehicle.set_vehicle_mod_kit_type(Entity, 0)
	if info.Mods._48[1] == -1 or info.Livery ~= -1 then
		vehicle.set_vehicle_livery(Entity, info.Livery)
	end
	kek_entity.set_wheel_type(Entity, info.WheelType) -- Wheel type must go first. Has caused a crash earlier.
	vehicle.set_vehicle_bulletproof_tires(Entity, info.BulletProofTyres == true)
	for i = 0, 75 do -- setting[2] is mod variation. Verified in menyoo source code.
		local setting <const> = info.Mods["_"..i]
		if type(setting) == "table" then
			vehicle.set_vehicle_mod(Entity, i, setting[1], i == 23 or i == 24)
		elseif type(setting) == "boolean" then
			vehicle.toggle_vehicle_mod(Entity, i, setting)
		end
	end
	if info.ModExtras then
		for i, value in pairs(info.ModExtras) do
			local extra_id <const> = tonumber((i:gsub("_", "")))
			if vehicle.does_extra_exist(Entity, extra_id) then
				vehicle.set_vehicle_extra(Entity, extra_id, not value) -- true == false. rockstar has made it opposite for some reason
			end
		end
	end
	if info.TorqueMultiplier and info.TorqueMultiplier ~= 1 then
		custom_upgrades.torque_modifier(Entity, info.TorqueMultiplier)
	end
	if info.RpmMultiplier and info.RpmMultiplier ~= 1 then
		vehicle.modify_vehicle_top_speed(Entity, info.RpmMultiplier * 100)
		entity.set_entity_max_speed(Entity, 540 * info.RpmMultiplier)
	end
	vehicle.set_vehicle_colors(Entity, colours.Primary, colours.Secondary)
	vehicle.set_vehicle_extra_colors(Entity, colours.Pearl, colours.Rim)
	if colours.tyreSmoke_R then
		vehicle.set_vehicle_tire_smoke_color(Entity, colours.tyreSmoke_R, colours.tyreSmoke_G, colours.tyreSmoke_B)
	end
	vehicle.set_vehicle_number_plate_text(Entity, type(info.NumberPlateText) == "string" and info.NumberPlateText or "kektram")
	if type(colours.LrXenonHeadlights) == "number" then -- Not all xmls supports this
		vehicle.set_vehicle_headlight_color(Entity, colours.LrXenonHeadlights)
	end
	if colours.IsPrimaryColourCustom then
		vehicle.set_vehicle_custom_primary_colour(Entity, essentials.get_rgb(colours.Cust1_R, colours.Cust1_G, colours.Cust1_B))
	end
	if colours.IsSecondaryColourCustom then
		vehicle.set_vehicle_custom_secondary_colour(Entity, essentials.get_rgb(colours.Cust2_R, colours.Cust2_G, colours.Cust2_B))
	end
	if colours.IsPearlColourCustom then
		vehicle.set_vehicle_custom_pearlescent_colour(Entity, colours.PearlCustom)
	end
	if info.PaintFade then
		vehicle.set_vehicle_enveff_scale(Entity, info.PaintFade)
	end
	if info.HeadlightIntensity then
		vehicle.set_vehicle_light_multiplier(Entity, info.HeadlightIntensity)
	end

	if info.RoofState then
		if info.RoofState == 1 or info.RoofState == 2 then
			vehicle.raise_convertible_roof(Entity, info.RoofState == 2);
		else
			vehicle.lower_convertible_roof(Entity, info.RoofState == 0);
		end
	end

	vehicle.set_vehicle_lights(Entity, info.LightsOn and 3 or 4)
	vehicle.set_vehicle_siren(Entity, info.SirenActive == true)
	vehicle.set_vehicle_number_plate_index(Entity, info.NumberPlateIndex)
	vehicle.set_vehicle_dirt_level(Entity, info.DirtLevel)
	vehicle.set_vehicle_window_tint(Entity, info.WindowTint)
	vehicle.set_vehicle_engine_on(Entity, info.EngineOn == true, true, false)
	vehicle.set_vehicle_neon_light_enabled(Entity, 0, info.Neons.Left == true)
	vehicle.set_vehicle_neon_light_enabled(Entity, 1, info.Neons.Right == true)
	vehicle.set_vehicle_neon_light_enabled(Entity, 2, info.Neons.Front == true)
	vehicle.set_vehicle_neon_light_enabled(Entity, 3, info.Neons.Back == true)
	vehicle.set_vehicle_neon_lights_color(Entity, essentials.get_rgb(info.Neons.R, info.Neons.G, info.Neons.B))
	if info.LandingGearState and (streaming.is_model_a_plane(hash) or streaming.is_model_a_heli(hash)) then
		vehicle.control_landing_gear(Entity, info.LandingGearState)
	end
	if info.EngineHealth then
		vehicle.set_vehicle_engine_health(Entity, info.EngineHealth)
	end
	if doors_open then
		for i, setting in pairs(doors_open) do
			if setting == true then
				vehicle.set_vehicle_door_open(Entity, enums.vehicle_door_indices[i], false, true)
			end
		end
	end
	if tyres_bursted then
		for i, setting in pairs(tyres_bursted) do
			if setting == true then
				vehicle.set_vehicle_tire_burst(Entity, enums.vehicle_tyre_indices[i], true, 1000)
			end
		end
	end
	if info.ReducedGrip == true then
		vehicle.set_vehicle_reduce_grip(Entity, true)
	end
	if info.WheelsCount then -- Any checks below is because the functions gathering these properties may return nil
		if info.WheelsRenderSize then
			vehicle.set_vehicle_wheel_render_size(Entity, info.WheelsRenderSize)
		end
		if info.WheelsRenderWidth then
			vehicle.set_vehicle_wheel_render_width(Entity, info.WheelsRenderWidth)
		end
		if info.MaxGear then
			vehicle.set_vehicle_max_gear(Entity, info.MaxGear)
		end
		if info.CurrentGear then
			vehicle.set_vehicle_current_gear(Entity, info.CurrentGear)
		end
		for i = 0, info.WheelsCount - 1 do
			if info["Wheel_"..i]["TireRadius"] then
				vehicle.set_vehicle_wheel_tire_radius(Entity, i, info["Wheel_"..i]["TireRadius"])
			end
			if info["Wheel_"..i]["RimRadius"] then
				vehicle.set_vehicle_wheel_rim_radius(Entity, i, info["Wheel_"..i]["RimRadius"])
			end
			if info["Wheel_"..i]["TireWidth"] then
				vehicle.set_vehicle_wheel_tire_width(Entity, i, info["Wheel_"..i]["TireWidth"])
			end
			if info["Wheel_"..i]["RotationSpeed"] then
				vehicle.set_vehicle_wheel_rotation_speed(Entity, i, info["Wheel_"..i]["RotationSpeed"])
			end
			if info["Wheel_"..i]["Power"] then
				vehicle.set_vehicle_wheel_power(Entity, i, info["Wheel_"..i]["Power"])
			end
			if info["Wheel_"..i]["Health"] then
				vehicle.set_vehicle_wheel_health(Entity, i, info["Wheel_"..i]["Health"])
			end
			if info["Wheel_"..i]["BrakePressure"] then
				vehicle.set_vehicle_wheel_brake_pressure(Entity, i, info["Wheel_"..i]["BrakePressure"])
			end
			if info["Wheel_"..i]["TractionVectorLength"] then
				vehicle.set_vehicle_wheel_traction_vector_length(Entity, i, info["Wheel_"..i]["TractionVectorLength"])
			end
			if info["Wheel_"..i]["xOffset"] then
				vehicle.set_vehicle_wheel_x_offset(Entity, i, info["Wheel_"..i]["xOffset"])
			end
			if info["Wheel_"..i]["yRotation"] then
				vehicle.set_vehicle_wheel_y_rotation(Entity, i, info["Wheel_"..i]["yRotation"])
			end
			if info["Wheel_"..i]["Flags"] then
				vehicle.set_vehicle_wheel_flags(Entity, i, info["Wheel_"..i]["Flags"])
			end
			if info["Wheel_"..i]["Power"] > 0 then
				vehicle.set_vehicle_wheel_is_powered(Entity, i, true)
			end
		end
	end
end

local function apply_ped_modifications(...)
	local Entity <const>, info <const>, entities <const> = ...
	if info.PedProperties.IsStill == true then
		ped.set_ped_config_flag(Entity, enums.ped_config_flags.DisablePedConstraints, 1)
	end
	if info.PedProperties.CanRagdoll == true then
		ped.set_ped_config_flag(Entity, enums.ped_config_flags.cantRagdoll, 0)
	end
	if info.PedProperties.CurrentWeapon 
	and info.PedProperties.CurrentWeapon ~= gameplay.get_hash_key("weapon_unarmed") 
	and streaming.is_model_valid(weapon.get_weapon_model(info.PedProperties.CurrentWeapon)) then -- Currentweapon isn't obtained by menyoo saver
		weapon.give_delayed_weapon_to_ped(Entity, info.PedProperties.CurrentWeapon, 0, 1)
		weapon_mapper.set_ped_weapon_attachments(Entity, true, info.PedProperties.CurrentWeapon)
		kek_entity.set_combat_attributes(Entity, true, {})
	end
	for i = 0, 9 do
		ped.set_ped_prop_index(Entity, i, info.PedProperties["PedProps"]["_"..i][1], info.PedProperties["PedProps"]["_"..i][2], 0)
	end
	for i = 0, 11 do
		ped.set_ped_component_variation(Entity, i, info.PedProperties["PedComps"]["_"..i][1], info.PedProperties["PedComps"]["_"..i][2], 0)
	end
	if info.PedProperties.HairColor then
		ped.set_ped_hair_colors(Entity, info.PedProperties.HairColor, info.PedProperties.HairHighlightColor)
		ped.set_ped_eye_color(Entity, info.PedProperties.EyeColor)
		if info.PedProperties.BlendData.mix_third then
			ped.set_ped_head_blend_data(Entity, 
				info.PedProperties.BlendData.shape_first, 
				info.PedProperties.BlendData.shape_second,
				info.PedProperties.BlendData.shape_third,
				info.PedProperties.BlendData.skin_first,
				info.PedProperties.BlendData.skin_second,
				info.PedProperties.BlendData.skin_third,
				info.PedProperties.BlendData.mix_shape,
				info.PedProperties.BlendData.mix_skin,
				info.PedProperties.BlendData.mix_third
			)
		end
		for i = 0, 19 do
			ped.set_ped_face_feature(Entity, i, info["FacialFeatures"][tostring(i)])
		end
	end
	if type(info.PedProperties.RelationshipGroupAltered) == true then
		ped.set_ped_relationship_group_hash(Entity, info.PedProperties.RelationshipGroup)
	end
	if info.PedProperties.PedVehicleSeat
	and info.PedProperties.PedVehicleSeat ~= -2
	and info.Attachment
	and entity.is_entity_a_ped(entities[info.Attachment.AttachedTo]) then
		ped.set_ped_into_vehicle(Entity, entities[info.Attachment.AttachedTo], info.PedProperties.PedVehicleSeat)
		ai.task_vehicle_drive_wander(Entity, entities[info.Attachment.AttachedTo], 150, settings.in_use["Drive style"])
		info.Attachment.__attributes.isAttached = false
	end
	if info.PedProperties.ScenarioActive == true then
		ai.task_start_scenario_in_place(Entity, info.PedProperties.ScenarioName, 0, true)
	end
	if info.PedProperties.AnimActive == true and essentials.request_anim_dict(info.PedProperties.AnimDict) then
		ai.task_play_anim(Entity, info.PedProperties.AnimDict, info.PedProperties.AnimName, 8.0, 1.0, -1, 1, 1.0, false, false, false)
		streaming.remove_anim_dict(info.PedProperties.AnimDict)
	end
	if info.PedProperties.MovementGroupName and essentials.request_anim_set(info.PedProperties.MovementGroupName) then
		ped.set_ped_movement_clipset(Entity, info.PedProperties.MovementGroupName)
		streaming.remove_anim_set(info.PedProperties.MovementGroupName)
	end
end

local function apply_entity_modifications(...) -- To be used with function spawn_entity. It doesnt freeze entities because that function does it.
	local Entity <const>, info <const>, entities <const>, pid <const> = ...
	if entity.is_an_entity(Entity) then
		if entity.is_entity_a_vehicle(Entity) and info.VehicleProperties then
			apply_vehicle_modifications(Entity, info)
		elseif entity.is_entity_a_ped(Entity) and info.PedProperties then
			apply_ped_modifications(Entity, info, entities)
		elseif entity.is_entity_an_object(Entity) and info.ObjectProperties and info.ObjectProperties.TextureVariation then
			object._set_object_texture_variation(Entity, info.ObjectProperties.TextureVariation)
		end
		if info.OpacityLevel then
			entity.set_entity_alpha(Entity, info.OpacityLevel, 1)
		end
		if info.LodDistance then
			entity.set_entity_lod_dist(Entity, info.LodDistance)
		end
		if info.MaxHealth then
			entity.set_entity_max_health(Entity, info.MaxHealth)
		end
		if info.Health then
			entity.set_entity_health(Entity, info.Health, 0) -- Third parameter is always 0 in freemode.ysc
		end

		local entity_proofs <const> = kek_entity.get_entity_proofs(Entity)

		entity.set_entity_proofs( -- If the file doesn't specify all the proofs, the conditions prevent proofs from being modified.
			Entity, 
			info.IsBulletProof 	  == true or info.IsBulletProof 	 == nil and entity_proofs.bullet 	or false, 
			info.IsFireProof 	  == true or entity_proofs.fire 	 == nil and entity_proofs.fire 		or false, 
			info.IsExplosionProof == true or entity_proofs.explosion == nil and entity_proofs.explosion or false, 
			info.IsCollisionProof == true or entity_proofs.collision == nil and entity_proofs.collision or false, 
			info.IsMeleeProof 	  == true or entity_proofs.melee 	 == nil and entity_proofs.melee 	or false, 
			info.IsSteamProof 	  == true or entity_proofs.steam 	 == nil and entity_proofs.steam 	or false, 
			entity_proofs.unknown,
			info.IsDrownProof	  == true or entity_proofs.drown 	 == nil and entity_proofs.drown 	or false
		)

		if type(info.HasGravity) == "boolean" then
			entity.set_entity_gravity(Entity, info.HasGravity)
		end
		if type(info.IsVisible) == "boolean" then
			entity.set_entity_visible(Entity, info.IsVisible)
		end
		if info.IsOnFire == true then
			fire.start_entity_fire(Entity)
		end
		entity.set_entity_god_mode(Entity, info.IsInvincible == true)
		if pid == player.player_id()
		and info.ModelHash == gameplay.get_hash_key("p_rcss_folded") -- Is object turret? 
		and info.Attachment
		and info.Attachment.__attributes.isAttached
		and entities[info.Attachment.AttachedTo] 
		and entity.is_entity_a_vehicle(entities[info.Attachment.AttachedTo])
		then
			custom_upgrades.vehicle_turret(
				entities[info.Attachment.AttachedTo], 
				Entity, 
				v3(info.Attachment.X, info.Attachment.Y, info.Attachment.Z)
			)
			info.Attachment.__attributes.isAttached = false
		end
	end
end

local function send_spawn_counter_msg(counts)
	essentials.msg(string.format("%s\n%s: %i\n%s: %i\n%s: %i", 
		lang["Spawned"], 
		lang["Peds"],
		counts.ped,
		lang["Vehicles"],
		counts.vehicle,
		lang["Objects"],
		counts.object),
		"green", 
		true,
		6
	)
end

local function get_max_networked_vehicles() -- There requires some bypass or something to spawn over 128 vehicles.
	return network.get_max_num_network_vehicles() > 128 and 128 or network.get_max_num_network_vehicles()
end

local function send_is_networked_msg(counts, network_status)
	if network_status == "is_networked" then
		essentials.msg(lang["The map/vehicle will be visible to other people."], "green", true, 5)
	elseif counts.object <= network.get_max_num_network_objects() and counts.ped <= network.get_max_num_network_peds() and counts.vehicle <= get_max_networked_vehicles() then
		essentials.msg(lang["The map/vehicle can be networked if you clear all entities. Currently there are other networked entities taking up space."], "yellow", true, 8)
	else
		essentials.msg(
			string.format(
				lang["The map/vehicle won't be visible to other players, it has too many entities. Networked maps/vehicles supports max:\n%i objects\n%i vehicles\n%i peds."], 
				network.get_max_num_network_objects(),
				get_max_networked_vehicles(),
				network.get_max_num_network_peds()
			), 
			"red", 
			true, 
			8
		)
	end
end

local function spawn_entity(info, entities, network_status)
	local hash <const> = info.ModelHash or type(info.Model) == "table" and info.Model.Hash or info.Model or info.model or info.hash or info.Hash
	if not streaming.is_model_valid(hash) then
		return 0
	end
	local Entity = 0
	if streaming.is_model_an_object(hash) and network_status == "is_networked" then
		Entity = kek_entity.spawn_networked_object(hash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, 40)
		end, info.Dynamic == false)
	elseif streaming.is_model_an_object(hash) and network_status == "is_not_networked" then
		Entity = kek_entity.spawn_local_object(hash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, 40)
		end, info.Dynamic == false)
	elseif streaming.is_model_a_ped(hash) and network_status == "is_networked" then
		Entity = kek_entity.spawn_networked_ped(hash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, 40), 0
		end)
	elseif streaming.is_model_a_ped(hash) and network_status == "is_not_networked" then
		Entity = kek_entity.spawn_local_ped(hash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, 40), 0
		end)
	elseif streaming.is_model_a_vehicle(hash) and network_status == "is_networked" then
		Entity = kek_entity.spawn_networked_vehicle(hash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, 40), 0
		end, {
			godmode = false,
			max = false,
			persistent = true
		})
	elseif streaming.is_model_a_vehicle(hash) and network_status == "is_not_networked" then
		Entity = kek_entity.spawn_local_mission_vehicle(hash, function()
			return memoize.get_player_coords(player.player_id()) + memoize.v3(0, 0, 40), 0
		end)
	end
	if entity.is_an_entity(Entity) then
		entity.freeze_entity(Entity, true)
	end
	return Entity
end

local function is_spawn_too_many_entities(counts, network_status)
	kek_entity.entity_manager:update()
	local status = false

	local number_of_peds <const> = math.ceil(network_status == "is_networked" and counts.ped * 1.5 or counts.ped)
	local ped_cap <const> = math.ceil(settings.valuei["Ped limits"].value - (kek_entity.entity_manager.counts.ped / 10))
	if number_of_peds > ped_cap then
		essentials.msg(lang["Requires %i more peds than can be spawned. There are peds taking up space; clear them to spawn the map/vehicle."]:format(number_of_peds - ped_cap), "red", true, 8)
		status = true
	end

	local number_of_vehicles <const> = math.ceil(counts.vehicle)
	local vehicle_cap <const> = math.ceil(settings.valuei["Vehicle limits"].value - (kek_entity.entity_manager.counts.vehicle / 10))
	if number_of_vehicles > vehicle_cap then
		essentials.msg(lang["Requires %i more vehicles than can be spawned. There are vehicles taking up space; clear them to spawn the map/vehicle."]:format(number_of_vehicles - vehicle_cap), "red", true, 8)
		status = true
	end

	local number_of_objects <const> = math.ceil(network_status == "is_networked" and counts.object or counts.object * 0.5)
	local object_cap <const> = math.ceil(settings.valuei["Object limits"].value - (kek_entity.entity_manager.counts.object / 10))
	if number_of_objects > object_cap then
		essentials.msg(lang["Requires %i more objects than can be spawned. There are objects taking up space; clear them to spawn the map/vehicle."]:format(number_of_objects - object_cap), "red", true, 8)
		status = true
	end
	return status
end

local function attach(...)
	local Entity <const>,
	info <const>,
	entities <const> = ...
	local status = false
	local att_info = info.Attachment or info.Placement -- Maps use Placement, vehicles use Attachment

	local offx  <const> = info.X 	 or info.x 	   or info.xt   or info.OffsetX or info["x offset"] or att_info and att_info.X     or 0
	local offy  <const> = info.Y 	 or info.y 	   or info.yt   or info.OffsetY or info["y offset"] or att_info and att_info.Y     or 0
	local offz  <const> = info.Z 	 or info.z 	   or info.zt   or info.OffsetZ or info["z offset"] or att_info and att_info.Z 	   or 0
	local pitch <const> = info.Pitch or info.pitch or info.RotX or info.Rotx 	or 				       att_info and att_info.Pitch or 0
	local roll  <const> = info.Roll  or info.roll  or info.RotY or info.Roty 	or 					   att_info and att_info.Roll  or 0
	local yaw   <const> = info.Yaw   or info.yaw   or info.RotZ or info.Rotz 	or 					   att_info and att_info.Yaw   or 0

	local entity_attached_to <const> = entities[info.AttachNumeration] or att_info and entities[att_info.AttachedTo] or entities["parent_entity"] or 0
	local is_attached <const> = info.isAttached or info.IsAttached or att_info and att_info.__attributes.isAttached
	
	local collision = (info.collision or info.Collision) ~= false
	if type(info.IsCollisionProof) == "boolean" then
		collision = info.IsCollisionProof == false
	elseif type(info.collision) == "number" or type(info.Collision) == "number" then
		collision = (info.collision or info.Collision) ~= 0
	end

	if (is_attached)
	and (math.type(info.PedVehicleSeat) ~= "integer" or info.PedVehicleSeat == -2)
	and entity.is_an_entity(Entity or 0) 
	and entity.is_an_entity(entity_attached_to)
	and type(offx)  == "number"
	and type(offy)  == "number"
	and type(offz)  == "number"
	and type(pitch) == "number"
	and type(roll)  == "number"
	and type(yaw)   == "number"
	and Entity ~= entity_attached_to then
		if not entity.is_entity_attached(Entity) then
			entity.set_entity_collision(Entity, collision, collision, collision)
		end

		entity.attach_entity_to_entity__native(
			Entity, 							 -- Entity to attach
			entity_attached_to, 			 	 -- Entity to attach to
			att_info and att_info.BoneIndex or info.Bone or info.bone or 0, -- Bone index
			v3(offx, offy, offz), 				 -- Offset from entity
			v3(pitch, roll, yaw), 				 -- Rotation
			false,								 -- Unknown, seems to not have any effect. Rockstar have it false.
			false, 								 -- Soft attach (can detach easily or not)
			collision, 							 -- Collision
			entity.get_entity_type(Entity) == 4, -- Is entity to be attached a ped
			2, 									 -- Rotation order
			true 								 -- Fixed rotation
		)
		entity.process_entity_attachments(entity_attached_to)
		if not entity.is_entity_attached(Entity) or entity.get_entity_attached_to(Entity) ~= entity_attached_to then
			kek_entity.clear_entities({Entity})
		else
			status = true
		end
	end
	if not status then
		essentials.msg(lang["Failed to attach an entity. Check debug console for more details."], "blue", true, 6)
		print(string.format(([[

			VALUES:
			Model name: %s (%s)
			Hash: %s (%s)
			x: %s (%s)
			y: %s (%s)
			z: %s (%s)
			pitch: %s (%s)
			roll: %s (%s)
			yaw: %s (%s)
			Entity id: %s (%s)
			is Entity an entity: %s
			is attached to, an entity: %s
			is attached bool from file: %s
			Tried to attach to itself? %s
			]]):gsub("\t", ""),
			info["model name"] or info["HashName"], type(info["model name"] or info["HashName"]),
			info.hash or info.Hash or info.model or info.Model or info.ModelHash, type(info.hash or info.Hash or info.model or info.Model or info.ModelHash),
			offx, type(offx), 
			offy, type(offy),
			offz, type(offz),
			pitch, type(pitch),
			roll, type(roll),
			yaw, type(yaw),
			Entity, type(Entity),
			entity.is_an_entity(Entity), 
			entity.is_an_entity(entity_attached_to), 
			is_attached,
			Entity == entity_attached_to
		))
		kek_entity.clear_entities({Entity})
	end
end

local function is_table_logic(Table)
	if not Table.__is_table then
		return {Table}
	else
		return Table
	end
end

function menyoo.spawn_xml_vehicle(...)
	local file_path <const>, pid <const> = ...
	if not utils.file_exists(file_path) then
		essentials.msg(lang["This file doesn't exist or has an invalid file name."], "red", true, 6)
		return 0
	end
	local info <const> = essentials.parse_xml(essentials.get_file_string(file_path)).Vehicle
	local spooner <const> = info and info.SpoonerAttachments

	if not info then
		essentials.msg(lang["Unsupported file format."], "red", true)
		return 0
	end
	local entities <const> = {}

	local counts <const> = get_entity_counts_from_xml_parse(
		(type(spooner) == "table" and (spooner.Attachment or spooner.Placement)) and is_table_logic(spooner.Attachment or spooner.Placement) or {}
	)
	counts.vehicle = counts.vehicle + 1 -- Parent vehicle isn't accounted for in the get counts function

	local network_status <const> = 
		counts.object <= network.get_max_num_network_objects() - #kek_entity.get_net_objects() 
		and counts.ped <= network.get_max_num_network_peds() - #kek_entity.get_net_peds() 
		and counts.vehicle <= get_max_networked_vehicles() - #kek_entity.get_net_vehicles()
		and "is_networked" or "is_not_networked"

	if is_spawn_too_many_entities(counts, network_status) then
		return 0
	end	

	local parent_entity <const> = spawn_entity(info, entities, network_status)
	if streaming.is_model_valid(info.ModelHash) then
		if entity.is_entity_a_vehicle(parent_entity) then
			entity.freeze_entity(parent_entity, true)
			entities[info.InitialHandle or "VEHICLE"] = parent_entity
			apply_entity_modifications(parent_entity, info, entities, pid)
		else
			essentials.msg(lang["Failed to spawn driver vehicle for unknown reason."], "red", true, 6)
			return 0
		end
	else
		essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
		return 0
	end
	if spooner and (spooner.Attachment or spooner.Placement) then -- Does it have attachments?
		for _, info in pairs(is_table_logic(spooner.Attachment or spooner.Placement)) do
			local Entity <const> = spawn_entity(info, entities, network_status)
			if entity.is_an_entity(Entity) then
				entities[info.InitialHandle] = Entity
				apply_entity_modifications(Entity, info, entities, pid)
				if info.Attachment and info.Attachment.__attributes.isAttached then
					attach(Entity, info, entities)
				end
			end
		end
	end
	entity.freeze_entity(parent_entity, info.FrozenPos == true)
	if not info.FrozenPos == true then
		rope.activate_physics(parent_entity)
	end
	kek_entity.set_entity_heading(parent_entity, player.get_player_heading(player.player_id()))
	send_spawn_counter_msg(counts)
	send_is_networked_msg(counts, network_status)
	return parent_entity
end

local function spawn_xml_map_type_1(info, entities, network_status) -- Most menyoo files follow this format
	local spooner <const> = info.SpoonerPlacements
	if player.player_count() > 0 and spooner.ClearWorld and spooner.ClearWorld > 0 then
		for _, entities in pairs(kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit({
				vehicles = {
					entities 			   = vehicle.get_all_vehicles(),
					max_number_of_entities = nil,
					remove_player_entities = true,
					max_range			   = spooner.ClearWorld,
					sort_by_closest 	   = false
				},
				peds = {
					entities 			   = ped.get_all_peds(),
					max_number_of_entities = nil,
					remove_player_entities = true,
					max_range			   = spooner.ClearWorld,
					sort_by_closest 	   = false
				},
				objects = {
					entities 			   = object.get_all_objects(),
					max_number_of_entities = nil,
					remove_player_entities = false,
					max_range			   = spooner.ClearWorld,
					sort_by_closest 	   = false
				}
			},
			player.get_player_ped(player.player_id())
		)) do
			kek_entity.clear_entities(entities, 25)
		end
	end
	if spooner.WeatherToSet and enums.weather[spooner.WeatherToSet] then
		gameplay.set_override_weather(enums.weather[spooner.WeatherToSet])
	end
	if spooner.IPLsToRemove then
		if type(spooner.IPLsToRemove.IPL) ~= "table" then
			spooner.IPLsToRemove.IPL = {spooner.IPLsToRemove.IPL}
		end
		for _, ipl in pairs(spooner.IPLsToRemove.IPL) do
			streaming.remove_ipl(ipl)
		end
	end
	for _, info in pairs(is_table_logic(spooner.Placement or spooner.Attachment)) do
		local Entity <const> = spawn_entity(info, entities, network_status)
		local is_frozen <const> = info.FrozenPos
		info.FrozenPos = true
		if entity.is_an_entity(Entity) then
			entities[info.InitialHandle] = Entity
			apply_entity_modifications(Entity, info, entities)
			if info.Attachment and info.Attachment.__attributes.isAttached then
				attach(Entity, info, entities)
			else
				entity.set_entity_rotation__native(Entity, v3(info.PositionRotation.Pitch, info.PositionRotation.Roll, info.PositionRotation.Yaw), 2, true)
				essentials.assert(entity.set_entity_coords_no_offset(Entity, v3(info.PositionRotation.X, info.PositionRotation.Y, info.PositionRotation.Z)), "Failed to set entity position.")
				entity.freeze_entity(Entity, is_frozen)
				if not is_frozen then
					rope.activate_physics(Entity)
				end
			end
		end
	end
end

local function spawn_xml_map_type_2(info, entities, network_status) -- Same as type_1, but missing many properties, such as vehicle mods
	if player.player_count() > 0 and info.SpoonerPlacements.ClearWorld then
		kek_entity.clear_entities(kek_entity.remove_player_entities(vehicle.get_all_vehicles()), 25)
		kek_entity.clear_entities(kek_entity.remove_player_entities(ped.get_all_peds()), 25)
		kek_entity.clear_entities(object.get_all_objects(), 25)
	end
	for _, info in pairs(is_table_logic(info.SpoonerPlacements.Placement)) do
		local Entity <const> = spawn_entity(info, entities, network_status)
		if entity.is_an_entity(Entity) then
			entities[info.InitialHandle] = Entity
			entity.set_entity_alpha(Entity, info.OpacityLevel, 1)
			entity.set_entity_visible(Entity, info.IsVisible)
			if info.IsOnFire == true then
				fire.start_entity_fire(Entity)
			end
			if info.Attachment and info.Attachment.__attributes.isAttached then
				attach(Entity, info, entities)
			else
				entity.set_entity_rotation__native(Entity, v3(info.PositionRotation.Pitch, info.PositionRotation.Roll, info.PositionRotation.Yaw), 2, true)
				essentials.assert(entity.set_entity_coords_no_offset(Entity, v3(info.PositionRotation.X, info.PositionRotation.Y, info.PositionRotation.Z)), "Failed to set entity position.")
				entity.freeze_entity(Entity, entity.is_entity_an_object(Entity))
				if not entity.is_entity_an_object(Entity) then
					rope.activate_physics(Entity)
				end
			end
		end
	end
end

local function spawn_xml_map_type_3(info, entities, network_status) -- LSCdamwithpeds&vehicles.xml
	for _, info in pairs(is_table_logic(info.Map.Objects.MapObject)) do
		info.ModelHash = info.Hash
		local Entity <const> = spawn_entity(info, entities, network_status)
		if entity.is_an_entity(Entity) then
			entities[Entity] = Entity
			local rot <const> = info.Rotation
			local pos <const> = info.Position
			entity.set_entity_rotation__native(Entity, v3(rot.X, rot.Y, rot.Z), 2, true)
			essentials.assert(
				entity.set_entity_coords_no_offset(Entity, v3(pos.X, pos.Y, pos.Z)), 
				"Failed to set entity position."
			)
			entity.freeze_entity(Entity, entity.is_entity_an_object(Entity))
			if not entity.is_entity_an_object(Entity) then
				rope.activate_physics(Entity)
			end
			if info.Type == "Ped" then
				weapon.give_delayed_weapon_to_ped(Entity, gameplay.get_hash_key("weapon_"..info.Weapon:lower()), 0, 1)
				ped.set_ped_relationship_group_hash(Entity, gameplay.get_hash_key(info.Relationship:upper()))
			end
		end
	end
end

local function get_xml_map_type(info)
	local spooner <const> = info.SpoonerPlacements
	if spooner and ((spooner.Placement and (info.prologue.kek_menu_version or spooner.AudioFile)) or spooner.Attachment) then
		return "type_1"
	elseif spooner and spooner.__attributes and spooner.__attributes["xmlns:xsi"] then
		return "type_2"
	elseif info.Map and info.Map.Objects then
		return "type_3"
	end
end

function menyoo.spawn_xml_map(...)
	local file_path <const>, teleport_to_map <const> = ...
	if not utils.file_exists(file_path) then
		essentials.msg(lang["This file doesn't exist or has an invalid file name."], "red", true, 6)
		return
	end
	local info <const> = essentials.parse_xml(essentials.get_file_string(file_path))
	local spooner <const> = info.SpoonerPlacements or info.Map

	local counts <const> = get_entity_counts_from_xml_parse(
		spooner.Objects and is_table_logic(spooner.Objects.MapObject)
		or is_table_logic(spooner.Placement or spooner.Attachment)
	)
	local network_status <const> = 
		counts.object <= network.get_max_num_network_objects() - #kek_entity.get_net_objects() 
		and counts.ped <= network.get_max_num_network_peds() - #kek_entity.get_net_peds() 
		and counts.vehicle <= get_max_networked_vehicles() - #kek_entity.get_net_vehicles()
		and "is_networked" or "is_not_networked"

	if is_spawn_too_many_entities(counts, network_status) then
		return 0
	end

	if not info.Map and not spooner then
		essentials.msg(lang["Unsupported file format."], "red", true)
		return
	end

	local tp_state, tp_err
	local frozen_vehicle <const> = player.get_player_vehicle(player.player_id())
	if teleport_to_map then
		entity.freeze_entity(player.get_player_ped(player.player_id()), true)
		entity.freeze_entity(frozen_vehicle, true)
		if spooner and spooner.ReferenceCoords then
			tp_state, tp_err = pcall(function() -- There has to be zero chance of user being frozen forever.
				kek_entity.teleport(
					kek_entity.get_most_relevant_entity(player.player_id()), 
					v3(
						spooner.ReferenceCoords.X, 
						spooner.ReferenceCoords.Y, 
						spooner.ReferenceCoords.Z
					)
				)
			end)
		elseif info.Map and info.Map.Objects and info.Map.Objects.MapObject then -- This type has no reference coords
			local t = info.Map.Objects.MapObject
			t = t.__is_table and t[1] or t
			local pos <const> = info.Map.Objects.ReferenceCoords or t.Position
			kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), v3(pos.X, pos.Y, pos.Z))
		else
			essentials.msg(lang["Failed to find reference coordinates."], "red", true, 6)
		end
	end

	local entities, map_type, status
	local state <const>, err <const> = pcall(function() -- Must unfreeze user entities no matter what.
		entities = {}
		map_type = get_xml_map_type(info)
		if map_type and settings.toggle["Clear before spawning xml map"].on then
			kek_entity.entity_manager:clear() -- This sets models as no longer needed
			system.yield(1000) -- Waits until models have left memory; has made spawning far more stable
		end

		if map_type == "type_1" then
			status = spawn_xml_map_type_1(info, entities, network_status)
		elseif map_type == "type_2" then
			status = spawn_xml_map_type_2(info, entities, network_status)
		elseif map_type == "type_3" then
			status = spawn_xml_map_type_3(info, entities, network_status)
		else
			status = "failed"
			essentials.msg(lang["Unsupported file format."], "red", true)
		end
	end)
	entity.freeze_entity(player.get_player_ped(player.player_id()), false)
	rope.activate_physics(player.get_player_ped(player.player_id()))
	entity.freeze_entity(frozen_vehicle, false)
	rope.activate_physics(frozen_vehicle)
	essentials.assert(tp_state == nil or tp_state, tp_err)
	essentials.assert(state, err)

	if status == "failed" then
		return
	end

	local ipls <const> = spooner.IPLsToLoad
	if spooner and ipls and ipls.IPL then
		local Entity
		for Entity_2 in essentials.entities(entities) do
			Entity = Entity_2
			break
		end
		if type(ipls.IPL) ~= "table" then
			ipls.IPL = {ipls.IPL}
		end
		for _, ipl in pairs(ipls.IPL) do
			streaming.request_ipl(ipl)
		end
		menu.create_thread(function()
			while entity.is_an_entity(Entity) do
				system.yield(0)
			end
			for _, ipl in pairs(ipls.IPL) do
				streaming.remove_ipl(ipl)
			end
		end, nil)
	end

	send_spawn_counter_msg(counts)
	send_is_networked_msg(counts, network_status)
	return entities
end

function menyoo.clone_vehicle(...)
	local Vehicle, pos <const>, heading <const> = ...
	if entity.is_an_entity(Vehicle) then
		Vehicle = kek_entity.get_parent_of_attachment(Vehicle)
		essentials.assert(entity.is_entity_a_vehicle(Vehicle), "Expected a vehicle.")
		local num <const> = math.random(1, math.maxinteger)
		local tmp_path <const> = paths.kek_menu_stuff.."kekMenuData\\temp_vehicle"..num..".xml"
		local car
		local status <const>, err <const> = pcall(function() -- So that file is removed even in case of errors
			menyoo_saver.save_vehicle(Vehicle, tmp_path)
			car = menyoo.spawn_xml_vehicle(tmp_path, player.player_id())
			kek_entity.set_entity_heading(car, heading or entity.get_entity_heading(Vehicle))
		end)
		io.remove(tmp_path)
		essentials.assert(status, err)
		if pos and entity.is_entity_a_vehicle(car) then
			kek_entity.teleport(car, pos)
		end
		vehicle.copy_vehicle_damages(Vehicle, car)
		return car
	else
		return 0
	end
end

local function get_ini_type(str)
	if str:find("^%[VEHICLE%]") or (str:find("License Plate Text Index", 1, true) and str:find("Tire Smoke Green", 1, true)) then
		return "type_1"
	elseif str:find("T%d+\32?=") and str:find("M%d+\32?=") then
		if str:find("[AllObjects]", 1, true) and str:find("ScorchedRender = ", 1, true) then
			return "type_2a"
		else
			return "type_2b"
		end
	elseif str:find("[Vehicle]", 1, true) and str:find("model=", 1, true) and str:find("%d%d=[-%d]+") then
		return "type_3"
	elseif (str:find("NeonEnabled", 1, true) or str:find("Radio=", 1, true)) and (str:find("TOGGLE_", 1, true) or str:find("Froozen=", 1, true)) and str:find("[Vehicle]", 1, true) then
		return "type_4"
	elseif str:find("[0]", 1, true) and not str:find("%[%a+%d*%]") then
		return "type_5"
	elseif str:find("^%[Vehicle%][\n\r]+Model=[%x-]+[\n\r]+%[0%]") then
		return "type_6"
	end
end

local gsub_map <const> = {
	["\32"] = "",
	["\9"] = "",
	[","] = ".",
	["_"] = ""
}

local gsub_map_2 <const> = {
	["tb"] = ""
}

local memoized <const> = setmetatable({}, {__mode = "vk"}) -- Makes parsing 2x faster. Stays in memory temporarily. Objects will be resurrected, but is eventually collected. Big files will leave memory immediately.
local function parse_ini(...)
	local str <const>, only_one_main <const> = ...
	if memoized[str] then -- Skips parsing entirely if memoized recently
		return memoized[str]
	else
		memoized[str] = {}
	end

	local find <const> = string.find
	local match <const> = string.match
	local gsub <const> = string.gsub
	local tonumber <const> = tonumber
	local remove_special <const> = essentials.remove_special

	local info <const>, current_name, current_table = memoized[str], "\xFF" -- \xFF will never get a match because gmatch ignores this character
	local current_pattern = "\xFF"

	local memoized <const> = {}

	if only_one_main then
		current_table = {is_parent_vehicle = true}
		current_pattern = "^%[.+%]$"
		current_name = "%["
		info[#info + 1] = current_table
	end

	local is_parent_entity_found = false

	for line in str:gmatch("[^\n\r\x80-\xFF]+") do
		if not memoized[line] then
			memoized[line] = {line = true, new_parent_find = true, equal_find = true, nested_parent_find = true} -- These filler entries is twice as fast due to not having to rehash
			memoized[line].line = (find(line, "^[#;]") or find(line, "[^\\][#;]")) and gsub(line, match(line, "[#;]\32?.+$") or "", "") or line -- Removes comments. Partial support for escape sequences. Won't work if comment & escape sequence in same line.
			memoized[line].new_parent_find = find(line, "^%[.+%]$")
			memoized[line].equal_find = find(line, "=", 1, true)
			memoized[line].nested_parent_find = find(line, current_pattern)
		end

		local memoized <const> = memoized[line]
		line = memoized.line

		if memoized.nested_parent_find then
			current_table = {}
			memoized.nested_parent = memoized.nested_parent or match(line, "^"..current_name.."%s*(.-)%]")
			info[#info][memoized.nested_parent] = current_table
		elseif not only_one_main and memoized.new_parent_find then
			current_table = {}
			info[#info + 1] = current_table
			memoized.current_name = memoized.current_name or remove_special(match(line, "^(%[.+)%]$"))
			current_name = memoized.current_name
			current_pattern = "^"..current_name..".+%]$"
			memoized.name_num_brackets_find = memoized.name_num_brackets_find or find(current_name, "^%%%[%d+$")
			memoized.Attached_find = memoized.Attached_find or find(current_name, "^%%%[Attached")
			if line == "[Vehicle]" or (#info == 1 and memoized.name_num_brackets_find) then
				info[#info].is_parent_vehicle = true
				essentials.assert(not is_parent_entity_found, "Attempted to set more than one parent entity.")
				is_parent_entity_found = true
			elseif memoized.Attached_find or memoized.name_num_brackets_find then
				info[#info].IsAttached = true
			end
		elseif memoized.equal_find then
			if memoized.index ~= "" then
				memoized.stupid_format_equal_last_char = memoized.stupid_format_equal_last_char or find(line, "=", -1, true)
				if memoized.stupid_format_equal_last_char then
					line = line:sub(1, -2)
				end
				local value <const> = match(line, "^.+\32*=\32*(.-)$") or "" -- Some formats puts nothing after =.
				memoized.index = match(line, "^(.-)\32*=\32*") or ""
				memoized.value = 
					   tonumber((gsub(value, ".", gsub_map)))
					or tonumber((gsub(value, "..", gsub_map_2)))
					or essentials.cast_value(value, "ini") -- extra () to only fetch first return value of gsub.
			end
			if memoized.index ~= "" then -- In case some format has no name for the value
				current_table[memoized.index] = memoized.value
			end
			if memoized.value == false and (memoized.index == "IsAttached" or memoized.index == "isAttached") then
				info[#info].is_parent_vehicle = true
			end
		else
			memoized.stupid_format_index = memoized.stupid_format_index or match(line, "^([x-z])[%d.-]+$")
			if not current_table[memoized.stupid_format_index] then
				memoized.stupid_format_value = memoized.stupid_format_value or tonumber(match(line, "^[x-z]([%d.-]+)$"))
				if memoized.stupid_format_index and memoized.stupid_format_value then
					current_table[memoized.stupid_format_index] = memoized.stupid_format_value -- Some formats are missing "=" on some of their values.
				end
			end
		end
	end
	return info
end
--[[
	Supports 2 types of inis
	2take1 inis
	Example of other type: Speedy.ini
	Any keys info["key"] is the other type
	Any keys info.key is 2take1.
--]]
local function spawn_type_1_ini(info, network_status)
	info = info[1]
	local entities <const> = {}
	local hash <const> = info["Vehicle"] and info["Vehicle"]["Model"] or info.VEHICLE and info.VEHICLE.hash
	if not streaming.is_model_a_vehicle(hash) then
		essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
		return -1
	end
	local Vehicle

	if network_status == "is_networked" then
		Vehicle = kek_entity.spawn_networked_vehicle(hash, function()
			return kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8), player.get_player_heading(player.player_id())
		end, {
			godmode = false,
			max = false,
			persistent = true
		})
	else
		Vehicle = kek_entity.spawn_local_mission_vehicle(hash, function()
			return kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8), player.get_player_heading(player.player_id())
		end)
	end

	if entity.is_entity_a_vehicle(Vehicle) then
		vehicle.set_vehicle_bulletproof_tires(Vehicle, is_bulletproof)
		kek_entity.set_wheel_type(
			Vehicle, 
			info.VEHICLE and info.VEHICLE.wheelType or info["Vehicle"]["Wheel Type"]
		)
		vehicle.set_vehicle_mod_kit_type(Vehicle, 0)

		for i = 0, 48 do
			if i >= 17 and i <= 22 then
				local mod = info.MODS and info.MODS["mod"..i] == 1
				if mod == nil then
					mod = info["Vehicle"] and info["Vehicle"][tostring(i)] == 1
				end
				vehicle.toggle_vehicle_mod(
					Vehicle, 
					i, 
					mod
				)
			else
				vehicle.set_vehicle_mod(
					Vehicle, 
					i, 
					info.MODS and info.MODS["mod"..i] or info["Vehicle"][tostring(i)], 
					i == 23 or i == 24
				)
			end
		end
		vehicle.set_vehicle_number_plate_index(
			Vehicle, 
			info.VEHICLE and info.VEHICLE.plateIndex or info["Vehicle"]["License Plate Text Index"]
		)

		local plate_text <const> = info.VEHICLE and info.VEHICLE.plate or info["Vehicle"]["License Plate Text"]
		vehicle.set_vehicle_number_plate_text(
			Vehicle, 
			type(plate_text) == "string" and plate_text or "kektram"
		)
		local is_bulletproof = info.VEHICLE and info.VEHICLE.bulletproof == 1
		if is_bulletproof == nil then
			is_bulletproof = info["Vehicle"]["Bullet Proof Tires"]
		end
		vehicle.set_vehicle_extra_colors(
			Vehicle, 
			info.VEHICLE and info.VEHICLE.pearl or info["Vehicle"]["Pearlescent"], 
			info.VEHICLE and info.VEHICLE.wheel or info["Vehicle"]["Wheel Color"]
		)
		vehicle.set_vehicle_tire_smoke_color(
			Vehicle, 
			info.VEHICLE and info.VEHICLE.tyressmoke_r or info["Vehicle"]["Tire Smoke Red"], 
			info.VEHICLE and info.VEHICLE.tyressmoke_g or info["Vehicle"]["Tire Smoke Green"], 
			info.VEHICLE and info.VEHICLE.tyressmoke_b or info["Vehicle"]["Tire Smoke Blue"]
		)
		vehicle.set_vehicle_window_tint(
			Vehicle, 
			info.VEHICLE and info.VEHICLE.windowTint or info["Vehicle"]["Window Tint"]
		)

		if info.VEHICLE then
			local extras <const> = info.EXTRAS
			local info <const> = info.VEHICLE
			if info.spawnInVehicle == 1 then
				ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), Vehicle, -1)
			end
			vehicle.set_vehicle_colors(Vehicle, info.primaryIndex, info.secondaryIndex)
			if info.isPrimaryColorCostum then
				vehicle.set_vehicle_custom_primary_colour(Vehicle, essentials.get_rgb(info.primary_r, info.primary_g, info.primary_b))
			end
			if info.isSecondaryColorCostum then
				vehicle.set_vehicle_custom_secondary_colour(Vehicle, essentials.get_rgb(info.secondary_r, info.secondary_g, info.secondary_b))
			end
			vehicle.set_vehicle_neon_light_enabled(Vehicle, 0, info.neonsLeft == 1 or info.neonLeft == 1)
			vehicle.set_vehicle_neon_light_enabled(Vehicle, 1, info.neonsRight == 1 or info.neonRight == 1)
			vehicle.set_vehicle_neon_light_enabled(Vehicle, 2, info.neonsFront == 1 or info.neonFront == 1)
			vehicle.set_vehicle_neon_light_enabled(Vehicle, 3, info.neonsBack == 1 or info.neonBack == 1)
			vehicle.set_vehicle_neon_lights_color(Vehicle, essentials.get_rgb(info.neon_r, info.neon_g, info.neon_b))
			vehicle.set_vehicle_headlight_color(Vehicle, info.headlightColor)
			local i = 1
			for _, value in pairs(extras) do
				vehicle.set_vehicle_extra(Vehicle, i, value == 0)
				i = i + 1
			end
		else
			local info <const> = info["Vehicle"]
			if info["Primary Red"] ~= 0 or info["Primary Green"] ~= 0 or info["Primary Blue"] ~= 0 then
				vehicle.set_vehicle_custom_primary_colour(Vehicle, essentials.get_rgb(info["Primary Red"], info["Primary Green"], info["Primary Blue"]))
			end
			if info["Secondary Red"] ~= 0 or info["Secondary Green"] ~= 0 or info["Secondary Blue"] ~= 0 then
				vehicle.set_vehicle_custom_secondary_colour(Vehicle, essentials.get_rgb(info["Secondary Red"], info["Secondary Green"], info["Secondary Blue"]))
			end
		end
	end
	return Vehicle
end

--[[
	Supports 1 type of ini.
	Example: Kiborg.ini
	For some reason this type of ini sometimes use "," instead of "." for its numbers.
--]]
local function spawn_type_2_ini(...)
	local info <const>, network_status <const> = ...
	local attached_entities <const> = {}
	local entities <const> = {}
	local parent_entity
	for _, info in pairs(info) do
		local hash <const> = info.Hash or info.hash or type(info.Model) == "table" and info.Model.Hash
		if hash then
			local Entity <const> = spawn_entity(info, entities, network_status)
			if entity.is_entity_a_vehicle(Entity) then
				kek_entity.set_wheel_type(Entity, info.WheelType.Index)
				vehicle.set_vehicle_mod_kit_type(Entity, 0)
				for i = 0, 49 do
					if i >= 17 and i <= 22 then
						if info.Toggles["T"..i] then
							vehicle.toggle_vehicle_mod(Entity, i, info.Toggles["T"..i] == 1)
						end
					else
						if info.Mods["M"..i] then
							vehicle.set_vehicle_mod(Entity, i, info.Mods["M"..i], i == 23 or i == 24)
						end
					end
				end
				for i = 0, 15 do
					if info.Extras["E"..i] then
						vehicle.set_vehicle_extra(Entity, i, not info.Extras["E"..i])
					end
				end
				vehicle.set_vehicle_tire_smoke_color(Entity, info.TireSmoke.R, info.TireSmoke.G, info.TireSmoke.B)
				vehicle.set_vehicle_neon_light_enabled(Entity, 0, info.Neon.Enabled0)
				vehicle.set_vehicle_neon_light_enabled(Entity, 1, info.Neon.Enabled1)
				vehicle.set_vehicle_neon_light_enabled(Entity, 2, info.Neon.Enabled2)
				vehicle.set_vehicle_neon_light_enabled(Entity, 3, info.Neon.Enabled3)
				vehicle.set_vehicle_neon_light_enabled(Entity, 4, info.Neon.Enabled4)
				vehicle.set_vehicle_neon_lights_color(Entity, essentials.get_rgb(info.NeonColor.R, info.NeonColor.G, info.NeonColor.B))
				vehicle.set_vehicle_colors(Entity, info.VehicleColors.Primary, info.VehicleColors.Secondary)
				vehicle.set_vehicle_extra_colors(Entity, info.ExtraColors.Pearl, info.ExtraColors.Wheel)
				vehicle.set_vehicle_brake_lights(Entity, info.BrakeLights)
				vehicle.set_vehicle_indicator_lights(Entity, 0, info.IndicatorRight)
				vehicle.set_vehicle_indicator_lights(Entity, 1, info.IndicatorLeft)
				vehicle.set_vehicle_number_plate_index(Entity, info.Numberplate.Index)
				vehicle.set_vehicle_number_plate_text(Entity, type(info.Numberplate.Text) == "string" and info.Numberplate.Text or "kektram")
				vehicle.set_vehicle_window_tint(Entity, info.WindowTint.Index)
				entity.set_entity_render_scorched(Entity, info.ScorchedRender == true)
				vehicle.set_vehicle_siren(Entity, info.Siren == true)
				if info.IsCustomPrimary.bool then
					vehicle.set_vehicle_custom_primary_colour(Entity, essentials.get_rgb(info.CustomPrimaryColor.R, info.CustomPrimaryColor.G, info.CustomPrimaryColor.B))
				end
				if info.IsCustomSecondary.bool then
					vehicle.set_vehicle_custom_secondary_colour(Entity, essentials.get_rgb(info.CustomSecondaryColor.R, info.CustomSecondaryColor.G, info.CustomSecondaryColor.B))
				end
				if info.IsEngineOn then
					vehicle.set_vehicle_engine_on(Entity, true, true, false)
				end
				if info.TyreBurstLF then
					vehicle.set_vehicle_tire_burst(Entity, 0, true, 1000.0)
				end
				if info.TyreBurstRF then
					vehicle.set_vehicle_tire_burst(Entity, 1, true, 1000.0)
				end
				if info.TyreBurstLM then
					vehicle.set_vehicle_tire_burst(Entity, 2, true, 1000.0)
				end
				if info.TyreBurstRM then
					vehicle.set_vehicle_tire_burst(Entity, 3, true, 1000.0)
				end
				if info.TyreBurstLR then
					vehicle.set_vehicle_tire_burst(Entity, 4, true, 1000.0)
				end
				if info.TyreBurstRR then
					vehicle.set_vehicle_tire_burst(Entity, 5, true, 1000.0)
				end
				if info.TyreBurst6ML then
					vehicle.set_vehicle_tire_burst(Entity, 45, true, 1000.0)
				end
				if info.TyreBurst6MR then
					vehicle.set_vehicle_tire_burst(Entity, 47, true, 1000.0)
				end
				if info.HeadlightMultiplier then
					vehicle.set_vehicle_light_multiplier(Entity, info.HeadlightMultiplier)
				end
				if info.LightsState then
					vehicle.set_vehicle_lights(Entity, info.LightsState)
				end
				if info.Dirt then
					vehicle.set_vehicle_dirt_level(Entity, info.Dirt)
				end
				if info.WindscreenDetached then
					vehicle.pop_out_vehicle_windscreen(Entity)
				end
				if info.PaintFade then
					vehicle.set_vehicle_enveff_scale(Entity, info.PaintFade.PaintFade)
				end
			elseif entity.is_entity_a_ped(Entity) then
				if info.ScenarioPlaying and type(info.ScenarioName) == "string" then
					ai.task_start_scenario_in_place(Entity, info.ScenarioName, 0, true)
				end
				for i = 0, 11 do
					ped.set_ped_component_variation(Entity, i, info["Component"..i], info["Texture"..i], 0)
				end
				if info.BlockFleeing then
					ped.set_ped_combat_attributes(Entity, enums.combat_attributes.CanFightArmedPedsWhenNotArmed, true)
				end
				for name, id in pairs(enums.prop_indices) do -- The list has more than what this ini supports
					if info["Prop"..name] then
						ped.set_ped_prop_index(Entity, id, info["Prop"..name], info["Texture"..name], 0)
					end
				end
			end
			if (info.IsAttached and entity.is_an_entity(Entity)) or (info.is_parent_vehicle and entity.is_entity_a_vehicle(Entity)) then
				entities[info.SelfNumeration or Entity] = Entity
				if info.IsAttached then
					entity.set_entity_collision(Entity, false, false, false)
					entity.freeze_entity(Entity, true)
					attached_entities[Entity] = info
				end
				if streaming.is_model_a_ped(hash) or streaming.is_model_a_vehicle(hash) then
					entity.set_entity_god_mode(Entity, info.Invincible)
				end
				if type(info.Visible) == "boolean" then
					entity.set_entity_visible(Entity, info.Visible)
				end
				if info.Alpha then
					entity.set_entity_alpha(Entity, info.Alpha, true)
				end
				if info.Health then
					entity.set_entity_health(Entity, info.Health, 0)
				end
				if info.Gravity == false then
					entity.set_entity_gravity(Entity, false)
				end
				if info.is_parent_vehicle then
					essentials.assert(not entities.is_parent_vehicle, "Tried to set multiple parent vehicles.")
					parent_entity = Entity
					entities.parent_entity = Entity
					if not streaming.is_model_a_vehicle(hash) then
						essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
						kek_entity.clear_entities(entities)
						return -1
					end
				end
			elseif info.is_parent_vehicle then
				kek_entity.clear_entities(entities)
				return 0
			end		
		end
	end
	for Entity, info in pairs(attached_entities) do
		attach(Entity, info, entities)
	end
	return parent_entity
end


--[[
	Supports 2 very similar ini types.
	Example 1: Mr. Roboto  - By JamezModz.ini
	Example 2: -JamezModz- Mr. Roboto v2.0.ini
--]]
local function spawn_type_3_ini(...)
	local info <const>, network_status <const> = ...
	local attached_entities <const> = {}
	local entities <const> = {}
	for _, info in pairs(info) do
		if info.Model or info.model then
			local Entity <const> = spawn_entity(info, entities, network_status)
			if entity.is_entity_a_vehicle(Entity) and info["tyre smoke red"] then -- info["tyre smoke red"] One of the types doesnt apply any mods to vehicles.
				kek_entity.set_wheel_type(Entity, info["wheel type"])
				vehicle.set_vehicle_mod_kit_type(Entity, 0)
				for i = 0, 48 do
					if i >= 17 and i <= 22 then
						local mod = info.Toggles and info.Toggles[tostring(i)]
						if mod == nil then
							mod = info["toggle "..i]
						end
						if mod ~= nil then
							vehicle.toggle_vehicle_mod(Entity, i, mod == 1)
						end
					else
						local mod <const> = info.Mods and info.Mods[tostring(i)] or info["mod "..i]
						if mod ~= nil then
							vehicle.set_vehicle_mod(Entity, i, mod, i == 23 or i == 24)
						end
					end
				end
				for i = 1, 11 do
					local extra = info.Extras and info.Extras[tostring(i)]
					if extra == nil then
						extra = info["extra "..i]
					end
					if extra ~= nil then
						vehicle.set_vehicle_extra(Entity, i, extra == 0)
					end
				end
				vehicle.set_vehicle_tire_smoke_color(Entity, info["tyre smoke red"], info["tyre smoke green"], info["tyre smoke blue"])
				vehicle.set_vehicle_neon_light_enabled(Entity, 0, info["neon 0"] == 1)
				vehicle.set_vehicle_neon_light_enabled(Entity, 1, info["neon 1"] == 1)
				vehicle.set_vehicle_neon_light_enabled(Entity, 2, info["neon 2"] == 1)
				vehicle.set_vehicle_neon_light_enabled(Entity, 3, info["neon 3"] == 1)
				vehicle.set_vehicle_neon_lights_color(Entity, essentials.get_rgb(info["neon red"], info["neon green"], info["neon blue"]))
				vehicle.set_vehicle_colors(Entity, info["primary paint"], info["secondary paint"])
				vehicle.set_vehicle_extra_colors(Entity, info["pearlescent colour"], info["wheel colour"])
				vehicle.set_vehicle_number_plate_index(Entity, info["plate index"])
				vehicle.set_vehicle_number_plate_text(Entity, type(info["plate text"]) == "string" and info["plate text"] or "kektram")
				vehicle.set_vehicle_window_tint(Entity, info["window tint"])
				vehicle.set_vehicle_dirt_level(Entity, info["dirt level"])
				vehicle.set_vehicle_bulletproof_tires(Entity, info["bulletproof tyres"] == 1)
				if info["custom primary colour"] and info["custom primary colour"] ~= 0 then
					vehicle.set_vehicle_custom_primary_colour(Entity, info["custom primary colour"])
				elseif info["primary red"] and (info["primary red"] ~= 0 or info["primary green"] ~= 0 or  info["primary blue"] ~= 0) then
					vehicle.set_vehicle_custom_primary_colour(Entity, essentials.get_rgb(info["primary red"], info["primary green"], info["primary blue"]))
				end

				if info["custom secondary colour"] and info["custom secondary colour"] ~= 0 then
					vehicle.set_vehicle_custom_secondary_colour(Entity, info["custom secondary colour"])
				elseif info["secondary red"] and (info["secondary red"] ~= 0 or info["secondary green"] ~= 0 or info["secondary blue"] ~= 0) then
					vehicle.set_vehicle_custom_secondary_colour(Entity, essentials.get_rgb(info["secondary red"], info["secondary green"], info["secondary blue"]))
				end

			end
			if (not info.is_parent_vehicle and entity.is_an_entity(Entity)) or (info.is_parent_vehicle and entity.is_entity_a_vehicle(Entity)) then
				if info.IsAttached then
					entity.set_entity_collision(Entity, false, false, false)
					entity.freeze_entity(Entity, true)
					attached_entities[Entity] = info
				elseif info.is_parent_vehicle then
					essentials.assert(not entities.is_parent_vehicle, "Tried to set multiple parent vehicles.")
					entities.parent_entity = Entity
					if not streaming.is_model_a_vehicle(info.Model or info.model) then
						essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
						kek_entity.clear_entities(entities)
						return -1
					end
				end
				entities[Entity] = Entity
			elseif info.is_parent_vehicle then
				kek_entity.clear_entities(entities)
				return 0
			end		
		end
	end
	for Entity, info in pairs(attached_entities) do
		attach(Entity, info, entities)
	end
	return entities.parent_entity
end


--[[
	Supports 2 types of ini.
	Example 1: AircraftCarrierByEinar.ini 
	Example 2: 420car.ini
--]]
local function spawn_type_4_ini(...)
	local info <const>, network_status <const> = ...
	local attached_entities <const> = {}
	local entities <const> = {}
	for _, info in pairs(info) do
		if info.Model or info.model then
			local Entity <const> = spawn_entity(info, entities, network_status)
			if entity.is_entity_a_vehicle(Entity) then
				if not info.IsAttached then -- Mods are only set for parent vehicle
					kek_entity.set_wheel_type(Entity, info.WheelsType or info.Wheels)
					vehicle.set_vehicle_mod_kit_type(Entity, 0)
					for i = 0, 45 do
						if not (i >= 17 and i <= 22) and info[tostring(i)] then -- The file doesnt use every index from 0 to 45.
							if info[tostring(i)] then							
								vehicle.set_vehicle_mod(Entity, i, info[tostring(i)], i == 23 or i == 24)
							end
						end
					end
					for i = 17, 22 do
						if info["TOGGLE_"..i] ~= nil then
							vehicle.toggle_vehicle_mod(Entity, i, info["TOGGLE_"..i] == 1)
						end
					end
					for i = 1, 11 do
						if info["Extra_"..i] ~= nil then
							vehicle.set_vehicle_extra(Entity, i, info["Extra_"..i] == 0) -- Extras want 0 for true for some reason
						end
					end
					vehicle.set_vehicle_tire_smoke_color(Entity, info.SmokeR, info.SmokeG, info.SmokeB)
					if info.NeonEnabled then
						for i = 0, 3 do
							vehicle.set_vehicle_neon_light_enabled(Entity, i, true)
						end
					else
						for i = 1, 4 do 
							vehicle.set_vehicle_neon_light_enabled(Entity, i - 1, info["Neon"..i] == 1)
						end
					end
					vehicle.set_vehicle_neon_lights_color(Entity, essentials.get_rgb(info.NeonR, info.NeonG, info.NeonB))
					vehicle.set_vehicle_colors(Entity, info.PrimaryPaint or info.Primary, info.SecondaryPaint or info.Secondary)
					vehicle.set_vehicle_extra_colors(Entity, info.Pearlescent or info.Pearl, info.WheelsColor or info.WheelColor)
					vehicle.set_vehicle_number_plate_index(Entity, info.PlateIndex or info.Plate or 0) -- Some files don't have this for some reason [or 0]
					vehicle.set_vehicle_number_plate_text(Entity, type(info.PlateText) == "string" and info.PlateText or "kektram")
					vehicle.set_vehicle_window_tint(Entity, info.WindowTint or info.Tint)
					vehicle.set_vehicle_bulletproof_tires(Entity, (info.Bulletproof or info.BulletproofTires) == 1)
					if info.PaintFade then
						vehicle.set_vehicle_enveff_scale(Entity, info.PaintFade)
					end
					if info.Dirt then
						vehicle.set_vehicle_dirt_level(Entity, info.Dirt)
					end
					if info.PrimaryPaintT == 1 then
						vehicle.set_vehicle_custom_primary_colour(Entity, essentials.get_rgb(info.PrimaryR, info.PrimaryG, info.PrimaryB))
					end
					if info.SecondaryPaintT == 1 then
						vehicle.set_vehicle_custom_secondary_colour(Entity, essentials.get_rgb(info.SecondaryR, info.SecondaryG, info.SecondaryB))
					end
				end
			end
			if (not info.is_parent_vehicle and entity.is_an_entity(Entity)) or (info.is_parent_vehicle and entity.is_entity_a_vehicle(Entity)) then
				if info.IsAttached then
					entity.set_entity_collision(Entity, false, false, false)
					entity.freeze_entity(Entity, true)
					attached_entities[Entity] = info
				end

				if info.is_parent_vehicle then
					essentials.assert(not entities.is_parent_vehicle, "Tried to set multiple parent vehicles.")
					entities.parent_entity = Entity
					if not streaming.is_model_a_vehicle(info.Model or info.model) then
						essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
						kek_entity.clear_entities(entities)
						return -1
					end
				end
				entities[Entity] = Entity
			elseif info.is_parent_vehicle then
				kek_entity.clear_entities(entities)
				return 0
			end		
		end
	end
	for Entity, info in pairs(attached_entities) do
		attach(Entity, info, entities)
	end
	return entities.parent_entity
end


--[[
	Supports 1 type of ini.
	Example: DeLoreanByEinar.ini
--]]
local function spawn_type_5_ini(...)
	local info <const>, network_status <const> = ...
	local attached_entities <const> = {}
	local entities <const> = {}
	for _, info in pairs(info) do
		if info.Model or info.model then
			local Entity <const> = spawn_entity(info, entities, network_status)
			if (not info.is_parent_vehicle and entity.is_an_entity(Entity)) or (info.is_parent_vehicle and entity.is_entity_a_vehicle(Entity)) then
				if info.IsAttached then
					entity.set_entity_collision(Entity, false, false, false)
					entity.freeze_entity(Entity, true)
					info.X = info.X - entities.parent_entity_info.X
					info.Y = info.Y - entities.parent_entity_info.Y
					info.Z = info.Z - entities.parent_entity_info.Z
					attached_entities[Entity] = info
				end
				if info.is_parent_vehicle then
					essentials.assert(not entities.is_parent_vehicle, "Tried to set multiple parent vehicles.")
					entities.parent_entity = Entity
					entities.parent_entity_info = info
					if not streaming.is_model_a_vehicle(info.Model or info.model) then
						essentials.msg(lang["Failed to spawn vehice. Driver vehicle was an invalid model hash."], "red", true, 6)
						kek_entity.clear_entities(entities)
						return -1
					end
				end
				entities[Entity] = Entity
			elseif info.is_parent_vehicle then
				kek_entity.clear_entities(entities)
				return 0
			end				
		end
	end
	for Entity, info in pairs(attached_entities) do
		attach(Entity, info, entities)
	end
	return entities.parent_entity
end

function menyoo.spawn_ini_vehicle(...)
	local file_path <const> = ...
	local str <const> = essentials.get_file_string(file_path)
	if str:find("?xml", 1, true) and str:find("Spooner", 1, true) then
		essentials.msg(lang["Tried to spawn a xml vehicle with ini spawner."], "red", true, 6)
		return 0
	end
	local parent_entity
	local ini_type <const> = get_ini_type(str)
	local ini_parse <const> = parse_ini(
		str, 
		ini_type == "type_1" or ini_type == "type_2b"
	)
	local counts <const> = get_entity_counts_from_ini_parse(ini_parse) -- Parent vehicle is accounted for without manually incrementing
	local network_status <const> = 
		counts.object <= network.get_max_num_network_objects() - #kek_entity.get_net_objects() 
		and counts.ped <= network.get_max_num_network_peds() - #kek_entity.get_net_peds() 
		and counts.vehicle <= get_max_networked_vehicles() - #kek_entity.get_net_vehicles()
		and "is_networked" or "is_not_networked"

	if is_spawn_too_many_entities(counts, network_status) then
		return 0
	end	

	if ini_type == "type_1" then
		parent_entity = spawn_type_1_ini(ini_parse, network_status)
	elseif ini_type == "type_2a" or ini_type == "type_2b" then
		parent_entity = spawn_type_2_ini(ini_parse, network_status)
	elseif ini_type == "type_3" or ini_type == "type_6" then
		parent_entity = spawn_type_3_ini(ini_parse, network_status)
	elseif ini_type == "type_4" then
		parent_entity = spawn_type_4_ini(ini_parse, network_status)
	elseif ini_type == "type_5" then
		parent_entity = spawn_type_5_ini(ini_parse, network_status)
	else
		essentials.msg(lang["Unsupported file format."], "red", true)
		return 0
	end
	if parent_entity and entity.is_entity_a_vehicle(parent_entity) then
		entity.set_entity_rotation(parent_entity, memoize.v3())
		kek_entity.set_entity_heading(parent_entity, player.get_player_heading(player.player_id()))
	elseif parent_entity ~= -1 then
		essentials.msg(lang["Failed to spawn driver vehicle for unknown reason."], "red", true, 6)
	end

	send_spawn_counter_msg(counts)
	send_is_networked_msg(counts, network_status)
	return parent_entity or 0
end
return essentials.const_all(menyoo)