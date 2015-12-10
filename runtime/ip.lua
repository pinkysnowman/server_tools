--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- IP look up feature ----------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("ip", {
	params = "<playername> | leave playername empty to see your IP",
	description = "Shows IP address.",
	privs = {admin=true},
	func = function(name, param)
		if not param or param == "" then param = name end
		if minetest.get_player_by_name(param) then
			return true, "IP address of "..param.." is "..minetest.get_player_ip(param)
		else
			return false, param.." is not online."
		end
	end
})
