/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SafeModeTrigger extends CGameplayEntity
{
	editable var enable : bool;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		thePlayer.EnableMode( PM_Safe, enable );
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		
		
	}		
}

class W3PlayerModeTrigger extends CGameplayEntity
{
	editable saved var isEnabled			: bool;
	var isActive							: bool;
	var isPlayerInside						: bool;
	editable var playerMode					: EPlayerMode;
	
	default isEnabled						= true;
	default isActive						= false;
	default isPlayerInside					= false;
	default playerMode						= PM_Safe;
	
	private function Activate()
	{
		if ( isActive )
		{
			return;
		}
		isActive = true;
		if ( playerMode == PM_Safe )
		{
			thePlayer.EnableMode( PM_Safe, true );
		}
		else if ( playerMode == PM_Combat )
		{
			thePlayer.GetPlayerMode().ForceCombatMode( FCMR_Trigger );
		}
	}
	private function Deactivate()
	{
		if( !isActive )
		{
			return;
		}
		isActive = false;
		if ( playerMode == PM_Safe )
		{
			thePlayer.EnableMode( PM_Safe, false );
		}
		else if ( playerMode == PM_Combat )
		{
			thePlayer.GetPlayerMode().ReleaseForceCombatMode( FCMR_Trigger );
		}
	}
	

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		isPlayerInside = true;
		if ( isEnabled )
		{
			Activate();
		}
	}	
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{	
		isPlayerInside = false;
		Deactivate();
	}
	
	function Enable( e : bool )
	{
		if ( e != isEnabled )
		{
			isEnabled = e;
			if ( e )
			{
				if ( isPlayerInside )
				{
					Activate();
				}
			}
			else
			{
				Deactivate();
			}
		}
	}
};

quest function EnablePlayerModeTrigger( triggerTag : name, enable : bool )
{
	var entities	: array<CEntity>;
	var trigger		: W3PlayerModeTrigger;
	var i, size 	: int;

	theGame.GetEntitiesByTag( triggerTag, entities );
	size = entities.Size();
	
	for ( i = 0; i < size; i += 1 )
	{
		trigger = (W3PlayerModeTrigger)entities[i];		
		if ( trigger )
		{
			trigger.Enable( enable );
		}
	}
}