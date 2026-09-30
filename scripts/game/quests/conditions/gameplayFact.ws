/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_GameplayFact_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_GameplayFact;
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		if ( condition && eventParam == condition.gameplayFactId )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_GameplayFact extends CQuestScriptedCondition
{
	editable var gameplayFactId : string;
	editable var value 			: int;
	editable var comparator 	: ECompareOp;
		
	var isFulfilled				: bool;
	var listener				: W3QuestCond_GameplayFact_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_GameplayFact_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterString( GetGlobalEventCategory( SEC_GameplayFact ), listener, gameplayFactId );
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterString( GetGlobalEventCategory( SEC_GameplayFact ), listener, gameplayFactId );
			delete listener;
			listener = NULL;		
		}
	}
	
	function Activate()
	{
		EvaluateImpl();
		if ( !isFulfilled )
		{
			RegisterListener( true );
		}		
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			RegisterListener( false );
		}
	}

	function Evaluate() : bool
	{	
		if ( !isFulfilled && !listener )
		{
			RegisterListener( true );
		}
		return isFulfilled;
	}

	function EvaluateImpl()
	{
		isFulfilled = ProcessCompare( comparator, GameplayFactsQuerySum( gameplayFactId ), value );
	}
}