/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTask3StateAttack extends CBTTaskAttack
{
	var loopTime 						: float;
	var endTaskWhenOwnerGoesPastTarget 	: bool;
	var endLoopOnDistance				: bool;
	var distanceToTarget				: float;
	var stopRotatingWhenTargetIsBehind 	: bool;
	var playFXOnLoopStart 				: name;
	var playLoopFXInterval				: float;
	var raiseEventName 					: name;
	var startDeactivationEventName 		: name;
	var endDeactivationEventName 		: name;
	
	private var startPos				: Vector;
	public var lastFXTime				: float;
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		combatDataStorage.SetIsAttacking( true, GetLocalTime() );
		return super.OnActivate();
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc 	: CNewNPC = GetNPC();
		var loopRes : int;
		
		npc.SetBehaviorVariable( 'AttackEnd', 0.0 );
		
		if( IsNameValid( raiseEventName ) )
		{
			if( npc.RaiseForceEvent( raiseEventName ) )
			{
				npc.WaitForBehaviorNodeDeactivation( startDeactivationEventName, 10.0f );
			}
			else
			{
				return BTNS_Failed;
			}
		}
		
		if ( IsNameValid( playFXOnLoopStart ) && playLoopFXInterval <= 0 )
			npc.PlayEffect( playFXOnLoopStart );
		
		
		loopRes = Loop();
		if ( loopRes )
		{
			return BTNS_Completed;
		}
		
		ChooseAnim();
		if ( IsNameValid( playFXOnLoopStart ))
		{
			npc.StopEffect( playFXOnLoopStart );
		}
		npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
		
		npc.WaitForBehaviorNodeDeactivation( endDeactivationEventName, 10.0f );
		
		if ( loopRes == -1 )
		{
			return BTNS_Failed;
		}
		
		return BTNS_Completed;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		ChooseAnim();
		if ( IsNameValid( playFXOnLoopStart ))
			npc.StopEffect( playFXOnLoopStart );
		
		npc.SetBehaviorVariable( 'AttackEnd', 1.0 );
		super.OnDeactivate();
	}
	
	latent function Loop() : int
	{
		var endTime 					: float;
		var dotProduct 					: float;
		var playFX						: bool;
		var npc 						: CNewNPC;
		var target						: CActor;
		var targetPos					: Vector;
		var npcPos						: Vector;
		var dist						: float;
		
		
		endTime = GetLocalTime() + loopTime;
		playFX = IsNameValid( playFXOnLoopStart ) && playLoopFXInterval > 0;
		
		
		if( endLoopOnDistance )
		{
			npc = GetNPC();
			target = GetCombatTarget();
			npcPos = npc.GetWorldPosition();
			targetPos = target.GetWorldPosition();
			
			dist = VecDistance2D( npcPos, targetPos );
			
			while( dist > distanceToTarget )
			{
				SleepOneFrame();
				npcPos = npc.GetWorldPosition();
				targetPos = target.GetWorldPosition();
				dist = VecDistance2D( npcPos, targetPos );
			}
		}
		else if ( endTaskWhenOwnerGoesPastTarget )
		{
			npc = GetNPC();
			target = GetCombatTarget();
			startPos = npc.GetWorldPosition();
			dotProduct = 0;
			
			if ( playFX )
			{
				npc.PlayEffect( playFXOnLoopStart );
			}
			
			while ( dotProduct >= 0.0f && GetLocalTime() <= endTime )
			{
				if ( playFX && GetLocalTime() > lastFXTime + playLoopFXInterval )
				{
					npc.PlayEffect( playFXOnLoopStart );
					lastFXTime = GetLocalTime();
				}
				
				Sleep( 0.25 );
				npcPos		= npc.GetWorldPosition();
				targetPos 	= target.GetWorldPosition();
				dotProduct 	= VecDot( targetPos - startPos, targetPos - npcPos );
			}
		}
		else
		{
			while ( GetLocalTime() <= endTime )
			{
				if ( playFX )
				{
					npc.PlayEffect( playFXOnLoopStart );
					Sleep( playLoopFXInterval );
				}
				else
					SleepOneFrame();
			}
		}
		
		
		
		return 0;
	}
	
	function ChooseAnim()
	{
		return;
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( stopRotatingWhenTargetIsBehind && eventName == 'RotateEventSync' )
		{
			if ( AbsF(NodeToNodeAngleDistance(GetCombatTarget(),GetActor())) < 90 )
			{
				return super.OnGameplayEvent( 'RotateEventStart' );
			}
			else
			{
				GetNPC().SuspendRotationAdjustment();
				return true;
			}
		}
		
		return super.OnGameplayEvent( eventName );
	}
}

