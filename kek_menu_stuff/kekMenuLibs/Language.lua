-- Copyright © 2020-2022 Kektram

local language <const> = {version = "1.0.0"}

local paths <const> = {home = utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\"}
paths.kek_menu_stuff = paths.home.."scripts\\kek_menu_stuff\\"
paths.language_ini = paths.kek_menu_stuff.."kekMenuLibs\\Languages\\language.ini"

do
	if utils.file_exists(paths.language_ini) then
		local file <const> = io.open(paths.language_ini)
		language.what_language = file:read("*l") or "English.txt"
		file:close()
	else
		language.what_language = "English.txt"
	end
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

local function sub_unicode(str, start, End)
	return str:sub(utf8.offset(str, start), utf8.offset(str, End + 1) - 1)
end

if language.what_language ~= "English.txt" and utils.file_exists(paths.what_language) then
	local pattern <const> = string.rep("[\0-\x7F\xC2-\xFD]?[\x80-\xBF]*", 1000)
	for line in io.lines(paths.what_language) do
		local english = line:match("([^§]+)\32§") or line:match("([^§]+)§")
		if english then
			local translation = sub_unicode(line, utf8.len(english) + 3, utf8.len(line))
			local status, err = pcall(function() assert(utf8.len(translation), "Invalid translation") end)
			if not status then
				print(english, err)
				error(err)
			end
			translation = translation:gsub("\\n", "\n")
			english = english:gsub("\\n", "\n")
			language.lang[english] = translation
		end
	end
end

setmetatable(language.lang, {
	__index = function(t, index)
		t[index] = index
		return index
	end
})

return language