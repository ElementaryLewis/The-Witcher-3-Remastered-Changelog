/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CPopsGasEntity extends CInteractiveEntity
{
	editable var restorationTime	: float;
	editable var settlingTime		: float;
	editable var fxOnSpawn			: name;
	editable var immunityFact  		: string;
	
	var i : int;
	var settled : bool;
	var victim : CActor;
	var victims : array< CActor >;
	var poisonArea : CTriggerAreaComponent;
	var buffParams : SCustomEffectParams;
	
	default restorationTime = 5.0;
	default settlingTime = 2.0;
	default fxOnSpawn = 'toxic_gas';
	default settled = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		poisonArea = (CTriggerAreaComponent)GetComponent( 'PoisonArea' );	
		Enable( bIsEnabled );
	}
	
	final function Enable( flag : bool )
	{
		if( poisonArea ) 
		{
			poisonArea.SetEnabled( flag );
		}
		Spawn( flag );
	}
	
	final function Spawn( flag : bool )
	{
		if( flag ) 
		{
			PlayEffect( fxOnSpawn );
			AddTimer( 'Settle', settlingTime );
		}
		else
		{
			StopEffect( fxOnSpawn );
			RemoveTimer( 'Settle' );
		}
	}
	
	timer function Settle( deltaTime : float , id : int)
	{
		settled = true;
		if( poisonArea ) 
		{
			poisonArea.SetEnabled( true );
		}
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( ( FactsQuerySum( immunityFact ) > 0 ) && ( activator.GetEntity() == thePlayer ) )
			return false;
		
		victim = (CActor)activator.GetEntity();	
		if ( victim )
		{
			if( (CR4Player)victim )
			{
				victim.PlayVoiceset( 100, "coughing" );
			}
			victims.PushBack( victim );
			
			if ( victims.Size() == 1 )
			{	
				if( buffParams.effectType == EET_Undefined )
				{						
					buffParams.effectType = EET_PoisonCritical;
					buffParams.creator = this;
					buffParams.duration = 1.0;
					
					buffParams.sourceName = "PopsGasAffliction";
				}
				AddTimer( 'PoisonVictim', 0.1, true );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		victim = (CActor)activator.GetEntity();
		if ( victim && victims.Contains( victim ) )
		{
			victims.Remove( victim );
			if ( victims.Size() == 0 )
				RemoveTimer( 'PoisonVictim' );
		}
	}
	
	timer function Restore( deltaTime : float , id : int)
	{
		Spawn( bIsEnabled );
	}
	
	timer function PoisonVictim( deltaTime : float , id : int)
	{
		var i : int;
		for ( i = 0; i < victims.Size(); i += 1 )
			victims[i].AddEffectCustom( buffParams );
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		if( bIsEnabled && settled )
		{
			settled = false;
			if( poisonArea ) 
			{
				poisonArea.SetEnabled( false );
			}
			victims.Clear();
			StopAllEffects();
			AddTimer( 'Restore', restorationTime, , , , true );
		}
	}
}