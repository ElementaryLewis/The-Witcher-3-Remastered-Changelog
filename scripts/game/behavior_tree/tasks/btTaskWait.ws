/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWait extends IBehTreeTask
{
	var Delay : float;
	
	latent function Main() : EBTNodeStatus
	{	
		Sleep(Delay);
		return BTNS_Completed;
	}

}

class CBTTaskWaitDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskWait';

	editable var Delay : float;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'OnStopHorse' );
	}
}


class CBTTaskForceWait extends IBehTreeTask
{
	var available : bool;
	default available = false;
	
	var Delay : float;
	var Event : name;
	
	function IsAvailable() : bool
	{
		if (available)
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate()
	{
		GetActor().ActionCancelAll();
	}
	
	function OnDeactivate()
	{
		available = false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var time : float;
		GetActor().WaitForBehaviorNodeDeactivation('OnAnimIdleActivated', 10.0f );
		time = GetLocalTime();
		while ( time + Delay > GetLocalTime() )
		{
			Sleep(0.01);
		}
		return BTNS_Completed;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == Event )
		{
			available = true;
			return true;
		}
		if ( eventName == 'CalmDown' || eventName == 'ForceIdle' )
		{
			GetActor().RaiseForceEvent('ForceIdle');
		}
		if ( eventName == 'Stop' )
		{
			available = true;
		}
		return false;
	}
}

class CBTTaskForceWaitDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskForceWait';

	editable var Delay : float;
	editable var Event : name;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		
		listenToGameplayEvents.PushBack( 'ForceIdle' );
		if ( IsNameValid( Event ) )
		{
			listenToGameplayEvents.PushBack( Event );
		}
	}
}