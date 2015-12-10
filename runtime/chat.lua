--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Profanity Monitor feature! --------------------------------------------------------------
-- Add the line >> disable_profanity_filter = false to the .conf to disable this feature! --
-- also includes an offline message delivery system for /msg -------------------------------
--------------------------------------------------------------------------------------------

local violationlog = server_tools.worldpath.."/violationlog.txt"
local disable = minetest.setting_getbool("disable_profanity_filter")
local disable_olm = minetest.setting_getbool("disable_offline_msgs")
local olm_autoclear = minetest.setting_getbool("offline_msgs_auto_clear")
local offline_msgs_file = server_tools.worldpath.."/offline_msgs"
local offline_msgs = {}

if disable_olm ~= true then
	local function load_offline_msg()
		local input = io.open(offline_msgs_file, "r")
		if input then
			repeat
				local line_out = input:read("*l")
				if line_out == nil or line_out == "" then
					break
				end
				local found, _, name, msg = line_out:find("^([^%s]+)%s(.+)$")
				offline_msgs[name] = msg
			until input:read(0) == nil
			io.close(input)
		end
	end

	load_offline_msg()

	function offline_msg(sendto,name,message)
		local prev_msg = ""
		if offline_msgs[sendto] then
			prev_msg = offline_msgs[sendto]..", next pm: "
		end
		offline_msgs[sendto] = prev_msg..os.date("PM %m/%d/%y %X from "..name..": \""..message.."\"")
		save_offline_msgs()
	end

	function save_offline_msgs()
		local output = io.open(offline_msgs_file, "w")
		local data = {}
		for i, v in pairs(offline_msgs) do
			if v ~= "" then
				table.insert(data,string.format("%s %s \n", i,v))
			end
		end
		output:write(table.concat(data))
		io.close(output)
	end

	minetest.register_on_joinplayer(function(player)
		local plname = player:get_player_name()
		if offline_msgs[plname] then
			minetest.chat_send_player(plname, offline_msgs[plname])
			minetest.log("action", plname.." recieved PM(s) "..offline_msgs[plname])
			if olm_autoclear == true then
				offline_msgs[name] = ""
				save_offline_msgs()	
			end
		end
	end)

	if olm_autoclear == true then
		table.insert(server_tools.print_out, "\t>>>> Offline /msg auto clear on login is active!")
	else
		minetest.register_chatcommand("check_msg", {
			params = "<clear>",
			description = "Checks your offline messages.",
			func = function(name, param)
				if offline_msgs[name] and offline_msgs[name] ~= "" then
					local msg = offline_msgs[name]
					if param == "clear" then 
						offline_msgs[name] = ""
						save_offline_msgs()
						return true, "Offline messages were cleared!"
					else
						return true, offline_msgs[name]..", To clear offline messages do /check_msg clear"
					end
				else
					return false, "No messages to show!"
				end
			end
		})
	end

	table.insert(server_tools.print_out, "\t>>>> Offline /msg useage is available!")
end

function check_filter(name,msg,type,sendto)
	if disable ~= true then
		local to = sendto or ""
		local lmsg = msg:lower()
		local block = false
		local why = ""
		for word, reason in pairs(server_tools.disallowed_words) do
			if lmsg:find(word) then
				minetest.log("action", "[ALERT!!!] \"profanity or bad words!!\" "..name..
					" is in violation!!!")
				violation(name,type,msg,to)
				if minetest.check_player_privs(name, {admin=true})
				or minetest.check_player_privs(name, {unfiltered=true}) then
					why = reason.."!"
				else
					block = true
					why = reason.."!"
				end
			end
		end
		return block, why
	end
end

minetest.register_privilege("unfiltered", {
	description = "Bypasses the chat filter", 
	give_to_singleplayer = true
})

function violation(name,type,msg,sendto)
	local to = sendto or ""
	local file = io.open(violationlog, "a")
	file:write(os.date("["..name.."] %m/%d/%y %X: \""..type.."\""..to.." "..msg.."\n"))
	file:close()
end

-- Handeler for public chat
---------------------------

minetest.register_on_chat_message(function(name, message)
	local block, reason = check_filter(name,message,"chat")
	if block == true then
		minetest.chat_send_player(name, "This will not be shown, "..reason)
		return true
	elseif reason ~= "" then
		minetest.chat_send_player(name, reason)
		return false
	else
		return false
	end
end)

-- Handeler for private chat
----------------------------

minetest.register_chatcommand("msg", {
	params = "<name> <message>",
	description = "Send a private message",
	privs = {shout=true},
	func = function(name, param)
		local found, _, sendto, message = param:find("^([^%s]+)%s(.+)$")
		if found then
			local block, reason = check_filter(name,message,"/msg",sendto)
			if block == true then
				return false, reason..", your message will not be sent!!!"
			end
			if minetest.get_player_by_name(sendto) then
				minetest.log("action", "PM from "..name.." to "..sendto..": "..message)
				minetest.chat_send_player(sendto, "PM from "..name..": "..message)
				if reason ~= "" then
					return true, reason..", Message sent"
				else
					return true, "Message sent"
				end
			else
				for is_name, data in pairs(minetest.auth_table) do
					if is_name == sendto then
						offline_msg(sendto,name,message)
						minetest.log("action", "PM from "..name.." to "..sendto..": "..message)
						if reason ~= "" then
							return true, reason..", "..sendto.." will recieve your message when they log back on!"
						else
							return true, sendto.." will recieve your message when they log back on!"
						end
					end
				end
				return false, "Player does not exist on this server, please check spelling and capitolization of the name!"
			end
		else
			return false, "Invalid usage, see /help msg"
		end
	end,
})

--Handeler for "/me" chat
-------------------------

minetest.register_chatcommand("me", {
	params = "<action>",
	description = "chat action (eg. /me goes outside)",
	privs = {shout=true},
	func = function(name, param)
		local block, reason = check_filter(name,param,"/me")
		if block == true then
			return false, "This will not be shown, "..reason
		elseif reason ~= "" then
			minetest.chat_send_player(name, reason)
		end
		minetest.chat_send_all("* "..name.." "..param)
		if server_tools.irc_loaded then
			irc:say("* "..name.." "..param)
		end
	end,
})

if disable ~= true then
	table.insert(server_tools.print_out, "\t>>>> Profanity filter function loaded!")
else
	table.insert(server_tools.print_out, "\t>>>> Profanity filter function will not be loaded!!!")
end
