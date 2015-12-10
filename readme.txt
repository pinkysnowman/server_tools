--------------------------------------------------------------------------------------------
------------------------------ Server Tools Mod ver: 1.0 :D --------------------------------
--------------------------------------------------------------------------------------------
Mod by Ginger Pollard (crazyginger72)                                                   
(c)2015 license: WTFPL 

 This mod adds some useful features and comands to the game as well as an optional      
 profanity and language filter that over rides the /me and /msg functions to help block 
 un desired messages from being sent, also it reports violations to the minetest log!   
                                                                                        
 The mod also adds a time and lag hud, white list for players, the ability to kill or  
 set a players hp, the ability to look a players IP address, the ability to get players 
 location, the ability to see what a player is weilding, the ability to remove a        
 players weild item, the ability to search a players inventory for an item, the ability 
 to remove an item(s) from a players inventory, the ability to set time by the          
 "HH:MM am/pm" format, the ability to only let admin use "/privs" to view others        
 privileges, the ability to empty a players inventory list by "item_list" name and the  
 ability to set up to 5 different /spawn locations.                                     
                                                                                        
 The white list, time and lag HUD, "/empty_inv" feature, "/privs" blocker function and  
 profanity filter can be disabled or enabled via the .conf
 
*some code by shadowninja via "name_restrictions" mod  
 -------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------

Special privs: 
	"admin"

Comands and usage:
	/settime >> Sets game time via HH:MM AM/PM instead of a value.
	         ex: /settime 9:26 pm or 16:28
	         (if am/pm is blank it will default to am)
	         (also works woth 24hr time inputs)

	/ip >> Shows your IP address or the IP address of a player.
	    ex: /ip or /ip <playername>

	/whereis >> Shows the location cordinat of a player.
	         ex: /whereis <playername>

	/weild >> Shows a players current weild item.
	       ex: /weild <playername>

	/removeweild >> Removes a players current weild item.
	             ex: /removeweild <playername>

	/search_inv >> Searches a players inventory for a specific item.
	            ex: /search_inv <playername> <itemname> 
	            (itemname may be alias or item string)

	/remove_inv >> Removes a specific item from a players inventory.
	            ex: /remove_inv <playername> <itemname> <amount> 
	            (itemname may be alias or item string)
	            (amount can be any positive number, if blank will remove all the item)

	/empty_inv >> Empties a players inventory by specific "item_list".
	           ex: /empty_inv <playername> <listname> 
	           (list name such as "main", "craft" or other "item_list"s)

	/kill >> Kills the player.
	      ex: /kill <playername>

	/killme >> Kills you!
	        ex: /killme

	/sethp >> Sets a players hp.
	       ex: /sethp <playername> <HP> 
	       (HP can be a number from 1 to 20)

	***HP and Kill functions only work if your world is set to enable damage!

	/whitelist >> This adds a "whitelist" of players allowed on the world.
	           ex: /whitelist <add> <playername> or <remove> <playername>

	/spawn >> This adds the "/spawn" comand to the game.
	       ex: /spawn or /spawn <number> 
	       (if number is blank, is a 1 or a 0 then the normal spawn is used)
	       (you may set up to 5 spawn locations)
	       (automatically checks for multiple )



