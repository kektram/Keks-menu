-- Copyright © 2020-2021 Kektram

local language <const> = {version = "1.0.0"}

local paths <const> = {
	home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\",
	kek_menu_stuff = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\"
}

do
	local file = io.open(paths.home.."scripts\\kek_menu_stuff\\kekMenuLibs\\Languages\\language.ini")
	if io.type(file) == "file" then
		language.what_language = file:read("*l") or "English.txt"
	end
	file:close()
end

if utils.file_exists(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\scripts\\kek_menu_stuff\\kekMenuLibs\\Languages\\Vehicle names\\"..language.what_language:gsub("%.txt$", ".lua")) then
	language.translated_vehicle_names = require("\\Languages\\Vehicle names\\"..language.what_language:gsub("%.txt", ""))
else
	language.translated_vehicle_names = {}
end

if not utils.file_exists(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini") then
	local file = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini", "w+")
	file:write("English.txt")
	file:flush()
	file:close()
end

language.lang = {}

if language.what_language ~= "English.txt" and utils.file_exists(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\"..language.what_language) then
	local file = io.open(paths.kek_menu_stuff.."kekMenuLibs\\Languages\\"..language.what_language)
	local str <const> = file:read("*a")
	file:close()
	for line in str:gmatch("([^\n]*)\n?") do
		local temp_entry = line:match("§(.+)")
		if temp_entry then
			temp_entry = temp_entry:gsub("%s", "")
			local str = line:match("§(.+)")
			if str then
				str = str:gsub("\\n", "\n")
				str = str:gsub("\\\\\"", "\\\"")
				language.lang[line:match("(.+)§").."§"] = str
			end
		end
	end
end

setmetatable(language.lang, {
	__index = function(t, index)
		return (index:match("(.+) §") or index):gsub("\\n", "\n")
	end
})

return language