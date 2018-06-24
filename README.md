# UMC
Ultimate Map Chooser plugin

NOTE: You do not have to install ALL the plugins for this to work! Each one can be added or removed as necessary due to their modular nature (this is intentional). Just make sure to install the umc_core.smx and then install any subsequent plugins that you might need for mapvoting and such and go from there.

Please read the documentation here on the plugin: 
https://code.google.com/archive/p/sourcemod-ultimate-mapchooser/wikis
http://www.vertigogaming.org/wiki/index.php/UMC_Plugin

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