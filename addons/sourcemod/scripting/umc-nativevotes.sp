/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                              Ultimate Mapchooser - Native Voting                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
 
#pragma semicolon 1

#include <sourcemod>
#include <sdktools_sound>
#include <umc-core>
#include <umc_utils>
#include <nativevotes>

#include <emitsoundany>

#undef REQUIRE_PLUGIN

//Auto update
#include <updater>
#if AUTOUPDATE_DEV
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/dev/updateinfo-umc-builtinvotes.txt"
#else
    #define UPDATE_URL "http://www.ccs.neu.edu/home/steell/sourcemod/ultimate-mapchooser/updateinfo-umc-builtinvotes.txt"
#endif

// From core
#define NOTHING_OPTION "?nothing?"

new bool:vote_active;
new Handle:g_menu;
new Handle:cvar_logging;

//Plugin Information
public Plugin:myinfo =
{
    name        = "[UMC] Native Voting",
    author      = "Steell",
    description = "Extends Ultimate Mapchooser to allow usage of Native Votes.",
    version     = PL_VERSION,
    url         = "http://forums.alliedmods.net/showthread.php?t=134190"
};


//Changelog:
/*
3.3.2 (3/4/2012)
Fixed issue where extend map wasn't working properly.

3.3.1r2 (12/15/11)
Fixed issue which prevented votes from starting.

3.3.1 (12/13/11)
Fixed issue where errors were being logged accidentally.
Fixed issue where cancelling a vote could cause errors (and in some cases cause voting to stop working).

3.4.6 (2/9/13)
Updated to new Native Votes API.
*/

public OnPluginStart()
{
    LoadTranslations("ultimate-mapchooser.phrases");
}

//
public OnAllPluginsLoaded()
{
    cvar_logging = FindConVar("sm_umc_logging_verbose");

	// Don't replace core if we're on L4D, L4D2, or CS:GO
    if (LibraryExists("nativevotes") && NativeVotes_IsVoteTypeSupported(NativeVotesType_NextLevelMult))
    {
        UMC_RegisterVoteManager("core", VM_MapVote, VM_GroupVote, VM_CancelVote);
    }
    
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


//
public OnPluginEnd()
{
    UMC_UnregisterVoteManager("core");
}


//************************************************************************************************//
//                                        CORE VOTE MANAGER                                       //
//************************************************************************************************//

public bool:VM_IsVoteInProgress()
{
	return NativeVotes_IsVoteInProgress();
}

//
public Action:VM_MapVote(duration, Handle:vote_items, const clients[], numClients,
                         const String:startSound[])
{
    if (VM_IsVoteInProgress())
    {
        LogUMCMessage("Could not start native vote, another NativeVotes vote is already in progress.");
        return Plugin_Stop;
    }

    new bool:verboseLogs = cvar_logging != INVALID_HANDLE && GetConVarBool(cvar_logging);

    if (verboseLogs)
       LogUMCMessage("Adding Clients to Vote:");
	
    DEBUG_MESSAGE("Attempting to start native vote...")
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
        LogUMCMessage("Could not start native vote, no players to display vote to!");
        return Plugin_Stop;
    }
    
    //new Handle:menu = BuildVoteMenu(vote_items, "Map Vote Menu Title", Handle_MapVoteResults);
    //g_menu = BuildVoteMenu(vote_items, Handle_MapVoteResults);
    g_menu = BuildVoteMenu(vote_items, Handle_MapVoteResults, NativeVotesType_NextLevelMult);
    
    vote_active = g_menu != INVALID_HANDLE && NativeVotes_Display(g_menu, clientArr, count, duration);
    
    if (vote_active)
    {
		
       DEBUG_MESSAGE("Setting CVA True")

       if (strlen(startSound) > 0)
           EmitSoundToAllAny(startSound);
        
       return Plugin_Continue;
    }
    else
    {
       DEBUG_MESSAGE("Setting CVA False -- Couldn't start vote")
       LogError("Could not start native vote.");
       return Plugin_Stop;
    }
}

