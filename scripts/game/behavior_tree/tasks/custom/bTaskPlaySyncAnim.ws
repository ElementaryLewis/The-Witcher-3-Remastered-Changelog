/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskPlaySyncAnim extends IBehTreeTask
{
	public var useSetupSimpleSyncAnim2 	: bool;
	public var syncAnimNameLeftStance	: name;
	public var syncAnimNameRightStance	: name;
	public var raiseForceIdle 			: bool;
	public var denyWhenTargetIsDodging 	: bool;
	public var denyIfTargetNotPlayer 	: bool;
	public var onAnimEvent 				: name;
	public var onGameplayEvent 			: name;
	public var shouldComplete 			: bool;
	
	private var activated 				: bool;
	
	
	function OnActivate() : EBTNodeStatus
	{
		activated = false;
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		var target 	: CActor;
		var player  : CR4Player = thePlayer;
		var res 	: bool;
		
		target = GetCombatTarget();
		if ( denyIfTargetNotPlayer && target != thePlayer )
		{
			return BTNS_Failed;
		}
		if ( denyWhenTargetIsDodging && target.IsCurrentlyDodging() )
		{
			return BTNS_Failed;
		}
		
		res = IsNameValid( onGameplayEvent ) || IsNameValid( onAnimEvent );
		
		while ( res && !activated )
		{
			SleepOneFrame();
		}
		
		if ( raiseForceIdle )
		{
			GetNPC().RaiseForceEvent( 'ForceIdle' );
		}
		
		if ( player == target && player.GetCombatIdleStance() == 0 )
		{
			if ( useSetupSimpleSyncAnim2 )
			{
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( syncAnimNameLeftStance, npc, target );
			}
			else
			{
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( syncAnimNameLeftStance, npc, target );
			}
		}
		else
		{
			if ( useSetupSimpleSyncAnim2 )
			{
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( syncAnimNameRightStance, npc, target );
			}
			else
			{
				theGame.GetSyncAnimManager().SetupSimpleSyncAnim( syncAnimNameRightStance, npc, target );
			}
		}
		Sleep(1.f);
		
		if( shouldComplete )
		{
			return BTNS_Completed;
		}
		else return BTNS_Active;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( onGameplayEvent ) && eventName == onGameplayEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( IsNameValid( onAnimEvent ) && animEventName == onAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return false;
	}
};

class CBTTaskPlaySyncAnimDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskPlaySyncAnim';

	editable var useSetupSimpleSyncAnim2 	: bool;
	editable var syncAnimNameLeftStance		: name;
	editable var syncAnimNameRightStance	: name;
	editable var raiseForceIdle 			: bool;
	editable var denyWhenTargetIsDodging 	: bool;
	editable var denyIfTargetNotPlayer 		: bool;
	editable var onAnimEvent 				: name;
	editable var onGameplayEvent 			: name;
	editable var shouldComplete 			: bool;
	
	default raiseForceIdle = true;
	default shouldComplete = true;
	
	
	hint raiseForceIdle = "ensures that animation played before sync won't be played after without context";
	hint useSetupSimpleSyncAnim2 = "for new sync cases, if you don't know you need it, don't use it";
	
};






struct SSyncAttackTypes
{
	editable var leftStanceFrontAttack		: EAttackType;
	editable var rightStanceFrontAttack		: EAttackType;
	editable var leftStanceBackAttack		: EAttackType;
	editable var rightStanceBackAttack		: EAttackType;
}

class CBTTaskPlaySyncAnimAttack extends CBTTaskAttack
{
	public var useSetupSimpleSyncAnim2 		: bool;
	public var overrideAttackTypes 			: bool;
	public var disableCollision 			: bool;
	public var syncAttackAnims 				: SSyncAttackTypes;
	public var checkConditionsOnIsAvailable : bool;
	public var syncAnimNameLeftStance		: name;
	public var syncAnimNameRightStance		: name;
	public var raiseForceIdle 				: bool;
	public var denyWhenTargetIsDodging 		: bool;
	public var denyWhenTargetIsGuarded		: bool;
	public var denyWhenTargetIsUsingQuen	: bool;
	public var permitOnlyWhenTargetIsGuarded: bool;
	public var denyWhenCollidingWithVictirm	: bool;
	public var activateOnDistanceBelow 		: float;
	public var activateOnDistanceAbove 		: float;
	public var activateOnAngleBelow 		: float;
	public var checkMoveType 				: bool;
	public var activateOnGreaterEqualMoveType: EMoveType;
	public var zTolerance 					: float;
	public var denyIfTargetNotPlayer 		: bool;
	public var onAnimEvent 					: name;
	public var onGameplayEvent 				: name;
	public var completeOnMainEnd 			: bool;
	
