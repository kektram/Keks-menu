---@diagnostic disable: undefined-global
-- Copyright © 2020-2021 Kektram

kek_menu.lib_versions["Admin mapper"] = "1.0.3"

local admin_mapper <const> = {}
local essentials <const> = kek_menu.require("Essentials")
local enums <const> = kek_menu.require("Enums")

local admins <const> = table.const_all({
	["Spacer-galore"] = {67241866, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["RollD20"] = {89288299, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["SecretWizzle54"] = {88439202, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["Wawaweewa_I_Like"] = {179848415, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["BackBoyoDrill"] = {184360405, "RedDeadOnline", "Cheatermonitoring+Gamebugtesting"},
	["NoAuthorityHere"] = {184359255, "RedDeadOnline", "Cheatermonitoring+Gamebugtesting"},
	["ScentedString"] = {182860908, "RedDeadOnline", "Cheatermonitoring+Gamebugtesting"},
	["CapnZebraZorse"] = {117639172, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["godlyGoodestBoi"] = {142582982, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["whiskylifter"] = {115642993, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["pigeon_nominate"] = {100641297, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["SlightlyEvilHoss"] = {116815567, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["ChangryMonkey"] = {88435319, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["StompoGrande"] = {64499496, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["x_Shannandoo_x"] = {174623946, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["Long-boi-load"] = {174626867, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["NootN0ot"] = {151972200, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["applecloning"] = {115643538, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["BeoMonstarh"] = {144372813, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["BlobbyFett22"] = {88047835, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["ExoSnowBoarder"] = {115670847, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["ExtremeThanks15"] = {173426004, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["BailMail99"] = {170727774, "GTAOnline", "Onlinecontentdev/Gamebugtesting"},
	["ForrestTrump69"] = {93759254, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["KingOfGolf"] = {174247774, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["KrustyShackles"] = {151975489, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["PassiveSalon"] = {146999560, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["PearBiscuits34"] = {179930265, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["SlowMoKing"] = {88435236, "GTAOnline+RedDeadOnline", "Cheatermonitoring+Gamebugtesting"},
	["Smooth_Landing"] = {179936743, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["SuperTrevor123"] = {179848203, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["Tamehippo"] = {151158634, "GTAOnline+RedDeadOnline", "Cheatermonitoring+Gamebugtesting"},
	["uwu-bend"] = {174623904, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["VickDMF"] = {179936852, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["AlpacaBarista"] = {117639190, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["The_Real_Harambe"] = {93759401, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["Flares4Lyfe"] = {103814653, "GTAOnline+RedDeadOnline", "Cheatermonitoring+Gamebugtesting"},
	["FluteOfMilton"] = {121970978, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["PipPipJongles"] = {174623951, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["YUyu-lampon"] = {174624061, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["DeadOnAir"] = {10552062, "GTAOnline", "Onlinecontentdev/Gamebugtesting"},
	["Poppernopple"] = {174625194, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["KrunchyCh1cken"] = {174625307, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["BlessedChu"] = {174625407, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["Surgeio"] = {174625552, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["WindmillDuncan"] = {174625647, "GTAOnline", "Cheatermonitoring+Gamebugtesting"},
	["Paulverines"] = {138273823, "GTAOnline", "Gamebugtesting"},
	["ZombieTom66"] = {138302559, "GTAOnline", "Gamebugtesting"},
	["st1nky_p1nky"] = {139813495, "GTAOnline", "Gamebugtesting+possiblecheatermonitoring(?)"},
	["OilyLordAinsley"] = {88435916, "GTAOnline+RedDeadOnline", "Gamebugtesting+possiblecheatermonitoring(?)"},
	["FruitPuncher15"] = {174875493, "GTAOnline", "SCTVcheatermonitoring"},
	["PisswasserMax"] = {171094021, "RedDeadOnline", "SCTVcheatermonitoring"},
	["BanSparklinWater"] = {173213117, "GTAOnline+RedDeadOnline", "SCTVcheatermonitoring"},
	["BrucieJuiceyIV"] = {171093866, "RedDeadOnline", "SCTVcheatermonitoring"},
	["RapidRaichu"] = {88435362, "GTAOnline+RedDeadOnline", "Gamebugtesting"},
	["kingmario11"] = {137601710, "GTAOnline", "SCTVcheatermonitoring"},
	["DigitalFox9"] = {103054099, "GTAOnline", "Cheatanalysis"},
	["FoxesAreCool69"] = {104041189, "GTAOnline", "Cheatanalysis"},
	["SweetPlumbus"] = {99453882, "GTAOnline", "SCTVcheatermonitoring+cheatanalysis"},
	["IM-_-Wassup"] = {104432921, "GTAOnline", "SCTVcheatermonitoring"},
	["WickedFalcon4054"] = {147604980, "GTAOnline", "Gamebugtesting"},
	["aquabull"] = {130291558, "GTAOnline", "Gamebugtesting"},
	["Ghostofwar1"] = {141884823, "GTAOnline", "Gamebugtesting"},
	["DAWNBILLA"] = {131037988, "GTAOnline", "Gamebugtesting"},
	["Aur3lian"] = {153219155, "GTAOnline", "SCTVcheatermonitoring"},
	["JulianApost4te"] = {155527062, "GTAOnline", "SCTVcheatermonitoring"},
	["DarkStar7171"] = {114982881, "GTAOnline+RedDeadOnline", "Unknown"},
	["xCuteBunny"] = {119266383, "GTAOnline", "SCTVcheatermonitoring"},
	["random_123"] = {119958356, "GTAOnline", "SCTVcheatermonitoring"},
	["random123"] = {216820, "GTAOnline", "SCTVcheatermonitoring"},
	["flyingcobra16"] = {121397532, "GTAOnline", "SCTVcheatermonitoring"},
	["CriticalRegret"] = {121698158, "GTAOnline", "Cheatanalysis"},
	["ScentedPotter"] = {18965281, "GTAOnline", "Cheatanalysis"},
	["Huginn5"] = {56778561, "GTAOnline", "Cheatanalysis"},
	["Sonknuck-"] = {63457, "GTAOnline+RedDeadOnline", "Cheatanalysis"},
	["HammerDaddy69"] = {121943600, "GTAOnline", "SCTVcheatermonitoring"},
	["johnet123"] = {123017343, "GTAOnline", "Gamebugtesting"},
	["bipolarcarp"] = {123849404, "GTAOnline", "SCTVcheatermonitoring"},
	["jakw0lf"] = {127448079, "GTAOnline", "Gamebugtesting"},
	["Kakorot02"] = {129159629, "GTAOnline", "SCTVcheatermonitoring"},
	["CrazyCatPilots"] = {127403483, "GTAOnline", "Gamebugtesting"},
	["G_ashman"] = {174194059, "GTAOnline", "Gamebugtesting"},
	["Rossthetic"] = {131973478, "GTAOnline", "AltaccountofHuginn5"},
	["StrongBelwas1"] = {64234321, "GTAOnline", "TechnicalQATester"},
	["TonyMSD1"] = {62409944, "GTAOnline", "TechnicalQATester"},
	["AMoreno14"] = {64074298, "GTAOnline", "TechnicalQATester"},
	["PayneInUrAbs"] = {133709045, "GTAOnline", "SCTVcheatermonitoring"},
	["shibuz_gamer123"] = {134412628, "GTAOnline", "SCTVcheatermonitoring"},
	["M1thras"] = {137579070, "GTAOnline", "SCTVcheatermonitoring"},
	["Th3_Morr1gan"] = {137714280, "GTAOnline", "SCTVcheatermonitoring"},
	["Z3ro_Chill"] = {137851207, "GTAOnline", "SCTVcheatermonitoring"},
	["Titan261"] = {130291511, "GTAOnline", "Gamebugtesting"},
	["Coffee_Collie"] = {138075198, "GTAOnline", "Unknown"},
	["BananaGod951"] = {137663665, "GTAOnline", "SCTVcheatermonitoring"},
	["s0cc3r33"] = {9284553, "GTAOnline+RedDeadOnline", "SCTVcheatermonitoring"},
	["trajan5"] = {147111499, "GTAOnline", "SCTVcheatermonitoring"},
	["thewho146"] = {6597634, "GTAOnline", "Gamebugtesting"},
	["Bangers_RSG"] = {23659342, "GTAOnline", "Livestreams"},
	["Bash_RSG"] = {23659354, "GTAOnline", "Livestreams"},
	["Bubblez_RSG"] = {103318524, "GTAOnline", "Livestreams"},
	["ChefRSG"] = {132521200, "GTAOnline", "Unknown"},
	["Chunk_RSG"] = {107713114, "GTAOnline", "Livestreams"},
	["HotTub_RSG"] = {107713060, "GTAOnline", "Livestreams"},
	["JPEGMAFIA_RSG"] = {23659353, "GTAOnline", "Livestreams"},
	["Klang_RSG"] = {57233573, "GTAOnline", "Livestreams"},
	["Lean1_RSG"] = {111439945, "GTAOnline", "Livestreams"},
	["Ton_RSG"] = {81691532, "GTAOnline", "Livestreams"},
	["RSGWolfman"] = {77205006, "GTAOnline", "Unknown"},
	["TheUntamedVoid"] = {25695975, "GTAOnline", "Unknown"},
	["TylerTGTAB"] = {24646485, "GTAOnline", "Unknown"},
	["Wilted_spinach"] = {49770174, "None", "Unknown"},
	["RSGINTJoe"] = {146452200, "GTAOnline+RedDeadOnline", "Unknown"},
	["RSGGuestV"] = {54468359, "GTAOnline", "Unknown"},
	["RSGGuest50"] = {54462116, "GTAOnline", "Unknown"},
	["RSGGuest40"] = {53309582, "GTAOnline", "Unknown"},
	["Logic_rsg"] = {85593421, "GTAOnline", "Unknown"},
	["RSGGuest12"] = {21088063, "GTAOnline", "Unknown"},
	["RSGGuest7"] = {50850475, "GTAOnline", "Unknown"},
	["ScottM_RSG"] = {31586721, "GTAOnline", "Unknown"},
	["Rockin5"] = {56583239, "GTAOnline", "Unknown"},
	["playrockstar6"] = {20158753, "GTAOnline", "Unknown"},
	["PlayRockstar5"] = {20158751, "GTAOnline", "Unknown"},
	["PlayRockstar1"] = {23659351, "GTAOnline", "Unknown"},
	["Player8_RSG"] = {91031119, "GTAOnline", "Unknown"},
	["Player7_RSG"] = {91003708, "GTAOnline", "Unknown"},
	["MaxPayneDev16"] = {16396170, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev15"] = {16396157, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev14"] = {16396148, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev13"] = {16396141, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev12"] = {16396133, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev11"] = {16396126, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev10"] = {16396118, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev9"] = {16396107, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev8"] = {16396096, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev7"] = {16396091, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev6"] = {16396080, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev5"] = {16395850, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev4"] = {16395840, "MaxPayne3+GTAOnline+GTA4", "Coregamedev"},
	["MaxPayneDev3"] = {16395850, "MaxPayne3+GTAOnline+GTA4+RDR1", "Coregamedev"},
	["MaxPayneDev2"] = {16395782, "MaxPayne3", "Coregamedev"},
	["MaxPayneDev1"] = {16395773, "AllAAAtitlesuptoGTA5", "Coregamedev"},
	["MaxPayne3Dev12"] = {22577458, "MaxPayne3", "Coregamedev"},
	["MaxPayne3Dev11"] = {22577440, "MaxPayne3", "Coregamedev"},
	["MaxPayne3Dev9"] = {22577121, "MaxPayne3", "Coregamedev"},
	["GTAdev4"] = {16395782, "GTA5", "Coregamedev"},
	["GTAdev3"] = {20158757, "GTA5", "Coregamedev"}
})

local admin_ips <const> = table.const_all({
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

function admin_mapper.is_scid_admin(...)
	local scid <const> = ...
	for _, rid in pairs(admins) do
		if rid[1] == scid then
			return rid[1] 
		end
	end
end

function admin_mapper.is_name_admin(...)
	local Name <const> = ...
	for name, _ in pairs(admins) do
		if Name == name then
			return name 
		end
	end
end

function admin_mapper.is_admin(...)
	local Name <const>,
	scid <const>,
	ip <const> = ...
	local result = admin_mapper.is_ip_admin(ip)
	if result then
		return result
	end
	result = admin_mapper.is_scid_admin(scid)
	if result then
		return result
	end
	result = admin_mapper.is_name_admin(Name)
	if result then
		return result
	end
end

function admin_mapper.is_there_admin_in_session()
	for pid in essentials.players() do
		if admin_mapper.is_admin(player.get_player_name(pid), player.get_player_scid(pid), essentials.get_ip_in_ipv4(pid)) then
			return true
		end
	end
end

return admin_mapper