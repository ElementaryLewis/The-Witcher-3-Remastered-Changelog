/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCollisionMonitor extends CBTTaskPlayAnimationEventDecorator
{
	public var onActivate 						: bool;
	public var onAnimEvent 						: bool;
	public var dealDamage						: bool;
	public var soundEventOnCollidedActor 		: name;
	public var destroyObstacleOnCollision 		: bool;
	public var raiseEventOnObstacleCollision 	: name;
	public var chargeType						: EChargeAttackType;
	public var forceCriticalEffect 				: bool;
	public var forceCriticalEffectNpcOnly 		: bool;
	public var completeOnCollisionWithObstacle 	: bool;
	public var unavailableForOneFrameOnInterval : float;
	
	private var bCollisionWithActor 			: bool;
	private var bCollisionWithObstacle 			: bool;
	private var bCollisionWithObstacleProbe 	: bool;
	private var activated						: bool;
	private var xmlDamageName					: name;
	private var collidedActor 					: CActor;
	private var collidedEntity					: CGameplayEntity;
	private var collidedProbedEntity			: CGameplayEntity;
	private var activationTimeStamp 			: float;
	private var actorCollisionTimeStamp 		: float;
	private var objectCollisionTimeStamp 		: float;
	private var objectProbeCollisionTimeStamp 	: float;
	private var intervalCheckTimeStamp			: float;
	private var hadForceCriticalStates 			: bool; 
	
	default bCollisionWithActor 				= false;
	default bCollisionWithObstacle 				= false;
	default bCollisionWithObstacleProbe 		= false;
	
	
	function IsAvailable() : bool
	{
		if ( completeOnCollisionWithObstacle )
		{
			if ( unavailableForOneFrameOnInterval > 0 && ( bCollisionWithObstacle || bCollisionWithObstacleProbe ) 
				&& GetLocalTime() > intervalCheckTimeStamp + unavailableForOneFrameOnInterval )
			{
				intervalCheckTimeStamp = GetLocalTime();
				return false;
			}
			else if ( GetLocalTime() < objectCollisionTimeStamp + 0.5 )
			{
				return false;
			}
		}
		
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			activated = true;
		}
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		while( true )
		{
			if ( activated && GetLocalTime() > activationTimeStamp )
			{
				activated = false;
			}
			
			if ( bCollisionWithObstacle && GetLocalTime() > objectCollisionTimeStamp + 0.5 )
			{
				collidedProbedEntity = NULL;
				collidedEntity = NULL;
				bCollisionWithObstacle = false;
			}
			if ( bCollisionWithObstacleProbe && GetLocalTime() > objectProbeCollisionTimeStamp + 0.5 )
			{
				bCollisionWithObstacleProbe = false;
			}
			
			if ( bCollisionWithActor && GetLocalTime() > actorCollisionTimeStamp + 0.5 )
			{
				collidedActor = NULL;
				bCollisionWithActor = false;
			}
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		super.OnDeactivate();
		
		bCollisionWithActor = false;
		bCollisionWithObstacle = false;
		collidedActor = NULL;
		activated = false;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 					: CNewNPC = GetNPC();
		var damageAction 			: W3DamageAction;
		var action					: W3Action_Attack;
		var tempEntity				: CGameplayEntity;
		var damage 					: float;
		var attackName				: name;
		var skillName				: name;
		var params					: SCustomEffectParams;
		var components 				: array<CComponent>;
		var destructionComponent 	: CDestructionComponent;
		var i 						: int;
		
		
		if ( ( activated || completeOnCollisionWithObstacle ) && !bCollisionWithObstacle && eventName == 'CollisionWithObstacleProbe' )
		{
			bCollisionWithObstacleProbe = true;
			objectProbeCollisionTimeStamp = GetLocalTime();
			tempEntity = (CGameplayEntity)GetEventParamObject();
			if ( tempEntity )
			{
				collidedProbedEntity = tempEntity;
			}
			
			if ( completeOnCollisionWithObstacle )
			{
				if ( unavailableForOneFrameOnInterval > 0 )
				{
					if ( GetLocalTime() > intervalCheckTimeStamp + unavailableForOneFrameOnInterval )
					{
						intervalCheckTimeStamp = GetLocalTime();
						Complete( false ); 
					}
				}
				else
				{
					Complete( false ); 
				}
			}
			
			return true;
		}
		else if ( ( activated || completeOnCollisionWithObstacle ) && !bCollisionWithObstacle && eventName == 'CollisionWithObstacle' )
		{
			bCollisionWithObstacle = true;
			objectCollisionTimeStamp = GetLocalTime();
			collidedEntity = (CGameplayEntity)GetEventParamObject();
			
			if ( !collidedEntity )
			{
				collidedEntity = collidedProbedEntity;
			}
			
			
			if ( destroyObstacleOnCollision )
			{
				if( collidedEntity )
				{
					components = collidedEntity.GetComponentsByClassName( 'CDestructionComponent' );
					if( components.Size() > 0 )
					{
						for ( i = 0 ; i < components.Size() ; i += 1 )
						{
							destructionComponent = (CDestructionComponent) components[i];
							destructionComponent.ApplyFracture();
						}
					}
				}
			}
			
			if ( IsNameValid( raiseEventOnObstacleCollision ) )
			{
				npc.RaiseEvent( raiseEventOnObstacleCollision );
				npc.SignalGameplayEvent( 'ReactionToCollision' );
			}
			
			if ( completeOnCollisionWithObstacle )
			{
				Complete( false ); 
			}
			
			return true;
		}
		else if ( activated && !bCollisionWithActor && eventName == 'CollisionWithActor' )
		{
			collidedActor = (CActor)GetEventParamObject();
			if ( IsRequiredAttitudeBetween( npc, collidedActor, true ) )
			{
				if ( IsNameValid( soundEventOnCollidedActor ) )
				{
					collidedActor.SoundEvent( soundEventOnCollidedActor );
				}
				actorCollisionTimeStamp = GetLocalTime();
				bCollisionWithActor = true;
				if ( !dealDamage )
				{
					if( chargeType == ECAT_Knockdown )
						params.effectType = EET_KnockdownTypeApplicator;
					else if( chargeType == ECAT_Stagger )
						params.effectType = EET_Stagger;
					
					if( params.effectType != EET_Undefined )
					{
						params.creator = npc;
						params.duration = 0.5;
						
						if ( forceCriticalEffectNpcOnly )
						{
							if ( npc.HasAbility( 'ForceCriticalEffectsAnimNPCOnly' ) )
							{
								hadForceCriticalStates = true;
							}
							else
							{
								npc.AddAbility( 'ForceCriticalEffectsAnimNPCOnly' );
							}
						}
						else if ( forceCriticalEffect )
						{
							if ( npc.HasAbility( 'ForceCriticalEffectsAnim' ) )
							{
								hadForceCriticalStates = true;
							}
							else
							{
								npc.AddAbility( 'ForceCriticalEffectsAnim' );
							}
						}
						collidedActor.AddEffectCustom( params );
						if ( forceCriticalEffectNpcOnly && !hadForceCriticalStates )
						{
							npc.RemoveAbility( 'ForceCriticalEffectsAnimNPCOnly' );
						}
						else if ( forceCriticalEffect && !hadForceCriticalStates )
						{
							npc.RemoveAbility( 'ForceCriticalEffectsAnim' );
						}
					}				
				}
				else
				{
					action = new W3Action_Attack in theGame.damageMgr;
					
					switch ( chargeType )
					{
						case ECAT_Knockdown:
							skillName = 'attack_super_heavy';
							attackName = 'attack_super_heavy';
							break;
						case ECAT_Stagger:
							skillName = 'attack_stagger';
							attackName = 'attack_stagger';
							break;
					}
					
					if ( forceCriticalEffectNpcOnly )
					{
						if ( npc.HasAbility( 'ForceCriticalEffectsAnimNPCOnly' ) )
						{
							hadForceCriticalStates = true;
						}
						else
						{
							npc.AddAbility( 'ForceCriticalEffectsAnimNPCOnly' );
						}
					}
					else if ( forceCriticalEffect )
					{
						if ( npc.HasAbility( 'ForceCriticalEffectsAnim' ) )
						{
							hadForceCriticalStates = true;
						}
						else
						{
							npc.AddAbility( 'ForceCriticalEffectsAnim' );
						}
					}
					
					action.Init( npc, collidedActor, NULL, npc.GetInventory().GetItemFromSlot( 'r_weapon' ), attackName, npc.GetName(), EHRT_None, false, false, skillName, AST_Jab, ASD_UpDown, true, false, false, false );
					theGame.damageMgr.ProcessAction( action );
					
					if ( forceCriticalEffectNpcOnly && !hadForceCriticalStates )
					{
						npc.RemoveAbility( 'ForceCriticalEffectsAnimNPCOnly' );
					}
					else if ( forceCriticalEffect && !hadForceCriticalStates )
					{
						npc.RemoveAbility( 'ForceCriticalEffectsAnim' );
					}
					
					delete action;
				}
			}
			return true;
		}
		
		
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType,animInfo);
		
		if ( onAnimEvent )
		{
			if ( animEventName == 'attackStart' || ( animEventName == 'Knockdown' && animEventType == AET_Duration )
			|| ( animEventName == 'Stagger' && animEventType == AET_Duration ) )
			{
				activationTimeStamp = GetLocalTime();
				activated = true;
				return true;
			}
			
		}
		
		return res;
	}
}

class CBTTaskCollisionMonitorDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass 						= 'CBTTaskCollisionMonitor';
	
	editable var onActivate 					: bool;
	editable var onAnimEvent 					: bool;
	editable var dealDamage 					: bool;
	editable var destroyObstacleOnCollision 	: bool;
	editable var chargeType 					: EChargeAttackType;
	editable var forceCriticalEffect 			: bool;
	editable var forceCriticalEffectNpcOnly 	: bool;
	editable var raiseEventOnObstacleCollision 	: name;
	editable var soundEventOnCollidedActor 		: name;
	editable var completeOnCollisionWithObstacle: bool;
	editable var unavailableForOneFrameOnInterval: float;
	
	default onActivate 							= true;
	default raiseEventOnObstacleCollision 		= 'AttackFail';
	default dealDamage 							= true;
	default chargeType 							= ECAT_Knockdown;
	default destroyObstacleOnCollision 			= true;
	default soundEventOnCollidedActor 			= 'sharley_roll_hit_add';
	default forceCriticalEffect 				= true;
}





class CBTTaskReactionToCollision extends CBTTaskCollisionMonitor
{
	
	public var waitTimeout 						: float;
	public var activationTimeout 				: float;
	public var knockdownDuration 				: float;
	
	private var timeStamp 						: float;
	private var receivedEvent 					: bool;
	private var isInCorrectBehGraphNode 		: bool;
	private var activationScriptEvent 			: name;
	private var deactivateScriptEvent 			: name;
	
