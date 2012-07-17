/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                          Ultimate Mapchooser - Post-Played Exclusion                          *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <umc-core>
#include <umc_utils>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-postexclude.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-postexclude.txt"
#endif

#define REQUIRE_PLUGIN

public Plugin:myinfo =
{
    name = "[UMC] Post-Played Exclusion",
    author = "Sazpaimon and Steell",
    description = "Allows users to specify an amount of time after a map is played that it should be excluded.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

#define POSTEX_KEY_MAP "allow_every"
#define POSTEX_KEY_GROUP "default_allow_every"
#define POSTEX_DEFAULT_VALUE 0

new Handle:cvar_nom_ignore = INVALID_HANDLE;
new Handle:cvar_display_ignore = INVALID_HANDLE;

new Handle:time_played_trie = INVALID_HANDLE;

public OnPluginStart()
{
    cvar_nom_ignore = CreateConVar(
        "sm_umc_postex_ignorenominations",
        "0",
        "Determines if nominations are exempt from being excluded due to Post-Played Exclusion.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_display_ignore = CreateConVar(
        "sm_umc_postex_ignoredisplay",
        "0",
        "Determines if maps being displayed are exempt from being excluded due to Post-Played Exclusion.",
        0, true, 0.0, true, 1.0
    );
    
    AutoExecConfig(true, "umc-postexclude");
    
    time_played_trie = CreateTrie();
    
    UMC_RegTemplateVariable(POSTEX_KEY_MAP, OnTemplateRequested);
}


//
public OnMapStart()
{
    decl String:map[MAP_LENGTH], String:group[MAP_LENGTH];
    GetCurrentMap(map, sizeof(map));
    UMC_GetCurrentMapGroup(group, sizeof(group));

    new Handle:groupMaps;
    if (!GetTrieValue(time_played_trie, group, groupMaps))
    {
        groupMaps = CreateTrie();
        SetTrieValue(time_played_trie, group, groupMaps);
    }
    SetTrieValue(groupMaps, map, GetTime());
}


//
bool:IsStillDelayed(const String:map[], const String:group[], minsDelayed)
{
    new Handle:groupMaps;
    if (!GetTrieValue(time_played_trie, group, groupMaps))
        return false;
    new timePlayed;
    if (!GetTrieValue(groupMaps, map, timePlayed))
        return false;
    new Float:minsSincePlayed = GetTime() - timePlayed / 60.0;
    
#if UMC_DEBUG
    new bool:result = minsSincePlayed <= minsDelayed;
    if (minsDelayed > 0)
    {
        if (result)
            DEBUG_MESSAGE("Map %s Excluded: Played %.f mins ago, delayed for %i mins after playing. (%.f remaining).", map, minsSincePlayed, minsDelayed, minsDelayed-minsSincePlayed)
        else
            DEBUG_MESSAGE("Map %s Allowed: Played %.f mins ago, delayed for %i mins after playing. (Allowed for the past %.f mins).", map, minsSincePlayed, minsDelayed, minsSincePlayed-minsDelayed)
    }
    return result;
#else
    return minsSincePlayed <= minsDelayed;
#endif
}


//
public OnTemplateRequested(const String:varName[], String:buffer[], maxlen, Handle:kv, 
                           const String:map[], const String:group[])
{
    new def, val;
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        def = KvGetNum(kv, POSTEX_KEY_GROUP, POSTEX_DEFAULT_VALUE);
    
        if (KvJumpToKey(kv, map))
        {    
            val = KvGetNum(kv, POSTEX_KEY_MAP, def);
            KvGoBack(kv);
        }
        else
        {
            val = def;
        }
        KvGoBack(kv);
    }
    
    FormatEx(buffer, maxlen, "Allowed every %i minutes", val);
}


//Called when UMC wants to know if this map is excluded
public Action:UMC_OnDetermineMapExclude(Handle:kv, const String:map[], const String:group[],
                                        bool:isNom, bool:forMapChange)
{
    if (isNom && GetConVarBool(cvar_nom_ignore))
        return Plugin_Continue;
        
    if (!forMapChange && GetConVarBool(cvar_display_ignore))
        return Plugin_Continue;
    
    new def, val;
    
    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        def = KvGetNum(kv, POSTEX_KEY_GROUP, POSTEX_DEFAULT_VALUE);
    
        if (KvJumpToKey(kv, map))
        {    
            val = KvGetNum(kv, POSTEX_KEY_MAP, def);
            KvGoBack(kv);
        }
        else
        {
            val = def;
        }
        KvGoBack(kv);
    }
    
    if (IsStillDelayed(map, group, val))
        return Plugin_Stop;
    
    return Plugin_Continue;
}

