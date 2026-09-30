/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsEffectActive_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_IsEffectActive;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.entityTag )
		{
			condition.FindEntity();
		}	
	}
}

class W3QuestCond_IsEffectActive extends CQuestScriptedCondition
{
	editable var effectName : name;
	editable var entityTag  : name;
	editable var inverted: bool;

	var entity				: CEntity;
	var listener			: W3QuestCond_IsEffectActive_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_IsEffectActive_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, entityTag );
			FindEntity();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, entityTag );
			delete listener;
			listener = NULL;		
		}
	}

	function Activate()
	{
		FindEntity();
		if ( !entity )
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
		if ( entity )
		{
			if ( inverted )
			{
				return !entity.IsEffectActive(effectName, false);
			}
			else
			{
				return entity.IsEffectActive(effectName, false);
			}
		}
		else if ( !listener )
		{
			RegisterListener( true );
		}
		return false;
	}
	
	function FindEntity()
	{
		entity = theGame.GetEntityByTag( entityTag );
	}
}