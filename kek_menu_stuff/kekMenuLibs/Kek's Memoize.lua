-- Copyright © 2020-2022 Kektram
--[[
	This library aims to reduce garbage created by constructing expensive objects.
	Certain functions, such as getting distance, is very wasteful in a loop.
--]]

local memoize <const> = {version = "1.0.1"}

--[[ v3 & v2 memoize documentation

	0xFFFFE / 0x64 is the max coordinate for v3.
	0x3FFFFFFE / 0x3E8 is the max coordinate for v2.
	Supports negative & positive coordinates.
	If you try to memoize a vector with bigger coordinates than supported, it won't be memoized and will instead, construct the vector like default.

	Doing vector math creates brand new vector objects, so it's safe to do: 
	local example = memoize.v2(10, -13) + 5 
	Creates new v2 object, unrelated to the memoized object.

	NEVER do this:
	local v2_object = memoize.v2()
	v2_object.x = 100
	Any request for memoize.v2() and existing uses is now v2(100, 0) instead of v2(0, 0)

	There's currently no way to set constant vectors, so it's up to you to not modify the memoized vectors.
	V3 memoize is guaranteed to differentiate between all coordinates with 1 / 10^2 or bigger fractions. v3(10.123, 9, 9) would be unsupported.
	V2 memoize is guaranteed to differentiate between all coordinates with 1 / 10^3 or bigger fractions. v2(10.1232, 9) would be unsupported.
	Why memoize v3 & v2?
	The main purpose of caching is calming down the garbage collector. It causes stuttering and reduced fps.
	Additionally, these functions make it 10x faster to obtain the values if they are already memoized.
	This speed buff is negligible, because we're talking 0.6 million vs 6 million iterations in 1 second.
--]]

do
	local sign_bit_x <const> = 1 << 62
	local sign_bit_y <const> = 1 << 61
	local sign_bit_z <const> = 1 << 60
	local max_20_bit_num <const> = 1048475 
	local v3 <const> = v3
	local memoized <const> = {}
	function memoize.v3(x, y, z)
		x = x or 0
		y = y or 0
		z = z or 0
		local xi = x * 100 // 1
		local yi = y * 100 // 1
		local zi = z * 100 // 1
		if xi >= -max_20_bit_num 
		and xi <= max_20_bit_num 
		and yi >= -max_20_bit_num 
		and yi <= max_20_bit_num 
		and zi >= -max_20_bit_num
		and zi <= max_20_bit_num then
			local signs = 0
			if xi < 0 then
				xi = xi * -1
				signs = signs | sign_bit_x
			end
			if yi < 0 then
				yi = yi * -1
				signs = signs | sign_bit_y
			end
			if zi < 0 then
				zi = zi * -1
				signs = signs | sign_bit_z
			end
			local hash <const> = signs | xi << 40 | yi << 20 | zi
			memoized[hash] = memoized[hash] or v3(x, y, z)
			return memoized[hash]
		else
			return v3(x, y, z)
		end
	end
end

do
	local sign_bit_x <const> = 1 << 62
	local sign_bit_y <const> = 1 << 61
	local max_30_bit_num <const> = 1073740823
	local v2 <const> = v2
	local memoized <const> = {}
	function memoize.v2(x, y)
		x = x or 0
		y = y or 0
		local xi = x * 1000 // 1
		local yi = y * 1000 // 1
		if xi >= -max_30_bit_num 
		and xi <= max_30_bit_num 
		and yi >= -max_30_bit_num 
		and yi <= max_30_bit_num then
			local signs = 0
			if xi < 0 then
				xi = xi * -1
				signs = signs | sign_bit_x
			end
			if yi < 0 then
				yi = yi * -1
				signs = signs | sign_bit_y
			end
			local hash <const> = signs | xi << 30 | yi
			memoized[hash] = memoized[hash] or v2(x, y)
			return memoized[hash]
		else
			return v2(x, y)
		end
	end
end

do
	for func_name, func_table_name in pairs({
		get_entity_coords = "entity",
		get_player_coords = "player"

	}) do
		local memoized <const> = setmetatable({}, {__mode = "vk"})
		memoize[func_name] = function(data)
			if memoized[data] and memoized[data].time > utils.time_ms() then
				return memoized[data].pos
			else
				memoized[data] = memoized[data] or {}
				memoized[data].pos = (_G[func_table_name] or package.loaded[func_table_name])[func_name](data)
				memoized[data].time = utils.time_ms() + math.ceil(20000 * math.min(gameplay.get_frame_time(), 0.03)) 
				return memoized[data].pos
			end
		end
	end
end

do -- memoizes entity tables for 50 frames. Only useful in loops.
	for func_name, func_table_name in pairs({
		get_all_peds = "ped",
		get_all_vehicles = "vehicle",
		get_all_objects = "object",
		get_all_pickups = "object"
	}) do
		local memoized <const> = {timer = 0}
		memoize[func_name] = function()
			if utils.time_ms() > memoized.timer then
				memoized.timer = utils.time_ms() + math.ceil(50000 * math.min(gameplay.get_frame_time(), 0.03))
				memoized.Table = setmetatable(
					_G[func_table_name][func_name](), {
						__newindex = function() 
							error("Tried to modify a read-only table.") 
						end
					}
				)
				return memoized.Table
			else
				return memoized.Table
			end
		end
	end
end

do
	local memoized <const> = setmetatable({}, {__mode = "vk"})
	function memoize.get_distance_between(entity_or_position_1, entity_or_position_2, e1, e2, memoize_time)
		local type1 <const> = math.type(entity_or_position_1) == "integer"
		local type2 <const> = math.type(entity_or_position_2) == "integer"
		local hash
		if (type1 and type2) or e1 or e2 then
			e1 = e1 or entity_or_position_1
			e2 = e2 or entity_or_position_2
			hash = 0 | e1 << 30 | e2
			if memoized[hash] and memoized[hash].time > utils.time_ms() then
				return memoized[hash].magnitude
			end
		end
		if type1 then
			entity_or_position_1 = entity.get_entity_coords(entity_or_position_1)
		end
		if type2 then 
			entity_or_position_2 = entity.get_entity_coords(entity_or_position_2)
		end
		local magnitude <const> = entity_or_position_1:magnitude(entity_or_position_2)
		if hash then
			memoized[hash] = memoized[hash] or {}
			memoized[hash].magnitude = magnitude
			memoized[hash].time = utils.time_ms() + math.ceil((memoize_time or 20) * 1000 * math.min(gameplay.get_frame_time(), 0.03))
		end
		return magnitude
	end
end

return memoize