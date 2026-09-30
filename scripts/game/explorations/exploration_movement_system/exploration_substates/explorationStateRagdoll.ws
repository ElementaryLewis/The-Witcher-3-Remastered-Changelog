/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateRagdoll extends CExplorationStateAbstract
{	
	private var	lastPos	: Vector;
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Ragdoll';
		}
		
		m_StateTypeE			= EST_Locked;
		
		m_InputContextE			= EGCI_Ignore; 
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{
		return false;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}

	
	function StateCanExitToTo( nextStateName : name ) : bool
	{	
		return nextStateName == 'Idle' || nextStateName == 'Swim' || nextStateName == 'CombatExploration' || nextStateName == 'Jump' || nextStateName == 'Slide';
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		lastPos	= m_ExplorationO.m_OwnerE.GetWorldPosition();		
		
		
		thePlayer.AbortSign();	
	}
	
	
	function StateChangePrecheck( )	: name
	{	
		if ( VecLengthSquared( m_ExplorationO.m_OwnerMAC.GetVelocity() ) <= 9.0f 
			&& m_ExplorationO.GetStateTimeF() > 0.2f 
			&& m_ExplorationO.m_OwnerMAC.GetSubmergeDepth() < -0.0)
		{
			thePlayer.SetIsInAir( false );
		}
		
		if( HasQueuedState() )
		{
			if( !StateCanExitToTo( GetQueuedState() ) )
			{
				return GetStateName();
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		var curPos		: Vector;
		var fallHeight	: float;
		
		
		
		
		
		
		m_ExplorationO.m_SharedDataO.UpdateFallHeight();
		
		lastPos	= curPos;
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		thePlayer.SetBIsCombatActionAllowed( true );
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	function ReactToCriticalState( enabled : bool ) : bool
	{
		if( !enabled )
		{
			if( m_ExplorationO.IsOnGround() )
			{
				SetReadyToChangeTo( 'Idle' );
			}
			else
			{
				SetReadyToChangeTo( 'Jump' );
			}
		}
		
		
		return true;
	}
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		return true;
	}
	
	
	function ReactToLoseGround() : bool
	{
		
		
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{
		var fallDiff		: float;
		var jumpTotalDiff	: float;
		var damagePerc		: float;
		
		
		
		m_ExplorationO.m_SharedDataO.CalculateFallingHeights( fallDiff, jumpTotalDiff );
		
		
		damagePerc		= m_ExplorationO.m_OwnerE.ApplyFallingDamage( fallDiff, true );
		
		m_ExplorationO.m_SharedDataO.ResetHeightFallen();		
		
		return true;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
	}
}