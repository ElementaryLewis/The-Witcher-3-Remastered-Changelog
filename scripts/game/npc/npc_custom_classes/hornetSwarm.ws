/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3HornetSwarm extends CGameplayEntity
{
	editable var damageVal				: SAbilityAttributeValue;
	editable var destroyEntAfter		: float;
	editable var fleeDuration			: float;

	private var m_SlideCmp				: W3SlideToTargetComponent;
	private var victims 				: array<SSwarmVictim>;					
	private var buffParams 				: SCustomEffectParams;
	private var initDistanceToTarget 	: float;
	private var finalDistanceToTarget 	: float;
	private var syncEventName			: name;
	
	private var swarmOwner				: CNewNPC;
	private var damageTriggerArea 		: CTriggerAreaComponent;

		default fleeDuration = 3;
		default destroyEntAfter = 20.0f;
		default syncEventName = 'allowShield';

	event OnSpawned( spawnData : SEntitySpawnData )
	{
		super.OnSpawned(spawnData);

		m_SlideCmp 		= ( W3SlideToTargetComponent ) 	GetComponentByClassName('W3SlideToTargetComponent');
		m_SlideCmp.SetTargetNode( NULL );
		
		damageTriggerArea = (CTriggerAreaComponent)this.GetComponent( "damageArea" );

		PlayEffectSingle( 'bee_cloud' );
		
		AddTimer( 'DestroyWithDeathEffects', destroyEntAfter, false );
	}
	
	function SetSwarmOwner( creator : CNewNPC )
	{
		if ( creator )
			swarmOwner = creator;
	}

	event OnFireHit(source : CGameplayEntity)
	{
		super.OnFireHit(source);
		
		StopEffect('bee_cloud');
		PlayEffect('death_fx');
		PlayEffectSingle( 'bee_fire' );
		AddTimer( 'DestroyEnt', 2.0 );	
	}

	event OnAardHit( source : W3AardProjectile )
	{
		super.OnAardHit( source );
		initDistanceToTarget = VecDistance( GetWorldPosition(), thePlayer.GetWorldPosition() );
		StartFlee();
	}
	
	event OnFrostHit(source : CGameplayEntity)
	{
		super.OnFrostHit(source);
		StopEffect('bee_cloud');
		PlayEffect('death_fx');
		PlayEffectSingle( 'bee_frozen' );
		AddTimer( 'DestroyEnt', 2.0 );	
	}
	
	public function StartFlee()
	{
		Flee();
		AddTimer( 'StopFlee', fleeDuration, false,,,false, true );
	}
	
	public function Flee()
	{
		m_SlideCmp.SetTargetNode( thePlayer );
		m_SlideCmp.SetStopDistance( 16 );
		m_SlideCmp.SetFallBackSpeed( 4 );
		AddTimer( 'CheckWall', 0.2f, false );
	}
	
	private timer function StopFlee( _Dt : float, id : int )
	{
		m_SlideCmp.SetStopDistance( 0 );
		m_SlideCmp.SetFallBackSpeed( 0 );
		m_SlideCmp.SetTargetNode( NULL );
	}
	
	private timer function CheckWall( _Dt : float, id : int )
	{
		finalDistanceToTarget = VecDistance( GetWorldPosition(), thePlayer.GetWorldPosition() );
		if( (finalDistanceToTarget - initDistanceToTarget) <= 1.0f )
			AddTimer( 'DestroyWithDeathEffects', 0.01f, false );
	}
	

	timer function DestroyWithDeathEffects(dt : float, id : int)
	{
		StopEffect('bee_cloud');
		PlayEffect('death_fx');
		
		damageTriggerArea.isEnabled = false;
		RemoveTimer('ApplyEffect');
		
		if(buffParams.buffSpecificParams)
			delete buffParams.buffSpecificParams;
		
		AddTimer('DestroyEnt', 2.0f, false);
	}

	timer function DestroyEnt(dt : float, id : int)
	{
		if(buffParams.buffSpecificParams)
			delete buffParams.buffSpecificParams;
			
		if ( swarmOwner )
			swarmOwner.SignalGameplayEvent( syncEventName );

		Destroy();
	}

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		var swarmVictim : SSwarmVictim;
		var wasVictimBefore : bool;
		var i, cnt : int;

		if(area.GetName() == "damageArea")
		{
			victim = (CActor)activator.GetEntity();

			if( victim )

			{
				wasVictimBefore = false;
				cnt = 0;
				for(i=0; i<victims.Size(); i+=1)
				{
					if(victims[i].actor == victim)
					{
						wasVictimBefore = true;
						victims[i].inTrigger = true;
					}

					if(victims[i].inTrigger)
						cnt += 1;
				}

				if(!wasVictimBefore)
				{
					swarmVictim.actor = victim;
					swarmVictim.timeInSwarm = 0.f;
					swarmVictim.inTrigger = true;
					victims.PushBack( swarmVictim );
					cnt += 1;
				}

				if ( cnt == 1 )
					AddTimer( 'ApplyEffect', 0.1, true );

				return true;
			}
		}
	}

	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var victim : CActor;
		var i : int;
		var empty : bool;

		if(area.GetName() == "damageArea")
		{
			victim = (CActor)activator.GetEntity();
			if(victim)
			{
				for(i=0; i<victims.Size(); i+=1)
				{
					if(victims[i].actor == victim)
					{
						victims[i].inTrigger = false;
						break;
					}
				}

				empty = true;
				for(i=0; i<victims.Size(); i+=1)
				{
					if(victims[i].inTrigger)
					{
						empty = false;
						break;
					}
				}

				if(empty)
					RemoveTimer( 'ApplyEffect' );

				return true;
			}
		}
	}

	timer function ApplyEffect( deltaTime : float , id : int)
	{
		var i : int;
		var specParams : W3BuffDoTParams;
		var damageAction : W3DamageAction;
		var damage : float;

		
		var tempBuffParams : SCustomEffectParams;
		var tempDamageVal : SAbilityAttributeValue;
		

		if(buffParams.effectType == EET_Undefined)
		{
			specParams = new W3BuffDoTParams in this;
			specParams.isEnvironment = true;

			buffParams.vibratePadLowFreq = 0.1;
			buffParams.vibratePadHighFreq = 0.2;
			buffParams.effectType = EET_Swarm;
			buffParams.creator = this;
			buffParams.sourceName = "bee_swarm";
			buffParams.duration = 1;
			buffParams.effectValue = damageVal;
			buffParams.buffSpecificParams = specParams;
		}

		for ( i = 0; i < victims.Size(); i += 1 )
		{
			if(!victims[i].inTrigger)
				continue;

			victims[i].timeInSwarm += deltaTime;

			
			
			if( victims[i].actor != thePlayer && GetAttitudeBetween(victims[i].actor, thePlayer) == AIA_Friendly )
			{
				if( CeilF(victims[i].timeInSwarm) % 15 < 3 && !victims[i].actor.HasBuff(EET_Swarm) )
				{
					tempBuffParams = buffParams;
					tempBuffParams.effectValue = tempDamageVal;
					victims[i].actor.AddEffectCustom(tempBuffParams);
				}
			}
			else 
			if((CPlayer)victims[i].actor || CeilF(victims[i].timeInSwarm) % 15 < 3)
			{
				victims[i].actor.AddEffectCustom(buffParams);
			}
			else
			{
				damageAction = new W3DamageAction in theGame;

				damageAction.Initialize(this, victims[i].actor, NULL, "beeSwarm3Plus", EHRT_None, CPS_Undefined, false, false, false, true);
				damage = deltaTime * ( damageVal.valueAdditive + damageVal.valueMultiplicative * victims[i].actor.GetMaxHealth() );
				damageAction.AddDamage(theGame.params.DAMAGE_NAME_PHYSICAL, damage);
				damageAction.SetIsDoTDamage(deltaTime);
				damageAction.SetIgnoreArmor(true);
				damageAction.SetCanPlayHitParticle(false);
				theGame.damageMgr.ProcessAction( damageAction );

				delete damageAction;
			}
		}
	}
}