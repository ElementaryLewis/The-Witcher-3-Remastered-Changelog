/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDelay extends IBehTreeTask
{
	var delay : float;
	var nextActionTime : float;
	
	default nextActionTime = 0.0;
	
	function IsAvailable() : bool
	{
		var target : CActor;
		var npc : CNewNPC;
		
		if ( nextActionTime > GetLocalTime() )
		{
			return false;
		}
		
		npc = GetNPC();
		target = GetCombatTarget();
		
		return target && target.IsAlive();
		
	}
	
	function OnDeactivate()
	{
		nextActionTime = GetLocalTime() + delay;
	}
}
class CBTTaskDelayDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDelay';

	editable var delay : float;

	default delay = 10.0;
}


class CBTTaskActivateOnlyOnce extends IBehTreeTask
{
	private var successOnly					: bool;	
	private var resetWhenReattachFromPool	: bool;
	private var resetOnGameplayEvent 		: name;
	private var wasActivated 				: bool;
	
	default wasActivated = false;
	
	
	function IsAvailable() : bool
	{
		return !wasActivated;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if( !successOnly )
			wasActivated = true;
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !successOnly )
			wasActivated = true;
	}
	
	function OnCompletion( success : bool )
	{
		if( success && successOnly )
			wasActivated = true;
	}
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if( eventName == 'OnReattachFromPool' && resetWhenReattachFromPool )
		{
			wasActivated = false;
		}
		else if ( eventName == resetOnGameplayEvent )
		{
			wasActivated = false;
		}
		return true;
	}
}
class CBTTaskActivateOnlyOnceDef extends IBehTreeTaskDefinition
{
	editable var successOnly				: bool;
	editable var resetWhenReattachFromPool	: bool;
	editable var resetOnGameplayEvent 		: name;
	
	default instanceClass = 'CBTTaskActivateOnlyOnce';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnReattachFromPool' );
		if ( IsNameValid( resetOnGameplayEvent ) )
		{
			listenToGameplayEvents.PushBack( resetOnGameplayEvent );
		}
	}
}

