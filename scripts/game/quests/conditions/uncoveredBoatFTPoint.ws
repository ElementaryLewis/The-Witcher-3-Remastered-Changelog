/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_UncoveredBoatFTPoint_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_UncoveredBoatFTPoint;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_UncoveredBoatFTPoint extends CQuestScriptedCondition
{
	saved var isFulfilled	: bool;
	var listener			: W3QuestCond_UncoveredBoatFTPoint_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_UncoveredBoatFTPoint_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnMapPinChanged ), listener );
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnMapPinChanged ), listener );
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
		isFulfilled = theGame.GetCommonMapManager().HasFastTravelPoints( true, true, true, false );
	}
}