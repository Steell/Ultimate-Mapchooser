/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                               Ultimate Mapchooser - Map Commands                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <umc-core>
#include <umc_utils>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-mapcommands.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-mapcommands.txt"
#endif

#define REQUIRE_PLUGIN

public Plugin:myinfo =
{
    name = "[UMC] Map Commands",
    author = "Steell",
    description = "Allows users to specify commands to be executed for maps and map groups.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

#define COMMAND_KEY     "command"
#define PRE_COMMAND_KEY "pre-command"

//Changelog:
/*
*/

new String:map_command[256];
new String:group_command[256];


#if AUTOUPDATE_ENABLE
//
public OnPluginStart()
{
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}


//Called when a new API library is loaded. Used to register UMC auto-updating.
public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}
#endif


//Execute commands after all configs have been executed.
public OnConfigsExecuted()
{
    decl String:map[MAP_LENGTH], String:group[MAP_LENGTH];
    GetCurrentMap(map, sizeof(map));
    UMC_GetCurrentMapGroup(group, sizeof(group));

    if (strlen(group_command) > 0)
    {
        LogUMCMessage("SETUP: Executing map group command: '%s'", group_command);
        ServerCommand(group_command);
        strcopy(group_command, sizeof(group_command), "");
    }
    
    if (strlen(map_command) > 0)
    {
        LogUMCMessage("SETUP: Executing map command: '%s'", map_command);
        ServerCommand(map_command);
        strcopy(map_command, sizeof(map_command), "");
    }
}


//Called when UMC has set the next map.
public UMC_OnNextmapSet(Handle:kv, const String:map[], const String:group[], const String:display[])
{
    if (kv == INVALID_HANDLE)
        return;
    
    decl String:gPreCommand[256], String:mPreCommand[256];

    KvRewind(kv);
    KvJumpToKey(kv, group);
    
    KvGetString(kv, COMMAND_KEY, group_command, sizeof(group_command), "");
    KvGetString(kv, PRE_COMMAND_KEY, gPreCommand, sizeof(gPreCommand), "");
    
    if (strlen(gPreCommand) > 0)
    {
        LogUMCMessage("SETUP: Executing map group pre-command: '%s'", gPreCommand);
        ServerCommand(gPreCommand);
    }
        
    KvJumpToKey(kv, map);
    
    KvGetString(kv, COMMAND_KEY, map_command, sizeof(map_command), "");
    KvGetString(kv, PRE_COMMAND_KEY, mPreCommand, sizeof(mPreCommand), "");
    
    if (strlen(mPreCommand) > 0)
    {
        LogUMCMessage("SETUP: Executing map pre-command: '%s'", mPreCommand);
        ServerCommand(mPreCommand);
    }
        
    KvRewind(kv);
}