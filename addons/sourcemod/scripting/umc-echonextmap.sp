/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                               Ultimate Mapchooser - Echo Nextmap                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <umc-core>
#include <umc_utils>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-echonextmap.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-echonextmap.txt"
#endif

public Plugin:myinfo =
{
    name = "[UMC] Echo Nextmap",
    author = "Steell",
    description = "Displays messages to the server when the next map is set.",
    version = PL_VERSION,
    url = "http://forums.alliedmods.net/showthread.php?t=134190"
}

//Cvars
new Handle:cvar_center  = INVALID_HANDLE;
new Handle:cvar_hint    = INVALID_HANDLE;
new Handle:cvar_display = INVALID_HANDLE;


//Called when the plugin loads.
public OnPluginStart()
{
    cvar_display = CreateConVar(
        "sm_umc_echonextmap_display",
        "0",
        "If enabled, the displayed map name will be the real name of the map, not the name taken from the map's \"display\" setting.",
        0, true, 0.0, true, 1.0
    );

    cvar_center = CreateConVar(
        "sm_umc_echonextmap_center",
        "1",
        "If enabled, a message will be displayed in the center of the screen when the next map is set.",
        0, true, 0.0, true, 1.0
    );
    
    cvar_hint = CreateConVar(
        "sm_umc_exchonextmap_hint",
        "0",
        "If enabled, a message will be displayed in the hint box when the next map is set.",
        0, true, 0.0, true, 1.0
    );

    //Create the config if it doesn't exist, and then execute it.
    AutoExecConfig(true, "umc-echonextmap");
    
    //Load the translations file
    LoadTranslations("ultimate-mapchooser.phrases");

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


//Called when UMC has set the next map.
public UMC_OnNextmapSet(Handle:kv, const String:map[], const String:group[], const String:display[])
{
    DEBUG_MESSAGE("Map changed, displaying message...")

    new bool:disp = !GetConVarBool(cvar_display);

    if (GetConVarBool(cvar_center))
    {
        new String:msg[256];
        if (disp && strlen(display) > 0)
            Format(msg, sizeof(msg), "[UMC] %t", "Next Map", display);
        else
            Format(msg, sizeof(msg), "[UMC] %t", "Next Map", map);
        DEBUG_MESSAGE("Attempting to display center message: \"%s\"", msg)
        DisplayServerMessage(msg, "C");
        //PrintCenterTextAll("[UMC] %t", "Next Map", map);
    }
    if (GetConVarBool(cvar_hint))
    {
        if (disp && strlen(display) > 0)
        {
            DEBUG_MESSAGE("Attempting to display hint message: \"%s\"", display)
            PrintHintTextToAll("[UMC] %t", "Next Map", display);
        }
        else
        {
            DEBUG_MESSAGE("Attempting to display hint message: \"%s\"", map)
            PrintHintTextToAll("[UMC] %t", "Next Map", map);
        }
    }
}


