/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3WitchBoilingWaterObstacle extends W3DurationObstacle
{
	
	
	
	private editable var		applyDebuffType					: EEffectType;	default applyDebuffType = EET_Undefined;
	private editable var		debuffDuration					: float;		default debuffDuration = 0.2;
	private editable var		simpleDamageAction				: bool;			default simpleDamageAction = true;
	private editable var 		damageValue 					: float; 		default damageValue = 100;
	private editable var 		allowDmgValueOverrideFromXML	: bool; 		default allowDmgValueOverrideFromXML = true;
	private editable var		attackDelay						: float;		default attackDelay = 1.667f;
	private editable var		attackRadius					: float;		default attackRadius = 1;
	private editable var		increaseRadiusDelta				: float;
	private editable var		ignoreVictimWithTag				: name; 
	private editable var		preAttackEffectName				: name;
	private editable var		attackEffectName				: name;
	private editable var		hitReactionType					: EHitReactionType;	default hitReactionType = EHRT_Heavy;
	private editable var		loopedAttack					: bool;
	private editable var 		playAttackEffectOnlyWhenHit 	: bool;
	private editable var		useSeperateAttackEffectEntity 	: CEntityTemplate;
	private editable var 		onAttackEffectCameraShakeStrength: float;
	private editable var 		onHitCameraShakeStrength 		: float;
	
	private			 var 		fxEntity 						: CEntity;
	private 		 var		summoner						: CActor;
	private			 var		params 							: SCustomEffectParams;
	private			 var		effectComponent					: CComponent;
	
	
	
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{	
		super.OnSpawned( spawnData );
		
		effectComponent = GetComponentByClassName( 'CEffectDummyComponent' );
		
		if ( IsNameValid(preAttackEffectName) )
		{
			PlayEffect(preAttackEffectName);
		}
		
		AddTimer( 'Appear', attackDelay, loopedAttack );
		if ( increaseRadiusDelta > 0 )
		{
			AddTimer( 'ScaleEffect', 0.01f, true );
		}
	}
	
	
	private timer function Appear( _Delta : float, optional id : int)
	{
		var i						: int;
		var l_entitiesInRange		: array <CGameplayEntity>;
		var l_damage				: W3DamageAction;
		var l_action 				: W3Action_Attack; 
		var l_actor					: CActor;
		var none					: SAbilityAttributeValue;
		var l_tempBool				: bool;
		
		if ( !l_tempBool )
		{
			if ( !SetParams() ) return;
			l_tempBool = true;
		}
		
		if ( IsNameValid(attackEffectName) && !playAttackEffectOnlyWhenHit )
		{
			if ( useSeperateAttackEffectEntity )
			{
				fxEntity = theGame.CreateEntity( useSeperateAttackEffectEntity, this.GetWorldPosition(), this.GetWorldRotation() );
				fxEntity.PlayEffect(attackEffectName);
				fxEntity.DestroyAfter( 5.0 );
			}
			else
			{
				PlayEffect(attackEffectName);
			}
			
			if ( onAttackEffectCameraShakeStrength > 0 )
			{
				GCameraShake( onAttackEffectCameraShakeStrength, true, l_actor.GetWorldPosition(), 30.0f );
			}
		}
		
		FindGameplayEntitiesInRange( l_entitiesInRange, this, attackRadius, 1000);
		
		for	( i = 0; i < l_entitiesInRange.Size(); i += 1 )
		{
			l_actor = (CActor) l_entitiesInRange[i];
			if ( !l_actor ) continue;
			
			if ( l_actor == summoner ) continue;
			
			if ( IsNameValid( ignoreVictimWithTag ) && l_actor.HasTag( ignoreVictimWithTag ) ) continue;
			
			if ( !l_actor.IsCurrentlyDodging() )
			{
				
				if( damageValue < 101 && !summoner.HasTag( 'q111_witch' ) )
				{
					if ( simpleDamageAction )
					{
						l_action = new W3Action_Attack in theGame.damageMgr;
						
						l_action.Init( (CGameplayEntity)summoner, l_actor, NULL, ((CGameplayEntity)summoner).GetInventory().GetItemFromSlot( 'r_weapon' ), 'attack_heavy', ((CGameplayEntity)summoner).GetName(), EHRT_Heavy, false, true, 'attack_heavy', AST_Jab, ASD_DownUp, false, false, false, true );
						l_action.GetDamageValueTotal();
						theGame.damageMgr.ProcessAction( l_action );
						
						if ( onHitCameraShakeStrength > 0 )
							GCameraShake( onHitCameraShakeStrength, true, l_actor.GetWorldPosition(), 30.0f );
						
						delete l_action;
					}
					if ( applyDebuffType != EET_Undefined )
					{
						l_actor.AddEffectCustom(params);
					}
					
					if ( IsNameValid(attackEffectName) && playAttackEffectOnlyWhenHit )
					{
						if ( useSeperateAttackEffectEntity )
						{
							fxEntity = theGame.CreateEntity( useSeperateAttackEffectEntity, l_actor.GetWorldPosition(), l_actor.GetWorldRotation() );
							fxEntity.PlayEffect(attackEffectName);
							fxEntity.DestroyAfter( 5.0 );
						}
						else
						{
							PlayEffect(attackEffectName);
						}
					}
					
				} 
				else if ( damageValue > 0 )
				{
					if ( simpleDamageAction )
					{
						l_damage = new W3DamageAction in this;
						l_damage.Initialize( summoner, l_actor, summoner, summoner.GetName(), hitReactionType, CPS_Undefined, false, false, false, true );
						l_damage.AddDamage( theGame.params.DAMAGE_NAME_PHYSICAL, damageValue );
						theGame.damageMgr.ProcessAction( l_damage );
						delete l_damage;
						
						if ( onHitCameraShakeStrength > 0 )
							GCameraShake( onHitCameraShakeStrength, true, l_actor.GetWorldPosition(), 30.0f );
					}
					if ( applyDebuffType != EET_Undefined )
					{
						l_actor.AddEffectCustom(params);
					}
					
					if ( IsNameValid(attackEffectName) && playAttackEffectOnlyWhenHit )
					{
						if ( useSeperateAttackEffectEntity )
						{
							fxEntity = theGame.CreateEntity( useSeperateAttackEffectEntity, l_actor.GetWorldPosition(), l_actor.GetWorldRotation() );
							fxEntity.PlayEffect(attackEffectName);
							fxEntity.DestroyAfter( 5.0 );
						}
						else
						{
							PlayEffect(attackEffectName);
						}
					}
				}
			}
		}
	}
	
	function SetParams() : bool
	{
		var l_dm 					: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var l_summonedEntityComp 	: W3SummonedEntityComponent;	
		var l_dmg_min, l_dmg_max	: SAbilityAttributeValue;
		
		l_summonedEntityComp = (W3SummonedEntityComponent) GetComponentByClassName('W3SummonedEntityComponent');
		
		if( !l_summonedEntityComp )
		{
			return false;
		}
		
		summoner = l_summonedEntityComp.GetSummoner();
		
		if ( allowDmgValueOverrideFromXML )
		{
			l_dm.GetAbilityAttributeValue('environment_DamageStats', 'witch_boiling_water', l_dmg_min, l_dmg_max);
			if ( (l_dmg_max.valueBase * l_dmg_max.valueMultiplicative) > 0 )
			{
				damageValue = l_dmg_max.valueBase * l_dmg_max.valueMultiplicative;
			}
		}
		else
		{
			l_dmg_max.valueAdditive = damageValue;
		}
		
		if ( applyDebuffType != EET_Undefined )
		{
			params.effectType = applyDebuffType;
			params.sourceName = 'witch_boiling_water';
			params.duration 	= debuffDuration;
			params.effectValue = l_dmg_max;
			params.customFXName = 'bla';
		}
		return true;
	}
	
	timer function ScaleEffect( deltaTime : float , id : int)
	{
		var l_currentScaleRate 	: float;
		var l_scaleVector			: Vector;
		
		attackRadius += increaseRadiusDelta * deltaTime;
		l_currentScaleRate += increaseRadiusDelta * deltaTime;
		l_scaleVector.X = l_currentScaleRate;
		l_scaleVector.Y = l_currentScaleRate;
		l_scaleVector.Z = l_currentScaleRate;
		effectComponent.SetScale( l_scaleVector );
	}
	
	private function SpecificDisappear()
	{
		
		damageValue = 0;
	}
}