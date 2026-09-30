/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_HudTimeOut_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_HudTimeOut;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition )
		{
			condition.EvaluateImpl();
		}	
	}
}

class W3QuestCond_HudTimeOut extends CQuestScriptedCondition
{
	saved var isFulfilled	: bool;
	var listener			: W3QuestCond_HudTimeOut_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_HudTimeOut_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListener( GetGlobalEventCategory( SEC_OnHudTimeOut ), listener );
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListener( GetGlobalEventCategory( SEC_OnHudTimeOut ), listener );
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
		isFulfilled = ( thePlayer.GetCurrentTimeOut() <= 0 );
	}
}