	default activationScriptEvent 				= 'ReactionToCollisionStart';
	default deactivateScriptEvent 				= 'ReactionToCollisionEnd';
	
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
	
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().SetBehaviorVariable( 'AttackEnd', 0.0, true );
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var res : bool;
		
		while ( true )
		{
			if ( GetLocalTime() >= timeStamp + knockdownDuration  && !res )
			{
				GetNPC().SetBehaviorVariable( 'AttackEnd', 1.0, true );
				res = true;
			}
			if ( ( GetLocalTime() >= timeStamp + 1.0 && !isInCorrectBehGraphNode ) || GetLocalTime() >= timeStamp + waitTimeout )
			{
				return BTNS_Completed;
			}
			SleepOneFrame();
		}
		
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetBehaviorVariable( 'AttackEnd', 1.0, true );
		receivedEvent = false;
		isInCorrectBehGraphNode = false;
	}
	
	function OnListenedGameplayEvent( eventName: CName ) : bool
	{
		if( eventName == 'ReactionToCollision' )
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

class CBTTaskReactionToCollisionDef extends CBTTaskCollisionMonitorDef
{
	default instanceClass 							= 'CBTTaskReactionToCollision';
	
	
	editable var waitTimeout 						: float;
	editable var activationTimeout 					: float;
	editable var knockdownDuration 					: float;
	
	private var activationScriptEvent 				: name;
	private var deactivateScriptEvent 				: name;
	
	
	default waitTimeout 							= 5.0f;
	default activationTimeout 						= 1.0f;
	default knockdownDuration 						= 2.0f;
	default activationScriptEvent 					= 'ReactionToCollisionStart';
	default deactivateScriptEvent 					= 'ReactionToCollisionEnd';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'ReactionToCollision' );
		listenToGameplayEvents.PushBack( activationScriptEvent );
		listenToGameplayEvents.PushBack( deactivateScriptEvent );
	}
}