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

local function char_to_hex(char)
	return string.format("%%%02X", string.byte(char))
end

local function encode_url(url)
	url = url:gsub("([^%w])", char_to_hex)
	return url
end

-- "https://translate.googleapis.com/translate_a/single?client=gtx&sl="..translate_from.."&tl="..translate_to.."&dt=t&q="..encode_url(str)) ENDPOINT 1; this one provides more info, splits sentences into multiple objects.
-- "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl="..translate_from.."&tl="..translate_to.."&q="..encode_url(str) ENDPOINT 2; this one is easier to work with. If there are limits, this one is probably less likely to hit them since less data.
function language.translate_text(str, translate_from, translate_to)
	local 
		status <const>,
		str <const> = web.get("https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl="..translate_from.."&tl="..translate_to.."&q="..encode_url(str))

	if status == 200 then
		local translation, detected_language <const> = str:match("%[%[\"(.-)\",\"(.-)\"%]%]")
		translation = translation:gsub("\\n", "\n")
		translation = translation:gsub("\\r", "\r")
		translation = translation:gsub("\\\"", "\"")
		return translation, detected_language
	else
		return "REQUEST FAILED", "FAILED"
	end
end

setmetatable(language.lang, {
	__index = function(t, index)
		t[index] = index
		return index
	end
})

return language