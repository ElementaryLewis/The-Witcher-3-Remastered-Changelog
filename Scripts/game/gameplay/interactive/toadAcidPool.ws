/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CToadAcidPool extends CInteractiveEntity
{
	editable var poisonDamage		: SAbilityAttributeValue;
	editable var fxOnSpawn			: name;
	editable var immunityFact  		: string;
	editable var despawnTimer		: float;
	editable var damageVal			: float;
	editable var explosionRange		: float;
	editable var destroyTimer		: float;
	
	var settled 	: bool;
	var victim 		: CActor;
	var victims 	: array< CActor >;
	var poisonArea 	: CTriggerAreaComponent;
	var buffParams 	: SCustomEffectParams;
	var damage : W3DamageAction;
	var entitiesInRange : array< CGameplayEntity >;
	var targetEntity : CActor;
	var fxStartTime		: float;
	private var hasExploded : bool;

	
	default fxOnSpawn = 'toxic_gas';
	default despawnTimer = 5.0;
	default destroyTimer = 0.1;
	default fxStartTime = 0.5;
	default hasExploded = false;
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		poisonArea = (CTriggerAreaComponent)GetComponent( 'PoisonArea' );	
		Enable( true );
	}
	
	final function Enable( flag : bool )
	{
		PlayEffect( fxOnSpawn );
		AddTimer( 'EnablePoison', fxStartTime );
		Spawn( flag );
	}
	
	final function Spawn( flag : bool )
	{
		if( flag ) 
		{
			AddTimer( 'Despawn', despawnTimer, );
		}
		else
		{
			StopEffect( fxOnSpawn );
		}
	}
	

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		if( ( FactsQuerySum( immunityFact ) > 0 ) && ( activator.GetEntity() == thePlayer ) )
			return false;
		
		victim = (CActor)activator.GetEntity();	
		if ( victim )
		{
			victims.PushBack( victim );
			
			if ( victims.Size() == 1 )
			{	
				if( buffParams.effectType == EET_Undefined )
				{						
					buffParams.effectType = EET_Poison;
					buffParams.creator = this;
					buffParams.creator = this;
					buffParams.duration = 1.0;
					buffParams.effectValue = poisonDamage;
					buffParams.sourceName = "ToadAcidPool";
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
	
	
	timer function PoisonVictim( deltaTime : float , id : int)
	{
		var i : int;
		for ( i = 0; i < victims.Size(); i += 1 )
			victims[i].AddEffectCustom( buffParams );
	}
	
		
	timer function Despawn( deltaTime : float , id : int)
	{
		poisonArea.SetEnabled( false );
		this.StopAllEffects();
		this.DestroyAfter(2.0);
	}

	timer function EnablePoison( deltaTime : float , id : int)
	{
		if( poisonArea ) 
		{
			poisonArea.SetEnabled( true );
		}
	}
	
	event OnAardHit( sign : W3AardProjectile )
	{
		poisonArea.SetEnabled( false );
		AddTimer( 'Despawn', destroyTimer );
	}
	
	event OnFireHit( source : CGameplayEntity )
	{
		
		var i : int;
		
		
		if(! hasExploded)
		{
			hasExploded = true;
			
			StopAllEffects();
			PlayEffect( 'toxic_gas_explosion' );
			GCameraShake( 1.5, true, GetWorldPosition(), 20.0f );
			
			
			if ( thePlayer.IsCameraLockedToTarget() && thePlayer.GetDisplayTarget() == this )
			{
				thePlayer.OnForceSelectLockTarget();
			}
			
			FindGameplayEntitiesInSphere(entitiesInRange, this.GetWorldPosition(), explosionRange, 10);		
			entitiesInRange.Remove(this);
			for( i = 0; i < entitiesInRange.Size(); i += 1 )
			{
				targetEntity = (CActor)entitiesInRange[i];
				
				if(targetEntity)
				{
					damage = new W3DamageAction in this;
					damage.Initialize( this, entitiesInRange[i], NULL, this, EHRT_None, CPS_Undefined, false, false, false, true );
					if ( targetEntity == GetWitcherPlayer() )
						damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal * (int)GetWitcherPlayer().GetLevel() );
					else
						damage.AddDamage( theGame.params.DAMAGE_NAME_FIRE, damageVal * (int)CalculateAttributeValue(targetEntity.GetAttributeValue('level',,true)) );
					damage.AddEffectInfo(EET_KnockdownTypeApplicator);
					damage.SetProcessBuffsIfNoDamage(true);
					theGame.damageMgr.ProcessAction( damage );
					
					delete damage;
				}
				else
				{
					entitiesInRange[i].OnFireHit(this);
				}
			}
			
			super.OnFireHit(source);
			RemoveTimer( 'PoisonVictim' );
			this.StopEffect(fxOnSpawn);
			this.DestroyAfter(3.f);
			
		}
	}
}