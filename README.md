# UMC
Ultimate Map Chooser plugin

3.5.1 Update Commit (03-28-2017)
-----------------
- Fixed a conflict in cvars for nomination display. This most likely caused a bug with both display of the message and the display on the vote menu.
- Created new config cvar sm_umc_nommsg_display for chat display of which maps were nominated
- Created new config cvar sm_umc_mapnom_display for display position in the vote menu (top or bottom)
- Fixed a logic error involving nominiation map display.
- Recompiled plugins (still uses 1.7.3 Sourcemod) and added cvars to configuration file.

3.5.0 Initial/Update Commits (10-16-2016)
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