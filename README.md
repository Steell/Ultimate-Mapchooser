# UMC
Ultimate Map Chooser.

This plugin is design to be a more complex mapchooser plugin that can be used to create various map lists to vote from. While it has all the standard map voting items (rtv, nominate, etc.) it also has some complexity in that you can set special conditions (such as player thresholds) for certain maps, which can help introduce some maps when a server is more full or allow users to pick ones based on map prefix, gamemode, and other such things.

Currently this plugin works with the following games (or at least it should):
- TF2
- ZPS
- CS:GO
- Insurgency
- Nuclear Dawn
- EmpiresMod
- Hidden: Source
- Neotokyo

I can only confirm that it works in TF2 and ZPS. Allegedly, it works in CS:GO (or it should after fixing the sound precaching crash). It can also work in other Source games that are not mentioned provided that rely on common/generic round end events and cvars. If other games need support or there are issues with specific games/mods, please create an issue request and I'll see what I can do.

For full explainations on the modules and their function, please read the documentation (originally made by Steell) here: 
https://code.google.com/archive/p/sourcemod-ultimate-mapchooser/wikis


# Installation
To install the plugin, simply download the files, unzip them, and then copy the addons and cfg folders into your game server's main directory. This will add ALL of the files into your game's "addons/sourcemod" directories. If asked to merge folders, click yes. If asked to overwrite (assuming you are using an older version), click yes. Each module/plugin has its own configuration file that will generate if not present, but for convenience, the configuration files have also been included.

The map file you need to use is called umc_mapcycle.txt (which is also provided) and it will be where you place all of your maps and any of the options/configurations for the maps. This file can be used to create multiple map groups or give some maps the ability to appear under certain conditions in the map votes/nominations list depending on the modules you choose to utilize. The umc_mapcycle.txt file MUST exist in the main directory of your game's server installation as that is where the plugin looks for this file by default. You may rename the umc_mapcycle.txt file to something else or make another mapcycle file (will obviously need to have a different name), you'll just need to specify in the appropriate configuration files (such as umc_votecommand.cfg) the name of the file you want to use. By default, it uses umc_mapcycle.txt and it is highly recommended that you only use one mapcycle file for all of the plugins. For more in depth information on each of these modules and their functions, see the links above for more info.

Please be sure to disable any other mapchooser/nominate/rtv plugins including the ones that come with Sourcemod if you plan on using this plugin!

You do not have to install ALL the plugins for this to work! Each one can be added or removed as necessary due to their modular nature (this is intentional). Just make sure to install the umc_core.smx and then install any subsequent plugins that you might need for mapvoting.

In order to gain the most out of UMC, I recommend installing/configuring the following modules for your server:

- umc-core.smx (You MUST have this plugin as it enables all the other plugin modules. UMC modules ARE NOT standalone!)
- umc-adminmenu.smx (Enables the admin menu under the sm_admin cvar)
- umc-endvote.smx (Necessary for creating a vote that appears at the end of a map)
- umc-rockthevote.smx (Required to enable UMC's rtv.)
- umc-nominate.smx (Required to allow players to nominate maps)
- umc-endvote-warnings.smx (Warnings players when a map vote will take place at the end of a map. Optional, but recommended.)
- umc-votecommand.smx (Required to allow map voting. Dictates how votes should work).
- umc-randomcycle.smx (Optional. Use this if you want the mapchooser to randomly choose the next map)
- umc-echonextmap.smx (Optional. Echos the next map that is chosen by the mapchooser)
- umc-playerlimits.smx (Optional, though recommended if you want to specify which maps appear in a vote based on how many players are on the server or in certain instances of tiered voting)

Please also note that older games/mods that run on Source 2007 may not work correctly or some functions might not be available. 

# Changelog

3.6.2 Update (11-29-2018)
-----------------
- Compiled/Updated codebase for SM 1.9
- Fixed Issue #2 ( https://github.com/Silenci0/UMC/issues/2 ) with adminvotes not displaying properly after calling a vote from the admin menu.
- Fixed (hopefully) an issue with sound precaching causing crashes in CS:GO by moving sound precaching to OnMapStart. This issue was reported in this thread: https://forums.alliedmods.net/showthread.php?t=310602
- Regarding Issue #1 ( https://github.com/Silenci0/UMC/issues/1 ):
    * This is not a bug so much as it is intentional. The umc-playerlimits.smx module is necessary for some tiered voting and groupings depending on the options used.
- Regarding Issue #3 ( https://github.com/Silenci0/UMC/issues/3 ):
    * The crashing/server lagging is mostly due to using a multitude of options with a sizeable list of maps, primarily the Display option which changes the name of the maps in the UMC voting list.
    * If possible, review your UMC mapcycle file and either 1.) remove the diplay option 2.) Remove duplicate map entries and/or 3.) Consolidate maps into fewer group categories to read from.
    * This is more of a plugin design flaw due to how the UMC plugins/modules handles a certain amount of complexities in its mapcycle file. Generally, keeping things simple will lessen the likelihood of crashes/lag from this plugin. so it

