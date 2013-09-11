/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                  Ultimate Mapchooser - Core                                   *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#define RUNTESTS 0

//Dependencies
#include <umc-core>
#include <umc_utils>
#include <sourcemod>
#include <sdktools_sound>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-core.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-core.txt"
#endif

//Some definitions
#define NOTHING_OPTION "?nothing?"
#define WEIGHT_KEY "___calculated-weight"

//Plugin Information
public Plugin:myinfo =
{
    name        = "[UMC] Ultimate Mapchooser Core",
    author      = "Steell",
    description = "Core component for [UMC]",
    version     = PL_VERSION,
    url         = "http://forums.alliedmods.net/showthread.php?t=134190"
};

//Changelog:
/*
 3.4.5 (10/7/2010)
  Added initial support for CS:GO.
  Improved error handling with overlapping votes.
  Group votes with only one group available will now trigger a map vote, containing maps from the group.
  Fixed bug with selective runoff votes trying to send the vote menu to invalid clients.
  Fixed bug where Random Mapcycle would select a map after the map has been selected and ended due to instant mapchange from a vote.
  Fixed memory leak in certain error cases.
  Improved error handling in situations with an invalid mapcycle handle.

 3.4.4 (9/1/2012)
  Fixed issue where End of Map Votes determined by mp_maxrounds would not start.

 3.4.3 (8/31/2012)
  Fixed issue where map changes were happening too early.
  Added support for CS:GO mp_match_can_clinch convar.
  Improved German language translation. (Thanks elninjo!)

 3.4.2 (8/26/2012)
  Fixed issue where all RTV votes would count as bonus votes if no bonus flags were set.
  Added support for changes in GoldenEye: Source
  Immediate map changes will now attempt to end the round immediately instead of just changing the map.
  Cleaned up some log statements.
  Fixed potential crashing issue.
  When the next map is set, the "nextmap" cvar is now also updated.

 3.4.1 (8/4/2012)
  Added ability for admins to count extra towards entering an RTV.
  -New cvars "sm_umc_rtv_enteradminflags_bonusflags" and "sm_umc_rtv_enteradminflags_bonusamt" to control this feature
  Updated End of Map Vote so that changes in mp_timelimit after a vote has failed will restart the timer.
  Added group-wide exclusion to Post-Played Exclusion
  -New "group_allow_every" option for Map Groups specifies how long before the group can be played again.
  -"default_allow_every" still assigns "allow_every" for each map
  -Maps can override a group's "group_allow_every" setting, which will affect the entire group
  -If a map has an "allow_every" setting, it overrides the "group_allow_every" setting, but just for the map.
  Fixed issue with second stage of multistage votes sometimes not working.
  Fixed odd crashing issue (I think).

 3.4 (7/22/2012)
  Modified Map Commands:
  -"pre_command" now fires at Map End
  -"postvote_command" fires when map is set as next map by UMC
  -"command" has not changed and still fires at the start of the map
  Added ability to specify different map change times for End of Map Votes
  -New cvar "sm_umc_endvote_changetime" to control this ability.
  Added advanced template system for map names.
  -New templates: {NOMINATED}, {MIN_PLAYERS}, {MAX_PLAYERS}, {MIN_TIME}, {MAX_TIME}, {RATING}
  -New cvar "sm_umc_nomination_display" in ultimate-mapchooser.cfg
  Added Map Start indicator to UMC logs.
  Fixed RTV entrance threshold so that admin flags are taken into account.
  Fixed Non-Selective runoff votes so that admin flags are taken into account.
  Fixed issue where Extend Map and Don't Change options would not appear in Group votes.
  Fixed issue where nominating a map via chat with an argument would display incorrect information.
  Fixed rare issue where clients connecting could get recently-disconnected clients' votes.
  Fixed memory leak with nominations
  Moved source code repository to GitHub.

 3.3.2 (3/4/2012)
  Updated UMC Logging functionality
  -All UMC logging is placed in it's own log files (prepended with UMC)
  -Verbose logs now also log:
  --The layout of the vote menu
  --All clients in the vote
  --What each client voted for, at the time they voted
  Added ability for Random Mapcycle to select the next map at the start of the game.
  -New cvar "sm_umc_randcycle_start" to control this ability
  Added ability to view the current mapcycle of all modules
  -New admin command "sm_umc_displaymaplists" to control this ability
  Added ability to make the first slot in the vote a "No Vote" button. (thanks Azelphur!)
  -New cvar sm_umc_votemanager_core_novote to control this feature.
  Fixed issue where extend map wasn't working with BuiltinVotes
  Fixed issue where bots were being included in votes.
  Various other small fixes.

 3.3.1 (12/13/2011)
  Updated sm_umc_rtv_postvoteaction cvar to allow for normal RTV votes after a vote has taken place.
  Fixed issue where errors were being logged accidentally.
  Fixed issue where cancelling a vote could cause errors (and in some cases cause voting to stop working).
  Fixed issue where Selective Runoff was always enabled.
  Fixed issue where channging the map when the round ends could cause it to change instantly.

 3.3 (11/17/11)
  Slot blocking functionality has been changed. Modules now cannot specify how many slots they want blocked. All slot blocking is not controlled by core.
  -New cvar "votemanager_core_blockslots" has been added to control this feature in Core.
  -All "blockslots" cvars in various UMC modules have been removed.
  Vote Manager support placeholder has been added. Next version will allow modules to specify their own VM IDs.
  New cvar "sm_umc_votemanager_core_blockslots" has been added. With this update, the ability to specify how many slots to be blocked on a per-module basis has been removed. This cvar will be used for all cases where block slots are added to votes. (This means that the blockslots cvars in the various module .cfgs are now meaningless, and can be removed if you so desire).
  Removed "runoff_blockslots" cvar. Runoff votes will always use the same BlockSlot setting as is used normally.
  Added new Extend Command cvar, used to specify a command to be executed when a map is extended.
  -New cvar "extend_command" in ultimate-mapchooser.cfg to control this feature.
  Fixed issue with Random Mapcycle module which caused "next_mapgroup" option to be ignored.
  Fixed rare memory leaks.

 3.2.4 (10/12/11)
  Added Auto Updating support.
  Added new feature to the End of Map Vote module that delays a vote for a certain amount of time after it is triggered due to a round ending.
  -New cvar "roundend_delaystart" to control this feature.
  Fixed bug in Player Count Monitoring where an incorrect translation phrase was breaking Yes/No votes.

 3.2.3 (9/17/11)
  Updated Map Rate Map-Reweighting module to conform with the new Map Rate RELOADED cvars.
  Fixed issue in TF2 where maps ending due to the mp_winlimit cvar would not trigger Random Mapcycle map selection.
  Fixed issue with Tiered Votes where "Extend" and "Don't Change" options were not properly handled.

 3.2.2 (8/11/11)
  Added new Post-Played Exclusion module, giving the ability to specify a period of time after a map is played that it should be excluded. (Thanks Sazpaimon!)
  Fixed bug which caused runoff votes to fail immediately when maximum amount of runoffs is set to 0 (infinite).
  Fixed issue with invalid translation phrase in the ADMINMENU module.
  Fixed issue with portugese translation.
  Fixed issue where the option to change the map immediately was not working in Player Count Monitor.
  Fixed issue with translation phrase which caused max player threshold to not trigger. PLAYERCOUNTMONITOR

 3.2.1 (7/4/11)
  Fixed issue where previously played groups were not being removed from the mapcycle.
  Optimized vote menu population.

 3.2 (7/2/11)
  Modified previous exclusion so that it is performed at the start of the map.
  Fixed issue where tiered votes would not work correctly when started via the admin menu and exlusion is ignored.
  Changed previous-map exclusion so it doesn't automatically exclude the current map. If cvar is set to 0, the current map will not be excluded.

 3.1.2 (6/24/11)
  Disabled Prefix Exclusion by default.
  Fixed issue with Map Votes not starting when there are no nominations.
  Fixed issues where cancelled votes could cause memory leaks.

 3.1.1 (6/23/11)
  Fixed translation typo in Admin Menu
  Fixed translation bug in Admin Menu
  Fixed issue where admin flags would sometimes cause votes not to appear.
  Fixed bug in the Admin Menu where Stopping an active vote would do nothing.

 3.1 (6/22/11)
  Added new map option to associate a nomination with a different group.
  -New "nominate_group" option at the map-level of the mapcycle definition.
  Added admin flag for ability to see vote menu.
  -New "adminflags" cvar in ADMINMENU, ENDVOTE, PLAYERCOUNTMONITOR, ROCKTHEVOTE, and VOTECOMMAND.
  Added admin flag for ability to enter rtv. [RTV]
  -New "enteradminflags" cvar in RTV.
  Added ability to specify flags for maps, limiting which players can nominate them.
  -New group and map option in mapcycle "nominate_flags" to specify flags.
  -New cvar "adminflags" in NOMINATE to set default.
  Added ability to specify flags for maps, limiting which admins can select them in the admin menu.
  -New group and map option in mapcycle "adminmenu_flags" to specify flags.
  Added admin flags for admins who can ignore map exclusion in the admin menu.
  -New cvar "sm_umc_am_adminflags_exclude" to control this feature.
  Added admin flags for admins who can override default settings in the admin menu.
  -New cvar "sm_umc_am_adminflags_defaults" to control this feature.
  Added mp_winlimit-based vote warnings. [ENDVOTE-WARNINGS]
  Turned basic time-based vote warnings on by default.
  Added ability for sound to be played during countdown between Runoff/Tiered votes. [CORE]
  -New "sm_umc_countdown_sound" cvar to specify the sound.
  Added ability to specify a default weight for maps that do not have enough Map Rate ratings. [MAPRATE-REWEIGHT]
  -New "sm_umc_maprate_default" cvar to control this feature.
  Fixed bug with nominations not using group exclusion settings.
  Fixed bug with nominations not passing their own mapcycle to forwards.
  Fixed bug with tiered nomination menu excluding groups unnecessarily.
  Fixed memory leak when parsing nominations for map group vote menus.
  Fixed bug which could cause groups with no valid maps to be added to group votes.
  Fixed bug in Prefix Exclusion which caused prefixes to be excluded even when the memory cvar was set to 0.

 3.0.8 (6/11/11)
  Fixed bug where sometimes only the first map group would be processed for map exclusions.

 3.0.7 (6/10/11)
  Changed default value for all threshold cvars to 0.
  Added standard mapcycle feature; if given a special header, regular one-map-per-line mapcycles can be used with UMC.
  Fixed bug that was causing "handle is invalid" error messages when runoff votes fail and thair failaction is set to consider the vote a success.
  Fixed issues with Polish translation.
  Modified exclusion algorithm when generating vote menus, should allow for nominations to be added to empty groups.
  Heavily modified internal nomination system.
  Fixed memory leak when mapcycle files can not be found.

 3.0.6 (6/7/11)
  Changed minimum value of the sm_umc_maprate_expscale cvar to 0. [MAPRATE-REWEIGHT]
  Fixed bug in Player Count Monitoring where it couldn't auto-detect the current group. [PLAYERCOUNTMONITOR]
  Fixed bug where errors could be caused by group exclusion code.
  Heavily optimized debugging system, should result in execution speedup.
  Optimized umc-maprate-reweight to fetch map weights in O(1) as opposed to O(n)
  Added more debug messages.

 3.0.5 (5/29/11)
  Fixed bug where individual clients cancelling a vote menu could break tiered and group votes.

 3.0.4 (5/28/11)
  Added experimental admin menu module. [ADMINMENU]
  Fixed rare bug with tiered nomination menus displaying groups with no maps in it. [NOMINATIONS]
  Fixed bug where error log would be spammed with KillTimer errors (finally). [ENDVOTE]
  Fixed bug where endvotes would not work in games without certain cvars. [ENDVOTE]
  Made map weights of 0 automatically exclude maps from selection. [WEIGHT]
  Updated various documentation.
  Minor Optimizations.

 3.0.3 (5/23/11)
  Added ability to specify amount of times a prefix can be in the previously played prefixes before it is excluded.
  -New cvar "sm_umc_prefixexclude_amount" in umc-prefixexclude to control this feature.
  Fixed bug where endvotes would not appear after a map was extended. [ENDVOTE]

 3.0.2 (5/22/11)
  Fixed bug with previously played map exclusion in second stage tiered vote.
  Fixed bug where nominated maps were not being excluded from votes properly.
  Fixed bug where group votes would pick a random map group to be the next map.
  Optimized map weight system so each map is only weighted once.
  Made modules with previous map exclusions search for the current group if core reports it as INVALID_GROUP.
  Added ability to specify a scale for umc-maprate-reweight
  -New cvar "sm_umc_maprate_expscale" in umc-maprate-reweight to control this feature.
  Added ability to make all votes use valve-syle menus (users press ESC to vote).
  -New cvar "sm_umc_menu_esc" in umc-core to control this feature.
  Made center message in umc-echonextmap last for at least 3 seconds.
  Sequences of warnings can now be defined using a dash (-) as well as an elipses (...).
  Added new Map Prefix Exclusion module (umc-prefixexclude).

 3.0.1 (5/18/11)
  Added extra argument to sm_setnextmap that specifies when the map will be changed.
  Added response to the reload mapcycles command.
  Fixed bug with map exclusion in tiered votes.

 3.0 (5/16/11)
  Near-complete rewrite of UMC. Divided up plugin into separate modules which operate independently. These modules are linked together through UMC's Core (this file).
  Fixed many, many bugs with the rewrite. I will only be listing the ones I know have been fixed.
  Fixed bug with Tiered Votes sometimes not displaying the second vote due to an invalid mapcycle.
  Fixed bug with Map Group Exclusion not working correctly.
  Fixed bug with Map Exclusion sometimes not working correctly.
  Implemented support for "mp_winlimit" triggered end of map votes.
  When UMC sets the next map, it can now be displayed in Center and Hint messages.
  -New "sm_umc_echonextmap_hint" and "sm_umc_echonextmap_center" cvars to control this ability.
  Added "next_mapgroup" to maps in the definitions, not just the groups anymore.
  Added ability to delay end of map votes so they will only appear at the end of rounds.
  -New "sm_umc_endvote_delayroundend" cvar to control this ability.
  Added command to display how maprate-reweight will be reweighting maps.
  Implemented developer's API, but it is not yet fully supported (in case I decide I need to make changes).
  Probably more, I really should have kept track.

 2.5.1 (5/5/11)
  Added color to the [UMC] prefix in say messages.
  Added German translation (thanks Leitwolf!)
  Added Polish translation (thanks Arcy!)
  Fixed minor issue with Random Selection of the Next Map not excluding maps correctly.
  Fixed minor issue with Player Limits that was generating errors.
  Fixed issue with "next_mapgroup" where it didn't properly check for excluded maps.
  Fixed bug with max runoff votes not working as intended.
  Implemented pre-command.

 2.5 (4/3/11)
  Added new feature: you can specify a maximum number of maps to appear in runoff votes.
  -New "sm_umc_runoff_max" cvar to control this ability.
  Players are now allowed to change their nomination.
  Fixed bug where the map group configuration is not set properly.
  Fixed tiered nomination menu where groups with no maps were still displayed.
  Fixed bug where the sm_umc_mapvote command would change to an invalid map if nobody voted.
  Added prevention code for various errors, not sure if it will fix them since I can't reproduce them.
  Optimized memory usage in adt_arrays with Strings.
  Added placeholders for "pre-command" support.

 2.4.6 (3/25/11)
  Fixed bug where having the same map in one group could cause a crash.
  Fixed errors where delays between votes (runoff and tiered) could cause errors if the map ends during them.
  Added dynamic reweight system, allowing other plugins to affect the weight of maps in UMC.

 2.4.5 (3/20/11)
  Disabled exit button on runoff votes.
  Made runoff votes use proper pagination (< 9 options = no pagination [Radio Style Menus only])

 2.4.4 (3/18/11)
  Fixed issue where an extension could cause multiple votes.

 2.4.3 (3/16/11)
  Fixed issue with second stage tiered votes not limiting maps to the winning map group.

 2.4.2 (3/9/11)
  Modified sm_umc_mapvote command to take an argument specifying when to change the map after the vote.
  Fixed issue with excluding previously played maps.
  Fixed issue with random selection of the next map excluding previously played maps.

 2.4.1 (3/7/11)
  Fixed bug that caused runoff votes to never have a maximum.
  Fixed bug that prevented some runoff votes from working correctly.

 2.4 (3/7/11)
  Made delay between votes (tiered and runoff) countdown to zero as opposed to one.
  Fixed bug that disabled RTVs and Random Selection of the Next Map if a vote occurs and there are no votes.
  Fixed bug with auto-pagination that broke votes with 8 or 9 items in HL2DM (and other mods that don't support Radio menus).

 2.3.4-beta3 (3/6/11)
  Made nomination menu not display maps from a map group if the strict cvar is on and enough maps have already been nominated to satisfy the maps_invote setting.
  Fixed selective runoff votes so they take into account previous votes (from before the runoff).

 2.3.4-beta2 (3/3/11)
  Added ability for map votes to allow duplicate maps. This is useful for people running votes where the same map may appear for different mods.
  -New sm_umc_vote_allowduplicates cvar to control this ability
  Added ability to filter the nomination menu based off of what maps should be excluded at the time it's displayed.
  -Removed sm_umc_nominate_timelimits cvar
  -New sm_umc_nominate_displaylimits cvar to control this ability
  Fixed cases where ignorelimits was not working.
  Code refactoring

 2.3.4-beta1 (3/2/11)
  Fixed bug with Yes/No Playerlimit vote where a tie would result in garbage display.
  Fixed bug where two RTVs could happen, one right after another, if enough people enter RTV during an RTV.
  Made nomination menu not close automatically.
  Fixed behavior of ignorelimits cvars and nominations.

 2.3 (2/24/11)
  Added client-side translations to all menus.
  Added optional "display" option to map definitions, and "display-template" option to map group definitions.
  Added ability to display nomination menu in tiers -- first select a group, then select a map.
  -New cvar to control this feature.
  Added ability to disable Map Exclusion for end-of-map votes, RTVs, random next map, and nominations.
  -Four new cvars to control this feature.
  Made all votes attempt to retry to initiate in the event they are blocked by a vote that is already running.
  Added call to OnNominationRemoved forward in all appropriate places.
  Modified nomination code in map group votes to not exclude the group if there were nominations for maps in it.
  Fixed odd bug where a vote would display garbage if there was a map group with a cumulative weight of 0.

 2.2.4 (2/21/11)
  Fixed bug with center message warnings.
  Fixed bug with runoff votes being populated with the wrong maps.
  Fixed bug with runoff votes not paying attention to the threshold cvar.
  Fixed bug with end of map vote timer that caused errors when the timelimit was changed.

 2.2.3 (2/19/11)
  Fixed bug that completely screwed up vote warnings.

 2.2.2 (2/19/11)
  Fixed bug that caused all time-based vote warnings to appear at 0 seconds.

 2.2.1 (2/18/11)
  Fixed problem with default min and max players for groups not being read correctly.

 2.2 (2/18/11)
  Added vote warnings support for frag and round limits.
  -Removed sm_umc_endvote_warnings cvar
  -Added three new cvars to control the feature: 1 each for time, frag, and round warnings.
  Added mapchooser's "sm_setnextmap" command.
  Changed required admin flag for commands from ADMFLAG_RCON to ADMFLAG_CHANGEMAP.
  Added prevention measures from starting RTVs during delay between runoff and tiered votes.
  Changed event hooks to act more like original mapchooser (may fix weird round_end bugs).
  Fixed "nextmap" chat command functionality.
  Fixed bug with end of map vote that prevented frag limit from triggering it.
  Fixed bug that required mapchooser to be enabled.
  Fixed rare memory leak with map exclusion algorithm for map groups with no maps defined.

 2.1 (2/17/11)
  Added support for mapchooser's natives.
  Added customization for how runoff and tiered vote messages are displayed.
  Fixed memory leak with nominations that are not added to votes.
  Fixed memory leak with map exclusion algorithm.

 2.0.2 (2/15/11)
  Fixed (another) obscure bug with Runoff Votes, this time preventing map change.

 2.0.1 (2/14/11)
  Fixed obscure bug with Runoff Votes that prevents a vote from starting.

 2.0 (2/13/11)
  Added new "command" option to map groups and maps defined in the mapcycle. The strings supplied will be executed at the start of the map.
  Added some code optimizations.
  Improved logging.
  Added ability for plugin to search for a map's player limits if the map wasn't changed by the plugin.
  Fixed bug with Tiered Votes where votes would fail if the winning group had only one available map.
  Fixed bug with data not being cleared when a vote menu fails to be created.
  Fixed bug with "rockthevote" chat triggers not working.
  Fixed bug with vote warnings where mp_timelimit was 0.
  Fixed bug where strict nominations would sometimes cause duplicate vote entries.
  Fixed bug where player limits would stop working.
  Fixed bug with group voting where if a nominated map won the winning map wasn't set correctly.
  Fixed memory leak with checking for maps with proper time and player counts.
  Organized code

 2.0-beta (2/5/11)
  Added Runoff Vote feature. If a vote end and the winning option is less than a specified threshold, another vote will be run with losing options eliminated.
  -Added cvar to control max amount runoffs to run (> 0 enables the feature)
  -Added cvar to control the threshold required to prevent a runoff
  -Added cvar to control which sound is played at the start of a runoff
  -Added cvar to specify whether runoffs are shown to everyone or just players who need to (re)vote.
  Added Tiered Votes. If enabled, first players will vote for a category, and then they will vote for a map from that category.
  -Modified type cvars to allow for this kind of vote.
  -Added cvar to control how many maps are displayed in the vote (after a category is already selected).
  Added ability to exclude previously played categories.
  -Three new cvars to control this ability.
  Added ability to specify how many slots to block (up to 5)
  -Modified blocking cvar to allow for this customization.
  Internationalisation - Translations are now supported.
  Votes will now only paginate when there are more than 9 slots required in the menu.
  Added optional auto-updating.
  Fixed memory leak with Random Selection of the Next Map.
  Fixed memory leak with Vote Warnings.
  Fixed bug with Vote Warnings not working after a map change.

 1.5.1 (1/26/11)
  Added shortcut to vote warnings that allows users to specify a sequence of warnings with one definition.
  Fixed issue with time restrictions that prevented max_time from being larger than min_time (necessary for, as an example, 11:00PM - 6:00AM, which would be min_time: 2300  max_time: 0600)
  Changed name of plugin from Improved Map Randomizer (IMR) to Ultimate Mapchooser (UMC)

 1.5 (1/24/11)
  Added vote warning feature. You can now specify warnings which appear to players before an end-of-map vote. Warnings are fully customizeable.
  -New cvar to enable/disable this feature.
  Added vote sounds. Cvars specify sounds to be played when a vote starts and completed.
  -Four new cvars, 2 for end-of-map votes and 2 for RTVs
  Added time-based map selection. New "min_time" and "max_time" options added to maps in "random_mapcycle.txt".
  Made votes with less than 10 items not have a paginated menu.
  Added more chat triggers for RTV. Now accepts: rtv, !rtv, rockthevote, and !rockthevote.
  Fixed memory bug with tracking min/max players for a map.
  Fixed bug with nominations where some categories stopped appearing in the menu.
  Fixed bug with strict nomination cvar and populating votes.
  Fixed bug with random group selections where groups with all their maps having been played recently and still excluded would still appear in votes.
  Literally commented the entire plugin source code thoroughly. Happy reading!

 1.4.1 (8/27/10)
  Fixed bug in some mods where random selection of the next map was not being triggered.

 1.4 (8/13/10)
  Added separate options for when the max player limit and min player limit of the current map is broken.
  -Two new cvars to control this feature.
  -Old cvar removed.
  Added a delay before the plugin checks to see if the current map has a valid number of players.
  -New cvar to control this feature.
  Added the ability to limit the number of nominations appearing in a vote to the number specified by that group's "maps_invote" setting.
  -New cvar to control this feature.

 1.3 (8/10/10)
  Added vote slot blocking feature. When enabled, the first four vote slots are disabled to prevent accidental votes.
  -New cvar to control this feature.
  Fixed issues with displaying certain text to clients.
  Improved error handling when rotation file is invalid.

 1.2 (8/8/10)
  Fixed bug where "next_mapgroup" was not working properly with votes.
  Fixed bug where current map was appearing in nomination menu.
  Added feature where if the current players on the server is not within the range defined by the current map's "min_players" and "max_players", the map can be changed.
  -Two new cvars to control this feature.
  Nominations now work with group votes.
  -When a group wins the vote, it selects a random map from the nominations for that group, taking into account the weights of the maps.

 1.1.3 (8/5/10)
  Fixed memory bug with nominations.
  Fixed (another) bug where random selection of the next map would not work properly.
  Added ability to include a "Don't Change" option in RTVs.
  -New cvar to enable/disable this ability.
  -New cvar to control the delay between an RTV where "Don't Change" wins and the ability for players to RTV again.

 1.1.2 (8/4/10)
  Fixed bug in DOD:S where plugin could not start due to missing "mp_maxrounds" cvar.

 1.1.1 (8/3/10)
  Fixed bug where rounds ending would trigger end of map votes even after one was already triggered.
  Fixed bug where frags would trigger end of map votes even after one was already triggered.
  Fixed bug where current map would appear in votes.
  Fixed bug where random selection of the next map would not work properly.

 1.1 (8/2/10)
  Added public cvar for tracking.
  Modified nominations
  -Nominations menu now contains all maps in rotation. Nominated maps will now be rejected when considered for inclusion in the vote. This way, players can nominate maps which may be valid when it's time to vote, even if they aren't valid at time of nomination.

 1.0 (8/1/10)
  Initial Release
*/

