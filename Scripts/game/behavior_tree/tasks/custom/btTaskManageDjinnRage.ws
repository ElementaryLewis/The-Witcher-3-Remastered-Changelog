/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageDjinnRage extends IBehTreeTask
{
	
	
	
	
	public var defaultFXName				: name;
	public var playFXOnAardHit				: name;
	public var playFXOnIgniHit				: name;
	public var weakenedFXName				: name;
	public var rageAbilityName				: name;
	public var weakenedAbilityName			: name;
	public var calmDownCooldown				: float;
	public var removeWeakenedStateOnCounter	: bool;
	
	
	
	private var m_isInYrden					: bool;
	private var m_inRageState				: bool;
	private var m_inWeakenedState			: bool;
	private var m_enterRageTimeStamp		: float;
	private var m_enterWeakendTimeStamp 	: float;
	
	
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_owner		: CNewNPC = GetNPC();
		
		while ( true )
		{
			if ( m_inRageState && GetLocalTime() >= m_enterRageTimeStamp + calmDownCooldown )
			{
				RemoveRageState();
			}
			
			if ( !m_inWeakenedState && l_owner.HasBuff( EET_Confusion ) || l_owner.HasBuff( EET_AxiiGuardMe ) )
			{
				RemoveRageState();
				EnterWeakenedState();
			}
			
			if ( m_inWeakenedState && !m_isInYrden && GetLocalTime() >= m_enterWeakendTimeStamp + calmDownCooldown )
				RemoveWeakenedState();
			
			SleepOneFrame();
		}
		
		return BTNS_Active;
	}
	
	
	
	
	
	private function EnterRageState()
	{
		var l_owner		: CNewNPC = GetNPC();
		
		m_inRageState = true;
		m_enterRageTimeStamp = GetLocalTime();
		
		l_owner.StopEffect( weakenedFXName );
		l_owner.AddAbility( rageAbilityName );
		l_owner.RemoveAbility( weakenedAbilityName );
	}
	
	
	
	
	private function RemoveRageState()
	{
		var l_owner		: CNewNPC = GetNPC();
		
		m_inRageState = false;
		
		l_owner.StopEffect( playFXOnAardHit );
		l_owner.StopEffect( playFXOnIgniHit );
		l_owner.RemoveAbility( rageAbilityName );
	}
	
	
	
	
	private function EnterWeakenedState()
	{
		var l_owner		: CNewNPC = GetNPC();
		
		m_inWeakenedState = true;
		m_inRageState = false;
		
		m_enterWeakendTimeStamp = GetLocalTime();
		
		l_owner.StopEffect( playFXOnAardHit );
		l_owner.StopEffect( playFXOnIgniHit );
		l_owner.StopEffect( defaultFXName );
		l_owner.PlayEffectSingle( weakenedFXName );
		l_owner.AddAbility( weakenedAbilityName );
		l_owner.RemoveAbility( rageAbilityName );
	}
	
	
	
	
	private function RemoveWeakenedState()
	{
		var l_owner			: CNewNPC = GetNPC();
		
		m_inWeakenedState = false;
		
		l_owner.PlayEffectSingle( defaultFXName );
		l_owner.StopEffect( weakenedFXName );
		l_owner.RemoveAbility( weakenedAbilityName );
	}
	
	
	
	
	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var l_owner			: CNewNPC = GetNPC();
		
		if ( eventName == 'EntersYrden' )
		{
			m_isInYrden = true;
			EnterWeakenedState();
			return true;
		}
		else if ( eventName == 'LeavesYrden' )
		{
			m_isInYrden = false;
			
			return true;
		}
		else if ( removeWeakenedStateOnCounter && ( eventName == 'LaunchCounterAttack' || eventName == 'HitReactionTaskCompleted' ) )
		{
			if ( !m_isInYrden )
				RemoveWeakenedState();
			return true;
		}
		else if ( eventName == 'IgniHitReceived' )
		{
			if ( !m_isInYrden && !l_owner.HasBuff( EET_Confusion ) && !l_owner.HasBuff( EET_AxiiGuardMe ) )
			{
				EnterRageState();
				l_owner.PlayEffectSingle( playFXOnIgniHit );
				l_owner.PlayEffectSingle( playFXOnAardHit );
			}
			return true;
		}
		else if ( eventName == 'AardHitReceived' )
		{
			if ( !m_isInYrden && !l_owner.HasBuff( EET_Confusion ) && !l_owner.HasBuff( EET_AxiiGuardMe ) )
			{
				EnterRageState();
				l_owner.PlayEffectSingle( playFXOnAardHit );
			}
			return true;
		}
		else if ( eventName == 'Death' )
		{
			l_owner.StopAllEffects();
			return true;
		}
		
		return false;
	}
};



class BTTaskManageDjinnRageDef extends IBehTreeTaskDefinition
{
	
	
	
	editable var defaultFXName					: name;
	editable var playFXOnAardHit				: name;
	editable var playFXOnIgniHit				: name;
	editable var weakenedFXName					: name;
	editable var rageAbilityName				: name;
	editable var weakenedAbilityName			: name;
	editable var calmDownCooldown				: float;
	editable var removeWeakenedStateOnCounter	: bool;
	
	default defaultFXName						= 'default';
	default playFXOnAardHit						= 'aard_reaction';
	default playFXOnIgniHit						= 'igni_reaction';
	default weakenedFXName						= 'weak';
	default rageAbilityName						= 'DjinnRage';
	default weakenedAbilityName					= 'DjinnWeak';
	default calmDownCooldown					= 5.f;
	default removeWeakenedStateOnCounter		= true;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'LaunchCounterAttack' );
		listenToGameplayEvents.PushBack( 'HitReactionTaskCompleted' );
		listenToGameplayEvents.PushBack( 'AardHitReceived' );
		listenToGameplayEvents.PushBack( 'IgniHitReceived' );
		listenToGameplayEvents.PushBack( 'EntersYrden' );
		listenToGameplayEvents.PushBack( 'LeavesYrden' );
		listenToGameplayEvents.PushBack( 'Death' );
	}
	
	default instanceClass = 'BTTaskManageDjinnRage';
};
