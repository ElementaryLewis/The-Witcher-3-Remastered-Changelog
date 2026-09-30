/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsItemUsed_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_IsItemUsed;
	
	event OnGlobalEventString( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : string )
	{
		if ( condition && eventParam == condition.factName )
		{
			condition.EvaluateImpl();		
		}	
	}
}

class W3QuestCond_IsItemUsed extends CQuestScriptedCondition
{
	editable var itemName 	: name;
	var factName 			: string;
	var isFulfilled			: bool;
	var listener 			: W3QuestCond_IsItemUsed_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_IsItemUsed_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterString( GEC_Fact, listener, factName );		
			EvaluateImpl();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterString( GEC_Fact, listener, factName );
			delete listener;
			listener = NULL;		
		}
	}
	
	function Activate()
	{
		factName = "item_use_" + itemName;
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
		isFulfilled = FactsQuerySum( factName ) > 0;	
	}
}