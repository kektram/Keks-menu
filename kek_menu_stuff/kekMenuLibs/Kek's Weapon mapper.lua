-- Copyright © 2020-2022 Kektram

local essentials <const> = require("Kek's Essentials")
local enums <const> = require("Kek's Enums")
local weapon_mapper <const> = {version = "1.0.5"}
local weapon_attachments <const> = essentials.const_all({
	[gameplay.get_hash_key("weapon_stungun")] = {},
	[gameplay.get_hash_key("weapon_flaregun")] = {},
	[gameplay.get_hash_key("weapon_gadgetpistol")] = {},
	[gameplay.get_hash_key("weapon_navyrevolver")] = {},
	[gameplay.get_hash_key("weapon_doubleaction")] = {},
	[gameplay.get_hash_key("weapon_marksmanpistol")] = {},
	[gameplay.get_hash_key("weapon_raycarbine")] = {},
	[gameplay.get_hash_key("weapon_wrench")] = {},
	[gameplay.get_hash_key("weapon_stone_hatchet")] = {},
	[gameplay.get_hash_key("weapon_golfclub")] = {},
	[gameplay.get_hash_key("weapon_hammer")] = {},
	[gameplay.get_hash_key("weapon_nightstick")] = {},
	[gameplay.get_hash_key("weapon_crowbar")] = {},
	[gameplay.get_hash_key("weapon_flashlight")] = {},
	[gameplay.get_hash_key("weapon_dagger")] = {},
	[gameplay.get_hash_key("weapon_poolcue")] = {},
	[gameplay.get_hash_key("weapon_bat")] = {},
	[gameplay.get_hash_key("weapon_knife")] = {},
	[gameplay.get_hash_key("weapon_battleaxe")] = {},
	[gameplay.get_hash_key("weapon_machete")] = {},
	[gameplay.get_hash_key("weapon_hatchet")] = {},
	[gameplay.get_hash_key("weapon_bottle")] = {},
	[gameplay.get_hash_key("weapon_autoshotgun")] = {},
	[gameplay.get_hash_key("weapon_musket")] = {},
	[gameplay.get_hash_key("weapon_dbshotgun")] = {},
	[gameplay.get_hash_key("weapon_compactlauncher")] = {},
	[gameplay.get_hash_key("weapon_minigun")] = {},
	[gameplay.get_hash_key("weapon_hominglauncher")] = {},
	[gameplay.get_hash_key("weapon_rpg")] = {},
	[gameplay.get_hash_key("weapon_railgun")] = {},
	[gameplay.get_hash_key("weapon_firework")] = {},
	[gameplay.get_hash_key("weapon_stinger")] = {}, -- RPG 2
	[gameplay.get_hash_key("weapon_rayminigun")] = {},
	[gameplay.get_hash_key("weapon_fireextinguisher")] = {},
	[gameplay.get_hash_key("weapon_snowball")] = {},
	[gameplay.get_hash_key("weapon_ball")] = {},
	[gameplay.get_hash_key("weapon_molotov")] = {},
	[gameplay.get_hash_key("weapon_stickybomb")] = {},
	[gameplay.get_hash_key("weapon_petrolcan")] = {},
	[gameplay.get_hash_key("weapon_flare")] = {},
	[gameplay.get_hash_key("weapon_grenade")] = {},
	[gameplay.get_hash_key("weapon_bzgas")] = {},
	[gameplay.get_hash_key("weapon_proxmine")] = {},
	[gameplay.get_hash_key("weapon_pipebomb")] = {},
	[gameplay.get_hash_key("weapon_hazardcan")] = {},
	[gameplay.get_hash_key("weapon_smokegrenade")] = {},
	[gameplay.get_hash_key("weapon_stungun_mp")] = {},
	[gameplay.get_hash_key("weapon_precisionrifle")] = {},
	[gameplay.get_hash_key("weapon_tacticalrifle")] = {
		{"Grip", "COMPONENT_AT_AR_AFGRIP", gameplay.get_hash_key("COMPONENT_AT_AR_AFGRIP")},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Extended clip", "COMPONENT_TACTICALRIFLE_CLIP_02", gameplay.get_hash_key("COMPONENT_TACTICALRIFLE_CLIP_02")},
		{"Flashlight", "COMPONENT_AT_AR_FLSH_REH", gameplay.get_hash_key("COMPONENT_AT_AR_FLSH_REH")}
	},
	[gameplay.get_hash_key("weapon_heavyrifle")] = {
		{"Default Clip", "COMPONENT_HEAVYRIFLE_CLIP_01", gameplay.get_hash_key("COMPONENT_HEAVYRIFLE_CLIP_01")},
		{"Extended Clip", "COMPONENT_HEAVYRIFLE_CLIP_02", gameplay.get_hash_key("COMPONENT_HEAVYRIFLE_CLIP_02")},
		{"Iron Sights Scope", "COMPONENT_HEAVYRIFLE_SIGHT_01", gameplay.get_hash_key("COMPONENT_HEAVYRIFLE_SIGHT_01")},
		{"Scope", "COMPONENT_AT_SCOPE_MEDIUM", gameplay.get_hash_key("COMPONENT_AT_SCOPE_MEDIUM")},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", gameplay.get_hash_key("COMPONENT_AT_AR_FLSH")},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", gameplay.get_hash_key("COMPONENT_AT_AR_SUPP")},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", gameplay.get_hash_key("COMPONENT_AT_AR_AFGRIP")},
		{"Digital Camo", "COMPONENT_HEAVYRIFLE_CAMO1", gameplay.get_hash_key("COMPONENT_HEAVYRIFLE_CAMO1")}
	},
	[gameplay.get_hash_key("weapon_emplauncher")] = {
		{"COMPONENT_EMPLAUNCHER_CLIP_01", "COMPONENT_EMPLAUNCHER_CLIP_01", gameplay.get_hash_key("COMPONENT_EMPLAUNCHER_CLIP_01")}
	},
	[gameplay.get_hash_key("weapon_fertilizercan")] = {},
	[gameplay.get_hash_key("weapon_knuckle")] = {
		{"Base Model", "COMPONENT_KNUCKLE_VARMOD_BASE", 0xF3462F33},
		{"The Pimp", "COMPONENT_KNUCKLE_VARMOD_PIMP", 0xC613F685},
		{"The Ballas", "COMPONENT_KNUCKLE_VARMOD_BALLAS", 0xEED9FD63},
		{"The Hustler", "COMPONENT_KNUCKLE_VARMOD_DOLLAR", 0x50910C31},
		{"The Rock", "COMPONENT_KNUCKLE_VARMOD_DIAMOND", 0x9761D9DC},
		{"The Hater", "COMPONENT_KNUCKLE_VARMOD_HATE", 0x7DECFE30},
		{"The Lover", "COMPONENT_KNUCKLE_VARMOD_LOVE", 0x3F4E8AA6},
		{"The Player", "COMPONENT_KNUCKLE_VARMOD_PLAYER", 0x8B808BB},
		{"The King", "COMPONENT_KNUCKLE_VARMOD_KING", 0xE28BABEF},
		{"The Vagos", "COMPONENT_KNUCKLE_VARMOD_VAGOS", 0x7AF3F785}
	},
	[gameplay.get_hash_key("weapon_switchblade")] = {
		{"Default Handle", "COMPONENT_SWITCHBLADE_VARMOD_BASE", 0x9137A500},
		{"VIP Variant", "COMPONENT_SWITCHBLADE_VARMOD_VAR1", 0x5B3E7DB6},
		{"Bodyguard Variant", "COMPONENT_SWITCHBLADE_VARMOD_VAR2", 0xE7939662}
	},
	[gameplay.get_hash_key("weapon_pistol")] = {
		{"Default Clip", "COMPONENT_PISTOL_CLIP_01", 0xFED0FD71},
		{"Extended Clip", "COMPONENT_PISTOL_CLIP_02", 0xED265A1C},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP_02", 0x65EA7EBB},
		{"Yusuf Amir Luxury Finish", "COMPONENT_PISTOL_VARMOD_LUXE", 0xD7391086}
	},
	[gameplay.get_hash_key("weapon_combatpistol")]= {
		{"Default Clip", "COMPONENT_COMBATPISTOL_CLIP_01", 0x721B079},
		{"Extended Clip", "COMPONENT_COMBATPISTOL_CLIP_02", 0xD67B4F2D},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A},
		{"Yusuf Amir Luxury Finish", "COMPONENT_COMBATPISTOL_VARMOD_LOWRIDER", 0xC6654D72}
	},
	[gameplay.get_hash_key("weapon_appistol")]= {
		{"Default Clip", "COMPONENT_APPISTOL_CLIP_01", 0x31C4B22A},
		{"Extended Clip", "COMPONENT_APPISTOL_CLIP_02", 0x249A17D5},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A},
		{"Gilded Gun Metal Finish", "COMPONENT_APPISTOL_VARMOD_LUXE", 0x9B76C72C}
	},
	[gameplay.get_hash_key("weapon_pistol50")]= {
		{"Default Clip", "COMPONENT_PISTOL50_CLIP_01", 0x2297BE19},
		{"Extended Clip", "COMPONENT_PISTOL50_CLIP_02", 0xD9D3AC92},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Platinum Pearl Deluxe Finish", "COMPONENT_PISTOL50_VARMOD_LUXE", 0x77B8AB2F}
	},
	[gameplay.get_hash_key("weapon_revolver")]= {
		{"VIP Variant", "COMPONENT_REVOLVER_VARMOD_BOSS", 0x16EE3040},
		{"Bodyguard Variant", "COMPONENT_REVOLVER_VARMOD_GOON", 0x9493B80D},
		{"Default Clip", "COMPONENT_REVOLVER_CLIP_01", 0xE9867CE3}
	},
	[gameplay.get_hash_key("weapon_snspistol")]= {
		{"Default Clip", "COMPONENT_SNSPISTOL_CLIP_01", 0xF8802ED9},
		{"Extended Clip", "COMPONENT_SNSPISTOL_CLIP_02", 0x7B0033B3},
		{"Etched Wood Grip Finish", "COMPONENT_SNSPISTOL_VARMOD_LOWRIDER", 0x8033ECAF}
	},
	[gameplay.get_hash_key("weapon_heavypistol")]= {
		{"Default Clip", "COMPONENT_HEAVYPISTOL_CLIP_01", 0xD4A969A},
		{"Extended Clip", "COMPONENT_HEAVYPISTOL_CLIP_02", 0x64F9C62B},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A},
		{"Etched Wood Grip Finish", "COMPONENT_HEAVYPISTOL_VARMOD_LUXE", 0x7A6A7B7B}
	},
	[gameplay.get_hash_key("weapon_revolver_mk2")]= {
		{"Default Rounds", "COMPONENT_REVOLVER_MK2_CLIP_01", 0xBA23D8BE},
		{"Tracer Rounds", "COMPONENT_REVOLVER_MK2_CLIP_TRACER", 0xC6D8E476},
		{"Incendiary Rounds", "COMPONENT_REVOLVER_MK2_CLIP_INCENDIARY", 0xEFBF25},
		{"Hollow Point Rounds", "COMPONENT_REVOLVER_MK2_CLIP_HOLLOWPOINT", 0x10F42E8F},
		{"Full Metal Jacket Rounds", "COMPONENT_REVOLVER_MK2_CLIP_FMJ", 0xDC8BA3F},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_MK2", 0x49B2945},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Compensator", "COMPONENT_AT_PI_COMP_03", 0x27077CCB},
		{"Digital Camo", "COMPONENT_REVOLVER_MK2_CAMO", 0xC03FED9F},
		{"Brushstroke Camo", "COMPONENT_REVOLVER_MK2_CAMO_02", 0xB5DE24},
		{"Woodland Camo", "COMPONENT_REVOLVER_MK2_CAMO_03", 0xA7FF1B8},
		{"Skull", "COMPONENT_REVOLVER_MK2_CAMO_04", 0xF2E24289},
		{"Sessanta Nove", "COMPONENT_REVOLVER_MK2_CAMO_05", 0x11317F27},
		{"Perseus", "COMPONENT_REVOLVER_MK2_CAMO_06", 0x17C30C42},
		{"Leopard", "COMPONENT_REVOLVER_MK2_CAMO_07", 0x257927AE},
		{"Zebra", "COMPONENT_REVOLVER_MK2_CAMO_08", 0x37304B1C},
		{"Geometric", "COMPONENT_REVOLVER_MK2_CAMO_09", 0x48DAEE71},
		{"Boom!", "COMPONENT_REVOLVER_MK2_CAMO_10", 0x20ED9B5B},
		{"Patriotic", "COMPONENT_REVOLVER_MK2_CAMO_IND_01", 0xD951E867}
	},
	[gameplay.get_hash_key("weapon_snspistol_mk2")]= {
		{"Default Clip", "COMPONENT_SNSPISTOL_MK2_CLIP_01", 0x1466CE6},
		{"Extended Clip", "COMPONENT_SNSPISTOL_MK2_CLIP_02", 0xCE8C0772},
		{"Tracer Rounds", "COMPONENT_SNSPISTOL_MK2_CLIP_TRACER", 0x902DA26E},
		{"Incendiary Rounds", "COMPONENT_SNSPISTOL_MK2_CLIP_INCENDIARY", 0xE6AD5F79},
		{"Hollow Point Rounds", "COMPONENT_SNSPISTOL_MK2_CLIP_HOLLOWPOINT", 0x8D107402},
		{"Full Metal Jacket Rounds", "COMPONENT_SNSPISTOL_MK2_CLIP_FMJ", 0xC111EB26},
		{"Flashlight", "COMPONENT_AT_PI_FLSH_03", 0x4A4965F3},
		{"Mounted Scope", "COMPONENT_AT_PI_RAIL_02", 0x47DE9258},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP_02", 0x65EA7EBB},
		{"Compensator", "COMPONENT_AT_PI_COMP_02", 0xAA8283BF},
		{"Digital Camo", "COMPONENT_SNSPISTOL_MK2_CAMO", 0xF7BEEDD},
		{"Brushstroke Camo", "COMPONENT_SNSPISTOL_MK2_CAMO_02", 0x8A612EF6},
		{"Woodland Camo", "COMPONENT_SNSPISTOL_MK2_CAMO_03", 0x76FA8829},
		{"Skull", "COMPONENT_SNSPISTOL_MK2_CAMO_04", 0xA93C6CAC},
		{"Sessanta Nove", "COMPONENT_SNSPISTOL_MK2_CAMO_05", 0x9C905354},
		{"Perseus", "COMPONENT_SNSPISTOL_MK2_CAMO_06", 0x4DFA3621},
		{"Leopard", "COMPONENT_SNSPISTOL_MK2_CAMO_07", 0x42E91FFF},
		{"Zebra", "COMPONENT_SNSPISTOL_MK2_CAMO_08", 0x54A8437D},
		{"Geometric", "COMPONENT_SNSPISTOL_MK2_CAMO_09", 0x68C2746},
		{"Boom!", "COMPONENT_SNSPISTOL_MK2_CAMO_10", 0x2366E467},
		{"Boom!", "COMPONENT_SNSPISTOL_MK2_CAMO_IND_01", 0x441882E6},
		{"Digital Camo", "COMPONENT_SNSPISTOL_MK2_CAMO_SLIDE", 0xE7EE68EA},
		{"Brushstroke Camo", "COMPONENT_SNSPISTOL_MK2_CAMO_02_SLIDE", 0x29366D21},
		{"Woodland Camo", "COMPONENT_SNSPISTOL_MK2_CAMO_03_SLIDE", 0x3ADE514B},
		{"Skull", "COMPONENT_SNSPISTOL_MK2_CAMO_04_SLIDE", 0xE64513E9},
		{"Sessanta Nove", "COMPONENT_SNSPISTOL_MK2_CAMO_05_SLIDE", 0xCD7AEB9A},
		{"Perseus", "COMPONENT_SNSPISTOL_MK2_CAMO_06_SLIDE", 0xFA7B27A6},
		{"Leopard", "COMPONENT_SNSPISTOL_MK2_CAMO_07_SLIDE", 0xE285CA9A},
		{"Zebra", "COMPONENT_SNSPISTOL_MK2_CAMO_08_SLIDE", 0x2B904B19},
		{"Geometric", "COMPONENT_SNSPISTOL_MK2_CAMO_09_SLIDE", 0x22C24F9C},
		{"Boom!", "COMPONENT_SNSPISTOL_MK2_CAMO_10_SLIDE", 0x8D0D5ECD},
		{"Patriotic", "COMPONENT_SNSPISTOL_MK2_CAMO_IND_01_SLIDE", 0x1F07150A}
	},
	[gameplay.get_hash_key("weapon_pistol_mk2")]= {
		{"Default Clip", "COMPONENT_PISTOL_MK2_CLIP_01", 0x94F42D62},
		{"Extended Clip", "COMPONENT_PISTOL_MK2_CLIP_02", 0x5ED6C128},
		{"Tracer Rounds", "COMPONENT_PISTOL_MK2_CLIP_TRACER", 0x25CAAEAF},
		{"Incendiary Rounds", "COMPONENT_PISTOL_MK2_CLIP_INCENDIARY", 0x2BBD7A3A},
		{"Hollow Point Rounds", "COMPONENT_PISTOL_MK2_CLIP_HOLLOWPOINT", 0x85FEA109},
		{"Full Metal Jacket Rounds", "COMPONENT_PISTOL_MK2_CLIP_FMJ", 0x4F37DF2A},
		{"Mounted Scope", "COMPONENT_AT_PI_RAIL", 0x8ED4BB70},
		{"Flashlight", "COMPONENT_AT_PI_FLSH_02", 0x43FD595B},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP_02", 0x65EA7EBB},
		{"Compensator", "COMPONENT_AT_PI_COMP", 0x21E34793},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO", 0x5C6C749C},
		{"Brushstroke Camo", "COMPONENT_PISTOL_MK2_CAMO_02", 0x15F7A390},
		{"Woodland Camo", "COMPONENT_PISTOL_MK2_CAMO_03", 0x968E24DB},
		{"Skull", "COMPONENT_PISTOL_MK2_CAMO_04", 0x17BFA99},
		{"Sessanta Nove", "COMPONENT_PISTOL_MK2_CAMO_05", 0xF2685C72},
		{"Perseus", "COMPONENT_PISTOL_MK2_CAMO_06", 0xDD2231E6},
		{"Leopard", "COMPONENT_PISTOL_MK2_CAMO_07", 0xBB43EE76},
		{"Zebra", "COMPONENT_PISTOL_MK2_CAMO_08", 0x4D901310},
		{"Geometric", "COMPONENT_PISTOL_MK2_CAMO_09", 0x5F31B653},
		{"Boom!", "COMPONENT_PISTOL_MK2_CAMO_10", 0x697E19A0},
		{"Patriotic", "COMPONENT_PISTOL_MK2_CAMO_IND_01", 0x930CB951},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_SLIDE", 0xB4FC92B0},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_02_SLIDE", 0x1A1F1260},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_03_SLIDE", 0xE4E00B70},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_04_SLIDE", 0x2C298B2B},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_05_SLIDE", 0xDFB79725},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_06_SLIDE", 0x6BD7228C},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_07_SLIDE", 0x9DDBCF8C},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_08_SLIDE", 0xB319A52C},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_09_SLIDE", 0xC6836E12},
		{"Digital Camo", "COMPONENT_PISTOL_MK2_CAMO_10_SLIDE", 0x43B1B173},
		{"Patriotic", "COMPONENT_PISTOL_MK2_CAMO_IND_01_SLIDE", 0x4ABDA3FA}
	},
	[gameplay.get_hash_key("weapon_vintagepistol")]= {
		{"Default Clip", "COMPONENT_VINTAGEPISTOL_CLIP_01", 0x45A3B6BB},
		{"Extended Clip", "COMPONENT_VINTAGEPISTOL_CLIP_02", 0x33BA12E8},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A}
	},
	[gameplay.get_hash_key("weapon_raypistol")]= {
		{"Festive tint", "COMPONENT_RAYPISTOL_VARMOD_XMAS18", 0xD7DBF707}
	},
	[gameplay.get_hash_key("weapon_ceramicpistol")]= {
		{"Default Clip", "COMPONENT_CERAMICPISTOL_CLIP_01", 0x54D41361},
		{"Extended Clip", "COMPONENT_CERAMICPISTOL_CLIP_02", 0x81786CA9},
		{"Suppressor Muzzle Brake", "COMPONENT_CERAMICPISTOL_SUPP", 0x9307D6FA}
	},
	[gameplay.get_hash_key("weapon_microsmg")]= {
		{"Default Clip", "COMPONENT_MICROSMG_CLIP_01", 0xCB48AEF0},
		{"Extended Clip", "COMPONENT_MICROSMG_CLIP_02", 0x10E6BA2B},
		{"Flashlight", "COMPONENT_AT_PI_FLSH", 0x359B7AAE},
		{"Scope", "COMPONENT_AT_SCOPE_MACRO", 0x9D2FBF29},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Yusuf Amir Luxury Finish", "COMPONENT_MICROSMG_VARMOD_LUXE", 0x487AAE09}
	},
	[gameplay.get_hash_key("weapon_smg")]= {
		{"Default Clip", "COMPONENT_SMG_CLIP_01", 0x26574997},
		{"Extended Clip", "COMPONENT_SMG_CLIP_02", 0x350966FB},
		{"Drum Magazine", "COMPONENT_SMG_CLIP_03", 0x79C77076},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_MACRO_02", 0x3CC6BA57},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A},
		{"Yusuf Amir Luxury Finish", "COMPONENT_SMG_VARMOD_LUXE", 0x27872C90}
	},
	[gameplay.get_hash_key("weapon_assaultsmg")]= {
		{"Default Clip", "COMPONENT_ASSAULTSMG_CLIP_01", 0x8D1307B0},
		{"Extended Clip", "COMPONENT_ASSAULTSMG_CLIP_02", 0xBB46E417},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_MACRO", 0x9D2FBF29},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Yusuf Amir Luxury Finish", "COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER", 0x278C78AF}
	},
	[gameplay.get_hash_key("weapon_minismg")]= {
		{"Default Clip", "COMPONENT_MINISMG_CLIP_01", 0x84C8B2D3},
		{"Extended Clip", "COMPONENT_MINISMG_CLIP_02", 0x937ED0B7}
	},
	[gameplay.get_hash_key("weapon_smg_mk2")]= {
		{"Default Clip", "COMPONENT_SMG_MK2_CLIP_01", 0x4C24806E},
		{"Extended Clip", "COMPONENT_SMG_MK2_CLIP_02", 0xB9835B2E},
		{"Tracer Rounds", "COMPONENT_SMG_MK2_CLIP_TRACER", 0x7FEA36EC},
		{"Incendiary Rounds", "COMPONENT_SMG_MK2_CLIP_INCENDIARY", 0xD99222E5},
		{"Hollow Point Rounds", "COMPONENT_SMG_MK2_CLIP_HOLLOWPOINT", 0x3A1BD6FA},
		{"Full Metal Jacket Rounds", "COMPONENT_SMG_MK2_CLIP_FMJ", 0xB5A715F},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS_SMG", 0x9FDB5652},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2", 0xE502AB6B},
		{"Medium Scope", "COMPONENT_AT_SCOPE_SMALL_SMG_MK2", 0x3DECC7DA},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Default Barrel", "COMPONENT_AT_SB_BARREL_01", 0xD9103EE1},
		{"Heavy Barrel", "COMPONENT_AT_SB_BARREL_02", 0xA564D78B},
		{"Digital Camo", "COMPONENT_SMG_MK2_CAMO", 0xC4979067},
		{"Brushstroke Camo", "COMPONENT_SMG_MK2_CAMO_02", 0x3815A945},
		{"Woodland Camo", "COMPONENT_SMG_MK2_CAMO_03", 0x4B4B4FB0},
		{"Skull", "COMPONENT_SMG_MK2_CAMO_04", 0xEC729200},
		{"Sessanta Nove", "COMPONENT_SMG_MK2_CAMO_05", 0x48F64B22},
		{"Perseus", "COMPONENT_SMG_MK2_CAMO_06", 0x35992468},
		{"Leopard", "COMPONENT_SMG_MK2_CAMO_07", 0x24B782A5},
		{"Zebra", "COMPONENT_SMG_MK2_CAMO_08", 0xA2E67F01},
		{"Geometric", "COMPONENT_SMG_MK2_CAMO_09", 0x2218FD68},
		{"Boom!", "COMPONENT_SMG_MK2_CAMO_10", 0x45C5C3C5},
		{"Patriotic", "COMPONENT_SMG_MK2_CAMO_IND_01", 0x399D558F}
	},
	[gameplay.get_hash_key("weapon_machinepistol")]= {
		{"Default Clip", "COMPONENT_MACHINEPISTOL_CLIP_01", 0x476E85FF},
		{"Extended Clip", "COMPONENT_MACHINEPISTOL_CLIP_02", 0xB92C6979},
		{"Drum Magazine", "COMPONENT_MACHINEPISTOL_CLIP_03", 0xA9E9CAF4},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_PI_SUPP", 0xC304849A}
	},
	[gameplay.get_hash_key("weapon_combatpdw")]= {
		{"Default Clip", "COMPONENT_COMBATPDW_CLIP_01", 0x4317F19E},
		{"Extended Clip", "COMPONENT_COMBATPDW_CLIP_02", 0x334A5203},
		{"Drum Magazine", "COMPONENT_COMBATPDW_CLIP_03", 0x6EB8C8DB},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL", 0xAA2C45B4}
	},
	[gameplay.get_hash_key("weapon_pumpshotgun")]= {
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_SR_SUPP", 0xE608B35E},
		{"Yusuf Amir Luxury Finish", "COMPONENT_PUMPSHOTGUN_VARMOD_LOWRIDER", 0xA2D79DDB}
	},
	[gameplay.get_hash_key("weapon_sawnoffshotgun")]= {
		{"Gilded Gun Metal Finish", "COMPONENT_SAWNOFFSHOTGUN_VARMOD_LUXE", 0x85A64DF9}
	},
	[gameplay.get_hash_key("weapon_assaultshotgun")] = {
		{"Default Clip", "COMPONENT_ASSAULTSHOTGUN_CLIP_01", 0x94E81BC7},
		{"Extended Clip", "COMPONENT_ASSAULTSHOTGUN_CLIP_02", 0x86BD7F72},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53}
	},
	[gameplay.get_hash_key("weapon_bullpupshotgun")] = {
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53}
	},
	[gameplay.get_hash_key("weapon_pumpshotgun_mk2")] = {
		{"Default Rounds", "COMPONENT_PUMPSHOTGUN_MK2_CLIP_01", 0xCD940141},
		{"Dragon's Breath Rounds", "COMPONENT_PUMPSHOTGUN_MK2_CLIP_INCENDIARY", 0x9F8A1BF5},
		{"Steel Buckshot Rounds", "COMPONENT_PUMPSHOTGUN_MK2_CLIP_ARMORPIERCING", 0x4E65B425},
		{"Flechette Rounds", "COMPONENT_PUMPSHOTGUN_MK2_CLIP_HOLLOWPOINT", 0xE9582927},
		{"Explosive Rounds", "COMPONENT_PUMPSHOTGUN_MK2_CLIP_EXPLOSIVE", 0x3BE4465D},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_MK2", 0x49B2945},
		{"Medium Scope", "COMPONENT_AT_SCOPE_SMALL_MK2", 0x3F3C8181},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_SR_SUPP_03", 0xAC42DF71},
		{"Squared Muzzle Brake", "COMPONENT_AT_MUZZLE_08", 0x5F7DCE4D},
		{"Digital Camo", "COMPONENT_PUMPSHOTGUN_MK2_CAMO", 0xE3BD9E44},
		{"Brushstroke Camo", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_02", 0x17148F9B},
		{"Woodland Camo", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_03", 0x24D22B16},
		{"Skull", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_04", 0xF2BEC6F0},
		{"Sessanta Nove", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_05", 0x85627D},
		{"Perseus", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_06", 0xDC2919C5},
		{"Leopard", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_07", 0xE184247B},
		{"Zebra", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_08", 0xD8EF9356},
		{"Geometric", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_09", 0xEF29BFCA},
		{"Boom!", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_10", 0x67AEB165},
		{"Patriotic", "COMPONENT_PUMPSHOTGUN_MK2_CAMO_IND_01", 0x46411A1D}
	},
	[gameplay.get_hash_key("weapon_heavyshotgun")] = {
		{"Default Clip", "COMPONENT_HEAVYSHOTGUN_CLIP_01", 0x324F2D5F},
		{"Extended Clip", "COMPONENT_HEAVYSHOTGUN_CLIP_02", 0x971CF6FD},
		{"Drum Magazine", "COMPONENT_HEAVYSHOTGUN_CLIP_03", 0x88C7DA53},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53}
	},
	[gameplay.get_hash_key("weapon_combatshotgun")] = {
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA}
	},
	[gameplay.get_hash_key("weapon_assaultrifle")] = {
		{"Default Clip", "COMPONENT_ASSAULTRIFLE_CLIP_01", 0xBE5EEA16},
		{"Extended Clip", "COMPONENT_ASSAULTRIFLE_CLIP_02", 0xB1214F9B},
		{"Drum Magazine", "COMPONENT_ASSAULTRIFLE_CLIP_03", 0xDBF0A53D},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_MACRO", 0x9D2FBF29},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Yusuf Amir Luxury Finish", "COMPONENT_ASSAULTRIFLE_VARMOD_LUXE", 0x4EAD7533}
	},
	[gameplay.get_hash_key("weapon_carbinerifle")] = {
		{"Default Clip", "COMPONENT_CARBINERIFLE_CLIP_01", 0x9FBE33EC},
		{"Extended Clip", "COMPONENT_CARBINERIFLE_CLIP_02", 0x91109691},
		{"Box Magazine", "COMPONENT_CARBINERIFLE_CLIP_03", 0xBA62E935},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_MEDIUM", 0xA0D89C42},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Yusuf Amir Luxury Finish", "COMPONENT_CARBINERIFLE_VARMOD_LUXE", 0xD89B9658}
	},
	[gameplay.get_hash_key("weapon_advancedrifle")] = {
		{"Default Clip", "COMPONENT_ADVANCEDRIFLE_CLIP_01", 0xFA8FA10F},
		{"Extended Clip", "COMPONENT_ADVANCEDRIFLE_CLIP_02", 0x8EC1C979},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL", 0xAA2C45B4},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Gilded Gun Metal Finish", "COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE", 0x377CD377}
	},
	[gameplay.get_hash_key("weapon_specialcarbine")] = {
		{"Default Clip", "COMPONENT_SPECIALCARBINE_CLIP_01", 0xC6C7E581},
		{"Extended Clip", "COMPONENT_SPECIALCARBINE_CLIP_02", 0x7C8BD10E},
		{"Drum Magazine", "COMPONENT_SPECIALCARBINE_CLIP_03", 0x6B59AEAA},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_MEDIUM", 0xA0D89C42},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Etched Gun Metal Finish", "COMPONENT_SPECIALCARBINE_VARMOD_LOWRIDER", 0x730154F2}
	},
	[gameplay.get_hash_key("weapon_bullpuprifle")] = {
		{"Default Clip", "COMPONENT_BULLPUPRIFLE_CLIP_01", 0xC5A12F80},
		{"Extended Clip", "COMPONENT_BULLPUPRIFLE_CLIP_02", 0xB3688B0F},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL", 0xAA2C45B4},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Gilded Gun Metal Finish", "COMPONENT_BULLPUPRIFLE_VARMOD_LOW", 0xA857BC78}
	},
	[gameplay.get_hash_key("weapon_bullpuprifle_mk2")] = {
		{"Default Clip", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_01", 0x18929DA},
		{"Extended Clip", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02", 0xEFB00628},
		{"Tracer Rounds", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER", 0x822060A9},
		{"Incendiary Rounds", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_INCENDIARY", 0xA99CF95A},
		{"Armor Piercing Rounds", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_ARMORPIERCING", 0xFAA7F5ED},
		{"Full Metal Jacket Rounds", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_FMJ", 0x43621710},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_02_MK2", 0xC7ADD105},
		{"Medium Scope", "COMPONENT_AT_SCOPE_SMALL_MK2", 0x3F3C8181},
		{"Default Barrel", "COMPONENT_AT_BP_BARREL_01", 0x659AC11B},
		{"Heavy Barrel", "COMPONENT_AT_BP_BARREL_02", 0x3BF26DC7},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Grip", "COMPONENT_AT_AR_AFGRIP_02", 0x9D65907A},
		{"Digital Camo", "COMPONENT_BULLPUPRIFLE_MK2_CAMO", 0xAE4055B7},
		{"Brushstroke Camo", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_02", 0xB905ED6B},
		{"Woodland Camo", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_03", 0xA6C448E8},
		{"Skull", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_04", 0x9486246C},
		{"Sessanta Nove", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_05", 0x8A390FD2},
		{"Perseus", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_06", 0x2337FC5},
		{"Leopard", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_07", 0xEFFFDB5E},
		{"Zebra", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_08", 0xDDBDB6DA},
		{"Geometric", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_09", 0xCB631225},
		{"Boom!", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_10", 0xA87D541E},
		{"Patriotic", "COMPONENT_BULLPUPRIFLE_MK2_CAMO_IND_01", 0xC5E9AE52}
	},
	[gameplay.get_hash_key("weapon_specialcarbine_mk2")] = {
		{"Default Clip", "COMPONENT_SPECIALCARBINE_MK2_CLIP_01", 0x16C69281},
		{"Extended Clip", "COMPONENT_SPECIALCARBINE_MK2_CLIP_02", 0xDE1FA12C},
		{"Tracer Rounds", "COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER", 0x8765C68A},
		{"Incendiary Rounds", "COMPONENT_SPECIALCARBINE_MK2_CLIP_INCENDIARY", 0xDE011286},
		{"Armor Piercing Rounds", "COMPONENT_SPECIALCARBINE_MK2_CLIP_ARMORPIERCING", 0x51351635},
		{"Full Metal Jacket Rounds", "COMPONENT_SPECIALCARBINE_MK2_CLIP_FMJ", 0x503DEA90},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_MK2", 0x49B2945},
		{"Large Scope", "COMPONENT_AT_SCOPE_MEDIUM_MK2", 0xC66B6542},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Grip", "COMPONENT_AT_AR_AFGRIP_02", 0x9D65907A},
		{"Default Barrel", "COMPONENT_AT_SC_BARREL_01", 0xE73653A9},
		{"Heavy Barrel", "COMPONENT_AT_SC_BARREL_02", 0xF97F783B},
		{"Digital Camo", "COMPONENT_SPECIALCARBINE_MK2_CAMO", 0xD40BB53B},
		{"Brushstroke Camo", "COMPONENT_SPECIALCARBINE_MK2_CAMO_02", 0x431B238B},
		{"Woodland Camo", "COMPONENT_SPECIALCARBINE_MK2_CAMO_03", 0x34CF86F4},
		{"Skull", "COMPONENT_SPECIALCARBINE_MK2_CAMO_04", 0xB4C306DD},
		{"Sessanta Nove", "COMPONENT_SPECIALCARBINE_MK2_CAMO_05", 0xEE677A25},
		{"Perseus", "COMPONENT_SPECIALCARBINE_MK2_CAMO_06", 0xDF90DC78},
		{"Leopard", "COMPONENT_SPECIALCARBINE_MK2_CAMO_07", 0xA4C31EE},
		{"Zebra", "COMPONENT_SPECIALCARBINE_MK2_CAMO_08", 0x89CFB0F7},
		{"Geometric", "COMPONENT_SPECIALCARBINE_MK2_CAMO_09", 0x7B82145C},
		{"Boom!", "COMPONENT_SPECIALCARBINE_MK2_CAMO_10", 0x899CAF75},
		{"Patriotic", "COMPONENT_SPECIALCARBINE_MK2_CAMO_IND_01", 0x5218C819}
	},
	[gameplay.get_hash_key("weapon_assaultrifle_mk2")] = {
		{"Default Clip", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_01", 0x8610343F},
		{"Extended Clip", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02", 0xD12ACA6F},
		{"Tracer Rounds", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER", 0xEF2C78C1},
		{"Incendiary Rounds", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_INCENDIARY", 0xFB70D853},
		{"Armor Piercing Rounds", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_ARMORPIERCING", 0xA7DD1E58},
		{"Full Metal Jacket Rounds", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_FMJ", 0x63E0A098},
		{"Grip", "COMPONENT_AT_AR_AFGRIP_02", 0x9D65907A},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_MK2", 0x49B2945},
		{"Large Scope", "COMPONENT_AT_SCOPE_MEDIUM_MK2", 0xC66B6542},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Default Barrel", "COMPONENT_AT_AR_BARREL_01", 0x43A49D26},
		{"Heavy Barrel", "COMPONENT_AT_AR_BARREL_02", 0x5646C26A},
		{"Digital Camo", "COMPONENT_ASSAULTRIFLE_MK2_CAMO", 0x911B24AF},
		{"Brushstroke Camo", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_02", 0x37E5444B},
		{"Woodland Camo", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_03", 0x538B7B97},
		{"Skull", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_04", 0x25789F72},
		{"Sessanta Nove", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_05", 0xC5495F2D},
		{"Perseus", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_06", 0xCF8B73B1},
		{"Leopard", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_07", 0xA9BB2811},
		{"Zebra", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_08", 0xFC674D54},
		{"Geometric", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_09", 0x7C7FCD9B},
		{"Boom!", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_10", 0xA5C38392},
		{"Patriotic", "COMPONENT_ASSAULTRIFLE_MK2_CAMO_IND_01", 0xB9B15DB0}
	},
	[gameplay.get_hash_key("weapon_carbinerifle_mk2")] = {
		{"Default Clip", "COMPONENT_CARBINERIFLE_MK2_CLIP_01", 0x4C7A391E},
		{"Extended Clip", "COMPONENT_CARBINERIFLE_MK2_CLIP_02", 0x5DD5DBD5},
		{"Tracer Rounds", "COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER", 0x1757F566},
		{"Incendiary Rounds", "COMPONENT_CARBINERIFLE_MK2_CLIP_INCENDIARY", 0x3D25C2A7},
		{"Armor Piercing Rounds", "COMPONENT_CARBINERIFLE_MK2_CLIP_ARMORPIERCING", 0x255D5D57},
		{"Full Metal Jacket Rounds", "COMPONENT_CARBINERIFLE_MK2_CLIP_FMJ", 0x44032F11},
		{"Grip", "COMPONENT_AT_AR_AFGRIP_02", 0x9D65907A},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Small Scope", "COMPONENT_AT_SCOPE_MACRO_MK2", 0x49B2945},
		{"Large Scope", "COMPONENT_AT_SCOPE_MEDIUM_MK2", 0xC66B6542},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Default Barrel", "COMPONENT_AT_CR_BARREL_01", 0x833637FF},
		{"Heavy Barrel", "COMPONENT_AT_CR_BARREL_02", 0x8B3C480B},
		{"Digital Camo", "COMPONENT_CARBINERIFLE_MK2_CAMO", 0x4BDD6F16},
		{"Brushstroke Camo", "COMPONENT_CARBINERIFLE_MK2_CAMO_02", 0x406A7908},
		{"Woodland Camo", "COMPONENT_CARBINERIFLE_MK2_CAMO_03", 0x2F3856A4},
		{"Skull", "COMPONENT_CARBINERIFLE_MK2_CAMO_04", 0xE50C424D},
		{"Sessanta Nove", "COMPONENT_CARBINERIFLE_MK2_CAMO_05", 0xD37D1F2F},
		{"Perseus", "COMPONENT_CARBINERIFLE_MK2_CAMO_06", 0x86268483},
		{"Leopard", "COMPONENT_CARBINERIFLE_MK2_CAMO_07", 0xF420E076},
		{"Zebra", "COMPONENT_CARBINERIFLE_MK2_CAMO_08", 0xAAE14DF8},
		{"Geometric", "COMPONENT_CARBINERIFLE_MK2_CAMO_09", 0x9893A95D},
		{"Boom!", "COMPONENT_CARBINERIFLE_MK2_CAMO_10", 0x6B13CD3E},
		{"Patriotic", "COMPONENT_CARBINERIFLE_MK2_CAMO_IND_01", 0xDA55CD3F}
	},
	[gameplay.get_hash_key("weapon_compactrifle")] = {
		{"Default Clip", "COMPONENT_COMPACTRIFLE_CLIP_01", 0x513F0A63},
		{"Extended Clip", "COMPONENT_COMPACTRIFLE_CLIP_02", 0x59FF9BF8},
		{"Drum Magazine", "COMPONENT_COMPACTRIFLE_CLIP_03", 0xC607740E}
	},
	[gameplay.get_hash_key("weapon_militaryrifle")] = {
		{"Default Clip", "COMPONENT_MILITARYRIFLE_CLIP_01", 0x2D46D83B},
		{"Extended Clip", "COMPONENT_MILITARYRIFLE_CLIP_02", 0x684ACE42},
		{"Iron Sights Scope", "COMPONENT_MILITARYRIFLE_SIGHT_01", 0x6B82F395},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL", 0xAA2C45B4},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA}
	},
	[gameplay.get_hash_key("weapon_mg")]= {
		{"Default Clip", "COMPONENT_MG_CLIP_01", 0xF434EF84},
		{"Extended Clip", "COMPONENT_MG_CLIP_02", 0x82158B47},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL_02", 0x3C00AFED},
		{"Yusuf Amir Luxury Finish", "COMPONENT_MG_VARMOD_LOWRIDER", 0xD6DABABE}
	},
	[gameplay.get_hash_key("weapon_combatmg")] = {
		{"Default Clip", "COMPONENT_COMBATMG_CLIP_01", 0xE1FFB34A},
		{"Extended Clip", "COMPONENT_COMBATMG_CLIP_02", 0xD6C59CD6},
		{"Scope", "COMPONENT_AT_SCOPE_MEDIUM", 0xA0D89C42},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Etched Gun Metal Finish", "COMPONENT_COMBATMG_VARMOD_LOWRIDER", 0x92FECCDD}
	},
	[gameplay.get_hash_key("weapon_combatmg_mk2")] = {
		{"Default Clip", "COMPONENT_COMBATMG_MK2_CLIP_01", 0x492B257C},
		{"Extended Clip", "COMPONENT_COMBATMG_MK2_CLIP_02", 0x17DF42E9},
		{"Tracer Rounds", "COMPONENT_COMBATMG_MK2_CLIP_TRACER", 0xF6649745},
		{"Incendiary Rounds", "COMPONENT_COMBATMG_MK2_CLIP_INCENDIARY", 0xC326BDBA},
		{"Armor Piercing Rounds", "COMPONENT_COMBATMG_MK2_CLIP_ARMORPIERCING", 0x29882423},
		{"Full Metal Jacket Rounds", "COMPONENT_COMBATMG_MK2_CLIP_FMJ", 0x57EF1CC8},
		{"Grip", "COMPONENT_AT_AR_AFGRIP_02", 0x9D65907A},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Medium Scope", "COMPONENT_AT_SCOPE_SMALL_MK2", 0x3F3C8181},
		{"Large Scope", "COMPONENT_AT_SCOPE_MEDIUM_MK2", 0xC66B6542},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Default Barrel", "COMPONENT_AT_MG_BARREL_01", 0xC34EF234},
		{"Heavy Barrel", "COMPONENT_AT_MG_BARREL_02", 0xB5E2575B},
		{"Digital Camo", "COMPONENT_COMBATMG_MK2_CAMO", 0x4A768CB5},
		{"Brushstroke Camo", "COMPONENT_COMBATMG_MK2_CAMO_02", 0xCCE06BBD},
		{"Woodland Camo", "COMPONENT_COMBATMG_MK2_CAMO_03", 0xBE94CF26},
		{"Skull", "COMPONENT_COMBATMG_MK2_CAMO_04", 0x7609BE11},
		{"Sessanta Nove", "COMPONENT_COMBATMG_MK2_CAMO_05", 0x48AF6351},
		{"Perseus", "COMPONENT_COMBATMG_MK2_CAMO_06", 0x9186750A},
		{"Leopard", "COMPONENT_COMBATMG_MK2_CAMO_07", 0x84555AA8},
		{"Zebra", "COMPONENT_COMBATMG_MK2_CAMO_08", 0x1B4C088B},
		{"Geometric", "COMPONENT_COMBATMG_MK2_CAMO_09", 0xE046DFC},
		{"Boom!", "COMPONENT_COMBATMG_MK2_CAMO_10", 0x28B536E},
		{"Patriotic", "COMPONENT_COMBATMG_MK2_CAMO_IND_01", 0xD703C94D}
	},
	[gameplay.get_hash_key("weapon_gusenberg")]= {
		{"Default Clip", "COMPONENT_GUSENBERG_CLIP_01", 0x1CE5A6A5},
		{"Extended Clip", "COMPONENT_GUSENBERG_CLIP_02", 0xEAC8C270}
	},
	[gameplay.get_hash_key("weapon_sniperrifle")] = {
		{"Default Clip", "COMPONENT_SNIPERRIFLE_CLIP_01", 0x9BC64089},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP_02", 0xA73D4664},
		{"Scope", "COMPONENT_AT_SCOPE_LARGE", 0xD2443DDC},
		{"Advanced Scope", "COMPONENT_AT_SCOPE_MAX", 0xBC54DA77},
		{"Etched Wood Grip Finish", "COMPONENT_SNIPERRIFLE_VARMOD_LUXE", 0x4032B5E7}
	},
	[gameplay.get_hash_key("weapon_heavysniper")] = {
		{"Default Clip", "COMPONENT_HEAVYSNIPER_CLIP_01", 0x476F52F4},
		{"Scope", "COMPONENT_AT_SCOPE_LARGE", 0xD2443DDC},
		{"Advanced Scope", "COMPONENT_AT_SCOPE_MAX", 0xBC54DA77}
	},
	[gameplay.get_hash_key("weapon_marksmanrifle_mk2")] = {
		{"Default Clip", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_01", 0x94E12DCE},
		{"Extended Clip", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02", 0xE6CFD1AA},
		{"Tracer Rounds", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER", 0xD77A22D2},
		{"Incendiary Rounds", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_INCENDIARY", 0x6DD7A86E},
		{"Armor Piercing Rounds", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_ARMORPIERCING", 0xF46FD079},
		{"Full Metal Jacket Rounds", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_FMJ", 0xE14A9ED3},
		{"Holographic Sight Scope", "COMPONENT_AT_SIGHTS", 0x420FD713},
		{"Large Scope", "COMPONENT_AT_SCOPE_MEDIUM_MK2", 0xC66B6542},
		{"Zoom Scope", "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2", 0x5B1C713C},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Flat Muzzle Brake", "COMPONENT_AT_MUZZLE_01", 0xB99402D4},
		{"Tactical Muzzle Brake", "COMPONENT_AT_MUZZLE_02", 0xC867A07B},
		{"Fat-End Muzzle Brake", "COMPONENT_AT_MUZZLE_03", 0xDE11CBCF},
		{"Precision Muzzle Brake", "COMPONENT_AT_MUZZLE_04", 0xEC9068CC},
		{"Heavy Duty Muzzle Brake", "COMPONENT_AT_MUZZLE_05", 0x2E7957A},
		{"Slanted Muzzle Brake", "COMPONENT_AT_MUZZLE_06", 0x347EF8AC},
		{"Split-End Muzzle Brake", "COMPONENT_AT_MUZZLE_07", 0x4DB62ABE},
		{"Default Barrel", "COMPONENT_AT_MRFL_BARREL_01", 0x381B5D89},
		{"Heavy Barrel", "COMPONENT_AT_MRFL_BARREL_02", 0x68373DDC},
		{"Grip", "COMPONENT_AT_AR_AFGRIP_02", 0x9D65907A},
		{"Digital Camo", "COMPONENT_MARKSMANRIFLE_MK2_CAMO", 0x9094FBA0},
		{"Brushstroke Camo", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_02", 0x7320F4B2},
		{"Woodland Camo", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_03", 0x60CF500F},
		{"Skull", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_04", 0xFE668B3F},
		{"Sessanta Nove", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_05", 0xF3757559},
		{"Perseus", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_06", 0x193B40E8},
		{"Leopard", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_07", 0x107D2F6C},
		{"Zebra", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_08", 0xC4E91841},
		{"Geometric", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_09", 0x9BB1C5D3},
		{"Boom!", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_10", 0x3B61040B},
		{"Boom!", "COMPONENT_MARKSMANRIFLE_MK2_CAMO_IND_01", 0xB7A316DA}
	},
	[gameplay.get_hash_key("weapon_heavysniper_mk2")] = {
		{"Default Clip", "COMPONENT_HEAVYSNIPER_MK2_CLIP_01", 0xFA1E1A28},
		{"Extended Clip", "COMPONENT_HEAVYSNIPER_MK2_CLIP_02", 0x2CD8FF9D},
		{"Incendiary Rounds", "COMPONENT_HEAVYSNIPER_MK2_CLIP_INCENDIARY", 0xEC0F617},
		{"Armor Piercing Rounds", "COMPONENT_HEAVYSNIPER_MK2_CLIP_ARMORPIERCING", 0xF835D6D4},
		{"Full Metal Jacket Rounds", "COMPONENT_HEAVYSNIPER_MK2_CLIP_FMJ", 0x3BE948F6},
		{"Explosive Rounds", "COMPONENT_HEAVYSNIPER_MK2_CLIP_EXPLOSIVE", 0x89EBDAA7},
		{"Zoom Scope", "COMPONENT_AT_SCOPE_LARGE_MK2", 0x82C10383},
		{"Advanced Scope", "COMPONENT_AT_SCOPE_MAX", 0xBC54DA77},
		{"Night Vision Scope", "COMPONENT_AT_SCOPE_NV", 0xB68010B0},
		{"Thermal Scope", "COMPONENT_AT_SCOPE_THERMAL", 0x2E43DA41},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_SR_SUPP_03", 0xAC42DF71},
		{"Squared Muzzle Brake", "COMPONENT_AT_MUZZLE_08", 0x5F7DCE4D},
		{"Bell-End Muzzle Brake", "COMPONENT_AT_MUZZLE_09", 0x6927E1A1},
		{"Default Barrel", "COMPONENT_AT_SR_BARREL_01", 0x909630B7},
		{"Heavy Barrel", "COMPONENT_AT_SR_BARREL_02", 0x108AB09E},
		{"Digital Camo", "COMPONENT_HEAVYSNIPER_MK2_CAMO", 0xF8337D02},
		{"Brushstroke Camo", "COMPONENT_HEAVYSNIPER_MK2_CAMO_02", 0xC5BEDD65},
		{"Woodland Camo", "COMPONENT_HEAVYSNIPER_MK2_CAMO_03", 0xE9712475},
		{"Skull", "COMPONENT_HEAVYSNIPER_MK2_CAMO_04", 0x13AA78E7},
		{"Sessanta Nove", "COMPONENT_HEAVYSNIPER_MK2_CAMO_05", 0x26591E50},
		{"Perseus", "COMPONENT_HEAVYSNIPER_MK2_CAMO_06", 0x302731EC},
		{"Leopard", "COMPONENT_HEAVYSNIPER_MK2_CAMO_07", 0xAC722A78},
		{"Zebra", "COMPONENT_HEAVYSNIPER_MK2_CAMO_08", 0xBEA4CEDD},
		{"Geometric", "COMPONENT_HEAVYSNIPER_MK2_CAMO_09", 0xCD776C82},
		{"Boom!", "COMPONENT_HEAVYSNIPER_MK2_CAMO_10", 0xABC5ACC7},
		{"Patriotic", "COMPONENT_HEAVYSNIPER_MK2_CAMO_IND_01", 0x6C32D2EB}
	},
	[gameplay.get_hash_key("weapon_marksmanrifle")] = {
		{"Default Clip", "COMPONENT_MARKSMANRIFLE_CLIP_01", 0xD83B4141},
		{"Extended Clip", "COMPONENT_MARKSMANRIFLE_CLIP_02", 0xCCFD2AC5},
		{"Scope", "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM", 0x1C221B1A},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Suppressor Muzzle Brake", "COMPONENT_AT_AR_SUPP", 0x837445AA},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Yusuf Amir Luxury Finish", "COMPONENT_MARKSMANRIFLE_VARMOD_LUXE", 0x161E9241}
	},
	[gameplay.get_hash_key("weapon_grenadelauncher")] = {
		{"Default Clip", "COMPONENT_GRENADELAUNCHER_CLIP_01", 0x11AE5C97},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL", 0xAA2C45B4}
	},
	[gameplay.get_hash_key("weapon_grenadelauncher_smoke")] = {
		{"Default Clip", "COMPONENT_GRENADELAUNCHER_CLIP_01", 0x11AE5C97},
		{"Flashlight", "COMPONENT_AT_AR_FLSH", 0x7BC4CDDC},
		{"Grip", "COMPONENT_AT_AR_AFGRIP", 0xC164F53},
		{"Scope", "COMPONENT_AT_SCOPE_SMALL", 0xAA2C45B4}
	}
})

local melee_weapons <const> = essentials.const_all({
	{"Pipe Wrench", 419712736},
	{"Stone Hatchet", 940833800},
	{"Golf Club", 1141786504},
	{"Hammer", 1317494643},
	{"Nightstick", 1737195953},
	{"Crowbar", 2227010557},
	{"Flashlight", 2343591895},
	{"Antique Cavalry Dagger", 2460120199},
	{"Pool Cue", 2484171525},
	{"Baseball Bat", 2508868239},
	{"Knife", 2578778090},
	{"Battle Axe", 3441901897},
	{"Knuckle Duster", 3638508604},
	{"Machete", 3713923289},
	{"Switchblade", 3756226112},
	{"Hatchet", 4191993645},
	{"Bottle", 4192643659}
})

local heavy_weapons <const> = essentials.const_all({
	{"Minigun", 1119849093},
	{"Homing Launcher", 1672152130},
	{"Railgun", 1834241177},
	{"Firework Launcher", 2138347493},
	{"Grenade Launcher", 2726580491},
	{"RPG", 2982836145},
	{"Widowmaker", 3056410471}
})

local explosive_weapons <const> = essentials.const_all({
	{"Homing Launcher", 1672152130},
	{"Railgun", 1834241177},
	{"Firework Launcher", 2138347493},
	{"Grenade Launcher", 2726580491},
	{"RPG", 2982836145},
	{"Compact Grenade Launcher", 125959754},
	{"Emp Launcher", gameplay.get_hash_key("weapon_emplauncher")}
})

local rifles <const> = essentials.const_all({
	{"Heavy rifle", gameplay.get_hash_key("weapon_heavyrifle")},
	{"Assault Rifle Mk II", 961495388},
	{"Compact Rifle", 1649403952},
	{"Bullpup Rifle", 2132975508},
	{"Carbine Rifle", 2210333304},
	{"Bullpup Rifle Mk II", 2228681469},
	{"Special Carbine Mk II", 2526821735},
	{"Advanced Rifle", 2937143193},
	{"Assault Rifle", 3220176749},
	{"Special Carbine", 3231910285},
	{"Carbine Rifle Mk II", 4208062921},
	{"Sniper Rifle", 100416529},
	{"Heavy Sniper Mk II", 177293209},
	{"Heavy Sniper", 205991906},
	{"Marksman Rifle Mk II", 1785463520},
	{"Marksman Rifle", 3342088282}	
})

local SMGs <const> = essentials.const_all({
	{"Combat PDW", 171789620},
	{"Micro SMG", 324215364},
	{"SMG", 736523883},
	{"Unholy Hellbringer", 1198256469},
	{"Gusenberg Sweeper", 1627465347},
	{"SMG Mk II", 2024373456},
	{"Combat MG", 2144741730},
	{"MG", 2634544996},
	{"Mini SMG", 3173288789},
	{"Machine Pistol", 3675956304},
	{"Combat MG Mk II", 3686625920},
	{"Assault SMG", 4024951519}
})

local pistols <const> = essentials.const_all({
	{"Stun gun 2", gameplay.get_hash_key("weapon_stungun_mp")},
	{"Vintage Pistol", 137902532},
	{"Pistol", 453432689},
	{"AP Pistol", 584646201},
	{"Ceramic Pistol", 727643628},
	{"Stun Gun", 911657153},
	{"Flare Gun", 1198879012},
	{"Combat Pistol", 1593441988},
	{"SNS Pistol Mk II", 2285322324},
	{"Navy Revolver", 2441047180},
	{"Double-Action Revolver", 2548703416},
	{"Pistol .50", 2578377531},
	{"Up-n-Atomizer", 2939590305},
	{"SNS Pistol", 3218215474},
	{"Pistol Mk II", 3219281620},
	{"Heavy Revolver", 3249783761},
	{"Heavy Revolver Mk II", 3415619887},
	{"Heavy Pistol", 3523564046},
	{"Marksman Pistol", 3696079510}		
})

local throwables <const> = essentials.const_all({
	{"Snowball", 126349499},
	{"Ball", 600439132},
	{"Molotov", 615608432},
	{"Sticky Bomb", 741814745},
	{"Jerry Can", 883325847},
	{"Flare", 1233104067},
	{"Grenade", 2481070269},
	{"BZ Gas", 2694266206},
	{"Proximity Mine", 2874559379},
	{"Pipe Bomb", 3125143736},
	{"Hazardous Jerry Can", 3126027122},
	{"Tear Gas", 4256991824},
	{"Fertilizer Can", gameplay.get_hash_key("weapon_fertilizercan")}
})

local shotguns <const> = essentials.const_all({
	{"Sweeper Shotgun", 317205821},
	{"Pump Shotgun", 487013001},
	{"Heavy Shotgun", 984333226},
	{"Pump Shotgun Mk II", 1432025498},
	{"Sawed-Off Shotgun", 2017895192},
	{"Bullpup Shotgun", 2640438543},
	{"Musket", 2828843422},
	{"Assault Shotgun", 3800352039},
	{"Double Barrel Shotgun", 4019527611}			
})

local misc <const> = essentials.const_all({
	{"Fire Extinguisher", 101631238}
})

local all_weapons <const> = essentials.const_all({
	melee_weapons,
	heavy_weapons,
	rifles,
	SMGs,
	pistols,
	throwables,
	shotguns,
	misc,
	explosive_weapons
})

local attachment_types <const> = essentials.const_all({
	{"scope", 1},
	{"clip", 1},
	{"grip", 1},
	{"flashlight", 1},
	{"rounds", 1},
	{"barrel", 1},
	{"muzzle brake", 1},
	{"magazine", 1}
})

local function get_hashes(...)
	local table_of_weapons <const> = ...
	local hashes <const> = {}
	for i = 1, #table_of_weapons do
		hashes[i] = table_of_weapons[i][2]
	end
	return hashes
end

weapon_mapper.melee_hashes = get_hashes(melee_weapons)
weapon_mapper.rifle_hashes = get_hashes(rifles)
weapon_mapper.smg_hashes = get_hashes(SMGs)
weapon_mapper.explosive_hashes = get_hashes(explosive_weapons)
weapon_mapper.shotgun_hashes = get_hashes(shotguns)
weapon_mapper.misc_weapon_hashes = get_hashes(misc)
weapon_mapper.throwables_hashes = get_hashes(throwables)
weapon_mapper.pistol_hashes = get_hashes(pistols)
weapon_mapper.heavy_weapon_hashes = get_hashes(heavy_weapons)

function weapon_mapper.get_table_of_melee_weapons()
	return get_hashes(melee_weapons)
end

function weapon_mapper.get_table_of_rifles()
	return get_hashes(rifles)
end

function weapon_mapper.get_table_of_smgs()
	return get_hashes(SMGs)
end

function weapon_mapper.get_table_of_explosive_weapons()
	return get_hashes(explosive_weapons)
end

function weapon_mapper.get_table_of_shotguns()
	return get_hashes(shotguns)
end

function weapon_mapper.get_table_of_misc_weapons()
	return get_hashes(misc)
end

function weapon_mapper.get_table_of_throwables()
	return get_hashes(throwables)
end

function weapon_mapper.get_table_of_pistols()
	return get_hashes(pistols)
end

function weapon_mapper.get_table_of_heavy_weapons()
	return get_hashes(heavy_weapons)
end

function weapon_mapper.get_table_of_weapons(...)
	local properties <const> = ...
	local Table <const> = {}
	if properties.rifles then
		table.move(weapon_mapper.rifle_hashes, 1, #weapon_mapper.rifle_hashes, #Table + 1, Table)
	end
	properties.rifles = nil
	if properties.smgs then
		table.move(weapon_mapper.smg_hashes, 1, #weapon_mapper.smg_hashes, #Table + 1, Table)
	end
	properties.smgs = nil
	if properties.shotguns then
		table.move(weapon_mapper.shotgun_hashes, 1, #weapon_mapper.shotgun_hashes, #Table + 1, Table)
	end
	properties.shotguns = nil
	if properties.pistols then
		table.move(weapon_mapper.pistol_hashes, 1, #weapon_mapper.pistol_hashes, #Table + 1, Table)
	end
	properties.pistols = nil
	if properties.explosives_heavy then
		table.move(weapon_mapper.explosive_hashes, 1, #weapon_mapper.explosive_hashes, #Table + 1, Table)
	end
	properties.explosives_heavy = nil
	if properties.heavy then
		table.move(weapon_mapper.heavy_weapon_hashes, 1, #weapon_mapper.heavy_weapon_hashes, #Table + 1, Table)
	end
	properties.heavy = nil
	if properties.throwables then
		table.move(weapon_mapper.throwables_hashes, 1, #weapon_mapper.throwables_hashes, #Table + 1, Table)
	end
	properties.throwables = nil
	if properties.melee then
		table.move(weapon_mapper.melee_hashes, 1, #weapon_mapper.melee_hashes, #Table + 1, Table)
	end
	properties.melee = nil
	if properties.misc then
		table.move(weapon_mapper.misc_weapon_hashes, 1, #weapon_mapper.misc_weapon_hashes, #Table + 1, Table)
	end
	properties.misc = nil
	essentials.assert(not next(properties), "Invalid weapon type.")
	return Table
end

function weapon_mapper.get_all_attachment_info_for_weapon(...)
	local weapon_hash <const> = ...
	essentials.assert(streaming.is_model_valid(weapon.get_weapon_model(weapon_hash)), "Tried to get attachments for an invalid weapon hash.", weapon_hash)
	essentials.assert(weapon_attachments[weapon_hash], "Failed to find information about a valid, weapon hash:", weapon_hash)
	return weapon_attachments[weapon_hash]
end

function weapon_mapper.get_weapon_attachment_details(...)
	local weapon_hash <const> = ...
	essentials.assert(streaming.is_model_valid(weapon.get_weapon_model(weapon_hash)), "Tried to get attachments for an invalid weapon hash.", weapon_hash)
	essentials.assert(weapon_attachments[weapon_hash], "Failed to find information about a valid, weapon hash:", weapon_hash)
	return weapon_attachments[weapon_hash]
end

function weapon_mapper.get_all_weapon_attachment_details()
	return weapon_attachments
end

function weapon_mapper.get_maxed_attachments_for_weapon(...)
	local weapon_hash <const> = ...
	essentials.assert(streaming.is_model_valid(weapon.get_weapon_model(weapon_hash)), "Tried to get attachments for an invalid weapon hash.", weapon_hash)
	essentials.assert(weapon_attachments[weapon_hash], "Failed to find information about a valid, weapon hash:", weapon_hash)
	local attachments <const> = {}
	for i, attachment in pairs(weapon_attachments[weapon_hash]) do
		for _, attachment_type in pairs(attachment_types) do
			if attachment[attachment_type[2]]:lower():find(attachment_type[1], 1, true) then
				attachments[#attachments + 1] = attachment[3]
			end
		end
	end
	return attachments
end

function weapon_mapper.get_random_attachments_for_weapon(...)
	local weapon_hash <const> = ...
	essentials.assert(streaming.is_model_valid(weapon.get_weapon_model(weapon_hash)), "Tried to get attachments for an invalid weapon hash.", weapon_hash)
	essentials.assert(weapon_attachments[weapon_hash], "Failed to find information about a valid, weapon hash:", weapon_hash)
	local attachments <const> = {}
	for _, attachment_type in pairs(attachment_types) do
		local temp <const> = {}
		for _, attachment in pairs(weapon_attachments[weapon_hash]) do
			if attachment[attachment_type[2]]:lower():find(attachment_type[1], 1, true) then
				temp[#temp + 1] = attachment[3]
			end
		end
		if #temp > 0 then
			attachments[#attachments + 1] = temp[math.random(1, #temp)]
		end
	end
	return attachments
end

function weapon_mapper.set_ped_weapon_attachments(...)
	local Ped <const>,
	random_attachments <const>,
	weapon_hash <const> = ...
	essentials.assert(streaming.is_model_valid(weapon.get_weapon_model(weapon_hash)), "Tried to get attachments for an invalid weapon hash.", weapon_hash)
	essentials.assert(weapon_attachments[weapon_hash], "Failed to find information about a valid, weapon hash:", weapon_hash)
	weapon.set_ped_weapon_tint_index(Ped, weapon_hash, math.random(1, math.max(weapon.get_weapon_tint_count(weapon_hash), 1)))
	local attachments
	if random_attachments then
		attachments = weapon_mapper.get_random_attachments_for_weapon(weapon_hash)
	else
		attachments = weapon_mapper.get_maxed_attachments_for_weapon(weapon_hash)
	end
	for i = 1, #attachments do
		weapon.give_weapon_component_to_ped(Ped, weapon_hash, attachments[i])
	end
	local void <const>, ammo <const> = weapon.get_max_ammo(Ped, weapon_hash)
	weapon.set_ped_ammo(Ped, weapon_hash, ammo)
end

return essentials.const_all(weapon_mapper)