/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationStateRoll extends CExplorationStateAbstract
{
	protected editable			var	m_TimeSafetyEndF		: float;		default m_TimeSafetyEndF			= 3.0f;
	protected editable			var	m_OrientationSpeedF		: float;		default	m_OrientationSpeedF			= 20.0f;
	private	  editable			var m_AutoRollB				: bool;			default	m_AutoRollB					= true;
	protected editable			var	m_RollMinHeightF		: float;		default	m_RollMinHeightF			= 0.3f;
	protected editable			var	m_RollTimeAfterF		: float;		default	m_RollTimeAfterF			= 0.1f;
	private						var	m_ReadyToEndB			: bool;
	private						var	m_ReadyToFallB			: bool;
	
	
	protected editable			var	m_BehLandRunS			: name;			default	m_BehLandRunS				= 'LandWalking';
	protected editable			var	m_BehLandCancelN		: name;			default	m_BehLandCancelN 			= 'AnimEndAUX';
	protected editable			var	m_BehLandCanEndN		: name;			default	m_BehLandCanEndN 			= 'LandEnd';
	protected editable			var	m_BehLandCanFallN		: name;			default	m_BehLandCanFallN			= 'LandCanFall';
	
	
	
	protected 					var m_SlidingB				: bool;
	protected editable			var	m_SlideTimeToDecideF	: float;		default	m_SlideTimeToDecideF		= 0.4f;
	
	
	private						var	m_ToFallB				: bool;
	private	editable			var	verticalMovementParams	: SVerticalMovementParams;
	
	
	private						var	m_ToSlideB				: bool;
	
	
	protected editable			var	m_TimeBeforeChainJumpF	: float;
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'Roll';
		}
		
		m_StateTypeE		= EST_Idle;
		m_InputContextE		= EGCI_JumpClimb; 
		m_HolsterIsFastB	= true;
		
		
		LogExplorationRoll( "	Initialized Log channel: ExplorationStateRoll" );
	}
	
	
	protected function AddActionsToBlock()
	{
		AddActionToBlock( EIAB_Signs );
		AddActionToBlock( EIAB_Fists );
		AddActionToBlock( EIAB_SwordAttack );
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
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		
		m_ReadyToEndB	= false;
		m_ReadyToFallB	= false;
		m_ToFallB		= false;
		
		
		
		m_SlidingB		= m_ExplorationO.StateWantsAndCanEnter('Slide');
		
		if( !m_SlidingB )
		{		
			
			m_ExplorationO.m_MoverO.StopVerticalMovement();
			m_ExplorationO.m_MoverO.StopAllMovement();
			
			theGame.VibrateControllerLight();	
		}
		
		
		m_SlidingB		= false; 
		
		
		BlockActions();
		thePlayer.OnRangedForceHolster();
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( false );
		
		
		m_ExplorationO.m_MoverO.SetVerticalMovementParams( verticalMovementParams );
		
		
		thePlayer.RemoveBuff(EET_Burning);
		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible( thePlayer, 'PlayerJumpAction', 3.f, 8.f, -1, 9999, true ); 
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( m_BehLandCanEndN,		'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( m_BehLandCanFallN,	'OnAnimEvent_SubstateManager' );
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( m_BehLandCancelN,		'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{		
		var slideDir 	: Vector;
		var slideNormal	: Vector;
		
		
		
		if( CanChainJump() )
		{
			if( m_ExplorationO.StateWantsAndCanEnter( 'Jump' ) )
			{
				LogExplorationRoll( " Exited by chaining a jump" );
				return 'Jump';
			}
		}
		
		
		if( m_SlidingB && m_ExplorationO.GetStateTimeF() >= m_SlideTimeToDecideF )
		{
			return 'Slide';
		}
		
		
		if( m_ExplorationO.GetStateTimeF() > 0.0f ) 
		{
			if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Idle' ) )
			{		
				
				if( m_ReadyToEndB || m_ReadyToFallB )
				{
					if( m_ToFallB ) 
					{
						LogExplorationRoll( " Exited by fall" );
						return 'StartFalling';
					}
					else if( m_SlidingB )
					{
						return 'Slide';
					}
					else if( m_ReadyToEndB && m_ExplorationO.m_InputO.IsModuleConsiderable() )
					{
						m_ExplorationO.SendAnimEvent( m_BehLandCancelN );
						LogExplorationRoll( " Exited by Movement once ready" );
						return 'Idle';
					}
				}
				
				
				if( m_ExplorationO.GetStateTimeF() >= m_TimeSafetyEndF )
				{
					LogExplorationRoll( " Exited by safety time out." );
					if( m_SlidingB )
					{
						return 'Slide';
					}
					else
					{
						return 'Idle';
					}
				}
			}
		}
		
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{	
		if( m_ExplorationO.GetStateTimeF() < m_SlideTimeToDecideF )
		{
			m_SlidingB	= m_ExplorationO.StateWantsAndCanEnter('Slide');
		}
		
		
		RunOrIdleUpdate();
		
		FallUpdate( _Dt );
		
		m_ExplorationO.m_MoverO.UpdateOrientToInput( m_OrientationSpeedF, _Dt );
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		if( nextStateName == 'Idle' )
		{
			m_ExplorationO.SendAnimEvent( m_BehLandCancelN );
		}
		
		thePlayer.SetBIsCombatActionAllowed( true );
		thePlayer.SetBIsInCombatAction(false);
		thePlayer.ReapplyCriticalBuff();
		
		
		m_ExplorationO.m_MoverO.SetVelocity( m_ExplorationO.m_OwnerMAC.GetVelocity() );
		
		
		thePlayer.OnCombatActionEndComplete();
		
		
		m_ExplorationO.m_OwnerMAC.SetEnabledFeetIK( true );
		
		
		m_ExplorationO.m_SharedDataO.SetTerrainSlopeSpeed( 10.0f );
		
		
		if( nextStateName != 'Slide' || nextStateName != 'StartFalling' )
		{
			thePlayer.GoToCombatIfWanted();
		}
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( m_BehLandCanEndN );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( m_BehLandCanFallN );
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( m_BehLandCancelN );
	}
	
	
	function CanInteract( ) :bool
	{		
		return false;
	}
	
	
	private function FallUpdate( _Dt : float )
	{
		if( m_ToFallB )
		{
			m_ExplorationO.m_MoverO.UpdatePerfectMovementVertical( _Dt );
			m_ExplorationO.m_SharedDataO.UpdateFallHeight();
		}
	}
	
	
	private function RunOrIdleUpdate()
	{		
		var isWalking	: float;
		
		
		
		if( thePlayer.GetIsWalking() )
		{
			if( thePlayer.GetIsRunning() )
			{
				isWalking	= 1.0f;
			}
			else
			{
				isWalking	= 0.5f;
			}
		}
		else
		{
			isWalking	= 0.0f;
		}
		
		
		m_ExplorationO.m_OwnerE.SetBehaviorVariable( m_BehLandRunS, isWalking );
	}	
	
	
	private function CanChainJump() : bool
	{
		
		if( m_ExplorationO.GetStateTimeF() <= m_TimeBeforeChainJumpF )
		{
			return false;
		}
		
		return true;
	}
	
	
	
	
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		if ( animEventName == m_BehLandCanEndN )
		{
			m_ReadyToEndB	= true;
		}
		else if( animEventName == m_BehLandCanFallN )
		{
			m_ReadyToFallB	= true;
		}
		else if( animEventName == m_BehLandCancelN )
		{		
			LogExplorationRoll( " SetReadyToChangeTo: Beh land cancel event received" );
			SetReadyToChangeTo( 'Idle' );
		}
	}
	
	
	
	
	
	
	function ReactToLoseGround() : bool
	{
		m_ToFallB	= true;
		
		return true;
	}
	
	
	function ReactToHitGround() : bool
	{
		var normal, dir : Vector;
		
		m_ToFallB	= false;
		
		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( dir, normal );
		m_ExplorationO.m_MoverO.RemoveSpeedOnThisDirection( normal );
		
		return true;
	}	
	
	
	
	
	function ReactToBeingHit( optional damageAction : W3DamageAction ) : bool
	{
		
		return m_ExplorationO.GetStateTimeF() < m_ExplorationO.m_SharedDataO.m_SkipLandAnimTimeMaxF;
		
	}

	
	private function LogExplorationRoll( text : string )
	{
		LogChannel( 'ExplorationState'			,GetStateName() + text );
		LogChannel( 'ExplorationStateLandExit'	, text );
	}
}