--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Player death message feature ------------------------------------------------------------
-- Add the line >> enable_death_msg = true to the .conf to enable this feature! ------------
--------------------------------------------------------------------------------------------

if minetest.setting_getbool("enable_death_msg") then
	minetest.register_on_dieplayer(function(player)
		local plname = player:get_player_name()
		minetest.chat_send_all(plname.." has died!")
	end)
	table.insert(server_tools.print_out, "\t>>>> Player death messages enabled!")
end