//TODO / IDEAS:
/*
 Keep track of clients between votes by storing them as userids OR steamids.
     -Possibility of SteamIDs due to how visual vote operates.

 Natives take an array of clients rather than a string of flags.

   New "next_map" map command, works with "next_mapgroup".
       -If next_map is set but next_mapgroup isn't, the current group is assumed.
       -If next_map is not set but next_mapgroup is, then a map is selected at random from the group.
       -If neither are set, a random map from a random group is selected.

 Need to find a cleaner/clearer way to handle case where nominations are only used in certain modules.
     -Solution 1: new "display-group" option that mimicks the "display" option for maps (but this is for groups).
     -Solution 2: implement mapcycle-level options (to complement group and map options).

 Take nominations into account when selecting a random map.
 Add cvar to control where nominations are placed in the vote (on top vs. scrambled)
 Possible Bug: map change (sm_map or changelevel) after a vote completes can set the wrong 
               current_cat. I'm not exactly sure how to fix this.
               PERHAPS: store the next map, when the map changes compare the current map to the one we have
                        stored. If they are different, set the current_cat to INVALID_GROUP.
 New mapexclude_strict cvar that doesn't take map group into account when excluding previously played maps.
 In situations where we're filtering a list of map tries (map/group tries) for a specific
     group, it may be easier to store it instead as a trie of groups, where each group points
     to a list of maps. 
 */

//BUGS:

//************************************************************************************************//
//                                        GLOBAL VARIABLES                                        //
//************************************************************************************************//

    ////----CONVARS-----/////
new Handle:cvar_runoff_display      = INVALID_HANDLE;
new Handle:cvar_runoff_selective    = INVALID_HANDLE;        
new Handle:cvar_vote_tieramount     = INVALID_HANDLE;
new Handle:cvar_vote_tierdisplay    = INVALID_HANDLE;
new Handle:cvar_logging             = INVALID_HANDLE;
new Handle:cvar_extend_display      = INVALID_HANDLE;
new Handle:cvar_dontchange_display  = INVALID_HANDLE;
new Handle:cvar_valvemenu           = INVALID_HANDLE;
new Handle:cvar_version             = INVALID_HANDLE;
new Handle:cvar_count_sound         = INVALID_HANDLE;
new Handle:cvar_extend_command      = INVALID_HANDLE;
new Handle:cvar_default_vm          = INVALID_HANDLE;
new Handle:cvar_block_slots         = INVALID_HANDLE;
new Handle:cvar_novote              = INVALID_HANDLE;
new Handle:cvar_nomdisp             = INVALID_HANDLE;

//Stores the current category.
new String:current_cat[MAP_LENGTH];

//Stores the category of the next map.
new String:next_cat[MAP_LENGTH];

//Array of nomination tries.
new Handle:nominations_arr = INVALID_HANDLE;

//Forward for when a nomination is removed.
new Handle:nomination_reset_forward = INVALID_HANDLE;

//
new String:countdown_sound[PLATFORM_MAX_PATH];

/* Reweight System */
new Handle:reweight_forward = INVALID_HANDLE;
new Handle:reweight_group_forward = INVALID_HANDLE;
new bool:reweight_active = false;
new Float:current_weight;

/* Exclusion System */
new Handle:exclude_forward = INVALID_HANDLE;

/* Reload System */
new Handle:reload_forward = INVALID_HANDLE;

/* Extend System */
new Handle:extend_forward = INVALID_HANDLE;

/* Nextmap System */
new Handle:nextmap_forward = INVALID_HANDLE;

/* Failure System */
new Handle:failure_forward = INVALID_HANDLE;

/* Vote Notification System */
new Handle:vote_start_forward = INVALID_HANDLE;
new Handle:vote_end_forward = INVALID_HANDLE;
new Handle:client_voted_forward = INVALID_HANDLE;

/* Vote Management System */
new Handle:vote_managers = INVALID_HANDLE;
new Handle:vote_manager_ids = INVALID_HANDLE;

/* Maplist Display */
new Handle:maplistdisplay_forward = INVALID_HANDLE;

/* Template System */
new Handle:template_forward = INVALID_HANDLE;

//Flags
new bool:change_map_round; //Change map when the round ends?

//Misc ConVars
new Handle:cvar_maxrounds = INVALID_HANDLE;
new Handle:cvar_fraglimit = INVALID_HANDLE;
new Handle:cvar_winlimit  = INVALID_HANDLE;
//new Handle:cvar_nextmap   = INVALID_HANDLE;
new Handle:cvar_nextlevel = INVALID_HANDLE; //GE:S


#if RUNTESTS
RunTests()
{
    LogUMCMessage("TEST: Running UMC tests.");

    LogUMCMessage("TEST: Finished running UMC tests.");
}
#endif


//************************************************************************************************//
//                                        SOURCEMOD EVENTS                                        //
//************************************************************************************************//

//Called before the plugin loads, sets up our natives.
public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
    CreateNative("UMC_AddWeightModifier", Native_UMCAddWeightModifier);
    CreateNative("UMC_StartVote", Native_UMCStartVote);
    CreateNative("UMC_GetCurrentMapGroup", Native_UMCGetCurrentGroup);
    CreateNative("UMC_GetRandomMap", Native_UMCGetRandomMap);
    CreateNative("UMC_SetNextMap", Native_UMCSetNextMap);
    CreateNative("UMC_IsMapNominated", Native_UMCIsMapNominated);
    CreateNative("UMC_NominateMap", Native_UMCNominateMap);
    CreateNative("UMC_CreateValidMapArray", Native_UMCCreateMapArray);
    CreateNative("UMC_CreateValidMapGroupArray", Native_UMCCreateGroupArray);
    CreateNative("UMC_IsMapValid", Native_UMCIsMapValid);
    //CreateNative("UMC_IsGroupValid", Native_UMCIsGroupValid);
    CreateNative("UMC_FilterMapcycle", Native_UMCFilterMapcycle);
    CreateNative("UMC_IsVoteInProgress", Native_UMCIsVoteInProgress);
    CreateNative("UMC_StopVote", Native_UMCStopVote);
    CreateNative("UMC_RegisterVoteManager", Native_UMCRegVoteManager);
    CreateNative("UMC_UnregisterVoteManager", Native_UMCUnregVoteManager);
    CreateNative("UMC_VoteManagerVoteCompleted", Native_UMCVoteManagerComplete);
    CreateNative("UMC_VoteManagerVoteCancelled", Native_UMCVoteManagerCancel);
    CreateNative("UMC_VoteManagerClientVoted", Native_UMCVoteManagerVoted);
    CreateNative("UMC_FormatDisplayString", Native_UMCFormatDisplay);
    
    RegPluginLibrary("umccore");
    
    return APLRes_Success;
}


//Called when the plugin is finished loading.
public OnPluginStart()
{
    cvar_nomdisp = CreateConVar(
        "sm_umc_nomination_display",
        "^",
        "String to replace the {NOMINATED} map display-template string with."
    );

    cvar_novote = CreateConVar(
        "sm_umc_votemanager_core_novote",
        "0",
        "Enable No Vote option at the top of vote menus. Requires SourceMod >= 1.4",
        0, true, 0.0, true, 1.0
    );

    cvar_block_slots = CreateConVar(
        "sm_umc_votemanager_core_blockslots",
        "0",
        "Specifies how many slots in a vote are disabled to prevent accidental voting.",
        0, true, 0.0, true, 5.0
    );

    cvar_default_vm = CreateConVar(
        "sm_umc_votemanager_default",
        "core",
        "Specifies the default UMC Vote Manager to be used for voting. The default value of \"core\" means that Sourcemod's built-in voting will be used."
    );

    cvar_extend_command = CreateConVar(
        "sm_umc_extend_command",
        "",
        "Specifies a server command to be executed when the map is extended by UMC."
    );

    cvar_count_sound = CreateConVar(
        "sm_umc_countdown_sound",
        "",
        "Specifies a sound to be played each second during the countdown time between runoff and tiered votes. (Sound will be precached and added to the download table.)"
    );
    
    cvar_valvemenu = CreateConVar(
        "sm_umc_votemanager_core_menu_esc",
        "0",
        "If enabled, votes will use Valve-Stlye menus (players will be required to press ESC in order to vote). NOTE: this may not work in TF2!",
        0, true, 0.0, true, 1.0
    );

    cvar_extend_display = CreateConVar(
        "sm_umc_extend_display",
        "0",
        "Determines where in votes the \"Extend Map\" option will be displayed.\n 0 - Bottom,\n 1 - Top",
        0, true, 0.0, true, 1.0
    );
    
    cvar_dontchange_display = CreateConVar(
        "sm_umc_dontchange_display",
        "0",
        "Determines where in votes the \"Don't Change\" option will be displayed.\n 0 - Bottom,\n 1 - Top",
        0, true, 0.0, true, 1.0
    );
    
    cvar_logging = CreateConVar(
        "sm_umc_logging_verbose",
        "1",
        "Enables in-depth logging. Use this to have the plugin log how votes are being populated.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_runoff_selective = CreateConVar(
        "sm_umc_runoff_selective",
        "0",
        "Specifies whether runoff votes are only displayed to players whose votes were eliminated in the runoff and players who did not vote.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_vote_tieramount = CreateConVar(
        "sm_umc_vote_tieramount",
        "6",
        "Specifies the maximum number of maps to appear in the second part of a tiered vote.",
        0, true, 2.0
    );
    
    cvar_runoff_display = CreateConVar(
        "sm_umc_runoff_display",
        "C",
        "Determines where the Runoff Vote Message is displayed on the screen.\n C - Center Message\n S - Chat Message\n T - Top Message\n H - Hint Message"
    );
    
    cvar_vote_tierdisplay = CreateConVar(
        "sm_umc_vote_tierdisplay",
        "C",
        "Determines where the Tiered Vote Message is displayed on the screen.\n C - Center Message\n S - Chat Message\n T - Top Message\n H - Hint Message"
    );

    //Version
    cvar_version = CreateConVar(
        "improved_map_randomizer_version", PL_VERSION, "Ultimate Mapchooser's version",
        FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED
    );
    
    //Create the config if it doesn't exist, and then execute it.
    AutoExecConfig(true, "ultimate-mapchooser");
    
    //Admin command to set the next map
    RegAdminCmd("sm_setnextmap", Command_SetNextmap, ADMFLAG_CHANGEMAP, "sm_setnextmap <map>");
    
    //Admin command to reload the mapcycle.
    RegAdminCmd(
        "sm_umc_reload_mapcycles", Command_Reload, ADMFLAG_RCON, "Reloads the mapcycle file."
    );
    
    //Admin command to stop votes in progress.
    RegAdminCmd(
        "sm_umc_stopvote", Command_StopVote, ADMFLAG_CHANGEMAP,
        "Stops all UMC votes that are in progress."
    );
    
    RegAdminCmd(
        "sm_umc_maphistory", Command_MapHistory, ADMFLAG_CHANGEMAP,
        "Shows the most recent maps played"
    );
    
    RegAdminCmd(
        "sm_umc_displaymaplists", Command_DisplayMapLists, ADMFLAG_CHANGEMAP,
        "Displays the current maplist for all UMC modules."
    );
    
    //Hook round end events
    HookEvent("round_end",            Event_RoundEnd); //Generic
    HookEventEx("game_round_end",     Event_RoundEnd); //Hidden: Source, Neotokyo
    HookEventEx("teamplay_win_panel", Event_RoundEnd); //TF2
    HookEventEx("arena_win_panel",    Event_RoundEnd); //TF2
    HookEventEx("round_win",          Event_RoundEnd); //Nuclear Dawn
    
    //Initialize our vote arrays
    nominations_arr = CreateArray();
    
    //Make listeners for player chat. Needed to recognize chat commands ("rtv", etc.)
    AddCommandListener(OnPlayerChat, "say");
    AddCommandListener(OnPlayerChat, "say2"); //Insurgency Only
    AddCommandListener(OnPlayerChat, "say_team");
    
    //Fetch Cvars
    cvar_maxrounds = FindConVar("mp_maxrounds");
    cvar_fraglimit = FindConVar("mp_fraglimit");
    cvar_winlimit  = FindConVar("mp_winlimit");
    //cvar_nextmap   = FindConVar("nextmap");
    
    //GE:S Fix
    new String:game[20];
    GetGameFolderName(game, sizeof(game));
    if (StrEqual(game, "gesource", false))
        cvar_nextlevel = FindConVar("nextlevel");
    
    //Load the translations file
    LoadTranslations("ultimate-mapchooser.phrases");
    
    //Setup our forward for when a nomination is removed
    nomination_reset_forward = CreateGlobalForward(
        "OnNominationRemoved", ET_Ignore, Param_String, Param_Cell
    );
    
    reweight_forward = CreateGlobalForward(
        "UMC_OnReweightMap", ET_Ignore, Param_Cell, Param_String, Param_String
    );
    
    reweight_group_forward = CreateGlobalForward(
        "UMC_OnReweightGroup", ET_Ignore, Param_Cell, Param_String
    );
    
    exclude_forward = CreateGlobalForward(
        "UMC_OnDetermineMapExclude",
        ET_Hook, Param_Cell, Param_String, Param_String, Param_Cell, Param_Cell
    );
    
    reload_forward = CreateGlobalForward("UMC_RequestReloadMapcycle", ET_Ignore);
    
    extend_forward = CreateGlobalForward("UMC_OnMapExtended", ET_Ignore);
    
    nextmap_forward = CreateGlobalForward(
        "UMC_OnNextmapSet", ET_Ignore, Param_Cell, Param_String, Param_String, Param_String
    );
    
    failure_forward = CreateGlobalForward("UMC_OnVoteFailed", ET_Ignore);
    
    maplistdisplay_forward = CreateGlobalForward(
        "UMC_DisplayMapCycle", ET_Ignore, Param_Cell, Param_Cell
    );
    
    vote_start_forward = CreateGlobalForward(
        "UMC_VoteStarted", ET_Ignore, Param_String, Param_Array, Param_Cell, Param_Cell
    );
    
    vote_end_forward = CreateGlobalForward(
        "UMC_VoteEnded", ET_Ignore, Param_String, Param_Cell
    );
    
    client_voted_forward = CreateGlobalForward(
        "UMC_ClientVoted", ET_Ignore, Param_String, Param_Cell, Param_Cell
    );
    
    template_forward = CreateGlobalForward(
        "UMC_OnFormatTemplateString",
        ET_Ignore, 
        Param_String, Param_Cell, Param_Cell, Param_String, Param_String
    );
    
    vote_managers = CreateTrie();
    vote_manager_ids = CreateArray(ByteCountToCells(64));
    
    UMC_RegisterVoteManager("core", VM_MapVote, VM_GroupVote, VM_CancelVote);
    
#if AUTOUPDATE_ENABLE
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
#endif
    
#if RUNTESTS
    RunTests();
#endif
}


#if AUTOUPDATE_ENABLE
//Called when a new API library is loaded. Used to register UMC auto-updating.
public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
#endif


//************************************************************************************************//
//                                           GAME EVENTS                                          //
//************************************************************************************************//

//Called before any configs are executed.
public OnMapStart()
{   
    DEBUG_MESSAGE("Executing Core OnMapStart")
    decl String:map[MAP_LENGTH];
    GetCurrentMap(map, sizeof(map));
    
    LogUMCMessage("---------------------MAP CHANGE: %s---------------------", map);

    //Update the current category.
    strcopy(current_cat, sizeof(current_cat), next_cat);
    strcopy(next_cat, sizeof(next_cat), INVALID_GROUP);
    
    CreateTimer(5.0, UpdateTrackingCvar);
}


//
public Action:UpdateTrackingCvar(Handle:timer)
{
    SetConVarString(cvar_version, PL_VERSION, false, false);
}


//Called after all config files were executed.
public OnConfigsExecuted()
{
    DEBUG_MESSAGE("Executing Core OnConfigsExecuted")
    //Have all plugins reload their mapcycles.
    //Call_StartForward(reload_forward);
    //Call_Finish();

    //Turn off the reweight system in the event it was left active (map change?)
    reweight_active = false;
    
    //No votes have been completed.
    //vote_completed = false;
    
    change_map_round = false;
    
    //TODO: Turn off all votes?
    //vote_inprogress = false;
    //vote_active = false; //Assuming the case where this is still active was caught by VoteComplete()
    
    GetConVarString(cvar_count_sound, countdown_sound, sizeof(countdown_sound));
    CacheSound(countdown_sound);
}


//Called when a player types in chat.
//Required to handle user commands.
public Action:OnPlayerChat(client, const String:command[], argc)
{
    //Return immediately if...
    //    ...nothing was typed.
    if (argc == 0) return Plugin_Continue;

    //Get what was typed.
    decl String:text[13];
    GetCmdArg(1, text, sizeof(text));
    
    if (StrEqual(text, "umc", false) || StrEqual(text, "!umc", false)
        || StrEqual(text, "/umc", false))
        PrintToChatAll("[SM] Ultimate Mapchooser v%s by Steell", PL_VERSION);
    
    return Plugin_Continue;
}


//Called when a client has left the server. Needed to update nominations.
public OnClientDisconnect(client)
{
    //Find this client in the array of clients who have entered RTV.
    new index = FindClientNomination(client);
    
    //Remove the client from the nomination pool if...
    //    ...the client is in the pool to begin with.
    if (index != -1)
    {
        new Handle:nomination = GetArrayCell(nominations_arr, index);
        
        decl String:oldMap[MAP_LENGTH];
        GetTrieString(nomination, MAP_TRIE_MAP_KEY, oldMap, sizeof(oldMap));
        new owner;
        GetTrieValue(nomination, "client", owner);
        Call_StartForward(nomination_reset_forward);
        Call_PushString(oldMap);
        Call_PushCell(owner);
        Call_Finish();

        new Handle:nomKV;
        GetTrieValue(nomination, "mapcycle", nomKV);
        CloseHandle(nomKV);
        CloseHandle(nomination);
        RemoveFromArray(nominations_arr, index);
    }
}


//Called when a round ends.
public Event_RoundEnd(Handle:evnt, const String:name[], bool:dontBroadcast)
{
    if (change_map_round)
    {
        change_map_round = false;

        // //Routine by Tsunami to end the map
        // new iGameEnd = FindEntityByClassname(-1, "game_end");
        // if (iGameEnd == -1 && (iGameEnd = CreateEntityByName("game_end")) == -1)
        // {
        decl String:map[MAP_LENGTH];
        GetNextMap(map, sizeof(map));
        ForceChangeInFive(map, "CORE");
        // } 
        // else 
        // {     
        //     AcceptEntityInput(iGameEnd, "EndGame");
        // }
    }
}


//Called at the end of a map.
public OnMapEnd()
{
    DEBUG_MESSAGE("Executing Core OnMapEnd")

    //Empty array of nominations (and close all handles).
    ClearNominations();
    
    //End all votes currently in progress.
    new size = GetArraySize(vote_manager_ids);
    new Handle:vM;
    new bool:inProgress;
    decl String:id[64];
    for (new i = 0; i < size; i++)
    {
        GetArrayString(vote_manager_ids, i, id, sizeof(id));
        GetTrieValue(vote_managers, id, vM);
        GetTrieValue(vM, "in_progress", inProgress);
        if (inProgress)
        {
            DEBUG_MESSAGE("Ending vote in progress: %s", id)
            VoteCancelled(vM);
        }
    }
}


//************************************************************************************************//
//                                             NATIVES                                            //
//************************************************************************************************//

