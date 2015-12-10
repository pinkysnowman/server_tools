--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- wield item lookup feature ---------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("wield", {
	params = "<playername>",
	description = "Shows what a players wield item is.",
	privs = {admin=true},
	func = function(name, param)
		if minetest.get_player_by_name(param) or not param or param == "" then
			local item = minetest.get_player_by_name(param):get_wielded_item():get_name()
			if item == "" then item = ".....nothing?" end
			return true, param.." is holding a "..item
		else
			return false, param.." is not online."
		end
	end
})

--------------------------------------------------------------------------------------------
-- Remove wield item feature ---------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("removewield", {
	params = "<playername>",
	description = "Removes a players wield item!",
	privs = {admin=true},
	func = function(name, param)
		local item = minetest.get_player_by_name(param):get_wielded_item()
		local itemname = item:get_name()
		if item == ( "" or nil or ":" ) or not item then 
			return false, "There is no wield item to remove!"
		end
		if minetest.get_player_by_name(param) or not param or param == "" then
			minetest.get_player_by_name(param):set_wielded_item(nil)
			minetest.log("action", name.." has removed "..param.."'s \""..itemname.."\"!")
			minetest.chat_send_player(param, "Your \""..itemname.."\" was removed by an admin!")
			return true, param.."'s \""..itemname.."\" was removed!"
		else
			return false, param.." is not online."
		end
	end
})
