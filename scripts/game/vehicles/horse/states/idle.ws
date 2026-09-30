/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Idle in W3HorseComponent
{
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
		parent.InternalSetSpeedMultiplier( 1 );
	}

	event OnLeaveState( nextStateName : name )
	{ 
		super.OnLeaveState( nextStateName );
	}
	
	event OnMountStarted( entity : CEntity, vehicleSlot : EVehicleSlot )
	{
		parent.OnMountStarted( entity, vehicleSlot );
		
		
		if ( entity == thePlayer && parent.useEarlyExploration )
		{
			parent.PushState( 'Exploration' );
		}
	}
	
	event OnMountFinished( entity : CEntity )
	{
		parent.OnMountFinished( entity );
		
		
		if ( entity == thePlayer )
		{
			parent.PushState( 'Exploration' );
		}
	}
	
	event OnTick( dt : float )
	{
		if ( parent.ShouldTickInIdle() )
			parent.OnTick( dt );
	}
}