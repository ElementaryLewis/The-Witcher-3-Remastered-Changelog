/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDefend extends IBehTreeTask
{
	public var useCustomHits : bool;
	public var listenToParryEvents : bool;
	public var completeTaskOnIsDefending : bool;
	public var minimumDuration	: float;
	public var playParrySound	: bool;
	
	
	private var m_activationTime : float;
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetGuarded(true);
		npc.SetParryEnabled( true );
		if ( useCustomHits )
		{
			npc.customHits = true;
			npc.SetCanPlayHitAnim( true );
		}
		
		m_activationTime = GetLocalTime();
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var npc : CNewNPC = GetNPC();
		
		npc.SetGuarded(false);
		npc.SetParryEnabled( false );
		if ( useCustomHits )
		{
			npc.customHits = false;
		}
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		var npc 					: CNewNPC = GetNPC();
		var data 					: CDamageData;
		var l_currentDuration		: float;
		
		if ( eventName == 'BeingHit' )
		{
			data = (CDamageData) GetEventParamBaseDamage();
			
			if( (CBaseGameplayEffect) data.causer )
				return true;
			
			if( !data.isDoTDamage && playParrySound )			
				npc.SoundEvent( "cmb_play_parry" );
				
			if ( data.customHitReactionRequested )
			{
				npc.RaiseEvent('CustomHit');
				SetHitReactionDirection();
				return true;
			}
		}
		else if ( listenToParryEvents && ( eventName == 'ParryPerform' || eventName == 'ParryStagger' ) && npc.CanPlayHitAnim() )
		{
			npc.RaiseEvent('CustomHit');
			SetHitReactionDirection();
			return true;
		}
		else if ( eventName == 'IsDefending' )
		{
			SetEventRetvalInt(1);
			
			l_currentDuration = GetLocalTime() - m_activationTime;
			
			if ( completeTaskOnIsDefending && l_currentDuration > minimumDuration )
				Complete(true);
			return true;
		}
		
		else if ( eventName == 'DamageTaken' )
		{
			data = (CDamageData) GetEventParamBaseDamage();
			
			if( !data.isDoTDamage && playParrySound )			
				npc.SoundEvent( "cmb_play_parry" );
		}
		
		
		return false;
	}
	
	private function SetHitReactionDirection()
	{
		
		var victimToAttackerAngle 	: float;
		var npc 					: CNewNPC = GetNPC();
		var target					: CActor = GetCombatTarget();
		
		victimToAttackerAngle = NodeToNodeAngleDistance( target, npc );
		
		if( AbsF(victimToAttackerAngle) <= 90 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Forward);
		}
		else if( AbsF(victimToAttackerAngle) > 90 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionDirection',(int)EHRD_Back);
		}
		
		if( victimToAttackerAngle > 45 && victimToAttackerAngle < 135 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_Right);
		}
		else if( victimToAttackerAngle < -45 && victimToAttackerAngle > -135 )
		{
			
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_Left);
		}
		else
		{
			npc.SetBehaviorVariable( 'HitReactionSide',(int)EHRS_None);
		}
	}
}

class CBTTaskDefendDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskDefend';

	editable var useCustomHits 				: bool;
	editable var listenToParryEvents 		: bool;
	editable var completeTaskOnIsDefending 	: bool;
	editable var minimumDuration			: float;
	editable var playParrySound				: bool;
	
	default useCustomHits = false;
	default listenToParryEvents = true;
	default completeTaskOnIsDefending = false;
	default playParrySound = true;
	
	hint completeTaskOnIsDefending = "IsDefending event is sent on Geralt's attack if this task is active geralt will play AttackReflect";
	hint minimumDuration = "The task won't complete on 'IsDefending' before this duration";
}
