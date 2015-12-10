--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- whereis feature -------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("whereis", {
	params = "<playername>",
	description = "Shows a players location.",
	privs = {admin=true},
	func = function(name, param)
		if not param or param == "" then 
			return false, "Usage: /whereis <playername> "
		end
		local player = minetest.get_player_by_name(param)
		if player then
			local pos = player:getpos()
			local px = math.floor(pos.x, 1)
			local py = math.floor(pos.y, 1)
			local pz = math.floor(pos.z, 1)
			return true, "Location of "..param.." is ("..px.." "..py.." "..pz..")"
		else
			return false, param.." is not online."
		end
	end
})

--------------------------------------------------------------------------------------------
-- wherewas feature ------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

local pl_was = {}
local pl_was_changed = false
local pl_was_file = minetest.get_worldpath() .. "/pl_was.plf"

local function load_pl_was()
	local input = io.open(pl_was_file, "r")
	if input then
		repeat
			local line_out = input:read("*l")
			if line_out == nil then
				break
			end
			local found, _, name, pos = line_out:find("^([^%s]+)%s+(.+)$")
			if not found then
				return
			end
			pl_was[name] = minetest.string_to_pos(pos)
		until input:read(0) == nil
		io.close(input)
	end
end

load_pl_was()

local function save_pl_was()
	local output = io.open(pl_was_file, "w")
	local data = {}
	for i, v in pairs(pl_was) do
		table.insert(data,string.format("%s %.1f %.1f %.1f", i,v.x,v.y,v.z))
	end
	output:write(table.concat(data,"\n"))
	io.close(output)
	return
end

minetest.register_chatcommand("wherewas", {
	params = "<playername>",
	description = "Shows a players last known location.",
	privs = {admin=true},
	func = function(name, param)
		if not param or param == "" then 
			return false, "Usage: /wherewas <playername> "
		end
		local pos = pl_was[param]
		if pos then
			local px = math.floor(pos.x, 1)
			local py = math.floor(pos.y, 1)
			local pz = math.floor(pos.z, 1)
			return true, "Last known location of "..param.." is ("..px.." "..py.." "..pz..")"
		else
			return false, param.." doesn't have a last know location. Player may still be online, try using /whereis."
		end
	end
})

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	local pos = player:getpos()
	pl_was[name] = pos
	pl_was_changed = true
end)

minetest.register_on_shutdown(function()
	save_pl_was()
end)

minetest.register_globalstep(function ( dtime )
	if pl_was_changed == true then
		save_pl_was()
		pl_was_changed = false
	end
end)
