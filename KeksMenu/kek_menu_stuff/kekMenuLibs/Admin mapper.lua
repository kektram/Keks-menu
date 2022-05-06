-- Copyright © 2020-2022 Kektram

local admin_mapper <const> = {version = "1.0.4"}
local essentials <const> = require("Essentials")
local enums <const> = require("Enums")

local name_to_scid <const> = essentials.const_all({
	["Spacer-galore"] = 67241866,
	["RollD20"] = 89288299,
	["SecretWizzle54"] = 88439202,
	["Wawaweewa_I_Like"] = 179848415,
	["BackBoyoDrill"] = 184360405,
	["NoAuthorityHere"] = 184359255,
	["ScentedString"] = 182860908,
	["CapnZebraZorse"] = 117639172,
	["godlyGoodestBoi"] = 142582982,
	["whiskylifter"] = 115642993,
	["pigeon_nominate"] = 100641297,
	["SlightlyEvilHoss"] = 116815567,
	["ChangryMonkey"] = 88435319,
	["StompoGrande"] = 64499496,
	["x_Shannandoo_x"] = 174623946,
	["Long-boi-load"] = 174626867,
	["NootN0ot"] = 151972200,
	["applecloning"] = 115643538,
	["BeoMonstarh"] = 144372813,
	["BlobbyFett22"] = 88047835,
	["ExoSnowBoarder"] = 115670847,
	["ExtremeThanks15"] = 173426004,
	["BailMail99"] = 170727774,
	["ForrestTrump69"] = 93759254,
	["KingOfGolf"] = 174247774,
	["KrustyShackles"] = 151975489,
	["PassiveSalon"] = 146999560,
	["PearBiscuits34"] = 179930265,
	["SlowMoKing"] = 88435236,
	["Smooth_Landing"] = 179936743,
	["SuperTrevor123"] = 179848203,
	["Tamehippo"] = 151158634,
	["uwu-bend"] = 174623904,
	["VickDMF"] = 179936852,
	["AlpacaBarista"] = 117639190,
	["The_Real_Harambe"] = 93759401,
	["Flares4Lyfe"] = 103814653,
	["FluteOfMilton"] = 121970978,
	["PipPipJongles"] = 174623951,
	["YUyu-lampon"] = 174624061,
	["DeadOnAir"] = 10552062,
	["Poppernopple"] = 174625194,
	["KrunchyCh1cken"] = 174625307,
	["BlessedChu"] = 174625407,
	["Surgeio"] = 174625552,
	["WindmillDuncan"] = 174625647,
	["Paulverines"] = 138273823,
	["ZombieTom66"] = 138302559,
	["st1nky_p1nky"] = 139813495,
	["OilyLordAinsley"] = 88435916,
	["FruitPuncher15"] = 174875493,
	["PisswasserMax"] = 171094021,
	["BanSparklinWater"] = 173213117,
	["BrucieJuiceyIV"] = 171093866,
	["RapidRaichu"] = 88435362,
	["kingmario11"] = 137601710,
	["DigitalFox9"] = 103054099,
	["FoxesAreCool69"] = 104041189,
	["SweetPlumbus"] = 99453882,
	["IM-_-Wassup"] = 104432921,
	["WickedFalcon4054"] = 147604980,
	["aquabull"] = 130291558,
	["Ghostofwar1"] = 141884823,
	["DAWNBILLA"] = 131037988,
	["Aur3lian"] = 153219155,
	["JulianApost4te"] = 155527062,
	["DarkStar7171"] = 114982881,
	["xCuteBunny"] = 119266383,
	["random_123"] = 119958356,
	["random123"] = 216820,
	["flyingcobra16"] = 121397532,
	["CriticalRegret"] = 121698158,
	["ScentedPotter"] = 18965281,
	["Huginn5"] = 56778561,
	["Sonknuck-"] = 63457,
	["HammerDaddy69"] = 121943600,
	["johnet123"] = 123017343,
	["bipolarcarp"] = 123849404,
	["jakw0lf"] = 127448079,
	["Kakorot02"] = 129159629,
	["CrazyCatPilots"] = 127403483,
	["G_ashman"] = 174194059,
	["Rossthetic"] = 131973478,
	["StrongBelwas1"] = 64234321,
	["TonyMSD1"] = 62409944,
	["AMoreno14"] = 64074298,
	["PayneInUrAbs"] = 133709045,
	["shibuz_gamer123"] = 134412628,
	["M1thras"] = 137579070,
	["Th3_Morr1gan"] = 137714280,
	["Z3ro_Chill"] = 137851207,
	["Titan261"] = 130291511,
	["Coffee_Collie"] = 138075198,
	["BananaGod951"] = 137663665,
	["s0cc3r33"] = 9284553,
	["trajan5"] = 147111499,
	["thewho146"] = 6597634,
	["Bangers_RSG"] = 23659342,
	["Bash_RSG"] = 23659354,
	["Bubblez_RSG"] = 103318524,
	["ChefRSG"] = 132521200,
	["Chunk_RSG"] = 107713114,
	["HotTub_RSG"] = 107713060,
	["JPEGMAFIA_RSG"] = 23659353,
	["Klang_RSG"] = 57233573,
	["Lean1_RSG"] = 111439945,
	["Ton_RSG"] = 81691532,
	["RSGWolfman"] = 77205006,
	["TheUntamedVoid"] = 25695975,
	["TylerTGTAB"] = 24646485,
	["Wilted_spinach"] = 49770174,
	["RSGINTJoe"] = 146452200,
	["RSGGuestV"] = 54468359,
	["RSGGuest50"] = 54462116,
	["RSGGuest40"] = 53309582,
	["Logic_rsg"] = 85593421,
	["RSGGuest12"] = 21088063,
	["RSGGuest7"] = 50850475,
	["ScottM_RSG"] = 31586721,
	["Rockin5"] = 56583239,
	["playrockstar6"] = 20158753,
	["PlayRockstar5"] = 20158751,
	["PlayRockstar1"] = 23659351,
	["Player8_RSG"] = 91031119,
	["Player7_RSG"] = 91003708,
	["MaxPayneDev16"] = 16396170,
	["MaxPayneDev15"] = 16396157,
	["MaxPayneDev14"] = 16396148,
	["MaxPayneDev13"] = 16396141,
	["MaxPayneDev12"] = 16396133,
	["MaxPayneDev11"] = 16396126,
	["MaxPayneDev10"] = 16396118,
	["MaxPayneDev9"] = 16396107,
	["MaxPayneDev8"] = 16396096,
	["MaxPayneDev7"] = 16396091,
	["MaxPayneDev6"] = 16396080,
	["MaxPayneDev5"] = 16395850,
	["MaxPayneDev4"] = 16395840,
	["MaxPayneDev3"] = 16395850,
	["MaxPayneDev2"] = 16395782,
	["MaxPayneDev1"] = 16395773,
	["MaxPayne3Dev12"] = 22577458,
	["MaxPayne3Dev11"] = 22577440,
	["MaxPayne3Dev9"] = 22577121,
	["GTAdev4"] = 16395782,
	["GTAdev3"] = 20158757
})

