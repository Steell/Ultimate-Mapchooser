# NOTICE: UMC is Unsupported
Hello everyone,

TL;DR: I will no longer be supporting UMC as a project and I will not be responding to issues/pull requests either. As it stands, it works as long as you are not trying to be too complex with the plugins or have large map lists of 100+ maps, but some features do not work as well as they could and it does not completely work with Workshop maps in its current form. If you wish to take on the project, please go ahead and fork the repo and do whatever you wish with my permission/blessing/whatever (you do not need to contact me!). Good luck! 

During February 2020, I had made a PSA notice in the issues section regarding an indefinite hiatus (see that post here: https://github.com/Silenci0/UMC/issues/20 ) due to a number of personal reasons among other world events that made things more difficult to continue doing modding for things such as UMC, at least for me. A lot of things have changed since then, but I am still not working on UMC. What little I did do for modding between now and then has only been for ZPS, but only just barely. However, when it came to bigger projects such as this, I simply did not have the time, patience, or ability/drive to continue even during the free time that I had. 

With that in mind, I want to make it clear: I will no longer support UMC now or in the future. Someone else will need to do so, if they wish to continue working on UMC that is. This DOES NOT mean the repo will be deleted (I want people to still fork from it and look at any issues still open/unsolved), I just won't be working on the plugin anymore or responding to any messages.

While I like the robust features of UMC as well as the idea behind it, keeping up with UMC has been its own chore. It has many problems with "newer" ways of dealing with maps (particularly dealing with workshop maps over fastdownload) and a number of bugs that come with its feature set that sometimes end up with fixes that cause more problems than solutions. On top of this, trying to fix UMC is a much more difficult task because of how UMC itself works, which requires work arounds and changes that may compromise certain aspects of the plugins design (which goes back to the fixes causing more problems than solutions). It still works, for the most part, but its obvious it has a lot of flaws and there are a number of cases where a particular feature ends up not working the way it should or the way most people would like. At this point, it would almost be simpler to build/design a whole new plugin for mapchoosing that attempts to have the same features as UMC without using the same design/backbone (paricularly, the overuse of keyvalues) as UMC does, but that too is its own job and if it were something that could be easily done, it would have been done years ago. That is not to say that it isn't possible, but to replicate the robust features of UMC while not relying on UMC's designs would take a little bit more elbow grease than most realize. 

For those who wish to take over the project for themselves, feel free to fork this repo and do whatever you want with my permission (not that you needed it, its open source for a reason, but you don't need to contact me if you do). But be warned that UMC has a number of issues to deal with and some of the features may need fixed, updated, or even revised, which might take some work. Ultimately, dealing with workshop maps is the biggest downside this plugin has since it does not work well and I'm not sure how to fix it without completely ripping out the system UMC uses via keyvalues (which is why I said it would be simpler to make a new plugin). If you don't care about workshop maps and are only focusing support on the fastdownload methodology, then your job is much simpler, but it still requires some work to fix. Either way, if you take this project on, you are in for some work.

For users that like using UMC, know that it still works, but it has constraints. The wiki for this repo has a recommended plugin section that you should follow and I suggest allowing for map nominations rather than group nominations. Use the map groups to help divide maps into categories for uses to choose from when nominating a map, but let the map plugins throw out some maps + player nominations to vote on. Have smaller map lists with a list of maps that players can choose from in UMC (you can still have a lot of maps on your server and can change to maps that aren't on the UMC maplist, just don't bog down your UMC maplists with 100+ maps!). Overall, this plugin works well if you aren't trying to be too complex about how you want your maps chosen. It does not like workshop maps so your best bet is using fastdownload for everything when using UMC. I do not have a recommended replacement map chooser plugin as an alternative for UMC. Unless one came out recently, I don't know of any others outside of the SM mapchooser and the Mapchooser Extended.

I hope this clears up any uncertainty about this version of UMC and its future (or lackthereof). Thanks for the support and messages over the years!



# UMC
Ultimate Map Chooser.

This plugin is design to be a more complex mapchooser plugin that can be used to create various map lists to vote from. While it has all the standard map voting items (rtv, nominate, etc.) it also has some complexity in that you can set special conditions (such as player thresholds) for certain maps, which can help introduce some maps when a server is more full or allow users to pick ones based on map prefix, gamemode, and other such things.

For full explainations on the modules, their functions, plugin installation instructions, game compatability, and other information regarding UMC, please refer to the github wiki found here: https://github.com/Silenci0/UMC/wiki


# Changelog
3.7.1 Update (11-09-2019)
-----------------
- Updated functag functions to typedefs in umc-core.inc to be inline with changes presented in SM 1.10.
    * For those curious, SM 1.10 introduces more Transitional Syntax improvements that are replacing old functionality. For more info regarding the Transitional API, please see their wikipage here: https://wiki.alliedmods.net/SourcePawn_Transitional_Syntax
- Updated the maprate-reweight plugin to use SQL_EscapeString instead of SQL_QuoteString due to it being depreciated.
- Recompiled all UMC plugins for SM 1.10 

3.7.0 Update (08-14-2019)
-----------------
- Restored 3.4.6's GetMapDisplayName code to UMC for better workshop support. This was taken out initially due to an incompatibility with ZPS 2.4 (back when this fork of the plugin was being used exclusively for that game).
    * Currently, workshop support should work in CS:GO for Windows, however TF2 (all platforms) and CS:GO Linux will not work at this time.
    * For more information on workshop support, formatting, and current status/info see the FAQ wiki page: https://github.com/Silenci0/UMC/wiki/FAQ
- Added sm_umc_nominate_duration cvar to umc-nominate plugin to determine how long the menu display can stay open for. This addresses this issue: https://github.com/Silenci0/UMC/issues/8
    * Added the cvar to the umc-nominate.cfg config file for convenience purposes.
- Added French translation by nobody-x (From pull request on Steell's plugin here: https://github.com/Steell/Ultimate-Mapchooser/pull/43)
- Added Polish language fix by Nerus87 (From pull request on Steell's plugin here: https://github.com/Steell/Ultimate-Mapchooser/pull/51)
- Added an updated umc-nativevotes plugin and the associated nativevotes files/plugins to UMC. 
    * Native votes will only work with TF2 at this time (this was where it was tested). I believe it might work with ZPS, L4D, and L4D2 but it WILL NOT WORK with CS:GO currently.
    * Native votes for UMC utilizes the latest plugin files from https://github.com/powerlord/sourcemod-nativevotes
    * For convenience purposes, only the necessary nativevotes files from the above repo (script files, plugins, and configurations) are included.
    * Please be aware that, unlike old style menus, native votes only provides 5 options in the vote selection when the actual voting process begins.
    * If you want to have old style menus or are running a game that does not use fancy vote panels, simply remove the nativevotes plugins (umc-nativevotes.smx and nativevotes.smx). No recompiling/coding necessary!
- Updated umc chat command in umc-core to only print to the player instead of to everyone on the server when invoked (From pull request on Steell's plugin here: https://github.com/Steell/Ultimate-Mapchooser/pull/47).
- Updated all UMC configuration files and the umc_mapcycle.txt file with updated links to the wiki: https://github.com/Silenci0/UMC/wiki 
- Removed the color codes (ie: \x03 and \x01) from the [UMC] tags for all modules. This is to make more generalized messages without color codes added to them. 
- General code clean up of all includes/source files. Attempting to keep things more readable/consistent in the code.
- Recompiled all plugins for the latest version of UMC.

3.6.2 Wiki Update (01-23-2019)
-----------------
- No code changes, just updated the wiki and README.md file with proper links.

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