public Action:VM_GroupVote(duration, Handle:vote_items, const clients[], numClients,
                           const String:startSound[])
{
    if (VM_IsVoteInProgress())
    {
        LogUMCMessage("Could not start native vote, another NativeVotes vote is already in progress.");
        return Plugin_Stop;
    }

    new bool:verboseLogs = cvar_logging != INVALID_HANDLE && GetConVarBool(cvar_logging);

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
        LogUMCMessage("Could not start native vote, no players to display vote to!");
        return Plugin_Stop;
    }
    
    //new Handle:menu = BuildVoteMenu(vote_items, "Map Vote Menu Title", Handle_MapVoteResults);
    g_menu = BuildVoteMenu(vote_items, Handle_MapVoteResults, NativeVotesType_Custom_Mult, "Group Vote Menu Title");
    
    DEBUG_MESSAGE("Setting CVA True")
    vote_active = true;
    
    if (g_menu != INVALID_HANDLE && NativeVotes_Display(g_menu, clientArr, count, duration))
    {
        if (strlen(startSound) > 0)
            EmitSoundToAllAny(startSound);
        
        return Plugin_Continue;
    }
	
    DEBUG_MESSAGE("Setting CVA False -- Couldn't start vote")
    vote_active = false;
    
    //ClearVoteArrays();
    LogError("Could not start native vote.");
    return Plugin_Stop;
}

//
Handle:BuildVoteMenu(Handle:vote_items, NativeVotes_VoteHandler:callback, NativeVotesType:type, const String:title[]="")
{
    new bool:verboseLogs = cvar_logging != INVALID_HANDLE && GetConVarBool(cvar_logging);
    
    if (verboseLogs)
        LogUMCMessage("VOTE MENU:");

    new size = GetArraySize(vote_items);
    if (size <= 1)
    {
        DEBUG_MESSAGE("Not enough items in the vote. Aborting.")
        LogError("VOTING: Not enough maps to run a map vote. %i maps available.", size);
        return INVALID_HANDLE;
    }
    
    //Begin creating menu
    new Handle:menu = NativeVotes_Create(Handle_VoteMenu, type,
                                         NATIVEVOTES_ACTIONS_DEFAULT|MenuAction_VoteCancel|MenuAction_Display|MenuAction_DisplayItem);
        
    if (title[0] != '\0')
    {
        NativeVotes_SetTitle(menu, title);
        //NativeVotes_SetDetails(menu, "Group Vote Menu Title");
    }
    NativeVotes_SetResultCallback(menu, callback); //Set callback
        
    new Handle:voteItem;
    decl String:info[MAP_LENGTH], String:display[MAP_LENGTH];
    for (new i = 0; i < size; i++)
    {
        voteItem = GetArrayCell(vote_items, i);
        GetTrieString(voteItem, "info", info, sizeof(info));
        GetTrieString(voteItem, "display", display, sizeof(display));
        
        NativeVotes_AddItem(menu, info, display);

#if UMC_DEBUG
        if (StrEqual(info, EXTEND_MAP_OPTION))
            DEBUG_MESSAGE("Adding Extend Option to vote menu. Position: %i", i + 1)
        else if (StrEqual(info, DONT_CHANGE_OPTION))
            DEBUG_MESSAGE("Adding Don't Change Option to vote menu. Position: %i", i + 1)
#endif
 
        if (verboseLogs)
            LogUMCMessage("%i: %s (%s)", i + 1, display, info);
    }
    
    DEBUG_MESSAGE("Vote menu built successfully.")
    return menu; //Return the finished menu.
}

//
public VM_CancelVote()
{
    DEBUG_MESSAGE("Vote Cancelled Callback -- NativeVotes")
    DEBUG_MESSAGE("Is NativeVotes Vote still active? %i", vote_active)
    if (vote_active)
    {
        DEBUG_MESSAGE("Vote Cancelled Callback -- NativeVotes Inner")        
        DEBUG_MESSAGE("Vote Cancelled and Cancel Callback not yet called!")
        DEBUG_MESSAGE("Setting CVA False -- Cancelled")
        vote_active = false;
        NativeVotes_Cancel();
    }
}


