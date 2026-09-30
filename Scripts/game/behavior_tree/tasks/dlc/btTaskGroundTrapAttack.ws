/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskGroundTrapAttack extends CBTTaskAttack
{
	public var allowDamageSelf 				: bool;
	public var guaranteeSelfHitChance 		: float;
	public var randomizePosition 			: bool;
	public var guaranteeTargetHitChance 	: float;
	public var guaranteeToHitEntityWithTag 	: float;
	public var entityTag 					: name;
	public var preferTargetsInCameraFrame 	: bool;
	public var navigationSafeSpotRadius 	: float;
	public var minDistFromTarget 			: float;
	public var maxDistFromTarget 			: float;
	public var camShakeStrength 			: float;
	public var activateOnAnimEvent 			: name;
	public var affectEnemiesInRange 		: float;
	public var damageTypeName 				: name;
	public var delayDamage 					: float;
	public var debuffType 					: EEffectType;
	public var raiseEventOnDamageNPC 		: name;
	public var debuffDuration 				: float;
	public var trapResourceName				: name;
	public var playFxOnTrapSpawn			: name;
	public var playFxDamage 				: name;
	public var delayDamageFx 				: float;
	public var playFxOnDamageVictim 		: name;
	public var completeAfterMain 			: bool;
	public var onActivateFromTaskAttack 	: bool;
	
	private var m_trapEntity				: CEntityTemplate;
	private var m_trap						: CGameplayEntity;
	private var m_activated 				: bool;
	private var guaranteedHit 				: bool;
	
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivateFromTaskAttack )
		{
			super.OnActivate();
		}
		return BTNS_Active;
	}
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var npc						: CNewNPC = GetNPC();
		var params 					: SCustomEffectParams;
		var action 					: W3DamageAction;
		var reactToHitEntity		: W3ReactToBeingHitEntity;
		var spawnPos 				: Vector;
		var attributeName 			: name;
		var victims 				: array<CGameplayEntity>;
		var damage 					: float;
		var timeStamp 				: float;
		var res1, res2, res3		: bool;
		var i 						: int;
		
		
		if ( !m_trapEntity )
		{
			m_trapEntity = (CEntityTemplate)LoadResourceAsync( trapResourceName );
		}
		
		if ( !m_trapEntity )
		{
			return BTNS_Failed;
		}
		
		attributeName = GetBasicAttackDamageAttributeName(theGame.params.ATTACK_NAME_LIGHT, theGame.params.DAMAGE_NAME_PHYSICAL);
		damage = CalculateAttributeValue(npc.GetAttributeValue(attributeName));
		
		action = new W3DamageAction in this;
		action.SetHitAnimationPlayType(EAHA_ForceNo);
		
		if ( IsNameValid( activateOnAnimEvent ) )
		{
			while( !m_activated )
			{
				SleepOneFrame();
			}
		}
		else
		{
			m_activated = true;
		}
		
		while ( m_activated )
		{
			if ( timeStamp == 0 )
				timeStamp = GetLocalTime();
			
			SleepOneFrame();
			
			if ( !res3 )
			{
				if ( randomizePosition )
				{
					spawnPos = FindPosition();
					while( !IsPositionValid( spawnPos, guaranteedHit ) )
					{
						SleepOneFrame();
						spawnPos = FindPosition();
					}
					guaranteedHit = false;
				}
				else
				{
					spawnPos = GetCombatTarget().GetWorldPosition();
				}
				m_trap = (CGameplayEntity)theGame.CreateEntity( m_trapEntity, spawnPos, npc.GetWorldRotation() );
				if ( IsNameValid( playFxOnTrapSpawn ) && m_trap )
					m_trap.PlayEffect( playFxOnTrapSpawn );
				
				res3 = true;
			}
			
			if ( ( timeStamp + delayDamageFx ) < GetLocalTime() && !res1 )
			{
				res1 = true;
				
				if ( IsNameValid( playFxDamage ) )
					m_trap.PlayEffect( playFxDamage );
			}
			
			if ( ( timeStamp + delayDamage ) < GetLocalTime() && !res2 )
			{
				victims.Clear();
				FindGameplayEntitiesInRange( victims, m_trap, affectEnemiesInRange, 99 );
				
				if ( camShakeStrength > 0 )
					GCameraShake(camShakeStrength, true, m_trap.GetWorldPosition(), 30.0f);
				
				if ( victims.Size() > 0 )
				{
					for ( i = 0 ; i < victims.Size() ; i += 1 )
					{
						reactToHitEntity = (W3ReactToBeingHitEntity)victims[i];
						if ( reactToHitEntity )
						{
							reactToHitEntity.ActivateEntity();
						}
						if ( ( allowDamageSelf || victims[i] != npc ) && !((CActor)victims[i]).IsCurrentlyDodging() && !((CActor)victims[i]).IsInvulnerable()
							&& ((CActor)victims[i]).GetGameplayVisibility() && ((CActor)victims[i]).IsAlive() )
						{
							if ( debuffType != EET_Undefined )
							{
								params.effectType = debuffType;
								params.creator = m_trap;
								params.sourceName = m_trap.GetName();
								if ( debuffDuration > 0 )
									params.duration = debuffDuration;
								
								((CActor)victims[i]).AddEffectCustom(params);
							}
							
							action.attacker = m_trap;
							action.Initialize( m_trap, victims[i], NULL, m_trap.GetName(), EHRT_None, CPS_Undefined, false, false, false, true);
							action.AddDamage(damageTypeName, damage );
							theGame.damageMgr.ProcessAction( action );
							if ( IsNameValid( playFxOnDamageVictim ) )
							{
								victims[i].PlayEffect( playFxOnDamageVictim );
							}
							if ( IsNameValid( raiseEventOnDamageNPC ) && victims[i] != thePlayer )
							{
								victims[i].RaiseEvent( raiseEventOnDamageNPC );
								((CActor)victims[i]).SignalGameplayEvent( 'CustomHit' );
							}
						}
					}
				}
				
				res2 = true;
				m_activated = false;
			}
		}
		
		victims.Clear();
		delete action;
		if ( completeAfterMain )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Active;
		}
	}
	
	
	
	function OnDeactivate()
	{
		m_trap.DestroyAfter( 5.0 );
		m_trap.StopAllEffects();
		m_activated = false;
		
		super.OnDeactivate();
	}
	
	
	
	final function FindPosition() : Vector
	{
		var randVec 			: Vector = Vector( 0.f, 0.f, 0.f );
		var targetPos 			: Vector;
		var outPos 				: Vector;
		var entities 			: array<CGameplayEntity>;
		var visibleEntities 	: array<CGameplayEntity>;
		var i, j 				: int;
		
		
		if ( RandF() < guaranteeToHitEntityWithTag )
		{
			guaranteedHit = true;
			FindGameplayEntitiesInRange( entities, GetNPC(), 999, 999, entityTag );
			if ( entities.Size() > 0 )
			{
				if ( preferTargetsInCameraFrame )
				{
					for ( i = 0 ; i < entities.Size() ; i += 1 )
					{
						if ( thePlayer.WasVisibleInScaledFrame( entities[i], 1.f, 1.f ) )
						{
							visibleEntities.PushBack( entities[i] );
						}
					}
					if ( visibleEntities.Size() > 0 )
					{
						j = RandRange( visibleEntities.Size() - 1, 0 );
						outPos = visibleEntities[j].GetWorldPosition();
					}
					else
					{
						j = RandRange( entities.Size() - 1, 0 );
						outPos = entities[j].GetWorldPosition();
					}
				}
				else
				{
					j = RandRange( entities.Size() - 1, 0 );
					outPos = entities[j].GetWorldPosition();
				}
			}
			else
			{
				targetPos = GetCombatTarget().GetWorldPosition();
				randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
				outPos = targetPos + randVec;
			}
		}
		else if ( RandF() < guaranteeTargetHitChance )
		{
			guaranteedHit = true;
			outPos = GetCombatTarget().GetWorldPosition();
		}
		else if ( RandF() < guaranteeSelfHitChance )
		{
			guaranteedHit = true;
			outPos = GetActor().GetWorldPosition();
		}
		else
		{
			targetPos = GetCombatTarget().GetWorldPosition();
			randVec = VecRingRand( minDistFromTarget, maxDistFromTarget );
			outPos = targetPos + randVec;
		}
		
		return outPos;
	}
	
	
	
	final function IsPositionValid( out whereTo : Vector, optional guarantee : bool ) : bool
	{
		var newPos 		: Vector;
		var z 		: float;
		var i 		: int;
		
		
		if ( guarantee )
		{
			if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, -1, 1, newPos ) )
			{
				if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
				{
					whereTo.Z = z;
					if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, -1, 1, newPos ) )
						return false;
				}
			}
		}
		else
		{
			if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, navigationSafeSpotRadius, 1, newPos ) )
			{
				if( theGame.GetWorld().NavigationComputeZ( whereTo, whereTo.Z - 5.0, whereTo.Z + 5.0, z ) )
				{
					whereTo.Z = z;
					if( !theGame.GetWorld().NavigationFindSafeSpot( whereTo, navigationSafeSpotRadius, 1, newPos ) )
						return false;
				}
			}
		}
		whereTo = newPos;
		return true;
	}
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == activateOnAnimEvent )
		{
			m_activated = true;	
			return true;
		}
		
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
}




class CBTTaskGroundTrapAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskGroundTrapAttack';
	
	editable var randomizePosition 			: bool;
	editable var allowDamageSelf 			: bool;
	editable var guaranteeSelfHitChance 	: float;
	editable var guaranteeTargetHitChance 	: float;
	editable var guaranteeToHitEntityWithTag: float;
	editable var entityTag 					: name;
	editable var preferTargetsInCameraFrame : bool;
	editable var navigationSafeSpotRadius 	: float;
	editable var minDistFromTarget 			: float;
	editable var maxDistFromTarget 			: float;
	editable var camShakeStrength 			: float;
	editable var activateOnAnimEvent 		: name;
	editable var affectEnemiesInRange 		: float;
	editable var raiseEventOnDamageNPC 		: name;
	editable var damageTypeName 			: name;
	editable var delayDamage 				: float;
	editable var debuffType 				: EEffectType;
	editable var debuffDuration 			: float;
	editable var trapResourceName 			: name;
	editable var playFxOnTrapSpawn			: name;
	editable var playFxDamage 				: name;
	editable var playFxOnDamageVictim 		: name;
	editable var delayDamageFx 				: float;
	editable var completeAfterMain  		: bool;
	editable var onActivateFromTaskAttack 	: bool;
	
	default onActivateFromTaskAttack = true;
	default damageTypeName = 'RendingDamage';
	default navigationSafeSpotRadius = 0.5;
}