public Native_UMCFormatDisplay(Handle:plugin, numParams)
{
    new maxlen = GetNativeCell(2);
    new Handle:kv = CreateKeyValues("umc_mapcycle");
    KvCopySubkeys(Handle:GetNativeCell(3), kv);
    
    new len;
    GetNativeStringLength(4, len);
    new String:map[len+1];
    if (len > 0)
        GetNativeString(4, map, len+1);
    GetNativeStringLength(5, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(5, group, len+1);
        
    decl String:display[MAP_LENGTH], String:gDisp[MAP_LENGTH];
    KvJumpToKey(kv, group);
    KvGetString(kv, "display-template", gDisp, sizeof(gDisp), "{MAP}");
    KvGoBack(kv);
    
    GetMapDisplayString(kv, group, map, gDisp, display, sizeof(display));
    CloseHandle(kv);
    
    SetNativeString(1, display, maxlen);
}


//
public Native_UMCVoteManagerVoted(Handle:plugin, numParams)
{
    new len;
    GetNativeStringLength(1, len);
    new String:id[len+1];
    if (len > 0)
        GetNativeString(1, id, len+1);
    
    new client = GetNativeCell(2);
    
    new Handle:option = Handle:GetNativeCell(3);
    
    Call_StartForward(client_voted_forward);
    Call_PushString(id);
    Call_PushCell(client);
    Call_PushCell(option);
    Call_Finish();
}


//
public Native_UMCFilterMapcycle(Handle:plugin, numParams)
{
    new Handle:kv = CreateKeyValues("umc_rotation");
    new Handle:arg = Handle:GetNativeCell(1);
    KvCopySubkeys(arg, kv);
    
    new Handle:mapcycle = Handle:GetNativeCell(2);
    
    new bool:isNom = bool:GetNativeCell(3);
    new bool:forMapChange = bool:GetNativeCell(4);
    
    FilterMapcycle(kv, mapcycle, isNom, forMapChange);
    
    return _:CloseAndClone(kv, plugin);
}


//
public Native_UMCVoteManagerCancel(Handle:plugin, numParams)
{
    DEBUG_MESSAGE("*UMC_VoteManagerCancel*")
    new len;
    GetNativeStringLength(1, len);
    new String:id[len+1];
    if (len > 0)
        GetNativeString(1, id, len+1);
        
    new Handle:voteManager;
    if (!GetTrieValue(vote_managers, id, voteManager))
    {
        ThrowNativeError(SP_ERROR_PARAM, "A Vote Manager with the ID \"%s\" does not exist!", id);
    }
    
    DEBUG_MESSAGE("Vote Manager found, calling VoteCancelled")
    
    VoteCancelled(voteManager);
}


//
public Native_UMCRegVoteManager(Handle:plugin, numParams)
{
    new Handle:voteManager;
    
    new len;
    GetNativeStringLength(1, len);
    new String:id[len+1];
    if (len > 0)
        GetNativeString(1, id, len+1);
        
    if (GetTrieValue(vote_managers, id, voteManager))
    {
        UMC_UnregisterVoteManager(id);
    }
    
    voteManager = CreateTrie();
    
    SetTrieValue(vote_managers, id, voteManager);
    
    SetTrieValue(voteManager, "plugin", plugin);
    SetTrieValue(voteManager, "map", GetNativeCell(2));
    SetTrieValue(voteManager, "group", GetNativeCell(3));
    SetTrieValue(voteManager, "cancel", GetNativeCell(4));
    SetTrieValue(voteManager, "vote_storage", CreateArray());
    SetTrieValue(voteManager, "in_progress", false);
    SetTrieValue(voteManager, "active", false);
    SetTrieValue(voteManager, "total_votes", 0);
    SetTrieValue(voteManager, "prev_vote_count", 0);
    SetTrieValue(voteManager, "map_vote", CreateArray());
    
    PushArrayString(vote_manager_ids, id);
}


//
public Native_UMCUnregVoteManager(Handle:plugin, numParams)
{
    new len;
    GetNativeStringLength(1, len);
    new String:id[len+1];
    if (len > 0)
        GetNativeString(1, id, len+1);
    
    new Handle:vM;
    
    if (!GetTrieValue(vote_managers, id, vM))
    {
        ThrowNativeError(SP_ERROR_PARAM, "A Vote Manager with the ID \"%s\" does not exist!", id);
    }
    
    if (UMC_IsVoteInProgress(id))
    {
        UMC_StopVote(id);
    }
    
    new Handle:hndl;
    GetTrieValue(vM, "vote_storage", hndl);
    CloseHandle(hndl);
    GetTrieValue(vM, "map_vote", hndl);
    CloseHandle(hndl);
    
    CloseHandle(vM);
    
    RemoveFromTrie(vote_managers, id);
    
    new index = FindStringInArray(vote_manager_ids, id);
    if (index != -1)
    {
        RemoveFromArray(vote_manager_ids, index);
    }
    
    if (StrEqual(id, "core", false))
    {
        UMC_RegisterVoteManager("core", VM_MapVote, VM_GroupVote, VM_CancelVote);
    }
}


//
public Native_UMCVoteManagerComplete(Handle:plugin, numParams)
{
    DEBUG_MESSAGE("*VoteManagerVoteCompleted*")

    new len;
    GetNativeStringLength(1, len);
    new String:id[len+1];
    if (len > 0)
        GetNativeString(1, id, len+1);
    
    new Handle:voteOptions = Handle:GetNativeCell(2);
    
    new Handle:vM;
    GetTrieValue(vote_managers, id, vM);
    
    new Handle:response = ProcessVoteResults(vM, voteOptions);
    
    new UMC_VoteResponseHandler:handler = UMC_VoteResponseHandler:GetNativeCell(3);
    
    new UMC_VoteResponse:result;
    new String:param[MAP_LENGTH];
    GetTrieValue(response, "response", result);
    GetTrieString(response, "param", param, sizeof(param));
    
    Call_StartFunction(plugin, handler);
    Call_PushCell(result);
    Call_PushString(param);
    Call_Finish();
    
    Call_StartForward(vote_end_forward);
    Call_PushString(id);
    Call_PushCell(result);
    Call_Finish();
    
    CloseHandle(response);
}


//native Handle:UMC_CreateValidMapArray(Handle:kv, const String:group[], bool:isNom, 
//                                      bool:forMapChange);
public Native_UMCCreateMapArray(Handle:plugin, numParams)
{
    new Handle:kv = CreateKeyValues("umc_rotation");
    new Handle:arg = Handle:GetNativeCell(1);
    KvCopySubkeys(arg, kv);
    
    new Handle:mapcycle = Handle:GetNativeCell(2);
    
    new len;
    GetNativeStringLength(3, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(3, group, len+1);
    
    new bool:isNom = bool:GetNativeCell(4);
    new bool:forMapChange = bool:GetNativeCell(5);
    
    new Handle:result = CreateMapArray(kv, mapcycle, group, isNom, forMapChange);
    
    CloseHandle(kv);
    
    if (result == INVALID_HANDLE)
    {
        ThrowNativeError(SP_ERROR_PARAM,
            "Could not generate valid map array from provided mapcycle.");
    }
    
    DEBUG_MESSAGE("*MEMLEAKTEST* Closing and cloning map trie made at {2}")
    
    //Clone all of the handles in the array to prevent memory leaks.
    new Handle:cloned = CreateArray();
    
    new size = GetArraySize(result);
    new Handle:map;
    for (new i = 0; i < size; i++)
    {
        map = GetArrayCell(result, i);
        PushArrayCell(cloned, CloseAndClone(map, plugin));
    }
    
    CloseHandle(result);
    
    return _:CloseAndClone(cloned, plugin);
}


//Create an array of valid maps from the given mapcycle and group.
Handle:CreateMapArray(Handle:kv, Handle:mapcycle, const String:group[], bool:isNom,
                      bool:forMapChange)
{
    if (kv == INVALID_HANDLE)
    {
        LogError("NATIVE: Cannot build map array, mapcycle is invalid.");
        return INVALID_HANDLE;
    }
 
    new bool:oneSection = false; 
    if (StrEqual(group, INVALID_GROUP))
    {
        if (!KvGotoFirstSubKey(kv))
        {
            LogError("NATIVE: Cannot build map array, mapcycle has no groups.");
            return INVALID_HANDLE;
        }
    }
    else
    {
        if (!KvJumpToKey(kv, group))
        {
            LogError("NATIVE: Cannot build map array, mapcycle has no group '%s'", group);
            return INVALID_HANDLE;
        }
        
        oneSection = true;
    }
    
    new Handle:result = CreateArray();
    decl String:mapName[MAP_LENGTH], String:groupName[MAP_LENGTH];
    do
    {
        KvGetSectionName(kv, groupName, sizeof(groupName));
        
        if (!KvGotoFirstSubKey(kv))
        {
            if (!oneSection)
                continue;
            else
                break;
        }
        
        do
        {
            if (IsValidMap(kv, mapcycle, groupName, isNom, forMapChange))
            {
                KvGetSectionName(kv, mapName, sizeof(mapName));
                DEBUG_MESSAGE("*MEMLEAKTEST* Creating map trie (CreateMapArray) [2]")
                PushArrayCell(result, CreateMapTrie(mapName, groupName));
            }
        }
        while (KvGotoNextKey(kv));
        
        KvGoBack(kv);
        
        if (oneSection) break;
    }
    while (KvGotoNextKey(kv));
    
    KvGoBack(kv);
    
    return result;
}


//native Handle:UMC_CreateValidMapGroupArray(Handle:kv, bool:isNom, bool:forMapChange);
public Native_UMCCreateGroupArray(Handle:plugin, numParams)
{
    new Handle:arg = Handle:GetNativeCell(1);
    new Handle:kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(arg, kv);
    new Handle:mapcycle = Handle:GetNativeCell(2);
    new bool:isNom = bool:GetNativeCell(3);
    new bool:forMapChange = bool:GetNativeCell(4);
    
    new Handle:result = CreateMapGroupArray(kv, mapcycle, isNom, forMapChange);
    
    CloseHandle(kv);
    
    return _:CloseAndClone(result, plugin);
}


//Create an array of valid maps from the given mapcycle and group.
Handle:CreateMapGroupArray(Handle:kv, Handle:mapcycle, bool:isNom, bool:forMapChange)
{
    if (!KvGotoFirstSubKey(kv))
    {
        LogError("NATIVE: Cannot build map array, mapcycle has no groups.");
        return INVALID_HANDLE;
    }
    
    new Handle:result = CreateArray(ByteCountToCells(MAP_LENGTH));
    decl String:groupName[MAP_LENGTH];
    do
    {
        if (IsValidCat(kv, mapcycle, isNom, forMapChange))
        {
            KvGetSectionName(kv, groupName, sizeof(groupName));
            PushArrayString(result, groupName);
        }    
    }
    while (KvGotoNextKey(kv));
    
    KvGoBack(kv);
    
    return result;
}


//native bool:UMC_IsMapNominated(const String:map[], const String:group[]);
public Native_UMCIsMapNominated(Handle:plugin, numParams)
{
    new len;
    GetNativeStringLength(1, len);
    new String:map[len+1];
    if (len > 0)
        GetNativeString(1, map, len+1);
        
    GetNativeStringLength(2, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(2, group, len+1);
    
    return _:(FindNominationIndex(map, group) != -1);
}


//native bool:UMC_NominateMap(const String:map[], const String:group[]);
public Native_UMCNominateMap(Handle:plugin, numParams)
{
    new Handle:kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(Handle:GetNativeCell(1), kv);
    
#if UMC_DEBUG
    LogKv(kv);
#endif
    
    new len;
    GetNativeStringLength(2, len);
    new String:map[len+1];
    if (len > 0)
        GetNativeString(2, map, len+1);
        
    GetNativeStringLength(3, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(3, group, len+1);
        
    new String:nomGroup[MAP_LENGTH];
    if (numParams > 4)
    {
        GetNativeStringLength(5, len);
        if (len > 0)
            GetNativeString(5, nomGroup, sizeof(nomGroup));
    }
    else
    {
        strcopy(nomGroup, sizeof(nomGroup), INVALID_GROUP);
    }
        
    return _:InternalNominateMap(kv, map, group, GetNativeCell(4), nomGroup);
}


//native AddWeightModifier(MapWeightModifier:func);
public Native_UMCAddWeightModifier(Handle:plugin, numParams)
{
    if (reweight_active)
    {
        current_weight *= Float:GetNativeCell(1);
        DEBUG_MESSAGE("New map weight: %f", current_weight)
    }
    else
        LogError("REWEIGHT: Attempted to add weight modifier outside of UMC_OnReweightMap forward.");
}


//native bool:UMC_StartVote( ...20+ params... );
public Native_UMCStartVote(Handle:plugin, numParams)
{
    //Retrieve the many, many parameters.
    new len;
    GetNativeStringLength(1, len);
    new String:voteManagerID[len+1];
    if (len > 0)
        GetNativeString(1, voteManagerID, len+1);
        
    if (strlen(voteManagerID) == 0)
        GetConVarString(cvar_default_vm, voteManagerID, len+1);
        
    new Handle:voteManager = INVALID_HANDLE;
    if (!GetTrieValue(vote_managers, voteManagerID, voteManager))
    {
        if (StrEqual(voteManagerID, "core"))
        {
            LogError("FATAL: Could not find core vote manager. Aborting vote.");
            return _:false;
        }
        LogError("Could not find a vote manager matching ID \"%s\". Using \"core\" instead.");
        if (!GetTrieValue(vote_managers, "core", voteManager))
        {
            LogError("FATAL: Could not find core vote manager. Aborting vote.");
            return _:false;
        }
        strcopy(voteManagerID, len+1, "core");
    }
    
    new bool:vote_inprogress;
    GetTrieValue(voteManager, "in_progress", vote_inprogress);
    
    if (vote_inprogress)
    {
        LogError("Cannot start a vote, vote manager \"%s\" already has a vote in progress.", voteManagerID);
        return _:false;
    }
    
    //Get the name of the calling plugin.
    decl String:stored_reason[PLATFORM_MAX_PATH];
    GetPluginFilename(plugin, stored_reason, sizeof(stored_reason));
    SetTrieString(voteManager, "stored_reason", stored_reason);
    
    //vote_completed = false;
    
    new Handle:kv = Handle:GetNativeCell(2);
    new Handle:mapcycle = Handle:GetNativeCell(3);
    new UMC_VoteType:type = UMC_VoteType:GetNativeCell(4);
    new time = GetNativeCell(5);
    new bool:scramble = bool:GetNativeCell(6);
    
    
    GetNativeStringLength(7, len);
    new String:startSound[len+1];
    if (len > 0)
        GetNativeString(7, startSound, len+1);
    GetNativeStringLength(8, len);
    new String:endSound[len+1];
    if (len > 0)
        GetNativeString(8, endSound, len+1);
    
    new bool:extend = bool:GetNativeCell(9);
    new Float:timestep = Float:GetNativeCell(10);
    new roundstep = GetNativeCell(11);
    new fragstep = GetNativeCell(12);
    new bool:dontChange = bool:GetNativeCell(13);
    new Float:threshold = Float:GetNativeCell(14);
    new UMC_ChangeMapTime:successAction = UMC_ChangeMapTime:GetNativeCell(15);
    new UMC_VoteFailAction:failAction = UMC_VoteFailAction:GetNativeCell(16);
    new maxRunoffs = GetNativeCell(17);
    new maxRunoffMaps = GetNativeCell(18);
    new UMC_RunoffFailAction:runoffFailAction = UMC_RunoffFailAction:GetNativeCell(19);
    
    GetNativeStringLength(20, len);
    new String:runoffSound[len+1];
    if (len > 0)
        GetNativeString(20, runoffSound, len+1);
    
    new bool:nominationStrictness = bool:GetNativeCell(21);
    new bool:allowDuplicates = bool:GetNativeCell(22);
    
    new voteClients[MAXPLAYERS+1];
    GetNativeArray(23, voteClients, sizeof(voteClients));
    new numClients = GetNativeCell(24);
    
    new bool:runExclusionCheck = (numParams >= 25) ? (bool:GetNativeCell(25)) : true;
    
    //OK now that that's done, let's save 'em.
    SetTrieValue(voteManager, "stored_type", type);
    SetTrieValue(voteManager, "stored_scramble", scramble);
    SetTrieValue(voteManager, "stored_ignoredupes", allowDuplicates);
    SetTrieValue(voteManager, "stored_strictnoms", nominationStrictness);

    if (failAction == VoteFailAction_Nothing)
    {
        SetTrieValue(voteManager, "stored_fail_action", RunoffFailAction_Nothing);
        SetTrieValue(voteManager, "remaining_runoffs", 0);
    }
    else if (failAction == VoteFailAction_Runoff)
    {    
        SetTrieValue(voteManager, "stored_fail_action", runoffFailAction);
        SetTrieValue(voteManager, "remaining_runoffs", (maxRunoffs == 0) ? -1 : maxRunoffs);
    }
    
    SetTrieValue(voteManager, "extend_timestep", timestep);
    SetTrieValue(voteManager, "extend_roundstep", roundstep);
    SetTrieValue(voteManager, "extend_fragstep", fragstep);
    SetTrieValue(voteManager, "stored_threshold", threshold);
    SetTrieValue(voteManager, "stored_runoffmaps_max", maxRunoffMaps);
    SetTrieValue(voteManager, "stored_votetime", time);
    
    SetTrieValue(voteManager, "change_map_when", successAction);
    
    new Handle:stored_kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(kv, stored_kv);
    SetTrieValue(voteManager, "stored_kv", stored_kv);
    
    new Handle:stored_mapcycle = CreateKeyValues("umc_rotation");
    KvCopySubkeys(mapcycle, stored_mapcycle);
    SetTrieValue(voteManager, "stored_mapcycle", stored_mapcycle);
    
    SetTrieString(voteManager, "stored_start_sound", startSound);
    SetTrieString(voteManager, "stored_end_sound", endSound);
    SetTrieString(voteManager, "stored_runoff_sound", (strlen(runoffSound) > 0) ? runoffSound : startSound);
    
    new users[MAXPLAYERS+1];
    ConvertClientsToUserIDs(voteClients, users, numClients);
    SetTrieArray(voteManager, "stored_users", users, numClients);
    
    SetTrieValue(voteManager, "stored_exclude", runExclusionCheck);
    
    //Make the vote menu.
    new Handle:options = BuildVoteItems(voteManager, stored_kv, stored_mapcycle, type, scramble,
                                        allowDuplicates, nominationStrictness, runExclusionCheck,
                                        extend, dontChange);
    
    //Run the vote if...
    //    ...the menu was created successfully.
    if (options != INVALID_HANDLE)
    {
        new bool:vote_active = PerformVote(voteManager, type, options, time, voteClients,
                                           numClients, startSound);
        if (vote_active)
        {
            Call_StartForward(vote_start_forward);
            Call_PushString(voteManagerID);
            Call_PushArray(voteClients, numClients);
            Call_PushCell(numClients);
            Call_PushCell(options);
            Call_Finish();
        }
        else
        {
            DeleteVoteParams(voteManager);
            ClearVoteArrays(voteManager);
            //VoteFailed(voteManager);
        }        
        
        FreeOptions(options);
        return _:vote_active;
    }
    else
    {
        DeleteVoteParams(voteManager);
        return _:false;
    }
}


//native bool:UMC_GetRandomMap(Handle:kv, const String:group=INVALID_GROUP, String:buffer[], size,
//                             Handle:excludedMaps, Handle:excludedGroups, bool:forceGroup);
public Native_UMCGetRandomMap(Handle:plugin, numParams)
{
    new Handle:kv = Handle:GetNativeCell(1);
    new Handle:filtered = CreateKeyValues("umc_rotation");
    KvCopySubkeys(kv, filtered);

    new Handle:mapcycle = Handle:GetNativeCell(2);
    new len;
    GetNativeStringLength(3, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(3, group, len+1);
        
    DEBUG_MESSAGE("Looking for random map in group \"%s\".", group)
    
    new bool:isNom = bool:GetNativeCell(8);
    new bool:forMapChange = bool:GetNativeCell(9);
    
    FilterMapcycle(filtered, mapcycle, isNom, forMapChange);
    WeightMapcycle(filtered, mapcycle);
    
#if UMC_DEBUG
    LogKv(filtered);
#endif
    
    decl String:map[MAP_LENGTH], String:groupResult[MAP_LENGTH];
    new bool:result = GetRandomMapFromCycle(filtered, group, map, sizeof(map), groupResult,
                                            sizeof(groupResult));
    
    CloseHandle(filtered);
    
    if (result)
    {
        SetNativeString(4, map, GetNativeCell(5), false);
        SetNativeString(6, groupResult, GetNativeCell(7), false);
        return true;
    }
    return false;
}


//native bool:UMC_SetNextMap(Handle:kv, const String:map[], const String:group[]);
public Native_UMCSetNextMap(Handle:plugin, numParams)
{
    new Handle:kv = Handle:GetNativeCell(1);
    
    new len;
    GetNativeStringLength(2, len);
    new String:map[len+1];
    if (len > 0)
        GetNativeString(2, map, len+1);
    GetNativeStringLength(3, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(3, group, len+1);
    
    if (!IsMapValid(map))
    {
        LogError("SETMAP: Map %s is invalid!", map);
        return;
    }
    
    new UMC_ChangeMapTime:when = UMC_ChangeMapTime:GetNativeCell(4);
    
    decl String:reason[PLATFORM_MAX_PATH];
    GetPluginFilename(plugin, reason, sizeof(reason));
    
    DoMapChange(when, kv, map, group, reason, map);
}


//
public Native_UMCIsVoteInProgress(Handle:plugin, numParams)
{
    if (numParams > 0)
    {
        new len;
        GetNativeStringLength(1, len);
        new String:voteManagerID[len+1];
        if (len > 0)
            GetNativeString(1, voteManagerID, len+1);
            
        if (strlen(voteManagerID) > 0)
        {
            new bool:inProgress;
            new Handle:vM;
            if (!GetTrieValue(vote_managers, voteManagerID, vM))
            {
                ThrowNativeError(SP_ERROR_PARAM,
                    "A Vote Manager with the ID \"%s\" does not exist!", voteManagerID);
            }
            GetTrieValue(vM, "in_progress", inProgress);
            return inProgress;
        }
    }
    decl String:buffer[64];
    new size = GetArraySize(vote_manager_ids);
    new Handle:vM;
    new bool:inProgress;
    for (new i = 0; i < size; i++)
    {
        GetArrayString(vote_manager_ids, i, buffer, sizeof(buffer));
        GetTrieValue(vote_managers, buffer, vM);
        GetTrieValue(vM, "in_progress", inProgress);
        if (inProgress)
            return _:true;
    }
    return _:false;
}


//
//"sm_umc_stopvote"
public Native_UMCStopVote(Handle:plugin, numParams)
{
    Native_UMCVoteManagerCancel(plugin, numParams);
}


//
public Native_UMCIsMapValid(Handle:plugin, numParams)
{
    new Handle:arg = Handle:GetNativeCell(1);
    new Handle:kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(arg, kv);
    
#if UMC_DEBUG
    DEBUG_MESSAGE("UMC_IsValidMap passed mapcycle:")
    LogKv(arg);
#endif
    
    new len;
    GetNativeStringLength(2, len);
    new String:map[len+1];
    if (len > 0)
        GetNativeString(2, map, len+1);
    GetNativeStringLength(3, len);
    new String:group[len+1];
    if (len > 0)
        GetNativeString(3, group, len+1);
    
    new bool:isNom = bool:GetNativeCell(4);
    new bool:forMapChange = bool:GetNativeCell(5);
    
    if (!KvJumpToKey(kv, group))
    {
        LogError("NATIVE: No group '%s' in mapcycle.", group);
        return _:false;
    }
    if (!KvJumpToKey(kv, map))
    {
        LogError("NATIVE: No map %s found in group '%s'", map, group);
        return _:false;
    }
    
    return _:IsValidMap(kv, arg, group, isNom, forMapChange);
}


//
public Native_UMCGetCurrentGroup(Handle:plugin, numParams)
{
    SetNativeString(1, current_cat, GetNativeCell(2), false);
}


//************************************************************************************************//
//                                            COMMANDS                                            //
//************************************************************************************************//

//
public Action:Command_DisplayMapLists(client, args)
{
    new bool:filtered;
    if (args < 1)
        filtered = false;
    else
    {
        decl String:arg[5];
        GetCmdArg(1, arg, sizeof(arg));
        filtered = StringToInt(arg) > 0;
    }

    PrintToConsole(client, "UMC Maplists:");
    
    Call_StartForward(maplistdisplay_forward);
    Call_PushCell(client);
    Call_PushCell(filtered);
    Call_Finish();
    
    return Plugin_Handled;
}


//
public Action:Command_MapHistory(client, args)
{
    PrintToConsole(client, "Map History:");

    new size = GetMapHistorySize();
    decl String:map[MAP_LENGTH], String:reason[100], String:timeString[100];
    new time;
    for (new i = 0; i < size; i++)
    {
        GetMapHistory(i, map, sizeof(map), reason, sizeof(reason), time);
        FormatTime(timeString, sizeof(timeString), NULL_STRING, time);
        ReplyToCommand(client, "%02i. %s : %s : %s", i+1, map, reason, timeString);
    }
    return Plugin_Handled;
}


//Called when the command to set the nextmap is called.
public Action:Command_SetNextmap(client, args)
{
    if (args < 1)
    {
        ReplyToCommand(
            client,
            "\x03[UMC]\x01 Usage: sm_setnextmap <map> <0|1|2>\n 0 - Change Now\n 1 - Change at end of round\n 2 - Change at end of map."
        );
        return Plugin_Handled;
    }
    
    decl String:map[MAP_LENGTH];
    GetCmdArg(1, map, sizeof(map));
    
    if (!IsMapValid(map))
    {
        ReplyToCommand(client, "\x03[UMC]\x01 Map '%s' was not found.", map);
        return Plugin_Handled;
    }
    
    new UMC_ChangeMapTime:when = ChangeMapTime_MapEnd;
    if (args > 1)
    {
        decl String:whenArg[2];
        GetCmdArg(2, whenArg, sizeof(whenArg));
        when = UMC_ChangeMapTime:StringToInt(whenArg);
    }
    
    //DisableVoteInProgress(id);
    DoMapChange(when, INVALID_HANDLE, map, INVALID_GROUP, "sm_setnextmap", map);
    
    //TODO: Make this a translation
    ShowActivity(client, "Changed nextmap to \"%s\".", map);
    LogUMCMessage("%L changed nextmap to \"%s\"", client, map);
    
    //vote_completed = true;
    
    return Plugin_Handled;
}


//Called when the command to reload the mapcycle has been triggered.
public Action:Command_Reload(client, args)
{
    //Call the reload forward.
    Call_StartForward(reload_forward);
    Call_Finish();
    
    ReplyToCommand(client, "\x03[UMC]\x01 UMC Mapcycles Reloaded.");    
    
    //Return success
    return Plugin_Handled;
}


//"sm_umc_stopvote"
public Action:Command_StopVote(client, args)
{
    //End all votes currently in progress.
    new size = GetArraySize(vote_manager_ids);
    new Handle:vM;
    new bool:inProgress;
    decl String:id[64];
    new bool:stopped = false;
    for (new i = 0; i < size; i++)
    {
        GetArrayString(vote_manager_ids, i, id, sizeof(id));
        GetTrieValue(vote_managers, id, vM);
        GetTrieValue(vM, "in_progress", inProgress);
        if (inProgress)
        {
            DEBUG_MESSAGE("Ending vote in progress: %s", id)
            stopped = true;
            VoteCancelled(vM);
        }
    }
    if (!stopped)
        ReplyToCommand(client, "\x03[UMC]\x01 No map vote running!"); //TODO Translation?
    return Plugin_Handled;
}

//************************************************************************************************//
//                                        CORE VOTE MANAGER                                       //
//************************************************************************************************//

new bool:core_vote_active;

//
public Action:VM_MapVote(duration, Handle:vote_items, const clients[], numClients,
                         const String:startSound[])
{
    if (IsVoteInProgress())
    {
        LogUMCMessage("Could not start core vote, another SM vote is already in progress.");
        return Plugin_Stop;
    }

    new bool:verboseLogs = GetConVarBool(cvar_logging);

    if (verboseLogs)
        LogUMCMessage("Adding Clients to Vote:");

    DEBUG_MESSAGE("Attempting to start core vote...")
    decl clientArr[MAXPLAYERS+1];
    new count = 0;
    new client;
    for (new i = 0; i < numClients; i++)
    {
        client = clients[i];
        if (client != 0 && IsClientInGame(client))
        {
            if (verboseLogs)
                LogUMCMessage("%i: %N (%i)", i, client, client);
            clientArr[count++] = client;
        }
    }
    
    if (count == 0)
    {
        LogUMCMessage("Could not start core vote, no players to display vote to!");
        return Plugin_Stop;
    }
    
    new Handle:menu = BuildVoteMenu(vote_items, "Map Vote Menu Title", Handle_MapVoteResults);
    
    core_vote_active = menu != INVALID_HANDLE && VoteMenu(menu, clientArr, count, duration);
    
    if (core_vote_active)
    {
        DEBUG_MESSAGE("Setting CVA True")

        if (strlen(startSound) > 0)
            EmitSoundToAll(startSound);
        
        return Plugin_Continue;
    }
    else
    {    
        DEBUG_MESSAGE("Setting CVA False -- Couldn't start vote")
        LogError("Could not start core vote.");
        return Plugin_Stop;
    }
}


//
public Action:VM_GroupVote(duration, Handle:vote_items, const clients[], numClients,
                           const String:startSound[])
{
    if (IsVoteInProgress())
    {
        LogUMCMessage("Could not start core vote, another SM vote is already in progress.");
        return Plugin_Stop;
    }

    new bool:verboseLogs = GetConVarBool(cvar_logging);

    if (verboseLogs)
        LogUMCMessage("Adding Clients to Vote:");

    decl clientArr[MAXPLAYERS+1];
    new count = 0;
    new client;
    for (new i = 0; i < numClients; i++)
    {
        client = clients[i];
        if (client != 0 && IsClientInGame(client))
        {
            if (verboseLogs)
                LogUMCMessage("%i: %N (%i)", i, client, client);
            clientArr[count++] = client;
        }
    }
    
    if (count == 0)
    {
        LogUMCMessage("Could not start core vote, no players to display vote to!");
        return Plugin_Stop;
    }
    
    new Handle:menu = BuildVoteMenu(vote_items, "Group Vote Menu Title", Handle_MapVoteResults);
      
    DEBUG_MESSAGE("Setting CVA True")
    core_vote_active = true;
    
    if (menu != INVALID_HANDLE && VoteMenu(menu, clientArr, count, duration))
    {
        if (strlen(startSound) > 0)
            EmitSoundToAll(startSound);
        
        return Plugin_Continue;
    }
    
    DEBUG_MESSAGE("Setting CVA False -- Couldn't start vote")
    core_vote_active = false;
    
    //ClearVoteArrays();
    LogError("Could not start core vote.");
    return Plugin_Stop;
}


//
Handle:BuildVoteMenu(Handle:vote_items, const String:title[], VoteHandler:callback)
{
    new bool:verboseLogs = GetConVarBool(cvar_logging);

    if (verboseLogs)
        LogUMCMessage("VOTE MENU:");

    //Begin creating menu
    new Handle:menu = (GetConVarBool(cvar_valvemenu))
        ? CreateMenuEx(GetMenuStyleHandle(MenuStyle_Valve), Handle_VoteMenu,
                       MenuAction_DisplayItem|MenuAction_Display)
        : CreateMenu(Handle_VoteMenu, MenuAction_DisplayItem|MenuAction_Display);
        
    SetVoteResultCallback(menu, callback); //Set callback
    SetMenuExitButton(menu, false); //Don't want an exit button.
        
    //Set the title
    SetMenuTitle(menu, title);
    
    //Keep track of slots taken up in the vote.
    new blockSlots = GetConVarInt(cvar_block_slots);
    new voteSlots = blockSlots;
    
    if (GetConVarBool(cvar_novote))
    {
        SetMenuOptionFlags(menu, MENUFLAG_BUTTON_NOVOTE);
        voteSlots++;
        
        if (verboseLogs)
            LogUMCMessage("1: No Vote");
    }
    
    DEBUG_MESSAGE("Setup slot blocking.")
    //Add blocked slots if...
    //    ...the cvar for blocked slots is enabled.
    AddSlotBlockingToMenu(menu, blockSlots);
    
    new size = GetArraySize(vote_items);
    
    //Throw an error and return nothing if...
    //    ...the number of items in the vote is less than 2 (hence no point in voting).
    if (size <= 1)
    {
        DEBUG_MESSAGE("Not enough items in the vote. Aborting.")
        LogError("VOTING: Not enough options to run a vote. %i options available.", size);
        CloseHandle(menu);
        return INVALID_HANDLE;
    }
    
    new Handle:voteItem;
    decl String:info[MAP_LENGTH], String:display[MAP_LENGTH];
    for (new i = 0; i < size; i++)
    {
        voteSlots++;
        
        voteItem = GetArrayCell(vote_items, i);
        GetTrieString(voteItem, "info", info, sizeof(info));
        GetTrieString(voteItem, "display", display, sizeof(display));
        
        AddMenuItem(menu, info, display);
        
#if UMC_DEBUG
        if (StrEqual(info, EXTEND_MAP_OPTION))
            DEBUG_MESSAGE("Adding Extend Option to vote menu. Position: %i", voteSlots)
        else if (StrEqual(info, DONT_CHANGE_OPTION))
            DEBUG_MESSAGE("Adding Don't Change Option to vote menu. Position: %i", voteSlots)
#endif
        
        if (verboseLogs)
            LogUMCMessage("%i: %s (%s)", voteSlots, display, info);
    }
    
    DEBUG_MESSAGE("Setting proper pagination.")
    SetCorrectMenuPagination(menu, voteSlots);
    DEBUG_MESSAGE("Vote menu built successfully.")
    return menu; //Return the finished menu.
}


//
public VM_CancelVote()
{
    DEBUG_MESSAGE("Vote Cancelled Callback -- Core")
    DEBUG_MESSAGE("Is Core Vote still active? %i", core_vote_active)
    if (core_vote_active)
    {
        DEBUG_MESSAGE("Vote Cancelled Callback -- Core Inner")        
        DEBUG_MESSAGE("Vote Cancelled and Cancel Callback not yet called!")
        DEBUG_MESSAGE("Setting CVA False -- Cancelled")
        core_vote_active = false;
        CancelVote();
    }
}


//Adds slot blocking to a menu
AddSlotBlockingToMenu(Handle:menu, blockSlots)
{
    //Add blocked slots if...
    //    ...the cvar for blocked slots is enabled.
    if (blockSlots > 3)
        AddMenuItem(menu, NOTHING_OPTION, "", ITEMDRAW_SPACER);
    if (blockSlots > 0)
        AddMenuItem(menu, NOTHING_OPTION, "Slot Block Message 1", ITEMDRAW_DISABLED);
    if (blockSlots > 1)
        AddMenuItem(menu, NOTHING_OPTION, "Slot Block Message 2", ITEMDRAW_DISABLED);
    if (blockSlots > 2)
        AddMenuItem(menu, NOTHING_OPTION, "", ITEMDRAW_SPACER);
    if (blockSlots > 4)
        AddMenuItem(menu, NOTHING_OPTION, "", ITEMDRAW_SPACER);
}


//Called when a vote has finished.
public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
    switch(action)
    {
        case MenuAction_Display:
        {
            //LogUMCMessage("DEBUG: Display");
            new Handle:panel = Handle:param2;
            
            decl String:phrase[255];
            GetMenuTitle(menu, phrase, sizeof(phrase));
            
            decl String:buffer[255];
            FormatEx(buffer, sizeof(buffer), "%T", phrase, param1);
            
            SetPanelTitle(panel, buffer);
        }
        case MenuAction_Select:
        {
            DEBUG_MESSAGE("MenuAction_Select")
            if (GetConVarBool(cvar_logging))
                LogUMCMessage("%L selected menu item %i", param1, param2);
            //TODO
            UMC_VoteManagerClientVoted("core", param1, INVALID_HANDLE);
        }
        case MenuAction_End:
        {
            DEBUG_MESSAGE("MenuAction_End")
            CloseHandle(menu);
            if (GetConVarBool(cvar_logging))
                LogUMCMessage("Vote has concluded.");
        }
        case MenuAction_VoteCancel:
        {
            DEBUG_MESSAGE("Vote Cancelled (Reason: %i)", param1)
            DEBUG_MESSAGE("Is Core Vote still active? %i", core_vote_active)
            if (core_vote_active)
            {
                //Vote was cancelled generically, notify UMC.                
                DEBUG_MESSAGE("Setting CVA False -- Cancelled")
                core_vote_active = false;
                UMC_VoteManagerVoteCancelled("core");
            }
        }
        case MenuAction_DisplayItem:
        {
            //LogUMCMessage("DEBUG: DisplayItem");
            decl String:map[MAP_LENGTH], String:display[MAP_LENGTH];
            GetMenuItem(menu, param2, map, sizeof(map), _, display, sizeof(display));
            
            if (StrEqual(map, EXTEND_MAP_OPTION) || StrEqual(map, DONT_CHANGE_OPTION) ||
                (StrEqual(map, NOTHING_OPTION) && strlen(display) > 0))
            {
                decl String:buffer[255];
                FormatEx(buffer, sizeof(buffer), "%T", display, param1);
                
                return RedrawMenuItem(buffer);
            }
        }
    }
    return 0;
}


//Handles the results of a vote.
public Handle_MapVoteResults(Handle:menu, num_votes, num_clients, const client_info[][2], num_items,
                             const item_info[][2])
{
    DEBUG_MESSAGE("Handling vote results...")
    DEBUG_MESSAGE("Setting CVA False -- Completed")
    core_vote_active = false;

    new Handle:results = ConvertVoteResults(menu, num_clients, client_info, num_items, item_info);
                                            
    UMC_VoteManagerVoteCompleted("core", results, Handle_Response);
    
    //Free Memory
    new size = GetArraySize(results);
    new Handle:item;
    new Handle:clients;
    for (new i = 0; i < size; i++)
    {
        item = GetArrayCell(results, i);
        GetTrieValue(item, "clients", clients);
        CloseHandle(clients);
        CloseHandle(item);
    }
    CloseHandle(results);
}


//
public Handle_Response(UMC_VoteResponse:response, const String:param[])
{
    //Do Nothing
}


//Converts results of a vote to the format required for UMC to process votes.
Handle:ConvertVoteResults(Handle:menu, num_clients, const client_info[][2], num_items,
                          const item_info[][2])
{
    new Handle:result = CreateArray();
    new itemIndex;
    new Handle:voteItem, Handle:voteClientArray;
    decl String:info[MAP_LENGTH], String:disp[MAP_LENGTH];
    for (new i = 0; i < num_items; i++)
    {
        itemIndex = item_info[i][VOTEINFO_ITEM_INDEX];
        GetMenuItem(menu, itemIndex, info, sizeof(info), _, disp, sizeof(disp));
        
        voteItem = CreateTrie();
        voteClientArray = CreateArray();
        
        SetTrieString(voteItem, "info", info);
        SetTrieString(voteItem, "display", disp);
        SetTrieValue(voteItem, "clients", voteClientArray);
        
        PushArrayCell(result, voteItem);
        
        for (new j = 0; j < num_clients; j++)
        {
            if (client_info[j][VOTEINFO_CLIENT_ITEM] == itemIndex)
                PushArrayCell(voteClientArray, client_info[j][VOTEINFO_CLIENT_INDEX]);
        }
    }
    return result;
}


//************************************************************************************************//
//                                        VOTING UTILITIES                                        //
//************************************************************************************************//

//
DisableVoteInProgress(Handle:vM)
{
    DEBUG_MESSAGE("Vote no longer in progress!")
    SetTrieValue(vM, "in_progress", false);
}


//
FreeOptions(Handle:options)
{
    new size = GetArraySize(options);
    new Handle:item;
    for (new i = 0; i < size; i++)
    {
        item = GetArrayCell(options, i);
        CloseHandle(item);
    }
    CloseHandle(options);
}


//
bool:PerformVote(Handle:voteManager, UMC_VoteType:type, Handle:options, time, const clients[], 
                 numClients, const String:startSound[])
{
    new Handle:plugin = INVALID_HANDLE;
    GetTrieValue(voteManager, "plugin", plugin);
    
    new VoteHandler:handler;
    switch (type)
    {
        case VoteType_Map:
        {
            LogUMCMessage("Initiating Vote Type: Map");
            GetTrieValue(voteManager, "map", handler);
        }
        case VoteType_Group:
        {
            LogUMCMessage("Initiating Vote Type: Group");
            GetTrieValue(voteManager, "group", handler);
        }        
        case VoteType_Tier:
        {
            LogUMCMessage("Initiating Vote Type: Stage 1 Tiered");
            GetTrieValue(voteManager, "group", handler);
        }
    }
    
    new Action:result;
    Call_StartFunction(plugin, handler);
    Call_PushCell(time);
    Call_PushCell(options);
    Call_PushArray(clients, numClients);
    Call_PushCell(numClients);
    Call_PushString(startSound);
    Call_Finish(result);
    
    new bool:started = result == Plugin_Continue;
    
    if (started)
    {
        SetTrieValue(voteManager, "in_progress", true);
        SetTrieValue(voteManager, "active", true);
    }
    
    return started;
}


enum UMC_BuildOptionsError
{
    BuildOptionsError_InvalidMapcycle,
    BuildOptionsError_NoMapGroups,
    BuildOptionsError_NotEnoughOptions,
    BuildOptionsError_Success
};


//Build and returns a new vote menu.
Handle:BuildVoteItems(Handle:vM, Handle:kv, Handle:mapcycle, &UMC_VoteType:type, bool:scramble,
                      bool:allowDupes, bool:strictNoms, bool:exclude, bool:extend, bool:dontChange)
{
    new Handle:result = CreateArray();
    new UMC_BuildOptionsError:error;

    switch (type)
    {
        case (VoteType_Map):
        {
            error = BuildMapVoteItems(vM, result, kv, mapcycle, scramble, extend, dontChange, 
                                      allowDupes, strictNoms, .exclude=exclude);
        }
        case (VoteType_Group):
        {
            error = BuildCatVoteItems(vM, result, kv, mapcycle, scramble, extend, dontChange, strictNoms,
                                      exclude);
        }
        case (VoteType_Tier):
        {
            error = BuildCatVoteItems(vM, result, kv, mapcycle, scramble, extend, dontChange, strictNoms,
                                      exclude);
        }
    }

    if ((type == VoteType_Group || type == VoteType_Tier) && error == BuildOptionsError_NotEnoughOptions)
    {
        type = VoteType_Map;
        error = BuildMapVoteItems(vM, result, kv, mapcycle, scramble, extend, dontChange,
                                  allowDupes, strictNoms, .exclude=exclude);
    }

    if (error == BuildOptionsError_InvalidMapcycle || error == BuildOptionsError_NoMapGroups)
    {
        CloseHandle(result);
        result = INVALID_HANDLE;
    }
    
    return result;
}


//Builds and returns a menu for a map vote.
UMC_BuildOptionsError:BuildMapVoteItems(Handle:voteManager, Handle:result, Handle:okv, 
                                        Handle:mapcycle, bool:scramble, bool:extend, 
                                        bool:dontChange, bool:ignoreDupes=false, 
                                        bool:strictNoms=false, bool:ignoreInvoteSetting=false, 
                                        bool:exclude=true)
{
    DEBUG_MESSAGE("MAPVOTE - Building map vote menu.")
    //Throw an error and return nothing if...
    //    ...the mapcycle is invalid.
    if (okv == INVALID_HANDLE)
    {
        LogError("VOTING: Cannot build map vote menu, rotation file is invalid.");
        return BuildOptionsError_InvalidMapcycle;
    }
    
    DEBUG_MESSAGE("Preparing mapcycle for traversal.")
    //Duplicate the kv handle, because we will be deleting some keys.
    KvRewind(okv); //rewind original
    new Handle:kv = CreateKeyValues("umc_rotation"); //new handle
    KvCopySubkeys(okv, kv); //copy everything to the new handle
    
    //Filter mapcycle
    if (exclude)
        FilterMapcycle(kv, mapcycle, .deleteEmpty=false);
    
#if UMC_DEBUG
    LogKv(kv);
#endif
    
    DEBUG_MESSAGE("Checking for groups.")
    //Log an error and return nothing if...
    //    ...it cannot find a category.
    if (!KvGotoFirstSubKey(kv))
    {
        LogError("VOTING: No map groups found in rotation. Vote menu was not built.");
        CloseHandle(kv);
        return BuildOptionsError_NoMapGroups;
    }
    
    DEBUG_MESSAGE("Preparing vote data storage.")
    ClearVoteArrays(voteManager);

    DEBUG_MESSAGE("Getting options from cvars.")
    //Determine how we're logging
    new bool:verboseLogs = GetConVarBool(cvar_logging);
    
    DEBUG_MESSAGE("Initializing Buffers")
    //Buffers
    new String:mapName[MAP_LENGTH];     //Name of the map
    new String:display[MAP_LENGTH];     //String to be displayed in the vote
    new String:gDisp[MAP_LENGTH];
    new String:catName[MAP_LENGTH];     //Name of the category.
    
    //Other variables
    new voteCounter = 0; //Number of maps in the vote currently
    new numNoms = 0;     //Number of nominated maps in the vote.
    new Handle:nominationsFromCat = INVALID_HANDLE; //adt_array containing all nominations from the
                                                    //current category.
    new Handle:tempCatNoms = INVALID_HANDLE;
    new Handle:trie        = INVALID_HANDLE; //a nomination
    new Handle:nameArr     = INVALID_HANDLE; //adt_array of map names from nominations
    new Handle:weightArr   = INVALID_HANDLE; //adt_array of map weights from nominations.
    
    new Handle:map_vote;
    GetTrieValue(voteManager, "map_vote", map_vote);
    
    new Handle:map_vote_display = CreateArray(ByteCountToCells(MAP_LENGTH));
    
    new nomIndex, position, numMapsFromCat, nomCounter, inVote, index; //, cIndex;
    
    new tierAmount = GetConVarInt(cvar_vote_tieramount);
    
    new Handle:nomKV;
    decl String:nomGroup[MAP_LENGTH];
    
    DEBUG_MESSAGE("Performing Traversal")
    //Add maps to vote array from current category.
    do
    {
        WeightMapGroup(kv, mapcycle);
    
        //Store the name of the current category.
        KvGetSectionName(kv, catName, sizeof(catName));
        
        DEBUG_MESSAGE("Fetching map group data")
        
        //Get the map-display template from the categeory definition.
        KvGetString(kv, "display-template", gDisp, sizeof(gDisp), "{MAP}");
        
        DEBUG_MESSAGE("Fetching Nominations")
        
        //Get all nominations for the current category.
        if (exclude)
        {
            tempCatNoms = GetCatNominations(catName);
            nominationsFromCat = FilterNominationsArray(tempCatNoms);        
#if UMC_DEBUG
            DEBUG_MESSAGE("Unfiltered:")
            PrintNominationArray(tempCatNoms);
            DEBUG_MESSAGE("Filtered:")
            PrintNominationArray(nominationsFromCat);
#endif
            CloseHandle(tempCatNoms);
        }
        else
            nominationsFromCat = GetCatNominations(catName);
        
        //Get the amount of nominations for the current category.
        numNoms = GetArraySize(nominationsFromCat);
        
        DEBUG_MESSAGE("Calculating amount of maps needed to be fetched.")
        
        //Get the total amount of maps to appear in the vote from this category.
        inVote = ignoreInvoteSetting 
                    ? tierAmount
                    : KvGetNum(kv, "maps_invote", 1);
        
        if (verboseLogs)
        {
            if (ignoreInvoteSetting)
                LogUMCMessage("VOTE MENU: (Verbose) Second stage tiered vote. See cvar \"sm_umc_vote_tieramount.\"");
            LogUMCMessage("VOTE MENU: (Verbose) Fetching %i maps from group '%s'", inVote, catName);
        }
        
        //Calculate the number of maps we still need to fetch from the mapcycle.
        numMapsFromCat = inVote - numNoms;
        
        DEBUG_MESSAGE("Determining proper nomination processing algorithm.")
        
        //Populate vote with nomination maps from this category if...
        //    ...we do not need to fetch any maps from the mapcycle AND
        //    ...the number of nominated maps in the vote is limited to the maps_invote setting for
        //       the category.
        if (numMapsFromCat < 0 && strictNoms)
        {
            //////
            //The piece of code inside this block is for the case where the current category's
            //nominations exceeds it's number of maps allowed in the vote.
            //
            //In order to solve this problem, we first fetch all nominations where the map has
            //appropriate min and max players for the amount of players on the server, and then
            //randomly pick from this pool based on the weights if the maps, until the number
            //of maps in the vote from this category is reached.
            //////
            
            DEBUG_MESSAGE("Performing strict nomination algorithm.")
            
            if (verboseLogs)
            {
                LogUMCMessage(
                    "VOTE MENU: (Verbose) Number of nominations (%i) exceeds allowable maps in vote for the map group '%s'. Limiting nominated maps to %i. (See cvar \"sm_umc_nominate_strict\")",
                    numNoms, catName, inVote
                );
            }
        
            //No nominations have been fetched from pool of possible nomination.
            nomCounter = 0;
            
            //Populate vote array with nominations from this category if...
            //    ...we have nominations from this category.
            if (numNoms > 0)
            {
                //Initialize name and weight adt_arrays.
                nameArr = CreateArray(ByteCountToCells(MAP_LENGTH));
                weightArr = CreateArray();
                new Handle:cycleArr = CreateArray();
                
                DEBUG_MESSAGE("Fetching data from all nominations in the map group.")
                
                //Store data from a nomination for...
                //    ...each index of the adt_array of nominations from this category.
                for (new i = 0; i < numNoms; i++)
                {
                    DEBUG_MESSAGE("Fetching nomination data.")
                    //Store nomination.
                    trie = GetArrayCell(nominationsFromCat, i);
                    
                    //Get the map name from the nomination.
                    GetTrieString(trie, MAP_TRIE_MAP_KEY, mapName, sizeof(mapName));
                    
                    DEBUG_MESSAGE("Determining what to do with the nomination.")
                    
                    //Add map to list of possible maps to be added to vote from the nominations 
                    //if...
                    //    ...the map is valid (correct number of players, correct time)
                    if (!ignoreDupes && FindStringInVoteArray(mapName, MAP_TRIE_MAP_KEY, map_vote) != -1)
                    {
                        DEBUG_MESSAGE("Skipping repeated nomination.")
                        if (verboseLogs)
                        {
                            LogUMCMessage(
                                "VOTE MENU: (Verbose) Skipping nominated map '%s' from map group '%s' because it already is in the vote.",
                                mapName, catName
                            );
                        }
                    }
                    else
                    {
                        DEBUG_MESSAGE("Adding nomination to the possible vote pool.")
                        //Increment number of noms fetched.
                        nomCounter++;
                        
                        //Fetch mapcycle for weighting
                        GetTrieValue(trie, "mapcycle", nomKV);
                        
                        //Add map name to the pool.
                        PushArrayString(nameArr, mapName);
                        
                        //Add map weight to the pool.
                        PushArrayCell(weightArr, GetMapWeight(nomKV, mapName, catName));
                        
                        PushArrayCell(cycleArr, trie);
                    }
                }
                
                //After we have parsed every map from the list of nominations...
                
                DEBUG_MESSAGE("Choosing nominations from the pool to be inserted into the vote.")
                
                //Populate vote array with maps from the pool if...
                //    ...the number of nominations fetched is greater than zero.
                if (nomCounter > 0)
                {
                    //Add a nominated map from the pool into the vote arrays for...
                    //    ...the number of available spots there are from the category.
                    new min = (inVote < nomCounter) ? inVote : nomCounter;
                    
                    DEBUG_MESSAGE("Begin parsing nomination pool.")
                    
                    for (new i = 0; i < min; i++)
                    {
                        DEBUG_MESSAGE("Fetching a random nomination from the pool.")
                        //Get a random map from the pool.
                        GetWeightedRandomSubKey(mapName, sizeof(mapName), weightArr, nameArr, index);
                        
                        new Handle:nom = GetArrayCell(cycleArr, index);
                        GetTrieValue(nom, "mapcycle", nomKV);
                        
                        GetTrieString(nom, "nom_group", nomGroup, sizeof(nomGroup));
                        
                        DEBUG_MESSAGE("Determining where to place the map in the vote.")
                        //Get the position in the vote array to add the map to
                        position = GetNextMenuIndex(voteCounter, scramble);
                        
                        DEBUG_MESSAGE("Fetching display info for the map from the mapcycle.")
                        
                        //Template
                        new Handle:dispKV = CreateKeyValues("umc_mapcycle");
                        KvCopySubkeys(nomKV, dispKV);
                        GetMapDisplayString(
                            dispKV, nomGroup, mapName, gDisp, display, sizeof(display)
                        );
                        CloseHandle(dispKV);
                        
                        /* KvJumpToKey(nomKV, nomGroup);
                        KvJumpToKey(nomKV, mapName);
                        KvGetString(nomKV, "display", display, sizeof(display), gDisp);
                        
                        DEBUG_MESSAGE("Setting proper display string.")
                        if (strlen(display) == 0)
                            strcopy(display, sizeof(display), mapName);
                        else
                            ReplaceString(display, sizeof(display), "{MAP}", mapName, false);
                        
                        KvGoBack(nomKV);
                        KvGoBack(nomKV); */
                        
                        DEBUG_MESSAGE("Adding nomination to the vote.")
                        
                        DEBUG_MESSAGE("*MEMLEAKTEST* Creating map trie (BuildMapVoteItems) [3]")
                        new Handle:map = CreateMapTrie(mapName, catName);
                        
                        new Handle:nomMapcycle = CreateKeyValues("umc_mapcycle");
                        KvCopySubkeys(nomKV, nomMapcycle);
                        
                        SetTrieValue(map, "mapcycle", nomMapcycle);
                        
                        DEBUG_MESSAGE("*MEMLEAKTEST* Inserting map trie created at [3] into vote manager storage")
                        InsertArrayCell(map_vote, position, map);
                        InsertArrayString(map_vote_display, position, display);
                        
                        //Increment number of maps added to the vote.
                        voteCounter++;
                        
                        DEBUG_MESSAGE("Preventing nomination and map from being picked again.")
                        
                        //Delete the map so it can't be picked again.
                        KvDeleteSubKey(kv, mapName);

                        //Remove map from pool.
                        RemoveFromArray(nameArr, index);
                        RemoveFromArray(weightArr, index);
                        RemoveFromArray(cycleArr, index);
                        
                        if (verboseLogs)
                        {
                            LogUMCMessage(
                                "VOTE MENU: (Verbose) Nominated map '%s' from group '%s' was added to the vote.",
                                mapName, catName
                            );
                        }
                    }
                }
                
                //Close handles for the pool.
                CloseHandle(nameArr);
                CloseHandle(weightArr);
                CloseHandle(cycleArr);
                
                //Update numMapsFromCat to reflect the actual amount still required.
                numMapsFromCat = inVote - nomCounter;
            }
        }
        //Otherwise, we fill the vote with nominations then fill the rest with random maps from the
        //mapcycle.
        else
        {
            DEBUG_MESSAGE("Adding all nominations to the vote.")
            //Add nomination to the vote array for..
            //    ...each index in the nomination array.
            for (new i = 0; i < numNoms; i++)
            {
                DEBUG_MESSAGE("Fetching nomination info.")
                //Get map name.
                new Handle:nom = GetArrayCell(nominationsFromCat, i);
                GetTrieString(nom, MAP_TRIE_MAP_KEY, mapName, sizeof(mapName));
                
                DEBUG_MESSAGE("Determining what to do with the nomination.")
                
                //Add nominated map to the vote array if...
                //    ...the map isn't already in the vote AND
                //    ...the server has a valid number of players for the map.
                if (!ignoreDupes
                    && FindStringInVoteArray(mapName, MAP_TRIE_MAP_KEY, map_vote) != -1)
                {
                    DEBUG_MESSAGE("Skipping repeated nomination.")
                    if (verboseLogs)
                    {
                        LogUMCMessage(
                            "VOTE MENU: (Verbose) Skipping nominated map '%s' from map group '%s' because it is already in the vote.",
                            mapName, catName
                        );
                    }
                }
                else
                {
                    GetTrieValue(nom, "mapcycle", nomKV);
                    GetTrieString(nom, "nom_group", nomGroup, sizeof(nomGroup));
                
                    //Get extra fields from the map
                    new Handle:dispKV = CreateKeyValues("umc_mapcycle");
                    KvCopySubkeys(nomKV, dispKV);
                    GetMapDisplayString(dispKV, nomGroup, mapName, gDisp, display, sizeof(display));
                    CloseHandle(dispKV);
                                        
                    /* KvJumpToKey(nomKV, nomGroup);
                    KvJumpToKey(nomKV, mapName);
                    KvGetString(nomKV, "display", display, sizeof(display), gDisp);
                    
                    DEBUG_MESSAGE("Setting proper display string.")
                    if (strlen(display) == 0)
                        strcopy(display, sizeof(display), mapName);
                    else
                        ReplaceString(display, sizeof(display), "{MAP}", mapName, false);
                        
                    KvGoBack(nomKV);
                    KvGoBack(nomKV); */
                    
                    DEBUG_MESSAGE("Determining where to place the map in the vote.")
                    //Get the position in the vote array to add the map to.
                    position = GetNextMenuIndex(voteCounter, scramble);
                    
                    DEBUG_MESSAGE("Adding nomination to the vote.")
                    
                    DEBUG_MESSAGE("*MEMLEAKTEST* Creating map trie (BuildMapVoteItems) [4]")
                    new Handle:map = CreateMapTrie(mapName, catName);
                        
                    new Handle:nomMapcycle = CreateKeyValues("umc_mapcycle");
                    KvCopySubkeys(nomKV, nomMapcycle);
                    
                    SetTrieValue(map, "mapcycle", nomMapcycle);
                    
                    DEBUG_MESSAGE("*MEMLEAKTEST* Inserting map trie created at [4] into vote manager storage")
                    InsertArrayCell(map_vote, position, map);
                    InsertArrayString(map_vote_display, position, display);
                    
                    //Increment number of maps added to the vote.
                    voteCounter++;
                    
                    DEBUG_MESSAGE("Preventing map from being picked again.")
                        
                    //Delete the map so it cannot be picked again.
                    KvDeleteSubKey(kv, mapName);
                    
                    if (verboseLogs)
                    {
                        LogUMCMessage(
                            "VOTE MENU: (Verbose) Nominated map '%s' from group '%s' was added to the vote.",
                            mapName, catName
                        );
                    }
                }
            }
        }
        
        //////
        //At this point in the algorithm, we have already handled nominations for this category.
        //If there are maps which still need to be added to the vote, we will be fetching them
        //from the mapcycle directly.
        //////
        
        DEBUG_MESSAGE("Finished processing nominations.")
        
        if (verboseLogs)
        {
            LogUMCMessage("VOTE MENU: (Verbose) Finished parsing nominations for map group '%s'",
                catName);
            if (numMapsFromCat > 0)
            {
                LogUMCMessage("VOTE MENU: (Verbose) Still need to fetch %i maps from the group.",
                    numMapsFromCat);
            }
        }
        
        DEBUG_MESSAGE("Current gDisp value: %s", gDisp)
        
        //We no longer need the nominations array, so we close the handle.
        CloseHandle(nominationsFromCat);
        
        DEBUG_MESSAGE("Begin filling remaining spots in the vote.")
        //Add a map to the vote array from the current category while...
        //    ...maps still need to be added from the current category.
        while (numMapsFromCat > 0)
        {
            DEBUG_MESSAGE("Attempting to fetch a map from the group.")
            //Skip the category if...
            //    ...there are no more maps that can be added to the vote.
            if (!GetRandomMap(kv, mapName, sizeof(mapName)))
            {
                if (verboseLogs)
                    LogUMCMessage("VOTE MENU: (Verbose) No more maps in map group '%s'", catName);
                DEBUG_MESSAGE("No more maps in group. Continuing to next group.")
                break;
            }

            //The name of the selected map is now stored in mapName.    
            
            DEBUG_MESSAGE("Checking to make sure the map isn't already in the vote.")
            //Remove the map from the category (so it cannot be selected again) and repick a map 
            //if...
            //    ...the map has already been added to the vote (through nomination or another 
            //       category
            if (!ignoreDupes && FindStringInVoteArray(mapName, MAP_TRIE_MAP_KEY, map_vote) != -1)
            {
                DEBUG_MESSAGE("Map found in vote. Removing from mapcycle.")
                KvDeleteSubKey(kv, mapName);
                if (verboseLogs)
                {
                    LogUMCMessage(
                        "VOTE MENU: (Verbose) Skipping selected map '%s' from map group '%s' because it is already in the vote.",
                        mapName, catName
                    );
                }
                continue;
            }
            
            //At this point we have a map which we are going to add to the vote array.

            if (verboseLogs)
            {
                LogUMCMessage(
                    "VOTE MENU: (Verbose) Selected map '%s' from group '%s' was added to the vote.",
                    mapName, catName
                );
            }
            
            DEBUG_MESSAGE("Searching for map in nominations.")
            //Find this map in the list of nominations.
            nomIndex = FindNominationIndex(mapName, catName);
            
            //Remove the nomination if...
            //    ...it was found.
            if (nomIndex != -1)
            {
                DEBUG_MESSAGE("Map found in nominations.")
                new Handle:nom = GetArrayCell(nominations_arr, nomIndex);
                
                DEBUG_MESSAGE("Calling nomination removal forward.")
                new owner;
                GetTrieValue(nom, "client", owner);
                
                Call_StartForward(nomination_reset_forward);
                Call_PushString(mapName);
                Call_PushCell(owner);
                Call_Finish();
                
                DEBUG_MESSAGE("Removing nomination.")
                new Handle:oldnomKV;
                GetTrieValue(nom, "mapcycle", oldnomKV);
                CloseHandle(oldnomKV);
                CloseHandle(nom);
                RemoveFromArray(nominations_arr, nomIndex);
                if (verboseLogs)
                {
                    LogUMCMessage("VOTE MENU: (Verbose) Removing selected map '%s' from nominations.",
                        mapName);
                }
            }
            
            DEBUG_MESSAGE("Fetching display info for the map from the mapcycle.")
            //Get extra fields from the map
            new Handle:dispKV = CreateKeyValues("umc_mapcycle");
            KvCopySubkeys(okv, dispKV);
            GetMapDisplayString(dispKV, catName, mapName, gDisp, display, sizeof(display));
            CloseHandle(dispKV);
            
            DEBUG_MESSAGE("Display name for %s: '%s'", mapName, display)
            
            /* KvJumpToKey(kv, mapName);
            KvGetString(kv, "display", display, sizeof(display), gDisp);
            
            DEBUG_MESSAGE("Setting proper display string.")
            if (strlen(display) == 0)
                strcopy(display, sizeof(display), mapName);
            else 
                ReplaceString(display, sizeof(display), "{MAP}", mapName, false);
            
            KvGoBack(kv); */
            
            DEBUG_MESSAGE("Determining where to place the map in the vote.")
            //Get the position in the vote array to add the map to.
            position = GetNextMenuIndex(voteCounter, scramble);
            
            DEBUG_MESSAGE("Adding map to the vote.")
                    
            DEBUG_MESSAGE("*MEMLEAKTEST* Creating map trie (BuildMapVoteItems) [5]")
            new Handle:map = CreateMapTrie(mapName, catName);
            
            new Handle:mapMapcycle = CreateKeyValues("umc_mapcycle");
            KvCopySubkeys(mapcycle, mapMapcycle);
            
            SetTrieValue(map, "mapcycle", mapMapcycle);
            
            DEBUG_MESSAGE("*MEMLEAKTEST* Inserting map trie created at [5] into vote manager storage")
            InsertArrayCell(map_vote, position, map);
            InsertArrayString(map_vote_display, position, display);
            
            //Increment number of maps added to the vote.
            voteCounter++;
            
            DEBUG_MESSAGE("Preventing map from being picked again.")
            //Delete the map from the KV so we can't pick it again.
            KvDeleteSubKey(kv, mapName);
            
            //One less map to be added to the vote from this category.
            numMapsFromCat--;
        }
    }
    while (KvGotoNextKey(kv)); //Do this for each category.
    
    //We no longer need the copy of the mapcycle
    CloseHandle(kv);
    
    new Handle:infoArr = BuildNumArray(voteCounter);
    
    new Handle:voteItem = INVALID_HANDLE;
    decl String:buffer[MAP_LENGTH];
    for (new i = 0; i < voteCounter; i++)
    {
        voteItem = CreateTrie();
        GetArrayString(infoArr, i, buffer, sizeof(buffer));
        SetTrieString(voteItem, "info", buffer);
        GetArrayString(map_vote_display, i, buffer, sizeof(buffer));
        SetTrieString(voteItem, "display", buffer);
        PushArrayCell(result, voteItem);
    }
    
    CloseHandle(map_vote_display);
    CloseHandle(infoArr);
    
    if (extend)
    {
        voteItem = CreateTrie();
        SetTrieString(voteItem, "info", EXTEND_MAP_OPTION);
        SetTrieString(voteItem, "display", "Extend Map");
        if (GetConVarBool(cvar_extend_display))
        {
            InsertArrayCell(result, 0, voteItem);
            DEBUG_MESSAGE("Adding Extend Option to start of options list...")
        }
        else
        {
            PushArrayCell(result, voteItem);
            DEBUG_MESSAGE("Adding Extend Option to end of options list...")
        }
    }
    
    if (dontChange)
    {
        voteItem = CreateTrie();
        SetTrieString(voteItem, "info", DONT_CHANGE_OPTION);
        SetTrieString(voteItem, "display", "Don't Change");
        if (GetConVarBool(cvar_dontchange_display))
        {
            InsertArrayCell(result, 0, voteItem);
            DEBUG_MESSAGE("Adding Don't Change Option to start of options list...")
        }
        else
        {
            PushArrayCell(result, voteItem);
            DEBUG_MESSAGE("Adding Don't Change Option to end of options list...")
        }
    }
    
    return BuildOptionsError_Success;
}


//Builds and returns a menu for a group vote.
UMC_BuildOptionsError:BuildCatVoteItems(Handle:vM, Handle:result, Handle:okv, Handle:mapcycle, 
                                        bool:scramble, bool:extend, bool:dontChange, 
                                        bool:strictNoms=false, bool:exclude=true)
{
    //Throw an error and return nothing if...
    //    ...the mapcycle is invalid.
    if (okv == INVALID_HANDLE)
    {
        LogError("VOTING: Cannot build map group vote menu, rotation file is invalid.");
        return BuildOptionsError_InvalidMapcycle;
    }
    
    //Rewind our mapcycle.
    KvRewind(okv); //rewind original
    new Handle:kv = CreateKeyValues("umc_rotation"); //new handle
    KvCopySubkeys(okv, kv);
    
    //Log an error and return nothing if...
    //    ...it cannot find a category.
    if (!KvGotoFirstSubKey(kv))
    {
        LogError("VOTING: No map groups found in rotation. Vote menu was not built.");
        CloseHandle(kv);
        return BuildOptionsError_NoMapGroups;
    }
    
    ClearVoteArrays(vM);
    
    new bool:verboseLogs = GetConVarBool(cvar_logging);
    
    decl String:catName[MAP_LENGTH]; //Buffer to store category name in.
    decl String:mapName[MAP_LENGTH];
    decl String:nomGroup[MAP_LENGTH];
    new voteCounter = 0;      //Number of categories in the vote.
    new Handle:catArray = CreateArray(ByteCountToCells(MAP_LENGTH), 0); //Array of categories in the vote.
    
    new Handle:catNoms = INVALID_HANDLE;
    new Handle:nom = INVALID_HANDLE;
    new size;
    new bool:haveNoms = false;
    
    new Handle:nomKV;
    new Handle:nomMapcycle;
    
    //Add the current category to the vote.
    do
    {
        KvGetSectionName(kv, catName, sizeof(catName));
        
        haveNoms = false;
        
        if (exclude)
        {
            catNoms = GetCatNominations(catName);
            size = GetArraySize(catNoms);
            for (new i = 0; i < size; i++)
            {
                nom = GetArrayCell(catNoms, i);
                GetTrieValue(nom, "mapcycle", nomMapcycle);
                
                nomKV = CreateKeyValues("umc_rotation");
                KvCopySubkeys(nomMapcycle, nomKV);
                
                GetTrieString(nom, "nom_group", nomGroup, sizeof(nomGroup));
                
                GetTrieString(nom, MAP_TRIE_MAP_KEY, mapName, sizeof(mapName));
                
                KvJumpToKey(nomKV, nomGroup);
                
                if (IsValidMapFromCat(nomKV, nomMapcycle, mapName, .isNom=true))
                {
                    haveNoms = true;            
                    CloseHandle(nomKV);
                    break;
                }
                
                CloseHandle(nomKV);
            }
            CloseHandle(catNoms);
        }
        else if (!KvGotoFirstSubKey(kv))
        {
            if (verboseLogs)
            {
                LogUMCMessage(
                    "VOTE MENU: (Verbose) Skipping empty map group '%s'.",
                    catName
                );
            }
            continue;
        }
        else
        {
            KvGoBack(kv);
            haveNoms = true;
        }
        
        //Skip this category if...
        //    ...the server doesn't have the required amount of players or all maps are excluded OR
        //    ...the number of maps in the vote from the category is less than 1.
        if (!haveNoms)
        {
            if (!IsValidCat(kv, mapcycle))
            {
                if (verboseLogs)
                {
                    LogUMCMessage(
                        "VOTE MENU: (Verbose) Skipping excluded map group '%s'.",
                        catName
                    );
                }
                continue;
            }
            else if (KvGetNum(kv, "maps_invote", 1) < 1 && strictNoms)
            {
                if (verboseLogs)
                {
                    LogUMCMessage(
                        "VOTE MENU: (Verbose) Skipping map group '%s' due to \"maps_invote\" setting of 0.",
                        catName
                    );
                }
                continue;
            }
        }
        
        if (verboseLogs)
            LogUMCMessage("VOTE MENU: (Verbose) Group '%s' was added to the vote.", catName);
        
        //Add category to the vote array...
        InsertArrayString(catArray, GetNextMenuIndex(voteCounter, scramble), catName);
        
        //Increment number of categories in the vote.
        voteCounter++;
    }
    while (KvGotoNextKey(kv)); //Do this for each category.
    
    //No longer need the copied mapcycle
    CloseHandle(kv);

    //Fall back to a map vote if only one group is available.
    if (GetArraySize(catArray) == 1)
    {
        CloseHandle(catArray);
        LogUMCMessage("Not enough groups available for group vote, performing map vote with only group available.");
        return BuildOptionsError_NotEnoughOptions;
    }
    
    new Handle:voteItem = INVALID_HANDLE;
    decl String:buffer[MAP_LENGTH];
    for (new i = 0; i < voteCounter; i++)
    {
        voteItem = CreateTrie();
        GetArrayString(catArray, i, buffer, sizeof(buffer));
        SetTrieString(voteItem, "info", buffer);
        SetTrieString(voteItem, "display", buffer);
        PushArrayCell(result, voteItem);
    }
    
    CloseHandle(catArray);
    
    if (extend)
    {
        voteItem = CreateTrie();
        SetTrieString(voteItem, "info", EXTEND_MAP_OPTION);
        SetTrieString(voteItem, "display", "Extend Map");
        if (GetConVarBool(cvar_extend_display))
        {
            InsertArrayCell(result, 0, voteItem);
            DEBUG_MESSAGE("Adding Extend Option to start of options list...")
        }
        else
        {
            PushArrayCell(result, voteItem);
            DEBUG_MESSAGE("Adding Extend Option to end of options list...")
        }
    }
    
    if (dontChange)
    {
        voteItem = CreateTrie();
        SetTrieString(voteItem, "info", DONT_CHANGE_OPTION);
        SetTrieString(voteItem, "display", "Don't Change");
        if (GetConVarBool(cvar_dontchange_display))
        {
            InsertArrayCell(result, 0, voteItem);
            DEBUG_MESSAGE("Adding Don't Change Option to start of options list...")
        }
        else
        {
            PushArrayCell(result, voteItem);
            DEBUG_MESSAGE("Adding Don't Change Option to end of options list...")
        }
    }

    return BuildOptionsError_Success;
}


//Calls the templating system to format a map's display string.
//  kv: Mapcycle containing the template info to use
//  group:  Group of the map we're getting display info for.
//  map:    Name of the map we're getting display info for.
//  buffer: Buffer to store the display string.
//  maxlen: Maximum length of the buffer.
GetMapDisplayString(Handle:kv, const String:group[], const String:map[], const String:template[],
                    String:buffer[], maxlen)
{
    strcopy(buffer, maxlen, "");
    if (KvJumpToKey(kv, group))
    {
        if (KvJumpToKey(kv, map))
        {
            KvGetString(kv, "display", buffer, maxlen, template);
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
    
    Call_StartForward(template_forward);
    Call_PushStringEx(
        buffer, maxlen, 
        SM_PARAM_STRING_UTF8|SM_PARAM_STRING_COPY, 
        SM_PARAM_COPYBACK
    );
    Call_PushCell(maxlen);
    Call_PushCell(kv);
    Call_PushString(map);
    Call_PushString(group);
    Call_Finish();
    
    DEBUG_MESSAGE("GMDS Buffer: %s", buffer)
}


//Replaces {MAP} and {NOMINATED} in template strings.
public UMC_OnFormatTemplateString(String:template[], maxlen, Handle:kv, const String:map[], 
                                  const String:group[])
{
    DEBUG_MESSAGE("OFTS: '%s' '%s' '%s'", map, group, template)

    if (strlen(template) == 0)
    {
        strcopy(template, maxlen, map);
        return;
    }
    
    ReplaceString(template, maxlen, "{MAP}", map, false);
    
    decl String:nomString[16];
    GetConVarString(cvar_nomdisp, nomString, sizeof(nomString));
    ReplaceString(template, maxlen, "{NOMINATED}", nomString, false);
    
    DEBUG_MESSAGE("OFTS End: %s", template)
}


//Selects a random map from a category based off of the supplied weights for the maps.
//    kv:     a mapcycle whose traversal stack is currently at the level of the category to choose 
//            from.
//    buffer:    a string to store the selected map in
//    key:  the key containing the weight information (for maps, 'weight', for cats, 'group_weight')
//    excluded: an adt_array of maps to exclude from the selection.
//bool:GetRandomMap(Handle:kv, String:buffer[], size, Handle:excluded, Handle:excludedCats, 
//                  bool:isNom=false, bool:forMapChange=true, bool:memory=true)
bool:GetRandomMap(Handle:kv, String:buffer[], size)
{
    decl String:catName[MAP_LENGTH];
    KvGetSectionName(kv, catName, sizeof(catName));
    
    DEBUG_MESSAGE("Preparing mapcycle for random map selection.")
    //Return failure if...
    //    ...there are no maps in the category.
    if (!KvGotoFirstSubKey(kv))
    {
        DEBUG_MESSAGE("No maps found in map group %s. Return false.", catName)
        return false;
    }

    DEBUG_MESSAGE("Preparing to traverse maps in the group.")
    new index = 0; //counter of maps in the random pool
    new Handle:nameArr = CreateArray(ByteCountToCells(MAP_LENGTH)); //Array to store possible map names
    new Handle:weightArr = CreateArray();  //Array to store possible map weights.
    decl String:temp[MAP_LENGTH]; //Buffer to store map names in.
    
    //Add a map to the random pool.
    do
    {
        //Get the name of the map.
        KvGetSectionName(kv, temp, sizeof(temp));
        
        DEBUG_MESSAGE("Adding map %s to the pool.", temp)
        
        //Add the map to the random pool.
        PushArrayCell(weightArr, GetWeight(kv));
        PushArrayString(nameArr, temp);
        
        //One more map in the pool.
        index++;
    }
    while (KvGotoNextKey(kv)); //Do this for each map.
    
    DEBUG_MESSAGE("Finished populating random pool.")
    
    //Go back to the category level.
    KvGoBack(kv);

    //Close pool and fail if...
    //    ...no maps are selectable.
    if (index == 0)
    {
        DEBUG_MESSAGE("No maps found in pool. Returning false.")
        CloseHandle(nameArr);
        CloseHandle(weightArr);
        return false;
    }

    DEBUG_MESSAGE("Getting random map from the pool.")
    
    //Use weights to randomly select a map from the pool.
    new bool:result = GetWeightedRandomSubKey(buffer, size, weightArr, nameArr, _);
    
    //Close the pool.
    CloseHandle(nameArr);
    CloseHandle(weightArr);
    
    //Done!
    return result;
}


//Searches array for given string. Returns -1 on failure.
FindStringInVoteArray(const String:target[], const String:val[], Handle:arr)
{
    new size = GetArraySize(arr);
    decl String:buffer[MAP_LENGTH];
    for (new i = 0; i < size; i++)
    {
        GetTrieString(GetArrayCell(arr, i), val, buffer, sizeof(buffer));
        if (StrEqual(buffer, target))
            return i;
    }
    return -1;
}


//Catches the case where a vote occurred but nobody voted.
VoteCancelled(Handle:vM)
{
    DEBUG_MESSAGE("*VoteCancelled*")
    new Handle:plugin, UMC_VoteCancelledHandler:handler;
    new bool:vote_inprogress;//, bool:vote_active;
    GetTrieValue(vM, "in_progress", vote_inprogress);
    //GetTrieValue(vM, "active", vote_active);
    if (vote_inprogress)
    {
        DEBUG_MESSAGE("Cancelling vote that is in progress...")
    
        GetTrieValue(vM, "cancel", handler);
        GetTrieValue(vM, "plugin", plugin);
        
        /*if (vote_active)
        {
            LogUMCMessage("Map vote ended with no votes.");
        
            //Reset flags
            SetTrieValue(vM, "active", false);
            //vote_active = false;
            
            //Cleanup the vote
        }*/
        
        ClearVoteArrays(vM);
        EmptyStorage(vM);
        DeleteVoteParams(vM);
        VoteFailed(vM);
        
        Call_StartFunction(plugin, handler);
        Call_Finish();
    }
#if UMC_DEBUG
    else
    {
        DEBUG_MESSAGE("Vote not in progress, nothing to cancel!")
    }
#endif
}


//Utility function to clear all the voting storage arrays.
ClearVoteArrays(Handle:voteManager)
{
    new Handle:map_vote;
    GetTrieValue(voteManager, "map_vote", map_vote);
    
    new size = GetArraySize(map_vote);
    new Handle:mapTrie;
    new Handle:kv;
    for (new i = 0; i < size; i++)
    {
        mapTrie = GetArrayCell(map_vote, i);
        GetTrieValue(mapTrie, "mapcycle", kv);
        CloseHandle(kv);
        DEBUG_MESSAGE("*MEMLEAKTEST* Closing map trie (ClearVoteArrays) {3, 4, 5}")
        CloseHandle(mapTrie);
    }
    ClearArray(map_vote);
}


//Get the winner from a vote.
any:GetWinner(Handle:vM)
{
    new Handle:vote_storage;
    GetTrieValue(vM, "vote_storage", vote_storage);
    
    new counter = 1;
    new Handle:voteItem = GetArrayCell(vote_storage, 0);
    new Handle:voteClients = INVALID_HANDLE;
    GetTrieValue(voteItem, "clients", voteClients);
    new most_votes = GetArraySize(voteClients);
    new num_items = GetArraySize(vote_storage);
    while (counter < num_items)
    {
        GetTrieValue(GetArrayCell(vote_storage, counter), "clients", voteClients);
        if (GetArraySize(voteClients) < most_votes)
            break;
        counter++;
    }
    if (counter > 1)
        return GetArrayCell(vote_storage, GetRandomInt(0, counter - 1));
    else
        return GetArrayCell(vote_storage, 0);
}


//Generates a list of categories to be excluded from the second stage of a tiered vote.
stock Handle:MakeSecondTieredCatExclusion(Handle:kv, const String:cat[])
{
    //Log an error and return nothing if...
    //  ...there are no categories in the cycle (for some reason).
    if (!KvJumpToKey(kv, cat))
    {
        LogError("TIERED VOTE: Cannot create second stage of vote, rotation file is invalid (no groups were found.)");
        return INVALID_HANDLE;
    }
    
    //Array to return at the end.
    new Handle:result = CreateKeyValues("umc_rotation");
    KvJumpToKey(result, cat, true);
    
    KvCopySubkeys(kv, result);
    
    //Return to the root.
    KvGoBack(kv);
    KvGoBack(result);
    
    //Success!
    return result;
}


//Updates the display for the interval between tiered votes.
DisplayTierMessage(timeleft)
{
    decl String:msg[255], String:notification[10];
    FormatEx(msg, sizeof(msg), "%t", "Another Vote", timeleft);
    GetConVarString(cvar_vote_tierdisplay, notification, sizeof(notification));
    DisplayServerMessage(msg, notification);
}


//Empties the vote storage
EmptyStorage(Handle:vM)
{
    new Handle:vote_storage;
    GetTrieValue(vM, "vote_storage", vote_storage);
    
    new size = GetArraySize(vote_storage);
    for (new i = 0; i < size; i++)
        RemoveFromStorage(vM, 0);
    
    SetTrieValue(vM, "total_votes", 0);
}


//Removes a vote item from the storage
RemoveFromStorage(Handle:vM, index)
{
    new Handle:vote_storage, total_votes;
    GetTrieValue(vM, "vote_storage", vote_storage);
    GetTrieValue(vM, "total_votes", total_votes);
    
    new Handle:stored = GetArrayCell(vote_storage, index);
    new Handle:clients = INVALID_HANDLE;
    GetTrieValue(stored, "clients", clients);
    SetTrieValue(vM, "total_votes", total_votes - GetArraySize(clients));
    CloseHandle(clients);
    CloseHandle(stored);
    RemoveFromArray(vote_storage, index);
}


//Gets the winning info for the vote
GetVoteWinner(Handle:vM, String:info[], maxinfo, &Float:percentage, String:disp[]="", maxdisp=0)
{
    new total_votes;
    GetTrieValue(vM, "total_votes", total_votes);

    new Handle:winner = GetWinner(vM);
    new Handle:clients = INVALID_HANDLE;
    GetTrieString(winner, "info", info, maxinfo);
    GetTrieString(winner, "display", disp, maxdisp);
    GetTrieValue(winner, "clients", clients);
    percentage = float(GetArraySize(clients)) / total_votes * 100;
}


//Finds the index of the given vote item in the storage array. Returns -1 on failure.
FindVoteInStorage(Handle:vote_storage, const String:info[])
{
    new arraySize = GetArraySize(vote_storage);
    new Handle:vote = INVALID_HANDLE;
    decl String:infoBuf[255];
    for (new i = 0; i < arraySize; i++)
    {
        vote = GetArrayCell(vote_storage, i);
        GetTrieString(vote, "info", infoBuf, sizeof(infoBuf));
        if (StrEqual(info, infoBuf))
            return i;
    }
    return -1;
}


//Comparison function for stored vote items. Used for sorting.
public CompareStoredVoteItems(index1, index2, Handle:array, Handle:hndl)
{
    new size1, size2;
    new Handle:vote = INVALID_HANDLE;
    new Handle:clientArray = INVALID_HANDLE;
    vote = GetArrayCell(array, index1);
    GetTrieValue(vote, "clients", clientArray);
    size1 = GetArraySize(clientArray);
    vote = GetArrayCell(array, index2);
    GetTrieValue(vote, "clients", clientArray);
    size2 = GetArraySize(clientArray);
    return size2 - size1;
}


//Adds vote results to the vote storage
AddToStorage(Handle:vM, Handle:vote_results)
{
    new Handle:vote_storage;
    GetTrieValue(vM, "vote_storage", vote_storage);
    
    SetTrieValue(vM, "prev_vote_count", GetArraySize(vote_storage));
    DEBUG_MESSAGE("Old storage size (PVC): %i", GetArraySize(vote_storage))
    
    new num_items = GetArraySize(vote_results);
    new storageIndex;
    new num_votes = 0;
    new Handle:voteItem = INVALID_HANDLE;
    new Handle:voteClientArray = INVALID_HANDLE;
    decl String:infoBuffer[255], String:dispBuffer[255];
    for (new i = 0; i < num_items; i++)
    {
        voteItem = GetArrayCell(vote_results, i);
        GetTrieString(voteItem, "info", infoBuffer, sizeof(infoBuffer));
        storageIndex = FindVoteInStorage(vote_storage, infoBuffer);
        GetTrieValue(voteItem, "clients", voteClientArray);
        num_votes += GetArraySize(voteClientArray);
        if (storageIndex == -1)
        {
            new Handle:newItem = CreateTrie();
            SetTrieString(newItem, "info", infoBuffer);
            GetTrieString(voteItem, "display", dispBuffer, sizeof(dispBuffer));
            SetTrieString(newItem, "display", dispBuffer);
            SetTrieValue(newItem, "clients", CloneArray(voteClientArray));
            PushArrayCell(vote_storage, newItem);
        }
        else
        {
            new Handle:storageClientArray;
            GetTrieValue(GetArrayCell(vote_storage, storageIndex), "client", storageClientArray);
            ArrayAppend(storageClientArray, voteClientArray);
        }
    }
    SortADTArrayCustom(vote_storage, CompareStoredVoteItems);
    
    new total_votes;
    GetTrieValue(vM, "total_votes", total_votes);
    SetTrieValue(vM, "total_votes", total_votes + num_votes);
    
    DEBUG_MESSAGE("New storage size: %i", GetArraySize(vote_storage))
}


//Handles the results of a vote
Handle:ProcessVoteResults(Handle:vM, Handle:vote_results)
{
    new Handle:result = CreateTrie();

    DEBUG_MESSAGE("Processing vote results")
    
    //Vote is no longer running.
    //vote_active = false;
    SetTrieValue(vM, "active", false);
    
    //Adds these results to the storage.
    AddToStorage(vM, vote_results);
    
    //Perform a runoff vote if it is necessary.
    if (NeedRunoff(vM))
    {
        new remaining_runoffs, prev_vote_count;
        GetTrieValue(vM, "remaining_runoffs", remaining_runoffs);
        GetTrieValue(vM, "prev_vote_count", prev_vote_count);
        
        DEBUG_MESSAGE("Will Runoff? (RR: %i) (PVC: %i)", remaining_runoffs, prev_vote_count)
        
        //If we can't runoff anymore
        if (remaining_runoffs == 0 || prev_vote_count == 2)
        {
            DEBUG_MESSAGE("Can't runoff, performing failure action.")
            
            //Retrieve
            new UMC_RunoffFailAction:stored_fail_action;
            GetTrieValue(vM, "stored_fail_action", stored_fail_action);
            
            if (stored_fail_action == RunoffFailAction_Accept)
            {
                ProcessVoteWinner(vM, result);
            }
            else if (stored_fail_action == RunoffFailAction_Nothing)
            {
                new total_votes;
                GetTrieValue(vM, "total_votes", total_votes);
                new Float:percentage;
                GetVoteWinner(vM, "", 0, percentage);
                PrintToChatAll(
                    "\x03[UMC]\x01 %t (%t)",
                    "Vote Failed",
                    "Vote Win Percentage",
                        percentage,
                        total_votes
                );
                LogUMCMessage("MAPVOTE: Vote failed, winning map did not reach threshold.");
                VoteFailed(vM);                
                DeleteVoteParams(vM);
                ClearVoteArrays(vM);
                SetTrieValue(result, "response", VoteResponse_Fail);
            }
            EmptyStorage(vM);
        }
        else
        {
            DoRunoffVote(vM, result);
        }
    }
    else //Otherwise set the results.
    {
        ProcessVoteWinner(vM, result);
        EmptyStorage(vM);
    }
    return result;
}


//Processes the winner from the vote.
ProcessVoteWinner(Handle:vM, Handle:response)
{
    //Detemine winner information.
    decl String:winner[255], String:disp[255];
    new Float:percentage;
    GetVoteWinner(vM, winner, sizeof(winner), percentage, disp, sizeof(disp));
    
    new UMC_VoteType:stored_type;
    GetTrieValue(vM, "stored_type", stored_type);
    
    SetTrieValue(response, "response", VoteResponse_Success);
    SetTrieString(response, "param", disp);
    
    switch (stored_type)
    {
        case VoteType_Map:
            Handle_MapVoteWinner(vM, winner, disp, percentage);
        case VoteType_Group:
            Handle_CatVoteWinner(vM, winner, disp, percentage);
        case VoteType_Tier:
        {
            SetTrieValue(response, "response", VoteResponse_Tiered);
            Handle_TierVoteWinner(vM, winner, disp, percentage);
        }
    }
}


//Determines if a runoff vote is needed.
bool:NeedRunoff(Handle:vM)
{
    //Retrive
    new Float:stored_threshold, total_votes;
    new Handle:vote_storage;
    GetTrieValue(vM, "stored_threshold", stored_threshold);
    GetTrieValue(vM, "total_votes", total_votes);
    GetTrieValue(vM, "vote_storage", vote_storage);

    DEBUG_MESSAGE("Determining if the vote meets the defined threshold of %f", stored_threshold)
    
    //Get the winning vote item.
    new Handle:voteItem = GetArrayCell(vote_storage, 0);
    new Handle:clients = INVALID_HANDLE;
    GetTrieValue(voteItem, "clients", clients);
    
    new numClients = GetArraySize(clients);
    new bool:result = (float(numClients) / total_votes) < stored_threshold;
    return result;
}


//Sets up a runoff vote.
DoRunoffVote(Handle:vM, Handle:response)
{   
    DEBUG_MESSAGE("Performing runoff vote")
    
    new remaining_runoffs;
    GetTrieValue(vM, "remaining_runoffs", remaining_runoffs);
    SetTrieValue(vM, "remaining_runoffs", remaining_runoffs - 1);

    //Array to store clients the menu will be displayed to.
    new Handle:runoffClients = CreateArray();
    
    //Build the runoff vote based off of the results of the failed vote.
    new Handle:runoffOptions = BuildRunoffOptions(vM, runoffClients);

    //Setup the timer if...
    //  ...the menu was built successfully
    if (runoffOptions != INVALID_HANDLE)
    {   
        new clients[MAXPLAYERS+1];
        new numClients;
    
        //Empty storage and add all clients if we're revoting completely.
        if (!GetConVarBool(cvar_runoff_selective))
        {
            DEBUG_MESSAGE("Non-selective runoff vote: erasing storage and adding all clients.")
            ClearArray(runoffClients);
            EmptyStorage(vM);
            
            /* decl String:adminFlags[64];
            GetTrieString(vM, "stored_adminflags", adminFlags, sizeof(adminFlags)); */
            
            new users[MAXPLAYERS+1];
            GetTrieArray2(vM, "stored_users", users, sizeof(users), numClients);
            ConvertUserIDsToClients(users, clients, numClients);
            
            //runoffClients = GetClientsWithFlags(adminFlags);
            ConvertArray(clients, numClients, runoffClients);
        }
        
        //Setup timer to delay the start of the runoff vote.
        SetTrieValue(vM, "runoff_delay", 7);
        
        //Display the first message
        DisplayRunoffMessage(8);
        
        DEBUG_MESSAGE("Runoff timer created. Runoff vote will be displayed in %i seconds.", 8)
        
        //Setup data pack to go along with the timer.
        new Handle:pack;    
        CreateDataTimer(
            1.0,
            Handle_RunoffVoteTimer,
            pack,
            TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT
        );
        //Add info to the pack.
        WritePackCell(pack, _:vM);
        WritePackCell(pack, _:runoffOptions);
        WritePackCell(pack, _:runoffClients);
        SetTrieValue(response, "response", VoteResponse_Runoff);
    }
    else //Otherwise, cleanup
    {
        LogError("RUNOFF: Unable to create runoff vote menu, runoff aborted.");
        CloseHandle(runoffClients);
        VoteFailed(vM);
        EmptyStorage(vM);
        DeleteVoteParams(vM);
        ClearVoteArrays(vM);
        SetTrieValue(response, "response", VoteResponse_Fail);
    }
}


//Builds a runoff vote menu.
//  clientArray:    adt_array to be populated with clients whose votes were eliminated
Handle:BuildRunoffOptions(Handle:vM, Handle:clientArray)
{
    new Handle:vote_storage, Float:stored_threshold;
    GetTrieValue(vM, "vote_storage", vote_storage);
    GetTrieValue(vM, "stored_threshold", stored_threshold);

    new bool:verboseLogs = GetConVarBool(cvar_logging);
    if (verboseLogs)
        LogUMCMessage("RUNOFF MENU: (Verbose) Building runoff vote menu.");
    
    new Float:runoffThreshold = stored_threshold;
    
    //Copy the current total number of votes. Needed because the number will change as we remove items.
    new totalVotes;
    GetTrieValue(vM, "total_votes", totalVotes);
    
    new Handle:voteItem = INVALID_HANDLE;
    new Handle:voteClients = INVALID_HANDLE;
    new voteNumVotes;
    new num_items = GetArraySize(vote_storage);
    
    //Array determining which clients have voted
    new bool:clientVotes[MAXPLAYERS + 1];
    for (new i = 0; i < num_items; i++)
    {
        voteItem = GetArrayCell(vote_storage, i);
        GetTrieValue(voteItem, "clients", voteClients);
        voteNumVotes = GetArraySize(voteClients);
        
        for (new j = 0; j < voteNumVotes; j++)
            clientVotes[GetArrayCell(voteClients, j)] = true;
    }
    for (new i = 1; i <= MaxClients; i++)
    {
        if (!clientVotes[i])
            PushArrayCell(clientArray, i);
    }
    
    new Handle:winning = GetArrayCell(vote_storage, 0);
    new winningNumVotes;
    new Handle:winningClients = INVALID_HANDLE;
    GetTrieValue(winning, "clients", winningClients);
    winningNumVotes = GetArraySize(winningClients);
    
    //Starting max possible percentage of the winning item in this vote.
    new Float:percent = float(winningNumVotes) / float(totalVotes) * 100;
    new Float:newPercent;
    
    //Max number of maps in the runoff vote
    new maxMaps;
    GetTrieValue(vM, "stored_runoffmaps_max", maxMaps);
    new bool:checkMax = maxMaps > 1;
    
    //Starting at the item with the least votes, calculate the new possible max percentage
    //of the winning item. Stop when this percentage is greater than the threshold.
    for (new i = num_items - 1; i > 1; i--)
    {
        voteItem = GetArrayCell(vote_storage, i);
        GetTrieValue(voteItem, "clients", voteClients);
        voteNumVotes = GetArraySize(voteClients);
        ArrayAppend(clientArray, voteClients);
        
        newPercent = float(voteNumVotes) / float(totalVotes) * 100;
        percent += newPercent;
        
        if (verboseLogs)
        {
            new String:dispBuf[255];
            GetTrieString(voteItem, "display", dispBuf, sizeof(dispBuf));
            LogUMCMessage(
                "RUNOFF MENU: (Verbose) '%s' was removed from the vote. It had %i votes (%.f%% of total)",
                dispBuf, voteNumVotes, newPercent
            );
        }
        
        //No longer store the map
        RemoveFromStorage(vM, i);
        num_items--;
        
        //Stop if...
        //  ...the new percentage is over the threshold AND
        //  ...the number of maps in the vote is under the max.
        if (percent >= runoffThreshold && (!checkMax || num_items <= maxMaps))
            break;
    }
    
    if (verboseLogs)
    {
        LogUMCMessage(
            "RUNOFF MENU: (Verbose) Stopped removing options from the vote. Maximum possible winning vote percentage is %.f%%.",
            percent
        );
    }
    
    //Start building the new vote menu.
    new Handle:newMenu = CreateArray();
    
    //Populate the new menu with what remains of the storage.
    new count = 0;
    decl String:info[255], String:disp[255];
    new Handle:item;
    for (new i = 0; i < num_items; i++)
    {
        voteItem = GetArrayCell(vote_storage, i);
        GetTrieString(voteItem, "info", info, sizeof(info));
        GetTrieString(voteItem, "display", disp, sizeof(disp));
        
        DEBUG_MESSAGE("*MEMLEAKTEST* Creating VoteOption Trie for Runoff (BuildRunoffOptions) [6]")
        item = CreateTrie();
        SetTrieString(item, "info", info);
        SetTrieString(item, "display", disp);
        PushArrayCell(newMenu, item);
        
        count++;
    }
    
    //Log an error and do nothing if...
    //  ...there weren't enough items added to the runoff vote.
    //  *This shouldn't happen if the algorithm is working correctly*
    if (count < 2)
    {
        
        for (new i = 0; i < count; i++)
        {
            DEBUG_MESSAGE("*MEMLEAKTEST* Closing VoteOptionTrie for Runoff error (BuildRunoffOptions) {6}")
            CloseHandle(GetArrayCell(newMenu, i));
        }
        CloseHandle(newMenu);
        LogError(
            "RUNOFF: Not enough remaining maps to perform runoff vote. %i maps remaining. Please notify plugin author.",
            count
        );
        return INVALID_HANDLE;
    }
    
    return newMenu;
}
                       
                       
//Called when the runoff timer for an end-of-map vote completes.
public Action:Handle_RunoffVoteTimer(Handle:timer, Handle:datapack)
{    
    ResetPack(datapack);
    new Handle:vM = Handle:ReadPackCell(datapack);

    new bool:vote_inprogress;
    GetTrieValue(vM, "in_progress", vote_inprogress);

    if (!vote_inprogress)
    {
        VoteFailed(vM);
        EmptyStorage(vM);
        DeleteVoteParams(vM);
        ClearVoteArrays(vM);
        
        new Handle:options = Handle:ReadPackCell(datapack);
        new Handle:clients = Handle:ReadPackCell(datapack);
        FreeOptions(options);
        CloseHandle(clients);
        
        return Plugin_Stop;
    }
    
    new runoff_delay;
    GetTrieValue(vM, "runoff_delay", runoff_delay);
    
    DisplayRunoffMessage(runoff_delay);

    //Display a message and continue timer if...
    //  ...the timer hasn't finished yet.
    if (runoff_delay > 0)
    {
        if (strlen(countdown_sound) > 0)
            EmitSoundToAll(countdown_sound);
        
        SetTrieValue(vM, "runoff_delay", runoff_delay - 1);
        return Plugin_Continue;
    }

    LogUMCMessage("RUNOFF: Starting runoff vote.");
    
    //Log an error and do nothing if...
    //    ...another vote is currently running for some reason.
    if (IsVoteInProgress()) 
    {
        //LogUMCMessage("RUNOFF: There is a vote already in progress, cannot start a new vote.");
        return Plugin_Continue;
    }
    
    new Handle:options = Handle:ReadPackCell(datapack);
    new Handle:voteClients = Handle:ReadPackCell(datapack);
    
    new clients[MAXPLAYERS+1];
    new numClients = GetArraySize(voteClients);
    ConvertAdtArray(voteClients, clients, sizeof(clients));
    
    CloseHandle(voteClients);
    
    new UMC_VoteType:type;
    GetTrieValue(vM, "stored_type", type);
    new time;
    GetTrieValue(vM, "stored_votetime", time);
    decl String:sound[PLATFORM_MAX_PATH];
    GetTrieString(vM, "stored_runoff_sound", sound, sizeof(sound));
    
    new bool:vote_active = PerformVote(vM, type, options, time, clients, numClients, sound);
    if (!vote_active)
    {
        DeleteVoteParams(vM);
        ClearVoteArrays(vM);
        EmptyStorage(vM);
        VoteFailed(vM);
    }
    
    FreeOptions(options);
    
   /*  //Play the vote start sound if...
    //  ...the filename is defined.
    if (strlen(stored_runoff_sound) > 0)
        EmitSoundToAll(stored_runoff_sound);
    //Otherwise, play the sound for end-of-map votes if...
    //  ...the filename is defined.
    else if (strlen(stored_start_sound) > 0)
        EmitSoundToAll(stored_start_sound);
    
    //Run the vote to selected client only if...
    //  ...the cvar to do so is enabled.
    if (GetConVarBool(cvar_runoff_selective))
    {
        //Log an error if...
        //    ...the vote cannot start for some reason.
        if (!VoteMenu(runoff_menu, clients, numClients, stored_votetime))
            LogUMCMessage("RUNOFF: Menu already has a vote in progress, cannot start a new vote.");
        else
        {
            PrintToChatAll("\x03[UMC]\x01 %t", "Selective Runoff");
            vote_active = true;
        }
    }
    //Otherwise, just display it to everybody.
    else
    {
        //Log an error if...
        //    ...the vote cannot start for some reason.
        if (!VoteMenuToAllWithFlags(runoff_menu, stored_votetime, stored_adminflags))
            LogUMCMessage("RUNOFF: Menu already has a vote in progress, cannot start a new vote.");
        else
            vote_active = true;
    } */

    return Plugin_Stop;
}


//Displays a notification for the impending runoff vote.
DisplayRunoffMessage(timeRemaining)
{
    decl String:msg[255], String:notification[10];
    if (timeRemaining > 5)
        FormatEx(msg, sizeof(msg), "%t", "Runoff Msg");
    else
        FormatEx(msg, sizeof(msg), "%t", "Another Vote", timeRemaining);
    GetConVarString(cvar_runoff_display, notification, sizeof(notification));
    DisplayServerMessage(msg, notification);
}


//Handles the winner of an end-of-map map vote.
public Handle_MapVoteWinner(Handle:vM, const String:info[], const String:disp[],
                            Float:percentage)
{
    //vote_completed = true;
    
    new total_votes;
    GetTrieValue(vM, "total_votes", total_votes);

    //Print a message and extend the current map if...
    //    ...the server voted to extend the map.
    if (StrEqual(info, EXTEND_MAP_OPTION))
    {
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "Map Extended",
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        LogUMCMessage("MAPVOTE: Players voted to extend the map.");
        ExtendMap(vM);
    }
    else if (StrEqual(info, DONT_CHANGE_OPTION))
    {
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "Map Unchanged",
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        
        LogUMCMessage("MAPVOTE: Players voted to stay on the map (Don't Change).");
        VoteFailed(vM);
    }
    else //Otherwise, we print a message and then set the new map.
    {
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "End of Map Vote Map Won",
                disp,
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        
        new Handle:map_vote, UMC_ChangeMapTime:change_map_when;
        GetTrieValue(vM, "map_vote", map_vote);
        GetTrieValue(vM, "change_map_when", change_map_when);
        decl String:stored_reason[PLATFORM_MAX_PATH];
        GetTrieString(vM, "stored_reason", stored_reason, sizeof(stored_reason));
        
        //Find the index of the winning map in the stored vote array.
        new index = StringToInt(info);
        decl String:map[MAP_LENGTH], String:group[MAP_LENGTH];
        
        new Handle:mapData = GetArrayCell(map_vote, index);
        GetTrieString(mapData, MAP_TRIE_MAP_KEY, map, sizeof(map));
        GetTrieString(mapData, MAP_TRIE_GROUP_KEY, group, sizeof(group));

        new Handle:mapcycle;
        GetTrieValue(mapData, "mapcycle", mapcycle);
        
        //Set it.
        DisableVoteInProgress(vM);
        DoMapChange(change_map_when, mapcycle, map, group, stored_reason, disp);
        
        LogUMCMessage("MAPVOTE: Players voted for map '%s' from group '%s'", map, group);
    }
    
    decl String:stored_end_sound[PLATFORM_MAX_PATH];
    GetTrieString(vM, "stored_end_sound", stored_end_sound, sizeof(stored_end_sound));
    
    //Play the vote completed sound if...
    //  ...the vote completed sound is defined.
    if (strlen(stored_end_sound) > 0)
        EmitSoundToAll(stored_end_sound);
    
    //No longer need the vote array.
    ClearVoteArrays(vM);
    DeleteVoteParams(vM);
}


//Handles the winner of an end-of-map category vote.
public Handle_CatVoteWinner(Handle:vM, const String:cat[], const String:disp[],
                            Float:percentage)
{
    DEBUG_MESSAGE("Handling group vote winner: %s", cat)
    //vote_completed = true;
    
    new total_votes;
    GetTrieValue(vM, "total_votes", total_votes);
    
    //Print a message and extend the map if...
    //    ...the server voted to extend the map.
    if (StrEqual(cat, EXTEND_MAP_OPTION))
    {
        DEBUG_MESSAGE("Map was extended")
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "Map Extended",
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        LogUMCMessage("Players voted to extend the map.");
        ExtendMap(vM);
    }
    else if (StrEqual(cat, DONT_CHANGE_OPTION))
    {
        DEBUG_MESSAGE("Map was not changed.")
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "Map Unchanged",
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        
        LogUMCMessage("Players voted to stay on the map (Don't Change).");
        VoteFailed(vM);
    }
    else //Otherwise, we pick a random map from the category and set that as the next map.
    {
        decl String:map[MAP_LENGTH];
        
        DEBUG_MESSAGE("Rewinding and copying the mapcycle")
        
        new Handle:stored_kv, Handle:stored_mapcycle;
        new UMC_ChangeMapTime:change_map_when;
        decl String:stored_reason[PLATFORM_MAX_PATH];
        new bool:stored_exclude;
        GetTrieValue(vM, "stored_kv", stored_kv);
        GetTrieValue(vM, "stored_mapcycle", stored_mapcycle);
        GetTrieValue(vM, "change_map_when", change_map_when);
        GetTrieString(vM, "stored_reason", stored_reason, sizeof(stored_reason));
        GetTrieValue(vM, "stored_exclude", stored_exclude);
        
        //Rewind the mapcycle.
        KvRewind(stored_kv); //rewind original
        new Handle:kv = CreateKeyValues("umc_rotation");
        KvCopySubkeys(stored_kv, kv);
                    
        //Jump to the category in the mapcycle.
        KvJumpToKey(kv, cat);
        
        if (stored_exclude)
        {
            DEBUG_MESSAGE("Filtering the map group")
            FilterMapGroup(kv, stored_mapcycle);
#if UMC_DEBUG
            LogKv(kv);
#endif
        }
        
        DEBUG_MESSAGE("Weighting map group")

        WeightMapGroup(kv, stored_mapcycle);
        
        new Handle:nominationsFromCat;
        
        //An adt_array of nominations from the given category.
        if (stored_exclude)
        {
            DEBUG_MESSAGE("Filtering Nominations")
            new Handle:tempCatNoms = GetCatNominations(cat);
            nominationsFromCat = FilterNominationsArray(tempCatNoms);
            CloseHandle(tempCatNoms);
        }
        else
            nominationsFromCat = GetCatNominations(cat);
        
        //if...
        //    ...there are nominations for this category.
        if (GetArraySize(nominationsFromCat) > 0)
        {
            DEBUG_MESSAGE("Processing nomination(s)")
        
            //Array of nominated map names.
            new Handle:nameArr = CreateArray(ByteCountToCells(MAP_LENGTH));
            
            //Array of nominated map weights (linked to the previous by index).
            new Handle:weightArr = CreateArray();
            
            new Handle:cycleArr = CreateArray();
            
            //Buffer to store the map name
            decl String:nameBuffer[MAP_LENGTH];
            decl String:nomGroup[MAP_LENGTH];
            
            //A nomination.
            new Handle:trie = INVALID_HANDLE;
            
            new Handle:nomKV;
            
            new index;
            
            //Add nomination to name and weight array for...
            //    ...each nomination in the nomination array for this category.
            new arraySize = GetArraySize(nominationsFromCat);
            for (new i = 0; i < arraySize; i++)
            {
                //Get the nomination at the current index.
                trie = GetArrayCell(nominationsFromCat, i);
                
                //Get the map name from the nomination.
                GetTrieString(trie, MAP_TRIE_MAP_KEY, nameBuffer, sizeof(nameBuffer));    
                
                GetTrieValue(trie, "mapcycle", nomKV);
                
                //Add the map to the map name array.
                PushArrayString(nameArr, nameBuffer);
                PushArrayCell(weightArr, GetMapWeight(nomKV, nameBuffer, cat));
                PushArrayCell(cycleArr, trie);
            }
            
            //Pick a random map from the nominations if...
            //    ...there are nominations to choose from.
            if (GetWeightedRandomSubKey(map, sizeof(map), weightArr, nameArr, index))
            {
                DEBUG_MESSAGE("Selecting random nomination")
                trie = GetArrayCell(cycleArr, index);
                GetTrieValue(trie, "mapcycle", nomKV);
                GetTrieString(trie, "nom_group", nomGroup, sizeof(nomGroup));
                DisableVoteInProgress(vM);
                DoMapChange(change_map_when, nomKV, map, nomGroup, stored_reason, map);
            }
            else //Otherwise, we select a map randomly from the category.
            {
                DEBUG_MESSAGE("Couldn't select a random nomination [you shouldn't ever see this...]")
                GetRandomMap(kv, map, sizeof(map));
                DisableVoteInProgress(vM);
                DoMapChange(change_map_when, stored_mapcycle, map, cat, stored_reason, map);
            }
            
            //Close the handles for the storage arrays.
            CloseHandle(nameArr);
            CloseHandle(weightArr);
            CloseHandle(cycleArr);
        }
        else //Otherwise, there are no nominations to worry about so we just pick a map randomly
             //from the winning category.
        {
            DEBUG_MESSAGE("No nominations, selecting a random map from the winning group")
            GetRandomMap(kv, map, sizeof(map)); //, stored_exmaps, stored_exgroups);
            DisableVoteInProgress(vM);
            DoMapChange(change_map_when, stored_mapcycle, map, cat, stored_reason, map);
            DEBUG_MESSAGE("Map selected was %s", map)
        }
        
        //We no longer need the adt_array to store nominations.
        CloseHandle(nominationsFromCat);
        
        //We no longer need the copy of the mapcycle.
        CloseHandle(kv);
        
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "End of Map Vote Group Won",
                map, cat,
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        LogUMCMessage(
            "MAPVOTE: Players voted for map group '%s' and the map '%s' was randomly selected.",
            cat, map
        );
    }
    
    decl String:stored_end_sound[PLATFORM_MAX_PATH];
    GetTrieString(vM, "stored_end_sound", stored_end_sound, sizeof(stored_end_sound));
    
    //Play the vote completed sound if...
    //  ...the vote completed sound is defined.
    if (strlen(stored_end_sound) > 0)
        EmitSoundToAll(stored_end_sound);
        
    DeleteVoteParams(vM);
}


//Handles the winner of an end-of-map tiered vote.
public Handle_TierVoteWinner(Handle:vM, const String:cat[], const String:disp[], Float:percentage)
{
    DEBUG_MESSAGE("Handling Tiered Endvote Winner \"%s\"", cat)
    
    new total_votes;
    GetTrieValue(vM, "total_votes", total_votes);
    
    //Print a message and extend the map if...
    //    ...the server voted to extend the map.
    if (StrEqual(cat, EXTEND_MAP_OPTION))
    {
        DEBUG_MESSAGE("Endvote - Extending the map.")
    
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "Map Extended",
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        LogUMCMessage("MAPVOTE: Players voted to extend the map.");
        DeleteVoteParams(vM);
        ExtendMap(vM);
    }
    else if (StrEqual(cat, DONT_CHANGE_OPTION))
    {
        PrintToChatAll(
            "\x03[UMC]\x01 %t %t (%t)",
            "End of Map Vote Over",
            "Map Unchanged",
            "Vote Win Percentage",
                percentage,
                total_votes
        );
        
        LogUMCMessage("MAPVOTE: Players voted to stay on the map (Don't Change).");
        DeleteVoteParams(vM);
        VoteFailed(vM);
    }
    else //Otherwise, we set up the second stage of the tiered vote
    {
        DEBUG_MESSAGE("Setting up second part of Tiered V.")
        LogUMCMessage("MAPVOTE (Tiered): Players voted for map group '%s'", cat);
        
        new vMapCount;
        
        DEBUG_MESSAGE("Counting the number of nominations from the winning group.")
        //Get the number of valid nominations from the group
        new Handle:tempNoms = GetCatNominations(cat);
        
        new bool:stored_exclude;
        GetTrieValue(vM, "stored_exclude", stored_exclude);
        
        if (stored_exclude)
        {
            new Handle:catNoms = FilterNominationsArray(tempNoms);
            vMapCount = GetArraySize(catNoms);        
            CloseHandle(catNoms);
        }
        else
        {
            vMapCount = GetArraySize(tempNoms);
        }
        CloseHandle(tempNoms);
        
        new Handle:stored_kv;
        GetTrieValue(vM, "stored_kv", stored_kv);
        
        //Jump to the map group
        KvRewind(stored_kv);
        new Handle:kv = CreateKeyValues("umc_rotation");
        KvCopySubkeys(stored_kv, kv);
        
        DEBUG_MESSAGE("Valid Maps: %i", vMapCount)
        
        if (!KvJumpToKey(kv, cat))
        {
            LogError("KV Error: Unable to find map group \"%s\". Try removing any punctuation from the group's name.", cat);
            CloseHandle(kv);
            return;
        }
        
        if (stored_exclude)
        {
            new Handle:stored_mapcycle;
            GetTrieValue(vM, "stored_mapcycle", stored_mapcycle);
            FilterMapGroup(kv, stored_mapcycle);
        }
            
        DEBUG_MESSAGE("Counting the number of available maps from the winning group.")
        //Get the number of valid maps from the group
        vMapCount += CountMapsFromGroup(kv);
        
        DEBUG_MESSAGE("Valid Maps: %i", vMapCount)
        
        //Return to the root.
        KvGoBack(kv);
        
        DEBUG_MESSAGE("Determining if we need to run a second vote.")
        //Just parse the results as a normal map group vote if...
        //  ...the total number of valid maps is 1.
        if (vMapCount <= 1)
        {
            DEBUG_MESSAGE("Only 1 map available, no vote required.")
            LogUMCMessage(
                "MAPVOTE (Tiered): Only one valid map found in group. Handling results as a Map Group Vote."
            );
            CloseHandle(kv);
            Handle_CatVoteWinner(vM, cat, disp, percentage);
            return;
        }
    
        DEBUG_MESSAGE("Starting countdown timer for the second vote.")
        
        //Setup timer to delay the next vote for a few seconds.
        SetTrieValue(vM, "tiered_delay", 4);
        
        //Display the first message
        DisplayTierMessage(5);
        
        new Handle:tieredKV = MakeSecondTieredCatExclusion(kv, cat);
        
#if UMC_DEBUG
        DEBUG_MESSAGE("Group for Tiered Vote:")
        LogKv(tieredKV);
#endif
        
        CloseHandle(kv);
        
        new Handle:pack = CreateDataPack();
        
        //Setup timer to delay the next vote for a few seconds.
        CreateDataTimer(
            1.0,
            Handle_TieredVoteTimer,
            pack,
            TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT
        );
        WritePackCell(pack, _:vM);
        WritePackCell(pack, _:tieredKV);
    }
    
    DEBUG_MESSAGE("Playing vote complete sound.")
    
    decl String:stored_end_sound[PLATFORM_MAX_PATH];
    GetTrieString(vM, "stored_end_sound", stored_end_sound, sizeof(stored_end_sound));
    
    //Play the vote completed sound if...
    //  ...the vote completed sound is defined.
    if (strlen(stored_end_sound) > 0)
        EmitSoundToAll(stored_end_sound);
        
    DEBUG_MESSAGE("Finished handling Tiered winner.")
}


//Called when the timer for the tiered end-of-map vote triggers.
public Action:Handle_TieredVoteTimer(Handle:timer, Handle:pack)
{
    ResetPack(pack);
    new Handle:vM = Handle:ReadPackCell(pack);
    
    new bool:vote_inprogress;
    GetTrieValue(vM, "in_progress", vote_inprogress);

    if (!vote_inprogress)
    {
        VoteFailed(vM);
        DeleteVoteParams(vM);
        return Plugin_Stop;
    }
    
    new tiered_delay;
    GetTrieValue(vM, "tiered_delay", tiered_delay);
    
    DisplayTierMessage(tiered_delay);
    
    if (tiered_delay > 0)
    {
        if (strlen(countdown_sound) > 0)
            EmitSoundToAll(countdown_sound);

        SetTrieValue(vM, "tiered_delay", tiered_delay - 1);
        return Plugin_Continue;
    }
        
    if (IsVoteInProgress())
    {
        return Plugin_Continue;
    }
    
    new Handle:tieredKV = Handle:ReadPackCell(pack);
    
    //Log a message
    LogUMCMessage("MAPVOTE (Tiered): Starting second stage of tiered vote.");
    
    new Handle:stored_mapcycle, bool:stored_scramble, bool:stored_ignoredupes,
        bool:stored_strictnoms, bool:stored_exclude;
    GetTrieValue(vM, "stored_mapcycle", stored_mapcycle);
    GetTrieValue(vM, "stored_scramble", stored_scramble);
    GetTrieValue(vM, "stored_ignoredupes", stored_ignoredupes);
    GetTrieValue(vM, "stored_strictnoms", stored_strictnoms);
    GetTrieValue(vM, "stored_exclude", stored_exclude);

    //Initialize the menu.
    new Handle:options = CreateArray();

    new UMC_BuildOptionsError:error = BuildMapVoteItems(
        vM, options, stored_mapcycle,
        tieredKV, stored_scramble, false,
        false, stored_ignoredupes,
        stored_strictnoms, true, stored_exclude);
    
    if (error == BuildOptionsError_Success)
    {
        //Play the vote start sound if...
        //  ...the vote start sound is defined.
        /* if (strlen(stored_start_sound) > 0)
            EmitSoundToAll(stored_start_sound);
        
        //Display the menu.
        VoteMenuToAllWithFlags(menu, stored_votetime, stored_adminflags); */
        
        decl String:stored_start_sound[PLATFORM_MAX_PATH]; //, String:adminFlags[64];
        GetTrieString(vM, "stored_start_sound", stored_start_sound, sizeof(stored_start_sound));
        //GetTrieString(vM, "stored_adminflags", adminFlags, sizeof(adminFlags));
        
        new users[MAXPLAYERS+1];
        new numClients;
        new clients[MAXPLAYERS+1];
        GetTrieArray2(vM, "stored_users", users, sizeof(users), numClients);
        ConvertUserIDsToClients(users, clients, numClients);
        
        SetTrieValue(vM, "stored_type", VoteType_Map);
        
        new stored_votetime;
        GetTrieValue(vM, "stored_votetime", stored_votetime);
        
        //vote_active = true;
        new bool:vote_active = PerformVote(vM, VoteType_Map, options, stored_votetime, clients,
                                           numClients, stored_start_sound);
        
        FreeOptions(options);
        
        if (!vote_active)
        {
            DeleteVoteParams(vM);
            ClearVoteArrays(vM);
            VoteFailed(vM);
        }
    }
    else
    {
        LogError("MAPVOTE (Tiered): Unable to create second stage vote menu. Vote aborted.");
        VoteFailed(vM);
        DeleteVoteParams(vM);
    }
        
    return Plugin_Stop;
}


//Extend the current map.
ExtendMap(Handle:vM)
{
    DisableVoteInProgress(vM);
    //vote_completed = false;
    
    new Float:extend_timestep;
    new extend_roundstep;
    new extend_fragstep;
    GetTrieValue(vM, "extend_timestep", extend_timestep);
    GetTrieValue(vM, "extend_roundstep", extend_roundstep);
    GetTrieValue(vM, "extend_fragstep", extend_fragstep);
    
    if (cvar_maxrounds != INVALID_HANDLE && GetConVarInt(cvar_maxrounds) > 0)
        SetConVarInt(cvar_maxrounds, GetConVarInt(cvar_maxrounds) + extend_roundstep);
    if (cvar_winlimit != INVALID_HANDLE && GetConVarInt(cvar_winlimit) > 0)
        SetConVarInt(cvar_winlimit, GetConVarInt(cvar_winlimit) + extend_roundstep);
    if (cvar_fraglimit != INVALID_HANDLE && GetConVarInt(cvar_fraglimit) > 0)
        SetConVarInt(cvar_fraglimit, GetConVarInt(cvar_fraglimit) + extend_fragstep);
    
    //Extend the time limit.
    ExtendMapTimeLimit(RoundToNearest(extend_timestep * 60));
    
    //Execute the extend command
    decl String:command[64];
    GetConVarString(cvar_extend_command, command, sizeof(command));
    if (strlen(command) > 0)
        ServerCommand(command);
    
    //Call the extend forward.
    Call_StartForward(extend_forward);
    Call_Finish();
    
    //Log some stuff.
    LogUMCMessage("MAPVOTE: Map extended.");
}


//Called when the vote has failed.
VoteFailed(Handle:vM)
{    
    DisableVoteInProgress(vM);

    Call_StartForward(failure_forward);
    Call_Finish();
}


//Sets the next map and when to change to it.
DoMapChange(UMC_ChangeMapTime:when, Handle:kv, const String:map[], const String:group[],
            const String:reason[], const String:display[]="")
{   
    //Set the next map group
    strcopy(next_cat, sizeof(next_cat), group);
                        
    //Set the next map in SM
    LogUMCMessage("Setting nextmap to: %s", map);
    SetNextMap(map);
    
    //Set the built in nextmap cvar
    //if (cvar_nextmap != INVALID_HANDLE)
    //    SetConVarString(cvar_nextmap, map);
    
    //GE:S Fix
    if (cvar_nextlevel != INVALID_HANDLE)
        SetConVarString(cvar_nextlevel, map);

    //Call UMC forward for next map being set
    new Handle:new_kv = INVALID_HANDLE;
    if (kv != INVALID_HANDLE)
    {
        new_kv = CreateKeyValues("umc_rotation");
        KvCopySubkeys(kv, new_kv);
    }
    else
        LogUMCMessage("Mapcycle handle is invalid. Map change reason: %s", reason);
    
    Call_StartForward(nextmap_forward);
    Call_PushCell(new_kv);
    Call_PushString(map);
    Call_PushString(group);
    Call_PushString(display);
    Call_Finish();

    if (new_kv != INVALID_HANDLE)
        CloseHandle(new_kv);

    //Perform the map change setup
    switch (when)
    {
        case ChangeMapTime_Now: //We change the map in 5 seconds.
        {
            decl String:game[20];
            GetGameFolderName(game, sizeof(game));
            if (!StrEqual(game, "gesource", false))
            {
                //Routine by Tsunami to end the map
                new iGameEnd = FindEntityByClassname(-1, "game_end");
                if (iGameEnd == -1 && (iGameEnd = CreateEntityByName("game_end")) == -1)
                {
                    ForceChangeInFive(map, reason);
                } 
                else 
                {     
                    AcceptEntityInput(iGameEnd, "EndGame");
                }
            }
            else
                ForceChangeInFive(map, reason);
        }
        case ChangeMapTime_RoundEnd: //We change the map at the end of the round.
        {
            LogUMCMessage("%s: Map will change to '%s' at the end of the round.", reason, map);
            
            change_map_round = true;
            
            //Print a message.
            PrintToChatAll("\x03[UMC]\x01 %t", "Map Change at Round End");
        }
    }
}


//Deletes the stored parameters for the vote.
DeleteVoteParams(Handle:vM)
{
    DEBUG_MESSAGE("Deleting Vote Parameters")
    
    new Handle:stored_kv, Handle:stored_mapcycle;
    GetTrieValue(vM, "stored_kv", stored_kv);
    GetTrieValue(vM, "stored_mapcycle", stored_mapcycle);
    
    CloseHandle(stored_kv);
    CloseHandle(stored_mapcycle);
    
    SetTrieValue(vM, "stored_kv", INVALID_HANDLE);
    SetTrieValue(vM, "stored_mapcycle", INVALID_HANDLE);
}


//************************************************************************************************//
//                                        VALIDITY TESTING                                        //
//************************************************************************************************//

//Checks to see if the server has the required number of players for the given map, and is in the
//required time range.
//    kv:       a mapcycle whose traversal stack is currently at the level of the map's category.
//    map:      the map to check
bool:IsValidMapFromCat(Handle:kv, Handle:mapcycle, const String:map[], bool:isNom=false,
                       bool:forMapChange=true)
{   
    decl String:catName[MAP_LENGTH];
    KvGetSectionName(kv, catName, sizeof(catName));
    
    //Return that the map is not valid if...
    //    ...the map doesn't exist in the category.
    if (!KvJumpToKey(kv, map))
    {
        DEBUG_MESSAGE("Could not find map '%s' in group '%s'", map, catName)
        return false;
    }
    
    //Determine if the map is valid, store the answer.
    new bool:result = IsValidMap(kv, mapcycle, catName, isNom, forMapChange);
    
    //Rewind back to the category.
    KvGoBack(kv);
    
    //Return the result.
    return result;
}


//Determines if the server has the required number of players for the given map.
//    kv:       a mapcycle whose traversal stack is currently at the level of the map.
bool:IsValidMap(Handle:kv, Handle:mapcycle, const String:groupName[], bool:isNom=false,
                bool:forMapChange=true)
{
    decl String:mapName[MAP_LENGTH];
    KvGetSectionName(kv, mapName, sizeof(mapName));
    
    if (!IsMapValid(mapName))
    {
        LogUMCMessage("WARNING: Map \"%s\" does not exist on the server. (Group: \"%s\")",
            mapName, groupName);
        return false;
    }
    
    new Action:result;
    
    new Handle:new_kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(mapcycle, new_kv);
    
    Call_StartForward(exclude_forward);
    Call_PushCell(new_kv);
    Call_PushString(mapName);
    Call_PushString(groupName);
    Call_PushCell(isNom);
    Call_PushCell(forMapChange);
    Call_Finish(result);
    
    CloseHandle(new_kv);
    
    new bool:re = result == Plugin_Continue;
    
    return re;
}


//Determines if the server has the required number of players for the given category and the
//required time.
//    kv: a mapcycle whose traversal stack is currently at the level of the category.
bool:IsValidCat(Handle:kv, Handle:mapcycle, bool:isNom=false, bool:forMapChange=true)
{
    //Get the name of the cat.
    decl String:catName[MAP_LENGTH];
    KvGetSectionName(kv, catName, sizeof(catName));
    
    //Return that the map is invalid if...
    //    ...there are no maps to check.
    if (!KvGotoFirstSubKey(kv))
        return false;
    
    //Check to see if the server's player count satisfies the min/max conditions for a map in the
    //category.
    do
    {
        //Return to the category level of the mapcycle and return true if...
        //    ...a map was found to be satisfied by the server's player count.
        if (IsValidMap(kv, mapcycle, catName, isNom, forMapChange))
        {
            KvGoBack(kv);
            return true;
        }
    }
    while (KvGotoNextKey(kv)); //Goto the next map in the category.

    //Return to the category level.
    KvGoBack(kv);
    
    //No maps in the category can be played with the current amount of players on the server.
    return false;
}


//Counts the number of maps in the given group.
CountMapsFromGroup(Handle:kv)
{
    new result = 0;
    if (!KvGotoFirstSubKey(kv))
        return result;
    
    do
    {
        result++;
    }
    while (KvGotoNextKey(kv));
    
    KvGoBack(kv);
    
    return result;
}


//Calculates the weight of a map by running it through all of the weight modifiers.
Float:GetMapWeight(Handle:mapcycle, const String:map[], const String:group[])
{
    //Get the starting weight
    current_weight = 1.0;
    
    new Handle:kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(mapcycle, kv);
    
    reweight_active = true;
    
    Call_StartForward(reweight_forward);
    Call_PushCell(kv);
    Call_PushString(map);
    Call_PushString(group);
    Call_Finish();
    
    reweight_active = false;
    
    CloseHandle(kv);
    
    //And return our calculated weight.
    return (current_weight >= 0.0) ? current_weight : 0.0;
}


//Calculates the weight of a map group
Float:GetMapGroupWeight(Handle:originalMapcycle, const String:group[])
{
    current_weight = 1.0;
    
    new Handle:kv = CreateKeyValues("umc_rotation");
    KvCopySubkeys(originalMapcycle, kv);
    
    reweight_active = true;
    
    Call_StartForward(reweight_group_forward);
    Call_PushCell(kv);
    Call_PushString(group);
    Call_Finish();
    
    reweight_active = false;
    
    CloseHandle(kv);
    
    return (current_weight >= 0.0) ? current_weight : 0.0;
}


//Calculates weights for a mapcycle
WeightMapcycle(Handle:kv, Handle:originalMapcycle)
{
    if (!KvGotoFirstSubKey(kv))
        return;
        
    decl String:group[MAP_LENGTH];
    do
    {
        KvGetSectionName(kv, group, sizeof(group));
        
        KvSetFloat(kv, WEIGHT_KEY, GetMapGroupWeight(originalMapcycle, group));
    
        WeightMapGroup(kv, originalMapcycle);
    }
    while (KvGotoNextKey(kv));
    
    KvGoBack(kv);
}


//Calculates weights for a map group.
WeightMapGroup(Handle:kv, Handle:originalMapcycle)
{
    decl String:map[MAP_LENGTH], String:group[MAP_LENGTH];
    KvGetSectionName(kv, group, sizeof(group));
    
    if (!KvGotoFirstSubKey(kv))
        return;
    
    do
    {
        KvGetSectionName(kv, map, sizeof(map));
        
        KvSetFloat(kv, WEIGHT_KEY, GetMapWeight(originalMapcycle, map, group));
    }
    while (KvGotoNextKey(kv));
    
    KvGoBack(kv);
}


//Returns the weight of a given map or map group
Float:GetWeight(Handle:kv)
{
    return KvGetFloat(kv, WEIGHT_KEY, 1.0);
}


//Filters a mapcycle with all invalid entries filtered out.
FilterMapcycle(Handle:kv, Handle:originalMapcycle, bool:isNom=false, bool:forMapChange=true,
              bool:deleteEmpty=true)
{
    //Do nothing if there are no map groups.
    if (!KvGotoFirstSubKey(kv))
        return;
        
    DEBUG_MESSAGE("Starting mapcycle filtering.")
    decl String:group[MAP_LENGTH];
    for ( ; ; )
    {
        //Filter all the maps.
        FilterMapGroup(kv, originalMapcycle, isNom, forMapChange);
        
        //Delete the group if there are no valid maps in it.
        if (deleteEmpty) 
        {
            if (!KvGotoFirstSubKey(kv))
            {
                KvGetSectionName(kv, group, sizeof(group));
        
                DEBUG_MESSAGE("Removing empty group \"%s\".", group)
                if (KvDeleteThis(kv) == -1)
                {
                    DEBUG_MESSAGE("Mapcycle filtering completed.")
                    return;
                }
                else
                    continue;
            }
            
            KvGoBack(kv);
        }
                
        if (!KvGotoNextKey(kv))
            break;
    }
    
    //Return to the root.
    KvGoBack(kv);
    
    DEBUG_MESSAGE("Mapcycle filtering completed.")
}


//Filters the kv at the level of the map group.
FilterMapGroup(Handle:kv, Handle:mapcycle, bool:isNom=false, bool:forMapChange=true)
{
    decl String:group[MAP_LENGTH];
    KvGetSectionName(kv, group, sizeof(group));
    
    if (!KvGotoFirstSubKey(kv))
        return;
    
    DEBUG_MESSAGE("Starting filtering of map group \"%s\".", group)
    
    decl String:mapName[MAP_LENGTH];
    for ( ; ; )
    {
        if (!IsValidMap(kv, mapcycle, group, isNom, forMapChange))
        {
            KvGetSectionName(kv, mapName, sizeof(mapName));
            DEBUG_MESSAGE("Removing invalid map \"%s\" from group \"%s\".", mapName, group)
            if (KvDeleteThis(kv) == -1)
            {
                DEBUG_MESSAGE("Map Group filtering completed for group \"%s\".", group)
                return;
            }
        }
        else
        {
            if (!KvGotoNextKey(kv))
                break;
        }
    }
    
    KvGoBack(kv);
    
    DEBUG_MESSAGE("Map Group filtering completed for group \"%s\".", group)
}


//************************************************************************************************//
//                                           NOMINATIONS                                          //
//************************************************************************************************//

//Filters an array of nominations so that only valid maps remain.
Handle:FilterNominationsArray(Handle:nominations, bool:forMapChange=true)
{
    new Handle:result = CreateArray();

    new size = GetArraySize(nominations);
    new Handle:nom;
    decl String:gBuffer[MAP_LENGTH], String:mBuffer[MAP_LENGTH];
    new Handle:mapcycle;
    new Handle:kv;
    for (new i = 0; i < size; i++)
    {
        nom = GetArrayCell(nominations, i);
        GetTrieString(nom, MAP_TRIE_MAP_KEY, mBuffer, sizeof(mBuffer));
        GetTrieString(nom, MAP_TRIE_GROUP_KEY, gBuffer, sizeof(gBuffer));
        GetTrieValue(nom, "mapcycle", mapcycle);
        
        kv = CreateKeyValues("umc_rotation");
        KvCopySubkeys(mapcycle, kv);
        
        if (!KvJumpToKey(kv, gBuffer))
        {
            DEBUG_MESSAGE("Could not find group '%s' in nomination mapcycle.", gBuffer)
            continue;
        }
        
        if (IsValidMapFromCat(kv, mapcycle, mBuffer, .isNom=true, .forMapChange=forMapChange))
            PushArrayCell(result, nom);
        
        CloseHandle(kv);
    }
    
    return result;
}


//Nominated a map and group
bool:InternalNominateMap(Handle:kv, const String:map[], const String:group[], client,
                         const String:nomGroup[])
{
    DEBUG_MESSAGE("Adding map '%s' from group '%s' to nominations.", map, group)
    if (FindNominationIndex(map, group) != -1)
    {
        DEBUG_MESSAGE("Map/Group is already in nominations.")
        return false;
    }
    
    DEBUG_MESSAGE("*MEMLEAKTEST* Creating nomination trie (InternalNominateMap) [1]")
    //Create the nomination trie.
    new Handle:nomination = CreateMapTrie(map, StrEqual(nomGroup, INVALID_GROUP) ? group : nomGroup);
    SetTrieValue(nomination, "client", client); //Add the client
    SetTrieValue(nomination, "mapcycle", kv); //Add the mapcycle
    SetTrieString(nomination, "nom_group", group);
    
    //Get and add the nominated map's weight.
    //SetTrieValue(nomination, "weight", GetArrayCell(nomination_weights[client], param2));
    
    DEBUG_MESSAGE("Detecting client's old nomination")
    //Remove the client's old nomination, if it exists.
    new index = FindClientNomination(client);
    if (index != -1)
    {
        DEBUG_MESSAGE("Nomination found for client")
        new Handle:oldNom = GetArrayCell(nominations_arr, index);
        
        decl String:oldName[MAP_LENGTH];
        GetTrieString(oldNom, MAP_TRIE_MAP_KEY, oldName, sizeof(oldName));
        
        Call_StartForward(nomination_reset_forward);
        Call_PushString(oldName);
        Call_PushCell(client);
        Call_Finish();
        
        DEBUG_MESSAGE("Removing old nomination")
        new Handle:nomKV;
        GetTrieValue(oldNom, "mapcycle", nomKV);
        CloseHandle(nomKV);
        CloseHandle(oldNom);
        RemoveFromArray(nominations_arr, index);
    }
    
    DEBUG_MESSAGE("*MEMLEAKTEST* Adding new nomination made at [1] to nomination array")
    //Add the nomination to the nomination array.
    PushArrayCell(nominations_arr, nomination);
    
    return true;
}


//Returns the index of the given client in the nomination pool. -1 is returned if the client isn't
//in the pool.
FindClientNomination(client)
{
    new buffer;
    new arraySize = GetArraySize(nominations_arr);
    for (new i = 0; i < arraySize; i++)
    {
        GetTrieValue(GetArrayCell(nominations_arr, i), "client", buffer);
        if (buffer == client)
            return i;
    }
    return -1;
}


//Utility function to find the index of a map in the nomination pool.
FindNominationIndex(const String:map[], const String:group[])
{
    decl String:mName[MAP_LENGTH];
    decl String:gName[MAP_LENGTH];
    new Handle:nom = INVALID_HANDLE;
    new arraySize = GetArraySize(nominations_arr);
    for (new i = 0; i < arraySize; i++)
    {
        nom = GetArrayCell(nominations_arr, i);
        GetTrieString(nom, MAP_TRIE_MAP_KEY, mName, sizeof(mName));
        GetTrieString(nom, MAP_TRIE_GROUP_KEY, gName, sizeof(gName));
        if (StrEqual(mName, map, false) && StrEqual(gName, group, false))
            return i;
    }
    return -1;
}


//Utility function to get all nominations from a group.
Handle:GetCatNominations(const String:cat[])
{
    new Handle:arr1 = FilterNominations(MAP_TRIE_GROUP_KEY, cat);
    new Handle:arr2 = FilterNominations(MAP_TRIE_GROUP_KEY, INVALID_GROUP);
    ArrayAppend(arr1, arr2);
    CloseHandle(arr2);
    return arr1;
}


//Utility function to filter out nominations whose value for the given key matches the given value.
Handle:FilterNominations(const String:key[], const String:value[])
{
    new Handle:result = CreateArray();
    new Handle:buffer;
    decl String:temp[255];
    new arraySize = GetArraySize(nominations_arr);
    for (new i = 0; i < arraySize; i++)
    {
        buffer = GetArrayCell(nominations_arr, i);
        GetTrieString(GetArrayCell(nominations_arr, i), key, temp, sizeof(temp));
        if (StrEqual(temp, value, false))
            PushArrayCell(result, buffer);
    }
    return result;
}


//Clears all stored nominations.
ClearNominations()
{
    new size = GetArraySize(nominations_arr);
    new Handle:nomination = INVALID_HANDLE;
    new owner;
    decl String:map[MAP_LENGTH];
    for (new i = 0; i < size; i++)
    {
        nomination = GetArrayCell(nominations_arr, i);
        GetTrieString(nomination, MAP_TRIE_MAP_KEY, map, sizeof(map));
        GetTrieValue(nomination, "client", owner);

        Call_StartForward(nomination_reset_forward);
        Call_PushString(map);
        Call_PushCell(owner);
        Call_Finish();
        
        new Handle:nomKV;
        GetTrieValue(nomination, "mapcycle", nomKV);
        CloseHandle(nomKV);
        CloseHandle(nomination);
    }
    ClearArray(nominations_arr);
}


//************************************************************************************************//
//                                         RANDOM NEXTMAP                                         //
//************************************************************************************************//

//bool:GetRandomMapFromCycle(Handle:kv, const String:group[], String:buffer[], size, String:gBuffer[],
//                           gSize, Handle:exMaps, Handle:exGroups, numEGroups, bool:isNom=false,
//                           bool:forMapChange=true)
bool:GetRandomMapFromCycle(Handle:kv, const String:group[], String:buffer[], size, String:gBuffer[],
                           gSize)
{
    //Buffer to store the name of the category we will be looking for a map in.
    decl String:gName[MAP_LENGTH];
    
#if UMC_DEBUG
    if (!StrEqual(group, INVALID_GROUP, false))
    {
        DEBUG_MESSAGE("Searching for random map in group %s.", group)
    }
#endif
    
    strcopy(gName, sizeof(gName), group);

#if UMC_DEBUG
    DEBUG_MESSAGE("group: %s, gName: %s", group, gName)
    new bool:p1 = StrEqual(gName, INVALID_GROUP, false);
    new bool:p2 = p1 || !KvJumpToKey(kv, gName);
    if (p1 || p2)
    {
        DEBUG_MESSAGE("Picking random group. P1: %i, P2: %i", p1, p2)
        LogKv(kv);
#else
    if (StrEqual(gName, INVALID_GROUP, false) || !KvJumpToKey(kv, gName))
    {
#endif
        if (!GetRandomCat(kv, gName, sizeof(gName)))
        {
            LogError(
                "RANDOM MAP: Cannot pick a random map, no available map groups found in rotation."
            );
            return false;
        }
        KvJumpToKey(kv, gName);
    }
    
    //Buffer to store the name of the new map.
    decl String:mapName[MAP_LENGTH];
    
    //Log an error and fail if...
    //    ...there were no maps found in the category.
    if (!GetRandomMap(kv, mapName, sizeof(mapName)))//, exMaps, exGroups, isNom, forMapChange))
    {
        LogError(
            "RANDOM MAP: Cannot pick a random map, no available maps found. Parent Group: %s",
            gName
        );
        return false;
    }

    KvGoBack(kv);
    
    //Copy results into the buffers.
    strcopy(buffer, size, mapName);
    strcopy(gBuffer, gSize, gName);
    
    //Return success!
    return true;
}


//Selects a random category based off of the supplied weights for the categories.
//    kv:       a mapcycle whose traversal stack is currently at the root level.
//    buffer:      a string to store the selected category in.
//    key:      the key containing the weight information (most likely 'group_weight')
//    excluded: adt_array of excluded maps
//bool:GetRandomCat(Handle:kv, String:buffer[], size, Handle:excludedCats, numExcludedCats,
//                  Handle:excluded, bool:isNom=false, bool:forMapChange=true)
bool:GetRandomCat(Handle:kv, String:buffer[], size)
{
    DEBUG_MESSAGE("Getting a random group")

    //Fail if...
    //    ...there are no categories in the mapcycle.
    if (!KvGotoFirstSubKey(kv))
        return false;

    new index = 0; //counter of categories in the random pool
    new Handle:nameArr = CreateArray(ByteCountToCells(MAP_LENGTH)); //Array to store possible category names.
    new Handle:weightArr = CreateArray();  //Array to store possible category weights.
    
    DEBUG_MESSAGE("Starting traversal")
    //Add a category to the random pool.
    do
    {
        decl String:temp[MAP_LENGTH]; //Buffer to store the name of the category.
        
        //Get the name of the category.
        KvGetSectionName(kv, temp, sizeof(temp));
        
        DEBUG_MESSAGE("Group %s added to random pool.", temp)
        
        //Add the category to the random pool.
        PushArrayCell(weightArr, GetWeight(kv));
        PushArrayString(nameArr, temp);
        
        //One more category in the pool.
        index++;
    }
    while (KvGotoNextKey(kv)); //Do this for each category.

    //Return to the root level.
    KvGoBack(kv);
    
    DEBUG_MESSAGE("Finished traversal.")
    
    //Fail if...
    //    ...no categories are selectable.
    if (index == 0)
    {
        CloseHandle(nameArr);
        CloseHandle(weightArr);
        return false;
    }
    
    DEBUG_MESSAGE("Selecting a random group.")

    //Use weights to randomly select a category from the pool.
    new bool:result = GetWeightedRandomSubKey(buffer, size, weightArr, nameArr);
    
    //Close the pool.
    CloseHandle(nameArr);
    CloseHandle(weightArr);
    
#if UMC_DEBUG
    if (result)
        DEBUG_MESSAGE("Selected group %s", buffer)
#endif
    
    //Booyah!
    return result;
}


