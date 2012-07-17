/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                               Ultimate Mapchooser - Time Limits                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <umc-core>
#include <umc_utils>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-timelimits.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-timelimits.txt"
#endif

#define REQUIRE_PLUGIN

public Plugin:myinfo =
{
    name = "[UMC] Time Limits",
    author = "Steell",
    description = "Allows users to specify time limits for maps.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

#define TIMELIMIT_KEY_MAP_MIN "min_time"
#define TIMELIMIT_KEY_MAP_MAX "max_time"
#define TIMELIMIT_KEY_GROUP_MIN "default_min_time"
#define TIMELIMIT_KEY_GROUP_MAX "default_max_time"

#define DEFAULT_MIN 0
#define DEFAULT_MAX 2359

new Handle:cvar_nom_ignore = INVALID_HANDLE;
new Handle:cvar_display_ignore = INVALID_HANDLE;

public OnPluginStart()
{
    cvar_nom_ignore = CreateConVar(
        "sm_umc_timelimits_ignorenominations",
        "0",
        "Determines if nominations are exempt from being excluded due to Time Limits.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_display_ignore = CreateConVar(
        "sm_umc_timelimits_ignoredisplay",
        "0",
        "Determines if maps being displayed are exempt from being excluded due to Time Limits.",
        0, true, 0.0, true, 1.0
    );
    
    AutoExecConfig(true, "umc-timelimits");

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
                                        bool:isNom, bool:forMapChange)
{
    if (isNom && GetConVarBool(cvar_nom_ignore))
        return Plugin_Continue;
        
    if (!forMapChange && GetConVarBool(cvar_display_ignore))
        return Plugin_Continue;
    
    new defaultMin, defaultMax;
    new min, max;
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        defaultMin = KvGetNum(kv, TIMELIMIT_KEY_GROUP_MIN, DEFAULT_MIN);
        defaultMax = KvGetNum(kv, TIMELIMIT_KEY_GROUP_MAX, DEFAULT_MAX);
    
        if (KvJumpToKey(kv, map))
        {    
            min = KvGetNum(kv, TIMELIMIT_KEY_MAP_MIN, defaultMin);
            max = KvGetNum(kv, TIMELIMIT_KEY_MAP_MAX, defaultMax);
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
    
    if (IsTimeBetween(min, max))
        return Plugin_Continue;
    
    DEBUG_MESSAGE("Map %s is excluded due to Time Limits. Min: %i, Max: %i", map, min, max)
    return Plugin_Stop;
}