//Called when a vote has finished.
public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            if (cvar_logging != INVALID_HANDLE && GetConVarBool(cvar_logging))
                LogUMCMessage("%L selected menu item %i", param1, param2);
            //TODO
            UMC_VoteManagerClientVoted("core", param1, INVALID_HANDLE);
        }
        
        case MenuAction_Display:
        {
            new NativeVotesType:type = NativeVotes_GetType(menu);
            if (type == NativeVotesType_Custom_Mult)
            {
                decl String:phrase[255];
                NativeVotes_GetTitle(menu, phrase, sizeof(phrase));
                
                decl String:buffer[255];
                FormatEx(buffer, sizeof(buffer), "%T", phrase, param1);
				
                NativeVotes_RedrawVoteTitle(buffer);
                return _:Plugin_Changed;
            }
        }
        case MenuAction_VoteCancel:
        {
            switch (param1)
            {
                case VoteCancel_Generic:
                {
                    NativeVotes_DisplayFail(menu, NativeVotesFail_Generic);
                }
                case VoteCancel_NoVotes:
                {
                    NativeVotes_DisplayFail(menu, NativeVotesFail_NotEnoughVotes);
                }
            }
            if (vote_active)
            {
                DEBUG_MESSAGE("Vote Cancelled")
                vote_active = false;
                UMC_VoteManagerVoteCancelled("core");
            }
        }
        case MenuAction_End:
        {
            DEBUG_MESSAGE("MenuAction_End")
            NativeVotes_Close(menu);
        }
        case MenuAction_DisplayItem:
        {
            decl String:map[MAP_LENGTH], String:display[MAP_LENGTH];
            NativeVotes_GetItem(menu, param2, map, sizeof(map), display, sizeof(display));

            if (StrEqual(map, EXTEND_MAP_OPTION) || StrEqual(map, DONT_CHANGE_OPTION) ||
                (StrEqual(map, NOTHING_OPTION) && strlen(display) > 0))
            {
                decl String:buffer[255];
                FormatEx(buffer, sizeof(buffer), "%T", display, param1);
                
                NativeVotes_RedrawVoteItem(buffer);
                return _:Plugin_Changed;
            }
		}
    }
    return 0;
}


//Handles the results of a vote.
public Handle_MapVoteResults(Handle:menu, num_votes, num_clients, const client_indeces[], const client_votes[],
                             num_items, const item_indeces[], const item_votes[])
{
    DEBUG_MESSAGE("Handling vote results...")
    DEBUG_MESSAGE("Setting CVA False -- Completed")
    vote_active = false;
	
    new Handle:results = ConvertVoteResults(menu, num_clients, client_indeces, client_votes, num_items,
                                            item_indeces);

    UMC_VoteManagerVoteCompleted("core", results, Handle_UMCVoteResponse);
    
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


//Converts results of a vote to the format required for UMC to process votes.
Handle:ConvertVoteResults(Handle:menu, num_clients, const client_indeces[], const client_votes[],
                          num_items, const item_indeces[])
{
    new Handle:result = CreateArray();
    new itemIndex;
    new Handle:voteItem, Handle:voteClientArray;
    decl String:info[MAP_LENGTH], String:disp[MAP_LENGTH];
    for (new i = 0; i < num_items; i++)
    {
        itemIndex = item_indeces[i];
        NativeVotes_GetItem(menu, itemIndex, info, sizeof(info), disp, sizeof(disp));
        
        voteItem = CreateTrie();
        voteClientArray = CreateArray();
        
        SetTrieString(voteItem, "info", info);
        SetTrieString(voteItem, "display", disp);
        SetTrieValue(voteItem, "clients", voteClientArray);
        
        PushArrayCell(result, voteItem);
        
        for (new j = 0; j < num_clients; j++)
        {
            if (client_votes[j] == itemIndex)
                PushArrayCell(voteClientArray, client_indeces[j]);
        }
    }
    return result;
}


public Handle_UMCVoteResponse(UMC_VoteResponse:response, const String:param[])
{
    switch (response)
    {
        case VoteResponse_Success:
        {
           if (StrEqual(param, EXTEND_MAP_OPTION))
           {
              NativeVotes_DisplayPassEx(g_menu, NativeVotesPass_Extend);
           }
           else if (StrEqual(param, DONT_CHANGE_OPTION))
           {
              NativeVotes_DisplayPassCustom(g_menu, "%t", "Map Unchanged");
           }
           else
           {
              decl String:map[MAP_LENGTH];
              strcopy(map, sizeof(map), param);
              if (NativeVotes_GetType(g_menu) == NativeVotesType_Custom_Mult)
              {
                 // NativeVotes_DisplayPassEx(g_menu, NativeVotesPass_NextLevel, map);
                 NativeVotes_DisplayPassCustom(g_menu, "%s", map);
              }
              else
              {
                 NativeVotes_DisplayPass(g_menu, map);
              }
           }
        }
        case VoteResponse_Runoff:
        {
            NativeVotes_DisplayFail(g_menu, NativeVotesFail_NotEnoughVotes);
        }
        case VoteResponse_Tiered:
        {
            decl String:map[MAP_LENGTH];
            strcopy(map, sizeof(map), param);
            //NativeVotes_DisplayPass(g_menu, map);
            NativeVotes_DisplayPassCustom(g_menu, "%s", map);
        }
        case VoteResponse_Fail:
        {
            NativeVotes_DisplayFail(g_menu, NativeVotesFail_NotEnoughVotes);
        }
    }
}
