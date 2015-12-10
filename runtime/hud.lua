--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 2.2 :D --------------------------------
--------------------------------------------------------------------------------------------
--Mod by Ginger Pollard (crazyginger72)                                                   --
--(c)2015 license: WTFPL                                                                  --
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------
-- Time and Lag hud ------------------------------------------------------------------------
-- Add the line >> load_time_lag_hud = false to the .conf to disable this feature! ---------
--------------------------------------------------------------------------------------------

local disable = minetest.setting_getbool("load_time_lag_hud")
local hud_color = minetest.setting_get("hud_color")
local add = ""
if hud_color then 
    add = "\n\t     *Color \""..hud_color.."\" was loaded!"
else
    hud_color = 0xFFFFFF
end
if disable ~= false then
    local player_hud = {}
    local player_hud_time = {}
    local player_hud_lag = {}
    local timer = 0;
    
    local function floormod ( x, y )
            return (math.floor(x) % y);
    end
    local function get_lag(raw)
            local a = server_tools.explode(", ",minetest.get_server_status())
            local b = server_tools.explode("=",a[4])
                    local lagnum = tonumber(string.format("%.2f", b[1]))
 		    local clag = 0
		    if lagnum > clag then 
			    clag = lagnum 
		    else
			    clag = clag * .75
		    end
                    if raw ~= nil then
                            return clag
                    else
                            return ("Current Lag: %s sec"):format(clag);
                    end
    end
    local function get_time ()
    local t, m, h, d
    t = 24*60*minetest.get_timeofday()
    m = floormod(t, 60)
    t = t / 60
    h = floormod(t, 60)
           
        
    if h == 12 then
        d = "pm"
    elseif h >= 13 then
        h = h - 12
        d = "pm"
    elseif h == 0 then
        h = 12
        d = "am"
    else
        d = "am"
    end
        return ("World time %02d:%02d %s"):format(h, m, d);
    end
    local function generatehud(player)
            local name = player:get_player_name()
            player_hud_time[name] = player:hud_add({
                    hud_elem_type = "text",
                    name = "player_hud:time",
                    position = {x=0.835, y=0.955},
                    text = get_time(),
                    scale = {x=100,y=100},
                    alignment = {x=0,y=0},
                    number = hud_color,
            })
            player_hud_lag[name] = player:hud_add({
                    hud_elem_type = "text",
                    name = "player_hud:lag",
                    position = {x=0.835, y=0.975},
                    text = get_lag(),
                    scale = {x=100,y=100},
                    alignment = {x=0,y=0},
                    number = hud_color,
            })
    end
    local function updatehud(player, dtime)
            local name = player:get_player_name()
            if player_hud_time[name] then 
            	player:hud_change(player_hud_time[name], "text", get_time()) 
            end
            if player_hud_lag[name] then 
            	player:hud_change(player_hud_lag[name], "text", get_lag()) 
            end
    end
    local function removehud(player)
            local name = player:get_player_name()
            if player_hud_time[name] then
                    player:hud_remove(player_hud_time[name])
            end
            if player_hud_lag[name] then
                    player:hud_remove(player_hud_lag[name])
            end
    end
    minetest.register_globalstep(function ( dtime )
    	timer = timer + dtime
        if (timer >= 1.0) then
        	timer = 0
            for _,player in ipairs(minetest.get_connected_players()) do
                    updatehud(player, dtime)
            end
        end
    end)
    minetest.register_on_joinplayer(function(player)
            minetest.after(0,generatehud,player)
    end)
    minetest.register_on_leaveplayer(function(player)
            minetest.after(1,removehud,player)
    end)
    table.insert(server_tools.print_out, "\t>>>> Time and Lag HUD loaded!"..add)
else
    table.insert(server_tools.print_out, "\t>>>> Time and Lag HUD not loaded!")
end
