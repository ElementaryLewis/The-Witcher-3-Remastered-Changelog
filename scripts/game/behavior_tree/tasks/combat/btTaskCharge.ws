/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCharge extends CBTTaskAttack
{
	public var raiseEventOnActivation 			: name;
	public var raiseEventOnObstacleCollision 	: name;
	public var handleCollisionWithObstacle 		: bool;
	public var checkLineOfSight					: bool;
	public var dealDamage						: bool;
	public var endTaskWhenOwnerGoesPastTarget 	: bool;
	public var chargeType						: EChargeAttackType;
	public var forceCriticalEffect 				: bool;
	public var forceCriticalEffectNpcOnly 		: bool;
	
	private var bCollisionWithActor 			: bool;
	private var bCollisionWithObstacle 			: bool;
	private var activated						: bool;
	private var xmlDamageName					: name;
	private var collidedActor 					: CActor;
	private var collidedEntity					: CGameplayEntity;
	private var collidedProbedEntity			: CGameplayEntity;
	private var hadForceCriticalStates 			: bool; 
	
	default bCollisionWithActor 				= false;
	default bCollisionWithObstacle 				= false;
	
	
	function IsAvailable() : bool
	{
		if( !checkLineOfSight )
		{ 
			return super.IsAvailable() ;
		}		
		if ( theGame.GetWorld().NavigationLineTest(GetActor().GetWorldPosition(), GetCombatTarget().GetWorldPosition(), GetActor().GetRadius()) )
		{
			return super.IsAvailable();
		}
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( IsNameValid( raiseEventOnActivation ) )
		{
			GetNPC().RaiseEvent( raiseEventOnActivation );
		} 
		
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var dotProduct 					: float;
		var npc 						: CNewNPC;
		var target						: CActor;
		var targetPos					: Vector;
		var npcPos						: Vector;
		var startPos					: Vector;
		
		npc.SetBehaviorVariable( 'AttackEnd', 0 );
		
		if ( endTaskWhenOwnerGoesPastTarget )
		{
			npc = GetNPC();
			target = GetCombatTarget();
			startPos = npc.GetWorldPosition();
			dotProduct = 0;
			
			while ( dotProduct >= 0.0f )
			{
				Sleep( 0.25 );
				npcPos		= npc.GetWorldPosition();
				targetPos 	= target.GetWorldPosition();
				dotProduct 	= VecDot( targetPos - startPos, targetPos - npcPos );
			}
			
			npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
			return BTNS_Completed;
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
		var tempEntity 				: CGameplayEntity;
		var damage 					: float;
		var attackName				: name;
		var skillName				: name;
		var params					: SCustomEffectParams;
		var components 				: array<CComponent>;
		var destructionComponent 	: CDestructionComponent;
		var i 						: int;
		
		
		if ( activated && !bCollisionWithObstacle && eventName == 'CollisionWithObstacleProbe' )
		{
			tempEntity = (CGameplayEntity)GetEventParamObject();
			if ( tempEntity )
			{
				collidedProbedEntity = tempEntity;
			}
			
			return true;
		}
		else if ( activated && !bCollisionWithObstacle && eventName == 'CollisionWithObstacle' )
		{
			bCollisionWithObstacle = true;
			collidedEntity = (CGameplayEntity)GetEventParamObject();
			
			if ( !collidedEntity )
			{
				collidedEntity = collidedProbedEntity;
			}
			
			
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
			
			if ( IsNameValid( raiseEventOnObstacleCollision ) )
			{
				npc.RaiseEvent( raiseEventOnObstacleCollision );
				npc.SignalGameplayEvent( 'ReactionToCollision' );
			}
			
			return true;
		}
		else if ( activated && !bCollisionWithActor && eventName == 'CollisionWithActor' )
		{
			collidedActor = (CActor)GetEventParamObject();
			if ( IsRequiredAttitudeBetween(npc,collidedActor,true) )
			{				
				bCollisionWithActor = true;
				if ( !dealDamage )
				{
					if(chargeType == ECAT_Knockdown)
						params.effectType = EET_KnockdownTypeApplicator;
					else if(chargeType == ECAT_Stagger)
						params.effectType = EET_Stagger;
					
					if(params.effectType != EET_Undefined)
					{
						params.creator = npc;
						params.duration = 0.5;
						
						collidedActor.AddEffectCustom(params);
					}				
				}
				else
				{
					
					action = new W3Action_Attack in theGame.damageMgr;
					
					switch (chargeType)
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
					
					action.Init( npc, collidedActor, NULL, npc.GetInventory().GetItemFromSlot( 'r_weapon' ), attackName, npc.GetName(), EHRT_None, false, true, skillName, AST_Jab, ASD_UpDown, true, false, false, false );
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
		
		return super.OnGameplayEvent( eventName );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var res : bool;
		
		res = super.OnAnimEvent(animEventName,animEventType,animInfo);
		
		if ( animEventName == 'attackStart' || ( animEventName == 'Knockdown' && animEventType == AET_DurationStart )
		|| ( animEventName == 'Stagger' && animEventType == AET_DurationStart ) )
		{
			activated = true;
			return true;
		}
		else if ( ( animEventName == 'Knockdown' && animEventType == AET_DurationEnd ) 
			   || ( animEventName == 'Stagger' && animEventType == AET_DurationEnd ) )
		{
			activated = false;
			return true;
		}
		
		return res;
	}
}

class CBTTaskChargeDef extends CBTTaskAttackDef
{
	default instanceClass 						= 'CBTTaskCharge';
	
	editable var raiseEventOnActivation 		: name;
	editable var raiseEventOnObstacleCollision 	: name;
	editable var handleCollisionWithObstacle 	: bool;
	editable var checkLineOfSight				: bool;
	editable var dealDamage 					: bool;
	editable var endTaskWhenOwnerGoesPastTarget	: bool;
	editable var chargeType 					: EChargeAttackType;
	editable var forceCriticalEffect 			: bool;
	editable var forceCriticalEffectNpcOnly 	: bool;
	
	default handleCollisionWithObstacle 		= true;
	default raiseEventOnActivation 				= 'Attack';
	default raiseEventOnObstacleCollision 		= 'AttackFail';
	default checkLineOfSight 					= true;
	default dealDamage 							= true;
	default chargeType 							= ECAT_Knockdown;
}