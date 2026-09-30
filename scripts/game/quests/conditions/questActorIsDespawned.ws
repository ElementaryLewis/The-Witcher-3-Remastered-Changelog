/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_ActorIsDespawned_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_ActorIsDespawned;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.actorTag )
		{
			condition.FindActors();	
		}	
	}	
}

class W3QuestCond_ActorIsDespawned extends CQuestScriptedCondition
{
	editable var actorTag 	: name;
	var actors				: array< CActor >;
	var listener			: W3QuestCond_ActorIsDespawned_Listener;
	
	function Activate()
	{	
		FindActors();
		listener = new W3QuestCond_ActorIsDespawned_Listener in this;
		listener.condition = this;
		theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, actorTag );
	}
	
	function Deactivate()
	{
		if ( listener )
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, actorTag );
			delete listener;
			listener = NULL;
		}
		actors.Clear();
	}

	function Evaluate() : bool
	{	
		var i : int;				
		for ( i = 0; i < actors.Size(); i+=1 )
		{
			if ( actors[i] )
			{
				return false;
			}
		}				
		return true;
	}
	
	function FindActors()
	{
		theGame.GetActorsByTag( actorTag, actors );	
	}
}