class CBTTaskReactionToCustomHit extends CBTTaskPlayAnimationEventDecorator
{
	public var raiseEventName 					: name;
	public var waitTimeout 						: float;
	public var activationTimeout 				: float;
	
	private var timeStamp 						: float;
	private var receivedEvent 					: bool;
	private var isInCorrectBehGraphNode 		: bool;
	private var activationScriptEvent 			: name;
	private var deactivateScriptEvent 			: name;
	
	default activationScriptEvent 				= 'CustomHitStart';
	default deactivateScriptEvent 				= 'CustomHitEnd';
	
	function Initialize()
	{
		GetNPC().ActivateSignalBehaviorGraphNotification( activationScriptEvent );		
		GetNPC().ActivateSignalBehaviorGraphNotification( deactivateScriptEvent );		
	}	
	
	function IsAvailable() : bool
	{
		if ( receivedEvent && GetLocalTime() < timeStamp + activationTimeout )
		{
			return true;
		}
		
		return false;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var res : bool;
		
		if ( IsNameValid( raiseEventName ) )
		{
			GetNPC().RaiseForceEvent( raiseEventName );
		}
		while ( true )
		{
			if ( ( GetLocalTime() >= timeStamp + 0.5 && !isInCorrectBehGraphNode ) || GetLocalTime() >= timeStamp + waitTimeout )
			{
				return BTNS_Completed;
			}
			SleepOneFrame();
		}
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		receivedEvent = false;
		isInCorrectBehGraphNode = false;
	}
	
	function OnListenedGameplayEvent( eventName: CName ) : bool
	{
		if( eventName == 'CustomHit' )
		{
			receivedEvent = true;
			timeStamp = GetLocalTime();
		}
		else if ( eventName == 'ReflectDamageEntityHit' )
		{
			receivedEvent = true;
			timeStamp = GetLocalTime();
		}
		else if( eventName == deactivateScriptEvent )
		{
			isInCorrectBehGraphNode = false;
		}
		else if( eventName == activationScriptEvent )
		{
			isInCorrectBehGraphNode = true;
		}
		
		return true;
	}	
}

class CBTTaskReactionToCustomHitDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass 							= 'CBTTaskReactionToCustomHit';
	
	editable var raiseEventName 					: name;
	editable var waitTimeout 						: float;
	editable var activationTimeout 					: float;
	
	private var activationScriptEvent 				: name;
	private var deactivateScriptEvent 				: name;
	
	default waitTimeout 							= 5.0f;
	default activationTimeout 						= 1.0f;
	default activationScriptEvent 					= 'CustomHitStart';
	default deactivateScriptEvent 					= 'CustomHitStartEnd';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'CustomHit' );
		listenToGameplayEvents.PushBack( 'ReflectDamageEntityHit' );
		listenToGameplayEvents.PushBack( activationScriptEvent );
		listenToGameplayEvents.PushBack( deactivateScriptEvent );
	}
}