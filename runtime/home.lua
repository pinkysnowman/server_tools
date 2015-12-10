--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- homes function --------------------------------------------------------------------------
-- Add the line >> override_homes = false to the .conf to disable this feature! ------------
--------------------------------------------------------------------------------------------

local override = minetest.setting_getbool("override_homes")
if override ~= false then

	local homes_file = minetest.get_worldpath() .. "/players/"
	local old_homes_file = minetest.get_worldpath() .. "/homes"

	local function loadhome(name)
		local input = io.open(homes_file..name..".phf", "r")
		if input then
			local line_out = input:read("*l")
			if line_out then
				local found, _, name, pos = line_out:find("^([^%s]+)%s+(.+)$")
				io.close(input)
				return pos
			else
				return 
			end
		end
	end

	local function savehome(name,pos)
		if not pos then pos = minetest.get_player_by_name(name):getpos() end
		local output = io.open(homes_file..name..".phf", "w")
		output:write(name.." "..pos.x.." "..pos.y.." "..pos.z)
		io.close(output)
	end

	local function importhomes(erase_old)
		local input = io.open(old_homes_file, "r") 
		if input then
			repeat
				local x = input:read("*n")
				if x == nil then
					break
				end
				local y = input:read("*n")
				local z = input:read("*n")
				local n = input:read("*l")
				savehome(n:sub(2), {x=x, y=y, z=z})
			until input:read(0) == nil
			io.close(input)
			if erase_old == "erase" then
				io.open(old_homes_file, "wb"):write("Homes have been converted to the .phf format"..
								" and stored in the /players directory of the world directory")
				return true, "Home files imported and old file was erased!"
			end
			return true, "Home files imported!"
		else
			return false, "ERROR IMPORTING HOMES!!!"
		end
	end

	minetest.register_chatcommand("home", {    
		description = "Teleports you to your home.",
		privs = {interact=true},
		func = function(name)
			local player = minetest.get_player_by_name(name)
			if player then
				local home = minetest.string_to_pos(loadhome(name))
				if home then
					player:setpos(home)
					return true, "Teleporting home!"
				else
					return false, "Home is not set, set a home using /sethome"
				end
			end
		end,
	})

	minetest.register_chatcommand("sethome", {
		description = "Sets your home.",
		privs = {interact=true},
		func = function(name)
			savehome(name)
			return true, "Home is set!"
		end,
	})

	minetest.register_chatcommand("importhomes", {
		description = "Imports old homes file to new format!",
		params = "<erase> | Leave blank to leave the existing homes file as it is.",
		privs = {server=true},
		func = function(name,param)
			return importhomes(param)
		end,
	})

	table.insert(server_tools.print_out, "\t>>>> \"/home\" and \"/sethome\" overrides loaded!")
else
	table.insert(server_tools.print_out, "\t>>>> \"/home\" and \"/sethome\" overrides not loaded!")
end
