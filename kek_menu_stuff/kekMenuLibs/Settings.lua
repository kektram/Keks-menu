-- Copyright © 2020-2021 Kektram

local settings <const> = {version = "1.0.0"}

local language <const> = require("Language")
local lang <const> = language.lang

local paths <const> = {
	home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\",
	kek_menu_stuff = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\"
}

settings.general = {}
settings.default = {}
settings.in_use = {}
settings.toggle = {}
settings.drive_style_toggles = {}
settings.valuei = {}
settings.hotkey_features = {}

function settings.add_setting(...)
	local properties <const> = ...
	settings.general[#settings.general + 1] = properties
	assert(type(properties.setting_name) == "string" and properties.setting ~= nil,
		debug.traceback("[Kek's menu]: Tried to initialize invalid default settings.", 2))
	settings.default[properties.setting_name] = properties.setting
end

function settings.save(...)
	local file_path <const> = ...
	local file = io.open(paths.home..file_path, "w+")
	for name, feat in pairs(settings.toggle) do
		settings.in_use[name] = feat.on
	end
	for name, feat in pairs(settings.valuei) do
		settings.in_use[name] = feat.value
	end
	for setting_name, _ in pairs(settings.default) do
		file:write(setting_name.."="..tostring(settings.in_use[setting_name]).."\n")
	end
	file:flush()
	file:close()
end

function settings.initialize(...)
	local file_path <const> = ...
	assert(utils.file_exists(paths.home..file_path), debug.traceback("Tried to initialize settings from a file that doesn't exist.", 2))
	local file = io.open(paths.home..file_path)
	assert(file, debug.traceback("Failed to open settings file.", 2))
	local str <const> = file:read("*a")
	file:close()
	for line in str:gmatch("([^\n]+)\n?") do
		local name <const> = line:match("^(.-)=")
		assert(name, debug.traceback("Failed to initialize setting name: "..line, 2))
		local setting = line:match("=(.+)$")
		assert(setting, debug.traceback("Failed to initialize setting value: "..line, 2))
		if tonumber(setting) and type(settings.default[name]) == "number" then
			setting = tonumber(setting)
		elseif setting == nil then
			setting = settings.default[name]
		elseif type(settings.default[name]) == "boolean" then
			setting = setting == "true"
		end
		assert(
			settings.default[name] == nil or type(setting) == type(settings.default[name]), 
			debug.traceback("Initialized setting value to wrong data type: "..line.."\nExpected type \""..type(settings.default[name]).."\", got \""..type(setting).."\".", 2)
		)
		settings.in_use[name] = setting
    end
	local file = io.open(paths.home..file_path, "w+")
	assert(io.type(file) == "file", debug.traceback("Failed to open settings file.", 2))
	for setting_name, default in pairs(settings.default) do
		if settings.in_use[setting_name] == nil then
			settings.in_use[setting_name] = default
		end
		file:write(setting_name.."="..tostring(settings.in_use[setting_name]).."\n")
	end
	file:flush()
	file:close()
    for name, feat in pairs(settings.toggle) do
    	feat.on = settings.in_use[name]
    end
    for name, feat in pairs(settings.valuei) do
    	feat.value = math.ceil(settings.in_use[name])
    end
    for _, toggle in pairs(settings.drive_style_toggles) do
    	toggle[2].on = settings.in_use["Drive style"] & toggle[1] ~= 0
    end
	for _, profile in pairs(settings.hotkey_features) do
		if settings.in_use[profile[3]] ~= "off" then
			profile[2].name = profile[1]..": "..settings.in_use[profile[3]]
		else
			profile[2].name = profile[1]..": "..lang["Turned off §"]
		end
	end
    settings.hotkey_control_keys_update = true
end

return settings