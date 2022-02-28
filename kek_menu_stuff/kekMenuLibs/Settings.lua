-- Copyright © 2020-2022 Kektram

local settings <const> = {version = "1.0.1"}

local language <const> = require("Language")
local lang <const> = language.lang

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"

settings.default = {}
settings.in_use = {}
settings.toggle = {}
settings.user_entity_features = {
	vehicle = {feats = {}, player_feats = {}},
	ped = {feats = {}, player_feats = {}},
	object = {feats = {}, player_feats = {}}
}
settings.drive_style_toggles = {}
settings.valuei = {}
settings.valuef = {}
settings.hotkey_features = {}

function settings:add_setting(...)
	local properties <const> = ...
	assert(type(properties.setting_name) == "string" and properties.setting ~= nil,
		debug.traceback("[Kek's menu]: Tried to initialize invalid default settings.", 2))
	self.default[properties.setting_name] = properties.setting
end

function settings:update_user_entity_feats(Type)
	local setting_name <const> = string.format("User %s", Type)
	assert(self.default[setting_name], "Invalid setting.")
	for _, feat in pairs(self.user_entity_features[Type].feats) do
		feat:set_str_data({self.in_use[setting_name]})
	end
	for _, feat_id in pairs(self.user_entity_features[Type].player_feats) do
		menu.get_player_feature(feat_id):set_str_data({self.in_use[setting_name]})
	end
end

function settings:update_user_entity(model_name, Type)
	local setting_name <const> = string.format("User %s", Type)
	assert(self.default[setting_name], "Invalid setting.")
	self.in_use[setting_name] = model_name:lower()
	settings:update_user_entity_feats(Type)
end

function settings:save(...)
	local file_path <const> = ...
	local file = io.open(file_path, "w+")
	for name, feat in pairs(self.toggle) do
		self.in_use[name] = feat.on
	end
	for name, feat in pairs(self.valuei) do
		self.in_use[name] = feat.value
	end
	for name, feat in pairs(self.valuef) do
		self.in_use[name] = feat.value
	end
	for setting_name, _ in pairs(self.default) do
		file:write(string.format("%s=%s\n", setting_name, tostring(self.in_use[setting_name])))
	end
	file:flush()
	file:close()
end

function settings:initialize(...)
	local file_path <const> = ...
	assert(utils.file_exists(file_path), debug.traceback("Tried to initialize settings from a file that doesn't exist.", 2))
	local file = io.open(file_path)
	assert(file, debug.traceback("Failed to open settings file.", 2))
	local str <const> = file:read("*a")
	file:close()
	local type <const>, tonumber <const> = type, tonumber
	for name, setting in str:gmatch("([^\n\r]+)=([^\n\r]+)") do
		local num <const> = tonumber(setting)
		local setting_type <const> = type(self.default[name])
		if setting_type == "number" then
			setting = num
		elseif setting == nil then
			setting = self.default[name]
		elseif setting_type == "boolean" then
			setting = setting == "true"
		end
		self.in_use[name] = setting
	end
	local file = io.open(file_path, "a+")
	file:setvbuf("full")
	assert(io.type(file) == "file", debug.traceback("Failed to open settings file.", 2))
	for setting_name, default in pairs(self.default) do
		if self.in_use[setting_name] == nil then
			self.in_use[setting_name] = default
			file:write(string.format("%s=%s\n", setting_name, tostring(self.in_use[setting_name])))
		end
	end
	file:close()
	for name, feat in pairs(self.toggle) do
		feat.on = self.in_use[name]
	end
	for name, feat in pairs(self.valuei) do
		feat.value = self.in_use[name]
	end
	for name, feat in pairs(self.valuef) do
		feat.value = self.in_use[name]
	end
	for _, feat in pairs(self.drive_style_toggles) do
		feat.on = self.in_use["Drive style"] & feat.data == feat.data
	end
	for _, Type in pairs({
		"vehicle",
		"ped",
		"object"
	}) do
		self:update_user_entity_feats(Type)
	end
	for _, profile in pairs(self.hotkey_features) do
		if self.in_use[profile[3]] ~= "off" then
			profile[2].name = string.format("%s: %s", profile[1], self.in_use[profile[3]])
		else
			profile[2].name = string.format("%s: %s", profile[1], lang["Turned off"])
		end
	end
	self.hotkey_control_keys_update = true
end

return settings