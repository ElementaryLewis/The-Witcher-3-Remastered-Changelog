/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskAttack extends CBTTaskPlayAnimationEventDecorator
{
	var attackType										: EAttackType;
	var stopTaskAfterDealingDmg 						: bool;
	var setAttackEndVarOnStopTask						: bool;
	var useDirectionalAttacks 							: bool;
	var fxOnDamageInstigated 							: name;
	var fxOnDamageVictim								: name;
	var soundEventOnDamageInstigated					: name;
	var soundEventOnDamageVictim						: name;
	var applyFXCooldown									: float;
	var behVarNameOnDeactivation 						: name;
	var behVarValueOnDeactivation 						: float;
	var stopAllEfectsOnDeactivation 					: bool;
	
	
	var slideToTargetOnAnimEvent 						: bool;
	var slideToTargetMaximumDistance 					: float;
	var useCombatTarget 								: bool;
	var applyEffectType									: EEffectType; 
	var applyEffectTypeArray							: array<EEffectType>;
	var customEffectDuration							: float;
	var customEffectValue								: float;
	var customEffectPercentValue						: float;
	var applyEffectInAttackRange 						: name;
	var hitDestructablesInAttackRange 					: bool;
	var useActionBlend 									: bool;
	var stopTaskOnCustomItemCollision 					: bool;
	var spawnSparksFxOnCustomItemCollision 				: name;
	var resourceNameOfSparksFxEntity 					: name;
	var unavailableWhenInvisibleTarget 					: bool;
	
	private var effectCooldown 							: float;
	public var stopTask 								: bool;
	public var fxTimeCooldown							: float;
	public var damageInstigatedEventReceived 			: bool;
	public var hitActionReactionEventReceived 			: bool;
	public var hitTimeStamp 							: float;
	
	default stopTask 									= false;
	default spawnSparksFxOnCustomItemCollision 			= 'fx';
	
	private var extractedMotionDisabled					: bool;
	
	function IsAvailable() : bool
	{
		var target : CActor = GetCombatTarget();
		
		if ( unavailableWhenInvisibleTarget && target && !target.GetGameplayVisibility() )
		{
			return false;
		}
		
		return super.IsAvailable();
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var target : CNode;
		var targetToAttackerAngle : float;
		var npcToTargetDist : float;
		var minDistance : float;
		var actorTarget : CActor;
		var humanCombatDataStorage : CHumanAICombatStorage;
		
		extractedMotionDisabled = false;
		
		if( useCombatTarget )
			target = GetCombatTarget();
		else
			target = GetActionTarget();
		
		npc.SetBehaviorVariable( 'AttackType', (int)attackType, true );
		
		if ( setAttackEndVarOnStopTask )
			npc.SetBehaviorVariable( 'AttackEnd', 0 );
		
		
		( (CActor) target ).SetUnpushableTarget( npc );
		npc.SetUnpushableTarget( (CActor) target );
		
		if ( useDirectionalAttacks )
		{
			targetToAttackerAngle = NodeToNodeAngleDistance( target, npc );
			
			npc.SetBehaviorVariable( 'targetAngleDiff', targetToAttackerAngle/180, true);
			
			if( targetToAttackerAngle >= -180.0 && targetToAttackerAngle < -157.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m180, true );
			}
			if( targetToAttackerAngle >= -157.5 && targetToAttackerAngle < -112.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m135, true );
			}
			if( targetToAttackerAngle >= -112.5 && targetToAttackerAngle < -67.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m90, true );
			}
			else if( targetToAttackerAngle >= -67.5 && targetToAttackerAngle < -22.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_m45, true );
			}
			else if( targetToAttackerAngle >= -22.5 && targetToAttackerAngle < 22.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_0, true );
			}
			else if( targetToAttackerAngle >= 22.5 && targetToAttackerAngle < 67.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_45, true );
			}
			else if( targetToAttackerAngle >= 67.5 && targetToAttackerAngle < 112.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_90, true );
			}
			else if( targetToAttackerAngle >= 112.5 && targetToAttackerAngle < 157.5 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_135, true );
			}
			else if( targetToAttackerAngle >= 157.5 && targetToAttackerAngle < 180.0 )
			{
				
				npc.SetBehaviorVariable( 'targetDirection', (int)ETD_Direction_180, true );
			}
			
		}
		
		humanCombatDataStorage = (CHumanAICombatStorage)combatDataStorage;
		
		if( humanCombatDataStorage && humanCombatDataStorage.GetActiveCombatStyle() == EBG_Combat_Fists )
		{
			actorTarget = (CActor)target;
			if( actorTarget )
			{
				npcToTargetDist = VecDistanceSquared2D( npc.GetWorldPosition(), actorTarget.GetWorldPosition() );
				minDistance = ((CMovingPhysicalAgentComponent)npc.GetMovingAgentComponent()).GetCapsuleRadius()+((CMovingPhysicalAgentComponent)actorTarget.GetMovingAgentComponent()).GetCapsuleRadius();
				
				minDistance += 0.05;
				
				if( npcToTargetDist <= ( minDistance * minDistance ) )
				{
					npc.GetMovingAgentComponent().SetUseExtractedMotion( false );
					extractedMotionDisabled = true;
				}
			}
		}
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var startTime 	: float = GetLocalTime();
		
		
		while ( startTime + 0.15 > GetLocalTime() ) 
		{	
			SleepOneFrame();
		}
		combatDataStorage.SetIsAttacking( true, GetLocalTime() );
		
		((CPlayer)GetCombatTarget()).SetPlayerUnderAttack( true ); 
		
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( GetActor(), 'NpcAttackAction', 10.0, 15.0f, -1, -1, true); 
		
		return BTNS_Active;
	}
	
	function OnDeactivate() 
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		
		combatDataStorage.SetIsAttacking( false );
		
		((CPlayer)GetCombatTarget()).SetPlayerUnderAttack( false ); 
		
		
		target.SetUnpushableTarget( NULL );
		npc.SetUnpushableTarget( NULL );
		
		
		if( extractedMotionDisabled )
		{
			npc.GetMovingAgentComponent().SetUseExtractedMotion( true );
		}
		
		
		if ( thePlayer.GetDodgeFeedbackTarget() == npc )
			npc.SetDodgeFeedback( false );		
		
		
		
		if ( behVarNameOnDeactivation )
		{
			npc.SetBehaviorVariable( behVarNameOnDeactivation, behVarValueOnDeactivation, true );
		}
		
		if ( stopAllEfectsOnDeactivation )
		{
			npc.StopAllEffects();
		}
		
		stopTask = false;
		
		super.OnDeactivate();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var movingAgent			: CMovingAgentComponent;
		var target 				: CActor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var movementAdjustor	: CMovementAdjustor;
		var minDistance			: float;
		var maxDistance 		: float;
		
		if ( animEventName == 'SlideToTarget' && slideToTargetOnAnimEvent && !extractedMotionDisabled && ( animEventType == AET_DurationStart || animEventType == AET_DurationStartInTheMiddle ))
		{
			movingAgent = GetActor().GetMovingAgentComponent();
			target = GetCombatTarget();
			movementAdjustor = movingAgent.GetMovementAdjustor();
			
			if ( movementAdjustor )
			{
				movementAdjustor.CancelByName( 'SlideToTarget' );
				ticket = movementAdjustor.CreateNewRequest( 'SlideToTarget' );
				movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
				
				movementAdjustor.MaxLocationAdjustmentSpeed( ticket, 1000.0f );
				movementAdjustor.ScaleAnimation( ticket, false, true, false );
				
				
				minDistance = 0.0f;
				maxDistance = ClampF( slideToTargetMaximumDistance, minDistance, slideToTargetMaximumDistance );
				movementAdjustor.SlideTowards( ticket, target, minDistance, maxDistance );
			}
			return true;
		}
		else if ( ( stopTask && animEventName == 'AllowBlend' ) || ( useActionBlend && animEventName == 'ActionBlend') )
		{
			GetNPC().RaiseEvent('AnimEndAUX');
			Complete(true);
			return true;
		}
		
		return super.OnAnimEvent(animEventName, animEventType, animInfo);
	}
	
	function EventDamageInstigated()
	{
		var npc 					: CNewNPC = GetNPC();
		var entities 				: array<CGameplayEntity>;
		var i						: int;
		var destructionComponent 	: CDestructionComponent;
		var victim 					: CActor;
		
		
		hitActionReactionEventReceived = false;
		damageInstigatedEventReceived = false;
		
		if ( ( GetLocalTime() > effectCooldown ) && IsNameValid( applyEffectInAttackRange ) )
		{
			npc.GatherEntitiesInAttackRange( entities, applyEffectInAttackRange );
			effectCooldown = GetLocalTime() + 0.5;
			
			if ( entities.Size() > 0 )
			{
				if ( IsNameValid( applyEffectInAttackRange ) )
				{
					for ( i = 0 ; i<entities.Size() ; i+=1 )
					{
						if ( (CActor)entities[i] && GetAttitudeBetween( npc, entities[i] ) == AIA_Hostile )
						{
							ApplyCriticalEffectOnTarget( (CActor)entities[i] );
						}
					}
				}
				if ( hitDestructablesInAttackRange )
				{
					for ( i = 0 ; i<entities.Size() ; i+=1 )
					{
						destructionComponent = (CDestructionComponent) entities[i].GetComponentByClassName( 'CDestructionComponent' );
						if( destructionComponent )
						{
							destructionComponent.ApplyFracture();
						}
					}
				}
			}
		}
		
		if ( !IsNameValid( applyEffectInAttackRange ) )
		{
			victim = (CActor)GetEventParamObject();
			if ( victim )
			{
				ApplyCriticalEffectOnTarget( victim );
			}
			else
			{
				ApplyCriticalEffectOnTarget();
			}
		}
		
		if ( IsNameValid( fxOnDamageInstigated ) && ( GetLocalTime() > fxTimeCooldown ))
		{
			fxTimeCooldown = GetLocalTime() + applyFXCooldown;
			npc.PlayEffect(fxOnDamageInstigated);
		}
		if ( IsNameValid( fxOnDamageVictim ) || IsNameValid( soundEventOnDamageVictim ) && ( GetLocalTime() > fxTimeCooldown ))
		{
			fxTimeCooldown = GetLocalTime() + applyFXCooldown;
			GetCombatTarget().PlayEffect( fxOnDamageVictim );
			GetCombatTarget().SoundEvent( soundEventOnDamageVictim );
		}
		if ( stopTaskAfterDealingDmg )
		{
			if ( setAttackEndVarOnStopTask )
				npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
			stopTask = true;
		}
	}
	
	function EventStopTaskOnCustomItemCollision()
	{
		var npc						: CNewNPC = GetNPC();
		var weaponEntity 			: CEntity;
		var weaponTipPosition 		: Vector;
		var weaponSlotMatrix 		: Matrix;
		var weaponId				: SItemUniqueId;
		var sparksEntity  			: CEntity;
		
		npc.RaiseEvent( 'AnimEndAUX' );
		if ( IsNameValid( spawnSparksFxOnCustomItemCollision ) )
		{
			weaponId = npc.GetInventory().GetItemFromSlot( 'r_weapon' );
			weaponEntity = npc.GetInventory().GetItemEntityUnsafe( weaponId ); 
			weaponEntity.CalcEntitySlotMatrix( spawnSparksFxOnCustomItemCollision, weaponSlotMatrix );
			weaponTipPosition = MatrixGetTranslation( weaponSlotMatrix );
			sparksEntity = theGame.CreateEntity( (CEntityTemplate)LoadResource( resourceNameOfSparksFxEntity ), weaponTipPosition );
			sparksEntity.PlayEffect( 'sparks' );
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var damageData: W3DamageAction;
		
		if ( eventName == 'HitActionReaction' )
		{
			hitActionReactionEventReceived = true;
			if ( hitActionReactionEventReceived && damageInstigatedEventReceived && GetLocalTime() < hitTimeStamp + 0.5 )
			{
				EventDamageInstigated();
			}
			hitTimeStamp = GetLocalTime();
			return true;
		}
		else if ( eventName == 'DamageInstigated' )
		{
			damageData = ( W3DamageAction ) GetEventParamObject();
			if ( !damageData.IsDoTDamage() )
			{
				damageInstigatedEventReceived = true;
				if ( hitActionReactionEventReceived && damageInstigatedEventReceived && GetLocalTime() < hitTimeStamp + 0.5 )
				{
					EventDamageInstigated();
				}
				hitTimeStamp = GetLocalTime();
			}
			return true;
		}
		else if ( eventName == 'AxiiGuardMeAdded' )
		{
			GetNPC().RaiseEvent('AnimEndAUX');
			Complete(true);
			return true;
		}
		else if ( eventName == 'StopTaskOnCustomItemCollision' && stopTaskOnCustomItemCollision )
		{
			EventStopTaskOnCustomItemCollision();
			Complete( true );
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
	
	function ApplyCriticalEffectOnTarget( optional actor : CActor )
	{
		var npc 	: CNewNPC = GetNPC();
		var target 	: CActor = GetCombatTarget();
		var params 	: SCustomEffectParams;
		var i 		: int;
		
		
		params.creator = npc;
		params.sourceName = npc.GetName();
		
		if ( customEffectDuration > 0 )
		{
			params.duration = customEffectDuration;
		}
		if ( customEffectValue > 0 )
		{
			params.effectValue.valueAdditive = customEffectValue;
		}
		if ( customEffectPercentValue > 0 )
		{
			params.effectValue.valueMultiplicative = customEffectPercentValue;
		}
		if ( applyEffectTypeArray.Size() > 0 )
		{
			for ( i=0 ; i<applyEffectTypeArray.Size() ; i+=1 )
			{
				if ( applyEffectTypeArray[i] != EET_Undefined )
				{
					params.effectType = applyEffectTypeArray[i];
					if ( actor )
					{
						if ( applyEffectTypeArray[i] != EET_Drunkenness || ( applyEffectTypeArray[i] == EET_Drunkenness && actor == thePlayer ) )
						{
							actor.AddEffectCustom( params );
						}
					}
					else
					{
						if ( applyEffectTypeArray[i] != EET_Drunkenness || ( applyEffectTypeArray[i] == EET_Drunkenness && target == thePlayer ) )
						{
							target.AddEffectCustom( params );
						}
					}
				}
			}
		}
		else if ( applyEffectType != EET_Undefined )
		{
			params.effectType = applyEffectType;
			if ( actor )
			{
				if ( applyEffectType != EET_Drunkenness || ( applyEffectType == EET_Drunkenness && actor == thePlayer ) )
				{
					actor.AddEffectCustom( params );
				}
			}
			else
			{
				if ( applyEffectType != EET_Drunkenness || ( applyEffectType == EET_Drunkenness && actor == thePlayer ) )
				{
					target.AddEffectCustom( params );
				}
			}
		}
	}
};

class CBTTaskAttackDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskAttack';
	
	editable var attackType										: EAttackType;
	editable var stopTaskAfterDealingDmg						: bool;
	editable var setAttackEndVarOnStopTask						: bool;
	editable var useDirectionalAttacks 							: bool;
	editable var fxOnDamageInstigated 							: name;
	editable var fxOnDamageVictim								: name;
	editable var soundEventOnDamageInstigated					: name;
	editable var soundEventOnDamageVictim						: name;
	editable var applyFXCooldown								: float;
	editable var behVarNameOnDeactivation 						: name;
	editable var behVarValueOnDeactivation 						: float;	
	editable var stopAllEfectsOnDeactivation 					: bool;
	
	editable var slideToTargetOnAnimEvent 						: bool;
	editable var slideToTargetMaximumDistance 					: float; 
	editable var useCombatTarget 								: bool;
	editable var useActionBlend 								: bool;
	editable var attackParameter								: CBehTreeValInt;
	editable var applyEffectInAttackRange 						: name;
	editable var hitDestructablesInAttackRange 					: bool;
	editable var applyEffectType								: EEffectType;
	editable var applyEffectTypeArray 							: array<EEffectType>;
	editable var stopTaskOnCustomItemCollision 					: bool;
	editable var spawnSparksFxOnCustomItemCollision 			: name;
	editable var resourceNameOfSparksFxEntity 					: name;
	editable var customEffectDuration							: float;
	editable var customEffectValue								: float;
	editable var customEffectPercentValue						: float;
	editable var unavailableWhenInvisibleTarget 				: bool;
	
	default attackType 											= EAT_Attack1;
	default stopTaskAfterDealingDmg 							= false;
	default useDirectionalAttacks 								= false;
	default stopAllEfectsOnDeactivation 						= false;
	default slideToTargetOnAnimEvent 							= true;
	default useCombatTarget 									= true;
	default useActionBlend 										= false;
	default customEffectDuration								= -1;
	default slideToTargetMaximumDistance 						= 10000;
	default spawnSparksFxOnCustomItemCollision 					= 'fx';
	default resourceNameOfSparksFxEntity 						= 'sword_colision_fx';
	default unavailableWhenInvisibleTarget 						= true;
	
	hint spawnSparksFxOnCustomItemCollision = "name of the slot on item to spawn fx entity";
	
	function OnSpawn( task : IBehTreeTask )
	{
		var thisTask : CBTTaskAttack; 
		
		thisTask = (CBTTaskAttack)task;
		
		if( attackType ==  EAT_None && GetValInt( attackParameter ) >= 0 )
		{
			thisTask.attackType	= GetValInt( attackParameter );
		}
	}
};
