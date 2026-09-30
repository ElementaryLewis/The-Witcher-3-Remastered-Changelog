/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CDettlaffColumn extends CNewNPC
{
	var numberOfHits 						: int;
	var destroyCalled						: bool;
	var foundEntity							: CEntity;
	var construct							: CActor;
	var summonedComp						: W3SummonedEntityComponent;
	var percLife							: float;
	var chunkLife							: float;
	var lastHitTimestamp					: float;
	var testedHitTimestamp					: float;
	
	editable var requiredHits				: int;
	editable var timeBetweenHits			: float;
	editable var timeBetweenFireDamage		: float;
	editable var effectOnTakeDamage			: name;
	editable var timeToDestroy				: float;

	default destroyCalled = false;
	default timeBetweenHits = 0.5f;
	default timeBetweenFireDamage = 1.0f;
	default requiredHits = 10;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		SetAppearance('alive');
		summonedComp = (W3SummonedEntityComponent) this.GetComponentByClassName('W3SummonedEntityComponent');
		foundEntity = theGame.GetEntityByTag( 'dettlaff_arena' );
		thePlayer.OnBecomeAwareAndCanAttack( this );
	}
	
	function CheckHitsCounter()
	{
		if( numberOfHits >= requiredHits )
		{
			if( !destroyCalled )
			{
				DestroyEntity();
			}
		}
	}
	
	function AddHit()
	{
		lastHitTimestamp = theGame.GetEngineTimeAsSeconds();
		numberOfHits+=1;
		foundEntity.PlayEffect( 'hit' );
		construct.SignalGameplayEvent( 'column_hit');
		construct = theGame.GetActorByTag('dettlaff_construct');
		PlayEffect( 'hit' );
		percLife = (100/requiredHits)*0.01;	
		chunkLife = ( GetStatMax( BCS_Essence ) )* percLife;
		ForceSetStat( BCS_Essence, ( GetStat( BCS_Essence ) - chunkLife ));
		
		CheckHitsCounter();
	}
	
	function RemoveHit()
	{
		numberOfHits-=1;
		CheckHitsCounter();
	}
	
	function DestroyEntity()
	{
		destroyCalled = true;
		FactsAdd("ColumnDeath",1);
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{
		testedHitTimestamp = theGame.GetEngineTimeAsSeconds();
		if( action.attacker == thePlayer && action.DealsAnyDamage() && ( testedHitTimestamp > lastHitTimestamp + timeBetweenHits ) && !action.HasDealtFireDamage() )
		{
			AddHit();
		}
		else if( action.attacker == thePlayer && action.DealsAnyDamage() && ( testedHitTimestamp > lastHitTimestamp + timeBetweenFireDamage ) && action.HasDealtFireDamage())
		{
			AddHit();
			PlayEffectSingle('critical_burning');
			AddTimer('StopBurningFX', 2.0f, false );
		}
		
		if( destroyCalled )
		{
			super.OnTakeDamage(action);
		}
	}
	
	timer function StopBurningFX(dt : float, id : int)
	{
		StopEffect('critical_burning');
	}
	
	
	event OnDeath( damageAction : W3DamageAction  )
	{
		summonedComp.OnDeath();
		PlayEffect( 'dying_out' );
		AddTimer('DeadAppearance', 0.0f, false);
		RemoveTag( 'arena_support' );
		thePlayer.OnBecomeUnawareOrCannotAttack( this );
	}
	
	function StartPumping()
	{
		PlayEffect( 'pumping' );
	}
	
	function StopPumping()
	{
		StopEffect( 'pumping' );
	}
	
	timer function DeadAppearance(delta : float , id : int)
	{
		PlayEffect('boom');
		SetAppearance('dead');
	}

}
class CDettlaffConstruct extends CNewNPC
{
	var numberOfHits 						: int;
	var destroyCalled						: bool;
	var percLife							: float;
	var chunkLife							: float;
	var healthBarPerc						: float;
	var lastHitTimestamp					: float;
	var testedHitTimestamp					: float;
	var l_temp								: float;
	
	editable var timeBetweenHits			: float;
	editable var timeBetweenFireDamage		: float;
	editable var baseStat					: EBaseCharacterStats;
	editable var requiredHits				: int;
	editable var effectOnTakeDamage			: name;
	editable var timeToDestroy				: float;

	default destroyCalled = false;
	default timeBetweenHits = 0.5f;
	default timeBetweenFireDamage = 1.0f;
	default baseStat = BCS_Vitality;
	default requiredHits = 10;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned( spawnData );
		SoundSwitch( "dettlaff_monster", "dettlaff_construct", 'Head' );
		requiredHits = 5;
	}
	
	function AddHit()
	{
		lastHitTimestamp = theGame.GetEngineTimeAsSeconds();
		numberOfHits+=1;
		RaiseEvent('AdditiveHit');
		SoundEvent("cmd_heavy_hit");
		percLife = (100/requiredHits)*0.01;	
		chunkLife = ( GetStatMax( BCS_Essence ) )* percLife;
		ForceSetStat( BCS_Essence, ( GetStat( BCS_Essence ) - chunkLife ));
		CheckHitsCounter();
	}
	
	function CheckHitsCounter()
	{
		if( numberOfHits >= requiredHits )
		{
			if( !destroyCalled )
			{
				DestroyEntity();
			}
		}
	}
	
	function DestroyEntity()
	{
		destroyCalled = true;
	}
	
	event OnTakeDamage( action : W3DamageAction )
	{	
		testedHitTimestamp = theGame.GetEngineTimeAsSeconds();
		if( action.attacker == thePlayer && action.DealsAnyDamage() && ( testedHitTimestamp > lastHitTimestamp + timeBetweenHits ) && !action.HasDealtFireDamage() )
		{
			AddHit();
		}
		else if( action.attacker == thePlayer && action.DealsAnyDamage() && ( testedHitTimestamp > lastHitTimestamp + timeBetweenFireDamage ) && action.HasDealtFireDamage())
		{
			AddHit();
			PlayEffectSingle('critical_burning');
			AddTimer('StopBurningFX', 2.0f, false );
		}
		
		if( destroyCalled )
		{
			numberOfHits = 0;
			destroyCalled = false;
			OnDeath(action);
		}
	}
	
	timer function StopBurningFX(dt : float, id : int)
	{
		StopEffect('critical_burning');
	}
}
