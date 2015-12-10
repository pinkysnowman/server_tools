--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Player Kill and HP setting --------------------------------------------------------------
--------------------------------------------------------------------------------------------

local enable = minetest.setting_getbool("enable_damage")
if enable == true then
	minetest.register_chatcommand("kill", {
	    params = "<playername>",
	    description = "The player will be klled immediately",
	    privs = {admin=true},
	    func = function(name, param)
	        if param == "" then
	            return false, "Usage: /kill <playername>"
	        end
	        if minetest.get_player_by_name(param) then
	        	minetest.get_player_by_name(param):set_hp(0)
	            minetest.chat_send_player(param, "An admin has killed you!")
	            minetest.log("action", name.." has killed "..param..".")
	            return true, param.." has been killed."
	        elseif not minetest.get_player_by_name(param) then
	        	return false, param.." isn't online."
	        end
	    end
	})

	minetest.register_chatcommand("killme", {
	    description = "Kills you immediately",
	    privs = {interact=true},
	    func = function(name, param)
	        if minetest.get_player_by_name(name) then
	        	minetest.get_player_by_name(name):set_hp(0)
	            return true, "You have been killed."
	        end
	    end
	})

	minetest.register_chatcommand("sethp", {
	    params = "<playername> <value>",
	    description = "Allows to set a player's HP.",
	    privs = {admin=true},
	    func = function(name, param)
	        if param == "" then
	            return false, "Usage: /sethp <playername> <value 1-20>"
	        end
	        local user, hp = string.match(param, " *([%w%-]+) *(%d*)")
	        hp = tonumber(hp)
	        if hp == nil or hp == "" or hp >20 or hp <= 1 then
	            return false, "Usage: /sethp <playername> <value 1-20>"
	        end
	        if minetest.get_player_by_name(user) then
	            minetest.get_player_by_name(user):set_hp(hp)
	            minetest.chat_send_player(user, name.." set your hp to "..hp.."!")
	            minetest.log("action", name.." has set "..user.."'s HP to "..hp..".")
	            return true, user.."'s HP set to "..hp.."."
	        elseif not minetest.get_player_by_name(user) then
	        	return false, user.." isn't online."
	        end
	    end
	})

	table.insert(server_tools.print_out, "\t>>>> \"/kill\", \"/killme\" and \"/sethp\" Loaded!")
else
	table.insert(server_tools.print_out, "\t>>>> Damage is not enabled, \n\t     \"/kill\", \"/killme\" and \"/sethp\" not loaded!")
end