3.6.0 Update (06-11-2018)
-----------------
- Compiled/Updated codebase for SM 1.8
- Added ZPS round end and round restart support. You can now use rounds instead of relying on a game timer!
- Updated some of the code in core/utils for compatibility.
- Removed changelog from UMC core code. Please see the original plugin code for all previous change log events made by the previous author!

3.5.1 Hotfix 2 (06-18-2017)
-----------------
- Rolled back changes for AFK players. There was a bug regarding it that caused an issue where 1 player decided the next map. This issue is a bit more involved to handle, so I suggest using an AFK manager to kick afk players.
- Fixed a bug with nominated maps not displaying at the top of the mapvote correctly. Seems like an odd logic bug caused the issue.

3.5.1 Hotfix (06-04-2017)
-----------------
- Added "game_round_restart" hook so that levels could be changed via rtv at the end of a round. 
- Added logic to count only spectators, survivors, and zombies in votes (RTV, round-end, etc) for ZPS. This change effectively stops counting AFK players and does not allow them to vote if they are in the waiting room (team 0) or have somehow managed to change to team 4 (which is the cops team, something left over from another time).
- Recompiled all plugins so that the changes made in umc_utils.inc would be applied. Please update all the plugins being used for your servers!
- Special thanks to Tango and the Davidian guys for catching all of this. 
- NOTE: Due to the changes for who gets counted in the votes, this may have unintended effects in other games if used there. I will begin working on a better/more logical way to handle AFK players and, perhaps, create a cvar to handle this functionality at a later date.

3.5.1 Update (03-28-2017)
-----------------
- Fixed a conflict in cvars for nomination display. This most likely caused a bug with both display of the message and the display on the vote menu.
- Created new config cvar sm_umc_nommsg_display for chat display of which maps were nominated
- Created new config cvar sm_umc_mapnom_display for display position in the vote menu (top or bottom)
- Fixed a logic error involving nominiation map display.
- Recompiled plugins (still uses 1.7.3 Sourcemod) and added cvars to configuration file.

3.5.0 Initial/Update (10-16-2016)
-----------------
- Added a number of changes from 3.4.6-dev (done by powerlord) to the plugin (including 1.7.3 Sourcemod support). Original version by Steell.
- Added ZPS support.
- FindMap changes from 3.4.6 removed due to incompatiblities with older games or games that do not use workshop.
- Removed all updater code. This plugin no longer supports updater.
- Added GNU/GPL headers to all plugins.
- Added Nomination display cvar to plugin. You can now display map nominations at the top or bottom of the vote list.
- Commented out all DEBUG_MESSAGE portions of code in of all plugins. This should remove any unnecessary debug/log messages for better efficiency.
- Re-tabbed all code in code files. 1 Tab = 4 whitespaces.
- Fixed many error messages coming from the code.
- General clean up of some code files (not all required this, some code changes did not take place).
- Recompiled for Sourcemod 1.7.3
- While changes were mainly for ZPS, its still the same UMC. All relevant information is here: https://forums.alliedmods.net/showthread.php?t=134190