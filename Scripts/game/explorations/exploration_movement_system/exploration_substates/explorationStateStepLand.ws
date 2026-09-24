/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateStepLand extends CExplorationStateAbstract
{
	public				var enabled			: bool;			default	enabled			= false;
	
	
	private				var	fallCancelled	: bool;
	private				var	ended			: bool;
	private editable	var	timeSafetyEnd	: float;		default timeSafetyEnd	= 0.2f;
	
	
	private				var	directionToLand	: float;
	
	
	private editable	var	timeToChainJump	: float;		default timeToChainJump	= 0.05f;
	
	
	protected editable	var	behAnimEnded	: name;			default	behAnimEnded	= 'LandEnd';
	protected editable	var	behLandRunS		: name;			default	behLandRunS		= 'LandWalking';
	protected editable	var	behAnimFall		: name;			default	behAnimFall		= 'StepToFall';
	

	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'StepLand';
		}
		
		m_StateTypeE	= EST_OnAir;
		
		SetCanSave( false );
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
	}

	
	function StateWantsToEnter() : bool
	{
		if( !m_ExplorationO.m_CollisionManagerO.GetLandGoesToFall( ) )
		{
			return false;
		}
		
		if( !m_ExplorationO.m_CollisionManagerO.IsDirectionToFallFree( 0.0f ) )
		{
			return false;
		}
		
		return true;
	}

	
	function StateCanEnter( curStateName : name ) : bool
	{	
		if( !enabled )
		{
			return false;
		}
		
		if( m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_KnockBack || m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_KnockBackFall || m_ExplorationO.m_SharedDataO.m_JumpTypeE == EJT_ToWater )
		{
			return false;
		}
		
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{		
		FindDirectionToFall();
		
		PrepareMovementAdjustor();
		
		
		fallCancelled	= false;
		ended			= false;
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( behAnimEnded, 'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{				
		
		if( m_ExplorationO.StateWantsAndCanEnter( 'Jump' ) )
		{
			if( m_ExplorationO.GetStateTimeF() >= timeToChainJump )
			{
				m_ExplorationO.SetBehaviorParamBool( behAnimFall, true );
				return 'Jump';
			}
		}
		
		
		if( ended || ( ( timeSafetyEnd > 0.0f && timeSafetyEnd < m_ExplorationO.GetStateTimeF() ) || ( timeSafetyEnd == 0.0f && 3.0f < m_ExplorationO.GetStateTimeF() ) ) )
		{			
			if( fallCancelled )
			{
				if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
				{
					m_ExplorationO.SetBehaviorParamBool( behAnimFall, false );
					return 'Idle';
				}
			}
			else
			{
				if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'StartFalling' ) )
				{
					m_ExplorationO.SetBehaviorParamBool( behAnimFall, true );
					return 'StartFalling';
				}
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		var walkSpeed	: float;
		
		
		m_ExplorationO.m_OwnerMAC.GetMovementAdjustor().CancelByName( 'TurnOnStepLand' );
		
		
		if( nextStateName == 'Idle' )
		{
			if( thePlayer.GetIsWalking() )
			{
				if( thePlayer.GetIsRunning() )
				{
					walkSpeed	= 1.0f;
				}
				else
				{
					walkSpeed	= 0.5f;
				}
			}
			else
			{
				walkSpeed	= 0.0f;
			}
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( behLandRunS, walkSpeed );
		}
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( behAnimEnded );
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		fallCancelled	= false;
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{		
		fallCancelled	= true;
		
		return true;
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == behAnimEnded )
		{
			ended	= true;
		}
	}
	
	
	private function FindDirectionToFall()
	{
		directionToLand	= m_ExplorationO.m_OwnerE.GetHeading();
	}
	
	
	private function PrepareMovementAdjustor()
	{
		var movAdj 			: CMovementAdjustor;
		var ticket 			: SMovementAdjustmentRequestTicket;
		
		
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		ticket = movAdj.CreateNewRequest( 'TurnOnStepLand' );
		
		movAdj.AdjustmentDuration( ticket, 0.15f );
		movAdj.RotateTo( ticket, directionToLand );
		movAdj.LockMovementInDirection( ticket, directionToLand );
	}
}