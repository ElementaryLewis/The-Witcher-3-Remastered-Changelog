/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_CanSeePlayer_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_CanSeePlayer;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.actorTag )
		{
			condition.FindActor();	
		}	
	}	
}

class W3QuestCond_CanSeePlayer extends CQuestScriptedCondition
{
	editable var actorTag 	: name;
	var npc 				: CNewNPC;
	var listener			: W3QuestCond_CanSeePlayer_Listener;
	
	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_CanSeePlayer_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, actorTag );
			FindActor();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, actorTag );
			delete listener;
			listener = NULL;
		}
	}
	
	function Activate()
	{	
		FindActor();
		if ( !npc )
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
		if ( npc )
		{
			return npc.IfCanSeePlayer();
		}
		else if ( !listener )
		{
			RegisterListener( true );		
		}
		return false;
	}
	
	function FindActor()
	{
		if ( npc )
		{
			return;
		}
		npc = theGame.GetNPCByTag( actorTag );
		if ( npc && listener )
		{
			RegisterListener( false );		
		}
	}
}