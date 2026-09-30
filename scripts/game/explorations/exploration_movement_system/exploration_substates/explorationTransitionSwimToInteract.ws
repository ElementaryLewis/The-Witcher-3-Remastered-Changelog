/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CxplorationTransitionSwimToInteract extends CExplorationStateTransitionAbstract
{
	
	
	private			editable	var	enabled						: bool;						default	enabled				= false;
	private						var	transitionReadyToEnd		: bool;
	protected		editable	var	timeToTransition			: float;					default timeToTransition	= 1.0f;
	protected		editable	var	requireAngle				: bool;						default requireAngle		= false;
	protected		editable	var	timeToStopTrying			: float;					default	timeToStopTrying	= 1.5f;
	private						var locomotionSegment			: CR4LocomotionSwimToStop;
	private			editable	var	animEventToBeReady			: name;						default	animEventToBeReady	= 'ReadyToInteract';
	
	
	
	private function InitializeSpecific( _Exploration : CExplorationStateManager )
	{	
		if( !IsNameValid( m_StateNameN ) )
		{
			m_StateNameN	= 'TransitionSwimToInteract';
		}
		if( !IsNameValid( m_TransitionOriginStateN ) )
		{
			m_TransitionOriginStateN	= 'Swim'; 
		}
		if( !IsNameValid( m_TransitionEndStateN ) )
		{
			m_TransitionEndStateN	= 'Interaction';
		}
		
		m_StateTypeE	= EST_Idle;
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
		return enabled;
	}
	
	
	private function StateEnterSpecific( prevStateName : name )	
	{
		
		if( !locomotionSegment )
		{
			locomotionSegment	= new CR4LocomotionSwimToStop in thePlayer;
		}
		thePlayer.ActionDirectControl( locomotionSegment );
		
		transitionReadyToEnd	= false;
	}
	
	
	private function AddAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.AddAnimEventCallback( animEventToBeReady, 'OnAnimEvent_SubstateManager' );
	}
	
	
	function StateChangePrecheck( )	: name
	{
		if( transitionReadyToEnd )
		{
			if( !requireAngle || locomotionSegment.GetIsCloseEnough() )
			{
				if( m_ExplorationO.CanChangeBetwenStates( GetStateName(), 'Interaction' ) )
				{
					if( WantsToInteractWithExploration() )
					{
						return m_TransitionEndStateN;
					}
					
					else if( m_ExplorationO.GetStateTimeF() >= timeToStopTrying )
					{
						return 'Swim';
					}
				}
			}
		}
		return super.StateChangePrecheck();
	}
	
	
	protected function StateUpdateSpecific( _Dt : float )
	{
		
		if( m_ExplorationO.GetStateTimeF() >= timeToTransition )
		{
			transitionReadyToEnd	= true;
		}
	}
	
	
	private function StateExitSpecific( nextStateName : name )
	{
		thePlayer.SetDefaultLocomotionController();
	}
	
	
	private function RemoveAnimEventCallbacks()
	{
		m_ExplorationO.m_OwnerE.RemoveAnimEventCallback( animEventToBeReady );
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) 
	{ 
		if( animEventName == animEventToBeReady )
		{
			transitionReadyToEnd	= true;
		}
	}
	
	
	function ReactToLoseGround() : bool
	{
		return true;
	}
	
	
	private function WantsToInteractWithExploration() : bool
	{
		var exploration					: SExplorationQueryToken;
		var queryContext				: SExplorationQueryContext;
		var	explorationOwnerPosition	: Vector;
		var	explorationPosition			: Vector;
		var	explorationDirection		: Vector;
		var	speed						: Vector;
		
		
		
		exploration	= m_ExplorationO.m_SharedDataO.GetLastExploration();
		queryContext.inputDirectionInWorldSpace	= VecNormalize( exploration.pointOnEdge - m_ExplorationO.m_OwnerE.GetWorldPosition() );
		
		
		
		
		
		
		exploration = theGame.QueryExplorationSync( m_ExplorationO.m_OwnerE, queryContext );
		
		
		if ( !exploration.valid )
		{
			return false;
		}
		
		
		m_ExplorationO.m_SharedDataO.SetExplorationToken( exploration, GetStateName() );
		
		return true;
	}
	
	
	function CanInteract( ) :bool
	{		
		return true;
	}
}