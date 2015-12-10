--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Auto reply bot feature ------------------------------------------------------------------
--------------------------------------------------------------------------------------------

if server_tools.auto_reply then
	minetest.register_chatcommand("auto_reply", {
		params = "<topic> | <list>",
		description = "Command the bot to give useful information",
		privs = {admin=true},
		func = function(player, param)
			if not param or param == "" then
				return false, "Invalid usage, see /help auto_reply"
			end
			if param == "list" then
				local list = {}
				for reply, _ in pairs(server_tools.auto_reply) do
					table.insert(list,reply)
				end
				return true, "Available replies: "..table.concat(list,", ")
			else
				for reply, msg in pairs(server_tools.auto_reply) do
					if param:lower():find(reply) then
						minetest.chat_send_all(msg)
						return true
					end
				end
				return false, "Invalid usage, see /help auto_reply"
			end
		end,
	})
	table.insert(server_tools.print_out, "\t>>>> Auto reply bot is now loaded!")
end
