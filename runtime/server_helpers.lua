--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Server announcments ---------------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("server", {
	params = "<message>",
	description = "Sends message to all as ***SERVER***",
	privs = {server=true},
	func = function(name, param)
		minetest.chat_send_all("***SERVER*** "..param)
		minetest.log("action", name.." invokes /server => \""..param.."\"")
	end,
})

--------------------------------------------------------------------------------------------
-- Server Delayed shutdown -----------------------------------------------------------------
--------------------------------------------------------------------------------------------

minetest.register_chatcommand("shutdown", {
	params = "<delay_in_seconds(0..360)> | Leave blank for normal shutdown",
	description = "shutdown server",
	privs = {server=true},
	func = function(name, param)
		if param ~= "" then
			param = tonumber(param)
			if param > 0 or param < 360 then
				minetest.log("action", name .. " shuts down server, delayed "..param.." seconds.")
				minetest.chat_send_all("*** Server will be shutting down in "..param.." seconds (operator request).")
				minetest.after(param, function()
					minetest.log("action", " shutting down server, delayed shutdown by "..name)
					minetest.request_shutdown()
					minetest.chat_send_all("*** Server shutting down (operator request).")
				end)
				local time = param
				repeat
					param = param-10
					minetest.after(param, function()
						minetest.chat_send_all("***Server will be shutting down!!!!***")
					end)
				until param <= 10
				return true, "shutdowning server down in "..time.." seconds!!!"
			else
				return false, "Delay time must be between 1 and 3600"
			end
		else
			minetest.log("action", name.." shuts down server")
			minetest.request_shutdown()
			minetest.chat_send_all("*** Server shutting down (operator request).")
		end
	end,
})

--------------------------------------------------------------------------------------------
-- Server welcome for new players feature --------------------------------------------------
-- Add the line >> enable_welcome = true to the .conf to enable this feature! --------------
-- Add the line >> welcome_msg = <message here> .conf set aditional welcome message --------
--------------------------------------------------------------------------------------------

local server_name = minetest.setting_get("server_name")
local welcome = minetest.setting_get("welcome_msg") 

if minetest.setting_getbool("enable_welcome") then
	local welcome_msg = ""
	if welcome then
		welcome_msg = ", "..welcome
	end
	minetest.register_on_newplayer(function(player)
		local plname = player:get_player_name()
		minetest.chat_send_player("Welcome to "..server_name..welcome_msg)
	end)
	table.insert(server_tools.print_out, "\t>>>> New player welcome message enabled!")
end
