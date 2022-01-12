/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                   Ultimate Mapchooser - Extend and Don't Change Positioning                   *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#pragma semicolon 1

#include <sourcemod>
#include <umc-core>

//Plugin Information
public Plugin:myinfo =
{
	name        = "[UMC] Extend and Don't Change Positioning",
	author      = "Steell",
	description = "Modifies the position of the Extend Map and Don't Change options in UMC votes",
	version     = PL_VERSION,
	url         = "http://forums.alliedmods.net/showthread.php?t=134190"
};


new Handle:cvar_ex_change = INVALID_HANDLE;
new Handle:cvar_dc_change = INVALID_HANDLE;

new ex_change_cntr = 0;
new dc_change_cntr = 0;

//Called when the plugin is finished loading.
public OnPluginStart()
{
	cvar_ex_change = CreateConVar(
		"sm_umc_extend_changeposafter",
		"0",
		"Specifies how many times the map is extended before the position of the Extend Map option is changed. 0 = Never change.",
		0, true, 0.0
	);

	cvar_dc_change = CreateConVar(
		"sm_umc_dontchange_changeposafter",
		"0",
		"Specifies how many times a map vote fails before the position of the Don't Change option is changed. 0 = Never change",
		0, true, 0.0
	);

	AutoExecConfig(true, "umc-extend-position");
}


public OnConfigsExecuted()
{
	ex_change_cntr = 0;
	dc_change_cntr = 0;
}


//Called when UMC has extended a map.
public UMC_OnMapExtended()
{
	ex_change_cntr++;
	if (ex_change_cntr == GetConVarInt(cvar_ex_change))
	{
		SetConVarInt(FindConVar("sm_umc_extend_display"), 0);
	}
}


//Called when a UMC vote fails (or Don't Change is the winner).
public UMC_OnVoteFailed()
{
	dc_change_cntr++;
	if (dc_change_cntr == GetConVarInt(cvar_dc_change))
	{
		SetConVarInt(FindConVar("sm_umc_dontchange_display"), 0);
	}
}
