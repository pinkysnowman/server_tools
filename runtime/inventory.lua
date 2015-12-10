--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Player inventory look up feature --------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("search_inv", {
	params = "<playername> <itemname>",
	description = "Searches players inventory for an item.",
	privs = {admin=true},
	func = function(name, param)
		if param == "" then
			return false, "Usage: /search_inv <playername> <itemname>"
		end
		local found, _, player, itemname = param:find("^([^%s]+)%s+(.+)$")
		if found == nil then
			return false, "invalid usage!"
		end
		if not minetest.get_player_by_name(player) then
			return false, player.." is not online."
		end
		if minetest.get_player_by_name(player):get_inventory():contains_item("main", itemname) then
			return true, player.." has the item \""..itemname.."\" in their inventory!"
		else
			return true, player.." doesn't have a \""..itemname.."\" in their inventory!"
		end
	end
})

--------------------------------------------------------------------------------------------
-- Player inventory remove item feature ----------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("remove_inv", {
	params = "<playername> <itemname> <amount>",
	description = "Searches players inventory for an item.",
	privs = {admin=true},
	func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "Usage: /remove_inv <playername> <itemname> <optional amount>")
			return
		end
		local found, _, player, itemname, amount = param:find("^([^%s]+)%s+(.+)$")
		if found == nil then
			worldedit.player_notify(name, "Usage: /remove_inv <playername> <itemname> <optional amount>")
			return
		end
		if not minetest.get_player_by_name(player) then
			minetest.chat_send_player(name, player.." is not online.")
			return
		end
		if minetest.get_player_by_name(player):get_inventory():contains_item("main", itemname) then
			if not amount then amount = "" end
			minetest.chat_send_player(name, "\""..itemname.."\" has been removed from "..player.."'s inventory!")
			minetest.chat_send_player(player, "\""..itemname.."\" has been removed from your inventory by an admin!")
			minetest.log("action", "\""..itemname.."\" has been removed from "..player.."'s inventory by "..name.."!")
			if amount == "" then amount = 65535 end
			minetest.get_player_by_name(player):get_inventory():remove_item("main", itemname.." "..amount)
		else
			minetest.chat_send_player(name, player.." doesn't have a \""..itemname.."\" in their inventory!")
		end
	end
})

--------------------------------------------------------------------------------------------
-- Player inventory list empty feature -----------------------------------------------------
-- Add the line >> disable_empty_inv = true to the .conf to disable this feature! ----------
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("disable_empty_inv")
if disable ~= true then
	minetest.register_chatcommand("empty_inv", {
		params = "<player> <list>",
		description = "Destroys all items in players inventory ,crafting grid or other items list.",
		privs = {admin=true},
		func = function(name, param)
			local found, _, player, list = param:find("^([^%s]+)%s+(.+)$")
			if list ~= "main" and list ~= "craft" then
				return false, "You must specify the item list to clear! ex: \"main\", \"craft\" or other list."
			end
			local plname = minetest.get_player_by_name(player)
			if not plname or plname == name then
				return false, "Can not empty!!!"
			end
			local inv = plname:get_inventory()
			inv:set_list(list, {})
			minetest.chat_send_player(player, "Your item list \""..list.."\" has been cleared by an admin!")
			minetest.log("action", player.."'s item list \""..list.."\" has been cleared by "..name.."!")
			return true, player.."'s item list \""..list.."\" has been cleared!"
		end,
	})
	table.insert(server_tools.print_out, "\t>>>> \"/empty_inv\" command Loaded!\n\t     *Admin can now clear a players inventory list!")
end
