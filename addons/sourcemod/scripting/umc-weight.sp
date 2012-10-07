/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                Ultimate Mapchooser - Map Weight                               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <umc-core>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-weight.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-weight.txt"
#endif

public Plugin:myinfo =
{
    name = "[UMC] Map Weight",
    author = "Steell",
    description = "Allows users to specify weights for maps and groups, making them more or less likely to be picked randomly.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

#define WEIGHT_KEY_MAP   "weight"
#define WEIGHT_KEY_GROUP "group_weight"


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


//Excludes maps with a set weight of 0
public Action:UMC_OnDetermineMapExclude(Handle:kv, const String:map[], const String:group[], bool:isNom, bool:forMapChange)
{
    if (kv == INVALID_HANDLE)
        return Plugin_Continue;

    KvRewind(kv);
    
    if (KvJumpToKey(kv, group))
    {
        if (KvJumpToKey(kv, map))
        {
            if (KvGetFloat(kv, WEIGHT_KEY_MAP, 1.0) == 0.0)
            {
                KvGoBack(kv);
                KvGoBack(kv);
                return Plugin_Stop;
            }
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
    return Plugin_Continue;
}



//Reweights a map when UMC requests.
public UMC_OnReweightMap(Handle:kv, const String:map[], const String:group[])
{
    if (kv == INVALID_HANDLE)
        return;

    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        if (KvJumpToKey(kv, map))
        {
            UMC_AddWeightModifier(KvGetFloat(kv, WEIGHT_KEY_MAP, 1.0));
            KvGoBack(kv);
        }
        KvGoBack(kv);
    }
}


//Reweights a group when UMC requests.
public UMC_OnReweightGroup(Handle:kv, const String:group[])
{
    if (kv == INVALID_HANDLE)
        return;

    KvRewind(kv);
    if (KvJumpToKey(kv, group))
    {
        UMC_AddWeightModifier(KvGetFloat(kv, WEIGHT_KEY_GROUP, 1.0));
        KvGoBack(kv);
    }
}