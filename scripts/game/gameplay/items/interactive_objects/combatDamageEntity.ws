/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3CombatDamageEntity extends CInteractiveEntity
{
	var victims 	: array< CActor >;
	var victim 		: CActor;
	var isActive	: bool;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		area = (CTriggerAreaComponent)GetComponent( "SpikyRocks" );
		victim = (CActor)activator.GetEntity();
		
		victim.AddEffectDefault(EET_Burning, this, 'environment');
	}
}

statemachine class W3FlammableDamageEntity extends CInteractiveEntity
{
	editable 	var explosionEntity 	: CEntityTemplate;
				var spawnedExplosion 	: CDamageAreaEntity;
	
	var victim 	: CActor;
	var pos		: Vector;
	
	default autoState = 'Untouched';
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		if ( !spawnData.restored )
		{
			GotoStateAuto();
		}
		
	}
		
	function SpawnDamageArea()
	{
		spawnedExplosion = (CDamageAreaEntity)(theGame.CreateEntity( explosionEntity, pos ));
	}
	
	function PlayBurningEffect()
	{
		var burningTime : float;
		
		burningTime = RandRangeF( 80.f, 32.f );
		PlayEffect( 'burning_fx' );
		
		AddTimer( 'TurnOnFireFading', burningTime, , , , true );
	}
	
	timer function TurnOnFireFading( deltaTime : float , id : int)
	{
		PlayEffect( 'smoke_fx' );
		StopEffect( 'burning_fx' );
		spawnedExplosion.Destroy();
	}
}

state Untouched in W3FlammableDamageEntity
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}
	
	event OnFireHit(source : CGameplayEntity)
	{
		parent.OnFireHit(source);
		
		parent.pos = parent.GetWorldPosition();
		
		
		parent.SpawnDamageArea();
		parent.PlayBurningEffect();
		parent.PushState( 'Burnt' );
		parent.GetComponent( "MushroomCollision" ).SetEnabled( false );
	}
}

state Burnt in W3FlammableDamageEntity
{
	event OnStateEnter( prevStateName : name )
	{
		super.OnEnterState( prevStateName );
	}

	event OnFireHit(source : CGameplayEntity)
	{
		parent.OnFireHit(source);
	}
}