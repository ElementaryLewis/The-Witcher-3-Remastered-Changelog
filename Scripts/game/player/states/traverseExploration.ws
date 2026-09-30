/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state TraverseExploration in CPlayer extends Base
{
	private var exploration : SExplorationQueryToken;
	default exploration = NULL;
	
	private var running : bool;
	default running = false;
	
	private var prevState : name;

	
	
	
	
	
	event OnEnterState( prevStateName : name )
	{
		super.OnEnterState(prevStateName);
		prevState = prevStateName;
		running = true;
		
		
		theGame.GetGameCamera().ChangePivotPositionController('Default');
		theGame.GetGameCamera().ChangePivotDistanceController('Default');
	
		if( exploration.type == ET_Ladder )
		{
			InitLadderTraverse( prevStateName );
		}
		else
		{
			parent.AddTimer( 'UpdateTraverser', 0.f, true, false, TICK_PrePhysics );
			ProcessExploration();
		}
	}

	entry function InitLadderTraverse( prevStateName : name )
	{
		
		parent.ActionTraverseExploration( exploration );
		parent.ActivateAndSyncBehavior( 'Gameplay' );

		if( prevStateName == 'Swimming' )
		{
			thePlayer.substateManager.SetBehaviorParamBool( 'fromWaterToLadder', true );
		}
	}




	event OnLadderStepFinished()
	{
		var traverser : CScriptedExplorationTraverser = parent.GetTraverser();
		traverser.AdjustStep();
	}



	event OnLadderJumpOnStarted()
	{

	}

	event OnLadderJumpOnFinished()
	{
		
	}



	event OnInitialLadderMotionStarted()
	{
		
		
		if( !thePlayer.IsCiri())
			thePlayer.SetUseNewLadderAnimations( true ); 
	}

	event OnInitialLadderMotionFinished()
	{
		thePlayer.substateManager.SetBehaviorParamBool( 'fromWaterToLadder', false );
		

		thePlayer.substateManager.m_SharedDataO.SetCanJumpOnLadder( false );
	}



	event OnLadderLoopStarted()
	{
		thePlayer.substateManager.m_SharedDataO.SetCanGetOffLadder(true);
		thePlayer.substateManager.SetBehaviorParamBool( 'ladderAtEnd' , false);
		thePlayer.substateManager.SetBehaviorParamBool( 'ladderCanMoveFromCatch', false );
	}

	event OnLadderLoopFinished()
	{
		
		
	}



	event OnSlideStarted()
	{
		thePlayer.substateManager.m_SharedDataO.SetCanGetOffLadder( true ); 
	}

	event OnSlideFinished()
	{
		thePlayer.substateManager.m_SharedDataO.SetLadderGetOffInterrupted(true); 
	}																				  



	event OnGettingOffLadderStarted()
	{	

	}

	event OnGettingOffLadderFinished()
	{
		
		thePlayer.substateManager.m_SharedDataO.SetLadderGetOffInterrupted(true); 
	}																			  	  
	



	event OnCanLeaveState( newState : name )
	{
		if ( newState == 'PlayerDialogScene' ) 
		{
			return true;
		}
		if(exploration.type == ET_Ladder)
		{
			return true;
		}

		return !running;
	}

	event OnLeaveState( nextStateName : name )
	{ 
		var traverser 			: CScriptedExplorationTraverser = parent.GetTraverser();
		LogAssert( !traverser, "TraverseExploration::SetExploration, 'traverser' is still set" );
		LogAssert( exploration.valid, "TraverseExploration::OnLeaveState, 'exploration' is still valid" );
	
		thePlayer.OnFinishTraversingExploration();

		exploration.valid = false;
		
		if(exploration.type != ET_Ladder) 
		{
			parent.RemoveTimer( 'UpdateTraverser' );
		}
		
		
		super.OnLeaveState(nextStateName);
		
		
		thePlayer.SetLadderCamReset(false);
		running = false;
	}
	
	
	
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{	
		var input : float;	

		moveData.pivotRotationController.StopRotating();		
		moveData.pivotRotationController.SetDesiredHeading(thePlayer.GetHeading(),0.4f);
		if(thePlayer.GetLadderCamReset())
			moveData.pivotRotationController.SetDesiredPitch(-15.f,0.7f);
		else
		{
			input = theInput.GetActionValue('GI_AxisLeftY');
			moveData.pivotRotationController.SetDesiredPitch(input * 30,0.5f);
		}
		if(thePlayer.GetExplCamera())
		{	
			moveData.pivotPositionController.SetDesiredPosition( thePlayer.GetWorldPosition() , 15.f );
			moveData.pivotDistanceController.SetDesiredDistance( 1.5f );	
			moveData.pivotPositionController.offsetZ = 1.15f;
			DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 6.0f, -3.1f, 1.2f ), 2.0f, dt );
		}
		
	}
	
	
	
	
	final function SetExploration( e : SExplorationQueryToken )
	{
		var traverser 			: CScriptedExplorationTraverser = parent.GetTraverser();
		LogAssert( exploration.valid, "TraverseExploration::SetExploration, 'exploration' is already set" );
		LogAssert( traverser, "TraverseExploration::SetExploration, 'traverser' is already set" );
		
		exploration = e;
	}
	
	entry function ProcessExploration()
	{
		var traverser 			: CScriptedExplorationTraverser = parent.GetTraverser();
		var actionResult : bool;
		
		if ( exploration.valid )
		{
			LogChannel( 'Exploration' , "Start..." );
			
			actionResult = parent.ActionExploration( exploration );
			if ( actionResult )
			{
				
				LogChannel( 'Exploration' , "TRUE" );
			}
			else
			{
				
				LogChannel( 'Exploration' , "FALSE" );
			}
			
			LogChannel( 'Exploration' , "End..." );
		}
		else
		{
			LogAssert( exploration.valid, "TraverseExploration::SetExploration, 'exploration' is not set" );
			LogAssert( traverser, "TraverseExploration::SetExploration, 'traverser' is not set" );
		}
		
		exploration.valid = false;
		traverser = NULL;
		
		running = false;
		
		parent.PopState();
	}
}