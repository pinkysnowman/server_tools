--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- "/privs" check blocker function ---------------------------------------------------------
-- Add the line >> enable_privs_check_block = true to the .conf to enable this feature! ----
--------------------------------------------------------------------------------------------

if minetest.setting_getbool("enable_privs_check_block") then
	minetest.register_chatcommand("privs", {
		params = "<name>",
		description = "print out privileges of player",
		func = function(name, param)
			if param ~= ( "" or nil ) 
				and not minetest.check_player_privs(name, {privs=true})
				and not minetest.check_player_privs(name, {server=true})
				and not minetest.check_player_privs(name, {admin=true}) then
				return false, "Your privileges are insufficient to view others privileges!"
			end
			param = (param ~= "" and param or name)
			return true, "Privileges of "..param..": "
				..minetest.privs_to_string(minetest.get_player_privs(param), ' ')
		end,
	})
	table.insert(server_tools.print_out, "\t>>>> \"/privs\" check will require admin level privileges!")
end
