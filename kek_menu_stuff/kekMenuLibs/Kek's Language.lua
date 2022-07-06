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

do
	local unicode_escape <const> = function(unicode)
		return utf8.char(tonumber(unicode, 16))
	end
	-- "https://translate.googleapis.com/translate_a/single?client=gtx&sl="..translate_from.."&tl="..translate_to.."&dt=t&dj=1&source=input&q="..encode_url(str)) ENDPOINT 1; this one provides more info, splits sentences into multiple objects.
	-- "https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl="..translate_from.."&tl="..translate_to.."&q="..encode_url(str) ENDPOINT 2; this one is easier to work with. If there are limits, this one is probably less likely to hit them since less data. Has worse translations.
	function language.translate_text(str, translate_from, translate_to)
		str = str:gsub("[\n\r]+", "<code>0</code>")
		local
			status <const>,
			str <const> = web.get("https://translate.googleapis.com/translate_a/single?client=gtx&sl="..translate_from.."&tl="..translate_to.."&dt=t&dj=1&source=input&q="..web.urlencode(str))
		
		if status ~= 200 then
			return "REQUEST FAILED", "FAILED"
		end

		local detected_language <const> = str:match("\"src\":\"([^\"]+)\"")
		local sentences <const> = {}
		for sentence in str:gmatch("trans\":\"(.-)\",\"orig\":") do
			sentences[#sentences + 1] = sentence
		end
		local translation = table.concat(sentences)
		translation = translation:gsub("\\u(%x%x%x%x)", unicode_escape) -- THIS MUST BE DONE BEFORE BACKSLASH ESCAPE.
		translation = translation:gsub(" <code> 0 </code> ", "\n")
		translation = translation:gsub("\\(.)", "%1")
		return translation, detected_language
	end
end

setmetatable(language.lang, {
	__index = function(t, index)
		t[index] = index
		return index
	end
})

return language