	private var activated 					: bool;
	private var npc 						: CNewNPC;
	private	var target 						: CActor;
	private var component 					: CAnimatedComponent;
	
	
	function IsAvailable() : bool
	{
		if( checkConditionsOnIsAvailable )
		{
			return CheckConditions();
		}
		return true;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var target 		: CActor = GetCombatTarget();
		var npc 		: CActor = GetNPC();
		var angleDist 	: float;
		
		if ( raiseForceIdle )
		{
			GetNPC().RaiseForceEvent( 'ForceIdle' );
		}
		activated = false;
		super.OnActivate();
		
		if ( overrideAttackTypes )
		{
			angleDist = NodeToNodeAngleDistance( npc, target );
			
			
			if ( target == thePlayer && thePlayer.GetCombatIdleStance() == 0 )
			{
				
				if ( angleDist >= -90.0 && angleDist < 90.0 )
				{
					npc.SetBehaviorVariable( 'AttackType', (int)syncAttackAnims.leftStanceFrontAttack, true );
				}
				
				else
				{
					npc.SetBehaviorVariable( 'AttackType', (int)syncAttackAnims.leftStanceBackAttack, true );
				}
			}
			
			else
			{
				
				if ( angleDist >= -90.0 && angleDist < 90.0 )
				{
					npc.SetBehaviorVariable( 'AttackType', (int)syncAttackAnims.rightStanceFrontAttack, true );
				}
				
				else
				{
					npc.SetBehaviorVariable( 'AttackType', (int)syncAttackAnims.rightStanceBackAttack, true );
				}
			}
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var movementAdjustor	: CMovementAdjustor;
		var player  			: CR4Player = thePlayer;
		var res 				: bool;
		
		
		res = IsNameValid( onGameplayEvent ) || IsNameValid( onAnimEvent );
		while ( res && !activated )
		{
			SleepOneFrame();
		}
		
		if ( CheckConditions() )
		{
			if ( raiseForceIdle )
			{
				GetNPC().RaiseForceEvent( 'ForceIdle' );
			}
			
			movementAdjustor = target.GetMovingAgentComponent().GetMovementAdjustor();
			if ( movementAdjustor )
			{
				movementAdjustor.CancelAll();
			}
			
			if ( player == target )
			{
				thePlayer.BlockAllActions( 'BTTaskPlaySyncAnim', true );
				thePlayer.SetImmortalityMode( AIM_Invulnerable, AIC_SyncedAnim );
				thePlayer.OnTaskSyncAnim( GetNPC(), syncAnimNameLeftStance );
				if ( disableCollision )
				{
					npc.EnableCharacterCollisions( false );
				}
				if ( player.GetCombatIdleStance() == 0 )
				{
					if ( useSetupSimpleSyncAnim2 )
					{
						if ( !theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( syncAnimNameLeftStance, npc, target ) )
						{
							thePlayer.BlockAllActions( 'BTTaskPlaySyncAnim', false );
							thePlayer.SetImmortalityMode( AIM_None, AIC_SyncedAnim );
							if ( disableCollision )
							{
								npc.EnableCharacterCollisions( true );
							}
							return BTNS_Failed;
						}
					}
					else
					{
						if ( !theGame.GetSyncAnimManager().SetupSimpleSyncAnim( syncAnimNameLeftStance, npc, target ) )
						{
							thePlayer.BlockAllActions( 'BTTaskPlaySyncAnim', false );
							thePlayer.SetImmortalityMode( AIM_None, AIC_SyncedAnim );
							if ( disableCollision )
							{
								npc.EnableCharacterCollisions( true );
							}
							return BTNS_Failed;
						}
					}
				}
				else
				{
					if ( useSetupSimpleSyncAnim2 )
					{
						if ( !theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( syncAnimNameRightStance, npc, target ) )
						{
							thePlayer.BlockAllActions( 'BTTaskPlaySyncAnim', false );
							thePlayer.SetImmortalityMode( AIM_None, AIC_SyncedAnim );
							if ( disableCollision )
							{
								npc.EnableCharacterCollisions( true );
							}
							return BTNS_Failed;
						}
					}
					else
					{
						if ( !theGame.GetSyncAnimManager().SetupSimpleSyncAnim( syncAnimNameRightStance, npc, target ) )
						{
							thePlayer.BlockAllActions( 'BTTaskPlaySyncAnim', false );
							thePlayer.SetImmortalityMode( AIM_None, AIC_SyncedAnim );
							if ( disableCollision )
							{
								npc.EnableCharacterCollisions( true );
							}
							return BTNS_Failed;
						}
					}
				}
			}
			else
			{
				if ( useSetupSimpleSyncAnim2 )
				{
					if ( !theGame.GetSyncAnimManager().SetupSimpleSyncAnim2( syncAnimNameLeftStance, npc, target ) )
					{
						return BTNS_Failed;
					}
				}
				else
				{
					if ( !theGame.GetSyncAnimManager().SetupSimpleSyncAnim( syncAnimNameLeftStance, npc, target ) )
					{
						return BTNS_Failed;
					}
				}
			}
		}
		
		Sleep( 0.1 );
		
		thePlayer.BlockAllActions( 'BTTaskPlaySyncAnim', false );
		thePlayer.SetImmortalityMode( AIM_None, AIC_SyncedAnim );
		if ( disableCollision )
		{
			npc.EnableCharacterCollisions( true );
		}
		if ( completeOnMainEnd )
		{
			return BTNS_Completed;
		}
		else
		{
			return BTNS_Active;
		}
	}
	
	final function CheckConditions() : bool
	{
		var npcPos 			: Vector;
		var targetPos 		: Vector;
		var currentSpeed 	: float;
		var witcher 		: W3PlayerWitcher;
		
		
		
		
		target = GetCombatTarget();
		npc = GetNPC();
		
		npcPos = npc.GetWorldPosition();
		targetPos = target.GetWorldPosition();
		
		
		if ( checkMoveType )
		{
			if ( !component )
			{
				component = ( CAnimatedComponent )GetActor().GetComponentByClassName( 'CAnimatedComponent' );
			}
			currentSpeed = component.GetMoveSpeedRel();
			switch ( activateOnGreaterEqualMoveType )
			{
				case MT_Walk:			if ( currentSpeed < 1 ) return false;
				case MT_Run: 			if ( currentSpeed < 2 ) return false;
				case MT_FastRun: 		if ( currentSpeed < 3 ) return false;
				case MT_Sprint: 		if ( currentSpeed < 4 ) return false;
			}
		}
		if ( target == thePlayer && ( thePlayer.GetCurrentStateName() == 'AimThrow' || thePlayer.IsThrowHold() || thePlayer.GetIsAimingCrossbow() ) )
		{
			return false;
		}
		if ( denyIfTargetNotPlayer && target != thePlayer )
		{
			return false;
		}
		if ( denyWhenTargetIsDodging && target.IsCurrentlyDodging() )
		{
			return false;
		}
		if ( denyWhenTargetIsGuarded && target.IsGuarded() )
		{
			return false;
		}
		if ( denyWhenTargetIsUsingQuen && target == thePlayer )
		{
			witcher = GetWitcherPlayer();
			if ( witcher.IsQuenActive( true ) )
			{
				return false;
			}
		}
		if ( permitOnlyWhenTargetIsGuarded && !target.IsGuarded() )
		{
			return false;
		}
		if ( activateOnDistanceBelow > 0 && VecDistance( npcPos, targetPos ) > activateOnDistanceBelow )
		{
			return false;
		}
		if ( activateOnDistanceAbove > 0 && VecDistance( npcPos, targetPos ) < activateOnDistanceAbove )
		{
			return false;
		}
		if ( activateOnAngleBelow > 0 && NodeToNodeAngleDistance( npc, target ) > activateOnAngleBelow )
		{
			return false;
		}
		if ( denyWhenCollidingWithVictirm && npc.GetRadius() + target.GetRadius() + 0.1 > VecDistance( npcPos, targetPos ) )
		{
			return false;
		}
		if ( zTolerance > 0 )
		{
			if ( npcPos.Z < 0 && targetPos.Z < 0 )
			{
				if ( AbsF( AbsF( npcPos.Z ) - AbsF( targetPos.Z ) ) > zTolerance )
				{
					return false;
				}
			}
			else if ( AbsF( npcPos.Z - targetPos.Z ) > zTolerance )
			{
				return false;
			}
		}
		
		return true;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( IsNameValid( onGameplayEvent ) && eventName == onGameplayEvent )
		{
			activated = true;
			return true;
		}
		
		return super.OnGameplayEvent( eventName );
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if( IsNameValid( onAnimEvent ) && animEventName == onAnimEvent )
		{
			activated = true;
			return true;
		}
		
		return super.OnAnimEvent( animEventName, animEventType, animInfo );
	}
};

class CBTTaskPlaySyncAnimAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskPlaySyncAnimAttack';
	