class CBTTask3StateAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTask3StateAttack';

	editable var loopTime 						: float;
	editable var endTaskWhenOwnerGoesPastTarget	: bool;
	editable var endLoopOnDistance				: bool;
	editable var distanceToTarget				: float;
	editable var stopRotatingWhenTargetIsBehind : bool;
	editable var playFXOnLoopStart				: name;
	editable var playLoopFXInterval				: float;
	editable var raiseEventName 				: name;
	editable var startDeactivationEventName 	: name;
	editable var endDeactivationEventName 		: name;
	
	default distanceToTarget = 1.5;
	default loopTime = 4.0;
	default playLoopFXInterval = -1;
	default stopRotatingWhenTargetIsBehind = false;
	default raiseEventName = '3StateAttack';
	default startDeactivationEventName = 'AttackStart';
	default endDeactivationEventName = 'AttackEnd';
}



class CBTTask3StateWithRot extends CBTTask3StateAttack
{
	var endLeft		: EAttackType;
	var endRight	: EAttackType;
	
	function ChooseAnim()
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		var angleDist : float = NodeToNodeAngleDistance(target, npc);
		
		if ( angleDist > 90 )
		{
			npc.SetBehaviorVariable( 'AttackType', (int)endRight, true );
		}
		else if ( angleDist < -90 )
		{
			npc.SetBehaviorVariable( 'AttackType', (int)endLeft, true );
		}
	}
}

class CBTTask3StateWithRotDef extends CBTTask3StateAttackDef
{
	default instanceClass = 'CBTTask3StateWithRot';

	editable var endLeft	: EAttackType;
	editable var endRight	: EAttackType;
	
	default endLeft = EAT_Attack5;
	default endRight = EAT_Attack5;
}



class CBTTask3StateWithDist extends CBTTask3StateAttack
{
	var distance	: float;
	var endLess	: EAttackType;
	var endMore	: EAttackType;
	
	function ChooseAnim()
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		
		var dist : float = VecDistance2D(npc.GetWorldPosition(),target.GetWorldPosition());
		
		if ( dist <= distance )
		{
			npc.SetBehaviorVariable( 'AttackType', (int)endLess, true );
		}
		else
		{
			npc.SetBehaviorVariable( 'AttackType',(int)endMore, true );
		}
	}
}

class CBTTask3StateWithDistDef extends CBTTask3StateAttackDef
{
	default instanceClass = 'CBTTask3StateWithDist';

	editable var distance	: float;
	editable var endLess	: EAttackType;
	editable var endMore	: EAttackType;
	
	default endLess = EAT_Attack5;
	default endMore = EAT_Attack5;
}



class CBTTask3StateWithDistAndRot extends CBTTask3StateAttack
{
	var distance	: float;
	var endLeft		: EAttackType;
	var endRight	: EAttackType;
	
	function ChooseAnim()
	{
		var npc : CNewNPC = GetNPC();
		var target : CActor = GetCombatTarget();
		
		var dist : float = VecDistance2D(npc.GetWorldPosition(),target.GetWorldPosition());
		var angleDist : float = NodeToNodeAngleDistance(target, npc);
		
		if ( dist >= distance )
		{
			if ( angleDist > 90 )
			{
				npc.SetBehaviorVariable( 'AttackType', (int)endRight, true );
			}
			else if ( angleDist < -90 )
			{
				npc.SetBehaviorVariable( 'AttackType', (int)endLeft, true );
			}
		}
	}
}

