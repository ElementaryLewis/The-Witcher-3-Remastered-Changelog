/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskAddEffectToTarget extends IBehTreeTask
{
	public var onActivate			: bool;
	public var onEvent				: bool;
	public var onDeactivate			: bool;
	public var eventName			: name;
	public var useLookAt 			: bool;
	public var applyEffectInterval	: float;
	public var applyEffectForTime 	: float;
	public var applyEffectInRange	: float;
	public var applyEffectInCone	: float;
	public var effectType			: EEffectType;
	public var effectDuration		: float;
	public var effectValue			: float;
	public var effectValuePerc		: float;
	public var applyOnOwner			: bool;
	public var customFXName			: name;
	public var breakQuen			: bool;
	
	private var activated 			: bool;
	private var timeStamp 			: float;

	function OnActivate() : EBTNodeStatus
	{
		if ( onActivate )
		{
			ProcessEffect();
			activated = true;
		}
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var lastEffectApplicationTime : float;
		
		if ( applyEffectInterval > 0 )
		{
			if ( !activated )
			{
				SleepOneFrame();
			}
			timeStamp = GetLocalTime();
			Sleep( applyEffectInterval);
			while ( timeStamp < GetLocalTime() + applyEffectForTime )
			{
				if ( lastEffectApplicationTime < GetLocalTime() + applyEffectInterval )
				{
					lastEffectApplicationTime = GetLocalTime();
					ProcessEffect();
				}
				SleepOneFrame();
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			ProcessEffect();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == eventName )
		{
			ProcessEffect();
			activated = true;
			return true;
		}
		return false;
	}
	
	function ProcessEffect()
	{
		var npc			: CNewNPC = GetNPC();
		var npcPos		: Vector;
		var targetPos	: Vector;
		var lookAtPos	: Vector;
		
		if ( useLookAt )
		{
			npcPos = npc.GetWorldPosition();
			targetPos = GetCombatTarget().GetWorldPosition();
			lookAtPos = npc.GetBehaviorVectorVariable( 'lookAtTarget' );
			
			if ( applyEffectInRange > 0 && applyEffectInCone > 0 )
			{
				if ( VecDistance( npcPos, targetPos ) <= applyEffectInRange 
					&& AbsF( AngleDistance( VecHeading( lookAtPos - npcPos ), VecHeading( targetPos - npcPos ) ) ) <= applyEffectInCone )
				{
					ApplyEffect();
				}
			}
			else if ( applyEffectInRange > 0 && applyEffectInCone <= 0  )
			{
				if ( VecDistance( npcPos, targetPos ) <= applyEffectInRange )
				{
					ApplyEffect();
				}
			}
			else if ( applyEffectInCone > 0 && applyEffectInRange <= 0 )
			{
				if ( AbsF( AngleDistance( VecHeading( lookAtPos - npcPos ), VecHeading( targetPos - npcPos ) ) ) <= applyEffectInCone )
				{
					ApplyEffect();
				}
			}
			else
			{
				ApplyEffect();
			}
			
			npc.GetVisualDebug().AddSphere( 'addEffectToTarget', 0.5, lookAtPos, true, Color( 0,0,255 ), 5.0f );
		}
		else
		{
			npcPos = npc.GetWorldPosition();
			targetPos = GetCombatTarget().GetWorldPosition();
			
			if ( applyEffectInRange > 0 && applyEffectInCone > 0 )
			{
				if ( VecDistance( npcPos, targetPos ) <= applyEffectInRange 
					&& AbsF( AngleDistance( npc.GetHeading(), VecHeading( targetPos - npcPos ) ) ) <= applyEffectInCone )
				{
					ApplyEffect();
				}
			}
			else if ( applyEffectInRange > 0 && applyEffectInCone <= 0  )
			{
				if ( VecDistance( npcPos, targetPos ) <= applyEffectInRange )
				{
					ApplyEffect();
				}
			}
			else if ( applyEffectInCone > 0 && applyEffectInRange <= 0 )
			{
				if ( AbsF( AngleDistance( npc.GetHeading(), VecHeading( targetPos - npcPos ) ) ) <= applyEffectInCone )
				{
					ApplyEffect();
				}
			}
			else
			{
				ApplyEffect();
			}
		}
		
		if( breakQuen && GetCombatTarget() == thePlayer )
		{
			if( GetWitcherPlayer().IsAnyQuenActive() )
			{
				thePlayer.FinishQuen( false );
			}
		}
	}
	
	function ApplyEffect()
	{
		var npc		: CNewNPC = GetNPC();
		var target	: CActor = GetCombatTarget();
		var params 	: SCustomEffectParams;
		
		params.effectType = effectType;
		params.creator = npc;
		params.sourceName = npc.GetName();
		params.duration = effectDuration;
		params.customFXName = customFXName;
		
		if ( effectValue > 0 )
			params.effectValue.valueAdditive = effectValue;
		
		if ( effectValuePerc > 0 )
			params.effectValue.valueMultiplicative = effectValuePerc;
		
		if ( IsNameValid( customFXName ) )
			params.customFXName = customFXName;
		
		if( target && !applyOnOwner )
		{
			target.AddEffectCustom(params);
		}
		else if( applyOnOwner )
		{
			GetNPC().AddEffectCustom(params);
		}
	}
};

class CBTTaskAddEffectToTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskAddEffectToTarget';

	editable var onActivate				: bool;
	editable var onEvent				: bool;
	editable var onDeactivate			: bool;
	editable var useLookAt 				: bool;
	editable var applyEffectInterval	: float;
	editable var applyEffectForTime 	: float;
	editable var applyEffectInRange		: float;
	editable var applyEffectInCone		: float;
	editable var eventName				: name;
	editable var effectType				: EEffectType;
	editable var effectDuration			: float;
	editable var effectValue			: float;
	editable var effectValuePerc		: float;
	editable var applyOnOwner			: bool;
	editable var customFXName			: name;
	editable var breakQuen				: bool;
	
	default onActivate = true;
	default effectDuration = 1.0f;
	default applyOnOwner = false;
	default breakQuen = false;
};