	editable var disableCollision 				: bool;
	editable var useSetupSimpleSyncAnim2 		: bool;
	editable var overrideAttackTypes 			: bool;
	editable var syncAttackAnims 				: SSyncAttackTypes;
	editable var checkConditionsOnIsAvailable 	: bool;
	editable var syncAnimNameLeftStance			: name;
	editable var syncAnimNameRightStance		: name;
	editable var raiseForceIdle 				: bool;
	editable var denyWhenTargetIsDodging 		: bool;
	editable var denyWhenTargetIsGuarded		: bool;
	editable var denyWhenTargetIsUsingQuen		: bool;
	editable var permitOnlyWhenTargetIsGuarded	: bool;
	editable var denyWhenCollidingWithVictirm 	: bool;
	editable var activateOnDistanceBelow 		: float;
	editable var activateOnDistanceAbove 		: float;
	editable var activateOnAngleBelow 			: float;
	editable var checkMoveType 					: bool;
	editable var activateOnGreaterEqualMoveType : EMoveType;
	editable var zTolerance 					: float;
	editable var denyIfTargetNotPlayer 			: bool;
	editable var onAnimEvent 					: name;
	editable var onGameplayEvent 				: name;
	editable var completeOnMainEnd 				: bool;
	
	default raiseForceIdle 						= true;
	default denyWhenTargetIsUsingQuen 			= true;
	
	hint raiseForceIdle = "ensures that animation played before sync won't be played after without context";
	hint useSetupSimpleSyncAnim2 = "for new sync cases, if you don't know you need it, don't use it";
	
};