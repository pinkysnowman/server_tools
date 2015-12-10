--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Player physics feature ------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("physics", {
	params = "<player> <speed>,<gravity>,<jump> | <player> <param> <value> | <player> <reset>",
	description = "Sets physics override (default: 1)",
	privs = {admin=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return
		end
		local plname, rparam = string.match(param, "^([^ ]+) +([^ ]+)$")
		if plname and rparam == "reset" then
			local plhere = minetest.get_player_by_name(plname)
			if not plhere then
				return false, "Player is not online!"
			end
			minetest.get_player_by_name(plname):set_physics_override(1, 1, 1)
			return true, "Physics reset!"
		end
		local plname, speed, gravity, jump = param:match("^([^ ]+) +([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		if plname then
			local plhere = minetest.get_player_by_name(plname)
			if not plhere then
				return false, "Player is not online!"
			end
			minetest.get_player_by_name(plname):set_physics_override(tonumber(speed), tonumber(gravity), tonumber(jump))
			return true, "Physics set to speed:"..speed.." gravity:"..gravity.." jump:"..jump
		end
		local found, _, plname, pparam, value = param:find("^([^%s]+)%s+(.+)$")
		if found then
			local plhere = minetest.get_player_by_name(plname)
			if not plhere then
				return false, "Player is not online!"
			end
			local speed, gravity,jump = nil,nil,nil
			pparam, value = string.match(pparam, "^([^ ]+) +([^ ]+)$")
			if pparam == "speed" then
				speed = tonumber(value)
			elseif pparam == "gravity" then
				gravity = tonumber(value)
			elseif pparam == "jump" then
				jump = tonumber(value)
			else
				return false, "Invalid usage, see /help physics"
			end
			minetest.get_player_by_name(plname):set_physics_override(tonumber(speed), tonumber(gravity), tonumber(jump))
			return true, pparam.." is set to "..value	
			end 
		return false, "Invalid usage, see /help physics"
	end,
})

table.insert(server_tools.print_out, "\t>>>> Player physics override Loaded!")