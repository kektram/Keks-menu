-- Copyright © 2020-2021 Kektram

kek_menu.lib_versions["Menyoo spawner"] = "2.0.1"

local xml_end = {
	"^%s*</Attachment>$",
	"^%s*</Placement>$"
}

local xml_start = {
	"^%s*<Attachment>$",
	"^%s*<Placement>$"
}

local menyoo = {}
local home <const> = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"

local essentials = kek_menu.require("Essentials")
local kek_entity = kek_menu.require("Kek's entity functions")
local custom_upgrades = kek_menu.require("Custom upgrades")
local location_mapper = kek_menu.require("Location mapper")
local weapon_mapper = kek_menu.require("Weapon mapper")
local vehicle_saver = kek_menu.require("Vehicle saver")

local lang = kek_menu.lang

-- Utilities
	local function new_attachment_check(...)
		local str,
		End <const>,
		initial <const> = ...
		str = str or ""
		if initial then
			return str:find(initial, 1, true)
		elseif End then
			return str:find(xml_end[1]) or str:find(xml_end[2])
		else
			return str:find(xml_start[1]) or str:find(xml_start[2])
		end
	end

	local function extract_info(...)
		local file <const>, initial <const> = ...
		local str = ""
		local info = {}
		local tree_parent = ""
		while str and not new_attachment_check(str, true, initial) do
			if str:find("<Attachment%s*isAttached=[%w%p]+/*>") then
				info[str:match("%s*([%w%p]+)=")] = str:match("<Attachment%s*isAttached=(.+)/*>") == "\"true\""
			else
				local property <const> = str:match("<.+>(.*)<.+>")
				if property and not new_attachment_check(str, true, initial) then
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
				and not str:match("^%s*<(.+)>.*<.+>%s*$") 
				and str:match("^%s*<([%p%w%c]+)>%s*$")  
				and not new_attachment_check(str, true, initial) then
					tree_parent = str:match("^%s*<([%p%w%c]+)>%s*$")
				end
				if str:match("^%s*</(.+)>%s*$") then
					tree_parent = ""
				end
			end
			str = essentials.file(file, "read", "*l")
			essentials.random_wait(2500)
		end
		return info
	end

	local function apply_entity_modifications(...)
		local Entity <const>,
		info <const>, 
		entities <const>,
		pid <const> = ...
		if entity.is_an_entity(Entity or 0) then
			if streaming.is_model_a_vehicle(entity.get_entity_model_hash(Entity)) then
				vehicle.set_vehicle_mod_kit_type(Entity, 0)
				for i = 0, 48 do
					local setting = info["Mods_"..i]
					if type(setting) == "table" then
						setting = setting[1]
					elseif type(setting) == "boolean" then
						vehicle.toggle_vehicle_mod(Entity, i, setting)
					end
				end
				if type(info["TorqueMultiplier"]) == "number" and info["TorqueMultiplier"] ~= 1 then
					custom_upgrades.torque_modifier(Entity, info["TorqueMultiplier"])
				end
				if type(info["RpmMultiplier"]) == "number" and info["RpmMultiplier"] ~= 1 then
					vehicle.modify_vehicle_top_speed(Entity, info["RpmMultiplier"] * 100)
					entity.set_entity_max_speed(Entity, 540 * info["RpmMultiplier"])
				end
				if math.type(info["ColoursPearl"]) == "integer" and math.type(info["ColoursRim"]) == "integer" then
					vehicle.set_vehicle_extra_colors(Entity, info["ColoursPearl"], info["ColoursRim"])
				end
				if math.type(info["ColoursPrimary"]) == "integer" and math.type(info["ColoursSecondary"]) == "integer" then
					vehicle.set_vehicle_colors(Entity, info["ColoursPrimary"], info["ColoursSecondary"])
					if info["ColoursIsPrimaryColourCustom"] then
						vehicle.set_vehicle_custom_primary_colour(Entity, info["ColoursPrimary"])
						vehicle.set_vehicle_custom_pearlescent_colour(Entity, info["ColoursPearl"])
					end
					if info["ColoursIsSecondaryColourCustom"] then
						vehicle.set_vehicle_custom_secondary_colour(Entity, info["ColoursSecondary"])
					end
				end
				if math.type(info["ColourstyreSmoke_R"]) == "integer" 
				and math.type(info["ColourstyreSmoke_G"]) == "integer" 
				and math.type(info["ColourstyreSmoke_B"]) == "integer" then
					vehicle.set_vehicle_tire_smoke_color(Entity, info["ColourstyreSmoke_R"], info["ColourstyreSmoke_G"], info["ColourstyreSmoke_B"])
				end
				if type(info["NumberPlateText"]) == "string" then
					vehicle.set_vehicle_number_plate_text(Entity, info["NumberPlateText"])
				end
				if math.type(info["NumberPlateIndex"]) == "integer" then
					vehicle.set_vehicle_number_plate_index(Entity, info["NumberPlateIndex"])
				end
				if math.type(info["WheelType"]) == "integer" then
					vehicle.set_vehicle_wheel_type(Entity, info["WheelType"])
				end
				if math.type(info["WindowTint"]) == "integer" then
					vehicle.set_vehicle_window_tint(Entity, info["WindowTint"])
				end
				vehicle.set_vehicle_bulletproof_tires(Entity, info["BulletProofTyres"] == true)
				vehicle.set_vehicle_engine_on(Entity, info["EngineOn"] == true, true, false)
				if type(info["EngineHealth"]) == "number" then
					vehicle.set_vehicle_engine_health(Entity, info["EngineHealth"])
				end
				vehicle.set_vehicle_neon_light_enabled(Entity, 0, info["NeonsLeft"] == true)
				vehicle.set_vehicle_neon_light_enabled(Entity, 1, info["NeonsRight"] == true)
				vehicle.set_vehicle_neon_light_enabled(Entity, 2, info["NeonsFront"] == true)
				vehicle.set_vehicle_neon_light_enabled(Entity, 3, info["NeonsBack"] == true)
				if math.type(info["NeonsR"]) == "integer" 
				and math.type(info["NeonsG"]) == "integer" 
				and math.type(info["NeonsB"]) == "integer" then
					vehicle.set_vehicle_neon_lights_color(Entity, info["NeonsR"] * info["NeonsG"] * info["NeonsB"])
				end
				if math.type(info["Livery"]) == "integer" and info["Livery"] ~= -1 then
					vehicle.set_vehicle_livery(Entity, info["Livery"])
				end
				if type(info["DoorsOpenFrontLeftDoor"]) == true then
					vehicle.set_vehicle_door_open(Entity, 0, info["DoorsOpenFrontLeftDoor"], info["DoorsOpenFrontLeftDoor"])
				end
				if type(info["DoorsOpenFrontRightDoor"]) == true then
					vehicle.set_vehicle_door_open(Entity, 1, info["DoorsOpenFrontRightDoor"], info["DoorsOpenFrontRightDoor"])
				end
				if type(info["DoorsOpenBackLeftDoor"]) == true then
					vehicle.set_vehicle_door_open(Entity, 2, info["DoorsOpenBackLeftDoor"], info["DoorsOpenBackLeftDoor"])
				end
				if type(info["DoorsOpenBackRightDoor"]) == true then
					vehicle.set_vehicle_door_open(Entity, 3, info["DoorsOpenBackRightDoor"], info["DoorsOpenBackRightDoor"])
				end
				if type(info["DoorsOpenHood"]) == true then
					vehicle.set_vehicle_door_open(Entity, 4, info["DoorsOpenHood"], info["DoorsOpenHood"])
				end
				if type(info["DoorsOpenTrunk"]) == true then
					vehicle.set_vehicle_door_open(Entity, 5, info["DoorsOpenTrunk"], info["DoorsOpenTrunk"])
				end
				if type(info["DoorsOpenTrunk2"]) == true then
					vehicle.set_vehicle_door_open(Entity, 6, info["DoorsOpenTrunk2"], info["DoorsOpenTrunk2"])
				end
				if info["TyresBurstedFrontLeft"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 0, true, 1000)
				end
				if info["TyresBurstedFrontRight"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 1, true, 1000)
				end
				if info["TyresBursted_2"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 2, true, 1000)
				end
				if info["TyresBursted_3"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 3, true, 1000)
				end
				if info["TyresBurstedBackLeft"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 4, true, 1000)
				end
				if info["TyresBurstedBackRight"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 5, true, 1000)
				end
				if info["TyresBursted_6"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 45, true, 1000)
				end
				if info["TyresBursted_7"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 47, true, 1000)
				end
				if info["TyresBursted_8"] == true then
					vehicle.set_vehicle_tire_burst(Entity, 8, true, 1000)
				end
				if type(info["WheelsRenderSize"]) == "number" then
					vehicle.set_vehicle_wheel_render_size(Entity, info["WheelsRenderSize"])
				end
				if type(info["WheelsRenderWidth"]) == "number" then
					vehicle.set_vehicle_wheel_render_width(Entity, info["WheelsRenderWidth"])
				end
				if math.type(info["LandingGearState"]) == "integer" then
					vehicle.control_landing_gear(Entity, info["LandingGearState"])
				end
				if info["ReducedGrip"] == true then
					vehicle.set_vehicle_reduce_grip(Entity, true)
				end
				if math.type(info["MaxGear"]) == "integer" then
					vehicle.set_vehicle_max_gear(Entity, info["MaxGear"])
				end
				if math.type(info["CurrentGear"]) == "integer" then
					vehicle.set_vehicle_current_gear(Entity, info["CurrentGear"])
				end
				if math.type(info["WheelsCount"]) == "integer" then
					for i = 0, info["WheelsCount"] - 1 do
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
			elseif streaming.is_model_a_ped(entity.get_entity_model_hash(Entity)) then
				local t = 0
				if info["IsStill"] == true then
					t = 1
				end
				ped.set_ped_config_flag(Entity, 301, t)
				local t = 1
				if info["CanRagdoll"] == true then
					t = 0
				end
				ped.set_ped_config_flag(Entity, 104, t)
				if math.type(info["CurrentWeapon"]) == "integer" and info["CurrentWeapon"] ~= 2725352035 then
					weapon.give_delayed_weapon_to_ped(Entity, info["CurrentWeapon"], 0, 1)
					weapon_mapper.set_ped_weapon_attachments(Entity, true, info["CurrentWeapon"])
					kek_entity.set_combat_attributes(Entity, false, true)
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
				if math.type(info["HairColor"]) == "integer" and math.type(info["HairHighlightColor"]) == "integer" then
					ped.set_ped_hair_colors(Entity, info["HairColor"], info["HairHighlightColor"])
				end
				if math.type(info["EyeColor"]) == "integer" then
					ped.set_ped_eye_color(Entity, info["EyeColor"])
				end
				if math.type(info["BlendDatashape_first"]) == "integer"
				and math.type(info["BlendDatashape_second"]) == "integer"
				and math.type(info["BlendDatashape_third"]) == "integer"
				and math.type(info["BlendDataskin_first"]) == "integer"
				and math.type(info["BlendDataskin_second"]) == "integer"
				and math.type(info["BlendDataskin_third"]) == "integer"
				and type(info["BlendDatamix_shape"]) == "number"
				and type(info["BlendDatamix_skin"]) == "number"
				and type(info["BlendDatamix_third"]) == "number" then
					ped.set_ped_head_blend_data(Entity, 
						info["BlendDatashape_first"], 
						info["BlendDatashape_second"],
						info["BlendDatashape_third"],
						info["BlendDataskin_first"],
						info["BlendDataskin_second"],
						info["BlendDataskin_third"],
						info["BlendDatamix_shape"],
						info["BlendDatamix_skin"],
						info["BlendDatamix_third"]
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
				if type(info["RelationshipGroupAltered"]) == true and math.type(info["RelationshipGroup"]) == "integer" then
					ped.set_ped_relationship_group_hash(Entity, info["RelationshipGroup"])
				end
				if type(info["MaxHealth"]) == "number" then
					ped.set_ped_max_health(Entity, info["MaxHealth"])
				end
				if type(info["Health"]) == "number" then
					ped.set_ped_health(Entity, info["Health"])
				end
				if math.type(info["PedVehicleSeat"]) == "integer"
				and info["PedVehicleSeat"] ~= -2
				and math.type(entities[info["AttachedTo"]]) == "integer" 
				and entity.is_an_entity(entities[info["AttachedTo"]]) then
					ped.set_ped_into_vehicle(Entity, entities[info["AttachedTo"]], info["PedVehicleSeat"])
					if info["Seat"] == -1 then
						ai.task_vehicle_drive_wander(Entity, entities[info["AttachedTo"]], 150, kek_menu.settings["Drive style"])
					end
				end
			elseif pid == player.player_id() 
				and entity.get_entity_model_hash(Entity) == 3084738513 
				and info["isAttached"] 
				and entities[info["AttachedTo"]] then
					local offset = v3()
				if type(info["X"]) == "number" then
					offset.x = info["X"]
				end
				if type(info["Y"]) == "number" then
					offset.y = info["Y"]
				end
				if type(info["Z"]) == "number" then
					offset.z = info["Z"]
				end
				custom_upgrades.vehicle_turret(entities[info["AttachedTo"]], Entity, offset)
			end
			if info["IsFireProof"] == true then
				custom_upgrades.immune_to_fire(Entity)
			end
			if type(info["OpacityLevel"]) == "number" then
				entity.set_entity_alpha(Entity, info["OpacityLevel"], 1)
			end
			if info["IsVisible"] == false then
				entity.set_entity_visible(Entity, false)
			end
			if info["HasGravity"] == false then
				entity.set_entity_gravity(Entity, false)
			end
			if info["IsOnFire"] then
				fire.start_entity_fire(Entity)
			end
			entity.set_entity_god_mode(Entity, info["IsInvincible"] == true)
			entity.freeze_entity(Entity, info["FrozenPos"] == true)
		end
	end

	local function attach(...)
		local Entity <const>,
		info <const>,
		entities <const> = ...
		if info["isAttached"] and (math.type(info["PedVehicleSeat"]) ~= "integer" or info["PedVehicleSeat"] == -2) and entity.is_an_entity(Entity or 0) and entity.is_an_entity(entities[info["AttachedTo"]] or 0) then
			local rot = v3()
			local offset = v3()
			if type(info["X"]) == "number" then
				offset.x = info["X"]
			end
			if type(info["Y"]) == "number" then
				offset.y = info["Y"]
			end
			if type(info["Z"]) == "number" then
				offset.z = info["Z"]
			end
			if type(info["Pitch"]) == "number" then
				rot.x = info["Pitch"]
			end
			if type(info["Roll"]) == "number" then
				rot.y = info["Roll"]
			end
			if type(info["Yaw"]) == "number" then
				rot.z = info["Yaw"]
			end
			if math.type(info["BoneIndex"]) ~= "integer" then
				info["BoneIndex"] = 0
			end
			entity.attach_entity_to_entity(Entity, entities[info["AttachedTo"]], info["BoneIndex"], offset, rot, false, info["IsCollisionProof"] == false, info["Type"] == 1, 0, true)
		end
	end

	local function spawn_vehicle(...)
		local file <const>,
		entities <const>,
		pid <const>,
		parent_entity <const> = ...
		local info <const> = extract_info(file)
		local hash <const> = info["ModelHash"]
		local Entity <const> = kek_menu.spawn_entity(hash, function()
			return player.get_player_coords(player.player_id()) + v3(-50, 0, 30), 0
		end, false, false, false, 4, true, nil, info["Dynamic"] == false)
		if not entity.is_an_entity(Entity) then
			return entities, hash
		end
		if math.type(info["AttachedTo"]) ~= "integer" then
			info["AttachedTo"] = parent_entity
			entities[info["AttachedTo"]] = parent_entity
		end
		entities[info["InitialHandle"]] = Entity
		apply_entity_modifications(Entity, info, entities, pid)
		if info["isAttached"] then
			attach(Entity, info, entities)
		end
		return entities, hash
	end
	
	local function spawn_map_object(...)
		local file <const>,
		entities <const>,
		pid <const> = ...
		local info <const> = extract_info(file)
		local hash <const> = info["ModelHash"]
		if type(info["PositionRotationX"]) == "number" and type(info["PositionRotationY"]) == "number" and type(info["PositionRotationZ"]) == "number" then
			local Entity <const> = kek_menu.spawn_entity(hash, function()
				return player.get_player_coords(player.player_id()) + v3(0, 0, 50), 0
			end, false, true, false, 4, true, 0.6, info["Dynamic"] == false, true)
			entities[info["InitialHandle"]] = Entity
			apply_entity_modifications(Entity, info, entities, pid)
			if info["isAttached"] then
				attach(Entity, info, entities)
			elseif type(info["PositionRotationPitch"]) == "number" and type(info["PositionRotationRoll"]) == "number" and type(info["PositionRotationYaw"]) == "number" then
				entity.set_entity_rotation(Entity, v3(info["PositionRotationPitch"], info["PositionRotationRoll"], info["PositionRotationYaw"]))
				entity.set_entity_coords_no_offset(Entity, v3(info["PositionRotationX"], info["PositionRotationY"], info["PositionRotationZ"]))
			end
		end
		return entities, hash
	end

function menyoo.spawn_custom_vehicle(...)
	local file_path <const>,
	pid <const>,
	teleport <const> = ...
	if not player.is_player_valid(pid) then
		return 0, {}
	end
	if not file_path:find("%.xml$") then
		essentials.msg("["..lang["File name §"]..": "..tostring(file_path:match("\\.+\\(.-)%..+$")).."]: "..lang["Wrong file extension. §"], 6, true, 8)
		return 0, {}
	end
	local parent_entity, entities, file = 0, {}
	local hashes = {}
	local info = {}
	if utils.file_exists(file_path) then
		file = io.open(file_path)
		local str2 <const> = essentials.file(file, "read", "*l")
		local str = essentials.file(file, "read", "*l")
		if not str or str == "" then
			essentials.file(file, "close")
			essentials.msg("["..lang["File name §"]..": "..tostring(file_path:match("\\.+\\(.-)%.xml$")).."]: "..lang["Xml file is empty. §"], 6, true, 8)
			return 0, {}
		end
		if not str2:lower():find("?xml version=\"1.0\"", 1, true) or str:lower():find("map", 1, true) then
			essentials.msg(lang["Unsupported file format. §"], 6, true)
			essentials.file(file, "close")
			return 0, {}
		end
		info = extract_info(file, "SpoonerAttachments")
		parent_entity = kek_menu.spawn_entity(info["ModelHash"] or 0, function()
			return player.get_player_coords(player.player_id()) + v3(-50, 0, 30), player.get_player_heading(pid)
		end, false, false, false, 4, true, nil, info["Dynamic"] == false)
		kek_entity.max_car(parent_entity, true)
		if entity.is_an_entity(parent_entity) then
			hashes[#hashes + 1] = info["ModelHash"]
			entities[info["InitialHandle"] or 0] = parent_entity
			apply_entity_modifications(parent_entity, info, entities, pid)
			entity.freeze_entity(parent_entity, true)
		else
			return 0, {}
		end
		str = ""
		while str do
			essentials.random_wait(2500)
			if new_attachment_check(str) then
				local tabs <const> = str:match("^(%s*)[%w%p]+")
				xml_end = {
					"^"..tabs.."</Attachment>$",
					"^"..tabs.."</Placement>$"
				}
				xml_start = {
					"^"..tabs.."<Attachment>$",
					"^"..tabs.."<Placement>$"
				}
				entities, hashes[#hashes + 1] = spawn_vehicle(file, entities, pid, parent_entity)
			end
			str = essentials.file(file, "read", "*l")
		end
		entity.freeze_entity(parent_entity, info["FrozenPos"] == true)
		for i, hash in pairs(hashes) do
			streaming.set_model_as_no_longer_needed(hash)
		end
		essentials.file(file, "close")
		if teleport then
			kek_entity.teleport(parent_entity, location_mapper.get_most_accurate_position(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 8)))
		end
	else
		essentials.msg(lang["Couldn't find file §"], 6, true)
	end
	return parent_entity, entities
end

function menyoo.spawn_map(...)
	local file_path <const>,
	pid <const>,
	teleport_to_map <const> = ...
	if not player.is_player_valid(pid) then
		return 0, {}
	end
	if not file_path:find("%.xml$") then
		essentials.msg("["..lang["File name §"]..": "..tostring(file_path:match("\\.+\\(.-)%..+$")).."]: "..lang["Wrong file extension. §"], 6, true, 8)
		return 0, {}
	end
	local entities = {}
	if utils.file_exists(file_path) then
		local hashes = {}
		local file <close> = io.open(file_path)
		local str = essentials.file(file, "read", "*l")
		if not str or str == "" then
			essentials.msg("["..lang["File name §"]..": "..tostring(file_path:match("\\.+\\(.-)%.xml$")).."]: "..lang["Xml file is empty. §"], 6, true, 8)
			return 0, {}
		end
		if not str:lower():find("?xml version=\"1.0\"", 1, true) then
			essentials.msg(lang["Unsupported file format. §"], 6, true)
			return 0, {}
		end
		local reference_pos
		repeat
			if str:find("<ReferenceCoords>", 1, true) then
				local x <const> = tonumber((essentials.file(file, "read", "*l") or ""):match(">(.-)<"))
				local y <const> = tonumber((essentials.file(file, "read", "*l") or ""):match(">(.-)<"))
				local z <const> = tonumber((essentials.file(file, "read", "*l") or ""):match(">(.-)<"))
				essentials.file(file, "read", "*l")
				str = essentials.file(file, "read", "*l")
				if type(x) == "number" and type(y) == "number" and type(z) == "number" then
					reference_pos = v3(x, y, z)
				end
			end
			str = essentials.file(file, "read", "*l")
		until new_attachment_check(str)
		while str do
			essentials.random_wait(2500)
			if new_attachment_check(str) then
				local tabs <const> = str:match("^(%s*)[%w%p]+")
				xml_end = {
					"^"..tabs.."</Attachment>$",
					"^"..tabs.."</Placement>$"
				}
				xml_start = {
					"^"..tabs.."<Attachment>$",
					"^"..tabs.."<Placement>$"
				}
				entities, hashes[#hashes + 1] = spawn_map_object(file, entities, pid)
			end
			str = essentials.file(file, "read", "*l")
		end
		for i, hash in pairs(hashes) do
			streaming.set_model_as_no_longer_needed(hash)
		end
		if teleport_to_map then
			if reference_pos then
				kek_entity.teleport(essentials.get_most_relevant_entity(pid), reference_pos)
			else
				for handle, Entity in pairs(entities) do
					if entity.is_an_entity(Entity) then
						kek_entity.teleport(essentials.get_most_relevant_entity(pid), entity.get_entity_coords(Entity))
						break
					end
				end
			end
		end
	else
		essentials.msg(lang["Couldn't find file §"], 6, true)
	end
	return entities
end

function menyoo.clone_vehicle(...)
	local Vehicle = ...
	if entity.is_an_entity(Vehicle) then
		Vehicle = kek_entity.get_parent_of_attachment(Vehicle)
		local num <const> = math.random(-10^10, 10^10)
		vehicle_saver.save_vehicle(Vehicle, home.."scripts\\kek_menu_stuff\\kekMenuData\\temp_vehicle"..num..".xml")
		local car <const> = menyoo.spawn_custom_vehicle(home.."scripts\\kek_menu_stuff\\kekMenuData\\temp_vehicle"..num..".xml", player.player_id(), true)
		io.remove(home.."scripts\\kek_menu_stuff\\kekMenuData\\temp_vehicle"..num..".xml")
		return car
	end
	return 0
end

return menyoo