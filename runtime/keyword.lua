--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- keyword interact feature ----------------------------------------------------------------
--------------------------------------------------------------------------------------------

local keyword = minetest.setting_get("keyword")
local interact_spawn = minetest.setting_get_pos("static_spawnpoint_1")

if keyword then
	local function grant_interact(name)
		if not minetest.get_player_privs(name).interact then
			local privs = minetest.get_player_privs(name)
			privs.interact = true
			minetest.set_player_privs(name, privs)
			minetest.chat_send_player(name, "You have now been granted \"interact\" privileges!")
			minetest.log("action", os.date("%m/%d/%y %X: "..name.." has ben granted \"interact\" privileges by the \"server_tools\" mod!"))
			if interact_spawn and interact_spawn ~= "" then 
				minetest.get_player_by_name(name):setpos(interact_spawn) 
			end
			if server_tools.irc_loaded then
				irc:say("Notice, "..name.." has read the rules and been granted \"interact\" privileges!")
			end
		else
			minetest.chat_send_player(name, "You already have \"interact\" privileges!")
		end
	end
	minetest.register_on_chat_message(function(name, message)
		if message:lower():find(keyword) then
			grant_interact(name)
			return true
		end
	end)
	minetest.register_chatcommand("interact", {
		params = "<player>",
		description = "Grants interact in the way the keyword does.",
		privs = {basic_privs=true},
		func = function(name, param)
		if not param or param == "" then
			return false 
		end
		for is_name, data in pairs(minetest.auth_table) do
			if is_name == param then
				grant_interact(param)
				return true, "Granted!"
			else
				return false, "Player "..param.." does not exist!!!"
			end
		end
	end,
	})
	table.insert(server_tools.print_out, "\t>>>> Interact granted by keyword enabled!\n"
									   .."\t     *Keyword is \""..keyword.."\"")
else
	table.insert(server_tools.print_out, "\t>>>> Interact granted by keyword disabled!")
end

minetest.register_chatcommand("set_keyword", {
	params = "<keyword>",
	description = "set the keyword",
	privs = {server=true},
	func = function(name, param)
	keyword = param
		minetest.setting_set("keyword", param)
		minetest.setting_save()
		minetest.log("action", os.date("%m/%d/%y %X: "..name.." has set a new keyword "..param))
		return true, "Keyword is now set to "..param
	end,
})
