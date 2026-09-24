/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateSkatingIdle extends CExplorationStateAbstract
{		
	private				var	skateGlobal		: CExplorationSkatingGlobal;
	
	private editable	var	turnSpeed			: float;		default	turnSpeed			= 700.0f;
	private editable	var	turnStartTolerance	: float;		default	turnStartTolerance	= 10.0f;
	
	
	private editable	var hackCiri			: bool;			default	hackCiri			= true;
	private editable	var behEventStart		: name;			default	behEventStart		= 'Skate_StartStep';
	private editable	var behEventEnd			: name;			default	behEventEnd			= 'AnimEndAux';
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'SkateIdle';
		}
		
		skateGlobal	= _Exploration.m_SharedDataO.m_SkateGlobalC;
		
		
		m_StateTypeE	= EST_Skate;
	}
	
	
	private function AddDefaultStateChangesSpecific()
	{
		AddStateToTheDefaultChangeList( 'SkateDashAttack' );
		AddStateToTheDefaultChangeList( 'SkateJump' );
		AddStateToTheDefaultChangeList( 'SkateHitLateral' );
	}

	
	function StateWantsToEnter() : bool
	{	
		
		return m_ExplorationO.GetStateTypeCur() != EST_Skate;
	}
	
	
	function StateCanEnter( curStateName : name ) : bool
	{	
		return true;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{				
		m_ExplorationO.m_MoverO.StopAllMovement();
		
		
		if( hackCiri )
		{		
			m_ExplorationO.m_OwnerE.SetBehaviorVariable( 'test_ciri_replacer', 1.0f);
			theGame.ChangePlayer( "Ciri" );
			
			thePlayer.GotoState('Skating');
			hackCiri	= false;
		}
		
		skateGlobal.SetActive( true );
		
		thePlayer.SetBIsCombatActionAllowed( false );
	}
	
	
	function StateChangePrecheck( )	: name
	{
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{				
		
		skateGlobal.UpdateRandomAttack();
		
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{		
			m_ExplorationO.SendAnimEvent( behEventStart );
			
			
			HackDirectionSet();
		}
		
		
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= m_ExplorationO.m_OwnerE.GetWorldForward();
		
		
		skateGlobal.SetBehParams( 0, 0, 0 );
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{		
		thePlayer.SetBIsCombatActionAllowed( true );
	}	
	
	
	private function HackDirectionSet()
	{
		var l_DirectionV		: Vector;
		var l_CamDirectionF		: float;
		var l_DirectionF		: float;
		
		
		
		l_DirectionV 	= theCamera.GetCameraDirection();			
		l_DirectionV.Z 	= 0;
		
		l_CamDirectionF = VecHeading( l_DirectionV );
		l_DirectionF	= thePlayer.GetHeading() - l_CamDirectionF;
		
		thePlayer.SetBehaviorVariable( 'rawPlayerHeading', l_DirectionF - 180);
		
		l_DirectionF = l_DirectionF - m_ExplorationO.m_InputO.GetHeadingOnPadF();
		
		
		
		thePlayer.GetMovingAgentComponent().SetGameplayMoveDirection( l_DirectionF );
		
		
	}
	
	
	
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if( animEventName	== behEventEnd )
		{
			SetReadyToChangeTo( 'SkateRun' );
			
			
			m_ExplorationO.m_MoverO.SetSpeedFromAnim();
		}
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		SetReadyToChangeTo( 'StartFalling' );
		
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{		
		return true;
	}	
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
}