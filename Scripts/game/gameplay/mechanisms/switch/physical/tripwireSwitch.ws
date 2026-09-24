/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3TripwireSwitch extends W3PhysicalSwitch
{
	protected editable	var	autoSwitchOnLeave		: bool;				default autoSwitchOnLeave = true;
	protected 			var entities				: array< CEntity >;
	protected			var delayedTurnOffEntity	: CEntity;
	protected			var delayedTurnOnEntity		: CEntity;
	protected editable 	var connectedTrapClueTag	: name;

	hint autoSwitchOnLeave = "If true then leaving the trigger will flip the switch";
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		if ( !entities.Contains( entity ) )
		{
			entities.PushBack( entity );
		}
		LogChannel( 'pressure', "OnAreaEnter " + entity.GetName() );

		TurnOnIfPossible( entity );
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var entity : CEntity;
		
		entity = activator.GetEntity();
		entities.Remove( entity );

		LogChannel( 'pressure', "OnAreaExit " + entity.GetName() );

		TurnOffIfPossible( entity );
	}
	
	
	event OnAardHit( sign : W3AardProjectile )
	{
			var entity : CEntity;
		
		entity = thePlayer;
		if ( !entities.Contains( entity ) )
		{
			entities.PushBack( entity );
		}
		LogChannel( 'pressure', "OnAardHitStart " + entity.GetName() );

		TurnOnIfPossible( entity );
		
		entities.Remove( entity );

		LogChannel( 'pressure', "OnAardHitStop " + entity.GetName() );

		TurnOffIfPossible( entity );
	}
	
	timer function OnCheckInventoryEntities( delta : float , id : int)
	{
		var i, size : int;
		var entity : CEntity;
		var inventory : CInventoryComponent;
		
		size = entities.Size();
		for ( i = 0; i < size; )
		{
			entity = entities[ i ];
			
			
			if ( (W3ActorRemains)entity )
			{
				
				inventory = (CInventoryComponent)entity.GetComponentByClassName( 'CInventoryComponent' );
				if ( inventory )
				{
					if ( inventory.IsEmpty() )
					{
						
						entities.Remove( entity );
						TurnOffIfPossible( NULL );
						continue;
					}
				}
			}
			i += 1;
		}
	}
	
	function TurnOnIfPossible( entity : CEntity )
	{
		var connectedTrapClue : CEntity;
		
		if ( IsAvailable() )
		{
			if ( IsOff() )
			{
				LogChannel( 'pressure', "turning on" );
				Turn( true, (CActor)entity, false, false );
				this.PlayEffect('trap_sprung');
				this.ApplyAppearance('sprung');
				
				connectedTrapClue = theGame.GetEntityByTag(connectedTrapClueTag);
				if (connectedTrapClue) connectedTrapClue.Destroy();
				
				AddTimer( 'OnCheckInventoryEntities', 0.2f, true, , , true );
				
				
				RemoveTimer( 'OnDelayedTurnOff' );
				RemoveTimer( 'OnDelayedTurnOn' );
			}
			else if ( IsSwitchingOff() )
			{
				LogChannel( 'pressure', "turning on delayed" );
				delayedTurnOnEntity = entity;
				AddTimer( 'OnDelayedTurnOn', 0.2f, , , , true );
			}
		}
	}
	
	function TurnOffIfPossible( entity : CEntity )
	{
		if ( ( entities.Size() == 0 ) && autoSwitchOnLeave && IsAvailable() )
		{
			if ( IsOn() )
			{
				
				
				LogChannel( 'pressure', "turning off" );
				Turn( false, (CActor)entity, false, false );
			
				RemoveTimer( 'OnCheckInventoryEntities' );

				RemoveTimer( 'OnDelayedTurnOff' );
				RemoveTimer( 'OnDelayedTurnOn' );
			}
			else if ( IsSwitchingOn() )
			{
				
				
				LogChannel( 'pressure', "turning off delayed" );
				delayedTurnOffEntity = entity;
				AddTimer( 'OnDelayedTurnOff', 0.2f, , , , true );
			}
		}
	}
	
	timer function OnDelayedTurnOn( delta : float , id : int)
	{
		LogChannel( 'pressure', "timer OnDelayedTurnOn" );
		TurnOnIfPossible( delayedTurnOnEntity );
	}

	timer function OnDelayedTurnOff( delta : float , id : int)
	{
		LogChannel( 'pressure', "timer OnDelayedTurnOff" );
		TurnOffIfPossible( delayedTurnOffEntity );
	}
	
	public function Disarm()
	{
		this.Enable(false);
		this.ApplyAppearance('sprung');
	}
}