class CBTTask3StateWithDistAndRotDef extends CBTTask3StateAttackDef
{
	default instanceClass = 'CBTTask3StateWithDistAndRot';

	editable var distance	: float;
	editable var endLeft	: EAttackType;
	editable var endRight	: EAttackType;
	
	default endLeft = EAT_Attack5;
	default endRight = EAT_Attack5;
	
	hint distance = "if ( distToTarget >= distance ) then perform Rot attack";
}



class CBTTask3StateAddEffectAttack extends CBTTask3StateAttack
{
	public var applyEffectInRange	: float;
	public var applyEffectInCone	: float;
	public var applyEffectInterval	: float;
	public var effectType			: EEffectType;
	public var effectDuration		: float;
	public var effectValue			: float;
	public var effectPercentValue	: float;
	public var activated			: bool;
	
	
	latent function Loop() : int
	{
		var timeStamp 					: float;
		var endTime						: float;
		var npc 						: CNewNPC = GetNPC();
		var npcPos						: Vector;
		var targetPos					: Vector;
		var lookAtPos					: Vector;
		var playFX						: bool;
		
		
		endTime = GetLocalTime() + loopTime;
		playFX = IsNameValid( playFXOnLoopStart ) && playLoopFXInterval > 0;
		
		if ( playFX )
			lastFXTime = GetLocalTime();
		
		while ( GetLocalTime() <= endTime )
		{
			if ( playFX && lastFXTime + playLoopFXInterval < GetLocalTime() )
			{
				npc.PlayEffect( playFXOnLoopStart );
				lastFXTime = GetLocalTime();
			}
			
			if ( ( timeStamp + applyEffectInterval ) < GetLocalTime() || timeStamp == 0 )
			{
				timeStamp = GetLocalTime();
				npcPos = npc.GetWorldPosition();
				targetPos = GetCombatTarget().GetWorldPosition();
				lookAtPos = npc.GetBehaviorVectorVariable( 'lookAtTarget' );
				
				if ( VecDistance( npcPos, targetPos ) <= applyEffectInRange 
					&& AbsF( AngleDistance( VecHeading( lookAtPos - npcPos ), VecHeading( targetPos - npcPos ) ) ) <= applyEffectInCone )
				{
					ApplyEffect( true );
				}
			}
			
			SleepOneFrame();
		}
		
		return 0;
	}
	
	function OnDeactivate() 
	{
		activated = false;
		
		super.OnDeactivate();
	}
	
	function ApplyEffect( b : bool )
	{
		var actor		: CActor = GetActor();
		var target		: CActor = GetCombatTarget();
		var params 		: SCustomEffectParams;
		var effectName 	: name;
		
		if ( !b )
		{
			target.RemoveBuff( effectType, false, actor.GetName() );
			return;
		}
		
		params.effectType = effectType;
		params.creator = actor;
		params.sourceName = actor.GetName();
		params.duration = effectDuration;
		
		effectName = EffectTypeToName( effectType );
		
		if ( effectValue > 0 )
			params.effectValue.valueAdditive = effectValue;
		
		if ( effectPercentValue > 0 )
			params.effectValue.valueMultiplicative = effectPercentValue;
		
		if( target && !target.HasEffect( effectName ) )
		{
			target.AddEffectCustom(params);
		}
	}
}

class CBTTask3StateAddEffectAttackDef extends CBTTask3StateAttackDef
{
	default instanceClass = 'CBTTask3StateAddEffectAttack';
	
	editable var applyEffectInRange		: float;
	editable var applyEffectInCone		: float;
	editable var applyEffectInterval	: float;
	editable var effectType				: EEffectType;
	editable var effectDuration			: float;
	editable var effectValue			: float;
	editable var effectPercentValue		: float;
	
	default applyEffectInRange			= 3;
	default applyEffectInCone			= 30;
	default applyEffectInterval  		= 0.5f;
	default effectDuration				= 1.f;
}
