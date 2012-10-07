/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                              Ultimate Mapchooser - Player Limits                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <umc-core>
#include <umc_utils>
#include <umc-playerlimits>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-playerlimits.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-playerlimits.txt"
#endif

public Plugin:myinfo =
{
    name = "[UMC] Player Limits",
    author = "Steell",
    description = "Allows users to specify player limits for maps.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

new Handle:cvar_nom_ignore = INVALID_HANDLE;
new Handle:cvar_display_ignore = INVALID_HANDLE;

public OnPluginStart()
{
    cvar_nom_ignore = CreateConVar(
        "sm_umc_playerlimits_nominations",
        "0",
        "Determines if nominations are exempt from being excluded due to Player Limits.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_display_ignore = CreateConVar(
        "sm_umc_playerlimits_display",
        "0",
        "Determines if maps being displayed are exempt from being excluded due to Player Limits.",
        0, true, 0.0, true, 1.0
    );
    
    AutoExecConfig(true, "umc-playerlimits");

#if AUTOUPDATE_ENABLE
    if (LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
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


//Called when UMC wants to know if this map is excluded
public Action:UMC_OnDetermineMapExclude(Handle:kv, const String:map[], const String:group[],
                                        bool:isNomination, bool:forMapChange)
{
    if (isNomination && GetConVarBool(cvar_nom_ignore))
    {
        DEBUG_MESSAGE("Skipping nominated map %s due to cvar.", map)
        return Plugin_Continue;
    }
        
    if (!forMapChange && GetConVarBool(cvar_display_ignore))
    {
        DEBUG_MESSAGE("Skipping displayed map %s due to cvar.", map)
        return Plugin_Continue;
    }

    if (kv == INVALID_HANDLE)
        return Plugin_Continue;
    
    new defaultMin, defaultMax;
    new min, max;
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        defaultMin = KvGetNum(kv, PLAYERLIMIT_KEY_GROUP_MIN, 0);
        defaultMax = KvGetNum(kv, PLAYERLIMIT_KEY_GROUP_MAX, MaxClients);
    
        if (KvJumpToKey(kv, map))
        {    
            min = KvGetNum(kv, PLAYERLIMIT_KEY_MAP_MIN, defaultMin);
            max = KvGetNum(kv, PLAYERLIMIT_KEY_MAP_MAX, defaultMax);
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
    
    DEBUG_MESSAGE("Map %s Player Limits -- Min: %i, Max: %i, Current: %i", map, min, max, GetRealClientCount())
    
    if (IsPlayerCountBetween(min, max))
    {
        DEBUG_MESSAGE("Not excluded.")
        return Plugin_Continue;
    }
    
    DEBUG_MESSAGE("Excluded")
    return Plugin_Stop;
}


//Display Template
public UMC_OnFormatTemplateString(String:template[], maxlen, Handle:kv, const String:map[], 
                                  const String:group[])
{
    new defaultMin, defaultMax;
    new min, max;
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        defaultMin = KvGetNum(kv, PLAYERLIMIT_KEY_GROUP_MIN, 0);
        defaultMax = KvGetNum(kv, PLAYERLIMIT_KEY_GROUP_MAX, MaxClients);
    
        if (KvJumpToKey(kv, map))
        {    
            min = KvGetNum(kv, PLAYERLIMIT_KEY_MAP_MIN, defaultMin);
            max = KvGetNum(kv, PLAYERLIMIT_KEY_MAP_MAX, defaultMax);
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
    
    decl String:minString[3], String:maxString[3];
    Format(minString, sizeof(minString), "%d", min);
    Format(maxString, sizeof(maxString), "%d", max);
    
    decl String:minSearch[12], String:maxSearch[12];
    Format(minSearch, sizeof(minSearch), "{%s}", PLAYERLIMIT_KEY_MAP_MIN);
    Format(maxSearch, sizeof(maxSearch), "{%s}", PLAYERLIMIT_KEY_MAP_MAX);
    
    ReplaceString(template, maxlen, minSearch, minString, false);
    ReplaceString(template, maxlen, maxSearch, maxString, false);
}