-- Kek's menu version 0.4.8.0 beta 14
-- Copyright © 2020-2022 Kektram
if __kek_menu_version then 
	menu.notify("Kek's menu is already loaded!", "Initialization cancelled.", 3, 0xff0000ff) 
	return
end

__kek_menu_version = "0.4.8.0 beta 14"
__kek_menu_debug_mode = false
__kek_menu_participate_in_betas = false
__kek_menu_check_for_updates = false

menu.create_thread(function()

do -- Prevents crashes from messages, primarily error messages, when they contain invalid utf8 bytes.
	local function check_msg_valid(message) 
	--[[
		Attempting to use https://en.wikipedia.org/wiki/Mao_Zedong as a message, getting the string via utils.from_clipboard, causes crash.
		Most concerning would be grabbing data from files. There could be all kinds of corruption.
		This will apply to all scripts loaded.
		If these wrappers cause problems with your script, please report it.
	--]]
		if message and not utf8.len(message) then
			message = message:gsub("[\0-\x7F\xC2-\xFD][\x80-\xBF]+", "")
			message = message:gsub("[\x80-\xFF]", "")
		end
		return message
	end

	local newindex <const> = getmetatable(menu).__newindex
	local original <const> = menu.notify
	getmetatable(menu).__newindex = nil
	menu.notify = function(message, title, seconds, color)
		original(check_msg_valid(message), title, seconds, color)
	end
	getmetatable(menu).__newindex = newindex

	local original <const> = error
	error = function(message, level)
		if type(message) ~= "number" and type(message) ~= "string" then
			original("Error message must be a number or a string.", (level and level + 1 or 2))
		end
		original(check_msg_valid(message).."\nIf you see this error, check the full traceback. Kek's menu wraps the error, assert and notify function to fix certain crashes.", (level and level + 1 or 2))
	end

	local original <const> = assert
	assert = function(condition, message)
		if not condition then -- Done like this to not have to concatenate unless needed
			print("If you see this error, check the full traceback. Kek's menu wraps the error, assert and notify function to fix certain crashes.")
		end
		return original(condition, check_msg_valid(message))
	end
end

local paths <const> = {
	home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"
}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"
paths.kek_menu_data = paths.kek_menu_stuff.."kekMenuData"
paths.kek_menu_logs = paths.kek_menu_stuff.."kekMenuLogs"
paths.blacklist = paths.kek_menu_stuff.."kekMenuLogs\\Blacklist.log"
paths.player_history_all_players = paths.kek_menu_stuff.."kekMenuLogs\\All players.log"
paths.kek_settings = paths.kek_menu_stuff.."keksettings.ini"
paths.clever_bot = paths.kek_menu_stuff.."kekMenuData\\Clever bot.ini"
paths.chat_spam_text = paths.kek_menu_stuff.."kekMenuData\\Spam text.txt"
paths.chat_bot = paths.kek_menu_stuff.."kekMenuData\\Kek's chat bot.txt"
paths.chat_judger = paths.kek_menu_stuff.."kekMenuData\\custom_chat_judge_data.txt"
paths.debugger = paths.kek_menu_stuff.."kekMenuLibs\\Debugger.lua"
paths.ini_vehicles = paths.home.."scripts\\Ini vehicles"
paths.menyoo_vehicles = paths.home.."scripts\\Menyoo vehicles"
paths.menyoo_maps = paths.home.."scripts\\Menyoo maps"

if not (package.path or ""):find(paths.kek_menu_stuff.."kekMenuLibs\\?.lua;", 1, true) then
	package.path = paths.kek_menu_stuff.."kekMenuLibs\\?.lua;"..package.path
end

if utils.file_exists(paths.kek_settings) 
and utils.file_exists(paths.debugger) then
	local file = io.open(paths.kek_settings)
	if file then
		local str <const> = file:read("*a")
		file:close()
		if str:match("Debug mode=(%a%a%a%a)") == "true" then
			__kek_menu_debug_mode = true
			dofile(paths.debugger)
		end
		if str:match("Participate in betas=(%a%a%a%a)") == "true" then
			__kek_menu_participate_in_betas = true
		end
		if str:match("Check for updates=(%a%a%a%a)") == "true" then
			__kek_menu_check_for_updates = true
		end
	end
else
	local file <const> = io.open(paths.kek_settings, "w+")
	file:close()
end

collectgarbage("incremental", 110, 100)
math.randomseed(math.floor(os.clock()) + os.time())

local u <const> = {}
local player_feat_ids <const> = {}

do -- Makes sure each library is loaded once and that every time one is required, has the same environment as the others
	local original_require <const> = require
	require = function(...)
		local name <const> = ...
		local lib = package.loaded[name] or original_require(name)
		if not lib then
			menu.notify(string.format("Failed to load %s.", name), "Error", 6, 0xff0000ff)
			local err <const> = select(2, loadfile(paths.kek_menu_stuff.."kekMenuLibs\\"..name..".lua")) -- 2take1's custom require function doesn't let you obtain error.
			print(err)
			error(err or "Unknown error during loading of "..name..".")
		end
		if not package.loaded[name] then
			package.loaded[name] = lib
		end
		return package.loaded[name]
	end

	for name, version in pairs({
		["Kek's Language"] = "1.0.0",
		["Kek's Settings"] = "1.0.2",
		["Kek's Essentials"] = "1.5.0",
		["Kek's Memoize"] = "1.0.1",
		["Kek's Enums"] = "1.0.5",
		["Kek's Vehicle mapper"] = "1.3.9", 
		["Kek's Ped mapper"] = "1.2.7",
		["Kek's Object mapper"] = "1.2.7", 
		["Kek's Globals"] = "1.3.5",
		["Kek's Weapon mapper"] = "1.0.5",
		["Kek's Location mapper"] = "1.0.2",
		["Kek's Keys and input"] = "1.0.7",
		["Kek's Drive style mapper"] = "1.0.4",
		["Kek's Menyoo spawner"] = "2.2.5",
		["Kek's entity functions"] = "1.2.7",
		["Kek's trolling entities"] = "1.0.7",
		["Kek's Custom upgrades"] = "1.0.2",
		["Kek's Admin mapper"] = "1.0.4",
		["Kek's Menyoo saver"] = "1.0.9",
		["Kek's Natives"] = "1.0.1"
	}) do
		if not utils.file_exists(paths.kek_menu_stuff.."kekMenuLibs\\"..name..".lua") then
			menu.notify(string.format("%s [%s]", package.loaded["Kek's Language"].lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu."], name), "Kek's "..__kek_menu_version, 6, 0xff0000ff)
			error(package.loaded["Kek's Language"].lang["You're missing a file in kekMenuLibs. Please reinstall Kek's menu."])
		else
			require(name)
		end
		if package.loaded[name].version ~= version then
			menu.notify(string.format("%s [%s]", package.loaded["Kek's Language"].lang["There's a library file which is the wrong version, please reinstall kek's menu."], name), "Kek's "..__kek_menu_version, 6, 0xff0000ff)
			error(package.loaded["Kek's Language"].lang["There's a library file which is the wrong version, please reinstall kek's menu."])
		end
	end
	require = original_require
end

local language <const> = package.loaded["Kek's Language"]
local settings <const> = package.loaded["Kek's Settings"]
local lang <const> = language.lang
local essentials <const> = package.loaded["Kek's Essentials"]
local memoize <const> = package.loaded["Kek's Memoize"]
local enums <const> = package.loaded["Kek's Enums"]
local weapon_mapper <const> = package.loaded["Kek's Weapon mapper"]
local location_mapper <const> = package.loaded["Kek's Location mapper"]
local keys_and_input <const> = package.loaded["Kek's Keys and input"]
local drive_style_mapper <const> = package.loaded["Kek's Drive style mapper"]
local globals <const> = package.loaded["Kek's Globals"]
local vehicle_mapper <const> = package.loaded["Kek's Vehicle mapper"]
local ped_mapper <const> = package.loaded["Kek's Ped mapper"]
local object_mapper <const> = package.loaded["Kek's Object mapper"]
local menyoo <const> = package.loaded["Kek's Menyoo spawner"]
local kek_entity <const> = package.loaded["Kek's entity functions"]
local troll_entity <const> = package.loaded["Kek's trolling entities"]
local custom_upgrades <const> = package.loaded["Kek's Custom upgrades"]
local admin_mapper <const> = package.loaded["Kek's Admin mapper"]
local menyoo_saver <const> = package.loaded["Kek's Menyoo saver"]
local natives <const> = package.loaded["Kek's Natives"]

if not menu.is_trusted_mode_enabled(1 << 2) then
	essentials.msg(lang["You must turn on trusted mode->Natives to use this script."], "red", true, 6)
	return
end

if not menu.is_trusted_mode_enabled(1 << 3) then
	essentials.msg(lang["You must turn on trusted mode->Http to use this script."], "red", true, 6)
	return
end

if __kek_menu_check_for_updates then
	if essentials.update_keks_menu() == "has updated" then
		return
	end
end

local player_history <const> = {
	year_parents = {},
	month_parents = {},
	day_parents = {},
	hour_parents = {},
	searched_players = {},
	players_added_to_history = setmetatable({
		__get_duplicate_check_string = function(pid)
			return string.format("|%s| &%d& ^%s^", player.get_player_name(pid), player.get_player_scid(pid), essentials.dec_to_ipv4(player.get_player_ip(pid)))
		end
	}, {
		__call = function(Table, pid)
			return Table[Table.__get_duplicate_check_string(pid)]
		end,
		__newindex = function(Table, pid_or_str, value)
			essentials.rawset(
				Table, 
				type(pid_or_str) == "number" and Table.__get_duplicate_check_string(pid_or_str)
				or type(pid_or_str) == "string" and pid_or_str, 
				value
			)
		end
	})
}

do -- Extra functionality to api functions
	local originals <const> = essentials.const({
		create_vehicle = vehicle.create_vehicle,
		create_ped = ped.create_ped,
		clone_ped = ped.clone_ped,
		create_object = object.create_object,
		create_world_object = object.create_world_object,
		request_control_of_entity = network.request_control_of_entity,
		menu_newindex = getmetatable(menu).__newindex,
		vehicle_newindex = getmetatable(vehicle).__newindex,
		ped_newindex = getmetatable(ped).__newindex,
		object_newindex = getmetatable(object).__newindex,
		network_newindex = getmetatable(network).__newindex
	})
	getmetatable(menu).__newindex = nil
	getmetatable(vehicle).__newindex = nil
	getmetatable(ped).__newindex = nil
	getmetatable(object).__newindex = nil
	getmetatable(network).__newindex = nil

	vehicle.create_vehicle = function(...)
		local model <const>,
		pos <const>,
		heading <const>,
		networked <const>,
		alwaysFalse <const>,
		weight <const> = ...
		if weight == 0 or kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			local Vehicle <const> = originals.create_vehicle(model, pos, heading, networked, alwaysFalse)
			kek_entity.entity_manager[Vehicle] = math.tointeger(weight) or 10
			return Vehicle
		end
		return 0
	end

	ped.create_ped = function(...)
		local type <const>,
		model <const>,
		pos <const>,
		heading <const>,
		isNetworked <const>,
		unk1 <const>,
		weight <const> = ...
		if weight == 0 or kek_entity.entity_manager:update().is_ped_limit_not_breached then
			local Ped <const> = originals.create_ped(type, model, pos, heading, isNetworked, unk1)
			kek_entity.entity_manager[Ped] = math.tointeger(weight) or 15
			return Ped
		end
		return 0
	end

	ped.clone_ped = function(Ped)
		if kek_entity.entity_manager:update().is_ped_limit_not_breached then
			local clone <const> = originals.clone_ped(Ped)
			if entity.is_an_entity(clone) then
				kek_entity.entity_manager[clone] = 15
			end
			return clone
		else
			return 0
		end
	end

	object.create_object = function(...)
		if weight == 0 or kek_entity.entity_manager:update().is_object_limit_not_breached then
			local Object <const> = originals.create_object(...)
			local weight <const> = select(5, ...)
			kek_entity.entity_manager[Object] = math.tointeger(weight) or 10
			return Object
		end
		return 0
	end

	object.create_world_object = function(...)
		if weight == 0 or kek_entity.entity_manager:update().is_object_limit_not_breached then
			local world_object <const> = originals.create_world_object(...)
			local weight <const> = select(5, ...)
			kek_entity.entity_manager[world_object] = math.tointeger(weight) or 10
			return world_object
		end
		return 0
	end

	network.request_control_of_entity = function(...)
		local Entity <const>, no_condition <const> = ...
		if no_condition or kek_entity.entity_manager:update()[kek_entity.entity_manager.entity_type_to_return_type[entity.get_entity_type(Entity)]] then
			return originals.request_control_of_entity(Entity)
		else
			return false
		end
	end

	getmetatable(menu).__newindex = originals.menu_newindex
	getmetatable(vehicle).__newindex = originals.vehicle_newindex
	getmetatable(ped).__newindex = originals.ped_newindex
	getmetatable(object).__newindex = originals.object_newindex
	getmetatable(network).__newindex = originals.network_newindex
end

for _, folder_name in pairs({
	"", 
	"kekMenuData", 
	"profiles", 
	"kekMenuLogs", 
	"kekMenuLibs", 
	"Player history", 
	"kekMenuLibs\\Languages",
	"Chat judger profiles",
	"Chatbot profiles"
}) do
	if not utils.dir_exists(paths.kek_menu_stuff..folder_name) then
		utils.make_dir(paths.kek_menu_stuff..folder_name)
	end
end

for _, folder_name in pairs({
	"Menyoo Vehicles",
	"Race ghosts",
	"Menyoo Maps",
	"Ini vehicles"
}) do
	if not utils.dir_exists(paths.kek_menu_stuff..folder_name) then
		utils.make_dir(paths.home.."scripts\\"..folder_name)
	end
end

for _, file_name in pairs({
	"kekMenuData\\custom_chat_judge_data.txt", 
	"kekMenuLogs\\Blacklist.log", 
	"kekMenuData\\Kek's chat bot.txt", 
	"kekMenuData\\Spam text.txt", 
	"kekMenuLogs\\All players.log",
	"kekMenuData\\Clever bot.ini",
	"kekMenuLogs\\Chat log.log",
	"kekMenuLogs\\kek_menu_log.log"
}) do
	if not utils.file_exists(paths.kek_menu_stuff..file_name) then
		essentials.create_empty_file(paths.kek_menu_stuff..file_name)
	end
end

for _, file_name in pairs({
	"kekMenuLibs\\data\\Truck.xml"
}) do
	if not utils.file_exists(paths.kek_menu_stuff..file_name) then
		essentials.msg(string.format("[%s]: %s", file_name, lang["Missing necessarry file. Please reinstall. Read the README that comes with the script for more information."]), "red", true)
		error(lang["Missing necessarry file. Please reinstall. Read the README that comes with the script for more information."])
	end
end

if utils.file_exists(paths.kek_settings) and essentials.get_file_string(paths.kek_settings):match("Script quick access=(%a%a%a%a)") == "true" then
	u.kekMenu, u.kekMenuP = 0, 0
else
	u.kekMenu = menu.add_feature(lang["Kek's menu"], "parent", 0).id
	u.kekMenuP = menu.add_player_feature(lang["Kek's menu"], "parent", 0).id
end
u.player_history = menu.add_feature(lang["Player history"], "parent", u.kekMenu)
u.gvehicle = menu.add_feature(lang["Vehicle"], "parent", u.kekMenu)
u.self_options = menu.add_feature(lang["Self options"], "parent", u.kekMenu)
u.weapons_self = menu.add_feature(lang["Weapons"], "parent", u.self_options.id)
u.search_features = menu.add_feature(lang["Search features from all luas loaded"], "parent", u.kekMenu, function(f)
	if utils.time_ms() < (f.data.has_informed or math.maxinteger) then -- In case people see the message just as it disappears and tries to see it again before it won't show up anymore
		essentials.msg(lang["If the search doesn't find the features you expect, make sure you load Kek's menu before you load all your other scripts."], "green", true, 6)
		essentials.rawset(f.data, "has_informed", utils.time_ms() + 10000) -- f.data is a const table
	end
	if f.child_count > 1 then
		for _, fake_feat in pairs(f.children) do
			if type(fake_feat.data) == "table" and type(fake_feat.data.real_feat) == "userdata" then
				if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
					fake_feat.on = fake_feat.data.real_feat.on
				end
				if fake_feat.value then
					fake_feat.value = fake_feat.data.real_feat.value
				end
				fake_feat.name = fake_feat.data.real_feat.name
			end
		end
	end
end)
u.chat_stuff = menu.add_feature(lang["Chat"], "parent", u.kekMenu)
menu.add_feature(lang["Send clipboard to chat"], "action", u.chat_stuff.id, function()
	essentials.send_message(utils.from_clipboard())
end)

u.chat_spammer = menu.add_feature(lang["Chat spamming"], "parent", u.chat_stuff.id)
u.custom_chat_judger = menu.add_feature(lang["Custom chat judger"], "parent", u.chat_stuff.id)
u.chat_bot = menu.add_feature(lang["Chat bot"], "parent", u.chat_stuff.id)
u.chat_commands = menu.add_feature(lang["Chat commands"], "parent", u.chat_stuff.id)
u.translate_chat = menu.add_feature(lang["Translate chat"], "parent", u.chat_stuff.id)

for _, properties in pairs({
	{
		folder = paths.menyoo_vehicles,
		folder_name = "Menyoo vehicles",
		extension = "xml",
		parent = u.gvehicle,
		func = menyoo.spawn_xml_vehicle,
		save_func = menyoo_saver.save_vehicle,
		str_data = {
			lang["Search"],
			lang["Refresh list"],
			lang["Save"]
		}
	},
	{
		folder = paths.ini_vehicles,
		folder_name = "Ini vehicles",
		extension = "ini",
		parent = u.gvehicle,
		func = menyoo.spawn_ini_vehicle,
		str_data = {
			lang["Search"],
			lang["Refresh list"]
		}
	}
}) do
	local parent
	local feat_name_map = {}
	local feat_str_data <const> = {
		lang["Spawn"],
		lang["Delete"],
		lang["Change name"]
	}

	local feat_func_callback <const> = function(f)
		if essentials.is_str(f, "Spawn") then
			if settings.toggle["Delete old #vehicle#"].on then
				kek_entity.clear_owned_vehicles()
			end
			local Vehicle <const> = properties.func(properties.folder.."\\"..f.name.."."..properties.extension, player.player_id())
			if entity.is_entity_a_vehicle(Vehicle) then
				kek_entity.teleport(Vehicle, kek_entity.vehicle_get_vec_rel_to_dims(entity.get_entity_model_hash(Vehicle), player.get_player_ped(player.player_id())))
				kek_entity.vehicle_preferences(Vehicle)
				kek_entity.user_vehicles[Vehicle] = Vehicle
			end
		elseif essentials.is_str(f, "Delete") then
			if utils.file_exists(properties.folder.."\\"..f.name.."."..properties.extension) then
				io.remove(properties.folder.."\\"..f.name.."."..properties.extension)
			end
			feat_name_map[f.name.."."..properties.extension] = nil
			essentials.delete_feature(f.id)
		elseif essentials.is_str(f, "Change name") then
			local input, status = f.name
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo vehicle."], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
					goto skip
				end
				if utils.file_exists(properties.folder.."\\"..input.."."..properties.extension) then
					essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			essentials.rename_file(properties.folder.."\\", f.name, input, properties.extension)
			feat_name_map[f.name.."."..properties.extension] = nil
			f.name = input
			feat_name_map[f.name.."."..properties.extension] = true
		end
	end

	local function create_custom_vehicle_feature(name)
		local safe_feat_name <const> = essentials.get_safe_feat_name(name)
		if name ~= safe_feat_name or name:find("..", 1, true) or name:find(".", -1, true) then
			return
		end
		local feat = menu.add_feature(safe_feat_name, "action_value_str", parent.id, feat_func_callback)
		feat.data = "MENYOO"
		feat_name_map[feat.name.."."..properties.extension] = true
		feat:set_str_data(feat_str_data)
	end
	parent = menu.add_feature(lang[properties.folder_name], "parent", properties.parent.id)

	local main_feat <const> = menu.add_feature(lang[properties.folder_name], "action_value_str", parent.id, function(f)
		if essentials.is_str(f, "Search") then
			local input, status <const> = keys_and_input.get_input(lang["Type in name of menyoo vehicle."], "", 128, 0)
			if status == 2 then
				return
			end
			input = essentials.make_string_case_insensitive(essentials.remove_special(input))
			local children <const> = parent.children
			for i = 1, #children do
				children[i].hidden = children[i].data == "MENYOO" and not children[i].name:find(input)
			end
		elseif essentials.is_str(f, "Refresh list") then
			local children <const> = parent.children
			for i = 1, #children do -- 3x faster to delete all then reconstruct than using utils.file_exists
				local feat <const> = children[i]
				if feat.data == "MENYOO" then
					essentials.delete_feature(feat.id)
				end
			end
			local files <const> = utils.get_all_files_in_directory(properties.folder, properties.extension)
			local End <const> = -1 - #("."..properties.extension)
			feat_name_map = {}
			for i = 1, #files do
				create_custom_vehicle_feature(files[i]:sub(1, End))
			end
		elseif essentials.is_str(f, "Save") then
			if not properties.save_func then
				return
			end
			if not entity.is_entity_a_vehicle(player.get_player_vehicle(player.player_id())) then
				essentials.msg(lang["Found no vehicle to save."], "red", true)
				return
			end
			local input, status
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo vehicle."], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
					goto skip
				end
				if utils.file_exists(properties.folder.."\\"..input.."."..properties.extension) then
					essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			properties.save_func(player.get_player_vehicle(player.player_id()), properties.folder.."\\"..input.."."..properties.extension)
			create_custom_vehicle_feature(input)
		end
	end)
	main_feat:set_str_data(properties.str_data)
	main_feat.data = "MAIN_FEAT"

	menu.add_feature(lang["Clear all owned entities"], "action", parent.id, function()
		u.clear_owned_entities.on = true
	end).data = "CLEAR_ENTITIES_FEAT"

	local End <const> = -1 - #("."..properties.extension)
	local files <const> = utils.get_all_files_in_directory(properties.folder, properties.extension)
	for i = 1, #files do
		create_custom_vehicle_feature(files[i]:sub(1, End))
	end
end

u.vehicleSettings = menu.add_feature(lang["Vehicle settings"], "parent", u.gvehicle.id)
u.settingsUI = menu.add_feature(lang["Settings"], "parent", u.kekMenu)
u.profiles = menu.add_feature(lang["Settings"], "parent", u.settingsUI.id)
u.script_loader = menu.add_feature(lang["Script loader"], "parent", u.settingsUI.id)
u.language_config = menu.add_feature(lang["Language configuration"], "parent", u.settingsUI.id)
u.ai_drive = menu.add_feature(lang["Ai driving"], "parent", u.gvehicle.id)
u.drive_style_cfg = menu.add_feature(lang["Drive style"], "parent", u.gvehicle.id)
u.protections = menu.add_feature(lang["Protections"], "parent", u.self_options.id)
u.modder_detection = menu.add_feature(lang["Modder detection"], "parent", u.kekMenu)
u.flagsTolog = menu.add_feature(lang["Modder logging settings"], "parent", u.modder_detection.id)
u.flagsToKick = menu.add_feature(lang["Auto kicker settings"], "parent", u.modder_detection.id)
u.vehicle_friendly = menu.add_feature(lang["Vehicle peaceful"], "parent", u.gvehicle.id)
u.vehicle_blacklist = menu.add_feature(lang["Vehicle blacklist"], "parent", u.gvehicle.id)
u.debug = menu.add_feature("Debugging", "parent", u.settingsUI.id)
u.session_trolling = menu.add_feature(lang["Session trolling"], "parent", u.kekMenu)
u.session_malicious = menu.add_feature(lang["Session malicious"], "parent", u.kekMenu)
u.weapon_blacklist = menu.add_feature(lang["Weapon blacklist"], "parent", u.session_malicious.id)
u.session_peaceful = menu.add_feature(lang["Session peaceful"], "parent", u.kekMenu)
u.kek_utilities = menu.add_feature(lang["Kek's utilities"], "parent", u.kekMenu)

u.player_vehicle_features = menu.add_player_feature(lang["Vehicle"], "parent", u.kekMenuP).id
u.malicious_player_features = menu.add_player_feature(lang["Malicious"], "parent", u.kekMenuP).id
u.script_stuff = menu.add_player_feature(lang["Scripts"], "parent", u.kekMenuP).id
u.pWeapons = menu.add_player_feature(lang["Weapons"], "parent", u.kekMenuP).id
u.player_misc_features = menu.add_player_feature(lang["Misc"], "parent", u.kekMenuP).id
u.player_peaceful = menu.add_player_feature(lang["Peaceful"], "parent", u.kekMenuP).id
u.player_trolling_features = menu.add_player_feature(lang["Trolling"], "parent", u.kekMenuP).id

local keks_custom_modder_flags = 
	{
		["Has-Suspicious-Stats"] = 0,
		["Blacklist"] = 0,
		["Godmode"] = 0
	}
	
u.modder_flag_setting_properties = 
	{
		["Log people with "] = {
			feat_name = "Log:", 
			parent = u.flagsTolog,
			bits = 0
		}, 
		["Kick people with "] = {
			feat_name = "Kick:", 
			parent = u.flagsToKick,
			bits = 0
		}
	}

local modIdStuff = {}
do
	local i = 0
	repeat
		modIdStuff[#modIdStuff + 1] = 1 << i
		i = i + 1
	until 1 << i == player.get_modder_flag_ends()
	for flag_name, _ in pairs(keks_custom_modder_flags) do
		local ends <const> = player.get_modder_flag_ends()
		local flag_int <const> = player.add_modder_flag(flag_name)
		if flag_int == ends then
			modIdStuff[#modIdStuff + 1] = flag_int
		end
		keks_custom_modder_flags[flag_name] = flag_int
	end
end

for _, properties in pairs({
	{
		setting_name = "Clear before spawning xml map",
		setting = true
	},
	{
		setting_name = "Force host", 
		setting = false
	}, 
	{
		setting_name = "Automatically check player stats", 
		setting = false
	}, 
	{
		setting_name = "Auto kicker", 
		setting = false
	},
	{
		setting_name = "Auto kicker notifications",
		setting = 0
	},
	{
		setting_name = "Log modders", 
		setting = true
	}, 
	{
		setting_name = "Blacklist", 
		setting = false
	},
	{
		setting_name = "Custom chat judger", 
		setting = false
	}, 
	{
		setting_name = "Chat judge reaction", 
		setting = 1
	}, 
	{
		setting_name = "User vehicle", 
		setting = "krieger"
	},
	{
		setting_name = "User ped",
		setting = "u_m_m_jesus_01"
	},
	{
		setting_name = "User object",
		setting = "prop_asteroid_01"
	},
	{
		setting_name = "Exclude friends from attacks", 
		setting = true
	},
	{
		setting_name = "Exclude yourself from trolling", 
		setting = true
	},
	{
		setting_name = "Plate vehicle text", 
		setting = "Kektram"
	}, 
	{
		setting_name = "Vehicle fly speed",
		setting = 150
	}, 
	{
		setting_name = "Vehicle blacklist",
		setting = false
	},
	{
		setting_name = "Spam text",
		setting = "Kektram"
	},
	{
		setting_name = "Echo chat",
		setting = false
	},
	{
		setting_name = "Kick any vote kickers",
		setting = false
	},
	{
		setting_name = "chat bot",
		setting = false
	},
	{
		setting_name = "chat bot delay",
		setting = 0
	},
	{
		setting_name = "Spam speed",
		setting = 100
	},
	{
		setting_name = "Echo delay",
		setting = 100
	},
	{
		setting_name = "Player history",
		setting = true
	},
	{
		setting_name = "Random weapon camos",
		setting = false
	},
	{
		setting_name = "Max number of people to kick in force host",
		setting = 31
	},
	{
		setting_name = "Vehicle clear distance",
		setting = 500
	},
	{
		setting_name = "Ped clear distance",
		setting = 500
	},
	{
		setting_name = "Object clear distance",
		setting = 500
	},
	{
		setting_name = "Pickup clear distance",
		setting = 500
	},
	{
		setting_name = "Ptfx clear distance",
		setting = 500
	},
	{
		setting_name = "Drive style",
		setting = 557
	},
	{
		setting_name = "Cops clear distance",
		setting = 500
	},
	{
		setting_name = "Chat logger",
		setting = true
	},
	{
		setting_name = "Script quick access",
		setting = false
	},
	{
		setting_name = "Chat commands",
		setting = false
	},
	{
		setting_name = "Only friends can use chat commands",
		setting = false
	},
	{
		setting_name = "Send command info",
		setting = false
	},
	{
		setting_name = "Godmode detection",
		setting = false
	},
	{
		setting_name = "Horn boost speed",
		setting = 25
	},
	{
		setting_name = "Horn boost",
		setting = false
	},
	{
		setting_name = "Bounty amount",
		setting = 10000
	},
	{
		setting_name = "Friends can't be targeted by chat commands",
		setting = true
	},
	{
		setting_name = "You can't be targeted",
		setting = true
	},
	{
		setting_name = "Auto tp to waypoint",
		setting = false
	},
	{
		setting_name = "Random weapon camos speed",
		setting = 500
	},
	{
		setting_name = "Chance to reply",
		setting = 100
	},
	{
		setting_name = "Aim protection",
		setting = false
	},
	{
		setting_name = "Aim protection mode",
		setting = 1
	},
	{
		setting_name = "Revenge",
		setting = false
	},
	{
		setting_name = "Revenge mode",
		setting = 1
	},
	{
		setting_name = "Anti stuck measures",
		setting = true
	},
	{
		setting_name = "Time OSD",
		setting = false
	},
	{
		setting_name = "Clever bot",
		setting = false
	},
	{
		setting_name = "Move mini map to people you spectate",
		setting = false
	},
	{
		setting_name = "Display 2take1 notifications",
		setting = false
	},
	{
		setting_name = "Display 2take1 notifications filter",
		setting = 0
	},
	{
		setting_name = "Number of notifications to display",
		setting = 15
	},
	{
		setting_name = "Log 2take1 notifications to console",
		setting = false
	},
	{
		setting_name = "Log 2take1 notifications to console filter",
		setting = 0
	},
	{
		setting_name = "Help interval",
		setting = 14
	},
	{
		setting_name = "Weapon blacklist",
		setting = false
	},
	{
		setting_name = "Weapon blacklist notifications",
		setting = 0
	},
	{
		setting_name = "Show red sphere clear entities",
		setting = true
	},
	{
		setting_name = "Force field sphere",
		setting = true
	},
	{
		setting_name = "Anti chat spam",
		setting = false
	},
	{
		setting_name = "Anti chat spam reaction", 
		setting = 0
	},
	{
		setting_name = "Debug mode",
		setting = false
	},
	{
		setting_name = "Check rid in also known as",
		setting = true
	},
	{
		setting_name = "Check name in also known as",
		setting = true
	},
	{
		setting_name = "Check ip in also known as",
		setting = false
	},
	{
		setting_name = "Vehicle limits",
		setting = 80
	},
	{
		setting_name = "Ped limits",
		setting = 80
	},
	{
		setting_name = "Object limits",
		setting = 230
	},
	{
		setting_name = "Draw entity limits",
		setting = false
	},
	{
		setting_name = "Draw number of script events sent",
		setting = false
	},
	{
		setting_name = "Draw garbage collection",
		setting = false
	},
	{
		setting_name = "Draw entity queue",
		setting = false
	},
	{
		setting_name = "Blacklist option",
		setting = 0
	},
	{
		setting_name = "Is player typing",
		setting = false
	},
	{
		setting_name = "Participate in betas",
		setting = false
	},
	{
		setting_name = "Translate chat into language",
		setting = false
	},
	{
		setting_name = "Translate chat into language option",
		setting = 0
	},
	{
		setting_name = "Translate chat into language what language",
		setting = 0
	},
	{
		setting_name = "Translate chat into language what language to detect",
		setting = 0
	},
	{
		setting_name = "Translate your messages too",
		setting = false
	},
	{
		setting_name = "Translate your messages into",
		setting = false
	},
	{
		setting_name = "Translate your messages into option",
		setting = 0
	},
	{
		setting_name = "Translate your messages into chat type",
		setting = 0
	},
	{
		setting_name = "Check for updates",
		setting = true
	}
}) do
	settings:add_setting(properties)
end

settings.toggle["Exclude friends from attacks"] = menu.add_feature(lang["Exclude friends from attacks"], "toggle", u.session_malicious.id)

for _, properties in pairs({
	{
		setting_name = "Chat judge #notifications#", 
		setting = true, 
		feature_name = lang["Notifications"], 
		feature_parent = u.custom_chat_judger
	},
	{
		setting_name = "Vehicle blacklist #notifications#", 
		setting = true, 
		feature_name = lang["Notifications"], 
		feature_parent = u.vehicle_blacklist
	},
	{
		setting_name = "Blacklist notifications #notifications#", 
		setting = true, 
		feature_name = lang["Notify when recognized in blacklist"], 
		feature_parent = u.modder_detection
	}
}) do
	settings:add_setting(properties)
	settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", properties.feature_parent.id, function(f)
		settings.in_use[properties.setting_name] = f.on
	end)
end

for _, properties in pairs({
	{
		setting_name = "Spawn #vehicle# in godmode", 
		setting = false, 
		feature_name = lang["Spawn vehicles in godmode"]
	},
	{
		setting_name = "Spawn inside of spawned #vehicle#", 
		setting = true, 
		feature_name = lang["Spawn inside of spawned vehicle"]
	}, 
	{
		setting_name = "Always f1 wheels on #vehicle#", 
		setting = false, 
		feature_name = lang["Always spawn with f1 wheels"]
	},
	{
		setting_name = "Always ask what #vehicle#", 
		setting = false, 
		feature_name = lang["Always ask what vehicle"]
	}, 
	{
		setting_name = "Air #vehicle# spawn mid-air", 
		setting = true, 
		feature_name = lang["Spawn air vehicle mid-air"]
	},
	{
		setting_name = "Spawn #vehicle# maxed", 
		setting = true, 
		feature_name = lang["Spawn vehicles maxed"]
	}, 
	{
		setting_name = "Delete old #vehicle#", 
		setting = true, 
		feature_name = lang["Delete old vehicle"]
	}
}) do
	settings:add_setting(properties)
	settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", u.vehicleSettings.id)
end

-- Mod tag related settings
settings.toggle["Log modders"] = menu.add_feature(lang["Log flags below to blacklist"], "toggle", u.flagsTolog.id, function(f)
	local blacklist_flag <const> = keks_custom_modder_flags["Blacklist"]
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			local scid <const> = player.get_player_scid(pid)
			if player.is_player_modder(pid, -1)
			and essentials.is_not_friend(pid)
			and essentials.how_many_people_named(pid) == 1
			and (
				(
					not f.data[scid] 
					and player.is_player_modder(pid, u.modder_flag_setting_properties["Log people with "].bits)
				)
				or (
					f.data.not_modder_flag_tracker[scid] 
					and ((f.data[scid] | player.get_player_modder_flags(pid) | blacklist_flag) ~ blacklist_flag) ~= f.data[scid]
				)
			) then
				f.data[scid] = ((f.data[scid] or 0) | player.get_player_modder_flags(pid) | blacklist_flag) ~ blacklist_flag
				local name = player.get_player_name(pid)
				local ip <const> = player.get_player_ip(pid)
				local str_to_log = string.format("§%s§ /%s/ &%s& <%s>", name, scid, ip, essentials.modder_flags_to_text(f.data[scid]))
				local found_str <const> = essentials.log(
					paths.blacklist, 
					str_to_log, 
					{string.format("/%i/", scid), string.format("&%i&", ip), string.format("§%s§", name)}
				)
				local flags_from_file 
				if found_str then
					flags_from_file = essentials.modder_text_to_flags(found_str:match("<(.+)>"))
					f.data[scid] = f.data[scid] | flags_from_file
				else
					f.data.recently_logged[pid] = utils.time_ms() + 2000
				end
				str_to_log = string.format("§%s§ /%s/ &%s& <%s>", name, scid, ip, essentials.modder_flags_to_text(f.data[scid]))
				f.data.not_modder_flag_tracker[scid] = not found_str or flags_from_file ~= 0
				if f.data.not_modder_flag_tracker[scid] and found_str ~= str_to_log then
					essentials.replace_lines_in_file_exact(
						paths.blacklist, 
						found_str,
						str_to_log
					)
				end
			end
		end
	end
end)
settings.toggle["Log modders"].data = {
	not_modder_flag_tracker = {}, -- Is accessed in remove_from_blacklist
	recently_logged = {} -- Accessed by blacklist feat
} -- settings.toggle["Log modders"].data is accessed by the auto kicker

settings.toggle["Auto kicker"] = menu.add_feature(lang["Auto kicker"], "value_str", u.flagsToKick.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			local scid <const> = player.get_player_scid(pid)
			if utils.time_ms() > (f.data[scid] or 0)
			and player.is_player_modder(pid, -1) 
			and essentials.is_not_friend(pid)
			and player.is_player_modder(pid, u.modder_flag_setting_properties["Kick people with "].bits) then
				if settings.toggle["Log modders"].on and player.is_player_modder(pid, u.modder_flag_setting_properties["Log people with "].bits) then
					local time <const> = utils.time_ms() + 1500
					while f.on and player.is_player_valid(pid) and time > utils.time_ms() and ((settings.toggle["Log modders"].on and not settings.toggle["Log modders"].data[scid]) or (settings.toggle["Player history"].on and not player_history.players_added_to_history(pid))) do
						system.yield(0)
					end
				end
				if player.is_player_valid(pid) and f.on and player.is_player_modder(pid, u.modder_flag_setting_properties["Kick people with "].bits) then
					local modder_flags <const> = essentials.modder_flags_to_text(player.get_player_modder_flags(pid))
					essentials.msg(string.format("%s %s%s%s", lang["Kicking"], player.get_player_name(pid), lang[", flags:\n"], modder_flags), "red", essentials.is_str(f, "Notifications on"))
					essentials.kick_player(pid)
					f.data[scid] = utils.time_ms() + 20000
				end
			end
		end
	end
end)
settings.toggle["Auto kicker"]:set_str_data({
	lang["Notifications on"],
	lang["Notifications off"]
})
settings.valuei["Auto kicker notifications"] = settings.toggle["Auto kicker"]
settings.toggle["Auto kicker"].data = {}

for setting_prefix, setting_property in pairs(u.modder_flag_setting_properties) do
	for i = 1, #modIdStuff do
		local setting_name <const> = setting_prefix..player.get_modder_flag_text(modIdStuff[i])
		settings:add_setting({
			setting_name = setting_name, 
			setting = false
		})

		settings.toggle[setting_name] = menu.add_feature(lang[setting_property.feat_name].." "..player.get_modder_flag_text(modIdStuff[i]), "toggle", setting_property.parent.id, function(f) 
			settings.in_use[setting_name] = f.on
			if f.on then
				setting_property.bits = setting_property.bits | modIdStuff[i]
			else
				setting_property.bits = setting_property.bits & (setting_property.bits ~ modIdStuff[i])
			end
		end)
	end
end

menu.add_feature(string.format("%s English %s", lang["Set"], lang["as default language."]), "action", u.language_config.id, function(f)
	local file <close> = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini", "w+")
	file:write("English.txt")
	file:flush()
	essentials.msg("English "..lang["was set as the default language."], "blue", true)
	essentials.msg("Reset lua state for language change to apply.", "red", true, 10)
end)
for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."kekMenuLibs\\Languages", "txt")) do
	menu.add_feature(string.format("%s %s %s", lang["Set"], file_name:gsub("%.txt$", ""), lang["as default language."]), "action", u.language_config.id, function(f)
		local file <close> = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini", "w+")
		file:write(file_name)
		file:flush()
		essentials.msg(string.format("%s %s", file_name:gsub("%.txt$", ""), lang["was set as the default language."]), "blue", true)
		essentials.msg("Reset lua state for language change to apply.", "red", true, 10)
	end)
end

do
	local function update_script_loader_toggle_name()
		local str <const> = essentials.get_file_string(paths.home.."scripts\\autoexec.lua")
		if str:find("if false then return end", 1, true) then
			u.toggle_script_loader.name = lang["Turn off script loader"]
		else
			u.toggle_script_loader.name = lang["Turn on script loader"]
		end
	end

	local function update_autoexec()
		if not utils.file_exists(paths.home.."scripts\\autoexec.lua") then
			essentials.create_empty_file(paths.home.."scripts\\autoexec.lua")
		end
		local str <const> = essentials.get_file_string(paths.home.."scripts\\autoexec.lua")
		if utils.file_exists(paths.home.."scripts\\autoexec.lua") and not str:find("sjhvnciuyu44khdjkhUSx", 1, true) then
			local file <close> = io.open(paths.home.."scripts\\autoexec.lua", "w+")
			file:write(table.concat({
				"if false then return end",
				"-- Version "..__kek_menu_version,
				"-- sjhvnciuyu44khdjkhUSx",
				"local appdata_path <const> = utils.get_appdata_path(\"PopstarDevs\", \"2Take1Menu\")..\"\\\\\"",
				"local scripts <const> = {}",
				"menu.create_thread(function()",
				"	system.yield(0)",
				"	for i = 0, #scripts - 1 do",
				"		local script_name <const> = scripts[#scripts - i]",
				"		local file_path <const> = appdata_path..\"scripts\\\\\"..script_name",
				"		if utils.file_exists(file_path) then",
				"			if require(script_name:gsub(\"%.lua$\", \"\")) then",
				"				menu.notify(\"Failed to load \"..script_name, \"error\", 6)",
				"				local err <const> = select(2, loadfile(file_path))",
				"				print(err)",
				"			end",
				"		end",
				"	end",
				"end, nil)"
			}, "\n"))
			file:flush()
		end
	end

	u.toggle_script_loader = menu.add_feature("", "action", u.script_loader.id, function(f)
		update_autoexec(true)
		local str <const> = essentials.get_file_string(paths.home.."scripts\\autoexec.lua")
		if str:find("^if false then return end") then
			essentials.replace_lines_in_file_exact(
				paths.home.."scripts\\autoexec.lua", 
				"if false then return end", 
				"if true then return end"
			)
			essentials.msg(lang["Turned off script loader"], "red", true)
		elseif str:find("^if true then return end") then
			essentials.replace_lines_in_file_exact(
				paths.home.."scripts\\autoexec.lua", 
				"if true then return end", 
				"if false then return end"
			)
			essentials.msg(lang["Turned on script loader"], "green", true)
		end
		update_script_loader_toggle_name()
	end)

	menu.add_feature(lang["Empty script loader file"], "action", u.script_loader.id, function()
		local file <close> = io.open(paths.home.."scripts\\autoexec.lua", "w+")
		update_autoexec(true)
		update_script_loader_toggle_name()
		essentials.msg(lang["Emptied script loader"], "blue", true)
	end)

	menu.add_feature(lang["Add script to auto loader"], "action", u.script_loader.id, function()
		local input, status <const> = keys_and_input.get_input(lang["Type in the name of the lua script to add."], "", 128, 0)
		if status == 2 then
			return
		end
		input = essentials.make_string_case_insensitive(essentials.remove_special(input))
		update_autoexec(true)
		for _, file_name in pairs(utils.get_all_files_in_directory(paths.home.."scripts\\", "lua")) do
			if file_name ~= "autoexec.lua" and file_name:find(input) then
				if not essentials.search_for_match_and_get_line(paths.home.."scripts\\autoexec.lua", {file_name}) then
					essentials.replace_lines_in_file_exact(
						paths.home.."scripts\\autoexec.lua", 
						"local scripts <const> = {}", 
						"local scripts <const> = {}\nscripts[#scripts + 1] = \""..file_name.."\""
					)
					essentials.msg(string.format("%s %s %s", lang["Added"], file_name, lang["to script loader"]), "green", true)
					update_script_loader_toggle_name()
					return
				else
					essentials.msg(string.format("%s %s", file_name, lang["is already in the script loader"]), "blue", true)
					return
				end
			end
		end
		essentials.msg(lang["Couldn't find file"], "red", true)
	end)

	menu.add_feature(lang["Remove script from auto loader"], "action", u.script_loader.id, function()
		local input, status <const> = keys_and_input.get_input(lang["Type in the lua script you want to remove."], "", 128, 0)
		if status == 2 then
			return
		end
		input = essentials.make_string_case_insensitive(essentials.remove_special(input))
		update_autoexec(true)
		for file_name in essentials.get_file_string(paths.home.."scripts\\autoexec.lua"):gmatch("scripts%[#scripts %+ 1%] = \"([^\n\r]+)\"") do
			if file_name:find(input) then
				if essentials.remove_lines_from_file_exact(paths.home.."scripts\\autoexec.lua", "scripts[#scripts + 1] = \""..file_name.."\"") then
					essentials.msg(string.format("%s %s %s.", lang["Removed"], file_name, lang["from script loader"]), "blue", true)
					update_script_loader_toggle_name()
					return
				end
			end
		end
		essentials.msg(lang["Couldn't find file"], "red", true)
	end)
	update_script_loader_toggle_name()
end

do
	settings.toggle["Godmode detection"] = menu.add_feature(lang["Godmode detection"], "toggle", u.modder_detection.id, function(f)
		while f.on do
			system.yield(0)
			for pid in essentials.players() do
				if f.data.is_god(f, pid)
					and (not f.data.tracker[player.get_player_scid(pid)] or utils.time_ms() > f.data.tracker[player.get_player_scid(pid)])
					and #kek_entity.is_any_tasks_active(player.get_player_ped(pid), f.data.tasks) > 1 
				then
					local scid <const> = player.get_player_scid(pid)
					f.data.tracker[scid] = utils.time_ms() + 15000
					menu.create_thread(function()
						local time <const> = utils.time_ms() + 1000
						while time > utils.time_ms() and f.data.is_god(f, pid)
						and #kek_entity.is_any_tasks_active(player.get_player_ped(pid), f.data.tasks) > 1 do
							system.yield(0)
						end
						if utils.time_ms() > time then
							local time <const> = utils.time_ms() + 10000
							while time > utils.time_ms() and f.data.is_god(f, pid) do
								system.yield(0)
							end
							if utils.time_ms() > time then
								essentials.msg(string.format("%s %s", player.get_player_name(pid), lang["is in godmode."]), "orange", true)
								player.mark_as_modder(pid, keks_custom_modder_flags["Godmode"])
								f.data.tracker[scid] = utils.time_ms() + 120000
							end
						end
					end, nil)
				end
			end
		end
	end)
	settings.toggle["Godmode detection"].data = {
		tasks = {
			enums.ctasks.Melee,
			enums.ctasks.Cover,
			enums.ctasks.AimAndThrowProjectile,
			enums.ctasks.ReloadGun,
			enums.ctasks.Weapon,
			enums.ctasks.ReactAimWeapon,
			enums.ctasks.Writhe,
			enums.ctasks.StayInCover,
			enums.ctasks.CombatFlank,
			enums.ctasks.Parachute,
			enums.ctasks.CombatRoll,
			enums.ctasks.AimGunOnFoot,
			enums.ctasks.PlayerWeapon,
			enums.ctasks.SwapWeapon,
			enums.ctasks.Gun,
			enums.ctasks.MoveMeleeMovement,
			enums.ctasks.MeleeActionResult,
			enums.ctasks.MeleeUpperbodyAnims,
			enums.ctasks.MountThrowProjectile,
			enums.ctasks.ThrowProjectile,
			enums.ctasks.AimFromGround,
			enums.ctasks.AimGunScripted,
			enums.ctasks.Bomb
		},
		is_god = function(f, pid)
			local hash <const> = entity.get_entity_model_hash(player.get_player_vehicle(pid))
			return 
				f.on
				and player.can_player_be_modder(pid)
				and player.is_player_god(pid)
				and entity.is_entity_visible(player.get_player_ped(pid))
				and memoize.get_player_coords(pid).z ~= -190
				and memoize.get_player_coords(pid).z ~= -180
				and not memoize.is_in_vehicle(pid)
				and not player.is_player_modder(pid, -1)
				and not entity.is_entity_dead(player.get_player_ped(pid))
				and essentials.is_not_friend(pid)
				and interior.get_interior_from_entity(player.get_player_ped(pid)) == 0
				and interior.get_interior_at_coords_with_type(memoize.get_player_coords(pid), "") == 0
		end,
		tracker = {}
	}
end

settings.toggle["Blacklist"] = menu.add_feature(lang["Blacklist"], "value_str", u.modder_detection.id, function(f)
	if f.on then
		if essentials.listeners["player_join"]["blacklist"] then -- value_str creates a new thread if no thread is active. Meaning duplicate event listeners.
			return
		end
		essentials.listeners["player_join"]["blacklist"] = event.add_event_listener("player_join", function(event)
			local pid <const> = event.player
			if player.is_player_valid(pid)
			and player.can_player_be_modder(pid)
			and player.player_id() ~= pid 
			and essentials.is_not_friend(pid)
			and essentials.how_many_people_named(pid) == 1
			and utils.time_ms() > (settings.toggle["Log modders"].data.recently_logged[pid] or 0) 
			and not player.is_player_modder(pid, keks_custom_modder_flags["Blacklist"]) then
				local rid <const> = player.get_player_scid(pid)
				local name = player.get_player_name(pid)
				local ip <const> = player.get_player_ip(pid)
				if #name < 1 then
					name = math.random(-2^61, 2^62)
				end
				local tags, what_was_detected = essentials.search_for_match_and_get_line(paths.blacklist, {
					string.format("/%i/", rid),
					string.format("&%i&", ip),
					string.format("§%s§", name)
				})
				if tags and what_was_detected then
					what_was_detected = what_was_detected:gsub("[/&§]", "")
					if what_was_detected:find("/", 1, true) then
						what_was_detected = string.format("%s: %s", lang["Rid"], what_was_detected)
					elseif what_was_detected:find("&", 1, true) then 
						what_was_detected = string.format("%s: %s", lang["IP"], essentials.dec_to_ipv4(tonumber(what_was_detected)))
					elseif what_was_detected:find("§", 1, true) then
						what_was_detected = string.format("%s: %s", lang["Name"], what_was_detected)
					end
					tags = tags:match("<(.+)>") or ""
					local flags <const> = essentials.modder_text_to_flags(tags)
					essentials.msg(
						string.format("%s %s%s %s %s%s", lang["Recognized"], name, lang["\nDetected:"], what_was_detected, lang["\nTags:\n"], tags), 
						"orange", 
						settings.in_use["Blacklist notifications #notifications#"]
					)
					if essentials.is_str(f, "Reapply marks") then
						player.set_player_as_modder(pid, flags)
					end
					if player.is_player_valid(pid) then
						player.mark_as_modder(pid, keks_custom_modder_flags["Blacklist"])
					end
				end
			end
		end)
	else
		event.remove_event_listener("player_join", essentials.listeners["player_join"]["blacklist"])
		essentials.listeners["player_join"]["blacklist"] = nil
	end
end)
settings.valuei["Blacklist option"] = settings.toggle["Blacklist"]
settings.valuei["Blacklist option"]:set_str_data({
	lang["Don't reapply marks"],
	lang["Reapply marks"]
})

do
	local strings <const> = essentials.const({
		lang["Has a lot of money."],
		lang["Has Negative lvl"],
		lang["Has Negative k/d"],
		lang["Has a high rank."],
		lang["Has a high k/d."],
		lang["Has modded weapons."]
	})
	local detection_string_cache <const> = {}

	local function suspicious_stats(pid)
		if player.is_player_valid(pid)
		and player.can_player_be_modder(pid)
		and not player.is_player_modder(pid, keks_custom_modder_flags["Has-Suspicious-Stats"])
		and globals.get_player_rank(pid) ~= 0 
		and not settings.toggle["Automatically check player stats"].data[player.get_player_scid(pid)] 
		and essentials.is_not_friend(pid) 
		and pid ~= player.player_id() 
		and (globals.get_player_money(pid) ~= globals.get_player_money(player.player_id()) 
			or globals.get_player_rank(pid) ~= globals.get_player_rank(player.player_id()) 
			or globals.get_player_kd(pid) ~= globals.get_player_kd(player.player_id())) then
			local severity = 0
			local hash = 0
			if globals.get_player_money(pid) > 120000000 or globals.get_player_money(pid) < -0.1 then
				severity = severity + 1
				hash = hash | 1 << 0
			end
			if globals.get_player_rank(pid) < 1 then
				severity = severity + 3
				hash = hash | 1 << 1
			end
			if globals.get_player_kd(pid) < -0.1 then
				severity = severity + 3
				hash = hash | 1 << 2
			end
			if globals.get_player_rank(pid) > 1200 then
				severity = severity + 1
				hash = hash | 1 << 3
			end
			if globals.get_player_kd(pid) > 10 then
				severity = severity + 1
				hash = hash | 1 << 4
			end
			local Ped <const> = player.get_player_ped(pid)
			if weapon.has_ped_got_weapon(Ped, gameplay.get_hash_key("weapon_stungun"))
			or weapon.has_ped_got_weapon(Ped, gameplay.get_hash_key("weapon_stinger"))
			or weapon.has_ped_got_weapon(Ped, gameplay.get_hash_key("weapon_railgun"))
			or weapon.has_ped_got_weapon(Ped, gameplay.get_hash_key("weapon_hazardcan"))
			or weapon.has_ped_got_weapon(Ped, gameplay.get_hash_key("weapon_fireextinguisher"))
			or weapon.has_ped_got_weapon(Ped, gameplay.get_hash_key("weapon_bzgas")) then
				severity = severity + 2
				hash = hash | 1 << 6
			end
			if not detection_string_cache[hash] then
				local str <const> = {}
				for i = 0, #strings - 1 do
					if hash & 1 << i ~= 0 then
						str[#str + 1] = strings[i + 1]
					end
				end
				detection_string_cache[hash] = table.concat(str, "\n")
			end
			if severity >= 3 then
				player.mark_as_modder(pid, keks_custom_modder_flags["Has-Suspicious-Stats"])
				settings.toggle["Automatically check player stats"].data[player.get_player_scid(pid)] = true
				essentials.msg(string.format("%s %s\n%s", player.get_player_name(pid), lang["has:"], detection_string_cache[hash]), "orange", true, 6)
			end
		end
	end

	settings.toggle["Automatically check player stats"] = menu.add_feature(lang["Modded stats detection"], "toggle", u.modder_detection.id, function(f)
		while f.on do
			for pid in essentials.players() do
				suspicious_stats(pid)
			end
			system.yield(0)
		end
	end)
	settings.toggle["Automatically check player stats"].data = {}
end

local function add_to_blacklist(...)
	if utils.file_exists(paths.blacklist) then
		local name,
		ip <const>,
		rid <const>,
		reason,
		text <const> = ...
		if not name or #name < 1 then
			name = "INVALID_NAME_758349843"
		end
		if not reason or #reason == 0 then
			reason = "Manually added"
		end
		local results <const> = essentials.log(paths.blacklist, string.format("§%s§ /%s/ &%s& <%s>", name, rid, ip, reason), {
			string.format("/%s/", rid),
			string.format("&%s&", ip),
			string.format("§%s§", name)
		})
		if results then
			essentials.replace_lines_in_file_exact(
				paths.blacklist, 
				results, 
				string.format("%s<%s>", results:match("(.+)<"), reason)
			)
			essentials.msg(lang["Changed the reason this person was added to the blacklist."], "blue", text)
		else
			essentials.msg(lang["Added to blacklist."], "green", text)
			return true
		end
	else
		essentials.msg(lang["Blacklist file doesn't exist."], "red", text)
	end
end

local function remove_from_blacklist(...)
	if utils.file_exists(paths.blacklist) then
		local name,
		ip,
		rid,
		text <const> = ...
		ip = tostring(ip)
		rid = tostring(rid)
		if ip:find("%.") then
			ip = tostring(essentials.ipv4_to_dec(ip))
		end
		local result = essentials.remove_lines_from_file_substring(paths.blacklist, string.format("/%i/", rid))
		result = result or essentials.remove_lines_from_file_substring(paths.blacklist, string.format("&%i&", ip))
		result = result or essentials.remove_lines_from_file_substring(paths.blacklist, string.format("§%s§", name))
		if result then
			settings.toggle["Log modders"].data.not_modder_flag_tracker[tonumber(rid)] = nil -- So that modder logger can't add anymore
			essentials.msg(lang["Removed rid."], "green", text)
		else
			essentials.msg(lang["Couldn't find player."], "blue", text)
		end
	else
		essentials.msg(lang["Blacklist file doesn't exist."], "red", text)
	end
end

menu.add_player_feature(lang["Blacklist"], "action_value_str", u.player_misc_features, function(f, pid)
	if essentials.is_str(f, "Add") then
		if pid == player.player_id() then
			essentials.msg(lang["You can't add yourself to the blacklist..."], "red", true)
			return
		end
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in why you're adding this person."], "", 128, 0)
		if status == 2 then
			return
		end
		add_to_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid), input, true)
		player.mark_as_modder(pid, keks_custom_modder_flags["Blacklist"])
	elseif essentials.is_str(f, "Remove") then
		remove_from_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid), true)
	end
end):set_str_data({
	lang["Add"],
	lang["Remove"]
})

settings.toggle["Kick any vote kickers"] = menu.add_feature(lang["Kick any vote kickers"], "toggle", u.protections.id, function(f)
	if f.on then
		essentials.nethooks["vote_kick_protex"] = hook.register_net_event_hook(function(...)
			local sender <const>, target <const>, event <const> = ...
			if event == enums.net_event_ids.KICK_VOTES_EVENT
			and sender ~= player.player_id()
			and target == player.player_id()
			and player.can_player_be_modder(sender)
			and essentials.is_not_friend(sender) then
				local player_name <const> = player.get_player_name(sender) -- Player is most likely gone after kick
				local scid <const> = player.get_player_scid(sender)
				if essentials.kick_player(sender) then
					essentials.msg(string.format("%s %s", player_name, lang["sent vote kick. Kicking them..."]), "orange", true)
				end
			end
		end)
	else
		hook.remove_net_event_hook(essentials.nethooks["vote_kick_protex"])
		essentials.nethooks["vote_kick_protex"] = nil
	end
end)

settings.toggle["Revenge"] = menu.add_feature(lang["Revenge"], "value_str", u.protections.id, function(f)
	while f.on do
		system.yield(0)
		if entity.is_entity_dead(player.get_player_ped(player.player_id())) then
			local pid <const> = network._network_get_player_killer_of_player(player.player_id()):__tointeger() -- is -1 if not killed by player
			if player.is_player_valid(pid) and essentials.is_not_friend(pid) and player.can_player_be_modder(pid) and player.player_id() ~= pid then
				if essentials.is_str(f, "Kill") then
					essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), enums.explosion_types.BLIMP, true, false, 0, player.get_player_ped(player.player_id()))
				elseif essentials.is_str(f, "Clown vans") then
					troll_entity.send_clown_van(pid)
				elseif essentials.is_str(f, "Kick") then
					essentials.kick_player(pid)
				elseif essentials.is_str(f, "Crash") then
					globals.script_event_crash(pid)
				end
			end
			while f.on and entity.is_entity_dead(player.get_player_ped(player.player_id())) do
				system.yield(0)
			end
		end
	end
end)
settings.valuei["Revenge mode"] = settings.toggle["Revenge"]
settings.valuei["Revenge mode"]:set_str_data({
	lang["Kill"],
	lang["Clown vans"],
	lang["Kick"],
	lang["Crash"]
})

settings.toggle["Aim protection"] = menu.add_feature(lang["Aim protection"], "value_str", u.protections.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) and player.get_entity_player_is_aiming_at(pid) == player.get_player_ped(player.player_id()) then
				if essentials.is_str(f, "Explode") or essentials.is_str(f, "Explode with blame") then
					if essentials.is_in_vehicle(pid) then
						ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
						system.yield(300)
					end
					local blame = pid
					if essentials.is_str(f, "Explode with blame") then
						blame = player.player_id()
					end
					essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), enums.explosion_types.GRENADELAUNCHER, true, false, 0, player.get_player_ped(blame))
				elseif essentials.is_str(f, "Taze") then
					local time <const> = utils.time_ms() + 500
					while time > utils.time_ms() do
						gameplay.shoot_single_bullet_between_coords(
							kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 0.3), 
							select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 
							0x60f1, 
							memoize.v3())), 
							0, 
							gameplay.get_hash_key("weapon_stungun"), 
							player.get_player_ped(player.player_id()), 
							true, 
							false, 
							1000
						)
						system.yield(75)
					end
				elseif essentials.is_str(f, "Invite to apartment") then
					globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, math.random(1, 113), 1, 1, 1}, true)
				end
			end
		end
		system.yield(0)
	end
end)
settings.valuei["Aim protection mode"] = settings.toggle["Aim protection"]
settings.valuei["Aim protection mode"]:set_str_data({
	lang["Explode"],
	lang["Explode with blame"],
	lang["Taze"],
	lang["Invite to apartment"]
})

menu.add_feature(lang["Blacklist"], "action_value_str", u.modder_detection.id, function(f)
	local illegal_chars_msg <const> = lang["Illegal characters detected. Please try again. Illegal chars:"].." \"/\", \"§\", \"&\", \"<\", \">\""
	if essentials.is_str(f, "Add") then
		local ip, reason, name = "", "", ""
		local scid <const>, status = keys_and_input.get_input(lang["Type in social club ID, also known as: rid / scid."], "", 16, 3)
		if status == 2 then
			return
		end
		while true do
			ip, status = keys_and_input.get_input(lang["Type in ip."], ip, 128, 0)
			if status == 2 then
				return
			end
			if ip:find("[/§&<>]") then
				essentials.msg(illegal_chars_msg, "red", true, 7)
			else
				break
			end
			system.yield(0)
		end
		if ip:find(".", 1, true) then
			ip = essentials.ipv4_to_dec(ip)
		end
		while true do
			reason, status = keys_and_input.get_input(lang["Type in why you're adding this person."], reason, 128, 0)
			if status == 2 then
				return
			end
			if reason:find("[/§&<>]") then
				essentials.msg(illegal_chars_msg, "red", true, 7)
			else
				break
			end
			system.yield(0)
		end
		while true do
			name, status = keys_and_input.get_input(lang["Type in their name."], name, 128, 0)
			if status == 2 then
				return
			end
			if name:find("[/§&<>]") then
				essentials.msg(illegal_chars_msg, "red", true, 7)
			else
				break
			end
			system.yield(0)
		end
		add_to_blacklist(name, ip, scid, reason, true)
		for pid in essentials.players() do
			if player.get_player_scid(pid) == scid then
				player.mark_as_modder(pid, keks_custom_modder_flags["Blacklist"])
			end
		end
	elseif essentials.is_str(f, "Remove") then
		local scid <const>, status <const> = keys_and_input.get_input(lang["Type in social club ID, also known as: rid / scid."], "", 16, 3)
		if status == 2 then
			return
		end
		local ip <const>, status <const> = keys_and_input.get_input(lang["Type in ip."], "", 128, 0)
		if status == 2 then
			return
		end
		remove_from_blacklist("", ip, scid, true)
	elseif essentials.is_str(f, "Add session") then
		local reason <const>, status <const> = keys_and_input.get_input(lang["Type in the why you're adding everyone."], "", 128, 0)
		if status == 2 then
			return
		end
		local number_of_players_added = 0
		local number_of_players_modified = 0
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) and add_to_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid), reason) then
				number_of_players_added = number_of_players_added + 1
			else
				number_of_players_modified = number_of_players_modified + 1
			end
		end
	elseif essentials.is_str(f, "Remove session") then
		for pid in essentials.players() do
			remove_from_blacklist(player.get_player_name(pid), player.get_player_ip(pid), player.get_player_scid(pid))
		end
	end
end):set_str_data({
	lang["Add"],
	lang["Remove"],
	lang["Add session"],
	lang["Remove session"]
})

settings.toggle["Script quick access"] = menu.add_feature(lang["Script quick access"], "toggle", u.settingsUI.id)

settings.user_entity_features.vehicle.feats["Change user vehicle setting"] = menu.add_feature(lang["Set vehicle in use"], "action_value_str", u.settingsUI.id, function()
	local input <const>, status <const> = keys_and_input.input_user_entity("vehicle")
	if status == 2 then
		return
	end
	settings:update_user_entity(input, "vehicle")
end)

settings.user_entity_features.ped.feats["Change user ped setting"] = menu.add_feature(lang["Set ped in use"], "action_value_str", u.settingsUI.id, function()
	local input <const>, status <const> = keys_and_input.input_user_entity("ped")
	if status == 2 then
		return
	end
	settings:update_user_entity(input, "ped")
end)

settings.user_entity_features.object.feats["Change user object setting"] = menu.add_feature(lang["Set object in use"], "action_value_str", u.settingsUI.id, function()
	local input <const>, status <const> = keys_and_input.input_user_entity("object")
	if status == 2 then
		return
	end
	settings:update_user_entity(input, "object")
end)

menu.add_feature(lang["Set to \"?\" to make it random."], "action", u.settingsUI.id)

menu.add_feature(lang["Show latest update changelog"], "action", u.settingsUI.id, function(f)
	essentials.show_changelog()
end)

settings.toggle["Participate in betas"] = menu.add_feature(lang["Participate in betas"], "toggle", u.settingsUI.id, function(f)
	__kek_menu_participate_in_betas = f.on
end)

settings.toggle["Check for updates"] = menu.add_feature(lang["Check for updates"], "toggle", u.settingsUI.id, function(f)
	__kek_menu_check_for_updates = f.on
end)

settings.toggle["Debug mode"] = menu.add_feature(lang["Debug mode"], "toggle", u.debug.id, function(f)
	if f.on and keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
		essentials.msg(lang["Save settings and reset lua state to load in debug mode."], "blue", true, 12)
		essentials.msg(lang["All scripts will run slower and might lag. More errors will occur, especially if you run other scripts."], "red", true, 12)
		essentials.msg(lang["Only use this mode if you intend to find bugs."], "blue", true, 12)
	end
end)

do
	local function update_limit(f)
		keys_and_input.input_number_for_feat(f, "")
	end
	local f

	f = menu.add_feature(lang["Vehicle limit"], "action_value_i", u.debug.id, update_limit)
	f.max = 300
	settings.valuei["Vehicle limits"] = f

	f = menu.add_feature(lang["Ped limit"], "action_value_i", u.debug.id, update_limit)
	f.max = 256
	settings.valuei["Ped limits"] = f

	f = menu.add_feature(lang["Object limit"], "action_value_i", u.debug.id, update_limit)
	f.max = 2300
	settings.valuei["Object limits"] = f

end

settings.toggle["Draw entity limits"] = menu.add_feature(lang["Draw entity limits"], "toggle", u.debug.id, function(f)
	while f.on do
		system.yield(0)
		ui.set_text_color(255, 255, 255, 255)
		ui.set_text_scale(0.3)
		ui.set_text_font(0)
		ui.set_text_outline(true)
		ui.draw_text(string.format("%s: %i/%i\n%s: %i/%i\n%s: %i/%i", 
			lang["Vehicles"],
			kek_entity.entity_manager.counts.vehicle,
			settings.valuei["Vehicle limits"].value * 10,
			lang["Peds"],
			kek_entity.entity_manager.counts.ped,
			settings.valuei["Ped limits"].value * 10,
			lang["Objects"],
			kek_entity.entity_manager.counts.object,
			settings.valuei["Object limits"].value * 10
			), 
		memoize.v2(0.8, 0.8))		
	end
end)

settings.toggle["Draw entity queue"] = menu.add_feature(lang["Draw entity queue"], "toggle", u.debug.id, function(f)
	while f.on do
		system.yield(0)
		ui.set_text_color(255, 255, 255, 255)
		ui.set_text_scale(0.3)
		ui.set_text_font(0)
		ui.set_text_outline(true)
		ui.draw_text(string.format("%s: %i\n%s: %i", 
			lang["Num of entities in queue"],
			#kek_entity.spawn_queue,
			lang["Num of entities spawned"],
			kek_entity.spawn_queue_id
			), 
		memoize.v2(0.8, 0.7))		
	end
end)

settings.toggle["Draw number of script events sent"] = menu.add_feature(lang["Draw number of se sent"], "toggle", u.debug.id, function(f)
	while f.on do
		system.yield(0)
		ui.set_text_color(255, 255, 255, 255)
		ui.set_text_scale(0.3)
		ui.set_text_font(0)
		ui.set_text_outline(true)
		ui.draw_text(string.format("%s: %i", lang["Number of script events sent"], globals.script_event_tracker.id), memoize.v2(0.8, 0.78))		
	end
end)

settings.toggle["Draw garbage collection"] = menu.add_feature(lang["Draw garbage collection stats"], "toggle", u.debug.id, function(f)
	local previous, change = 0, 0
	local timer = 0
	while f.on do
		system.yield(0)
		local garbage_count <const> = math.ceil(collectgarbage("count"))
		if utils.time_ms() > timer then
			change = garbage_count - previous
			previous = garbage_count
			timer = utils.time_ms() + 500
		end
		ui.set_text_color(255, 255, 255, 255)
		ui.set_text_scale(0.3)
		ui.set_text_font(0)
		ui.set_text_outline(true)
		ui.draw_text(string.format("%s: %i\n%s: %i", 
			lang["Garbage count"], garbage_count,
			lang["Garbage change"], change
			), memoize.v2(0.8, 0.74))		
	end
end)

menu.add_feature("Benchmark function", "action", u.debug.id, function(f)
	local passes = 0
	local time = utils.time_ms() + 1000
	local func <const> = "Change this to your function"
	if type(func) ~= "function" then
		essentials.msg("Go to the source code and enter the function's name at line "..(debug.getinfo(1).currentline - 2).." in file "..(debug.getinfo(1).short_src:match("\\/(.-)$") or "Kek's menu.lua"), "red", true, 6)
		return
	end
	while time > utils.time_ms() do
		for i = 1, 10000 do
			func()
		end
		passes = passes + 1
	end
	essentials.msg((passes * 10).."k passes in 1 second.", "blue", true, 6)
end)

do
	local object_testing_parent <const> = menu.add_feature("Object test", "parent", u.debug.id)
	local f1, f2, f3
	local feat = menu.add_feature("Spawn object & draw object properties", "toggle", object_testing_parent.id, function(f)
		local model <const> = settings.user_entity_features.object.feats["Change object testing"]:get_str_data()[1]
		f.data = kek_entity.spawn_local_object(object_mapper.get_hash_from_user_input(model), function()
			return essentials.get_player_coords(player.player_id()) + 2
		end)
		f1.on = true -- Update newly spawned object to current set rot
		entity.freeze_entity(f.data, true)
		while f.on do
			ui.set_text_color(255, 255, 255, 255)
			ui.set_text_scale(0.5)
			ui.set_text_font(1)
			ui.set_text_outline(true)
			ui.draw_text(string.format("%s", entity.get_entity_rotation__native(f.data, 2)), 
			memoize.v2(0.8, 0.6))
			system.yield(0)
			if model ~= settings.user_entity_features.object.feats["Change object testing"]:get_str_data()[1] then
				kek_entity.clear_entities({f.data})
				return HANDLER_CONTINUE
			end
		end
		kek_entity.clear_entities({f.data})
	end)

	settings.user_entity_features.object.feats["Change object testing"] = menu.add_feature("Set new object", "action_value_str", object_testing_parent.id, function(f)
		local input <const>, status <const> = keys_and_input.input_user_entity("object")
		if status == 2 then
			return
		end
		settings:update_user_entity(input, "object")
	end)

	local rot_set_callback <const> = function(f)
		if entity.is_entity_an_object(feat.data or 0) then
			entity.set_entity_rotation__native(feat.data, v3(f1.value, f2.value, f3.value), 2, true)
		end
	end
	f1 = menu.add_feature("X", "autoaction_value_i", object_testing_parent.id, rot_set_callback)
	f1.min = -180 f1.max = 180 f1.mod = 5

	f2 = menu.add_feature("Y", "autoaction_value_i", object_testing_parent.id, rot_set_callback)
	f2.min = -180 f2.max = 180 f2.mod = 5

	f3 = menu.add_feature("Z", "autoaction_value_i", object_testing_parent.id, rot_set_callback)
	f3.min = -180 f3.max = 180 f3.mod = 5
end

local function vehicle_effect_standard(...)
	local remove_players <const>, effect_callback <const>, dont_yield <const> = ...
	local entities <const> = memoize.get_all_vehicles()
	local Ped <const> = essentials.get_ped_closest_to_your_pov()
	local time <const> = utils.time_ms() + 3000
	for Vehicle in essentials.entities(entities) do
		if memoize.get_distance_between(Vehicle, Ped, nil, nil, 5) < 200
		and not entity.is_entity_attached(Vehicle)
		and (not remove_players or not vehicle.get_vehicle_has_been_owned_by_player(Vehicle))
		and kek_entity.get_control_of_entity(Vehicle, 0) then
			effect_callback(Vehicle, Ped, entities)
			entity.set_entity_as_no_longer_needed(Vehicle)
			if not dont_yield then 
				system.yield(0)
			end
		end
	end
	while time > utils.time_ms() do
		system.yield(0)
	end
end		

settings.valuei["Horn boost speed"] = menu.add_feature(lang["Horn boost"], "slider", u.session_peaceful.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if player.is_player_in_any_vehicle(pid)
			and player.is_player_pressing_horn(pid)
			and not menu.get_player_feature(player_feat_ids["Player horn boost"]).feats[pid].on 
			and (not f.data[player.get_player_scid(pid)] or utils.time_ms() > f.data[player.get_player_scid(pid)]) 
			and kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
				vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), math.min(150, entity.get_entity_speed(player.get_player_vehicle(pid)) + f.value))
				f.data[player.get_player_scid(pid)] = utils.time_ms() + 550
			end
		end
	end
end)
settings.valuei["Horn boost speed"].data = {}
settings.valuei["Horn boost speed"].max = 100
settings.valuei["Horn boost speed"].min = 5
settings.valuei["Horn boost speed"].mod = 5
settings.toggle["Horn boost"] = settings.valuei["Horn boost speed"]

menu.add_feature(lang["Max nearby cars"], "toggle", u.vehicle_friendly.id, function(f)
	local max_car <const> = function(car)
		kek_entity.max_car(car)
	end
	while f.on do
		system.yield(0)
		vehicle_effect_standard(true, max_car)
	end
end)

menu.add_feature(lang["Repair nearby cars"], "toggle", u.vehicle_friendly.id, function(f)
	local func <const> = function(car)
		kek_entity.repair_car(car)
	end
	while f.on do
		system.yield(0)
		vehicle_effect_standard(true, func)
	end			
end)

menu.add_feature(lang["Give nearby cars godmode"], "toggle", u.vehicle_friendly.id, function(f)
	local func <const> = function(car) 
		kek_entity.modify_entity_godmode(car, true) 
	end
	while f.on do
		system.yield(0)
		vehicle_effect_standard(true, func)
	end
	vehicle_effect_standard(true, function(car) 
		kek_entity.modify_entity_godmode(car, false) 
	end)
end)

menu.add_feature(lang["Nearby cars have no collision"], "toggle", u.vehicle_friendly.id, function(f)
	local tracker = {}
	while f.on do 
		system.yield(0)
		local entities <const> = vehicle.get_all_vehicles()
		local Ped <const> = essentials.get_ped_closest_to_your_pov()
		for Vehicle in essentials.entities(entities) do
			if utils.time_ms() > (tracker[Vehicle] or 0)
			and player.get_player_vehicle(player.player_id()) ~= Vehicle
			and memoize.get_distance_between(Vehicle, Ped, nil, nil, 5) < 150
			and kek_entity.get_control_of_entity(Vehicle, 0) then
				entity.set_entity_no_collsion_entity(Vehicle, kek_entity.get_most_relevant_entity(player.get_player_from_ped(essentials.get_ped_closest_to_your_pov())), false)
				tracker[Vehicle] = utils.time_ms() + 500
			end
		end
	end
	vehicle_effect_standard(true, function(car)
		entity.set_entity_no_collsion_entity(car, kek_entity.get_most_relevant_entity(player.get_player_from_ped(essentials.get_ped_closest_to_your_pov())), true)
	end, true)
end)

u.modify_nearby_car_top_speed = menu.add_feature(lang["Drive force multiplier"], "value_f", u.vehicle_friendly.id, function(f)
	local func <const> = function(car)
		entity.set_entity_max_speed(car, 45000)
		vehicle.modify_vehicle_top_speed(car, (f.value - 1) * 100)
	end
	while f.on do 
		system.yield(0)
		vehicle_effect_standard(true, func)
	end
end)
u.modify_nearby_car_top_speed.max = 20.0
u.modify_nearby_car_top_speed.min = -4.0
u.modify_nearby_car_top_speed.mod = 0.1
u.modify_nearby_car_top_speed.value = 1.0

local gravity <const> = menu.add_feature(lang["Gravity"], "value_f", u.vehicle_friendly.id, function(f)
	local func <const> = function(car)
		if player.get_player_vehicle(player.player_id()) ~= car then
			vehicle.set_vehicle_gravity_amount(car, f.value)
		end
	end
	while f.on do 
		system.yield(0)
		vehicle_effect_standard(true, func)
	end
	vehicle_effect_standard(true, function(car)
		if player.get_player_vehicle(player.player_id()) ~= car then
			vehicle.set_vehicle_gravity_amount(car, 9.8)
		end
	end)
end)
gravity.min = -980.0
gravity.max = 980.0
gravity.mod = 9.8
gravity.value = 9.8

local swap_nearby_to_police
do
	local police_vehicle_models <const> = essentials.const({
		"fbi",
		"fbi2",
		"police",
		"police2",
		"police3",
		"police4",
		"policeb",
		"policet",
		"policeold1",
		"policeold2",
		"pranger",
		"riot",
		"sheriff",
		"sheriff2"
	})
	local police_vehicle_map <const> = {}
	for i = 1, #police_vehicle_models do
		police_vehicle_map[gameplay.get_hash_key(police_vehicle_models[i])] = true
	end

	local police_ped_models <const> = essentials.const({
		"s_m_y_ranger_01",
		"s_m_y_sheriff_01",
		"s_m_y_cop_01",
		"s_f_y_sheriff_01",
		"s_f_y_cop_01",
		"s_m_y_hwaycop_01"
	})

	local police_weapons <const> = essentials.const({
		"weapon_pumpshotgun",
		"weapon_pistol",
		"weapon_carbinerifle"
	})

	local combat_attributes <const> = essentials.const(		{
		use_vehicle = true, 
		driveby = true,
		cover = true,
		leave_vehicle = true, 
		unarmed_fight_armed = true, 
		taunt_in_vehicle = false, 
		always_fight = true, 
		ignore_traffic = true, 
		use_fireing_weapons =  true
	})

	swap_nearby_to_police = menu.add_feature(lang["Swap nearby vehicles to police"], "toggle", u.session_trolling.id, function(f)
		settings.user_entity_features.vehicle.feats["Swap nearby cars"].on = false
		local buf <const> = {}
		while f.on and not settings.user_entity_features.vehicle.feats["Swap nearby cars"].on do
			system.yield(0)
			for Vehicle in essentials.entities(vehicle.get_all_vehicles()) do
				if not f.on or settings.user_entity_features.vehicle.feats["Swap nearby cars"].on then
					break
				end
				local entity_status <const> = kek_entity.entity_manager:update()
				if not police_vehicle_map[entity.get_entity_model_hash(Vehicle)]
				and entity_status.is_ped_limit_not_breached
				and entity_status.is_vehicle_limit_not_breached
				and (entity.is_entity_a_ped(entity.get_entity_attached_to(Vehicle)) or entity.get_entity_attached_to(Vehicle) == 0)
				and not vehicle.get_vehicle_has_been_owned_by_player(Vehicle) then
					if not select(2, kek_entity.get_number_of_passengers(Vehicle)) then
						local velocity <const> = entity.get_entity_velocity(Vehicle)
						local pos <const> = entity.get_entity_coords(Vehicle)
						local heading <const> = entity.get_entity_heading(Vehicle)
						buf[1] = Vehicle
						kek_entity.clear_entities(buf)
						if not entity.is_entity_a_vehicle(Vehicle) then
							local new_vehicle <const> = kek_entity.spawn_networked_vehicle(
								entity.is_entity_in_air(Vehicle) and gameplay.get_hash_key("polmav") or gameplay.get_hash_key(police_vehicle_models[math.random(1, #police_vehicle_models)]), 
								function()
									return pos, heading
								end, {
									godmode = false,
									max = false,
									persistent = false
								})
							kek_entity.max_car(new_vehicle, true) -- Only maxes performance
							local police <const> = kek_entity.spawn_networked_ped(gameplay.get_hash_key(police_ped_models[math.random(1, #police_ped_models)]), function()
								return essentials.get_player_coords(player.player_id()) + 30, 0
							end, enums.ped_types.cop)
							kek_entity.set_combat_attributes(police, false, combat_attributes)
							ped.set_ped_relationship_group_hash(police, enums.relationship_group_hashes.COP) -- Must go after set_combat_attributes. It sets relationship hash to hate_player.
							ped.set_can_attack_friendly(police, false, false)
							local weapon_hash <const> = gameplay.get_hash_key(police_weapons[math.random(1, #police_weapons)])
							weapon.give_delayed_weapon_to_ped(police, weapon_hash, 0, 0)
							weapon_mapper.set_ped_weapon_attachments(police, true, weapon_hash)
							ped.set_ped_into_vehicle(police, new_vehicle, -1)
							kek_entity.set_entity_heading(new_vehicle, heading)
							entity.set_entity_velocity(new_vehicle, velocity)
							entity.set_entity_as_no_longer_needed(police)
							entity.set_entity_as_no_longer_needed(new_vehicle)
						end
					end
				end
			end
		end
		f.on = false
	end)
end

settings.user_entity_features.vehicle.feats["Swap nearby cars"] = menu.add_feature(lang["Swap nearby cars"], "value_str", u.vehicle_friendly.id, function(f)
	swap_nearby_to_police.on = false
	while f.on do
		system.yield(0)
		local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
		if streaming.is_model_a_vehicle(hash) then
			for Vehicle in essentials.entities(memoize.get_all_vehicles()) do
				if not f.on or swap_nearby_to_police.on then
					break
				end
				local Ped <const> = essentials.get_ped_closest_to_your_pov()
				local entity_status <const> = kek_entity.entity_manager:update()
				if entity_status.is_ped_limit_not_breached
				and entity_status.is_vehicle_limit_not_breached
				and not entity.is_entity_in_air(Vehicle)
				and (entity.is_entity_a_ped(entity.get_entity_attached_to(Vehicle)) or entity.get_entity_attached_to(Vehicle) == 0)
				and not vehicle.get_vehicle_has_been_owned_by_player(Vehicle)
				and not ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver)) 
				and not vehicle.is_vehicle_model(Vehicle, hash) 
				and memoize.get_distance_between(Ped, Vehicle) < 240
				and kek_entity.get_control_of_entity(Vehicle, 0) then
					if not select(2, kek_entity.get_number_of_passengers(Vehicle)) then
						local velocity = memoize.v3()
						local car <const> = kek_entity.spawn_networked_vehicle(hash, function()
							local pos <const>, dir <const> = entity.get_entity_coords(Vehicle), entity.get_entity_heading(Vehicle)
							velocity = entity.get_entity_velocity(Vehicle)
							kek_entity.clear_entities({Vehicle})
							return pos, dir
						end, {
							godmode = entity.get_entity_god_mode(Vehicle), 
							max = true,
							persistent = false
						})
						if entity.is_entity_a_vehicle(car) then
							entity.set_entity_velocity(car, velocity)
							local Ped <const> = kek_entity.spawn_networked_ped(ped_mapper.get_random_ped("all peds except animals"), function() 
								return essentials.get_player_coords(player.player_id()) + 30, 0
							end)
							if entity.is_entity_a_ped(Ped) then
								ped.set_ped_into_vehicle(Ped, car, enums.vehicle_seats.driver)
								ai.task_vehicle_drive_wander(Ped, car, 150, settings.in_use["Drive style"])
							else
								kek_entity.clear_entities({Vehicle})
							end
							entity.set_entity_as_no_longer_needed(Ped)
							entity.set_entity_as_no_longer_needed(car)
						end
					end
				end
			end
		end
	end
end)

menu.add_feature(lang["Vehicle fly nearby vehicles"], "toggle", u.vehicle_friendly.id, function(f)
	while f.on do
		system.yield(0)
		local control_indexes <const> = essentials.const({
			enums.inputs["W LEFT STICK"],
			enums.inputs["S LEFT STICK"],
			forward_button = enums.inputs["W LEFT STICK"],
			backward_button = enums.inputs["S LEFT STICK"]

		})
		local cars <const> = essentials.const_all(kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(
			{
				vehicles = {
					entities 			   = vehicle.get_all_vehicles(),
					max_number_of_entities = 35,
					remove_player_entities = true,
					max_range			   = nil,
					sort_by_closest 	   = true
				}
			},
			essentials.get_ped_closest_to_your_pov()
		))
		for i = 1, 2 do
			while f.on and controls.is_disabled_control_pressed(0, control_indexes[i]) do
				system.yield(0)
				local speed <const> = essentials.const({
					settings.valuei["Vehicle fly speed"].value, 
					-settings.valuei["Vehicle fly speed"].value
				})
				for i2 = 1, #cars.vehicles do
					if kek_entity.get_control_of_entity(cars.vehicles[i2], 25) then
						entity.set_entity_rotation(cars.vehicles[i2], cam.get_gameplay_cam_rot())
						entity.set_entity_max_speed(cars.vehicles[i2], 45000)
						vehicle.set_vehicle_forward_speed(cars.vehicles[i2], speed[i])
					end
				end
			end
		end
		while f.on and not controls.is_disabled_control_pressed(0, control_indexes.forward_button) and not controls.is_disabled_control_pressed(0, control_indexes.backward_button) do
			system.yield(0)
			for i = 1, #cars.vehicles do
				if kek_entity.get_control_of_entity(cars.vehicles[i], 25) then
					entity.set_entity_velocity(cars.vehicles[i], memoize.v3())
					entity.set_entity_rotation(cars.vehicles[i], cam.get_gameplay_cam_rot())
				end
			end
		end
	end
end)

settings.user_entity_features.vehicle.feats["Ram everyone"] = menu.add_feature(lang["Ram everyone"], "value_str", u.session_trolling.id, function(f)
	local hash, vehicle_name
	while f.on do
		if vehicle_name ~= settings.in_use["User vehicle"] then
			hash = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
			vehicle_name = settings.in_use["User vehicle"]
		end
		if streaming.is_model_a_vehicle(hash) then
			local entities <const> = {}
			for pid in essentials.players() do
				if f.on
				and essentials.is_not_friend(pid) 
				and not player.is_player_god(pid)
				and not entity.is_entity_dead(player.get_player_ped(pid)) then
					entities[#entities + 1] = essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, pid, false, 8, hash)
				end
				if #entities > 0 then
					entity.set_entity_as_no_longer_needed(entities[#entities])
				end
				if not f.on then
					break
				end
			end
			system.yield(350)
			kek_entity.clear_entities(entities)
		else
			system.yield(0)
		end
	end
end)

menu.add_feature(lang["Disable vehicles"], "toggle", u.session_malicious.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if (player.get_player_vehicle(player.player_id()) == 0 or player.get_player_vehicle(pid) ~= player.get_player_vehicle(player.player_id())) then
				globals.disable_vehicle(pid, true)
			end
		end
		system.yield(250)
	end
end)

local disable_weapons
do
	local disable_weapon_tasks <const> = {
		enums.ctasks.AimGunOnFoot,
		enums.ctasks.Weapon,
		enums.ctasks.PlayerWeapon,
		enums.ctasks.SwapWeapon,
		enums.ctasks.Gun,
		enums.ctasks.Melee,
		enums.ctasks.MoveMeleeMovement,
		enums.ctasks.MeleeActionResult,
		enums.ctasks.MeleeUpperbodyAnims,
		enums.ctasks.ComplexEvasiveStep,
		enums.ctasks.MountThrowProjectile,
		enums.ctasks.AimGunVehicleDriveBy,
		enums.ctasks.AimAndThrowProjectile,
		enums.ctasks.ThrowProjectile,
		enums.ctasks.AimFromGround,
		enums.ctasks.AimGunScripted,
		enums.ctasks.ReloadGun,
		enums.ctasks.VehicleGun, 
		enums.ctasks.Bomb	
	}
	local tracker <const> = {}

	disable_weapons = function(...)
		local f <const>, pid <const> = ...
		if utils.time_ms() > (tracker[pid] or 0) and #kek_entity.is_any_tasks_active(player.get_player_ped(pid), disable_weapon_tasks) > 0 then
			if essentials.is_str(f, "Clear tasks") then
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			elseif essentials.is_str(f, "Taze") then
				local time <const> = utils.time_ms() + 500
				while time > utils.time_ms() do
					gameplay.shoot_single_bullet_between_coords(
						kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 0.3), 
						select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f1, memoize.v3())), 
						0, 
						gameplay.get_hash_key("weapon_stungun"), 
						player.get_player_ped(player.player_id()), 
						true, 
						false, 
						1000
					)
					system.yield(0)
				end
				tracker[pid] = utils.time_ms() + 1000
			elseif essentials.is_str(f, "Explode") then
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
				essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), enums.explosion_types.BLIMP, true, false, 0, player.get_player_ped(pid))
				tracker[pid] = utils.time_ms() + 1000
			elseif essentials.is_str(f, "Explode with blame") then
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
				essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), enums.explosion_types.BLIMP, true, false, 0, player.get_player_ped(player.player_id()))
				tracker[pid] = utils.time_ms() + 1000
			end
		end
	end
end

menu.add_feature(lang["Disable weapons"], "value_str", u.session_malicious.id, function(f, pid)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) then
				disable_weapons(f, pid)
			end
		end
	end
end):set_str_data({
	lang["Clear tasks"],
	lang["Taze"],
	lang["Explode"],
	lang["Explode with blame"]
})

do
	local weapon_hashes_to_blacklist <const> = {}
	settings.toggle["Weapon blacklist"] = menu.add_feature(lang["Weapon blacklist"], "value_str", u.weapon_blacklist.id, function(f)
		while f.on do
			system.yield(0)
			for hash in pairs(weapon_hashes_to_blacklist) do
				system.yield(0)
				for pid in essentials.players() do
					local scid <const> = player.get_player_scid(pid)
					if (not f.data[scid] or not f.data[scid][hash] or f.data[scid][hash] < utils.time_ms())
					and essentials.is_not_friend(pid)
					and weapon.has_ped_got_weapon(player.get_player_ped(pid), hash) then
						weapon.remove_weapon_from_ped(player.get_player_ped(pid), hash)
						essentials.msg(string.format("%s %s\'s %s.", lang["Removed"], player.get_player_name(pid), weapon.get_weapon_name(hash)), "orange", essentials.is_str(f, "Notifications on"))
						if not f.data[scid] then
							f.data[scid] = {}
						end
						f.data[scid][hash] = utils.time_ms() + 60000
					end
				end
			end
		end
	end)
	settings.toggle["Weapon blacklist"]:set_str_data({
		lang["Notifications on"],
		lang["Notifications off"]
	})
	settings.valuei["Weapon blacklist notifications"] = settings.toggle["Weapon blacklist"]
	settings.toggle["Weapon blacklist"].data = {}

	local weapons_added <const> = {}
	for i, weapon_group_name in pairs({
		lang["Rifles"],
		lang["SMGs"],
		lang["Shotguns"],
		lang["Pistols"],
		lang["Explosives"],
		lang["Throwables"],
		lang["Heavy"],
		lang["Melee"],
		lang["Miscellaneous"]
	}) do
		local parent <const> = menu.add_feature(weapon_group_name, "parent", u.weapon_blacklist.id)
		for _, hash in pairs(weapon_mapper.get_table_of_weapons({
			rifles = 1 == i,
			smgs = 2 == i,
			shotguns = 3 == i,
			pistols = 4 == i,
			explosives_heavy = 5 == i,
			throwables = 6 == i,
			heavy = 7 == i,
			melee = 8 == i,
			misc = 9 == i
		})) do
			if not weapons_added[hash] then
				local setting_name <const> = "weapon_blacklist_"..weapon.get_weapon_name(hash)
				weapons_added[hash] = true
				settings:add_setting({
					setting_name = setting_name,
					setting = false
				})
				settings.toggle[setting_name] = menu.add_feature(weapon.get_weapon_name(hash), "toggle", parent.id, function(f)
					weapon_hashes_to_blacklist[f.data] = f.on or nil
				end)
				settings.toggle[setting_name].data = hash
			end
		end
	end
end

function player_history.sort_numbers(t)
	table.sort(t, function(a, b) return (tonumber(a:match("[%d]+")) or 0) > (tonumber(b:match("[%d]+")) or 0) end)
	return t
end

function player_history.add_features(main_parent, rid, ip, name)
	if main_parent.child_count == 0 then
		local blacklist_feat
		menu.add_feature(lang["Copy to clipboard"], "action_value_str", main_parent.id, function(f, pid)
			if essentials.is_str(f, "rid") then
				utils.to_clipboard(rid)
			elseif essentials.is_str(f, "ip") then
				utils.to_clipboard(ip)
			elseif essentials.is_str(f, "name") then
				utils.to_clipboard(name)
			end
		end):set_str_data({
			lang["rid"],
			lang["ip"],
			lang["name"]
		})

		menu.add_feature(lang["Blacklist"], "action_value_str", main_parent.id, function(f)
			if essentials.is_str(f, "Add") then
				local input <const>, status <const> = keys_and_input.get_input(lang["Type in why you're adding this person."], "", 128, 0)
				if status == 2 then
					return
				end
				add_to_blacklist(name, essentials.ipv4_to_dec(ip), rid, input, true)
				for pid in essentials.players() do
					if rid == player.get_player_scid(pid) then
						player.mark_as_modder(pid, keks_custom_modder_flags["Blacklist"])
						break
					end
				end
				if blacklist_feat then
					blacklist_feat.name = string.format("%s: %s", lang["Blacklist reason"], input)
				end
			elseif essentials.is_str(f, "Remove") then
				remove_from_blacklist(name, essentials.ipv4_to_dec(ip), rid, true)
				if blacklist_feat then
					blacklist_feat.name = string.format("%s: %s", lang["Blacklist reason"], lang["isn't blacklisted"])
				end
			end
		end):set_str_data({
			lang["Add"],
			lang["Remove"]
		})

		local seen <const> = {}
		local matches <const> = {}
		local known_as <const> = {}
		local what_to_check <const> = {}
		if settings.toggle["Check rid in also known as"].on then
			what_to_check[#what_to_check + 1] = string.format("&%i&", rid)
		end
		if settings.toggle["Check name in also known as"].on then
			what_to_check[#what_to_check + 1] = string.format("|%s|", name)
		end
		if settings.toggle["Check ip in also known as"].on then
			what_to_check[#what_to_check + 1] = string.format("^%s^", ip)
		end
		if #what_to_check > 0 then -- In case all toggles are off
			local str <const> = essentials.get_file_string(paths.player_history_all_players, "rb")
			for _, input in pairs(what_to_check) do
				local End, start = 0
				repeat
					start, End = str:find(input, End + 1, true)
					if start then
						local str_pos <const> = essentials.get_position_of_previous_newline(str, start)
						local line <const> = str:sub(str_pos, str:find("[\r\n]", start))
						if not matches[line] then
							seen[#seen + 1] = {
								feat_name = string.format("%s %s", line:match("<(.-)>"), line:match("!(.-)!")),
								date = line:match("<(.-)>") or "01/01/01", -- Older versions of the script didn't support dates.
								time = line:match("!(.-)!") or "01:01:01" -- Older versions of the script didn't support times.
							}
							matches[line] = true
							known_as[line:match("|(.-)|")] = {
								matched = input:sub(2, -2), 
								name = line:match("|(.-)|") or "",
								date = line:match("<(.-)>") or ""
							}
						end
					end
				until not start
			end
			table.sort(seen, function(a, b)
				return essentials.date_to_int(a.date) + essentials.time_to_float(a.time) < essentials.date_to_int(b.date) + essentials.time_to_float(b.time)
			end)

			local feat
			local temporarily_disable_copy_to_clipboard
			menu.add_feature(lang["Chat log"], "parent", main_parent.id, function(parent)
				if not settings.toggle["Chat logger"].on then
					essentials.msg(lang["For chat to show here, chat logger must be on. You can find chat logger in script features > Chat"], "blue", true, 8)
				end
				local str <const> = essentials.get_file_string(paths.kek_menu_stuff.."kekMenuLogs\\Chat log.log", "rb")
				local name <const> = main_parent.name:sub(1, 16)
				local spaces <const> = string.rep("\32", 16 - (utf8.len(name) or #name))
				parent.data = essentials.get_all_matches(str, "["..name..spaces.."]", "%]:\32(.+)")
				if parent.child_count == 0 then
					local feats <const> = {}
					feat = menu.add_feature(lang["Scroll through messages"], "autoaction_value_i", parent.id, function(f)
						if #parent.data > 0 then
							local i2 = 1
							for i = f.value - 10, f.value - 1 do
								local str <const> = parent.data[#parent.data - i]
								feats[i2].hidden = str == nil
								if not feats[i2].hidden then
									feats[i2].data = essentials.split_string(str, 34)
									feats[i2].name = essentials.get_safe_feat_name(feats[i2].data[1])
									feats[i2].min = math.min(1, #feats[i2].data)
									feats[i2].max = #feats[i2].data
									feats[i2].mod = 1
								end
								i2 = i2 + 1
							end
						end
						if utils.time_ms() > temporarily_disable_copy_to_clipboard and keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
							local str <const> = {}
							for i = f.value - f.mod, f.value - 1 do
								str[#str + 1] = parent.data[#parent.data - i]
							end
							utils.to_clipboard(table.concat(str, "\n"))
							essentials.msg(lang["Copied to clipboard."], "blue", true, 3)
						end
					end)
					for i = 1, 10 do
						feats[i] = menu.add_feature("", "autoaction_value_i", parent.id, function(f)
							if keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
								utils.to_clipboard(table.concat(f.data))
								essentials.msg(lang["Copied to clipboard."], "blue", true, 3)
							end
							f.name = essentials.get_safe_feat_name(f.data[f.value])
						end)
						feats[i].hidden = true
					end
				end
				feat.min = 10
				feat.max = math.ceil(#parent.data / 10) * 10
				feat.mod = 10
				temporarily_disable_copy_to_clipboard = utils.time_ms() + 500
				feat.on = true -- Forces update of chat features
			end)

			local is_added_to_join_timeout = essentials.search_for_match_and_get_line(paths.home.."cfg\\scid.cfg", {string.format("%x", rid), name}) or ""
			local fake_friend_flags = tonumber(is_added_to_join_timeout:match(".+:%x+:(%x+)$") or "", 16)
			menu.add_feature(lang["Is added to join timeout"], "action_value_str", main_parent.id):set_str_data({tostring(fake_friend_flags ~= nil and fake_friend_flags & 4 == 4)})

			local is_blacklisted <const> = essentials.search_for_match_and_get_line(paths.blacklist, {string.format("/%i/", rid), string.format("&%s&", essentials.ipv4_to_dec(ip)), string.format("§%s§", name)}) or ""
			blacklist_feat = menu.add_feature(string.format("%s: %s", lang["Blacklist reason"], is_blacklisted:match("<(.+)>") or lang["isn't blacklisted"]), "action", main_parent.id)

			menu.add_feature(string.format("%s: %s", lang["First seen"], seen[1].feat_name), "action", main_parent.id)
			if #seen > 1 then
				menu.add_feature(string.format("%s: %s", lang["Last seen"], seen[#seen].feat_name), "action", main_parent.id)
				menu.add_feature(string.format("%s %i %s", lang["Seen"], #seen, lang["times."]), "action", main_parent.id)
			else
				menu.add_feature(string.format("%s 1 %s", lang["Seen"], lang["time."]), "action", main_parent.id)
			end
			menu.add_feature(lang["Also known as"]..":", "action_value_str", main_parent.id):set_str_data({lang["What is known for"]})
			for _, properties in pairs(known_as) do
				if not main_parent.name:find(properties.name, 1, true) then
					menu.add_feature(string.format("%s [%s]", properties.name, properties.date), "action_value_str", main_parent.id):set_str_data({properties.matched})
				end
			end
		end
	end
end

do
	local function search(file, pattern_input, f)
		essentials.assert(#pattern_input > 0, "Tried to get all matches with an empty pattern.")
		local str <const> = file:read("*a")
		local End, start, results = 0
		repeat
			start, End = str:find(pattern_input, End + 1) 
			if start then
				results = start
			end
		until not start or essentials.is_str(f, "search oldest to newest") or pattern_input == ""
		return results, str
	end
	menu.add_feature(lang["Player history"], "action_value_str", u.player_history.id, function(f)
		if essentials.is_str(f, "search newest to oldest") or essentials.is_str(f, "search oldest to newest") then
			local input, status <const> = keys_and_input.get_input(lang["Type in what player you wanna search for. rid / name / ip"], "", 128, 0)
			if status == 2 then
				return
			end
			if input == "" then
				essentials.msg(lang["Cancelled."], "blue", true)
				return
			end

			local pattern_input <const> = essentials.make_string_case_insensitive(essentials.remove_special(input))
			local file <close> = io.open(paths.player_history_all_players, "rb")
			local results, str
			if essentials.is_str(f, "search newest to oldest") then
				file:seek("end", -math.min(file:seek("end"), 65 * 801))
				file:read("*l") -- Makes sure there is no partial line being read
				results, str = search(file, pattern_input, f)
			end
			if not results then
				file:seek("set")
				results, str = search(file, pattern_input, f)
			end
			if results then
				local str_pos <const> = essentials.get_position_of_previous_newline(str, results)
				local line <const> = str:sub(str_pos, str:find("[\r\n]", results))
				local name <const> = line:match("|(.+)|") or "" 
				local rid <const> = line:match("&(%d+)&") or ""
				local ip <const> = line:match("%^([%d.]+)%^") or ""
				player_history.searched_players[#player_history.searched_players + 1] = menu.add_feature(name, "parent", u.player_history.id, function(f)
					player_history.add_features(f, rid, ip, name)	
				end)
			else
				essentials.msg(lang["Couldn't find player."], "red", true)
			end
		elseif essentials.is_str(f, "Clear search list") then
			for i, parent in pairs(player_history.searched_players) do
				for _, child in pairs(essentials.get_descendants(parent, {}, true)) do
					essentials.delete_feature(child.id)
				end
				player_history.searched_players[i] = nil
			end
		end
	end):set_str_data({
		lang["search newest to oldest"],
		lang["search oldest to newest"],
		lang["Clear search list"]	
	})
end

for _, year in pairs(player_history.sort_numbers(utils.get_all_sub_directories_in_directory(paths.kek_menu_stuff.."Player history"))) do
	local year_folder <const> = paths.kek_menu_stuff.."Player history\\"..year
	player_history.year_parents[year_folder] = menu.add_feature(year, "parent", u.player_history.id)

	for _, month in pairs(player_history.sort_numbers(utils.get_all_sub_directories_in_directory(year_folder))) do
		local month_folder <const> = year_folder.."\\"..month
		player_history.month_parents[month_folder] = menu.add_feature(string.gsub(month:gsub("_", " "), "%d", ""), "parent", player_history.year_parents[year_folder].id)

		for i, day in pairs(player_history.sort_numbers(utils.get_all_sub_directories_in_directory(month_folder))) do
			if i == 3 then
				goto exit
			end
			local day_folder <const> = month_folder.."\\"..day
			player_history.day_parents[day_folder] = menu.add_feature(day, "parent", player_history.month_parents[month_folder].id)

			for _, current_file in pairs(player_history.sort_numbers(utils.get_all_files_in_directory(day_folder, "log"))) do
				local file_path <const> = day_folder.."\\"..current_file
				player_history.hour_parents[file_path] = menu.add_feature(current_file:gsub("%.log$", ""), "parent", player_history.day_parents[day_folder].id)

				for name, rid, ip, time in essentials.get_file_string(file_path):gmatch("|([^\n\r|]+)| &(%d+)& %^([%d.]+)%^ !([%d:]+)!") do
					menu.add_feature(essentials.get_safe_feat_name(string.format("%s [%s]", name, time)), "parent", player_history.hour_parents[file_path].id, function(f)
						player_history.add_features(f, rid, ip, name)	
					end)
					player_history.players_added_to_history[string.format("|%s| &%d& ^%s^", name, rid, ip)] = true
				end
			end
		end
	end
end
::exit::

do
	local parent <const> = menu.add_feature(lang["Settings"], "parent", u.player_history.id)
	settings.toggle["Player history"] = menu.add_feature(lang["Player history"], "toggle", parent.id, function(f)
		while f.on do
			system.yield(0)
			for pid in essentials.players() do
				if not player_history.players_added_to_history(pid) then
					local day_num = os.date("%d")
					if day_num == "1" then
						day_num = "1st"
					elseif day_num == "2" then
						day_num = "2nd"
					elseif day_num == "3" then
						day_num = "3rd"
					else
						day_num = day_num.."th"
					end
					local year <const> = 			os.date("%Y")
					local time <const> = 			os.date("%H").." o'clock"
					local month <const> = 			string.format("%s_%s", os.date("%B"), os.date("%m"))
					local day <const> = 			string.format("%s %s of %s", os.date("%A"), day_num, month:match("(.+)_"))
					local year_folder <const> = 	string.format("%sPlayer history\\%s", paths.kek_menu_stuff, year)
					local month_folder <const> = 	string.format("%s\\%s", year_folder, month)
					local day_folder <const> = 		string.format("%s\\%s", month_folder, day)
					local file_path <const> = 		string.format("%s\\%s.log", day_folder, time)

					if not utils.dir_exists(year_folder) then
						utils.make_dir(year_folder)
					end
					if not utils.dir_exists(month_folder) then
						utils.make_dir(month_folder)
					end
					if not utils.dir_exists(day_folder) then
						utils.make_dir(day_folder)
					end
					if not utils.file_exists(file_path) then
						essentials.create_empty_file(file_path)
					end

					if not player_history.year_parents[year_folder] then
						player_history.year_parents[year_folder] = menu.add_feature(year, "parent", u.player_history.id)
					end
					if not player_history.month_parents[month_folder] then
						player_history.month_parents[month_folder] = menu.add_feature(string.gsub(month:gsub("_", " "), "%d", ""), "parent", player_history.year_parents[year_folder].id)
					end
					if not player_history.day_parents[day_folder] then
						player_history.day_parents[day_folder] = menu.add_feature(day, "parent", player_history.month_parents[month_folder].id)
					end
					if not player_history.hour_parents[file_path] then
						player_history.hour_parents[file_path] = menu.add_feature(time, "parent", player_history.day_parents[day_folder].id)
					end

					local name <const> = player.get_player_name(pid)
					local rid <const> = player.get_player_scid(pid)
					local ip <const> = essentials.dec_to_ipv4(player.get_player_ip(pid))
					local info_to_log <const> = string.format("|%s| &%d& ^%s^ !%s! <%s>", name, rid, ip, os.date("%X"), os.date("%x"))

					for _, hour in pairs(player_history.sort_numbers(utils.get_all_files_in_directory(day_folder, "log"))) do
						if essentials.search_for_match_and_get_line(day_folder.."\\"..hour..".log", {string.format("|%s|", name)}) then
							player_history.players_added_to_history[pid] = true
							break
						end
					end
					if not player_history.players_added_to_history(pid) then
						essentials.log(file_path, info_to_log)
						essentials.log(paths.player_history_all_players, info_to_log)
						local name_of_feat <const> = string.format("%s [%s]", name, os.date("%X"))
						menu.add_feature(name_of_feat, "parent", player_history.hour_parents[file_path].id, function(f)
							if f.child_count == 0 then
								player_history.add_features(f, rid, ip, name)
							end
						end)
						player_history.players_added_to_history[pid] = true
					end
				end
				system.yield(0)
			end
		end
	end)

	settings.toggle["Check rid in also known as"] = menu.add_feature(lang["Check rid in also known as"], "toggle", parent.id)
	settings.toggle["Check name in also known as"] = menu.add_feature(lang["Check name in also known as"], "toggle", parent.id)
	settings.toggle["Check ip in also known as"] = menu.add_feature(lang["Check ip in also known as"], "toggle", parent.id)
end

menu.add_player_feature(lang["Script event crash"], "action", u.malicious_player_features, function(f, pid)
	globals.script_event_crash(pid) 
end)

menu.add_player_feature(lang["Crash"], "action", u.malicious_player_features, function(f, pid)
	if player.player_count() == 0 then
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		return
	end
	local Vehicle <const> = menyoo.spawn_xml_vehicle(paths.kek_menu_stuff.."kekMenuLibs\\data\\Truck.xml", player.player_id())
	if entity.is_entity_a_vehicle(Vehicle) then
		entity.set_entity_visible(Vehicle, false)
		entity.set_entity_collision(Vehicle, false, false, false)
		entity.freeze_entity(Vehicle, true)
		local time <const> = utils.time_ms() + 1500
		while time > utils.time_ms() and entity.is_entity_a_vehicle(Vehicle) and player.is_player_valid(pid) do
			kek_entity.teleport(Vehicle, essentials.get_player_coords(pid))
			system.yield(0)
		end
		if not entity.is_entity_a_vehicle(Vehicle) then
			essentials.msg(lang["Crash entity went out of memory before it could be cleaned up."], "red", true, 6)
			return
		end
		kek_entity.teleport(Vehicle, v3(math.random(20000, 24000), math.random(20000, 24000), math.random(-2400, 2400)))
		kek_entity.hard_remove_entity_and_its_attachments(Vehicle)
		if entity.is_entity_a_vehicle(Vehicle) then
			essentials.msg(lang["Failed to cleanup crash entity while it is still in memory."], "red", true, 6)
		end
	end
end)

menu.add_player_feature(lang["Disable weapons"], "value_str", u.malicious_player_features, function(f, pid)
	while f.on do
		system.yield(0)
		disable_weapons(f, pid)
	end
end):set_str_data({
	lang["Clear tasks"],
	lang["Taze"],
	lang["Explode"],
	lang["Explode with blame"]
})

menu.add_player_feature(lang["Disable vehicles"], "toggle", u.malicious_player_features, function(f, pid)
	while f.on do
		globals.disable_vehicle(pid)
		system.yield(2000)
	end
end)

settings.user_entity_features.vehicle.player_feats["Hurricane"] = menu.add_player_feature(lang["Hurricane"], "value_str", u.malicious_player_features, function(f, pid)
	if player.player_count() == 0 then
		f.on = false
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		return
	end
	essentials.set_all_player_feats_except(menu.get_player_feature(f.id).id, false, {[pid] = true})
	local vehicles <const> = {}
	menu.create_thread(function()
		while f.on do
			system.yield(0)
			for i = 1, 7 do
				if not entity.is_entity_a_vehicle(vehicles[i] or 0) then
					local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
					if streaming.is_model_a_vehicle(hash) then
						vehicles[i] = kek_entity.spawn_networked_mission_vehicle(hash, function()
							return essentials.get_player_coords(player.player_id()) + v3(0, 0, essentials.random_real(30, 50)), 0
						end)
					end
				end
				if not f.on then
					break
				end
			end
		end
	end, nil)
	while f.on do
		system.yield(0)
		if not entity.is_entity_dead(player.get_player_ped(pid)) then
			for Vehicle in essentials.entities(essentials.deep_copy(vehicles)) do
				if entity.is_entity_dead(Vehicle) then
					kek_entity.repair_car(Vehicle)
				end
				system.yield(0)
				if kek_entity.get_control_of_entity(Vehicle, 200) then
					essentials.use_ptfx_function(vehicle.set_vehicle_out_of_control, Vehicle, false, true)
					kek_entity.teleport(Vehicle, essentials.get_player_coords(pid) + v3(essentials.random_real(-2, 2), essentials.random_real(-2, 2), essentials.random_real(-2, 2)))
				end
			end
		end
	end
	kek_entity.clear_entities(vehicles)
end).id

menu.add_player_feature(lang["Perma-cage"], "toggle", u.malicious_player_features, function(f, pid)
	if player.player_count() == 0 then
		f.on = false
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		return
	end
	local Ped = 0
	while f.on and player.player_count() > 0 do
		system.yield(0)
		if not kek_entity.get_control_of_entity(Ped) then
			kek_entity.hard_remove_entity_and_its_attachments(Ped)
			Ped = kek_entity.create_cage(pid)
		end
		if memoize.get_distance_between(player.get_player_ped(pid), Ped) > 5 then
			ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			kek_entity.teleport(Ped, essentials.get_player_coords(pid))
		end
	end
	f.on = false
	kek_entity.hard_remove_entity_and_its_attachments(Ped)
end)

do
	local vehicle_blacklist_reactions <const> = {
		lang["Turned off"],
		lang["EMP"],
		lang["Kick from vehicle"],
		lang["Explode"],
		lang["Ram"],
		lang["Glitch"],
		lang["Fill, steal & run away"],
		lang["Kick from session"],
		lang["Crash"],
		lang["Random"]
	}

	local vehicle_blacklist_reaction_names <const> = essentials.const({
		"Turned off",
		"EMP",
		"Kick from vehicle",
		"Explode",
		"Ram",
		"Glitch their vehicle",
		"steal",
		"Kick from session",
		"Crash",
		"Random"
	})

	for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
		settings:add_setting({
			setting_name = "vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(hash),
			setting = 0
		})
	end

	menu.add_feature(lang["Turn everything off"], "action", u.vehicle_blacklist.id, function()
		for _, feat in pairs(essentials.get_descendants(u.vehicle_blacklist, {})) do
			if feat.value then
				feat.value = 0
			end
		end
		for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
			settings.in_use["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(hash)] = 0
		end
	end)

	local parent <const> = menu.add_feature(lang["Search"], "parent", u.vehicle_blacklist.id)

	menu.add_feature(lang["Search"], "action", parent.id, function(f)
		local input, status <const> = keys_and_input.get_input(lang["Type in name of vehicle"], "", 128, 0)
		if status == 2 then
			return
		end
		for i, feat in pairs(f.data) do
			if feat == settings.valuei["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(feat.data)] then
				settings.valuei["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(feat.data)] = nil
			end
			essentials.delete_feature(feat.id)
			f.data[i] = nil
		end
		input = essentials.make_string_case_insensitive(input)
		for _, hash in pairs(vehicle.get_all_vehicle_model_hashes()) do
			if vehicle_mapper.get_vehicle_name(hash):find(input) then
				local setting_name <const> = "vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(hash)
				f.data[#f.data + 1] = menu.add_feature(vehicle_mapper.get_vehicle_name(hash), "autoaction_value_str", parent.id, function(f)
					for _, feat in pairs(essentials.get_descendants(u.vehicle_blacklist, {})) do
						if f ~= feat and feat.data == f.data then
							feat.value = f.value
						end
					end
					settings.in_use["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(f.data)] = f.value
				end)
				settings.valuei[setting_name] = settings.valuei[setting_name] or f.data[#f.data]
				f.data[#f.data].data = hash
				f.data[#f.data]:set_str_data(vehicle_blacklist_reactions)
				f.data[#f.data].value = settings.in_use[setting_name]
			end
		end
	end).data = {}

	settings.toggle["Vehicle blacklist"] = menu.add_feature(lang["Vehicle blacklist"], "toggle", u.vehicle_blacklist.id, function(f)
		local tracker <const> = {}
		while f.on do
			for pid in essentials.players() do
				if player.is_player_in_any_vehicle(pid) then
					local player_vehicle <const> = player.get_player_vehicle(pid)
					local p_veh_hash <const> = entity.get_entity_model_hash(player_vehicle)
					if streaming.is_model_a_vehicle(p_veh_hash) and player.can_player_be_modder(pid) and (not tracker[player_vehicle] or utils.time_ms() > tracker[player_vehicle]) then -- It has been observed entity hash can be 0 despite checking if player is in vehicle.
						local setting = vehicle_blacklist_reaction_names[settings.in_use["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(p_veh_hash)] + 1]
						if f.on and setting ~= "Turned off" and essentials.is_not_friend(pid)
						and (not player.is_player_in_any_vehicle(player.player_id()) or player_vehicle ~= player.get_player_vehicle(player.player_id())) then
							local name <const> = player.get_player_name(pid)
							local notif_on <const> = settings.in_use["Vehicle blacklist #notifications#"]
							if setting == "Random" then
								setting = vehicle_blacklist_reaction_names[math.random(2, #vehicle_blacklist_reaction_names - 3)]
							end
							local veh_name <const> = vehicle_mapper.get_vehicle_name(p_veh_hash)
							tracker[player_vehicle] = utils.time_ms() + 20000
							menu.create_thread(function()
								if setting == "EMP" then
									essentials.msg(string.format("%s %s's' %s.", lang["Vehicle blacklist:\nEMP'd"], name, veh_name), "orange", notif_on)
									local pos <const> = essentials.get_player_coords(pid)
									globals.send_script_event("Vehicle EMP", pid, {pid, essentials.round(pos.x), essentials.round(pos.y), essentials.round(pos.z), 0}, false, true)
								elseif setting == "Kick from vehicle" then
									essentials.msg(string.format("%s %s %s %s.", lang["Vehicle blacklist:\nKicked"], name, lang["out of their"], veh_name), "orange", notif_on)
									globals.disable_vehicle(pid)
								elseif setting == "Explode" then
									essentials.msg(string.format("%s %s's' %s.", lang["Vehicle blacklist:\nExploding"], name, veh_name), "orange", notif_on)		
									local time <const> = utils.time_ms() + 2000
									while time > utils.time_ms() and not entity.is_entity_dead(player.get_player_ped(pid)) do
										essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), math.random(0, essentials.number_of_explosion_types), true, false, 0, player.get_player_ped(pid))
										system.yield(300)
									end
								elseif setting == "Ram" then
									essentials.msg(string.format("%s %s's' %s.", lang["Vehicle blacklist:\nRamming"], name, veh_name), "orange", notif_on)
									kek_entity.ram_player(pid)
								elseif setting == "Glitch their vehicle" then
									essentials.msg(string.format("%s %s's' %s.", lang["Vehicle blacklist:\nGlitching"], name, veh_name), "orange", notif_on)
									kek_entity.glitch_vehicle(player_vehicle)
								elseif setting == "steal" then
									essentials.msg(string.format("%s %s's' %s.", lang["Vehicle blacklist:\nstealing"], name, veh_name), "orange", notif_on)
									menu.get_player_feature(player_feat_ids["Mad peds"]).feats[pid].value = 0
									menu.get_player_feature(player_feat_ids["Mad peds"]).feats[pid].on = true
								elseif setting == "Kick from session" then
									essentials.msg(string.format("%s %s %s %s.", lang["Vehicle blacklist:\nKicked"], name, lang["for using"], veh_name), "orange", notif_on)
									essentials.kick_player(pid)
								elseif setting == "Crash" then
									essentials.msg(string.format("%s %s %s %s.", lang["Vehicle blacklist:\nCrashed"], name, lang["for using"], veh_name), "orange", notif_on)
									globals.script_event_crash(pid)
								end
							end, nil)
						end
					end
				end
			end
			system.yield(0)
		end
	end)

	kek_entity.generate_vehicle_list(
		"autoaction_value_str",
		vehicle_blacklist_reactions,
		u.vehicle_blacklist,
		function(hash)
			return settings.in_use["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(hash)]
		end,
		function(f)
			for _, feat in pairs(essentials.get_descendants(u.vehicle_blacklist, {})) do
				if feat ~= f and f.data == feat.data then
					feat.value = f.value
				end
			end
			settings.in_use["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(f.data)] = f.value
		end,
		true
	)
end

menu.add_feature(lang["Spawn vehicle for everyone"], "action", u.session_peaceful.id, function()
	local default, hash = ""
	repeat
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in which car to spawn"], default, 128, 0)
		if status == 2 then
			return
		end
		hash = vehicle_mapper.get_hash_from_user_input(input:lower())
		if not streaming.is_model_a_vehicle(hash) then
			default = input
			essentials.msg(lang["Invalid model name."], "red", true, 6)
		end
	until streaming.is_model_a_vehicle(hash)

	local spawn_count = 0
	for pid in essentials.players() do
		local car <const> = kek_entity.spawn_networked_vehicle(hash, function()
			return essentials.get_player_coords(pid), player.get_player_heading(pid)
		end, {
			godmode = settings.toggle["Spawn #vehicle# in godmode"].on, 
			max = settings.toggle["Spawn #vehicle# maxed"].on,
			persistent = false
		})
		if not entity.is_entity_a_vehicle(car) then
			essentials.msg(string.format("%s %i / %i %s. %s", lang["Failed to spawn"], player.player_count() - spawn_count, player.player_count(), lang["Vehicles"]:lower(), lang["Vehicle limit was reached."]), "red", true, 6)
			break
		end
		spawn_count = spawn_count + 1
		decorator.decor_set_int(car, "MPBitset", 1 << 10)
	end
	essentials.msg(lang["Cars spawned."], "green", true)
end)

menu.add_feature(lang["Max everyone's car"], "action", u.session_peaceful.id, function()
	local initial_pos <const> = essentials.get_player_coords(player.player_id())
	for pid in essentials.players() do
		if kek_entity.check_player_vehicle_and_teleport_if_necessary(pid) then
			kek_entity.max_car(player.get_player_vehicle(pid))
		end
	end
	kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
	essentials.msg(lang["Maxed everyone's cars."], "green", true)
end)	

menu.add_player_feature(lang["Kidnap player"], "toggle", u.player_trolling_features, function(f, pid)
	if f.on then
		if player.player_id() == pid then
			essentials.msg(lang["You can't use this on yourself."], "red", true, 6)
			f.on = false
			return
		end
		essentials.set_all_player_feats_except(menu.get_player_feature(f.id).id, false, {[pid] = true})
		kek_entity.remove_player_vehicle(player.player_id())
		local van = 0
		menu.create_thread(function()
			while f.on and player.is_player_valid(pid) do
				system.yield(0)
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			end
		end, nil)
		while f.on do
			system.yield(0)
			if not entity.is_entity_dead(player.get_player_ped(pid)) then
				if not entity.is_entity_a_vehicle(van) then
					van = kek_entity.spawn_networked_vehicle(gameplay.get_hash_key("stockade"), function()
						return essentials.get_player_coords(pid) + memoize.v3(0, 0, 50), 0
					end, {
						godmode = true,
						max = true,
						persistent = true
					})
					vehicle.set_vehicle_doors_locked_for_all_players(van, true)
				end
				if entity.is_entity_a_vehicle(van) and not ped.is_ped_in_vehicle(player.get_player_ped(player.player_id()), van) then
					ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), van, enums.vehicle_seats.driver)
				end
				if player.is_player_valid(pid)
				and memoize.get_distance_between(player.get_player_ped(pid), van) > 5 
				and (not essentials.is_in_vehicle(pid) or kek_entity.remove_player_vehicle(pid)) then
					kek_entity.teleport(van, kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 2.20) - memoize.v3(0, 0, 1))
					kek_entity.set_entity_heading(van, player.get_player_heading(pid))
				end
			end			
		end
		if not select(2, kek_entity.get_number_of_passengers(van)) then
			kek_entity.clear_entities({van})
		end
	end
end)

menu.add_player_feature(lang["Make nearby peds hostile"], "toggle", u.player_trolling_features, function(f, pid)
	if f.on then
		local weapons <const> = weapon_mapper.get_table_of_weapons({
			rifles = true,
			smgs = true,
			heavy = true,
			throwables = true
		})
		local ped_tracker <const> = {}
		while f.on do
			system.yield(0)
			local player_ped <const> = player.get_player_ped(pid)
			local count = 0
			for Ped in essentials.entities(memoize.get_all_peds()) do
				if not ped.is_ped_a_player(Ped) and memoize.get_distance_between(player_ped, Ped) < 100 and kek_entity.get_control_of_entity(Ped, 100) then
					ai.task_combat_ped(Ped, player.get_player_ped(pid), 0, 16)
					if not ped_tracker[Ped] then
						count = count + 1
						weapon.give_delayed_weapon_to_ped(Ped, weapons[math.random(1, #weapons)], 0, 1)
						kek_entity.set_combat_attributes(Ped, true, {})
						ped.set_ped_can_ragdoll(Ped, false)
						local pos <const> = entity.get_entity_coords(Ped)
						gameplay.shoot_single_bullet_between_coords(pos, pos + memoize.v3(0, 0.0, 0.1), 0, gameplay.get_hash_key("weapon_pistol"), player.get_player_ped(pid), false, true, 100)
						ped.set_ped_can_ragdoll(Ped, true)
						ped_tracker[Ped] = true
						if count == 20 then
							break
						end
					end
				end
				if not f.on then
					break
				end
			end
		end
		for _, Ped in essentials.entities(ped_tracker) do
			if kek_entity.get_control_of_entity(Ped, 100) then
				weapon.remove_all_ped_weapons(Ped)
				kek_entity.set_combat_attributes(Ped, false, {})
				ped.clear_ped_tasks_immediately(Ped)
			end
		end
	end
end)

player_feat_ids["Mad peds"] = menu.add_player_feature(lang["Mad peds in their car"], "action_value_str", u.player_trolling_features, function(f, pid)
	for Vehicle in essentials.entities({player.get_player_vehicle(pid), player.player_count() > 0 and globals.get_player_global("personal_vehicle", pid) or 0}) do
		if not entity.is_entity_dead(Vehicle) then
			if (essentials.is_str(f, "Fill, steal & run away") or essentials.is_str(f, "Fill & steal")) and ped.is_ped_a_player(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0) then
				ped.clear_ped_tasks_immediately(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0)
				local time <const> = utils.time_ms() + 3000
				while entity.is_entity_a_ped(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0) and time > utils.time_ms() do
					system.yield(0)
				end
				system.yield(500)
			end
			local hash <const> = gameplay.get_hash_key(ped_mapper.LIST_OF_SPECIAL_PEDS[math.random(1, #ped_mapper.LIST_OF_SPECIAL_PEDS)])
			if essentials.is_str(f, "Fill, steal & run away") and not entity.is_entity_a_ped(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0) then
				local Ped <const> = kek_entity.spawn_networked_ped(hash, function()
					return essentials.get_player_coords(player.player_id()) + memoize.v3(0, 0, 10), 0
				end)
				ped.set_ped_into_vehicle(Ped, Vehicle, enums.vehicle_seats.driver)
				ped.set_ped_combat_attributes(Ped, 3, false)
			end
			troll_entity.setup_peds_and_put_in_seats(kek_entity.get_empty_seats(Vehicle), hash, Vehicle, pid, true)
			if essentials.is_str(f, "Fill, steal & run away") then
				ai.task_vehicle_drive_to_coord_longrange(vehicle.get_ped_in_vehicle_seat(Vehicle, enums.vehicle_seats.driver) or 0, Vehicle, v3(math.random(-7000, 7000), math.random(-7000, 7000), 50), 150, drive_style_mapper.get_drive_style_from_list({
					["Avoid vehicles"] = true,
					["Avoid empty vehicles"] = true,
					["Allow going wrong way"] = true,
					["Allow overtaking vehicles"] = true
				}), 100)
			end
		end
	end
end).id
menu.get_player_feature(player_feat_ids["Mad peds"]):set_str_data({
	lang["Fill, steal & run away"],
	lang["Fill & steal"],
	lang["Fill"]
})

menu.add_feature(lang["Teleport session"], "value_str", u.session_trolling.id, function(f)
	local initial_pos <const>, threads <const> = essentials.get_player_coords(player.player_id()), {}
	menu.create_thread(function()
		while f.on do
			entity.set_entity_velocity(kek_entity.get_most_relevant_entity(player.player_id()), memoize.v3())
			system.yield(0)
		end
	end, nil)
	while f.on do
		if essentials.is_str(f, "Current position") then
			local pos <const> = essentials.get_player_coords(player.player_id())
			while essentials.is_str(f, "Current position") and f.on do
				kek_entity.teleport_session(pos, f)
				system.yield(0)
			end
		elseif essentials.is_str(f, "Waypoint") and hud.is_waypoint_active() then
			local pos <const> = location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50))
			while essentials.is_str(f, "Waypoint") and f.on do
				kek_entity.teleport_session(pos, f)
				system.yield(0)
			end
		elseif essentials.is_str(f, "Mount Chiliad & kill") then
			local players <const> = {}
			for pid in essentials.players() do
				if not essentials.is_str(f, "Mount Chiliad & kill") or not f.on then
					break
				end
				if essentials.is_not_friend(pid) then
					if not essentials.is_in_vehicle(pid) and menu.has_thread_finished(threads[pid] or -1) then
						threads[pid] = menu.create_thread(function()
							globals.force_player_into_vehicle(pid)
						end, nil)
					end
					if menu.has_thread_finished(threads[pid] or -1) then
						local status <const> = kek_entity.teleport_player_and_vehicle_to_position(pid, memoize.v3(492, 5587, 795))
						if status then
							globals.disable_vehicle(pid)
							players[#players + 1] = pid
						end
					end
				end
			end
			essentials.wait_conditional(1500, function()
				return f.on and essentials.is_str(f, "Mount Chiliad & kill")
			end)
			for i = 1, #players do
				if not entity.is_entity_dead(player.get_player_ped(players[i])) then
					for i2 = 1, 10 do
						system.yield(0)
						essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(players[i]), enums.explosion_types.BLIMP, true, false, 0, player.get_player_ped(players[i]))
					end
				end
			end
		elseif essentials.is_str(f, "far away") then
			kek_entity.teleport_session(v3(24000, -24000, 2300), f)
		end
		system.yield(0)
	end
	kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
end):set_str_data({
	lang["Current position"],
	lang["Waypoint"],
	lang["Mount Chiliad & kill"],
	lang["far away"]
})

do
	local function get_people_in_front_of_person_in_host_queue()
		if network.network_is_host() then
			return
		end
		local hosts <const>, friends <const> = {}, {}
		local player_host_priority <const> = player.get_player_host_priority(player.player_id())
		for pid in essentials.players() do
			if player.get_player_host_priority(pid) <= player_host_priority and not player.is_player_host(pid) then
				hosts[#hosts + 1] = pid
				if network.is_scid_friend(player.get_player_scid(pid)) then
					friends[#friends + 1] = pid
				end
			end
		end
		hosts[#hosts + 1] = player.get_host() ~= player.player_id() and player.get_host() or nil
		return hosts, friends
	end

	local function get_host(...)
		local hosts <const>, friends <const> = get_people_in_front_of_person_in_host_queue()
		if friends and settings.toggle["Exclude friends from attacks"].on and #friends > 0 then
			essentials.msg(lang["One of the people further in host queue is your friend! Cancelled."], "red", true)
		elseif hosts then
			for _, pid in pairs(hosts) do
				essentials.kick_player(pid)
				system.yield(0)
			end
		end
	end

	menu.add_feature(lang["Get host"], "action", u.session_malicious.id, function(f)
		get_host()
	end)

	settings.toggle["Force host"] = menu.add_feature(lang["Get host automatically"], "toggle", u.session_malicious.id, function(f)
		while f.on do
			system.yield(0)
			local players_in_queue <const>, friends_in_queue <const> = get_people_in_front_of_person_in_host_queue()
			if players_in_queue and (not settings.toggle["Exclude friends from attacks"].on or #friends_in_queue == 0)
			and #players_in_queue <= settings.valuei["Max number of people to kick in force host"].value then
				get_host()
				system.yield(500)
			end
		end
	end)
end

settings.valuei["Max number of people to kick in force host"] = menu.add_feature(lang["Max kicks for auto host"], "autoaction_value_i", u.session_malicious.id)
settings.valuei["Max number of people to kick in force host"].max, settings.valuei["Max number of people to kick in force host"].min, settings.valuei["Max number of people to kick in force host"].mod = 31, 1, 1

do
	local block_area_parent <const> = menu.add_feature(lang["Block areas"], "parent", u.session_malicious.id)

	local function block_area(...)
		local angles <const>,
		offsets <const>,
		locations <const>,
		object_model <const> = ...
		for i, location in pairs(locations) do
			local offset = memoize.v3()
			if offsets[i] then
				offset = offsets[i]
			end
			local object <const> = kek_entity.spawn_networked_object(gameplay.get_hash_key(object_model), function()
				return location - memoize.v3(0, 0, 2) + offset
			end)
			if object and entity.is_entity_an_object(object) then
				if angles[i] then
					entity.set_entity_heading(object, angles[i])
				end
			end
		end
	end

	local function unblock_area(...)
		local model <const>, positions <const> = ...
		essentials.assert(streaming.is_model_valid(gameplay.get_hash_key(model)), "Invalid model.", model)
		local initial_pos <const> = essentials.get_player_coords(player.player_id())
		local had_to_teleport
		for _, pos in pairs(positions) do
			if essentials.get_player_coords(player.player_id()):magnitude(pos) > 200 then
				kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), pos)
				had_to_teleport = true
				system.yield(100)
			end
			for Object in essentials.entities(object.get_all_objects()) do
				if entity.get_entity_model_hash(Object) == gameplay.get_hash_key(model) then
					kek_entity.clear_entities({Object})
				end
			end
		end
		if had_to_teleport then
			kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
		end
	end

	menu.add_feature(lang["Los santos customs"], "action_value_str", block_area_parent.id, function(f)
		if essentials.is_str(f, "Block") then
			local angles <const> = essentials.const({
				-135, 
				0, 
				-40, 
				-90, 
				70, 
				0
			})
			block_area(angles, {}, location_mapper.LSC_POSITIONS, "v_ilev_cin_screen")
		elseif essentials.is_str(f, "Unblock") then
			unblock_area("v_ilev_cin_screen", location_mapper.LSC_POSITIONS)
		end
	end):set_str_data({
		lang["Block"],
		lang["Unblock"]
	})

	menu.add_feature(lang["Ammu-Nations"], "action_value_str", block_area_parent.id, function(f)
		if essentials.is_str(f, "Block") then
			block_area({}, {}, location_mapper.AMMU_NATION_POSITIONS, "prop_air_monhut_03_cr")
		elseif essentials.is_str(f, "Unblock") then
			unblock_area("prop_air_monhut_03_cr", location_mapper.AMMU_NATION_POSITIONS)
		end
	end):set_str_data({
		lang["Block"],
		lang["Unblock"]
	})

	menu.add_feature(lang["Casino"], "action_value_str", block_area_parent.id, function(f)
		if essentials.is_str(f, "Block") then
			local offsets <const> = 
				{
					memoize.v3(), 
					memoize.v3(-3, 4, 0), 
					memoize.v3(-2.5, 1.75, 0)
				}
			local angles <const> = essentials.const({
				55, 
				-34, 
				-32
			})
			block_area(angles, offsets, location_mapper.CASINO_POSITIONS, "prop_sluicegater")
		elseif essentials.is_str(f, "Unblock") then
			unblock_area("prop_sluicegater", location_mapper.CASINO_POSITIONS)
		end
	end):set_str_data({
		lang["Block"],
		lang["Unblock"]
	})
end

menu.add_feature(lang["Freeze session"], "toggle", u.session_malicious.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) 
			and not player.is_player_modder(pid, -1) 
			and not entity.is_entity_dead(player.get_player_ped(pid)) then
				ped.clear_ped_tasks_immediately(player.get_player_ped(pid))
			end
		end
	end
end)	

menu.add_feature(lang["Cage session"], "action", u.session_malicious.id, function()
	for pid in essentials.players() do
		if essentials.is_not_friend(pid) then
			kek_entity.create_cage(pid)
		end
	end
end)

menu.add_feature(lang["Give session bounty"], "action_value_str", u.session_trolling.id, function(f)
	if essentials.is_str(f, "Change amount") then
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in bounty amount"], "", 5, 3)
		if status == 2 then
			return
		end
		settings.in_use["Bounty amount"] = input
	else
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) then
				globals.set_bounty(pid, true, essentials.is_str(f, "Anonymous"))
			end
		end
	end
end):set_str_data({
	lang["Anonymous"],
	lang["With your name"],
	lang["Change amount"]		
})

menu.add_feature(lang["Reapply bounty"], "value_str", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if essentials.is_not_friend(pid) then
				globals.set_bounty(pid, true, essentials.is_str(f, "Anonymous"))
			end
		end
		local value <const> = f.value
		essentials.wait_conditional(10000, function() -- Spamming script events leads to inevitable crash. Setting one bounty sends up to 32 script events.
			return f.on and f.value == value
		end)
	end
end):set_str_data({
	lang["Anonymous"],
	lang["With your name"]	
})

menu.add_feature(lang["Never wanted"], "toggle", u.session_peaceful.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if player.get_player_wanted_level(pid) > 0 and player.is_player_playing(pid) and not player.is_player_modder(pid, -1) then
				globals.send_script_event("Generic event", pid, {pid, globals.GENERIC_ARG_HASHES.clear_wanted})
			end
		end
		system.yield(1000)
	end
end)

menu.add_feature(lang["off the radar"], "toggle", u.session_peaceful.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if globals.get_player_global("otr_status", pid) ~= 1 and player.is_player_playing(pid) and not player.is_player_modder(pid, -1) then
				globals.send_script_event("Give OTR or ghost organization", pid, {pid, utils.time() - 60, utils.time(), 1, 1, globals.get_player_global("generic", pid)})
			end
		end
		system.yield(1000)
	end
end)

u.send_30k_to_session = menu.add_feature(lang["30k ceo loop"], "toggle", u.session_peaceful.id, function(f)
	menu.get_player_feature(player_feat_ids["30k ceo"]).on = false
	menu.create_thread(function()
		while f.on do
			for pid in essentials.players() do
				if globals.get_player_global("organization_associate_hash", pid) ~= -1 then
					globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 0, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous")})
				end
			end
			essentials.wait_conditional(20000, function() 
				return f.on 
			end)
			if f.on then
				for pid in essentials.players() do
					if globals.get_player_global("organization_associate_hash", pid) ~= -1 then
						globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 1, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous")})
					end
				end
			end
			essentials.wait_conditional(20000, function() 
				return f.on 
			end)
		end
	end, nil)
	while f.on do
		for pid in essentials.players() do
			if globals.get_player_global("organization_associate_hash", pid) ~= -1 then
				globals.send_script_event("CEO money", pid, {pid, 30000, 198210293, 1, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous")})
			end
		end
		essentials.wait_conditional(120000, function() 
			return f.on 
		end)
	end
end)

settings.user_entity_features.vehicle.feats["Respawn vehicle"] = menu.add_feature(lang["Respawn vehicle after death"], "value_str", u.session_peaceful.id, function(f)
	local states <const> = {}
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			local scid <const> = player.get_player_scid(pid)
			states[scid] = states[scid] or entity.is_entity_dead(player.get_player_ped(pid))
			if states[scid] and player.get_player_coords(pid).z > -10 and not entity.is_entity_dead(player.get_player_ped(pid)) then
				states[scid] = false
				kek_entity.clear_entities({f.data[scid]})
				local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
				f.data[scid] = kek_entity.spawn_networked_vehicle(hash, function()
					return location_mapper.get_most_accurate_position(kek_entity.vehicle_get_vec_rel_to_dims(hash, player.get_player_ped(pid))), player.get_player_heading(pid)
				end, {
					godmode = settings.toggle["Spawn #vehicle# in godmode"].on, 
					max = settings.toggle["Spawn #vehicle# maxed"].on,
					persistent = false
				})
			end
		end
	end
end)
settings.user_entity_features.vehicle.feats["Respawn vehicle"].data = {}

settings.toggle["Is player typing"] = menu.add_feature(lang["Notify when typing & stopped typing"], "toggle", u.session_peaceful.id, function(f)
	while f.on do
		system.yield(0)
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				if globals.get_player_global("is_player_typing", pid) & 1 << 16 ~= 0 and not f.data[pid] then
					essentials.msg(string.format("%s %s", player.get_player_name(pid), lang["is typing."]), "blue", true, 4)
					f.data[pid] = true
				elseif f.data[pid] and globals.get_player_global("is_player_typing", pid) & 1 << 16 == 0 then
					essentials.msg(string.format("%s %s", player.get_player_name(pid), lang["is no longer typing."]), "orange", true, 4)
					f.data[pid] = false
				end
			end
		end
	end
end)
settings.toggle["Is player typing"].data = {}

menu.add_feature(lang["Block passive mode"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) and player.is_player_playing(pid) then
				globals.send_script_event("Block passive", pid, {pid, 1}, true)
			end
		end
		system.yield(1000)
	end
	for pid in essentials.players() do
		if not player.is_player_modder(pid, -1) then
			globals.send_script_event("Block passive", pid, {pid, 0}, true)
		end
	end
end)

menu.add_feature(lang["Teleport to Perico island"], "action", u.session_trolling.id, function(f)
	for pid in essentials.players() do
		if not player.is_player_modder(pid, -1) then
			globals.send_script_event("Send to Perico island", pid, {pid, globals.get_script_event_hash("Send to Perico island"), 0, 0}, true)
		end
	end
end)

menu.add_feature(lang["Organization"], "action_value_str", u.session_trolling.id, function(f)
	if essentials.is_str(f, "Ban") then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("CEO ban", pid, {pid, 1}, true)
			end
		end
	elseif essentials.is_str(f, "Dismiss") then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Dismiss or terminate from CEO", pid, {pid, 1, 5}, true)
			end
		end
	elseif essentials.is_str(f, "Terminate") then
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) then
				globals.send_script_event("Dismiss or terminate from CEO", pid, {pid, 1, 6}, true)
			end
		end
	end
end):set_str_data({
	lang["Ban"],
	lang["Dismiss"],
	lang["Terminate"]
})

menu.add_feature(lang["Notification spam"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		local exclusion_table <const> = {[player.player_id()] = true}
		for pid in essentials.players() do
			local rand_pid <const> = essentials.get_random_player_except(exclusion_table)
			globals.send_script_event("Notifications", pid, {
				pid, 
				globals.NOTIFICATION_HASHES_RAW[math.random(1, #globals.NOTIFICATION_HASHES_RAW)], 
				math.random(-2147483647, 2147483647),
				1, 0, 0, 0, 0, 0, pid, 
				player.player_id(), 
				rand_pid, 
				essentials.get_random_player_except({[player.player_id()] = true, [rand_pid] = true})
			})
		end
		system.yield(500)
	end
end)

menu.add_feature(lang["Transaction error"], "toggle", u.session_trolling.id, function(f)
	while f.on do
		for pid in essentials.players() do
			if not player.is_player_modder(pid, -1) and player.is_player_playing(pid) then
				globals.send_script_event("Transaction error", pid, {pid, 50000, 0, 1, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous"), 1}, true)
			end
		end
		system.yield(1000)
	end
end)

settings.toggle["Chat logger"] = menu.add_feature(lang["Chat logger"], "toggle", u.chat_stuff.id, function(f)
	if f.on then
		essentials.listeners["chat"]["logger"] = essentials.add_chat_event_listener(function(event)
			if player.is_player_valid(event.player)
			and (not f.data[player.get_player_scid(event.player)] or utils.time_ms() + 10000 > f.data[player.get_player_scid(event.player)]) then
				local name <const> = player.get_player_name(event.player)..string.rep("\32", 16 - (utf8.len(player.get_player_name(event.player):sub(1, 16)) or #player.get_player_name(event.player):sub(1, 16)))
				local str <const> = {}
				for line in event.body:gmatch("[^\n\r]+") do
					str[#str + 1] = string.format("[%s][%s]: %s\n", name, os.date(), line)
				end
				essentials.log(paths.kek_menu_stuff.."kekMenuLogs\\Chat log.log", table.concat(str, "\n"))
				if f.data[player.get_player_scid(event.player)] and utils.time_ms() < f.data[player.get_player_scid(event.player)] then
					f.data[player.get_player_scid(event.player)] = f.data[player.get_player_scid(event.player)] + 2000
				else
					f.data[player.get_player_scid(event.player)] = utils.time_ms() + 1000
				end
			end
			system.yield(0)
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["logger"])
		essentials.listeners["chat"]["logger"] = nil
	end
end)
settings.toggle["Chat logger"].data = {}

settings.toggle["Anti chat spam"] = menu.add_feature(lang["Anti chat spam"], "value_str", u.chat_stuff.id, function(f)
	if f.on then
		if essentials.listeners["chat"]["anti spam"] then
			return
		end
		local tracker <const> = {}
		essentials.listeners["chat"]["anti spam"] = essentials.add_chat_event_listener(function(event)
			local scid <const> = player.get_player_scid(event.player)
			if player.is_player_valid(event.player) and player.can_player_be_modder(event.player) and event.player ~= player.player_id() and essentials.is_not_friend(event.player) then
				local msg_increment 	 <const> = (utf8.len(event.body) or #event.body) + 85 -- People may send a message that contains invalid utf8 seq, causing utf8.len to return nil.
				local in_a_row_increment <const> = (utf8.len(event.body) or #event.body) >= 10 and 1.0 or 0.7
				
				if not tracker[scid] then
					tracker[scid] = {
						same_in_a_row_count = in_a_row_increment,
						previous_msg = event.body,
						fast_spam_count = msg_increment,
						time_since_last_msg = utils.time_ms() + 600
					}
					return
				end

				if tracker[scid].previous_msg == event.body then
					tracker[scid].same_in_a_row_count = tracker[scid].same_in_a_row_count + in_a_row_increment
				else
					tracker[scid].same_in_a_row_count = in_a_row_increment
					tracker[scid].previous_msg = event.body
				end

				if utils.time_ms() > tracker[scid].time_since_last_msg then
					tracker[scid].fast_spam_count = msg_increment
				else
					tracker[scid].fast_spam_count = tracker[scid].fast_spam_count + msg_increment
				end
				tracker[scid].time_since_last_msg = utils.time_ms() + 600

				if tracker[scid].same_in_a_row_count >= 3.0 or tracker[scid].fast_spam_count >= 500 then
					essentials.msg(string.format("%s %s", player.get_player_name(event.player), lang["kicked for spamming chat."]), "orange", true, 6)
					tracker[scid] = nil
					if essentials.is_str(f, "Kick & add to timeout") then
						essentials.add_to_timeout(event.player)
					end
					essentials.kick_player(event.player)
				end
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["anti spam"])
		essentials.listeners["chat"]["anti spam"] = nil			
	end
end)
settings.valuei["Anti chat spam reaction"] = settings.toggle["Anti chat spam"]
settings.valuei["Anti chat spam reaction"]:set_str_data({
	lang["Kick"],
	lang["Kick & add to timeout"]
})

settings.toggle["Translate chat into language"] = menu.add_feature(lang["Translate chat"], "value_str", u.translate_chat.id, function(f)
	if f.on then
		if essentials.listeners["chat"]["translate"] then
			return
		end
		local tracker <const> = {} -- To prevent spamming requests at Google, 1 translation every 500ms per player.
		essentials.listeners["chat"]["translate"] = essentials.add_chat_event_listener(function(event)
			if (settings.toggle["Translate your messages too"].on or settings.toggle["Translate your messages into"].on or event.player ~= player.player_id())
			and event.body:find("^%P") -- chat commands
			and utils.time_ms() > (tracker[event.player] or 0) then
				local language_translate_into_setting = 
					enums.supported_langs_by_google_to_code[
						enums.supported_langs_by_google[settings.valuei["Translate chat into language what language"].value + 1]
					]
				local str, detected_language
				if player.player_id() == event.player and settings.toggle["Translate your messages into"].on then
					language_translate_into_setting = enums.supported_langs_by_google_to_code[
						enums.supported_langs_by_google[settings.valuei["Translate your messages into option"].value + 1]
					]
					str, detected_language = 
						language.translate_text(
							event.body, 
							"auto", 
							language_translate_into_setting
						)
				else
					str, detected_language = 
						language.translate_text(
							event.body, 
							"auto", 
							language_translate_into_setting
						)
				end
				tracker[event.player] = utils.time_ms() + 500
				if enums.supported_langs_by_google_to_name[detected_language]
				and str:lower():gsub("%s", "") ~= event.body:lower():gsub("%s", "") then
					local is_team_chat = essentials.is_str(f, "Team chat")
					if event.player == player.player_id() and settings.toggle["Translate your messages into"].on then
						is_team_chat = essentials.is_str(settings.valuei["Translate your messages into chat type"], "Team chat")
					end
					essentials.send_message(
						lang[enums.supported_langs_by_google_to_name[detected_language]].." > "..lang[enums.supported_langs_by_google_to_name[language_translate_into_setting]]..": "..str, 
						is_team_chat
					)
				end
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["translate"])
		essentials.listeners["chat"]["translate"] = nil
	end
end)
settings.toggle["Translate chat into language"]:set_str_data({
	lang["Team chat"],
	lang["All chat"]
})

settings.toggle["Translate your messages too"] = menu.add_feature(lang["Translate your messages"], "toggle", u.translate_chat.id)

settings.toggle["Translate your messages into"] = menu.add_feature(lang["Translate your messages into"], "value_str", u.translate_chat.id)
settings.valuei["Translate your messages into option"] = settings.toggle["Translate your messages into"]
settings.valuei["Translate your messages into option"]:set_str_data(
	(function()
		local t = {}
		for i = 1, #enums.supported_langs_by_google do
			t[#t + 1] = lang[enums.supported_langs_by_google[i]]
		end
		return t
	end)()
)

settings.valuei["Translate your messages into chat type"] = menu.add_feature(lang["Your messages chat type"], "action_value_str", u.translate_chat.id)
settings.valuei["Translate your messages into chat type"]:set_str_data({
	lang["All chat"],
	lang["Team chat"]
})

settings.valuei["Translate chat into language option"] = settings.toggle["Translate chat into language"]

settings.valuei["Translate chat into language what language"] = menu.add_feature(
	lang["Translate into"], 
	"action_value_str", 
	u.translate_chat.id
)
settings.valuei["Translate chat into language what language"]:set_str_data(
	(function()
		local t = {}
		for i = 1, #enums.supported_langs_by_google do
			t[#t + 1] = lang[enums.supported_langs_by_google[i]]
		end
		return t
	end)()
)

settings.valuei["Translate chat into language what language to detect"] = menu.add_feature(
	lang["Translate what is not"], 
	"action_value_str", 
	u.translate_chat.id
)
settings.valuei["Translate chat into language what language to detect"]:set_str_data(
	(function()
		local t = {}
		for i = 1, #enums.supported_langs_by_google do
			t[#t + 1] = lang[enums.supported_langs_by_google[i]]
		end
		return t
	end)()
)

do
	local function create_anti_stuck_thread(...)
		local f <const>, wp <const> = ...
		return menu.create_thread(function()
			local consecutive_stuck_counter = 0
			while f.on do
				system.yield(0)
				if settings.toggle["Anti stuck measures"].on then
					local time <const> = utils.time_ms() + 4000
					while f.on
					and settings.toggle["Anti stuck measures"].on
					and (not wp or not essentials.is_str(f, "waypoint") or hud.is_waypoint_active())
					and player.is_player_in_any_vehicle(player.player_id())
					and time > utils.time_ms()
					and entity.get_entity_speed(player.get_player_vehicle(player.player_id())) < 2
					and entity.get_entity_submerged_level(player.get_player_vehicle(player.player_id())) ~= 1
					and not entity.is_entity_in_air(player.get_player_vehicle(player.player_id())) do
						system.yield(0)
						if utils.time_ms() > time then
							consecutive_stuck_counter = consecutive_stuck_counter + 1
							if consecutive_stuck_counter < 5 then
								vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), -10)
								entity.set_entity_heading(player.get_player_vehicle(player.player_id()), kek_entity.get_rotated_heading(player.get_player_vehicle(player.player_id()), 180, player.player_id(), player.get_player_heading(player.player_id())))
							end
						end
					end
					if not settings.toggle["Anti stuck measures"].on then
						consecutive_stuck_counter = 0
					end
					if wp and essentials.is_str(f, "waypoint") and not hud.is_waypoint_active() then
						consecutive_stuck_counter = 0
					end
					if entity.get_entity_speed(player.get_player_vehicle(player.player_id())) > 12 then
						consecutive_stuck_counter = 0
					end
					if consecutive_stuck_counter > 3 or vehicle.is_vehicle_stuck_on_roof(player.get_player_vehicle(player.player_id())) or (entity.get_entity_submerged_level(player.get_player_vehicle(player.player_id())) == 1 and not streaming.is_model_a_boat(entity.get_entity_model_hash(player.get_player_vehicle(player.player_id())))) then
						consecutive_stuck_counter = 0
						kek_entity.teleport(player.get_player_vehicle(player.player_id()), essentials.get_player_coords(player.player_id() + kek_entity.get_random_offset(-80, 80, 25, 75), true))
					end
				end
				if entity.is_entity_a_vehicle(player.get_player_vehicle(player.player_id())) and entity.is_entity_dead(player.get_player_vehicle(player.player_id())) and player.is_player_in_any_vehicle(player.player_id()) then
					kek_entity.repair_car(player.get_player_vehicle(player.player_id()))
				end
			end
		end, nil)
	end

	settings.toggle["Anti stuck measures"] = menu.add_feature(lang["Anti stuck"], "toggle", u.ai_drive.id)

	u.ai_drive_feature = menu.add_feature(lang["Ai driving"], "value_str", u.ai_drive.id, function(f)
		if f.on then
			local thread <const> = create_anti_stuck_thread(f, true)
			local value, speed, style, Vehicle
			local time = 0
			local pos = ui.get_waypoint_coord()
			menu.get_player_feature(player_feat_ids["Follow player"]).on = false
			while f.on do
				if player.is_player_in_any_vehicle(player.player_id()) then
					if (not essentials.is_str(f, "waypoint") or hud.is_waypoint_active()) and entity.is_entity_upside_down(player.get_player_vehicle(player.player_id())) then
						local rot <const> = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
						entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(0, 0, rot.z))
					end
					if value ~= f.value 
					or Vehicle ~= player.get_player_vehicle(player.player_id()) 
					or speed ~= u.drive_speed.value 
					or style ~= settings.in_use["Drive style"] 
					or (essentials.is_str(f, "waypoint") and pos ~= ui.get_waypoint_coord()) 
					or utils.time_ms() > time
					or (essentials.is_str(f, "Wander") and not ai.is_task_active(player.get_player_ped(player.player_id()), enums.ctasks.CarDriveWander)) then
						if essentials.is_str(f, "waypoint") and not hud.is_waypoint_active() then
							kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
							while f.on and essentials.is_str(f, "waypoint") and not hud.is_waypoint_active() do
								system.yield(0)
							end
						end
						value = f.value
						speed = u.drive_speed.value
						style = settings.in_use["Drive style"]
						pos = ui.get_waypoint_coord()
						Vehicle = player.get_player_vehicle(player.player_id())
						time = utils.time_ms() + 7000
						entity.set_entity_max_speed(player.get_player_vehicle(player.player_id()), u.drive_speed.value)
						if essentials.is_str(f, "Wander") then
							ai.task_vehicle_drive_wander(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), u.drive_speed.value, settings.in_use["Drive style"])
						elseif essentials.is_str(f, "waypoint") and hud.is_waypoint_active() then
							ai.task_vehicle_drive_to_coord_longrange(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50)), u.drive_speed.value, settings.in_use["Drive style"], 10)
						end
					end
				end
				system.yield(250)
			end
			kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
		end
	end)
	u.ai_drive_feature:set_str_data({
		lang["Wander"],
		lang["waypoint"]
	})


	player_feat_ids["Follow player"] = menu.add_player_feature(lang["Follow player"], "toggle", u.player_misc_features, function(f, pid)
		if f.on then
			if player.player_id() == pid then
				essentials.msg(lang["You can't use this on yourself."], "red", true, 6)
				f.on = false
				return
			end
			essentials.set_all_player_feats_except(player_feat_ids["Follow player"], false, {[pid] = true})
			u.ai_drive_feature.on = false
			local thread <const> = create_anti_stuck_thread(f)
			local speed, style, Vehicle, value
			local time = 0
			local pos = essentials.get_player_coords(player.player_id())
			local Ped = player.get_player_ped(player.player_id())
			while f.on do
				if player.is_player_in_any_vehicle(player.player_id()) then
					if entity.is_entity_upside_down(player.get_player_vehicle(player.player_id())) then
						local rot <const> = entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))
						entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), v3(0, 0, rot.z))
					end
					if Vehicle ~= player.get_player_vehicle(player.player_id()) 
					or speed ~= u.drive_speed.value 
					or style ~= settings.in_use["Drive style"] 
					or utils.time_ms() > time
					or ((value > 250 and (memoize.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id())) < 250 or memoize.get_distance_between(Ped, player.get_player_ped(pid)) > 250))
						or (value < 250 and memoize.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id())) > 250)) then
						speed = u.drive_speed.value
						style = settings.in_use["Drive style"]
						Vehicle = player.get_player_vehicle(player.player_id())
						value = memoize.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id()))
						pos = essentials.get_player_coords(pid)
						Ped = player.get_player_ped(pid)
						entity.set_entity_max_speed(player.get_player_vehicle(player.player_id()), u.drive_speed.value)
						time = utils.time_ms() + 7000
						if memoize.get_distance_between(player.get_player_ped(pid), player.get_player_ped(player.player_id())) > 250 then
							ai.task_vehicle_drive_to_coord_longrange(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), pos, u.drive_speed.value, settings.in_use["Drive style"], 10)
						else
							ai.task_vehicle_follow(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()), player.get_player_ped(pid), u.drive_speed.value, settings.in_use["Drive style"], 0)
						end
					end
				end
				system.yield(250)
			end
			kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
		end
	end).id
end

do
	local flag_names <const> = {}
	for i = 1, #modIdStuff do
		flag_names[#flag_names + 1] = player.get_modder_flag_text(modIdStuff[i])
	end
	menu.add_player_feature(lang["Mark as modder"], "action_value_str", u.player_misc_features, function(f, pid)
		if player.is_player_modder(pid, 1 << f.value) then
			player.unset_player_as_modder(pid, 1 << f.value)
		else
			player.mark_as_modder(pid, 1 << f.value)
		end
	end):set_str_data(flag_names)
end

u.drive_speed = menu.add_feature(lang["Drive speed"], "action_slider", u.ai_drive.id, function(f)
	keys_and_input.input_number_for_feat(f, lang["Type in vehicle speed"])
end)
u.drive_speed.max, u.drive_speed.min, u.drive_speed.mod = 150, 5, 5
u.drive_speed.value = 90

for _, properties in pairs(drive_style_mapper.DRIVE_STYLE_FLAGS) do
	settings.drive_style_toggles[#settings.drive_style_toggles + 1] = menu.add_feature(lang[properties.name], "toggle", u.drive_style_cfg.id, function(f)
		if f.on and settings.in_use["Drive style"] & f.data == 0 then
			settings.in_use["Drive style"] = settings.in_use["Drive style"] ~ f.data
		elseif not f.on and settings.in_use["Drive style"] & f.data == f.data then
			settings.in_use["Drive style"] = settings.in_use["Drive style"] ~ f.data
		end
	end)
	settings.drive_style_toggles[#settings.drive_style_toggles].data = properties.flag
end

menu.add_player_feature(lang["This player can't use chat commands"], "toggle", u.player_misc_features, function(f, pid)
	settings.toggle["Chat commands"].data.player_chat_command_blacklist[player.get_player_scid(pid)] = f.on
end)

do
	local function create_judge_feat(...)
		local name <const> = ...
		if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
			return
		end
		menu.add_feature(essentials.get_safe_feat_name(name):gsub("%.ini$", ""), "action_value_str", u.custom_chat_judger.id, function(f)
			if essentials.is_str(f, "Load") then
				if not utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini") then
					essentials.msg(lang["Couldn't find file"], "red", true)
				else
					local str <const> = essentials.get_file_string(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini")
					do
						local is_valid, line_num = essentials.are_all_lines_pattern_valid(str, "[^\n\r]+")
						if not is_valid then
							essentials.msg(string.format("%s: %i\nscripts\\kek_menu_stuff\\Chat judger profiles\\%s.ini", lang["Failed to load profile. Error at line"], line_num, f.name), "red", true, 8)
							return
						end
					end
					essentials.msg(string.format("%s %s", lang["Successfully loaded"], f.name), "green", true)
					local file <close> = io.open(paths.chat_judger, "w+")
					file:write(str)
					file:flush()
				end
			elseif essentials.is_str(f, "Add entry") then
				local text = ""
				local status
				while true do
					text, status = keys_and_input.get_input(lang["Type in what to add."], text, 128, 0)
					if status == 2 then
						return
					end
					if essentials.search_for_match_and_get_line(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini", {text}, true) then
						essentials.msg(lang["Entry already exists in this profile."], "red", true, 6)
						goto skip 
					end
					if not essentials.invalid_pattern(text, true, true) then
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.log(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini", text)
				essentials.msg(string.format("%s %s", lang["Added"], text), "green", true)
			elseif essentials.is_str(f, "Remove entry") then
				local text <const>, status <const> = keys_and_input.get_input(lang["Type in what to remove."], "", 128, 0)
				if status == 2 then
					return
				end
				if essentials.remove_lines_from_file_exact(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini", text) then
					essentials.msg(string.format("%s %s", lang["Removed"], text), "green", true)
				else 
					essentials.msg(lang["Couldn't find entry."], "red", true)
				end
			elseif essentials.is_str(f, "Delete profile") then
				if utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini") then
					io.remove(paths.kek_menu_stuff.."Chat judger profiles\\"..f.name..".ini")
				end
				f.hidden = true
			elseif essentials.is_str(f, "Change name") then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in the name of the profile."], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
						goto skip
					end
					if utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..input..".ini") then
						essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
						goto skip
					end
					if input:find("[<>:\"/\\|%?%*]") then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
					else
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file(paths.kek_menu_stuff.."Chat judger profiles\\", f.name, input, "ini")
				f.name = input
			end
		end):set_str_data({
			lang["Load"],
			lang["Add entry"],
			lang["Remove entry"],
			lang["Delete profile"],
			lang["Change name"]
		})
	end

	settings.toggle["Custom chat judger"] = menu.add_feature(lang["Custom chat judge"], "value_str", u.custom_chat_judger.id, function(f)
		if f.on then
			if essentials.listeners["chat"]["judger"] then
				return
			end
			local memoized <const> = {}
			local gsub_map <const> = {
				["[BLACKLIST]"] = "",
				["[JOIN TIMEOUT]"] = ""
			}
			essentials.listeners["chat"]["judger"] = essentials.add_chat_event_listener(function(event)
				if player.is_player_valid(event.player)
				and player.can_player_be_modder(event.player)
				and event.player ~= player.player_id()
				and (not f.data.tracker[player.get_player_scid(event.player)] or utils.time_ms() > f.data.tracker[player.get_player_scid(event.player)])
				and essentials.is_not_friend(event.player) then
					local msg <const> = event.body:lower()
					f.data.tracker[player.get_player_scid(event.player)] = utils.time_ms() + 1000 -- Prevent chat spam problems
					for chat_judge_entry in io.lines(paths.chat_judger) do
						if chat_judge_entry ~= "" and chat_judge_entry ~= "\r" then
							memoized[chat_judge_entry] = memoized[chat_judge_entry] or {
								is_blacklist = chat_judge_entry:find("[BLACKLIST]", 1, true) ~= nil,
								is_timeout = chat_judge_entry:find("[JOIN TIMEOUT]", 1, true) ~= nil,
								entry = (chat_judge_entry:gsub("%[.-%]", gsub_map)):gsub("\r", "")
							}
							local entry <const> = memoized[chat_judge_entry].entry
							if essentials.unicode_find_2(msg, entry) then
								f.data.tracker[player.get_player_scid(event.player)] = utils.time_ms() + 4000
								local player_name <const> = player.get_player_name(event.player)
								if not f.data.blacklist_tracker[player.get_player_scid(event.player)] and memoized[chat_judge_entry].is_blacklist then
									add_to_blacklist(player_name, player.get_player_ip(event.player), player.get_player_scid(event.player), string.format("%s: \"%s\"", lang["Custom chat judge"], entry))
									f.data.blacklist_tracker[player.get_player_scid(event.player)] = true
								end
								if not f.data.timeout_tracker[player.get_player_scid(event.player)] and memoized[chat_judge_entry].is_timeout then
									essentials.add_to_timeout(event.player)
									f.data.timeout_tracker[player.get_player_scid(event.player)] = true
								end
								if essentials.is_str(f, "Ram") then
									essentials.msg(string.format("%s %s %s [%s]", lang["Chat judge:\nRamming"], player_name, lang["with explosive tankers"], entry), "orange", settings.in_use["Chat judge #notifications#"])
									ped.clear_ped_tasks_immediately(player.get_player_ped(event.player))
									system.yield(0)
									kek_entity.ram_player(event.player)
								elseif essentials.is_str(f, "Kick from session") then
									essentials.msg(string.format("%s %s [%s]", lang["Chat judge:\nKicking"], player_name, entry), "orange", settings.in_use["Chat judge #notifications#"])
									essentials.kick_player(event.player)
								elseif essentials.is_str(f, "Crash") then
									essentials.msg(string.format("%s %s [%s]", lang["Chat judge\nCrashing"], player_name, entry), "orange", settings.in_use["Chat judge #notifications#"])
									globals.script_event_crash(event.player)
								end
								break
							end
						end
					end
				end
			end)
		else
			event.remove_event_listener("chat", essentials.listeners["chat"]["judger"])
			essentials.listeners["chat"]["judger"] = nil
		end
	end)
	settings.valuei["Chat judge reaction"] = settings.toggle["Custom chat judger"]
	settings.valuei["Chat judge reaction"].data = {
		tracker = {},
		blacklist_tracker = {},
		timeout_tracker = {}
	}
	settings.valuei["Chat judge reaction"]:set_str_data({
		lang["Ram"], 
		lang["Kick from session"], 
		lang["Crash"]
	})

	menu.add_feature(lang["Create new judger profile"], "action", u.custom_chat_judger.id, function(f)
		local input, status
		while true do
			input, status = keys_and_input.get_input(lang["Type in the name of the profile."], input, 128, 0)
			if status == 2 then
				return
			end
			if input:find("..", 1, true) or input:find("%.$") then
				essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
				goto skip
			end
			if utils.file_exists(paths.kek_menu_stuff.."Chat judger profiles\\"..input..".ini") then
				essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
				goto skip
			end
			if input:find("[<>:\"/\\|%?%*]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
			else
				break
			end
			::skip::
			system.yield(0)
		end
		essentials.create_empty_file(paths.kek_menu_stuff.."Chat judger profiles\\"..input..".ini")
		create_judge_feat(input)
	end)

	menu.add_feature(lang["How to use"], "action_value_str", u.custom_chat_judger.id, function(f)
		essentials.send_pattern_guide_msg(f.value, "Chat judger")
	end):set_str_data({
		lang["Part"].." 1",
		lang["Part"].." 2",
		lang["Part"].." 3",
		lang["Part"].." 4",
		lang["Part"].." 5",
		lang["Part"].." 6"
	})

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."Chat judger profiles", "ini")) do
		create_judge_feat(file_name)
	end
end

do
	local feat = menu.add_feature(lang["Chat spammer"], "value_str", u.chat_spammer.id, function(f)
		while f.on do
			local time <const> = utils.time_ms() -- Send each line won't iterate if string is empty. Therefore it must force a wait if sending a message didn't take > 90ms.
			if essentials.is_str(f, "Spam text") then
				essentials.send_message(settings.in_use["Spam text"])
			elseif essentials.is_str(f, "Random") then
				essentials.send_message(essentials.get_random_string(1, 20))
			elseif essentials.is_str(f, "Send each line") then
				local str <const> = settings.in_use["Spam text"]
				local value <const> = f.value
				for line in str:gmatch("[^\n\r]+") do
					essentials.send_message(line)
					f.data.wait(f)
					if settings.in_use["Spam text"] ~= str or f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			elseif essentials.is_str(f, "From clipboard") then
				essentials.send_message(utils.from_clipboard())
			elseif essentials.is_str(f, "From clipboard & send each line") then
				local str <const> = utils.from_clipboard()
				local value <const> = f.value
				for line in str:gmatch("[^\n\r]+") do
					essentials.send_message(line)
					f.data.wait(f)
					if utils.from_clipboard() ~= str or f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			elseif essentials.is_str(f, "From file") then
				essentials.send_message(essentials.get_file_string(paths.chat_spam_text))
			elseif essentials.is_str(f, "From file & send each line") then
				local value <const> = f.value
				for line in io.lines(paths.chat_spam_text) do
					essentials.send_message(line)
					f.data.wait(f)
					if f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			elseif essentials.is_str(f, "Random text from file") then
				local strings <const> = {}
				local value <const> = f.value
				for line in io.lines(paths.chat_spam_text) do
					strings[#strings + 1] = line
				end
				for i = 1, #strings do
					local num <const> = math.random(1, #strings)
					essentials.send_message(strings[num])
					table.remove(strings, num)
					f.data.wait(f)
					if f.value ~= value then
						break
					end
					if not f.on then
						return
					end
				end
			end
			f.data.wait(f, utils.time_ms() - time < 90)
		end
	end)
	feat.data = essentials.const({
		wait = function(...)
		local f <const>, force_wait <const> = ...
		local value <const> = f.value
		local spam_speed <const> = settings.valuei["Spam speed"].value
		if force_wait or spam_speed > 100 then -- essentials.send_message yields for 100ms guaranteed
			local time <const> = (utils.time_ms() + settings.valuei["Spam speed"].value) - 100 -- 100 compensates for the time waited in essentials.send_message.
			repeat
				system.yield(0)
			until essentials.round(utils.time_ms() / gameplay.get_frame_time() * 1000) >= essentials.round(time / gameplay.get_frame_time() * 1000) or not f.on or value ~= f.value or spam_speed ~= settings.valuei["Spam speed"].value
		end
	end})
	feat:set_str_data({
		lang["Spam text"],
		lang["Random"],
		lang["Send each line"],
		lang["From clipboard"],
		lang["From clipboard & send each line"],
		lang["From file"],
		lang["From file & send each line"],
		lang["Random text from file"]
	})
end

settings.valuei["Spam speed"] = menu.add_feature(lang["Spam speed, click to type"], "action_value_i", u.chat_spammer.id, function(f)
	keys_and_input.input_number_for_feat(f, lang["Type in chat spam speed"])
end)
settings.valuei["Spam speed"].max, settings.valuei["Spam speed"].min, settings.valuei["Spam speed"].mod = 1000000, 100, 25

menu.add_feature(lang["Text to spam, type it in"], "action", u.chat_spammer.id, function(f)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in what to spam in chat"], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Spam text"] = input
end)

settings.toggle["Only friends can use chat commands"] = menu.add_feature(lang["Only friends can use commands"], "toggle", u.chat_commands.id)

settings.toggle["Friends can't be targeted by chat commands"] = menu.add_feature(lang["Friends can't be targeted"], "toggle", u.chat_commands.id)

settings.toggle["You can't be targeted"] = menu.add_feature(lang["You can't be targeted"], "toggle", u.chat_commands.id)

settings.toggle["Chat commands"] = menu.add_feature(lang["Chat commands"], "toggle", u.chat_commands.id, function(f)
	if f.on then
		essentials.listeners["chat"]["commands"] = essentials.add_chat_event_listener(function(event)
			if player.is_player_valid(event.player) and f.data.command_strings[(event.body:match("^%p(%a+)") or ""):lower()] then
				if utils.time_ms() < (f.data.tracker[event.player] or 0) then
					essentials.send_message("[Chat commands]: Attempting too many commands. Max 1 command every second.", player.player_id() == event.player)
					return
				end
				f.data.tracker[event.player] = utils.time_ms() + 1000
				if f.data.player_chat_command_blacklist[player.get_player_scid(event.player)] then
					essentials.send_message(string.format("[Chat commands]: Your chat command access have been revoked, %s.", player.get_player_name(event.player)), event.player == player.player_id())
					return
				end
				if not (not settings.toggle["Only friends can use chat commands"].on or network.is_scid_friend(player.get_player_scid(event.player)) or player.player_id() == event.player) then
					essentials.send_message("[Chat commands]: You can't use chat commands.")
					return
				end
				if player.is_player_valid(event.player) then
					local str = event.body:lower()
					local found_player_pid = false
					local pid
					local player_name <const> = str:match("^%p%a+ ([^\32]+)")
					if player_name 
					and not str:find("^%ptp [^\32]+$")
					and not str:find("^%pteleport [^\32]+$")
					and not str:find("^%p[^\32]+ on")
					and not str:find("^%p[^\32]+ off") -- It's quite common for player names to have on or off in their names.
					and player.is_player_valid(essentials.name_to_pid(player_name)) then
						pid = essentials.name_to_pid(player_name)
						local name_pattern <const> = essentials.remove_special(player_name):lower()
						str = str:gsub(" "..name_pattern.." ", " ")
						str = str:gsub(" "..name_pattern.."$", "")
						found_player_pid = true
					else
						pid = event.player
					end

					if settings.toggle["You can't be targeted"].on and pid == player.player_id() and event.player ~= player.player_id() then
						essentials.send_message("[Chat commands]: You can't use chat commands on this player.")
						return
					end
					if settings.toggle["Friends can't be targeted by chat commands"].on and event.player ~= pid and network.is_scid_friend(player.get_player_scid(pid)) and player.player_id() ~= event.player then
						essentials.send_message("[Chat commands]: You can't use chat commands on this player.")
						return
					end
					if f.on then
						if settings.in_use["Spawn #chat command#"] and str:find("^%pspawn [^\32]+") then
							local hash <const> = vehicle_mapper.get_hash_from_user_input(str:match("^%pspawn (.*)"))
							if not streaming.is_model_a_vehicle(hash) then
								essentials.send_message("[Chat commands]: Invalid vehicle name.", event.player == player.player_id())
								return
							end
							if player.player_id() ~= event.player 
							and not network.is_scid_friend(player.get_player_scid(event.player))
							and settings.toggle["Vehicle blacklist"].on
							and settings.in_use["vehicle_blacklist_"..vehicle_mapper.GetModelFromHash(hash)] ~= 0 then
								essentials.send_message("[Chat commands]: This vehicle is blacklisted.", event.player == player.player_id())
								return
							end
							menu.create_thread(function()
								local Vehicle <const> = kek_entity.spawn_networked_vehicle(hash, function()
									local pos = kek_entity.vehicle_get_vec_rel_to_dims(hash, player.get_player_ped(pid))
									local accurate_pos <const> = location_mapper.get_most_accurate_position_soft(pos)
									if pos == accurate_pos then -- If ground_z can't be obtained
										pos = essentials.get_player_coords(pid) 
									end
									return pos, player.get_player_heading(pid)
								end, {
									godmode = settings.toggle["Spawn #vehicle# in godmode"].on, 
									max = settings.toggle["Spawn #vehicle# maxed"].on,
									persistent = false
								})
								if not entity.is_entity_a_vehicle(Vehicle) then
									essentials.send_message("[Chat commands]: Vehicle spawn limit is reached. Spawns are disabled.", event.player == player.player_id())
								end
							end, nil)
						elseif settings.in_use["weapon #chat command#"] and str:find("^%pweapon [^\32]+") then
							if str:find("^%pweapon all$") then
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									if not weapon.has_ped_got_weapon(player.get_player_ped(pid), weapon_hash) then
										weapon.give_delayed_weapon_to_ped(player.get_player_ped(pid), weapon_hash, 1, 0)
										weapon.set_ped_ammo(player.get_player_ped(pid), weapon_hash, 9999)
										system.yield(0)
										if pid == player.player_id() then 
											weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(pid), true, weapon_hash)
										end
									end
								end
							else
								local user_input <const> = essentials.make_string_case_insensitive(str:match("^%pweapon (.+)"))
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									if weapon.get_weapon_name(weapon_hash):find(user_input) then
										if not weapon.has_ped_got_weapon(player.get_player_ped(pid), weapon_hash) then
											weapon.give_delayed_weapon_to_ped(player.get_player_ped(pid), weapon_hash, 1, 0)
											weapon.set_ped_ammo(player.get_player_ped(pid), weapon_hash, 9999)
											if pid == player.player_id() then 
												weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(pid), true, weapon_hash)
											end
										end
										return
									end
								end
								essentials.send_message("[Chat commands]: Invalid weapon name.", event.player == player.player_id())
							end
						elseif settings.in_use["removeweapon #chat command#"] and str:find("^%premoveweapon .+") then
							local user_input <const> = essentials.make_string_case_insensitive(str:match("^%premoveweapon (.+)"))
							if str:find("^%premoveweapon all$") then
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									weapon.remove_weapon_from_ped(player.get_player_ped(pid), weapon_hash)
									system.yield(0)
								end
							else
								for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
									if weapon.get_weapon_name(weapon_hash):find(user_input) then
										weapon.remove_weapon_from_ped(player.get_player_ped(pid), weapon_hash)
										return
									end
								end
								essentials.send_message("[Chat commands]: Invalid weapon name.", event.player == player.player_id())
							end
						elseif settings.in_use["Kill #chat command#"] and str:find("^%pkill") and (pid ~= event.player or found_player_pid) then
							if player.is_player_god(pid) then
								essentials.send_message(string.format("[Chat commands] Failed to kill %s; He is in a property or in godmode. Them being in godmode doesn't mean they're a modder, the game gives you godmode in many scenarios.", player.get_player_name(pid)), event.player == player.player_id())
							else
								menu.create_thread(function()
									local blame
									if player.is_player_valid(essentials.name_to_pid(str:match("^%pkill ([^\32]+)$"))) then
										blame = essentials.name_to_pid(str:match("^%pkill ([^\32]+)$"))
									else
										blame = event.player
									end
									local time <const> = utils.time_ms() + 900
									while not entity.is_entity_dead(player.get_player_ped(pid)) and time > utils.time_ms() do
										essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), enums.explosion_types.BARREL, true, false, 0, player.get_player_ped(blame))
										system.yield(75)
									end
									kek_entity.ram_player(pid)
								end, nil)
							end
						elseif settings.in_use["Cage #chat command#"] and str:find("^%pcage$") and (pid ~= event.player or found_player_pid) then
							local update <const> = kek_entity.entity_manager:update()
							if update.is_object_limit_not_breached and update.is_ped_limit_not_breached then
								menu.create_thread(function()
									local Ped <const> = kek_entity.create_cage(pid)
									if not entity.is_entity_a_ped(Ped) then
										essentials.send_message("[Chat commands]: Failed to spawn cage. Entity limits are reached.", event.player == player.player_id())
									end
								end, nil)
							else
								essentials.send_message("[Chat commands]: Failed to spawn cage. Entity limits are reached.", event.player == player.player_id())
							end
						elseif settings.in_use["Kick #chat command#"] and str:find("^%pkick$") then
							if pid == event.player then
								essentials.send_message("[Chat commands]: You can't kick yourself.")
								return
							end
							if pid == player.player_id() or not player.can_player_be_modder(pid) then
								essentials.send_message("[Chat commands]: You can't kick this player.")
								return
							end
							essentials.kick_player(pid)
						elseif settings.in_use["Crash #chat command#"] and str:find("^%pcrash$") then
							if pid == event.player then
								essentials.send_message("[Chat commands]: You can't crash yourself.")
								return
							end
							if pid == player.player_id() then
								essentials.send_message("[Chat commands]: You can't crash this player.")
								return
							end
							menu.create_thread(function()
								globals.script_event_crash(pid)
							end, nil)
						elseif settings.in_use["clowns #chat command#"] and str:find("^%pclowns$") then
							menu.create_thread(function()
								local clown_van <const> = troll_entity.send_clown_van(pid)
								if not entity.is_entity_a_vehicle(clown_van) then
									essentials.send_message("[Chat commands]: Failed to spawn clown van.", event.player == player.player_id())
								end
							end, nil)
						elseif settings.in_use["jet #chat command#"] and str:find("^%pjet$") then
							menu.create_thread(function()
								local jet <const> = troll_entity.send_jet(pid)
								if not entity.is_entity_a_vehicle(jet) then
									essentials.send_message("[Chat commands]: Failed to spawn jet.", event.player == player.player_id())
								end
							end, nil)
						elseif settings.in_use["chopper #chat command#"] and str:find("^%pchopper$") then
							menu.create_thread(function()
								local chopper <const> = troll_entity.send_attack_chopper(pid)
								if not entity.is_entity_a_vehicle(chopper) then
									essentials.send_message("[Chat commands]: Failed to spawn chopper.", event.player == player.player_id())
								end
							end, nil)
						elseif settings.in_use["tp #chat command#"] and (str:find("^%ptp [^\32]+") or str:find("^%pteleport [^\32]+")) then
							str = str:gsub("^%pteleport", "!tp")
							menu.create_thread(function()
								local pos
								if player.is_player_valid(essentials.name_to_pid(str:match("^%ptp ([^\32]+)"))) then
									pos = "player_pos" -- forcing player causes out-of-date position, so position is grabbed afterwards
								end
								if not pos then
									local str <const> = str:match("^%ptp (.+)"):lower()
									for name, vector in pairs(location_mapper.GENERAL_POSITIONS) do
										if not pos and name:lower():find(str, 1, true) then
											pos = vector
										elseif pos and name:lower() == str then
											pos = vector
										end
									end
								end
								if not pos then
									local x <const> = tonumber(str:match("^%ptp (%-?[%d.-]+),?"))
									local y <const> = tonumber(str:match("^%ptp %-?[%d.-]+,? (%-?[%d.-]+)"))
									local z <const> = tonumber(str:match("^%ptp %-?[%d.-]+,? %-?[%d.-]+,? (%-?[%d.-]+)"))
									if x and y then
										if not z then
											pos = location_mapper.get_most_accurate_position(v3(x, y, -50), true)
										else
											pos = v3(x, y, z)
										end
									end
								end
								if pos then
									menu.create_thread(function()
										if player.player_id() ~= pid and not essentials.is_in_vehicle(pid) then
											globals.force_player_into_vehicle(pid)
										end
										if pos == "player_pos" then
											pos = kek_entity.get_vector_relative_to_entity(player.get_player_ped(essentials.name_to_pid(str:match("^%ptp ([^\32]+)"))), 7)
										end
										kek_entity.teleport_player_and_vehicle_to_position(
											pid, 
											pos
										)
									end, nil)
								else
									essentials.send_message("[Chat commands]: Failed to find out where you wanted to teleport to.", event.player == player.player_id())
								end
							end, nil)
						elseif settings.in_use["apartmentteleport #chat command#"] and str:find("^%papartmentteleport") then
							local apartment_id <const> = tonumber(str:match("^%papartmentteleport (%d+)$"))
							if not apartment_id or apartment_id < 1 or apartment_id > 113 then
								essentials.send_message("[Chat commands]: Invalid apartment id. Must be between 1 and 113.", event.player == player.player_id())
								return
							end
							globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, apartment_id, 1, 1, 1})
						elseif settings.in_use["offtheradar #chat command#"] and str:find("^%pofftheradar") then
							if not str:match("%pofftheradar (%a+)") then
								essentials.send_message("[Chat commands]: Missing argument <on/off>")
								return
							end
							if str:match("%pofftheradar (%a+)") ~= "on" and str:match("%pofftheradar (%a+)") ~= "off" then
								essentials.send_message("[Chat commands]: expected <on/off>, got \""..str:match("%pofftheradar (%a+)").."\"")
								return
							end
							menu.get_player_feature(player_feat_ids["player otr"]).feats[pid].on = str:match("%pofftheradar (%a+)") == "on"
						elseif settings.in_use["neverwanted #chat command#"] and str:find("^%pneverwanted") then
							if not str:match("%pneverwanted (%a+)") then
								essentials.send_message("[Chat commands]: Missing argument <on/off>")
								return
							end
							if str:match("%pneverwanted (%a+)") ~= "on" and str:match("%pneverwanted (%a+)") ~= "off" then
								essentials.send_message("[Chat commands]: expected <on/off>, got \""..str:match("%pneverwanted (%a+)").."\"")
								return
							end
							menu.get_player_feature(player_feat_ids["Never wanted"]).feats[pid].on = str:match("%pneverwanted (%a+)") == "on"
						elseif settings.in_use["bounty #chat command#"] and str:find("^%pbounty") then
							if globals.get_player_global("bounty_status", pid) == 1 then
								essentials.send_message("[Chat commands]: This player already have a bounty set on them.")
								return
							end
							local amount <const> = math.tointeger(str:match("^%pbounty%s+(%d+)"))
							if not amount or amount < 0 or amount > 10000 then
								essentials.send_message("[Chat commands]: Invalid bounty amount. It have to be an integer number between 0 & 10000.")
								return
							end
							globals.set_bounty(pid, false, true, amount)
						elseif str:find("^%phelp$") then
							if not admin_mapper.is_there_admin_in_session() then
								f.data.send_chat_commands()
							end
						end
					end
				end
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["commands"])
		essentials.listeners["chat"]["commands"] = nil
	end
end)

do
	local chat_command_setting_properties <const> = essentials.const({
		{
			setting_name = "Kick #chat command#", 
			setting = false, 
			feature_name = lang["Kick"],
			args = "<Player>"
		},
		{
			setting_name = "Crash #chat command#", 
			setting = false, 
			feature_name = lang["Crash"],
			args = "<Player>"
		},
		{
			setting_name = "apartmentteleport #chat command#", 
			setting = false, 
			feature_name = lang["Apartment invites"], 
			args = "<Player> <1 - 113>"
		},
		{
			setting_name = "Cage #chat command#", 
			setting = false, 
			feature_name = lang["Cage player"],
			args = "<Player>"
		},
		{
			setting_name = "Kill #chat command#", 
			setting = false, 
			feature_name = lang["Kill player"], 
			args = "<Player> <Player>"
		},
		{
			setting_name = "clowns #chat command#", 
			setting = false, 
			feature_name = lang["Clown vans"],
			args = "<Player>"
		},
		{
			setting_name = "jet #chat command#", 
			setting = false, 
			feature_name = lang["Jet"],
			args = "<Player>"
		},
		{
			setting_name = "chopper #chat command#", 
			setting = false, 
			feature_name = lang["Send attack chopper"],
			args = "<Player>"
		},
		{
			setting_name = "neverwanted #chat command#", 
			setting = true, 
			feature_name = lang["Never wanted"],
			args = "<Player> <on / off>"
		},
		{
			setting_name = "bounty #chat command#",
			setting = true,
			feature_name = lang["Set bounty"],
			args = "<Player> <0 - 10000>"
		},
		{
			setting_name = "offtheradar #chat command#", 
			setting = true, 
			feature_name = lang["off the radar"],
			args = "<Player> <on / off>"
		},
		{
			setting_name = "Spawn #chat command#", 
			setting = true, 
			feature_name = lang["Spawn vehicle"], 
			args = "<Player> <Vehicle>"
		},
		{
			setting_name = "weapon #chat command#", 
			setting = true, 
			feature_name = lang["Give weapon"], 
			args = "<Player> <Weapon name / All>"
		},
		{
			setting_name = "removeweapon #chat command#", 
			setting = false, 
			feature_name = lang["Remove weapon"], 
			args = "<Player> <Weapon name / All>"
		},
		{
			setting_name = "tp #chat command#", 
			setting = false, 
			feature_name = lang["Teleport to"], 
			args = "<Player> <Player / Location>",
			alternative_command_info = "or !teleport "
		}
	})

	settings.toggle["Chat commands"].data = essentials.const({
		tracker = {},
		command_strings = {
			teleport = true,
			help = true
		},
		player_chat_command_blacklist = {},
		send_chat_commands = function(send_to_team)
			local str = {"Chat Commands:"}
			local str_len = 0
			for i = 1, #chat_command_setting_properties do
				if settings.in_use[chat_command_setting_properties[i].setting_name] then
					str[#str + 1] = string.format("!%s%s%s",
					chat_command_setting_properties[i].setting_name:lower():gsub("#chat command#", ""),
					chat_command_setting_properties[i].alternative_command_info or "",
					chat_command_setting_properties[i].args or "")
					str_len = str_len + #str[#str]
					if str_len > 190 then
						essentials.send_message(table.concat(str, "\n"), send_to_team)
						str = {}
						str_len = 0
					end
				end
			end
			if str_len > 180 then
				essentials.send_message(table.concat(str, "\n"), send_to_team)
				str = {}
				str_len = 0
			end
			if settings.toggle["Only friends can use chat commands"].on then
				str[#str + 1] = "These commands can only be used by my friends."
			else
				str[#str + 1] = "These commands can be used by everyone."
			end
			str[#str + 1] = "To show this again, do !help"
			essentials.send_message(table.concat(str, "\n"), send_to_team)
		end
	})

	for _, properties in pairs(chat_command_setting_properties) do
		settings:add_setting(properties)
		settings.toggle["Chat commands"].data.command_strings[properties.setting_name:lower():match("(%w+)%s+#chat command#")] = false
	end

	menu.add_feature(lang["Send command list"], "action_value_str", u.chat_commands.id, function(f)
		settings.toggle["Chat commands"].data.send_chat_commands(essentials.is_str(f, "Team"))
	end):set_str_data({
		lang["All"],
		lang["Team"]
	})

	settings.toggle["Send command info"] = menu.add_feature(lang["Send command list every"], "value_str", u.chat_commands.id, function(f)
		while f.on do
			local time <const> = utils.time_ms() + ((f.value + 1) * 60000)
			local value <const> = f.value
			while f.on and time > utils.time_ms() and globals.is_fully_transitioned_into_session() and f.value == value do
				system.yield(0)
			end
			if settings.toggle["Chat commands"].on and settings.toggle["Send command info"].on and value == f.value then
				while not globals.is_fully_transitioned_into_session() and f.on do
					system.yield(0)
				end
				if not admin_mapper.is_there_admin_in_session() and f.on then
					settings.toggle["Chat commands"].data.send_chat_commands()
				end
			end
			system.yield(0)
		end
	end)
	do
		local str <const> = {
			lang["minute"],
			"2nd "..lang["minute"],
			"3rd "..lang["minute"]
		}
		for i = 4, 120 do
			str[i] = string.format("%ith %s", i, lang["minute"])
		end
		settings.toggle["Send command info"]:set_str_data(str)
	end
	settings.valuei["Help interval"] = settings.toggle["Send command info"]

	u.chat_commands_parent = menu.add_feature(lang["Commands"], "parent", u.chat_commands.id)
	for _, properties in pairs(chat_command_setting_properties) do
		settings.toggle[properties.setting_name] = menu.add_feature(properties.feature_name, "toggle", u.chat_commands_parent.id, function(f)
			settings.in_use[properties.setting_name] = f.on
			settings.toggle["Chat commands"].data.command_strings[properties.setting_name:lower():match("(%w+)%s+#chat command#")] = f.on
		end)
	end
end

settings.valuei["Echo delay"] = menu.add_feature(lang["Echo delay, click to type"], "action_value_i", u.chat_spammer.id, function(f)
	keys_and_input.input_number_for_feat(f, lang["Type in echo delay."])	
end)
settings.valuei["Echo delay"].max, settings.valuei["Echo delay"].min, settings.valuei["Echo delay"].mod = 20000, 0, 25

settings.toggle["Echo chat"] = menu.add_feature(lang["Echo chat"], "toggle", u.chat_spammer.id, function(f)
	if f.on then
		essentials.listeners["chat"]["echo"] = essentials.add_chat_event_listener(function(event)
			if player.is_player_valid(event.player) 
			and player.player_id() ~= event.player 
			and essentials.is_not_friend(event.player) then
				for i = 1, settings.valuei["Echo delay"].value / 10 do
					if not f.on or settings.valuei["Echo delay"].value ~= settings.valuei["Echo delay"].value then
						break
					end
					system.yield(0)
				end
				essentials.send_message(event.body)
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["echo"])
		essentials.listeners["chat"]["echo"] = nil
	end
end)

do
	local function create_chatbot_feat(...)
		local name <const> = ...
		if name:find("..", 1, true) or name:find("%.$") or name ~= essentials.get_safe_feat_name(name) then
			return
		end
		menu.add_feature(essentials.get_safe_feat_name(name):gsub("%.ini$", ""), "action_value_str", u.chat_bot.id, function(f)
			if essentials.is_str(f, "Load") then
				if not utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini") then
					essentials.msg(lang["Couldn't find file"], "red", true)
				else
					local str <const> = essentials.get_file_string(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini")
					do
						local is_valid, line_num = essentials.are_all_lines_pattern_valid(str, "|([^\n\r]+)|&")
						if not is_valid then
							essentials.msg(string.format("%s: %i\nscripts\\kek_menu_stuff\\Chatbot profiles\\%s.ini", lang["Failed to load profile. Error at line"], line_num, f.name), "red", true, 8)
							return
						end
					end
					essentials.msg(string.format("%s %s", lang["Successfully loaded"], f.name), "green", true)
					local file <close> = io.open(paths.chat_bot, "w+")
					file:write(str)
					file:flush()
					u.update_chat_bot = true
				end
			elseif essentials.is_str(f, "Add entry") then
				local what_to_react_to = ""
				local status
				while true do
					what_to_react_to, status = keys_and_input.get_input(lang["Type in what the bot will react to."], what_to_react_to, 128, 0)
					if essentials.search_for_match_and_get_line(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini", {string.format("|%s|", what_to_react_to)}) then
						essentials.msg(lang["Entry already exists in this profile."], "orange", true, 6)
						goto skip 
					end
					if status == 2 then
						return
					end
					if not essentials.invalid_pattern(what_to_react_to, true, true) and not what_to_react_to:find("[¢|&]") then
						break
					elseif not essentials.invalid_pattern(what_to_react_to) then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"¢\", \"|\" & \"&\"", "red", true, 7)
					end
					::skip::
					system.yield(0)
				end
				local reaction <const> = {}
				local i = 1
				local str, status = ""
				while u.number_of_responses_from_chat_bot.value >= i do
					str, status = keys_and_input.get_input(lang["Type in what the bot will say to what you previously typed in."], str, 128, 0)
					if status == 2 then
						return
					end	
					if not str:find("[¢|&]") then
						reaction[#reaction + 1] = str
						i = i + 1
						str = ""
					else
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"¢\", \"|\" & \"&\"", "red", true, 7)
					end
					system.yield(0)
				end
				if #reaction == 0 then
					essentials.msg(lang["Too few reactions to add entry."], "red", true)
					return
				end
				essentials.log(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini", string.format("|%s|&¢ %s ¢&", what_to_react_to, table.concat(reaction, " ¢¢ ")))
				essentials.msg(lang["Successfully added entry."], "green", true)
			elseif essentials.is_str(f, "Remove entry") then
				local what_to_remove <const>, status <const> = keys_and_input.get_input(lang["Type in what the text the bot reacts to in the entry you wish to remove."], "", 128, 0)
				if status == 2 then
					return
				end
				if essentials.remove_lines_from_file_exact(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini", string.format("|%s|", what_to_remove)) then
					essentials.msg(lang["Removed entry."], "green", true)
				else 
					essentials.msg(lang["Couldn't find entry."], "orange", true)
				end
			elseif essentials.is_str(f, "Delete profile") then
				if utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini") then
					io.remove(paths.kek_menu_stuff.."Chatbot profiles\\"..f.name..".ini")
				end
				f.hidden = true
			elseif essentials.is_str(f, "Change name") then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in the name of the profile."], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
						goto skip
					end
					if utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..input..".ini") then
						essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
						goto skip
					end
					if input:find("[<>:\"/\\|%?%*]") then
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
					else
						break
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file(paths.kek_menu_stuff.."Chatbot profiles\\", f.name, input, "ini")
				f.name = input
			end
		end):set_str_data({
			lang["Load"],
			lang["Add entry"],
			lang["Remove entry"],
			lang["Delete profile"],
			lang["Change name"]
		})
	end

	u.number_of_responses_from_chat_bot = menu.add_feature(lang["Number of responses"], "action_value_i", u.chat_bot.id)
	u.number_of_responses_from_chat_bot.max = 100
	u.number_of_responses_from_chat_bot.min = 1
	u.number_of_responses_from_chat_bot.mod = 1
	u.number_of_responses_from_chat_bot.value = 1

	settings.valuei["chat bot delay"] = menu.add_feature(lang["Answer delay chatbot"], "action_value_i", u.chat_bot.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in answer delay."])	
	end)
	settings.valuei["chat bot delay"].max, settings.valuei["chat bot delay"].min, settings.valuei["chat bot delay"].mod = 7200, 0, 20

	settings.valuei["Chance to reply"] = menu.add_feature(lang["Chance to reply"].." %", "action_value_i", u.chat_bot.id)
	settings.valuei["Chance to reply"].min = 1
	settings.valuei["Chance to reply"].max = 100
	settings.valuei["Chance to reply"].mod = 1

	settings.toggle["chat bot"] = menu.add_feature(lang["Chat bot"], "toggle", u.chat_bot.id, function(f)
		if f.on then
			local str = essentials.get_file_string(paths.chat_bot)
			do
				local is_valid, line_num = essentials.are_all_lines_pattern_valid(str, "|([^\n\r]+)|&")
				if not is_valid then
					essentials.msg(string.format("[%s]: %s: %i\nscripts\\kek_menu_stuff\\kekMenuData\\Kek's chat bot.txt", lang["Chat bot"], lang["Failed to load profile. Error at line"], line_num), "red", true, 12)
					f.on = false
					return
				end
			end
			essentials.listeners["chat"]["bot"] = essentials.add_chat_event_listener(function(event)
				if player.is_player_valid(event.player)
				and player.player_id() ~= event.player 
				and math.random(1, 100) <= settings.valuei["Chance to reply"].value then
					system.yield(settings.valuei["chat bot delay"].value)
					if player.is_player_valid(event.player) then
						if u.update_chat_bot then
							str = essentials.get_file_string(paths.chat_bot)
							u.update_chat_bot = false
						end
						local count, reactions_str = 0
						local msg <const> = event.body:lower()
						for what_to_react_to, reactions in str:gmatch("|([^\n\r]+)|&([^\n\r]+)&") do
							what_to_react_to = what_to_react_to:lower()
							local start, End = msg:find(what_to_react_to)
							if start and End - start > count then
								count = End - start
								reactions_str = reactions
							end
						end
						if not reactions_str then
							return
						end
						local reactions <const> = {}
						for entry in reactions_str:gmatch("¢ (.-) ¢") do
							reactions[#reactions + 1] = entry
						end
						local str = reactions[math.random(math.min(1, #reactions), #reactions)]
						str = str:gsub("%[PLAYER_NAME%]", player.get_player_name(event.player))
						str = str:gsub("%[MY_NAME%]", player.get_player_name(player.player_id()))
						local exclusion <const> = {[player.player_id()] = true}
						str = str:gsub("%[RANDOM_NAME%]", function()
							return player.get_player_name(essentials.get_random_player_except(exclusion))
						end)
						essentials.send_message(str)
					end
				end
			end)
		else
			event.remove_event_listener("chat", essentials.listeners["chat"]["bot"])
			essentials.listeners["chat"]["bot"] = nil
		end
	end) 

	menu.add_feature(lang["Create new chatbot profile"], "action", u.chat_bot.id, function(f)
		local input, status
		while true do
			input, status = keys_and_input.get_input(lang["Type in the name of the profile."], input, 128, 0)
			if status == 2 then
				return
			end
			if input:find("..", 1, true) or input:find("%.$") then
				essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
				goto skip
			end
			if utils.file_exists(paths.kek_menu_stuff.."Chatbot profiles\\"..input..".ini") then
				essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
				goto skip
			end
			if input:find("[<>:\"/\\|%?%*]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
			else
				break
			end
			::skip::
			system.yield(0)
		end
		essentials.create_empty_file(paths.kek_menu_stuff.."Chatbot profiles\\"..input..".ini")
		create_chatbot_feat(input)
	end)

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."Chatbot profiles", "ini")) do
		create_chatbot_feat(file_name)
	end

	menu.add_feature(lang["How to use"], "action_value_str", u.chat_bot.id, function(f)
		essentials.send_pattern_guide_msg(f.value, "Chatbot")
	end):set_str_data({
		lang["Part"].." 1",
		lang["Part"].." 2",
		lang["Part"].." 3",
		lang["Part"].." 4",
		lang["Part"].." 5"
	})
end

settings.toggle["Clever bot"] = menu.add_feature(lang["Log chat & use as chatbot"], "toggle", u.chat_bot.id, function(f)
	if f.on then
		local mapped_messages <const> = {}
		local concat_str <const> = {}
		do
			local index
			for line in io.lines(paths.clever_bot) do
				if line:find("%S%s*§|§") then
					if mapped_messages[index] and #mapped_messages[index] == 0 then
						mapped_messages[index] = nil
					end
					index = line:match("(.*)§|§")
					concat_str[#concat_str + 1] = line
					mapped_messages[index] = {index = #concat_str}
				elseif line:find("^\t%s*%S") then
					concat_str[#concat_str + 1] = line
					mapped_messages[index][#mapped_messages[index] + 1] = line
				end
			end
		end
		local last_response
		essentials.listeners["chat"]["Clever bot"] = essentials.add_chat_event_listener(function(event)
			if player.is_player_valid(event.player) and (not f.data[player.get_player_scid(event.player)] or utils.time_ms() > f.data[player.get_player_scid(event.player)]) then
				f.data[player.get_player_scid(event.player)] = utils.time_ms() + 1000
				if math.random(1, 100) <= settings.valuei["Chance to reply"].value and mapped_messages[event.body] and event.player ~= player.player_id() then
					essentials.send_message(mapped_messages[event.body][math.random(1, #mapped_messages[event.body])]:match("^\t(.*)"))
				end
				if not event.body:find("^%p") and not event.body:find("[Chat commands]", 1, true) and not essentials.contains_advert(event.body) then
					if last_response then
						if mapped_messages[last_response] then
							for i = 1, #mapped_messages[last_response] do
								if mapped_messages[last_response][i] == "\t"..event.body then
									return
								end
							end
							local initial_size <const> = #concat_str
							mapped_messages[last_response][#mapped_messages[last_response] + 1] = "\t"..event.body
							for i = 0, #mapped_messages[last_response] do -- Manual shift is far more efficient than table.remove. This shifts all elements multiple indices at once.
								concat_str[mapped_messages[last_response].index + i] = nil
							end
							if #concat_str == initial_size then
								local size <const> = #mapped_messages[last_response] + 1
								for i = mapped_messages[last_response].index, #concat_str - size do
									concat_str[i] = concat_str[i + size]
								end
								for i = (#concat_str - size) + 1, #concat_str do
									concat_str[i] = nil
								end
							end
						else
							mapped_messages[last_response] = {"\t"..event.body}
						end
						mapped_messages[last_response].index = #concat_str + 1
						concat_str[#concat_str + 1] = last_response.."§|§"
						for i = 1, #mapped_messages[last_response] do
							concat_str[#concat_str + 1] = mapped_messages[last_response][i]
						end
						local file <close> = io.open(paths.clever_bot, "w+")
						concat_str[#concat_str + 1] = "" -- Inserting newline at last position
						file:write(table.concat(concat_str, "\n"))
						concat_str[#concat_str] = nil -- So this doesn't interfere with the manual index shifts
						file:flush()
					end
					last_response = event.body
				end
			end
		end)
	else
		event.remove_event_listener("chat", essentials.listeners["chat"]["Clever bot"])
		essentials.listeners["chat"]["Clever bot"] = nil
	end
end)
settings.toggle["Clever bot"].data = {}

settings.toggle["Auto tp to waypoint"] = menu.add_feature(lang["Auto tp to waypoint"], "toggle", u.self_options.id, function(f)
	while f.on do
		system.yield(0)
		if hud.is_waypoint_active() then
			local pos <const> = ui.get_waypoint_coord()
			ui.set_waypoint_off()
			kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), location_mapper.get_most_accurate_position(v3(pos.x, pos.y, -50)))
		end
	end
end)

settings.toggle["Move mini map to people you spectate"] = menu.add_feature(lang["Move mini map to people you spectate"], "toggle", u.self_options.id, function(f)
	local who_spectating
	local pos <const> = player.get_player_coords(player.player_id())
	player.extend_world_boundary_for_player(pos.x, pos.y, pos.z)
	while f.on do
		system.yield(0)
		if network.network_is_in_spectator_mode() then
			who_spectating = network.get_player_player_is_spectating(player.player_id()) or who_spectating
			entity.set_entity_velocity(kek_entity.get_most_relevant_entity(player.player_id()), memoize.v3())
			hud.set_minimap_in_spectator_mode(true, player.get_player_ped(who_spectating))
		elseif who_spectating and who_spectating ~= -1 then
			hud.set_minimap_in_spectator_mode(false, player.get_player_ped(who_spectating))
			who_spectating = -1
		end
	end
	player.reset_world_boundary_for_player()
end)

local function display_settings(...)
	local parent <const>,
	name_of_feature <const>,
	x <const>,
	y <const>,
	scale <const>,
	max_scale <const>,
	stretch <const> = ...

	if stretch then
		settings.valuef[name_of_feature.." stretch"] = menu.add_feature(lang["Stretch"], "action_value_f", parent.id, function(f)
			keys_and_input.input_number_for_feat(f, lang["Type in stretch"])
		end)
		settings.valuef[name_of_feature.." stretch"].min = 0.2
		settings.valuef[name_of_feature.." stretch"].max = 250
		settings.valuef[name_of_feature.." stretch"].mod = 0.2
		settings:add_setting({
			setting_name = name_of_feature.." stretch", 
			setting = 35
		})
	end
	settings.valuei[name_of_feature.." X"] = menu.add_feature("X", "action_value_i", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in where horizontally the time is displayed."])
	end)
	settings.valuei[name_of_feature.." X"].min = 0
	settings.valuei[name_of_feature.." X"].max = 2000
	settings.valuei[name_of_feature.." X"].mod = 10
	settings:add_setting({
		setting_name = name_of_feature.." X", 
		setting = x
	})

	settings.valuei[name_of_feature.." Y"] = menu.add_feature("Y", "action_value_i", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in where vertically the time is displayed."])
	end)
	settings.valuei[name_of_feature.." Y"].min = 0
	settings.valuei[name_of_feature.." Y"].max = 2000
	settings.valuei[name_of_feature.." Y"].mod = 10
	settings:add_setting({
		setting_name = name_of_feature.." Y", 
		setting = y
	})

	settings.valuei[name_of_feature.." font"] = menu.add_feature(lang["Font"], "action_value_i", parent.id)
	settings.valuei[name_of_feature.." font"].min = 0
	settings.valuei[name_of_feature.." font"].max = 8
	settings.valuei[name_of_feature.." font"].mod = 1
	settings:add_setting({
		setting_name = name_of_feature.." font", 
		setting = 1
	})

	settings.toggle[name_of_feature.." outline"] = menu.add_feature(lang["Outline"], "toggle", parent.id)
	settings:add_setting({
		setting_name = name_of_feature.." outline", 
		setting = true
	})

	settings.valuei[name_of_feature.." R"] = menu.add_feature("R", "action_value_i", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in RGB"]..": R")
	end)
	settings.valuei[name_of_feature.." R"].min = 0
	settings.valuei[name_of_feature.." R"].max = 255
	settings.valuei[name_of_feature.." R"].mod = 5
	settings:add_setting({
		setting_name = name_of_feature.." R", 
		setting = 255
	})

	settings.valuei[name_of_feature.." G"] = menu.add_feature("G", "action_value_i", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in RGB"]..": G")
	end)
	settings.valuei[name_of_feature.." G"].min = 0
	settings.valuei[name_of_feature.." G"].max = 255
	settings.valuei[name_of_feature.." G"].mod = 5
	settings:add_setting({
		setting_name = name_of_feature.." G", 
		setting = 100
	})

	settings.valuei[name_of_feature.." B"] = menu.add_feature("B", "action_value_i", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in RGB"]..": B")
	end)
	settings.valuei[name_of_feature.." B"].min = 0
	settings.valuei[name_of_feature.." B"].max = 255
	settings.valuei[name_of_feature.." B"].mod = 5
	settings:add_setting({
		setting_name = name_of_feature.." B", 
		setting = 255
	})

	settings.valuei[name_of_feature.." scale"] = menu.add_feature(lang["Size"], "action_slider", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in the size of the text."])
	end)
	settings.valuei[name_of_feature.." scale"].min = 0
	settings.valuei[name_of_feature.." scale"].max = max_scale
	settings.valuei[name_of_feature.." scale"].mod = 1
	settings:add_setting({
		setting_name = name_of_feature.." scale", 
		setting = scale
	})

	settings.valuei[name_of_feature.." A"] = menu.add_feature(lang["Opacity"], "action_slider", parent.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in RGB opacity"])
	end)
	settings.valuei[name_of_feature.." A"].min = 0
	settings.valuei[name_of_feature.." A"].max = 255
	settings.valuei[name_of_feature.." A"].mod = 5
	settings:add_setting({
		setting_name = name_of_feature.." A", 
		setting = 255
	})
end

do
	local blacklisted_strings <const> = essentials.const({
		"stack traceback",
		"LUA state has been reset",
		"\\",
		"] [Kek's ",
		"] Saved ",
		"[Spoofer]",
		"Error executing",
		"has been executed.",
		"Failed to load",
		"Kek's menu is already loaded!",
		"[C]",
		"MoistScript",
		"2Take1Script",
		"2T1Script Revive",
		"ZeroMenu",
		"[Spectating You]",
		"tried to report you",
		"SCID: ",
		"Triggered",
		"Toggled"
	})
	local whitelisted_strings <const> = {
		lang["is in godmode."],
		lang["Recognized"],
		lang["has a modded name."],
		lang[", flags:\n"],
		lang["Kicking "],
		"] Chat judge:",
		"Reason: "
	}
	local i = 0
	repeat
		whitelisted_strings[#whitelisted_strings + 1] = player.get_modder_flag_text(1 << i)
		i = i + 1
	until 1 << i == player.get_modder_flag_ends()
	local filter <const> = function(...)
		local str <const>, feat <const> = ...
		if feat.value == 1 then
			for i = 1, #whitelisted_strings do
				if str:find(whitelisted_strings[i], 1, true) then
					return false
				end
			end
			if not str:find("^%[202%d%-%d%d%-%d%d") and not str:find(":", 1, true) then
				return true
			end
			for i = 1, #blacklisted_strings do
				if str:find(blacklisted_strings[i], 1, true) then
					return true
				end
			end
		else
			return false
		end
	end

	u.display_notifications = menu.add_feature(lang["Display notifications"], "parent", u.self_options.id)
	settings.toggle["Display 2take1 notifications"] = menu.add_feature(lang["Display 2take1 notifications"], "value_str", u.display_notifications.id, function(f)
		if not utils.file_exists(paths.home.."notification.log") then
			essentials.create_empty_file(paths.home.."notification.log")
		end
		if utils.time_ms() > essentials.init_delay and not essentials.get_file_string(paths.home.."2Take1Menu.ini"):find("uiNotifyLog=1", 1, true) then
			essentials.msg(lang["\"Log to file\" must be toggled on in 2take1 notification settings in order for this to work."], "red", true, 10)
		end
		local file <const>, strings = io.open(paths.home.."notification.log", "rb")
		local keks_menu_str <const> = " (%["..lang["Kek's menu"]..") %d%.%d%.%d%.%d+%]"
		local value
		while f.on do
			if f.value ~= value then
				local end_pos <const> = file:seek("end")
				local pos = 0
				strings = {}
				repeat
					pos = math.min(end_pos, pos + 1000000)
					file:seek("end", -pos)
					for line in file:lines("*l") do
						if not filter(line, f) then
							line = line:gsub(keks_menu_str, " %1]")
							if line:find("~", 1, true) then
								line = line:gsub("~", "\\~")
							end
							strings[#strings + 1] = line
						end
					end
				until #strings >= settings.valuei["Number of notifications to display"].max or pos == end_pos
				strings = table.move(strings, math.max(#strings - settings.valuei["Number of notifications to display"].max + 1, 1), #strings, 1, {})
				value = f.value
			end
			local str <const> = file:read("*l")
			if str and str:find("[%w%p]") and not filter(str, f) then
				if #strings >= settings.valuei["Number of notifications to display"].max then
					table.remove(strings, 1)
				end
				strings[#strings + 1] = str
			end
			local i = 0
			for i2 = math.max(1, #strings - settings.valuei["Number of notifications to display"].value + 1), #strings do
				ui.set_text_color(settings.valuei["Display 2take1 notifications R"].value, settings.valuei["Display 2take1 notifications G"].value, settings.valuei["Display 2take1 notifications B"].value, settings.valuei["Display 2take1 notifications A"].value)
				ui.set_text_scale(settings.valuei["Display 2take1 notifications scale"].value / 30)
				ui.set_text_font(settings.valuei["Display 2take1 notifications font"].value)
				ui.set_text_outline(settings.toggle["Display 2take1 notifications outline"].on)
				ui.draw_text(strings[i2], memoize.v2(settings.valuei["Display 2take1 notifications X"].value / 2000, (settings.valuei["Display 2take1 notifications Y"].value + (i * settings.valuef["Display 2take1 notifications stretch"].value)) / 2000))
				i = i + 1
			end
			system.yield(0)
		end
		file:close()
	end)
	settings.valuei["Display 2take1 notifications filter"] = settings.toggle["Display 2take1 notifications"]
	settings.toggle["Display 2take1 notifications"]:set_str_data({
		lang["No filter"],
		lang["Filter"]
	})

	settings.valuei["Number of notifications to display"] = menu.add_feature(lang["Number of notifications"], "action_value_i", u.display_notifications.id)
	settings.valuei["Number of notifications to display"].max = 100
	settings.valuei["Number of notifications to display"].min = 1
	settings.valuei["Number of notifications to display"].mod = 1

	settings.toggle["Log 2take1 notifications to console"] = menu.add_feature(lang["Log to console"], "value_str", u.display_notifications.id, function(f)
		if utils.time_ms() > essentials.init_delay and not essentials.get_file_string(paths.home.."2Take1Menu.ini"):find("uiNotifyLog=1", 1, true) then
			essentials.msg(lang["\"Log to file\" must be toggled on in 2take1 notification settings in order for this to work."], "red", true, 10)
		end
		local file <close> = io.open(paths.home.."notification.log", "rb")
		file:seek("end")
		while f.on do
			local str <const> = file:read("*l")
			if str and not filter(str, f) then
				print(str)
			end
			system.yield(0)
		end
	end)
	settings.valuei["Log 2take1 notifications to console filter"] = settings.toggle["Log 2take1 notifications to console"]
	settings.toggle["Log 2take1 notifications to console"]:set_str_data({
		lang["No filter"],
		lang["Filter"]
	})
end

display_settings(u.display_notifications, "Display 2take1 notifications", 1560, 40, 9, 25, true)

u.display_time = menu.add_feature(lang["Display time"], "parent", u.self_options.id)
settings.toggle["Time OSD"] = menu.add_feature(lang["Display time"], "toggle", u.display_time.id, function(f)
	while f.on do
		ui.set_text_color(settings.valuei["Time OSD R"].value, settings.valuei["Time OSD G"].value, settings.valuei["Time OSD B"].value, settings.valuei["Time OSD A"].value)
		ui.set_text_scale(settings.valuei["Time OSD scale"].value / 30)
		ui.set_text_font(settings.valuei["Time OSD font"].value)
		ui.set_text_outline(settings.toggle["Time OSD outline"].on)
		ui.draw_text(os.date(), memoize.v2(settings.valuei["Time OSD X"].value / 2000, settings.valuei["Time OSD Y"].value / 2000))
		system.yield(0)
	end
end)
display_settings(u.display_time, "Time OSD", 0, 0, 15, 50)

u.force_field = menu.add_feature(lang["Force field"], "parent", u.self_options.id)

menu.add_feature(lang["Force field"], "value_str", u.force_field.id, function(f)
	if f.on then
		local pos = memoize.v3()
		menu.create_thread(function()
			while f.on do
				if settings.toggle["Force field sphere"].on then
					graphics.draw_marker(28, pos, memoize.v3(0, 90, 0), memoize.v3(0, 90, 0), memoize.v3(u.force_field_radius.value, u.force_field_radius.value, u.force_field_radius.value), 0, 255, 0, 35, false, false, 2, false, nil, "MarkerTypeDebugSphere", false)
				end
				system.yield(0)
			end
		end, nil)
		local buf <const> = {}
		while f.on do
			system.yield(0)
			buf[1] = nil
			buf[2] = nil
			if u.force_field_entity_type.value == 0 or u.force_field_entity_type.value == 2 then
				buf[1] = memoize.get_all_vehicles()
			end
			if u.force_field_entity_type.value == 1 or u.force_field_entity_type.value == 2 then
				buf[2] = memoize.get_all_peds()
			end
			local my_ped = player.get_player_ped(player.player_id())
			local my_vehicle <const> = player.get_player_vehicle(player.player_id())
			pos = essentials.get_player_coords(player.player_id()) + memoize.v3(u.force_field_offset_x.value, u.force_field_offset_y.value, u.force_field_offset_z.value)
			for i, entities in pairs(buf) do
				for Entity in essentials.entities(entities) do
					if my_vehicle ~= Entity then
						local is_player_in_vehicle, is_friend_in_vehicle
						if i == 1 then
							is_player_in_vehicle, is_friend_in_vehicle = kek_entity.is_player_in_vehicle(Entity)
						end
						if (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity))
						and (u.exclude_from_force_field.value == 2 
							or (u.exclude_from_force_field.value == 0 and not is_friend_in_vehicle)
							or (u.exclude_from_force_field.value == 1 and not is_player_in_vehicle)
						) then
							local coords <const> = memoize.get_entity_coords(Entity)
							local distance <const> = memoize.get_distance_between(pos, Entity, my_ped, nil, 3)
							if distance < u.force_field_radius.value and kek_entity.get_control_of_entity(Entity, 0) then
								if essentials.is_str(f, "Away from you") then
									entity.set_entity_velocity(Entity, (coords - pos) * (u.strength_away.value / distance))
								elseif essentials.is_str(f, "Towards you") then
									if distance > 20 then
										entity.set_entity_velocity(Entity, (pos - coords) * (u.strength_towards.value / distance))
									else
										entity.set_entity_velocity(Entity, (coords - pos) * (u.strength_towards.value / distance))
									end
								end
							end
						end
					end
				end
			end
		end
	end
end):set_str_data({
	lang["Away from you"],
	lang["Towards you"]
})

settings.toggle["Force field sphere"] = menu.add_feature(lang["Show sphere"], "toggle", u.force_field.id)

u.force_field_radius = menu.add_feature(lang["Force field radius"], "action_slider", u.force_field.id)
u.force_field_radius.max = 225
u.force_field_radius.min = 7.5
u.force_field_radius.mod = 7.5
u.force_field_radius.value = 22.5

u.strength_towards = menu.add_feature(lang["Strength towards you"], "action_slider", u.force_field.id)
u.strength_towards.max = 100
u.strength_towards.min = 2.5
u.strength_towards.mod = 2.5
u.strength_towards.value = 10

u.strength_away = menu.add_feature(lang["Strength away from you"], "action_slider", u.force_field.id)
u.strength_away.max = 100
u.strength_away.min = 2.5
u.strength_away.mod = 2.5
u.strength_away.value = 10

u.exclude_from_force_field = menu.add_feature(lang["Exclude"], "action_value_str", u.force_field.id)
u.exclude_from_force_field:set_str_data({
	lang["friends"],
	lang["players"],
	lang["no one"]
})

u.force_field_entity_type = menu.add_feature(lang["Entities"], "action_value_str", u.force_field.id)
u.force_field_entity_type:set_str_data({
	lang["Vehicles"], 
	lang["Peds"], 
	lang["Peds & vehicles"]
})

u.force_field_offset_x = menu.add_feature(lang["Offset"].." x", "action_value_i", u.force_field.id)
u.force_field_offset_x.max = 100
u.force_field_offset_x.min = -100
u.force_field_offset_x.mod = 2
u.force_field_offset_x.value = 0

u.force_field_offset_y = menu.add_feature(lang["Offset"].." y", "action_value_i", u.force_field.id)
u.force_field_offset_y.max = 100
u.force_field_offset_y.min = -100
u.force_field_offset_y.mod = 2
u.force_field_offset_y.value = 0

u.force_field_offset_z = menu.add_feature(lang["Offset"].." z", "action_value_i", u.force_field.id)
u.force_field_offset_z.max = 100
u.force_field_offset_z.min = -100
u.force_field_offset_z.mod = 2
u.force_field_offset_z.value = 0

do
	local custom_maps_parent <const> = menu.add_feature(lang["Menyoo maps"], "parent", u.self_options.id)
	local race_ghost_parent <const> = menu.add_feature(lang["Race ghosts"], "parent", u.self_options.id)

	local ghost_feat_callback <const> = function(f)
		if essentials.is_str(f, "Load") then
			if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..f.name..".lua") then
				local properties = loadfile(paths.home.."scripts\\Race ghosts\\"..f.name..".lua")
				local hash
				if not pcall(function()
					hash, properties = properties()
				end) or not streaming.is_model_valid(math.tointeger(hash) or 0) or type(properties) ~= "table" or #properties < 5 then
					essentials.msg(lang["Failed to load file."], "red", true)
					return
				end
				local Vehicle <const> = kek_entity.spawn_local_mission_vehicle(math.tointeger(hash), function()
					return properties[1].pos, 0 
				end)
				f.data.vehicle = Vehicle
				f.data.number_of_laps[Vehicle] = 0
				entity.set_entity_alpha(Vehicle, 180, true)
				entity.set_entity_collision(Vehicle, false, true, true)
				f.data.number_of_racers = f.data.number_of_racers + 1
				f.data.id[Vehicle] = f.data.number_of_racers
				kek_entity.set_blip(Vehicle, 56, math.min(f.data.number_of_racers, 84))
				f.data.threads[Vehicle] = menu.create_thread(function()
					while f.data.status ~= "STOP" do
						system.yield(0)
						local i = 2
						if f.data.number_of_laps[Vehicle] > 0 and #properties > 1000 then
							for i2 = 2, #properties do
								if properties[i2].time > 2 then
									i = i2
									break
								end
							end
						end
						local time = properties[i].time
						while #properties >= i do
							if not properties[i] then
								break
							end
							while time > properties[i].time do
								i = i + 1
								if not properties[i] then
									goto exit
								end
							end
							local new_pos = v3(properties[i - 1].pos.x, properties[i - 1].pos.y, properties[i - 1].pos.z)
							if essentials.round((properties[i].time - time) / gameplay.get_frame_time()) > 1 then
								while essentials.round((properties[i].time - time) / gameplay.get_frame_time()) > 1 do
									entity.set_entity_rotation(Vehicle, properties[i].rot)
									new_pos = new_pos + ((properties[i].pos - properties[i - 1].pos) / essentials.round((properties[i].time - time) / gameplay.get_frame_time()))
									entity.set_entity_coords_no_offset(Vehicle, new_pos)
									system.yield(0)
									time = time + gameplay.get_frame_time()
									if f.data.status == "STOP" or not entity.is_entity_a_vehicle(Vehicle) then
										goto complete_exit
									end
								end
							else
								entity.set_entity_rotation(Vehicle, properties[i].rot)
								entity.set_entity_coords_no_offset(Vehicle, properties[i].pos)
								system.yield(0)
								time = time + gameplay.get_frame_time()
							end
							i = i + 1
							if f.data.status == "STOP" or not entity.is_entity_a_vehicle(Vehicle) then
								goto complete_exit
							end
						end
						::exit::
						f.data.number_of_laps[Vehicle] = f.data.number_of_laps[Vehicle] + 1
						essentials.msg(string.format("[%s]: %s %s %s %s.", lang["Race ghosts"], f.name, f.data.id[Vehicle], lang["has finished lap"], f.data.number_of_laps[Vehicle]), "blue", true, 6)
					end
					::complete_exit::
					f.data.number_of_racers = f.data.number_of_racers - 1
					if f.data.number_of_racers == 0 then
						f.data.status = nil
					end
					f.data.number_of_laps[Vehicle] = nil
					f.data.id[Vehicle] = nil
					f.data.threads[Vehicle] = nil
					kek_entity.clear_entities({Vehicle})
				end, nil)
			end
		elseif essentials.is_str(f, "Unload") then
			f.data.status = "STOP"
		elseif essentials.is_str(f, "Teleport to start") then
			local properties = loadfile(paths.home.."scripts\\Race ghosts\\"..f.name..".lua")
			local hash
			if not pcall(function()
				hash, properties = properties()
			end) or not streaming.is_model_valid(math.tointeger(hash) or 0) or type(properties) ~= "table" then
				essentials.msg(lang["Failed to load file."], "red", true)
				return
			end
			kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), properties[1].pos)
			entity.set_entity_rotation(kek_entity.get_most_relevant_entity(player.player_id()), properties[1].rot)
		elseif essentials.is_str(f, "Set yourself in seat") then
			ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), f.data.vehicle, enums.vehicle_seats.driver)
		elseif essentials.is_str(f, "Delete") then
			f.data.status = "STOP"
			if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..f.name..".lua") then
				io.remove(paths.home.."scripts\\Race ghosts\\"..f.name..".lua")
			end
			f.hidden = true -- So that there is no delay between pressing delete and feature disappearing
			repeat
				system.yield(0)
				local count = 0
				for _, thread in pairs(f.data.threads) do -- Threads need access to f.data until they're finished. Deleting the feature removes that access.
					count = count + 1
				end
			until count == 0
			essentials.delete_feature(f.id)
		elseif essentials.is_str(f, "Change name") then
			local input, status = f.name
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of race ghost."], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
					goto skip
				end
				if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..input..".lua") then
					essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			essentials.rename_file(paths.home.."scripts\\Race ghosts\\", f.name, input, "lua")
			f.name = input
		end
	end

	local feat_str_data <const> = {
		lang["Load"],
		lang["Unload"],
		lang["Teleport to start"],
		lang["Set yourself in seat"],
		lang["Delete"],
		lang["Change name"]
	}

	local function create_ghost_racer_feature(...)
		local name <const> = ...
		local safe_feat_name = essentials.get_safe_feat_name(name)
		if name:find("..", 1, true) or name:find(".", -1, true) or name ~= safe_feat_name then
			return
		end
		local feat <const> = menu.add_feature(safe_feat_name, "action_value_str", race_ghost_parent.id, ghost_feat_callback)
		feat:set_str_data(feat_str_data)
		feat.data = {
			number_of_racers = 0,
			vehicle = 0,
			number_of_laps = {},
			id = {},
			threads = {}
		}
	end

	local record_race <const> = menu.add_feature(lang["Record race"], "toggle", race_ghost_parent.id, function(f)
		if player.is_player_in_any_vehicle(player.player_id()) then
			if utils.file_exists(paths.kek_menu_stuff.."kekMenuData\\Temp recorded race.lua") then
				essentials.msg(lang["Cleared old race & recording a new one."], "green", true, 3)
			end
			local file <close> = io.open(paths.kek_menu_stuff.."kekMenuData\\Temp recorded race.lua", "w+")
			local time, str <const> = 0, {string.format("return %i, {", entity.get_entity_model_hash(player.get_player_vehicle(player.player_id())))}
			while f.on and player.is_player_in_any_vehicle(player.player_id()) do
				str[#str + 1] = string.format("\t{pos = %s, rot = %s, time = %f},", tostring(entity.get_entity_coords(player.get_player_vehicle(player.player_id()))), tostring(entity.get_entity_rotation(player.get_player_vehicle(player.player_id()))), time)
				system.yield(0)
				time = time + gameplay.get_frame_time()
			end
			f.on = false
			str[#str] = str[#str]:gsub(",$", "")
			str[#str + 1] = "}"
			str[#str + 1] = ""
			file:write(table.concat(str, "\n"))
			file:flush()
		else
			f.on = false
			essentials.msg(lang["You must be in a vehicle in order to record."], "red", true, 6)
		end
	end)

	menu.add_feature(lang["Save recorded race"], "action", race_ghost_parent.id, function(f)
		if record_race.on then
			record_race.on = false
			system.yield(500)
		end
		local input, status
		while true do
			input, status = keys_and_input.get_input(lang["Type in name of race ghost."], input, 128, 0)
			if status == 2 then
				return
			end
			if input:find("..", 1, true) or input:find("%.$") then
				essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
				goto skip
			end
			if utils.file_exists(paths.home.."scripts\\Race ghosts\\"..input..".lua") then
				essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
				goto skip
			end
			if input:find("[<>:\"/\\|%?%*]") then
				essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
			else
				break
			end
			::skip::
			system.yield(0)
		end
		local file <close> = io.open(paths.home.."scripts\\Race ghosts\\"..input..".lua", "w+")
		file:write(essentials.get_file_string(paths.kek_menu_stuff.."kekMenuData\\Temp recorded race.lua"))
		file:flush()
		create_ghost_racer_feature(input)
	end)

	local feat_name_map = {}
	local spawning_active = false
	local map_feat_callback <const> = function(f)
		if essentials.is_str(f, "Spawn") then
			if spawning_active then
				essentials.msg(lang["Wait until the previous map is done spawning."], "blue", true, 6)
				return
			end
			spawning_active = true
			menyoo.spawn_xml_map(paths.menyoo_maps.."\\"..f.name..".xml", true)
			spawning_active = false
		elseif essentials.is_str(f, "Teleport to map spawn") then
			local info <const> = essentials.parse_xml(essentials.get_file_string(paths.menyoo_maps.."\\"..f.name..".xml"))
			if info.SpoonerPlacements and info.SpoonerPlacements.ReferenceCoords then
				kek_entity.teleport(
					kek_entity.get_most_relevant_entity(player.player_id()), 
					v3(
						info.SpoonerPlacements.ReferenceCoords.X, 
						info.SpoonerPlacements.ReferenceCoords.Y, 
						info.SpoonerPlacements.ReferenceCoords.Z
					)
				)
			elseif info.Map and info.Map.Objects.MapObject then -- This type has no reference coords
				local t = info.Map.Objects.MapObject
				t = t.__is_table and t[1] or t
				local pos <const> = info.Map.Objects.ReferenceCoords or t.Position
				kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), v3(pos.X, pos.Y, pos.Z))
			else
				essentials.msg(lang["Failed to load spawn coordinates."], "red", true, 6)
			end
		elseif essentials.is_str(f, "Set where you spawn") then
			if utils.file_exists(paths.menyoo_maps.."\\"..f.name..".xml") then
				local pos <const> = essentials.get_player_coords(player.player_id())
				local file_path <const> = paths.menyoo_maps.."\\"..f.name..".xml"
				local str, new_str = essentials.get_file_string(file_path)
				str = str:gsub("\r\n", "\n")
				essentials.assert(str ~= "", "Tried to replace menyoo map with an empty string.")
				local where_does_ref_coords_end
				local replacement <const> = 
					"\n\t<ReferenceCoords>\n"
					.. "\t\t<X>"..pos.x.."</X>\n"
					.. "\t\t<Y>"..pos.y.."</Y>\n"
					.. "\t\t<Z>"..pos.z.."</Z>\n"
					.. "\t</ReferenceCoords>\n"

				if str:find("</ReferenceCoords>", 1, true) then
					new_str = str:gsub(
						"%s*<ReferenceCoords>[\n\r]+"
						.. "%s*<X>[%d.-]+</X>[\n\r]+"
						.. "%s*<Y>[%d.-]+</Y>[\n\r]+"
						.. "%s*<Z>[%d.-]+</Z>[\n\r]+"
						.."%s*</ReferenceCoords>[\n\r]+",
						replacement
					)
					where_does_ref_coords_end = select(2, str:find("</ReferenceCoords>", 1, true))
				elseif not str:find("<Quaternion>", 1, true) then
					new_str = str:gsub(
						"<SpoonerPlacements>[\r\n]+",
						"<SpoonerPlacements>"..replacement
					)
					where_does_ref_coords_end = select(2, str:find("<SpoonerPlacements>", 1, true)) + #("<SpoonerPlacements>"..replacement)
				elseif str:find("<Objects>", 1, true) then
					new_str = str:gsub(
						"<Objects>[\r\n]+",
						"<Objects>"..replacement
					)
					where_does_ref_coords_end = select(2, str:find("<Objects>", 1, true)) + #("<Objects>"..replacement)
				else
					essentials.msg(lang["Failed to set coordinates."], "red", true, 6)
					return
				end
				
				essentials.assert(str:find(new_str:sub(where_does_ref_coords_end + 20, -1), 1, true), "Failed to set coords. Something went wrong and would've corrupted the file.")
				local file <close> = io.open(file_path, "w+")
				file:write(new_str)
				file:flush()
			end
		elseif essentials.is_str(f, "Delete") then
			if utils.file_exists(paths.menyoo_maps.."\\"..f.name..".xml") then
				io.remove(paths.menyoo_maps.."\\"..f.name..".xml")
			end
			feat_name_map[f.name..".xml"] = nil
			essentials.delete_feature(f.id)
		elseif essentials.is_str(f, "Change name") then
			local input, status = f.name
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo map."], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
					goto skip
				end
				if utils.file_exists(paths.menyoo_maps.."\\"..input..".xml") then
					essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			essentials.rename_file(paths.menyoo_maps.."\\", f.name, input, "xml")
			feat_name_map[f.name..".xml"] = nil
			f.name = input
			feat_name_map[f.name..".xml"] = true
		end
	end

	local feat_str_data <const> = {
		lang["Spawn"],
		lang["Teleport to map spawn"],
		lang["Set where you spawn"],
		lang["Delete"],
		lang["Change name"]
	}

	local function create_custom_map_feature(...)
		local name <const> = ...
		local safe_feat_name <const> = essentials.get_safe_feat_name(name)
		if name:find("..", 1, true) or name:find(".", -1, true) or name ~= safe_feat_name then
			return
		end
		local feat = menu.add_feature(safe_feat_name, "action_value_str", custom_maps_parent.id, map_feat_callback)
		feat.data = "MENYOO"
		feat:set_str_data(feat_str_data)
		feat_name_map[feat.name..".xml"] = true
	end

	local main_feat <const> = menu.add_feature(lang["Menyoo maps"], "action_value_str", custom_maps_parent.id, function(f)
		if essentials.is_str(f, "Search") then
			local input, status <const> = keys_and_input.get_input(lang["Type in name of menyoo map."], "", 128, 0)
			if status == 2 then
				return
			end
			input = essentials.make_string_case_insensitive(essentials.remove_special(input))
			local children <const> = custom_maps_parent.children
			for i = 1, #children do
				children[i].hidden = children[i].data == "MENYOO" and not children[i].name:find(input)
			end
		elseif essentials.is_str(f, "Save") or essentials.is_str(f, "Save only mission entities") then
			local input, status
			while true do
				input, status = keys_and_input.get_input(lang["Type in name of menyoo map."], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
					goto skip
				end
				if utils.file_exists(paths.menyoo_maps.."\\"..input..".xml") then
					essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
					goto skip
				end
				if input:find("[<>:\"/\\|%?%*]") then
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
				else
					break
				end
				::skip::
				system.yield(0)
			end
			menyoo_saver.save_map(paths.menyoo_maps.."\\"..input..".xml", essentials.is_str(f, "Save only mission entities"))
			create_custom_map_feature(input)
		elseif essentials.is_str(f, "Refresh list") then
			local children <const> = custom_maps_parent.children
			for i = 1, #children do -- 3x faster to delete all then reconstruct than using utils.file_exists
				local feat <const> = children[i]
				if feat.data == "MENYOO" then
					essentials.delete_feature(feat.id)
				end
			end
			local files <const> = utils.get_all_files_in_directory(paths.menyoo_maps, "xml")
			feat_name_map = {}
			for i = 1, #files do
				create_custom_map_feature(files[i]:sub(1, -5))
			end
		end
	end)
	main_feat:set_str_data({
		lang["Search"],
		lang["Save only mission entities"],
		lang["Save"],
		lang["Refresh list"]
	})
	main_feat.data = "MAIN_FEAT"

	menu.add_feature(lang["Clear all owned entities"], "action", custom_maps_parent.id, function()
		u.clear_owned_entities.on = true
	end).data = "CLEAR_ENTITIES_FEAT"

	settings.toggle["Clear before spawning xml map"] = menu.add_feature(lang["Clear owned entities before spawning map"], "toggle", custom_maps_parent.id)

	local files <const> = utils.get_all_files_in_directory(paths.menyoo_maps, "xml")
	for i = 1, #files do
		create_custom_map_feature(files[i]:sub(1, -5))
	end

	local files <const> = utils.get_all_files_in_directory(paths.home.."scripts\\Race ghosts", "lua")
	for i = 1, #files do
		create_ghost_racer_feature(files[i]:sub(1, -5))
	end
end

settings.user_entity_features.ped.player_feats["Spawn ped"] = menu.add_player_feature(lang["Spawn a ped"], "action_value_str", u.player_misc_features, function(f, pid)
	local hash <const> = ped_mapper.get_hash_from_user_input(settings.in_use["User ped"])
	if streaming.is_model_a_ped(hash) then
		kek_entity.spawn_networked_ped(hash, function() 
			return location_mapper.get_most_accurate_position_soft(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), 7)), 0
		end)
	end
end).id

settings.user_entity_features.ped.player_feats["Change ped"] = menu.add_player_feature(lang["Set ped in use"], "action_value_str", u.player_misc_features, function()
	settings.user_entity_features.ped.feats["Change user ped setting"].on = true
end).id

u.max_self_vehicle_loop = menu.add_feature(lang["Max car"], "slider", u.gvehicle.id, function(f)
	while f.on do
		kek_entity.max_car(player.get_player_vehicle(player.player_id()), false, true)
		system.yield(math.floor(1000 - f.value))
	end
end)
u.max_self_vehicle_loop.max = 975
u.max_self_vehicle_loop.min = 25
u.max_self_vehicle_loop.mod = 25
u.max_self_vehicle_loop.value = 500

menu.add_feature(lang["Max vehicle"], "action", u.gvehicle.id, function(f)
	kek_entity.max_car(player.get_player_vehicle(player.player_id()), false, true)
end)

menu.add_feature(lang["Change backplate text"], "action", u.vehicleSettings.id, function(f)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in the text you want displayed on the backplate of your cars after maxing them."], "", 128, 0)
	if status == 2 then
		return
	end
	settings.in_use["Plate vehicle text"] = input
end)

settings.user_entity_features.vehicle.feats["Change vehicle"] = menu.add_feature(lang["Set vehicle in use"], "action_value_str", u.gvehicle.id, function()
	settings.user_entity_features.vehicle.feats["Change user vehicle setting"].on = true
end)

settings.user_entity_features.vehicle.feats["Spawn vehicle"] = menu.add_feature(lang["Spawn vehicle"], "action_value_str", u.gvehicle.id, function()
	kek_entity.spawn_car()
end)

settings.valuei["Vehicle fly speed"] = menu.add_feature(lang["Vehicle fly speed, click to type"], "action_value_i", u.gvehicle.id, function(f)
	keys_and_input.input_number_for_feat(f, lang["Type in vehicle speed"])
end)
settings.valuei["Vehicle fly speed"].min, settings.valuei["Vehicle fly speed"].max, settings.valuei["Vehicle fly speed"].mod = 0, 45000, 10

u.vehicle_fly = menu.add_feature(lang["Vehicle fly"], "toggle", u.gvehicle.id, function(f)
	if f.on then
		local control_indexes <const> = essentials.const({
			[-3] = enums.inputs["A LEFT STICK"], 
			[-1] = enums.inputs["S LEFT STICK"], 
			[1] = enums.inputs["W LEFT STICK"], 
			[3] = enums.inputs["D LEFT STICK"], 
			[5] = enums.inputs["LEFT SHIFT A"], 
			[7] = enums.inputs["SPACEBAR X"]
		})
		local angles <const> = essentials.const({
			[-3] = 90,
			[3] = -90
		})
		local angle, rot = 0, memoize.v3()
		local direction_change_timer = 0
		local last_direction = 0
		local fly_entity = 0
		local thread = -1
		while f.on do
			system.yield(0)
			if menu.has_thread_finished(thread) and player.is_player_in_any_vehicle(player.player_id()) and not entity.is_entity_a_vehicle(fly_entity) then
				thread = menu.create_thread(function()
					fly_entity = kek_entity.spawn_local_mission_vehicle(gameplay.get_hash_key("bmx"), function() 
						return essentials.get_player_coords(player.player_id()), 0 
					end)
					entity.set_entity_max_speed(fly_entity, 45000)
					entity.set_entity_visible(fly_entity, false)
					entity.set_entity_collision(fly_entity, false, false, false)
				end, nil)
			end
			entity.set_entity_coords_no_offset(fly_entity, essentials.get_player_coords(player.player_id()))
			if player.is_player_in_any_vehicle(player.player_id()) then
				for i = -3, 7, 2 do
					while controls.is_disabled_control_pressed(0, control_indexes[i]) and f.on and player.is_player_in_any_vehicle(player.player_id()) do
						for i2 = -3, 7, 2 do
							if utils.time_ms() > direction_change_timer 
							and last_direction ~= i2 
							and i2 ~= i 
							and controls.is_disabled_control_pressed(0, control_indexes[i2]) then
								direction_change_timer = utils.time_ms() + 150
								last_direction = i
								i = i2
								angle = 0
								rot = memoize.v3()
								break
							end
							if last_direction ~= 0 and not controls.is_disabled_control_pressed(0, control_indexes[last_direction]) then
								last_direction = 0
							end
						end
						entity.set_entity_max_speed(player.get_player_vehicle(player.player_id()), 45000)
						if i == 5 then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(0, 0, -settings.valuei["Vehicle fly speed"].value))
						elseif i == 7 then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), v3(0, 0, settings.valuei["Vehicle fly speed"].value))
						elseif math.abs(i) == 1 then
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
							vehicle.set_vehicle_forward_speed(player.get_player_vehicle(player.player_id()), settings.valuei["Vehicle fly speed"].value * i / math.abs(i))
							entity.set_entity_coords_no_offset(fly_entity, essentials.get_player_coords(player.player_id()))
						else
							if angle == 0 or rot == memoize.v3() then
								angle = kek_entity.get_rotated_heading(player.get_player_vehicle(player.player_id()), angles[i], player.player_id())
								rot = cam.get_gameplay_cam_rot()
							end
							entity.set_entity_rotation(fly_entity, v3(0, 0, angle), player.player_id())
							entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), rot)
							vehicle.set_vehicle_forward_speed(fly_entity, settings.valuei["Vehicle fly speed"].value * 0.75)
							entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), entity.get_entity_velocity(fly_entity))
						end
						system.yield(0)
						kek_entity.get_control_of_entity(entity.get_entity_entity_has_collided_with(player.get_player_vehicle(player.player_id())), 0, true)
					end
					angle = 0
				end
				if f.on then
					entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), memoize.v3())
					entity.set_entity_rotation(player.get_player_vehicle(player.player_id()), cam.get_gameplay_cam_rot())
				end
			end
		end
		local velocity <const> = entity.get_entity_velocity(player.get_player_vehicle(player.player_id()))
		entity.freeze_entity(player.get_player_vehicle(player.player_id()), true)
		entity.freeze_entity(player.get_player_vehicle(player.player_id()), false)
		rope.activate_physics(player.get_player_vehicle(player.player_id()))
		entity.set_entity_velocity(player.get_player_vehicle(player.player_id()), velocity)
		kek_entity.clear_entities({fly_entity})
	end
end)

player_feat_ids["player otr"] = menu.add_player_feature(lang["Off the radar"], "toggle", u.player_peaceful, function(f, pid)
	while f.on do
		if globals.get_player_global("otr_status", pid) ~= 1 then
			globals.send_script_event("Give OTR or ghost organization", pid, {pid, utils.time() - 60, utils.time(), 1, 1, globals.get_player_global("generic", pid)})
			system.yield(1000)
		end
		system.yield(0)
	end
end).id

player_feat_ids["Never wanted"] = menu.add_player_feature(lang["Never wanted"], "toggle", u.player_peaceful, function(f, pid)
	while f.on do
		if player.is_player_valid(pid) and player.get_player_wanted_level(pid) > 0 then
			globals.send_script_event("Generic event", pid, {pid, globals.GENERIC_ARG_HASHES.clear_wanted})
			system.yield(1000)
		end
		system.yield(0)
	end
end).id

player_feat_ids["30k ceo"] = menu.add_player_feature(lang["30k ceo loop"], "toggle", u.player_peaceful, function(f, pid)
	if u.send_30k_to_session.on then
		essentials.msg(lang["The 30k loop for session is already toggled on."], "red", true, 6)
		f.on = false
		return
	end
	if globals.get_player_global("organization_associate_hash", pid) == -1 then
		essentials.msg(lang["The player must be an associate of an organization to use this. They can't be the ceo."], "red", true, 6)
		f.on = false
		return
	end
	menu.create_thread(function()
		while f.on do
			globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 0, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous")})
			essentials.wait_conditional(20000, function() 
				return f.on and globals.get_player_global("organization_associate_hash", pid) ~= -1
			end)
			if f.on then
				globals.send_script_event("CEO money", pid, {pid, 10000, -1292453789, 1, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous")})
			end
			essentials.wait_conditional(20000, function() 
				return f.on and globals.get_player_global("organization_associate_hash", pid) ~= -1
			end)
		end
	end, nil)
	while f.on and globals.get_player_global("organization_associate_hash", pid) ~= -1 do
		globals.send_script_event("CEO money", pid, {pid, 30000, 198210293, 1, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous")})
		essentials.wait_conditional(120000, function() 
			return f.on and globals.get_player_global("organization_associate_hash", pid) ~= -1
		end)
	end
	f.on = false
end).id

menu.add_player_feature(lang["Set bounty"], "action_value_str", u.script_stuff, function(f, pid)
	if essentials.is_str(f, "Change amount") then
		local input <const>, status <const> = keys_and_input.get_input(lang["Type in bounty amount"], "", 5, 3)
		if status == 2 then
			return
		end
		settings.in_use["Bounty amount"] = input
	else
		if globals.get_player_global("bounty_status", pid) == 1 then
			essentials.msg(lang["This player already have a bounty set on them."], "red", true, 6)
			return
		end
		globals.set_bounty(pid, false, essentials.is_str(f, "Anonymous"))
	end
end):set_str_data({
	lang["Anonymous"],
	lang["With your name"],
	lang["Change amount"]
})

menu.add_player_feature(lang["Reapply bounty"], "value_str", u.script_stuff, function(f, pid)
	while f.on do
		globals.set_bounty(pid, false, essentials.is_str(f, "Anonymous"))
		local value <const> = f.value
		essentials.wait_conditional(10000, function() -- Spamming script events leads to inevitable crash. Setting one bounty sends up to 32 script events.
			return f.on and f.value == value
		end)
	end
end):set_str_data({
	lang["Anonymous"],
	lang["With your name"]
})


menu.add_player_feature(lang["Teleport to Perico island"], "action", u.script_stuff, function(f, pid)
	globals.send_script_event("Send to Perico island", pid, {pid, globals.get_script_event_hash("Send to Perico island"), 0, 0})
end)

menu.add_player_feature(lang["Apartment invites"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		globals.send_script_event("Apartment invite", pid, {pid, pid, 1, 0, math.random(1, 113), 1, 1, 1})
		system.yield(5000)
	end
end)

menu.add_player_feature(lang["Block passive mode"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		globals.send_script_event("Block passive", pid, {pid, 1})
		system.yield(1000)
	end
	globals.send_script_event("Block passive", pid, {pid, 0})
end)

menu.add_player_feature(lang["Notification spam"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		local rand_pid <const> = essentials.get_random_player_except({[player.player_id()] = true})
		globals.send_script_event("Notifications", pid, {
			pid, 
			globals.NOTIFICATION_HASHES_RAW[math.random(1, #globals.NOTIFICATION_HASHES_RAW)], 
			math.random(-2147483647, 2147483647),
			1, 0, 0, 0, 0, 0, pid, 
			player.player_id(), 
			rand_pid, 
			essentials.get_random_player_except({[player.player_id()] = true, [rand_pid] = true})
		})
		system.yield(500)
	end
end)

menu.add_player_feature(lang["Transaction error"], "toggle", u.script_stuff, function(f, pid)
	while f.on do
		globals.send_script_event("Transaction error", pid, {pid, 50000, 0, 1, globals.get_player_global("generic", pid), globals.get_global("current"), globals.get_global("previous"), 1})
		system.yield(500)
	end
end)

menu.add_player_feature(lang["Teleport to"], "action_value_str", u.player_vehicle_features, function(f, pid)
	if essentials.is_str(f, "waypoint") and not hud.is_waypoint_active() then
		essentials.msg(lang["Please set a waypoint."], "red", true)
		return
	end
	if not essentials.is_in_vehicle(pid) and pid ~= player.player_id() then
		essentials.msg(lang["Forcing player into vehicle. This can take up to 15 seconds."], "yellow", true, 6)
		globals.force_player_into_vehicle(pid)
	end
	if not essentials.is_in_vehicle(pid) and pid ~= player.player_id() then
		essentials.msg(lang["Failed to teleport player."], "red", true, 6)
		return
	end
	if essentials.is_str(f, "me") then
		if pid == player.player_id() then
			essentials.msg(lang["You can't use this on yourself."], "red", true, 6)
			return
		end
		kek_entity.teleport_player_and_vehicle_to_position(pid, location_mapper.get_most_accurate_position_soft(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8)), true)
	elseif essentials.is_str(f, "waypoint") then
		kek_entity.teleport_player_and_vehicle_to_position(pid, location_mapper.get_most_accurate_position(v3(ui.get_waypoint_coord().x, ui.get_waypoint_coord().y, -50)), false, f)
	elseif essentials.is_str(f, "Mount Chiliad & kill") then
		if kek_entity.teleport_player_and_vehicle_to_position(pid, memoize.v3(491.9401550293, 5587, 794.00347900391), true) then
			globals.disable_vehicle(pid)
			system.yield(1500)
			for i = 1, 20 do
				system.yield(0)
				essentials.use_ptfx_function(fire.add_explosion, essentials.get_player_coords(pid), enums.explosion_types.BLIMP, true, false, 0, player.get_player_ped(pid))
			end
		end
	elseif essentials.is_str(f, "far away") then
		kek_entity.teleport_player_and_vehicle_to_position(pid, v3(math.random(20000, 25000), math.random(-25000, -20000), math.random(-2400, 2400)), true)
	end
end):set_str_data({
	lang["me"],
	lang["waypoint"],
	lang["Mount Chiliad & kill"],
	lang["far away"]
})

do
	local feat <const> = menu.add_player_feature(lang["Vehicle"], "action_value_str", u.player_vehicle_features, function(f, pid)
		f.data = f.data and f.data.scid == player.get_player_scid(pid) and f.data or setmetatable({scid = player.get_player_scid(pid)}, {
			__index = function()
				return 0
			end
		})
		local initial_pos <const> = essentials.get_player_coords(player.player_id())
		local initial_heading <const> = player.get_player_heading(player.player_id())
		local status <const>, had_to_teleport <const> = kek_entity.check_player_vehicle_and_teleport_if_necessary(pid)
		local Vehicle <const> = player.get_player_vehicle(pid)
		if status or entity.is_entity_a_vehicle(Vehicle) then
			if essentials.is_str(f, "Repair") then
				if kek_entity.get_control_of_entity(Vehicle, nil, nil, true) then
					kek_entity.repair_car(Vehicle)
				end
			elseif essentials.is_str(f, "Max") then
				if kek_entity.get_control_of_entity(Vehicle, nil, nil, true) then
					kek_entity.max_car(Vehicle)
				end
			elseif essentials.is_str(f, "Toggle engine") then
				if kek_entity.get_control_of_entity(Vehicle, nil, nil, true) then
					if f.data[Vehicle] & 1 == 0 then
						f.data[Vehicle] = f.data[Vehicle] | 1
						vehicle.set_vehicle_engine_health(Vehicle, -4000)
						essentials.msg(lang["Killed their engine."], "red", true, 5)
					else
						f.data[Vehicle] = f.data[Vehicle] & (f.data[Vehicle] ~ 1)
						vehicle.set_vehicle_engine_health(Vehicle, 1000)
						if vehicle.get_vehicle_number_of_passengers(Vehicle) > 0 then
							vehicle.set_vehicle_engine_on(Vehicle, true, true, false)
						end
						essentials.msg(lang["Revived their engine."], "green", true, 5)
					end
				end
			elseif essentials.is_str(f, "Unlock / lock inside") then
				if kek_entity.get_control_of_entity(Vehicle, nil, nil, true) then
					if f.data[Vehicle] & 2 == 0 then
						f.data[Vehicle] = f.data[Vehicle] | 2
						vehicle.set_vehicle_doors_locked(Vehicle, enums.car_locks.LOCKED_PLAYER_INSIDE)
						vehicle.set_vehicle_doors_locked_for_player(player.get_player_vehicle(pid), pid, true)
						essentials.msg(lang["Locked their car."], "red", true, 5)
					else
						f.data[Vehicle] = f.data[Vehicle] & (f.data[Vehicle] ~ 2)
						vehicle.set_vehicle_doors_locked_for_player(player.get_player_vehicle(pid), pid, false)
						vehicle.set_vehicle_doors_locked(Vehicle, enums.car_locks.UNLOCKED)
						essentials.msg(lang["Unlocked their car."], "green", true, 5)
					end
				end
			elseif essentials.is_str(f, "Remove") then
				globals.send_script_event("Destroy personal vehicle", pid, {pid, pid})
				kek_entity.remove_player_vehicle(pid)
			elseif essentials.is_str(f, "Clone") then
				if player.player_count() == 0 then
					essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
					return
				end
				local veh_dims <const> = kek_entity.get_longest_dimension(entity.get_entity_model_hash(Vehicle))

				local my_vehicle <const> = player.get_player_vehicle(player.player_id())
				local my_veh_dims <const> = entity.is_entity_a_vehicle(my_vehicle) and kek_entity.get_longest_dimension(entity.get_entity_model_hash(my_vehicle)) or 0
				menyoo.clone_vehicle(
					Vehicle, 
					location_mapper.get_most_accurate_position_soft(kek_entity.get_vector_relative_to_pos(
						initial_pos, 
						veh_dims + my_veh_dims + 3, 
						initial_heading
					)),
					initial_heading
				)
			end
		end
		if had_to_teleport then
			kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
		end
	end).id
	menu.get_player_feature(feat):set_str_data({
		lang["Repair"],
		lang["Max"],
		lang["Toggle engine"],
		lang["Unlock / lock inside"],
		lang["Remove"],
		lang["Clone"]
	})
end

settings.user_entity_features.vehicle.player_feats["Spawn vehicle"] = menu.add_player_feature(lang["Spawn vehicle"], "action_value_str", u.player_vehicle_features, function(f, pid)
	local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
	if streaming.is_model_a_vehicle(hash) then
		if not kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			essentials.msg(lang["Failed to spawn vehicle. Vehicle limit was reached"], "red", true, 6)
			return
		end
		kek_entity.spawn_networked_vehicle(hash, function()
			return location_mapper.get_most_accurate_position(kek_entity.vehicle_get_vec_rel_to_dims(hash, player.get_player_ped(pid))), player.get_player_heading(pid)
		end, {
			godmode = settings.toggle["Spawn #vehicle# in godmode"].on, 
			max = settings.toggle["Spawn #vehicle# maxed"].on,
			persistent = false
		})
	end
end).id

settings.user_entity_features.vehicle.player_feats["Change vehicle player"] = menu.add_player_feature(lang["Set vehicle in use"], "action_value_str", u.player_vehicle_features, function()
	settings.user_entity_features.vehicle.feats["Change user vehicle setting"].on = true
end).id

u.spawn_vehicle_parent = menu.add_player_feature(lang["Spawn vehicle"], "parent", u.player_vehicle_features).id
kek_entity.generate_player_vehicle_list({
		type = "action"
	},
	u.spawn_vehicle_parent,
	function(f, pid)
		if not kek_entity.entity_manager:update().is_vehicle_limit_not_breached then
			essentials.msg(lang["Failed to spawn vehicle. Vehicle limit was reached"], "red", true, 6)
			return
		end
		kek_entity.spawn_networked_vehicle(f.data, function()
			return kek_entity.vehicle_get_vec_rel_to_dims(f.data, player.get_player_ped(pid)), player.get_player_heading(pid)
		end, {
			godmode = settings.toggle["Spawn #vehicle# in godmode"].on, 
			max = settings.toggle["Spawn #vehicle# maxed"].on,
			persistent = false
		})
	end,
	""
)

player_feat_ids["Player horn boost"] = menu.add_player_feature(lang["Horn boost"], "slider", u.player_peaceful, function(f, pid)
	while f.on do
		system.yield(0)
		if player.is_player_valid(pid) 
		and player.is_player_in_any_vehicle(pid) 
		and player.is_player_pressing_horn(pid) 
		and kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
			vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), math.min(150, entity.get_entity_speed(player.get_player_vehicle(pid)) + f.value))
			system.yield(550)
		end
	end
end).id
menu.get_player_feature(player_feat_ids["Player horn boost"]).max = 100
menu.get_player_feature(player_feat_ids["Player horn boost"]).min = 5
menu.get_player_feature(player_feat_ids["Player horn boost"]).mod = 5
menu.get_player_feature(player_feat_ids["Player horn boost"]).value = 25

do
	local feat = menu.add_player_feature(lang["Flamethrower"], "action_value_str", u.player_peaceful, function(f, pid)
		local initial_pos <const> = essentials.get_player_coords(player.player_id())
		local status <const>, had_to_teleport <const> = kek_entity.check_player_vehicle_and_teleport_if_necessary(pid)
		if status then
			if essentials.is_str(f, "Give") then
				if not f.data.ptfx_in_use[player.get_player_vehicle(pid)] and kek_entity.get_control_of_entity(player.get_player_vehicle(pid), nil, nil, true) and essentials.request_ptfx("weap_xs_vehicle_weapons") then
					f.data.ptfx_in_use[player.get_player_vehicle(pid)] = essentials.use_ptfx_function(graphics.start_networked_ptfx_looped_on_entity, f.data.ptfx_names[math.random(1, #f.data.ptfx_names)], player.get_player_vehicle(pid), memoize.v3(0, 3, 0), memoize.v3(), essentials.random_real(1, 3))
					table.remove(essentials.ptfx_in_use, #essentials.ptfx_in_use)
					essentials.ptfx_in_use[#essentials.ptfx_in_use + 1] = utils.time_ms() + 60000
				end
			elseif essentials.is_str(f, "Remove") and f.data.ptfx_in_use[player.get_player_vehicle(pid)] and kek_entity.get_control_of_entity(player.get_player_vehicle(pid), nil, nil, true) then
				graphics.remove_particle_fx(f.data.ptfx_in_use[player.get_player_vehicle(pid)], false)
				f.data.ptfx_in_use[player.get_player_vehicle(pid)] = nil
			end
		end
		if had_to_teleport then
			kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
		end
	end)
	for pid = 0, 31 do
		feat.feats[pid].data = essentials.const({
			ptfx_in_use = {},
			ptfx_names = essentials.const({
				"muz_xs_turret_flamethrower_looping_sf",
				"muz_xs_turret_flamethrower_looping"
			})
		})
	end
	feat:set_str_data({
		lang["Give"],
		lang["Remove"]
	})
end

player_feat_ids["Drive force multiplier"] = menu.add_player_feature(lang["Drive force multiplier"], "action_value_f", u.player_vehicle_features, function(f, pid)
	local initial_pos <const> = essentials.get_player_coords(player.player_id())
	local status <const>, had_to_teleport <const> = kek_entity.check_player_vehicle_and_teleport_if_necessary(pid)
	if status and kek_entity.get_control_of_entity(player.get_player_vehicle(pid), nil, nil, true) then
		entity.set_entity_max_speed(player.get_player_vehicle(pid), 45000)
		vehicle.modify_vehicle_top_speed(player.get_player_vehicle(pid), (f.value - 1) * 100)
	end
	if had_to_teleport then
		kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
	end
end).id
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).max = 20.0
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).min = -4.0
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).mod = 0.1
menu.get_player_feature(player_feat_ids["Drive force multiplier"]).value = 1.0

menu.add_player_feature(lang["Car godmode"], "value_str", u.player_vehicle_features, function(f, pid)
	while f.on do
		system.yield(0)
		kek_entity.modify_entity_godmode(player.get_player_vehicle(pid), essentials.is_str(f, "Give"))
	end
end):set_str_data({
	lang["Give"],
	lang["Remove"]
})

menu.add_player_feature(lang["Vehicle can't be locked on"], "action_value_str", u.player_peaceful, function(f, pid)
	local initial_pos <const> = essentials.get_player_coords(player.player_id())
	local status <const>, had_to_teleport <const> = kek_entity.check_player_vehicle_and_teleport_if_necessary(pid)
	if status and kek_entity.get_control_of_entity(player.get_player_vehicle(pid), nil, nil, true) then
		vehicle.set_vehicle_can_be_locked_on(player.get_player_vehicle(pid), essentials.is_str(f, "Remove"), true)
	end
	if had_to_teleport then
		kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
	end
end):set_str_data({
	lang["Give"],
	lang["Remove"]
})

settings.user_entity_features.vehicle.player_feats["Respawn vehicle"] = menu.add_player_feature(lang["Respawn vehicle after death"], "value_str", u.player_peaceful, function(f, pid)
	local state = false
	while f.on do
		system.yield(0)
		state = state or entity.is_entity_dead(player.get_player_ped(pid))
		if state and player.get_player_coords(pid).z > -10 and not entity.is_entity_dead(player.get_player_ped(pid)) then
			state = false
			kek_entity.clear_entities({f.data})
			local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
			f.data = kek_entity.spawn_networked_vehicle(hash, function()
				return kek_entity.vehicle_get_vec_rel_to_dims(hash, player.get_player_ped(pid)), player.get_player_heading(pid)
			end, {
				godmode = settings.toggle["Spawn #vehicle# in godmode"].on, 
				max = settings.toggle["Spawn #vehicle# maxed"].on,
				persistent = false
			})
		end
	end
end).id

menu.add_player_feature(lang["Vehicle fly player"], "toggle", u.player_vehicle_features, function(f, pid)
	while f.on do
		system.yield(0)
		local control_indexes <const> = essentials.const({
			32, 
			33
		})
		entity.set_entity_max_speed(player.get_player_vehicle(pid), 45000)
		for i = 1, 2 do
			while controls.is_disabled_control_pressed(0, control_indexes[i]) do
				local speed <const> = essentials.const({
					settings.valuei["Vehicle fly speed"].value, 
					-settings.valuei["Vehicle fly speed"].value
				})
				if kek_entity.get_control_of_entity(player.get_player_vehicle(pid), 0) then
					entity.set_entity_max_speed(player.get_player_vehicle(pid), 45000)
					kek_entity.get_control_of_entity(entity.get_entity_entity_has_collided_with(player.get_player_vehicle(pid)), 0)
					entity.set_entity_rotation(player.get_player_vehicle(pid), cam.get_gameplay_cam_rot())
					vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), speed[i])
				end
				system.yield(0)
				if not f.on then
					break
				end
			end
		end
		if f.on then
			entity.set_entity_velocity(player.get_player_vehicle(pid), memoize.v3())
			entity.set_entity_rotation(player.get_player_vehicle(pid), cam.get_gameplay_cam_rot())
		end
	end
end)

settings.user_entity_features.vehicle.player_feats["Ram player"] = menu.add_player_feature(lang["Ram player with vehicle"], "value_str", u.player_trolling_features, function(f, pid)
	if player.player_count() == 0 then
		f.on = false
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		return
	end
	local hash, vehicle_name
	while f.on and player.player_count() > 0 do
		if vehicle_name ~= settings.in_use["User vehicle"] then
			vehicle_name = settings.in_use["User vehicle"]
			hash = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
		end
		if streaming.is_model_a_vehicle(hash) and not entity.is_entity_dead(player.get_player_ped(pid)) then
			essentials.use_ptfx_function(kek_entity.spawn_and_push_a_vehicle_in_direction, pid, true, 8, hash)
		end
		system.yield(0)
	end
	f.on = false
end).id

menu.add_player_feature(lang["Spastic car"], "toggle", u.player_trolling_features, function(f, pid)
	while f.on do
		if kek_entity.get_control_of_entity(player.get_player_vehicle(pid)) then
			entity.set_entity_rotation(player.get_player_vehicle(pid), v3(essentials.random_real(-179.9999, 179.9999), essentials.random_real(-179.9999, 179.9999), essentials.random_real(-179.9999, 179.9999)))
			vehicle.set_vehicle_forward_speed(player.get_player_vehicle(pid), math.random(-1000, 1000))
			entity.apply_force_to_entity(player.get_player_vehicle(pid), 3, math.random(-4, 4), math.random(-4, 4), math.random(-1, 5), 0, 0, 0, true, true)
		end
		system.yield(0)
	end
end)

menu.add_player_feature(lang["Send Menyoo vehicle attacker"], "action", u.player_trolling_features, function(f, pid)
	local input <const>, status <const> = keys_and_input.get_input(lang["Type in name of menyoo vehicle."], "", 128, 0)
	if status == 2 then
		return
	end
	for _, file_name in pairs(utils.get_all_files_in_directory(paths.menyoo_vehicles, "xml")) do
		if file_name:lower():find(input:lower(), 1, true) then
			local Vehicle <const> = menyoo.spawn_xml_vehicle(paths.menyoo_vehicles.."\\"..file_name, pid)
			if entity.is_entity_a_vehicle(Vehicle) then
				if streaming.is_model_a_plane(entity.get_entity_model_hash(Vehicle)) then
					essentials.msg(lang["Attackers can't use planes. Cancelled."], "red", true)
					kek_entity.hard_remove_entity_and_its_attachments(Vehicle)
					return
				end
				kek_entity.teleport(Vehicle, location_mapper.get_most_accurate_position(essentials.get_player_coords(pid) + kek_entity.get_random_offset(-80, 80, 45, 75), true), 0)
				troll_entity.setup_peds_and_put_in_seats(kek_entity.get_empty_seats(Vehicle), ped_mapper.get_random_ped("all peds except animals"), Vehicle, pid)
			end
			return
		end
	end
end)

menu.add_player_feature(lang["Send"], "value_str", u.player_trolling_features, function(f, pid)
	if player.player_count() == 0 then
		f.on = false
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		return
	end
	local Entity, temp
	while f.on do
		if essentials.is_str(f, "Clown vans") then
			temp = troll_entity.spawn_standard_alone(f, pid, troll_entity.send_clown_van)
		elseif essentials.is_str(f, "Kek's chopper") then
			temp = troll_entity.spawn_standard_alone(f, pid, troll_entity.send_kek_chopper)
		elseif essentials.is_str(f, "Army") then
			temp = troll_entity.spawn_standard_alone(f, pid, troll_entity.send_army)
		end
		if temp and temp ~= 0 and (type(temp ~= "table" or next(temp))) then
			Entity = temp
		end
		system.yield(0)
		if player.player_count() == 0 then
			f.on = false
		end
	end
	kek_entity.clear_entities(type(Entity) == "table" and Entity or {Entity})
end):set_str_data({
	lang["Clown vans"],
	lang["Kek's chopper"],
	lang["Army"]
})

settings.toggle["Exclude yourself from trolling"] = menu.add_feature(lang["Exclude you from session trolling"], "toggle", u.self_options.id, function(f)
	settings.in_use["Exclude yourself from trolling"] = f.on
end)

menu.add_feature(lang["Get parachute"], "action", u.self_options.id, function(f)
	weapon.give_delayed_weapon_to_ped(player.get_player_ped(player.player_id()), gameplay.get_hash_key("gadget_parachute"), 1, 0)
end)

menu.add_feature(lang["Send to session"], "value_str", u.session_trolling.id, function(f)
	if player.player_count() == 0 then
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		f.on = false
		return
	end
	local entities <const> = {}
	while f.on do
		system.yield(0)
		local temp
		if essentials.is_str(f, "Clown vans") then
			temp = troll_entity.spawn_standard(f, troll_entity.send_clown_van)
		elseif essentials.is_str(f, "Army") then
			temp = troll_entity.spawn_standard(f, troll_entity.send_army)
		elseif essentials.is_str(f, "Kek's chopper") then
			temp = troll_entity.spawn_standard(f, troll_entity.send_kek_chopper)
		elseif essentials.is_str(f, "Jet") then
			temp = troll_entity.spawn_standard(f, troll_entity.send_jet)
		end
		if temp and #temp > 0 then
			entities[#entities + 1] = temp
		end
	end
	for _, entities in pairs(entities) do
		for _, entities in pairs(entities) do
			kek_entity.clear_entities(type(entities) == "table" and entities or {entities})
		end
	end
end):set_str_data({
	lang["Clown vans"],
	lang["Army"],
	lang["Kek's chopper"],
	lang["Jet"]
})

menu.add_player_feature(lang["Taze player"], "toggle", u.player_trolling_features, function(f, pid)
	while f.on do
		gameplay.shoot_single_bullet_between_coords(kek_entity.get_vector_relative_to_entity(player.get_player_ped(pid), essentials.random_real(-0.5, 0.5)) + v3(0, 0, essentials.random_real(0, 1)), select(2, ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f2, memoize.v3())), 0, gameplay.get_hash_key("weapon_stungun"), player.get_player_ped(player.player_id()), true, false, 2000)
		system.yield(1000)
	end
end)

u.atomize = menu.add_player_feature(lang["Atomize"], "slider", u.player_trolling_features, function(f, pid)
	if player.player_id() == pid then
		essentials.msg(lang["You can't use this on yourself."], "red", true, 6)
		f.on = false
		return
	end
	while f.on do
		if not entity.is_entity_dead(player.get_player_ped(pid)) then
			essentials.use_ptfx_function(
				gameplay.shoot_single_bullet_between_coords, 
				kek_entity.get_vector_relative_to_entity(kek_entity.get_most_relevant_entity(pid), 1),
				entity.get_entity_coords(kek_entity.get_most_relevant_entity(pid)),
				1,
				gameplay.get_hash_key("weapon_raypistol"), 
				player.get_player_ped(player.player_id()), 
				true, 
				false, 
				1000
			)
		end
		system.yield(math.floor(1000 - f.value))
	end
end)
u.atomize.max = 1000
u.atomize.min = 200
u.atomize.mod = 50
u.atomize.value = 1000

menu.add_player_feature(lang["Float"], "value_str", u.player_trolling_features, function(f, pid)
	if player.player_count() == 0 then
		f.on = false
		essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
		return
	end
	local hash <const> = gameplay.get_hash_key("bkr_prop_biker_bblock_sml2")
	local platform = 0
	local pos = v3()
	while f.on and player.player_count() > 0 do
		system.yield(0)
		if not entity.is_entity_an_object(platform) then
			local objects <const> = memoize.get_all_objects()
			for i = 1, #objects do
				if entity.get_entity_model_hash(objects[i]) == hash and memoize.get_distance_between(objects[i], player.get_player_ped(pid)) < 75 then
					kek_entity.clear_entities({objects[i]})
				end
			end
			platform = kek_entity.spawn_networked_object(hash, function()
				pos = essentials.get_player_coords(pid) - memoize.v3(0, 0, -2.5)
				return pos
			end)
		end
		local player_coords <const> = essentials.get_player_coords(pid)
		if entity.get_entity_coords(platform).z > player_coords.z + 3 then
			pos.z = player_coords.z - 2.5
		elseif essentials.is_str(f, "Upwards") then
			pos.z = pos.z + 0.05
		elseif essentials.is_str(f, "Downwards") and entity.get_entity_coords(platform).z + 5 > player_coords.z then
			pos.z = pos.z - 0.05
		end
		pos.x = player_coords.x
		pos.y = player_coords.y
		kek_entity.teleport(platform, pos)
	end
	kek_entity.clear_entities({platform})
	f.on = false
end):set_str_data({
	lang["Upwards"],
	lang["Still"],
	lang["Downwards"]
})

menu.add_player_feature(lang["Glitch vehicle"], "action_value_str", u.player_trolling_features, function(f, pid)
	if essentials.is_str(f, "Glitch") then
		kek_entity.glitch_vehicle(player.get_player_vehicle(pid))
	elseif essentials.is_str(f, "Unglitch") then
		if entity.is_entity_a_vehicle(player.get_player_vehicle(pid)) then
			for seat = -1, vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(player.get_player_vehicle(pid))) - 2 do
				local Ped <const> = vehicle.get_ped_in_vehicle_seat(player.get_player_vehicle(pid), seat)
				if entity.is_entity_a_ped(Ped) and not ped.is_ped_a_player(Ped) then
					kek_entity.clear_entities(kek_entity.get_all_attached_entities(Ped))
					kek_entity.clear_entities({Ped})
				end
			end
		end
	end
end):set_str_data({
	lang["Glitch"],
	lang["Unglitch"]
})

menu.add_feature(lang["Give all weapons"], "action", u.weapons_self.id, function()
	for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
		weapon.give_delayed_weapon_to_ped(player.get_player_ped(player.player_id()), weapon_hash, 0, 0)
	end
end)

menu.add_feature(lang["Max all weapons"], "action", u.weapons_self.id, function()
	for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
		weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(player.player_id()), false, weapon_hash)
	end
end)

menu.add_feature(lang["Randomize all weapons"], "action", u.weapons_self.id, function()
	for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
		weapon_mapper.set_ped_weapon_attachments(player.get_player_ped(player.player_id()), true, weapon_hash)
	end
end)

settings.toggle["Random weapon camos"] = menu.add_feature(lang["Random weapon camo"], "slider", u.weapons_self.id, function(f)
	while f.on do
		for _, weapon_hash in pairs(weapon.get_all_weapon_hashes()) do
			if weapon.has_ped_got_weapon(player.get_player_ped(player.player_id()), weapon_hash) then
				local number_of_tints <const> = weapon.get_weapon_tint_count(weapon_hash)
				if weapon_hash and weapon_hash ~= gameplay.get_hash_key("weapon_unarmed") and number_of_tints > 0 then
					weapon.set_ped_weapon_tint_index(player.get_player_ped(player.player_id()), weapon_hash, math.random(1, number_of_tints))
				end
			end
		end
		system.yield(1000 - math.floor(f.value))
	end
end)
settings.valuei["Random weapon camos speed"] = settings.toggle["Random weapon camos"]
settings.valuei["Random weapon camos speed"].max = 980
settings.valuei["Random weapon camos speed"].min = 0
settings.valuei["Random weapon camos speed"].mod = 20
settings.valuei["Random weapon camos speed"].value = 500

player_feat_ids["Vehicle gun"] = menu.add_player_feature(lang["Vehicle gun"], "value_str", u.pWeapons, function(f, pid)
	if f.on then
		if player.player_id() == pid then
			u.self_vehicle_gun.on = true
		end
		local entities <const>, distance_from_player = {}
		menu.create_thread(function()
			while f.on do
				if #entities > 15 then
					kek_entity.clear_entities({entities[1]})
					table.remove(entities, 1)
				end
				system.yield(0)
			end
		end, nil)
		while f.on do
			if settings.in_use["User vehicle"] == "?" or player.is_player_in_any_vehicle(pid) then
				distance_from_player = 18
			else
				distance_from_player = 9
			end
			if f.on and ped.is_ped_shooting(player.get_player_ped(pid)) then
				local hash <const> = vehicle_mapper.get_hash_from_user_input(settings.in_use["User vehicle"])
				if streaming.is_model_a_vehicle(hash) then
					local car <const> = kek_entity.spawn_networked_mission_vehicle(hash, function()
						local distance <const> = kek_entity.get_longest_dimension(hash) + 6 +
						(entity.is_entity_a_vehicle(player.get_player_vehicle(pid)) 
							and kek_entity.get_longest_dimension(entity.get_entity_model_hash(player.get_player_vehicle(pid)))
						or 0)
						
						local pos <const> = kek_entity.get_vector_in_front_of_me(distance)
						return pos, player.get_player_heading(pid)
					end)
					if player.player_id() ~= pid then
						kek_entity.set_entity_rotation(car, entity.get_entity_rotation(player.get_player_ped(pid)))
					else
						kek_entity.set_entity_rotation(car, cam.get_gameplay_cam_rot())
					end
					vehicle.set_vehicle_forward_speed(car, 120)
					entities[#entities + 1] = car
				end
			end
			system.yield(0)
		end
		if player.player_id() == pid then
			u.self_vehicle_gun.on = false
		end
		kek_entity.clear_entities(entities)
	end
end).id
settings.user_entity_features.vehicle.player_feats["Player vehicle gun"] = player_feat_ids["Vehicle gun"]

menu.add_player_feature(lang["Kick gun"], "toggle", u.pWeapons, function(f, pid)
	while f.on do
		system.yield(0)
		local Ped <const> = player.get_entity_player_is_aiming_at(pid)
		if entity.is_entity_a_ped(Ped) and ped.is_ped_a_player(Ped) then
			local target_pid <const> = player.get_player_from_ped(Ped)
			if target_pid ~= player.player_id() and player.can_player_be_modder(target_pid) and ped.is_ped_shooting(player.get_player_ped(pid)) and essentials.is_not_friend(target_pid) then
				essentials.kick_player(target_pid)
			end
		end
	end
end)

menu.add_player_feature(lang["Delete gun"], "toggle", u.pWeapons, function(f, pid)
	while f.on do
		system.yield(0)
		local Entity <const> = player.get_entity_player_is_aiming_at(pid)
		network.request_control_of_entity(Entity)
		if ped.is_ped_shooting(player.get_player_ped(pid))
		and entity.is_an_entity(Entity) 
		and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) 
		and network.has_control_of_entity(Entity) then
			kek_entity.clear_entities({Entity})
		end
	end
end)

menu.add_player_feature(lang["Explosion gun"], "toggle", u.pWeapons, function(f, pid)
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(pid)) then
			local pos = select(2, ped.get_ped_last_weapon_impact(player.get_player_ped(pid)))
			essentials.use_ptfx_function(fire.add_explosion, pos, math.random(0, essentials.number_of_explosion_types), true, false, 0, player.get_player_ped(pid))
		end
		system.yield(0)
	end
end)

settings.user_entity_features.object.feats["Change object"] = menu.add_feature(lang["Set object in use"], "action_value_str", u.weapons_self.id, function()
	settings.user_entity_features.object.feats["Change user object setting"].on = true
end)

settings.user_entity_features.object.feats["Object gun"] = menu.add_feature(lang["Object gun"], "value_str", u.weapons_self.id, function(f)
	local entities <const> = {}
	while f.on do
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local hash <const> = object_mapper.get_hash_from_user_input(settings.in_use["User object"])
			if streaming.is_model_an_object(hash) then
				entities[#entities + 1] = kek_entity.spawn_networked_object(hash, function() 
					return kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 15), 0
				end)
				local pos <const> = kek_entity.get_collision_vector(player.player_id())
				kek_entity.set_entity_rotation(entities[#entities], cam.get_gameplay_cam_rot())
				for i = 1, 10 do
					entity.apply_force_to_entity(entities[#entities], 3, pos.x, pos.y, pos.z, 0, 0, 0, true, true)
				end
				if #entities > 10 then
					kek_entity.clear_entities({entities[1]})
					table.remove(entities, 1)
				end
			end
		end
		system.yield(0)
	end
	kek_entity.clear_entities(entities)
end)

u.airstrike_gun = menu.add_feature(lang["Airstrike gun"], "toggle", u.weapons_self.id, function(f)
	while f.on do
		system.yield(0)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			local pos <const> = kek_entity.get_collision_vector(player.player_id())
			gameplay.shoot_single_bullet_between_coords(pos + memoize.v3(0, 0, 15), pos, 1000, gameplay.get_hash_key("weapon_airstrike_rocket"), player.get_player_ped(player.player_id()), true, false, 250)
		end
	end
end)

settings.user_entity_features.vehicle.feats["Change vehicle gun"] = menu.add_feature(lang["Set vehicle in use"], "action_value_str", u.weapons_self.id, function()
	settings.user_entity_features.vehicle.feats["Change user vehicle setting"].on = true
end)

u.self_vehicle_gun = menu.add_feature(lang["Vehicle gun"], "value_str", u.weapons_self.id, function(f)
	menu.get_player_feature(player_feat_ids["Vehicle gun"]).feats[player.player_id()].on = f.on
end)
settings.user_entity_features.vehicle.feats["Vehicle gun"] = u.self_vehicle_gun

menu.add_feature(lang["Clear entities"], "value_str", u.kek_utilities.id, function(f)
	local radius = 0
	menu.create_thread(function()
		while f.on do
			if settings.toggle["Show red sphere clear entities"].on and not essentials.is_str(f, "Peds & vehicles") and not essentials.is_str(f, "All") and radius < 10001 then
				graphics.draw_marker(28, essentials.get_player_coords(player.player_id()), memoize.v3(0, 90, 0), memoize.v3(0, 90, 0), memoize.v3(radius, radius, radius), 255, 0, 0, 85, false, false, 2, false, nil, "MarkerTypeDebugSphere", false)
			end
			system.yield(0)
		end
	end, nil)
	while f.on do
		system.yield(0)
		if essentials.is_str(f, "Cops") then
			gameplay.clear_area_of_cops(memoize.get_entity_coords(essentials.get_ped_closest_to_your_pov()), settings.valuei["Cops clear distance"].value, true)
			radius = settings.valuei["Cops clear distance"].value
		else
			if essentials.is_str(f, "Ptfx") or essentials.is_str(f, "All") then
				graphics.remove_ptfx_in_range(memoize.get_entity_coords(essentials.get_ped_closest_to_your_pov()), settings.valuei["Ptfx clear distance"].value)
				radius = settings.valuei["Ptfx clear distance"].value
			end
			if not essentials.is_str(f, "Ptfx") then
				local entities <const> = {}
				if essentials.is_str(f, "Vehicles") or essentials.is_str(f, "Peds & vehicles") or essentials.is_str(f, "All") then
					entities.vehicles = {
						entities 			   = vehicle.get_all_vehicles(),
						max_number_of_entities = nil,
						remove_player_entities = true,
						max_range 			   = settings.valuei["Vehicle clear distance"].value,
						sort_by_closest 	   = false
					}
					radius = settings.valuei["Vehicle clear distance"].value
				end
				if essentials.is_str(f, "Peds") or essentials.is_str(f, "Peds & vehicles") or essentials.is_str(f, "All") then
					entities.peds = {
						entities 			   = ped.get_all_peds(),
						max_number_of_entities = nil,
						remove_player_entities = true,
						max_range 			   = settings.valuei["Ped clear distance"].value,
						sort_by_closest 	   = false
					}
					radius = settings.valuei["Ped clear distance"].value
				end
				if essentials.is_str(f, "Objects") or essentials.is_str(f, "All") and player.player_count() > 0 then
					entities.objects = {
						entities 			   = object.get_all_objects(),
						max_number_of_entities = nil,
						remove_player_entities = false,
						max_range 			   = settings.valuei["Object clear distance"].value,
						sort_by_closest 	   = false
					}
					radius = settings.valuei["Object clear distance"].value
				end
				if essentials.is_str(f, "Pickups") or essentials.is_str(f, "All") and player.player_count() > 0 then
					entities.pickups = {
						entities 			   = object.get_all_pickups(),
						max_number_of_entities = nil,
						remove_player_entities = false,
						max_range 			   = settings.valuei["Pickup clear distance"].value,
						sort_by_closest 	   = false
					}
					radius = settings.valuei["Pickup clear distance"].value
				end
				for _, entities in pairs(kek_entity.get_table_of_entities_with_respect_to_distance_and_set_limit(entities, essentials.get_ped_closest_to_your_pov())) do
					kek_entity.clear_entities(entities, 0)
				end
			end
		end
	end
end):set_str_data({
	lang["Vehicles"], 
	lang["Peds"], 
	lang["Objects"], 
	lang["Pickups"],
	lang["Ptfx"],
	lang["Peds & vehicles"], 
	lang["All"], 	
	lang["Cops"]
})

settings.toggle["Show red sphere clear entities"] = menu.add_feature(lang["Show sphere"], "toggle", u.kek_utilities.id)

for _, setting_name in pairs({
	"Vehicle clear distance", 
	"Ped clear distance", 
	"Object clear distance", 
	"Pickup clear distance",
	"Ptfx clear distance", 
	"Cops clear distance"
}) do
	settings.valuei[setting_name] = menu.add_feature(lang[setting_name], "action_value_i", u.kek_utilities.id, function(f)
		keys_and_input.input_number_for_feat(f, lang["Type in clear distance limit."])
	end)
	settings.valuei[setting_name].max, settings.valuei[setting_name].min, settings.valuei[setting_name].mod = 25000, 1, 10
end

u.clear_owned_entities = menu.add_feature(lang["Clear all owned entities"], "action", u.kek_utilities.id, function()
	kek_entity.entity_manager:clear()
	essentials.msg(lang["Cleared owned entities."], "green", true)
end)

menu.add_feature(lang["Disable ped spawning"], "toggle", u.kek_utilities.id, function(f)
	while f.on do
		ped.set_ped_density_multiplier_this_frame(0)
		system.yield(0)
	end
end)

menu.add_feature(lang["Disable vehicle spawning"], "toggle", u.kek_utilities.id, function(f)
	while f.on do
		vehicle.set_vehicle_density_multipliers_this_frame(0)
		system.yield(0)
	end
end)

menu.add_feature(lang["Shoot entity| get model name of entity"], "toggle", u.kek_utilities.id, function(f)
	while f.on do
		local model_name = ""
		local Entity = player.get_entity_player_is_aiming_at(player.player_id())
		if entity.is_entity_a_ped(Entity) and ped.is_ped_in_any_vehicle(Entity) then
			Entity = ped.get_vehicle_ped_is_using(Entity)
		end
		local hash <const> = entity.get_entity_model_hash(Entity)
		if ped.is_ped_shooting(player.get_player_ped(player.player_id())) then
			if streaming.is_model_an_object(hash) then
				model_name = object_mapper.GetModelFromHash(hash)
			elseif streaming.is_model_a_ped(hash) then
				model_name = ped_mapper.get_model_from_hash(hash)
			elseif streaming.is_model_a_vehicle(hash) then
				model_name = vehicle_mapper.GetModelFromHash(hash)
			else
				model_name = ""
			end
		end
		if Entity ~= 0 then
			local name, model
			if entity.is_entity_a_vehicle(Entity) then
				model = vehicle_mapper.GetModelFromHash(hash)
				name = vehicle_mapper.get_vehicle_name(hash).."\n"
			elseif entity.is_entity_a_ped(Entity) then
				name = ped_mapper.get_model_from_hash(hash)
			else
				name = object_mapper.GetModelFromHash(hash)
			end
			ui.set_text_color(255, 255, 255, 255)
			ui.set_text_scale(0.5)
			ui.set_text_font(1)
			ui.set_text_outline(true)
			ui.draw_text(string.format("%s%s\n%i\nRot: %s", name, model or "", hash, entity.get_entity_rotation__native(Entity, 2)), memoize.v2(0.5, 0.4))
		end
		if model_name ~= "" then
			essentials.msg(lang["The hash was copied to your clipboard, more info in the debug console."], "green", true)
			print(string.format("Model name: %s\nModel hash: %i", model_name, hash))
			utils.to_clipboard(tostring(hash))
			model_name = ""
			system.yield(250)
		end
		system.yield(0)
	end
end)

do
	u.entity_manager = menu.add_feature(lang["Entity manager"], "parent", u.kek_utilities.id)
	local parent_i = 0
	local entity_manager_parents <const> = essentials.const({
		menu.add_feature(lang["Vehicles"], "parent", u.entity_manager.id, function()
			parent_i = 1
		end),
		menu.add_feature(lang["Peds"], "parent", u.entity_manager.id, function()
			parent_i = 2
		end),
		menu.add_feature(lang["Objects"], "parent", u.entity_manager.id, function()
			parent_i = 3
		end)
	})

	local player_vehicles = {timer = 0}
	local timer <const> = {}

	local parents_in_use <const> = essentials.const({
		{}, -- Vehicles
		{}, -- Peds
		{} -- Objects
	})
	local filters <const> = {
		"", -- Vehicles
		"", -- Peds
		"" -- Objects
	}
	local entity_getters <const> = essentials.const({
		memoize.get_all_vehicles,
		memoize.get_all_peds,
		memoize.get_all_objects
	})
	local free_parents <const> = essentials.const({
		{}, -- Vehicles
		{}, -- Peds
		{} -- Objects
	})
	local get_names <const> = essentials.const({
		vehicle_mapper.get_vehicle_name,
		ped_mapper.get_model_from_hash,
		object_mapper.GetModelFromHash
	})
	local number_of_features <const> = essentials.const({
		300, -- Vehicles
		256, -- Peds
		2300 -- Objects
	})

	local explosion_names <const> = {}
	for explosion_name, id in pairs(enums.explosion_types) do
		explosion_names[id + 1] = explosion_name:lower()
	end

	local set_yourself_in_seat <const> = {}
	local teleport_all_in_front_of_player <const> = {}
	local teleport_in_front_of_player <const> = {}
	local attach_player_vehicle <const> = {}
	local detach_player_vehicle <const> = {}
	local seat_strings <const> = essentials.const({
		lang["Driver's seat"],
		lang["Front passenger seat"],
		lang["Left backseat"],
		lang["Right backseat"],
		lang["Extra seat"].." 1",
		lang["Extra seat"].." 2",
		lang["Extra seat"].." 3",
		lang["Extra seat"].." 4",
		lang["Extra seat"].." 5",
		lang["Extra seat"].." 6",
		lang["Extra seat"].." 7",
		lang["Extra seat"].." 8",
		lang["Extra seat"].." 9",
		lang["Extra seat"].." 10",
		lang["Extra seat"].." 11",
		lang["Extra seat"].." 12"
	})
	local function entities_ite(i)
		local ents <const> = {}
		for Entity in pairs(parents_in_use[i]) do
			ents[#ents + 1] = Entity
		end
		local my_ped <const> = player.get_player_ped(player.player_id())
		table.sort(ents, function(a, b) 
			return (memoize.get_distance_between(a, my_ped) < memoize.get_distance_between(b, my_ped)) 
		end)
		local i2 = 0
		local count = 0
		return function()
			repeat
				i2 = i2 + 1
			until not ents[i2] or
			(u.entity_manager_toggle.on
			and entity.is_an_entity(ents[i2])
			and not kek_entity.is_vehicle_an_attachment_to(kek_entity.get_parent_of_attachment(ents[i2]), player.get_player_vehicle(player.player_id()))
			and (not entity.is_entity_a_ped(ents[i2]) or not ped.is_ped_a_player(ents[i2]))
			and parents_in_use[i][ents[i2]].name:find(filters[i])
			and kek_entity.get_control_of_entity(ents[i2], 0))
			count = count + 1
			system.yield(0)
			return ents[i2], count
		end
	end

	for i = 1, 3 do
		menu.add_feature(lang["All entities of this type"], "parent", entity_manager_parents[i].id, function(parent)
			if parent.child_count == 0 then
				menu.add_feature(lang["Delete"], "action", parent.id, function(f)
					if i == 3 and player.player_count() == 0 then
						essentials.msg(lang["This can't be used in singleplayer."], "red", true, 6)
						return
					end
					for Entity in entities_ite(i) do
						kek_entity.hard_remove_entity_and_its_attachments(Entity)
					end
				end)
				local exp_type <const> = menu.add_feature(lang["Explode"], "action_value_str", parent.id, function(f)
					for Entity in entities_ite(i) do
						essentials.use_ptfx_function(fire.add_explosion, entity.get_entity_coords(Entity), f.value, true, false, 0, player.get_player_ped(player.player_id()))
					end								
				end)
				exp_type:set_str_data(explosion_names)
				exp_type.value = enums.explosion_types.BLIMP
				if i == 1 then
					local speed_set = menu.add_feature(lang["Set speed"], "action_value_i", parent.id, function(f)
						for Vehicle in entities_ite(i) do
							vehicle.set_vehicle_forward_speed(Vehicle, f.value)
						end
					end)
					local gravity <const> = menu.add_feature(lang["Gravity"], "action_value_f", parent.id, function(f)
						for Vehicle in entities_ite(i) do
							vehicle.set_vehicle_gravity_amount(Vehicle, f.value)
						end
					end)
					gravity.min = -980.0
					gravity.max = 980.0
					gravity.mod = 9.8
					gravity.value = 9.8

					speed_set.max, speed_set.min, speed_set.mod = 1000, -1000, 25
					speed_set.value = 100
					menu.add_feature(lang["Toggle engine"], "action_value_str", parent.id, function(f)
						for Vehicle in entities_ite(i) do
							if essentials.is_str(f, "Kick engine") then
								vehicle.set_vehicle_engine_health(Vehicle, -4000)
							elseif essentials.is_str(f, "Heal engine") then
								vehicle.set_vehicle_engine_health(Vehicle, 1000)
								if vehicle.get_vehicle_number_of_passengers(Vehicle) > 0 then
									vehicle.set_vehicle_engine_on(Vehicle, true, true, false)
								end
							end
						end
					end):set_str_data({
						lang["Kill engine"],
						lang["Heal engine"]
					})
				end
				if i == 2 then
					menu.add_feature(lang["Clear ped tasks"], "action", parent.id, function()
						for Ped in entities_ite(i) do
							ped.clear_ped_tasks_immediately(Ped)
						end
					end)
				end
				teleport_all_in_front_of_player[i] = menu.add_feature(lang["Teleport in front of player"], "action_value_str", parent.id, function(f)
					if player.is_player_valid(f.data[f.value + 1]) then
						for Entity, count in entities_ite(i) do
							entity.set_entity_coords_no_offset(Entity, location_mapper.get_most_accurate_position_soft(kek_entity.get_vector_relative_to_entity(player.get_player_ped(f.data[f.value + 1]), 10)))
							if count == 30 then
								break
							end
						end
					end
				end)
				if i == 1 or i == 2 then
					menu.add_feature(lang["Godmode"], "value_str", parent.id, function(f)
						while f.on do
							for Entity in entities_ite(i) do
								if entity.get_entity_god_mode(Entity) ~= (essentials.is_str(f, "Give")) then
									kek_entity.modify_entity_godmode(Entity, essentials.is_str(f, "Give"))
								end
							end
							system.yield(0)
						end
						for Entity in entities_ite(i) do
							if entity.get_entity_god_mode(Entity) then
								kek_entity.modify_entity_godmode(Entity, false)
							end
						end
					end):set_str_data({
						lang["Give"],
						lang["Remove"]
					})
					menu.add_feature(lang["Resurrect"], "action", parent.id, function()
						for Entity in entities_ite(i) do
							if entity.is_entity_dead(Entity) then
								if entity.is_entity_a_vehicle(Entity) then
									kek_entity.repair_car(Entity)
								elseif entity.is_entity_a_ped(Entity) then
									ped.resurrect_ped(Entity)
									ped.clear_ped_tasks_immediately(Entity)
								end
							end
						end
					end)
				end
			end
			local player_names <const> = {player.get_player_name(player.player_id())}
			teleport_all_in_front_of_player[i].data = {player.player_id()}
			for pid in essentials.players() do
				player_names[#player_names + 1] = player.get_player_name(pid)
				teleport_all_in_front_of_player[i].data[#teleport_all_in_front_of_player[i].data + 1] = pid
			end
			teleport_all_in_front_of_player[i]:set_str_data(player_names)
		end)

		menu.add_feature(lang["Filter"].." < >", "action", entity_manager_parents[i].id, function(f)
			local input <const>, status <const> = keys_and_input.get_input(lang["Type in name of entity."], "", 128, 0)
			if status == 2 then
				return
			end
			filters[i] = essentials.make_string_case_insensitive(essentials.remove_special(input))
			if input == "" then
				f.name = lang["Filter"].." < >"
			else
				f.name = string.format("%s < %s >", lang["Filter"], input)
			end
		end)

		for i2 = 1, number_of_features[i] do
			free_parents[i][#free_parents[i] + 1] = menu.add_feature("", "parent", entity_manager_parents[i].id, function(parent)
				if parent.child_count == 0 then
					local exp_type <const> = menu.add_feature(lang["Explode"], "action_value_str", parent.id, function(f)
						essentials.use_ptfx_function(fire.add_explosion, entity.get_entity_coords(parent.data.entity), f.value, true, false, 0, player.get_player_ped(player.player_id()))
					end)
					exp_type:set_str_data(explosion_names)
					exp_type.value = enums.explosion_types.BLIMP

					do
						local attach_parent <const> = menu.add_feature(lang["Attach players"], "parent", parent.id)
						local rot_x, rot_y, rot_z, offset_x, offset_y, offset_z, collision

						attach_player_vehicle[i] = menu.add_feature(lang["Attach player vehicle to entity"], "action_value_str", attach_parent.id, function(f)
							local initial_pos <const> = essentials.get_player_coords(player.player_id())
							local status <const>, had_to_teleport <const> = kek_entity.check_player_vehicle_and_teleport_if_necessary(f.data[f.value + 1])
							if not status or parent.data.entity == player.get_player_vehicle(f.data[f.value + 1]) then
								if not status then
									essentials.msg(lang["Player is not in a vehicle."], "red", true, 6)
								end
								goto exit
							end
							if kek_entity.get_control_of_entity(player.get_player_vehicle(f.data[f.value + 1]), nil, nil, true) then
								entity.attach_entity_to_entity(player.get_player_vehicle(f.data[f.value + 1]), parent.data.entity, 0, memoize.v3(offset_x.value, offset_y.value, offset_z.value), memoize.v3(rot_x.value, rot_y.value, rot_z.value), false, collision.on, false, 0, true)
							end
							::exit::
							if had_to_teleport then
								kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
							end
						end)

						detach_player_vehicle[i] = menu.add_feature(lang["Detach"], "action_value_str", attach_parent.id, function(f)
							local initial_pos <const> = essentials.get_player_coords(player.player_id())
							local status <const>, had_to_teleport <const> = kek_entity.check_player_vehicle_and_teleport_if_necessary(f.data[f.value + 1])
							if status and entity.is_entity_attached(player.get_player_vehicle(f.data[f.value + 1])) and kek_entity.get_control_of_entity(player.get_player_vehicle(f.data[f.value + 1]), nil, nil, true) then
								entity.detach_entity(player.get_player_vehicle(f.data[f.value + 1]))
							end
							if had_to_teleport then
								kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), initial_pos)
							end
						end)

						local f <const> = attach_player_vehicle[i]
						local attach_callback <const> = function()
							if entity.get_entity_attached_to(player.get_player_vehicle(f.data[f.value + 1])) == parent.data.entity then
								if parent.data.entity == player.get_player_vehicle(f.data[f.value + 1]) then
									return
								end
								if kek_entity.get_control_of_entity(player.get_player_vehicle(f.data[f.value + 1])) then
									entity.attach_entity_to_entity(player.get_player_vehicle(f.data[f.value + 1]), parent.data.entity, 0, memoize.v3(offset_x.value, offset_y.value, offset_z.value), memoize.v3(rot_x.value, rot_y.value, rot_z.value), false, collision.on, false, 0, true)
								end
							end
						end

						rot_x = menu.add_feature(lang["Rotation x"], "autoaction_value_i", attach_parent.id, attach_callback)
						rot_x.min, rot_x.max, rot_x.mod = -180, 180, 10

						rot_y = menu.add_feature(lang["Rotation y"], "autoaction_value_i", attach_parent.id, attach_callback)
						rot_y.min, rot_y.max, rot_y.mod = -180, 180, 10

						rot_z = menu.add_feature(lang["Rotation z"], "autoaction_value_i", attach_parent.id, attach_callback)
						rot_z.min, rot_z.max, rot_z.mod = -180, 180, 10

						offset_x = menu.add_feature(lang["Offset x"], "autoaction_value_i", attach_parent.id, attach_callback)
						offset_x.min, offset_x.max, offset_x.mod = -100, 100, 1

						offset_y = menu.add_feature(lang["Offset y"], "autoaction_value_i", attach_parent.id, attach_callback)
						offset_y.min, offset_y.max, offset_y.mod = -100, 100, 1

						offset_z = menu.add_feature(lang["Offset z"], "autoaction_value_i", attach_parent.id, attach_callback)
						offset_z.min, offset_z.max, offset_z.mod = -100, 100, 1
						offset_z.value = 3

						collision = menu.add_feature(lang["Collision"], "toggle", attach_parent.id, attach_callback)
						collision.on = true

						menu.add_feature(lang["Reset rot"], "action", attach_parent.id, function(f)
							rot_x.value, rot_y.value, rot_z.value = 0, 0, 0
							rot_x.on = true -- Update the entity's rot and offset
						end)
						menu.add_feature(lang["Reset offset"], "action", attach_parent.id, function(f)
							offset_x.value, offset_y.value, offset_z.value = 0, 0, 3
							offset_x.on = true -- Update the entity's rot and offset
						end)
						menu.add_feature(lang["Clear attachments"], "action", attach_parent.id, function(f)
							kek_entity.clear_entities(kek_entity.get_all_attached_entities(parent.data.entity))
						end)
					end

					if i == 1 then
						local speed_set = menu.add_feature(lang["Set speed"], "action_value_i", parent.id, function(f)
							if kek_entity.get_control_of_entity(parent.data.entity, nil, nil, true) then
								entity.set_entity_max_speed(parent.data.entity, 45000)
								vehicle.set_vehicle_forward_speed(parent.data.entity, f.value)
							end
						end)
						speed_set.max, speed_set.min, speed_set.mod = 1000, -1000, 25
						speed_set.value = 100
						local gravity <const> = menu.add_feature(lang["Gravity"], "action_value_f", parent.id, function(f)
							if kek_entity.get_control_of_entity(parent.data.entity, nil, nil, true) then
								vehicle.set_vehicle_gravity_amount(parent.data.entity, f.value)
							end
						end)
						gravity.min = -980.0
						gravity.max = 980.0
						gravity.mod = 9.8
						gravity.value = 9.8
						set_yourself_in_seat[i] = menu.add_feature(lang["Set yourself in seat"], "action_value_str", parent.id, function(f)
							local velocity <const> = entity.get_entity_velocity(parent.data.entity)
							ped.clear_ped_tasks_immediately(vehicle.get_ped_in_vehicle_seat(parent.data.entity, f.value - 1))
							ped.set_ped_into_vehicle(player.get_player_ped(player.player_id()), parent.data.entity, f.value - 1)
							entity.set_entity_velocity(parent.data.entity, velocity)
						end)
						menu.add_feature(lang["Toggle engine"], "action_value_str", parent.id, function(f)
							if kek_entity.get_control_of_entity(parent.data.entity, nil, nil, true) then
								if essentials.is_str(f, "Kill engine") then
									vehicle.set_vehicle_engine_health(parent.data.entity, -4000)
								elseif essentials.is_str(f, "Heal engine") then
									vehicle.set_vehicle_engine_health(parent.data.entity, 1000)
									if vehicle.get_vehicle_number_of_passengers(parent.data.entity) > 0 then
										vehicle.set_vehicle_engine_on(parent.data.entity, true, true, false)
									end
								end
							end
						end):set_str_data({
							lang["Kill engine"],
							lang["Heal engine"]
						})
					end
					if i == 2 then
						menu.add_feature(lang["Clear ped tasks"], "action", parent.id, function(f)
							ped.clear_ped_tasks_immediately(parent.data.entity)
						end)
					end
					if i == 1 or i == 2 then
						menu.add_feature(lang["Clone"], "action", parent.id, function(f)
							if entity.is_entity_a_vehicle(parent.data.entity) then
								local pos <const> = kek_entity.vehicle_get_vec_rel_to_dims(entity.get_entity_model_hash(parent.data.entity), player.get_player_ped(player.player_id()))
								local Vehicle <const> = menyoo.clone_vehicle(parent.data.entity, pos)
								kek_entity.set_entity_heading(Vehicle, player.get_player_heading(player.player_id()))
							elseif entity.is_entity_a_ped(parent.data.entity) then
								local Ped <const> = ped.clone_ped(parent.data.entity)
								kek_entity.teleport(Ped, location_mapper.get_most_accurate_position_soft(kek_entity.get_vector_relative_to_entity(player.get_player_ped(player.player_id()), 8)))
							end
						end)
						menu.add_feature(lang["Resurrect"], "action", parent.id, function(f)
							if entity.is_entity_dead(parent.data.entity) and kek_entity.get_control_of_entity(parent.data.entity, nil, nil, true) then
								if entity.is_entity_a_vehicle(parent.data.entity) then
									kek_entity.repair_car(parent.data.entity)
								elseif entity.is_entity_a_ped(parent.data.entity) then
									ped.resurrect_ped(parent.data.entity)
									ped.clear_ped_tasks_immediately(parent.data.entity)
								end
							end
						end)
						menu.add_feature(lang["Godmode"], "value_str", parent.id, function(f)
							while f.on and parent.on and entity.is_an_entity(parent.data.entity) do
								kek_entity.modify_entity_godmode(parent.data.entity, essentials.is_str(f, "Give"))
								system.yield(0)
							end
							f.on = false
						end):set_str_data({
							lang["Give"],
							lang["Remove"]
						})
					end
					menu.add_feature(lang["Delete"], "action", parent.id, function(f)
						for pid in essentials.players(true) do
							if player.get_player_vehicle(pid) == parent.data.entity then
								kek_entity.remove_player_vehicle(pid)
								return
							end
						end
						kek_entity.hard_remove_entity_and_its_attachments(parent.data.entity)
					end)
					menu.add_feature(lang["Teleport to entity"], "action", parent.id, function(f)
						kek_entity.teleport(kek_entity.get_most_relevant_entity(player.player_id()), kek_entity.get_vector_relative_to_entity(parent.data.entity, 1))
					end)
					teleport_in_front_of_player[i] = menu.add_feature(lang["Teleport in front of player"], "action_value_str", parent.id, function(f)
						if player.is_player_valid(f.data[f.value + 1]) then
							kek_entity.teleport(
								parent.data.entity, 
								entity.is_entity_a_vehicle(parent.data.entity) and kek_entity.vehicle_get_vec_rel_to_dims(entity.get_entity_model_hash(parent.data.entity), player.get_player_ped(f.data[f.value + 1]))
								or location_mapper.get_most_accurate_position_soft(kek_entity.get_vector_relative_to_entity(player.get_player_ped(f.data[f.value + 1]), 10))
							)
							kek_entity.set_entity_heading(parent.data.entity, player.get_player_heading(f.data[f.value + 1]))
						end
					end)
					menu.add_feature(lang["Copy to clipboard"], "action_value_str", parent.id, function(f)
						if essentials.is_str(f, "position") then
							utils.to_clipboard(tostring(entity.get_entity_coords(parent.data.entity)))
						elseif essentials.is_str(f, "pos without dec") then
							local pos <const> = entity.get_entity_coords(parent.data.entity)
							utils.to_clipboard(string.format("%i, %i, %i", essentials.round(pos.x), essentials.round(pos.y), essentials.round(pos.z)))
						elseif essentials.is_str(f, "hash") then
							utils.to_clipboard(tostring(entity.get_entity_model_hash(parent.data.entity)))
						elseif essentials.is_str(f, "model name") then
							if i == 1 then
								utils.to_clipboard(vehicle_mapper.GetModelFromHash(entity.get_entity_model_hash(parent.data.entity)))
							elseif i == 2 then
								utils.to_clipboard(ped_mapper.get_model_from_hash(entity.get_entity_model_hash(parent.data.entity)))
							elseif i == 3 then
								utils.to_clipboard(object_mapper.GetModelFromHash(entity.get_entity_model_hash(parent.data.entity)))
							end
						elseif essentials.is_str(f, "name") then
							utils.to_clipboard(get_names[i](entity.get_entity_model_hash(parent.data.entity)))
						end
					end):set_str_data({
						lang["position"],
						lang["pos without dec"],
						lang["hash"],
						lang["model name"],
						lang["name"]
					})
				end
				if i == 1 then
					set_yourself_in_seat[i]:set_str_data(table.move(seat_strings, 1, math.max(vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(parent.data.entity)), 1), 1, {}))
				end
				local player_names <const> = {player.get_player_name(player.player_id())} -- So that you are the first player in the str_data
				teleport_in_front_of_player[i].data = {player.player_id()}
				attach_player_vehicle[i].data = teleport_in_front_of_player[i].data
				detach_player_vehicle[i].data = teleport_in_front_of_player[i].data
				for pid in essentials.players() do
					player_names[#player_names + 1] = player.get_player_name(pid)
					teleport_in_front_of_player[i].data[#teleport_in_front_of_player[i].data + 1] = pid
				end
				teleport_in_front_of_player[i]:set_str_data(player_names)
				attach_player_vehicle[i]:set_str_data(player_names)
				detach_player_vehicle[i]:set_str_data(player_names)
			end)
			free_parents[i][#free_parents[i]].on = false
		end
	end

	u.entity_manager_toggle = menu.add_feature(lang["Entity manager"], "toggle", u.entity_manager.id, function(f)
		
		local format <const> = string.format
		local find <const> = string.find
		local is_an_entity <const> = entity.is_an_entity
		local is_ped_a_player <const> = ped.is_ped_a_player
		local get_entity_coords <const> = memoize.get_entity_coords
		local get_entity_model_hash <const> = entity.get_entity_model_hash
		local magnitude <const> = v3().magnitude
		local time_ms <const> = utils.time_ms
		-- Localized functions. This feature has a minor hit to fps, any micro optimization is needed.

		while f.on do
			system.yield(0)
			if parent_i ~= 0 then
				if parent_i == 1 then
					if time_ms() > player_vehicles.timer then
						player_vehicles.timer = time_ms() + 1000
						local my_ped_coords <const> = essentials.get_player_coords(player.player_id())
						for pid in essentials.players(true) do
							if player.get_player_vehicle(pid) ~= 0 then
								local Entity <const> = player.get_player_vehicle(pid)
								player_vehicles[Entity] = format("[%s]", player.get_player_name(pid))
								local parent <const> = parents_in_use[parent_i][Entity]
								if parent then
									parent.name = format("%s < %i > %s", parent.data.entity_name, magnitude(my_ped_coords, get_entity_coords(Entity)) // 1, player_vehicles[Entity])
								end
							end
						end
					end
				end
				local my_ped_coords <const> = essentials.get_player_coords(player.player_id())
				for Entity, parent in pairs(parents_in_use[parent_i]) do
					parent.on = find(parent.name, filters[parent_i]) ~= nil
					if is_an_entity(Entity) then
						if parent.on and time_ms() > (timer[Entity] or 0) then
							timer[Entity] = time_ms() + 250
							if parent_i == 1 and player_vehicles[Entity] then
								parent.name = format("%s < %i > %s", parent.data.entity_name, magnitude(my_ped_coords, get_entity_coords(Entity)) // 1, player_vehicles[Entity])
							else
								parent.name = format("%s < %i >", parent.data.entity_name, magnitude(my_ped_coords, get_entity_coords(Entity)) // 1)
							end
						end
					else
						parent.on = false
						local children <const> = parent.children
						for i = 1, #children do
							children[i].on = children[i].type == 2048
						end
						free_parents[parent_i][#free_parents[parent_i] + 1] = parent
						parents_in_use[parent_i][Entity] = nil
					end
				end
				local entities <const> = entity_getters[parent_i]()
				for i2 = 1, #entities do
					if not parents_in_use[parent_i][entities[i2]] and is_an_entity(entities[i2]) and (parent_i ~= 2 or not is_ped_a_player(entities[i2])) then
						parents_in_use[parent_i][entities[i2]] = free_parents[parent_i][#free_parents[parent_i]]
						free_parents[parent_i][#free_parents[parent_i]] = nil
						local entity_name <const> = get_names[parent_i](get_entity_model_hash(entities[i2]))
						local parent <const> = parents_in_use[parent_i][entities[i2]]
						parent.name = entity_name
						parent.data = parent.data or {}
						parent.data.entity_name = entity_name
						parent.data.entity = entities[i2]
					end
				end
			end
		end
		parent_i = 0
		player_vehicles = {timer = 0}
		for i = 1, 3 do
			for Entity, parent in pairs(parents_in_use[i]) do
				for _, child in pairs(parent.children) do
					child.on = child.type == 2048
				end
				parent.on = false
				free_parents[i][#free_parents[i] + 1] = parent
				parents_in_use[i][Entity] = nil
			end
		end
	end)
end

menu.add_player_feature(lang["Copy to clipboard"], "action_value_str", u.player_misc_features, function(f, pid)
	if essentials.is_str(f, "Rid") then
		utils.to_clipboard(tostring(player.get_player_scid(pid)))
	elseif essentials.is_str(f, "IP") then
		utils.to_clipboard(essentials.dec_to_ipv4(player.get_player_ip(pid)))
	elseif essentials.is_str(f, "Host token") then
		utils.to_clipboard(string.format("%x", player.get_player_host_token(pid)))
	elseif essentials.is_str(f, "Position") then
		local str <const> = tostring(essentials.get_player_coords(pid)):match("v3%(([%d%-%.%,%s]+)%)")
		utils.to_clipboard(str)
	elseif essentials.is_str(f, "Position without dec") then
		local pos <const> = essentials.get_player_coords(pid)
		utils.to_clipboard(string.format("%i, %i, %i", essentials.round(pos.x), essentials.round(pos.y), essentials.round(pos.z)))
	elseif essentials.is_str(f, "Vehicle hash") then
		utils.to_clipboard(tostring(entity.get_entity_model_hash(player.get_player_vehicle(pid))))
	elseif essentials.is_str(f, "Vehicle name") then
		local brand = vehicle.get_vehicle_brand(player.get_player_vehicle(pid)) or ""
		if brand ~= "" then
			brand = brand.." "
		end
		utils.to_clipboard(brand..tostring(vehicle.get_vehicle_model(player.get_player_vehicle(pid))))
	elseif essentials.is_str(f, "Ped hash") then
		utils.to_clipboard(tostring(entity.get_entity_model_hash(player.get_player_ped(pid))))
	end
end):set_str_data({
	lang["Rid"],
	lang["IP"],
	lang["Host token"],
	lang["Position"],
	lang["Position without dec"],
	lang["Vehicle hash"],
	lang["Vehicle name"],
	lang["Ped hash"]
})

do
	local function create_profile_feature(...)
		local file_name <const> = ...
		if file_name ~= essentials.get_safe_feat_name(file_name) then
			return
		end
		menu.add_feature(essentials.get_safe_feat_name(file_name):gsub("%.ini$", ""), "action_value_str", u.profiles.id, function(f)
			if essentials.is_str(f, "Load") then
				if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..f.name..".ini") then
					settings:initialize(paths.home.."scripts\\kek_menu_stuff\\profiles\\"..f.name..".ini")
					essentials.msg(string.format("%s %s.", lang["Successfully loaded"], f.name), "green", true)
				else
					essentials.msg(lang["Couldn't find file"], "red", true)
				end
			elseif essentials.is_str(f, "Save") then
				settings:save(paths.home.."scripts\\kek_menu_stuff\\profiles\\"..f.name..".ini")
				essentials.msg(string.format("%s %s.", lang["Saved"], f.name), "green", true)
			elseif essentials.is_str(f, "Delete") then
				if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..f.name..".ini") then
					io.remove(paths.kek_menu_stuff.."profiles\\"..f.name..".ini")
				end
				f.hidden = true
			elseif essentials.is_str(f, "Change name") then
				local input, status = f.name
				while true do
					input, status = keys_and_input.get_input(lang["Type in the name of the profile."], input, 128, 0)
					if status == 2 then
						return
					end
					if input:find("..", 1, true) or input:find("%.$") then
						essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
						goto skip
					end
					if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..input..".ini") then
						essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
						goto skip
					end
					if not input:find("[<>:\"/\\|%?%*]") then
						break
					else
						essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
					end
					::skip::
					system.yield(0)
				end
				essentials.rename_file(paths.kek_menu_stuff.."profiles\\", f.name, input, "ini")
				f.name = input
				essentials.msg(lang["Saved profile name."], "green", true)
			end
		end):set_str_data({
			lang["Load"],
			lang["Save"],
			lang["Delete"],
			lang["Change name"]
		})
	end

	 menu.add_feature(lang["Settings"], "action_value_str", u.profiles.id, function(f)
	 	if essentials.is_str(f, "save to default") then
			settings:save(paths.home.."scripts\\kek_menu_stuff\\keksettings.ini")
			essentials.msg(lang["Settings saved!"], "green", true)
		elseif essentials.is_str(f, "New profile") then
			local input, status
			while true do
				input, status = keys_and_input.get_input(lang["Type in the name of the profile."], input, 128, 0)
				if status == 2 then
					return
				end
				if input:find("..", 1, true) or input:find("%.$") then
					essentials.msg(lang["There can't be a \"..\" in the name. There also can't be a \".\" at the end of the name."], "red", true)
					goto skip
				end
				if utils.file_exists(paths.kek_menu_stuff.."profiles\\"..input..".ini") then
					essentials.msg(lang["Existing file found. Please choose another name."], "red", true)
					goto skip
				end
				if not input:find("[<>:\"/\\|%?%*]") then
					break
				else
					essentials.msg(lang["Illegal characters detected. Please try again. Illegal chars:"].." \"<\", \">\", \":\", \"/\", \"\\\", \"|\", \"?\", \"*\"", "red", true, 7)
				end
				::skip::
				system.yield(0)
			end
			essentials.create_empty_file(paths.kek_menu_stuff.."profiles\\"..input..".ini")
			settings:save(paths.home.."scripts\\kek_menu_stuff\\profiles\\"..input..".ini")
			create_profile_feature(input..".ini")
			essentials.msg(lang["Settings saved!"], "green", true)
		elseif essentials.is_str(f, "Reset settings to defaults") then
			local random_num = math.random(1, math.maxinteger)
			local tmp_path = paths.kek_menu_stuff.."kekMenuData\\tmp_settings_file"..random_num..".ini"
			local file = io.open(tmp_path, "w+")
			for setting_name, setting in pairs(settings.default) do
				file:write(string.format("%s=%s\n", setting_name, setting))
			end
			file:flush()
			file:close()
			settings:initialize(tmp_path)
			io.remove(tmp_path)
		end
	end):set_str_data({
		lang["save to default"],
		lang["New profile"],
		lang["Reset settings to defaults"]
	})

	for _, file_name in pairs(utils.get_all_files_in_directory(paths.kek_menu_stuff.."profiles", "ini")) do
		create_profile_feature(file_name)
	end
end

u.search_features.data = essentials.const({
	has_informed = false,
	feat_logic = function(...)
		local real_feat, fake_feat = ...
		if essentials.FEATURE_ID_MAP[fake_feat.type] == "action" then
			real_feat.on = true
		end
		if fake_feat.value then
			if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
				real_feat.on = true
				real_feat.value = fake_feat.value
				local real_value = real_feat.value
				local fake_value = fake_feat.value
				while fake_feat.on and real_feat.on do
					system.yield(0)
					if fake_feat.value ~= fake_value then
						real_feat.value = fake_feat.value
						fake_value = fake_feat.value
						real_value = fake_feat.value
					elseif real_feat.value ~= real_value then
						fake_feat.value = real_feat.value
						fake_value = real_feat.value
						real_value = real_feat.value
					end
				end
				fake_feat.on = false
				real_feat.on = false
			else
				real_feat.value = fake_feat.value
				if keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
					real_feat.on = true
				end
			end
		elseif essentials.FEATURE_ID_MAP[fake_feat.type] == "toggle" then
			real_feat.on = true
			while fake_feat.on and real_feat.on do
				system.yield(0)
			end
			real_feat.on = false
			fake_feat.on = false
		end
	end,
	player_feat_logic = function(...)
		local real_feat, 
		fake_feat,
		pid <const> = ...
		if essentials.FEATURE_ID_MAP[fake_feat.type] == "action" then
			menu.get_player_feature(real_feat.id).feats[pid].on = true
		end
		if fake_feat.value then
			if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
				menu.get_player_feature(real_feat.id).feats[pid].on = true
				menu.get_player_feature(real_feat.id).feats[pid].value = fake_feat.value
				local real_value = menu.get_player_feature(real_feat.id).feats[pid].value
				local fake_value = fake_feat.value
				while fake_feat.on and menu.get_player_feature(real_feat.id).feats[pid].on do
					system.yield(0)
					if fake_feat.value ~= fake_value then
						menu.get_player_feature(real_feat.id).feats[pid].value = fake_feat.value
						fake_value = fake_feat.value
						real_value = fake_feat.value
					elseif menu.get_player_feature(real_feat.id).feats[pid].value ~= real_value then
						fake_feat.value = menu.get_player_feature(real_feat.id).feats[pid].value
						fake_value = menu.get_player_feature(real_feat.id).feats[pid].value
						real_value = menu.get_player_feature(real_feat.id).feats[pid].value
					end
				end
				fake_feat.on = false
				menu.get_player_feature(real_feat.id).feats[pid].on = false
			else
				real_feat.value = fake_feat.value
				if keys_and_input.is_table_of_virtual_keys_all_pressed(keys_and_input.get_virtual_key_of_2take1_bind("MenuSelect")) then
					real_feat.on = true
				end
			end
		elseif essentials.FEATURE_ID_MAP[fake_feat.type] == "toggle" then
			real_feat.on = true
			while fake_feat.on and real_feat.on do
				system.yield(0)
			end
			real_feat.on = false
			fake_feat.on = false
		end
	end,
	set_feat_properties = function(...)
		local real_feat <const>,
		fake_feat,
		real_feat_player_if_relevant <const> = ...
		if fake_feat.value then
			if essentials.FEATURE_ID_MAP[fake_feat.type]:find("str", 1, true) then
				fake_feat:set_str_data((real_feat_player_if_relevant or real_feat):get_str_data())
			else
				fake_feat.min = real_feat.min
				fake_feat.max = real_feat.max
				fake_feat.mod = real_feat.mod
			end
			fake_feat.value = real_feat.value
		end
		if not essentials.FEATURE_ID_MAP[fake_feat.type]:find("action", 1, true) then
			fake_feat.on = real_feat.on
		end
	end
})

menu.add_feature(lang["Search"], "action", u.search_features.id, function()
	local input, status <const> = keys_and_input.get_input(lang["Type in name of a player or regular feature."], "", 128, 0)
	if status == 2 then
		return
	end
	input = input:lower()
	for _, fake_feat in pairs(u.search_features.children) do
		if fake_feat.data ~= "isn't searchable" then
			fake_feat.data = "isn't searchable"
			if fake_feat.type == 2048 and fake_feat.child_count > 0 then
				for _, child in pairs(fake_feat.children) do
					if child.data ~= "isn't searchable" then
						child.data = "isn't searchable"
						essentials.delete_feature(child.id)
					end
				end
			end
			essentials.delete_feature(fake_feat.id)
		end
	end
	local map <const> = essentials.const_all({
		feats = essentials.deep_copy(essentials.feats),
		player_feats = essentials.deep_copy(essentials.player_feats)
	})
	for type_of_feature, features in pairs(map) do
		for _, FEAT in pairs(features) do
			local real_feat
			if type_of_feature == "player_feats" then
				FEAT = menu.get_player_feature(FEAT)
				real_feat = FEAT.feats[0]
			else
				real_feat = FEAT
			end
			if real_feat.type ~= 2048
			and not real_feat.hidden
			and real_feat.data ~= "isn't searchable"
			and (not essentials.FEATURE_ID_MAP[real_feat.type]:find("str", 1, true) or FEAT:get_str_data())
			and real_feat.name:lower():find(input, 1, true) then
				if type_of_feature == "player_feats" then
					menu.add_feature(menu.get_player_feature(real_feat.id).feats[0].name, "parent", u.search_features.id, function(fake_feat)
						if fake_feat.child_count == 0 then
							for pid = 0, 31 do
								local feat_type = essentials.FEATURE_ID_MAP[menu.get_player_feature(real_feat.id).feats[pid].type]
								if feat_type:find("action", 1, true) and not feat_type:find("auto", 1, true) and feat_type ~= "action" then
									feat_type = "auto"..feat_type
								end
								local fake_feat = menu.add_feature(player.get_player_name(pid) or "", feat_type, fake_feat.id, function(fake_feat)
									u.search_features.data.player_feat_logic(menu.get_player_feature(real_feat.id).feats[pid], fake_feat, pid)
								end)
								fake_feat.hidden = not player.is_player_valid(pid)
								u.search_features.data.set_feat_properties(menu.get_player_feature(real_feat.id).feats[pid], fake_feat, menu.get_player_feature(real_feat.id))
							end
						else
							for pid, child in pairs(fake_feat.children) do
								child.hidden = not player.is_player_valid(pid - 1)
								if player.is_player_valid(pid - 1) then
									child.name = player.get_player_name(pid - 1)
								end
								if not essentials.FEATURE_ID_MAP[child.type]:find("action", 1, true) then
									child.on = menu.get_player_feature(real_feat.id).feats[pid - 1].on
								end
								if child.value then
									child.value = menu.get_player_feature(real_feat.id).feats[pid - 1].value
								end
							end
						end
					end)
				else
					local feat_type = essentials.FEATURE_ID_MAP[real_feat.type]
					if feat_type:find("action", 1, true) and not feat_type:find("auto", 1, true) and feat_type ~= "action" then
						feat_type = "auto"..feat_type
					end
					local fake_feat = menu.add_feature(real_feat.name, feat_type, u.search_features.id, function(fake_feat)
						u.search_features.data.feat_logic(real_feat, fake_feat)
					end)
					u.search_features.data.set_feat_properties(real_feat, fake_feat)
					fake_feat.data = real_feat
				end
			end
		end
	end
end).data = "isn't searchable"

settings:initialize(paths.home.."scripts\\kek_menu_stuff\\keksettings.ini")

essentials.listeners["exit"]["main_exit"] = event.add_event_listener("exit", function()
	kek_entity.entity_manager:update()
	for _, Entity in essentials.entities(essentials.deep_copy(kek_entity.entity_manager.entities)) do
		ui.remove_blip(ui.get_blip_from_entity(Entity))
		if network.has_control_of_entity(Entity) and not kek_entity.is_vehicle_an_attachment_to(kek_entity.get_parent_of_attachment(Entity), player.get_player_vehicle(player.player_id())) then
			if entity.is_entity_attached(Entity) then
				entity.detach_entity(Entity)
			end
			if not entity.is_entity_attached(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
				entity.set_entity_as_mission_entity(Entity, false, true)
				entity.delete_entity(Entity)
			end
		end
	end
	if player.is_player_in_any_vehicle(player.player_id()) then
		kek_entity.clear_tasks_without_leaving_vehicle(player.get_player_ped(player.player_id()), player.get_player_vehicle(player.player_id()))
	else
		ped.clear_ped_tasks_immediately(player.get_player_ped(player.player_id()))
	end
	for name, id_list in pairs(essentials.listeners) do
		for _, id in pairs(id_list) do
			event.remove_event_listener(name, id)
		end
	end
	for _, id in pairs(essentials.nethooks) do
		hook.remove_net_event_hook(id)
	end
end)

essentials.msg(lang["Successfully loaded Kek's menu."], "green", true)

end, nil)
