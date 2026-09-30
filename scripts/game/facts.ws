/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SFactParameters
{
	editable var ID			: string;
	editable var value		: int;
	editable var validFor	: int;
}


import function FactsAdd( ID : string, optional value : int, optional validFor : int , optional telemetryEvent : bool , optional storyScenePlayer : CStoryScenePlayer );


import function FactsQuerySum( ID : string ) : int;



import function FactsQuerySumSince( ID : string, sinceTime : EngineTime ) : int;


import function FactsQueryLatestValue( ID : string ) : int;


import function FactsDoesExist( ID : string ) : bool;


import function FactsRemove( ID : string ) : bool;

function FactsSet(ID : string, val : int, optional validFor : int )
{
	FactsRemove(ID);
	
	
	if(validFor == 0)
		validFor = -1;	

	FactsAdd(ID, val, validFor);
}

function FactsSubstract(ID : string, optional val : int)
{
	if(val == 0)
		val = 1;
		
	if(val > 0)
		FactsSet(ID, Max(0, FactsQuerySum(ID) - val) );
}








struct SGameplayFact
{
	saved var factName : string;
	saved var value : int;
};

struct SGameplayFactRemoval
{
	saved var factName : string;
	saved var value : int;
	saved var timerID : int;
};

function GameplayFactsAdd(factName : string, optional value : int, optional realtimeSecsValidFor : int)
{
	theGame.GameplayFactsAdd(factName, value, realtimeSecsValidFor);
	theGame.GetGlobalEventsManager().OnScriptedEventString( SEC_GameplayFact, SET_Unknown, factName );
}

function GameplayFactsSet(factName : string, value : int)
{
	theGame.GameplayFactsSet(factName, value);
	theGame.GetGlobalEventsManager().OnScriptedEventString( SEC_GameplayFact, SET_Unknown, factName );
}

function GameplayFactsQuerySum(factName : string) : int
{
	return theGame.GameplayFactsQuerySum(factName);
}

function GameplayFactsRemove(factName : string)
{
	return theGame.GameplayFactsRemove(factName);
	theGame.GetGlobalEventsManager().OnScriptedEventString( SEC_GameplayFact, SET_Unknown, factName );
}