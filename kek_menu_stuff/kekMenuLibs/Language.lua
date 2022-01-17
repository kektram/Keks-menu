-- Copyright © 2020-2021 Kektram

local language <const> = {version = "1.0.0"}

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"
paths.language_ini = paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini"

do
	local file <const> = io.open(paths.language_ini)
	if io.type(file) == "file" then
		language.what_language = file:read("*l") or "English.txt"
	end
	file:close()
	paths.what_language = paths.kek_menu_stuff.."kekMenuLibs\\Languages\\"..language.what_language	
end

if utils.file_exists(string.format("%skekMenuLibs\\Languages\\Vehicle names\\%s", paths.kek_menu_stuff, language.what_language:gsub("%.txt$", ".lua"))) then
	language.translated_vehicle_names = require("\\Languages\\Vehicle names\\"..language.what_language:gsub("%.txt", ""))
else
	language.translated_vehicle_names = {}
end

if not utils.file_exists(paths.language_ini) then
	local file = io.open(paths.language_ini, "w+")
	file:write("English.txt")
	file:flush()
	file:close()
end

language.lang = {}

if language.what_language ~= "English.txt" and utils.file_exists(paths.what_language) then
	local file = io.open(paths.what_language)
	local str <const> = file:read("*a")
	file:close()
	for english, translation in str:gmatch("([^\n§]+) §([^\n§]+)") do
		translation = translation:gsub("\\n", "\n")
		english = english:gsub("\\n", "\n")
		language.lang[english] = translation
	end
end

setmetatable(language.lang, {
	__index = function(t, index)
		t[index] = index
		return index
	end
})

return language