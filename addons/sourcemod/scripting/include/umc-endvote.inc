//Header file for Ultimate Mapchooser v3.0 by Steell.
#if defined _umc_endvote_included
    #endinput
#endif
#define _umc_endvote_included


/**
 * Called when the amount of time before the end of map vote starts changes.
 *
 * @param timeleft  The amount of time remaining before the vote starts.
 *
 * @noreturn
 */
forward UMC_EndVote_OnTimeTimerUpdated(timeleft);


/**
 * Called when the amount of completed rounds needed until the end of map vote starts changes.
 *
 * @param roundsleft    The amount of rounds remaining before the vote starts.
 *
 * @noreturn
 */
forward UMC_EndVote_OnRoundTimerUpdated(roundsleft);


/**
 * Called when the amount of completed rounds needed until the end of map vote starts changes.
 *
 * @param winsleft  The amount of wins remaining before the vote starts.
 * @param team  The index of the team with the most wins.
 *
 * @noreturn
 */
forward UMC_EndVote_OnWinTimerUpdated(winsleft, team);


/**
 * Called when the amount of frags needed until the end of map vote starts changes.
 *
 * @param fragsleft The amount of frags remaining before the vote starts.
 * @param client    The client with the most frags.
 *
 * @noreturn
 */
forward UMC_EndVote_OnFragTimerUpdated(fragsleft, client);


/**
 * Called when the time timer ticks.
 *
 * @param timeleft  The amount of time remaining before the vote starts.
 *
 * @noreturn
 */
forward UMC_EndVote_OnTimeTimerTicked(timeleft);


/** 
 * Called when the round timer ticks.
 * 
 * @param roundsleft    The amount of rounds remaining before the vote starts.
 *
 * @noreturn
 */
forward UMC_EndVote_OnRoundTimerTicked(roundsleft);


/**
 * Called when the win timer ticks.
 *
 * @param winsleft  The amount of wins remaining before the vote starts.
 * @param team  The index team with the most wins.
 *
 * @noreturn
 */
forward UMC_EndVote_OnWinTimerTicked(winsleft, team);


/**
 * Called when the frag timer ticks.
 *
 * @param fragsleft The amount of frags remaining before the vote starts.
 * @param client    The winning client.
 *
 * @noreturn
 */
forward UMC_EndVote_OnFragTimerTicked(fragsleft, client);



//SourceMod Malarky
public SharedPlugin:__pl_umc_endvote =
{
    name = "umc-endvote",
    file = "umc-endvote.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

public __pl_umc_endvote_SetNTVOptional()
{
    
}
