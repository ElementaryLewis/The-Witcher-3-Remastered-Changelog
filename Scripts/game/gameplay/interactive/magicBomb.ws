/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CMagicBombEntity extends CGameplayEntity
{
	editable var damageRadius		: float;
	editable var damageVal			: float;
	
	var settlingTime		: float;
	
	var entitiesInRange : array<CGameplayEntity>;
	var i : int;
	var damage : W3DamageAction;
	var victim : CActor;
	
	default damageRadius = 3;
	default damageVal = 50;
	default settlingTime = 2.5;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		Init();
	}
	
	function Init()
	{
		PlayEffect( 'arcane_circle' );
		AddTimer( 'Explode', settlingTime, , , , true );
	}
	
	timer function Explode( td : float , id : int)
	{
		StopAllEffects();
		Explosion();
	}

	function Explosion()
	{
		PlayEffect( 'explosion' );
		GCameraShake( 0.5, true, this.GetWorldPosition(), 15.0f );
		
		entitiesInRange.Clear();
		FindGameplayEntitiesInRange( entitiesInRange, this, damageRadius, 99 );
		for( i = 0; i < entitiesInRange.Size(); i += 1 )
		{
			victim = (CActor)entitiesInRange[i];
			if( victim )
			{
				victim.AddEffectDefault( EET_Stagger, this, this.GetName() );
			}
			
			damage = new W3DamageAction in this;
			damage.Initialize( this, entitiesInRange[i], this, this.GetName(), EHRT_None, CPS_Undefined, false, false, false, true );
			damage.AddDamage( theGame.params.DAMAGE_NAME_ELEMENTAL, damageVal );
			theGame.damageMgr.ProcessAction( damage );
			delete damage;
		}
	}
}

class CPhilippaAttractorTrigger extends CGameplayEntity
{
	editable var actorTagToSendInfo : name;
	editable var triggeredByPlayer : bool;
	editable var triggeredByBolts : bool;
	editable var triggeredByBombs : bool;
	var actor : CActor;
	var lastActivation : float;
	
	default actorTagToSendInfo = 'Philippa';
	default triggeredByPlayer = true;
	default triggeredByBolts = true;
	default triggeredByBombs = true;
	
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( lastActivation + 1.0 > theGame.GetEngineTimeAsSeconds() )
		{
			return false;
		}
		
		if( activator.GetEntity() == thePlayer && triggeredByPlayer )
		{
			actor = theGame.GetActorByTag( actorTagToSendInfo );
			actor.SignalGameplayEvent( 'shootAtPlayer' );
			lastActivation = theGame.GetEngineTimeAsSeconds(); 
		}
		else if( (W3BoltProjectile)activator.GetEntity() && triggeredByBolts )
		{
			actor = theGame.GetActorByTag( actorTagToSendInfo );
			actor.SignalGameplayEventParamObject( 'shootAtPoint', this );
			lastActivation = theGame.GetEngineTimeAsSeconds(); 
		}
		else if( (W3Petard)activator.GetEntity() && triggeredByBombs )
		{
			actor = theGame.GetActorByTag( actorTagToSendInfo );
			actor.SignalGameplayEventParamObject( 'shootAtPoint', this );
			lastActivation = theGame.GetEngineTimeAsSeconds(); 
		}
	}
}
