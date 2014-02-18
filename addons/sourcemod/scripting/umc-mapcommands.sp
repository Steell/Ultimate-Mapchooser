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

public Plugin:myinfo =
{
    name = "[UMC] Map Commands",
    author = "Steell",
    description = "Allows users to specify commands to be executed for maps and map groups.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

#define COMMAND_KEY          "command"
#define PRE_COMMAND_KEY      "pre-command"
#define POSTVOTE_COMMAND_KEY "postvote-command"

//Changelog:
/*
*/

new String:map_command[256];
new String:group_command[256];

new String:map_precommand[256];
new String:group_precommand[256];


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
    if (strlen(group_command) == 0 || strlen(map_command) == 0)
    {
        new Handle:kv = GetKvFromFile("umc_mapcycle.txt", "umc_mapcycle");
        decl String:CurrentMapGroup[64], String:CurrentMap[64];
        
        GetCurrentMap(CurrentMap, sizeof(CurrentMap));
        KvFindGroupOfMap(kv, CurrentMap, CurrentMapGroup, sizeof(CurrentMapGroup));
        
        if (KvJumpToKey(kv, CurrentMapGroup))
        {    
        	if (strlen(group_command) == 0)
                KvGetString(kv, COMMAND_KEY, group_command, sizeof(group_command), "");
        
        	if (KvJumpToKey(kv, CurrentMap) && strlen(map_command) == 0)
                KvGetString(kv, COMMAND_KEY, map_command, sizeof(map_command), "");
        }
        
        CloseHandle( kv );
    }
    
    DEBUG_MESSAGE("Executing MapCommands OnConfigsExecuted")
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


//Execute pre-commands when map ends
public OnMapEnd()
{
    DEBUG_MESSAGE("Executing MapCommands OnMapEnd")
    if (strlen(group_precommand) > 0)
    {
        LogUMCMessage("SETUP: Executing map group pre-command: '%s'", group_precommand);
        ServerCommand(group_precommand);
        strcopy(group_precommand, sizeof(group_precommand), "");
    }
    
    if (strlen(map_precommand) > 0)
    {
        LogUMCMessage("SETUP: Executing map pre-command: '%s'", map_precommand);
        ServerCommand(map_precommand);
        strcopy(map_precommand, sizeof(map_precommand), "");
    }
}


//Called when UMC has set the next map.
public UMC_OnNextmapSet(Handle:kv, const String:map[], const String:group[], const String:display[])
{
    if (kv == INVALID_HANDLE)
        return;
    
    decl String:gPVCommand[256], String:mPVCommand[256];

    KvRewind(kv); //TODO: Remove
    if (KvJumpToKey(kv, group))
    {    
        KvGetString(kv, COMMAND_KEY, group_command, sizeof(group_command), "");
        KvGetString(kv, POSTVOTE_COMMAND_KEY, gPVCommand, sizeof(gPVCommand), "");
        KvGetString(kv, PRE_COMMAND_KEY, group_precommand, sizeof(group_precommand), "");
        
        if (strlen(gPVCommand) > 0)
        {
            LogUMCMessage("SETUP: Executing map group postvote-command: '%s'", gPVCommand);
            ServerCommand(gPVCommand);
        }
            
        if (KvJumpToKey(kv, map))
        {
            KvGetString(kv, COMMAND_KEY, map_command, sizeof(map_command), "");
            KvGetString(kv, POSTVOTE_COMMAND_KEY, mPVCommand, sizeof(mPVCommand), "");
            KvGetString(kv, PRE_COMMAND_KEY, map_precommand, sizeof(map_precommand), "");
            
            if (strlen(mPVCommand) > 0)
            {
                LogUMCMessage("SETUP: Executing map postvote-command: '%s'", mPVCommand);
                ServerCommand(mPVCommand);
            }
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
}