local scid_to_name <const> = {}
for name, scid in pairs(name_to_scid) do
	scid_to_name[scid] = name
end

local admin_ips <const> = essentials.const_all({
	["NY"] = {"104.255.104.0", "104.255.104.254"},
	["NY 2"] = {"104.255.107.0", "104.255.107.254"},
	["NY 3"] = {"192.81.240.0", "192.81.240.254"},
	["NY 4"] = {"192.81.241.0", "192.81.241.254"},
	["NY 5"] = {"192.81.242.0", "192.81.242.254"},
	["NY 6"] = {"192.81.243.0", "192.81.243.254"},
	["RSGLDN - Great Britain"] = {"139.138.227.16", "139.138.227.63"},
	["RSGNYC - New York"] = {"139.138.231.0", "139.138.231.31"},
	["RSGNWE - Massachusetts"] = {"139.138.231.64", "139.138.231.79"},
	["RSGTOR - Toronto"] = {"139.138.232.0", "139.138.232.15"},
	["California"] = {"192.81.244.0", "192.81.244.254"}
})

function admin_mapper.is_ip_admin(...)
	local ip <const> = ...
	local IP <const> = ip:match("(.+%..+%..+)%.%d+")
	local range <const> = math.tointeger(ip:match(".+%..+%..+%.(%d+)"))
	for _, ip in pairs(admin_ips) do
		local base_ip <const> = ip[1]:match("(.+%..+%..+)%.%d+")
		local start_range <const> = math.tointeger(ip[1]:match(".+%..+%..+%.(%d+)"))
		local end_range <const> = math.tointeger(ip[2]:match(".+%..+%..+%.(%d+)"))
		if base_ip == IP and range >= start_range and range <= end_range then
			return ip[1]
		end
	end
end

function admin_mapper.is_scid_admin(scid)
	return scid_to_name[scid] ~= nil
end

function admin_mapper.is_name_admin(name)
	return name_to_scid[name] ~= nil
end

function admin_mapper.is_admin(pid)
	return admin_mapper.is_scid_admin(player.get_player_scid(pid))
	or admin_mapper.is_name_admin(player.get_player_name(pid))
	or admin_mapper.is_ip_admin(essentials.dec_to_ipv4(player.get_player_ip(pid)))
end

function admin_mapper.is_there_admin_in_session()
	for pid in essentials.players() do
		if admin_mapper.is_admin(pid) then
			return true
		end
	end
end

return essentials.const_all(admin_mapper)