/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3QuestCond_IsTargetOf_Listener extends IGlobalEventScriptedListener
{
	public var condition : W3QuestCond_IsTargetOf;
	
	event OnGlobalEventName( eventCategory : EGlobalEventCategory, eventType : EGlobalEventType, eventParam : name )
	{
		if ( condition && eventParam == condition.attackerTag )
		{
			condition.FindAttacker();	
		}	
	}	
}

class W3QuestCond_IsTargetOf extends CQCActorScriptedCondition
{
	editable var attackerTag 	: name;
	var attacker 				: CActor;
	var listener				: W3QuestCond_IsTargetOf_Listener;

	function RegisterListener( flag : bool )
	{
		if ( flag )
		{
			listener = new W3QuestCond_IsTargetOf_Listener in this;
			listener.condition = this;
			theGame.GetGlobalEventsManager().AddListenerFilterName( GEC_Tag, listener, attackerTag );
			FindAttacker();
		}
		else
		{
			theGame.GetGlobalEventsManager().RemoveListenerFilterName( GEC_Tag, listener, attackerTag );
			delete listener;
			listener = NULL;
		}
	}

	function OnActivate( actor : CActor ) : bool
	{	
		FindAttacker();
		if ( !attacker )
		{
			RegisterListener( true );
		}
		return true;
	}

	function OnDeactivate( actor : CActor ) : bool
	{	
		if ( listener )
		{
			RegisterListener( false );
		}
		return true;
	}

	function Evaluate( actor : CActor ) : bool
	{	
		if ( attacker )
		{
			return attacker.GetTarget() == actor;
		}
		else if ( !listener )
		{
			RegisterListener( true );		
		}
		return false;				
	}
	
	function FindAttacker()
	{
		if ( attacker )
		{
			return;
		}
		if ( attackerTag == 'PLAYER' )
		{
			attacker = thePlayer;
		}
		else
		{
			attacker = theGame.GetNPCByTag( attackerTag );
		}
		if ( attacker && listener )
		{
			RegisterListener( false );
		}
	}
}