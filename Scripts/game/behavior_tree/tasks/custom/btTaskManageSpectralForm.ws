/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageSpectralForm extends IBehTreeTask
{	
	
	
	
	private var m_LastEnteredYrden 	: W3YrdenEntity;
	
	private var m_IsInYrden			: bool;
	
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( CanSwitchToShadow() )
		{
			ActivateShadowForm();
		}
		
		return BTNS_Active;
	}	
	
	
	latent function Main() : EBTNodeStatus
	{
		var l_npc : CNewNPC = GetNPC();
		
		while( true )
		{
			
			if( m_IsInYrden && !m_LastEnteredYrden )
			{
				m_IsInYrden = false;
				l_npc.SetBehaviorVariable( 'isInYrden', 0 );
			}
			
			if( l_npc.HasAbility ( 'ShadowFormActive' ) )
			{
				l_npc.SetCanPlayHitAnim( false );
			}
			
			if ( CanSwitchToShadow() )
			{
				ActivateShadowForm();
			}
			if ( !CanSwitchToShadow() )
			{
				DeactivateShadowForm();
			}
			
			SleepOneFrame();
		}
		return BTNS_Active;
	}
	
	
	private final function CanSwitchToShadow() : bool
	{
		if( !m_IsInYrden && GetNPC().HasAbility('ShadowForm') && !GetNPC().IsAbilityBlocked('ShadowForm') )
		{
			return true;
		}
		return false;
	}
	
	
	private final function ActivateShadowForm()
	{
		var l_npc : CNewNPC = GetNPC();
		
		l_npc.PlayEffectSingle( 'shadows_form' );
		l_npc.SetCanPlayHitAnim( false );
		
		if( !l_npc.HasAbility ( 'ShadowFormActive' ) )
		{	
			l_npc.EnableCharacterCollisions( false );		
			l_npc.AddAbility('ShadowFormActive');
			l_npc.SoundSwitch( 'ghost_visibility', 'invisible' );
		}
	}
	
	
	private final function DeactivateShadowForm()
	{
		var l_npc : CNewNPC = GetNPC();
		
		if( l_npc.IsEffectActive( 'shadows_form' ) )
		{				
			l_npc.StopEffect( 'shadows_form' );				
		}
		
		if( l_npc.HasAbility ( 'ShadowFormActive' ) )
		{
			l_npc.EnableCharacterCollisions( true );
			l_npc.SetCanPlayHitAnim( true );
			l_npc.RemoveAbility('ShadowFormActive');
			l_npc.SoundSwitch( 'ghost_visibility', 'visible' );
		}
	}
	
	
	final function OnListenedGameplayEvent( eventName : name ) : bool
	{
		var l_yrdenEntity 	: W3YrdenEntity;
		
		l_yrdenEntity = (W3YrdenEntity) GetEventParamObject();
		
		if( !GetNPC().IsAlive() ) 
			return false;
		
		switch( eventName )
		{
			case 'EntersYrden':
			m_IsInYrden = true;
			GetNPC().SetBehaviorVariable( 'isInYrden', 1 );
			
			m_LastEnteredYrden = l_yrdenEntity;			
			
			
			DeactivateShadowForm();
			
			break;
			case 'LeavesYrden':
			if( l_yrdenEntity == m_LastEnteredYrden )
			{
				m_IsInYrden = false;
				GetNPC().SetBehaviorVariable( 'isInYrden', 0 );
				
				
				if( CanSwitchToShadow() )
				{
					ActivateShadowForm();
				}
			}
			break;
		}
		
		return true;
	}

}



class BTTaskManageSpectralFormDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageSpectralForm';
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToGameplayEvents.PushBack( 'EntersYrden' );
		listenToGameplayEvents.PushBack( 'LeavesYrden' );
	}
}