/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state Meditation in W3PlayerWitcher extends MeditationBase
{
	private var stopRequested : bool;						
	private var isSitting : bool;							
	
	
	private var closeUIOnStop : bool;						
	private var isLeavingState : bool;				
	private var isEntryFunctionLocked : bool;				
	private var scheduledGoToWaiting : bool;				
	private var waitBeforeGoToWaiting : float;				
	private var changedContext : bool;						
	private var waitForStandUpFinish : bool;
	private var fallCancel : bool;
	private var rotationRequested : bool;
	
		default scheduledGoToWaiting = false;
		default waitForStandUpFinish = true;
	
	

	event OnEnterState( prevStateName : name )
	{
		parent.AddAnimEventCallback('AllowRotation', 'OnAnimEvent_AllowRotation');
		
		super.OnEnterState(prevStateName);
		
		parent.ResetMeditationPointHeading();
		isLeavingState = false;
		rotationRequested = false;
		waitBeforeGoToWaiting = 0.f;
		parent.SetMeditationCameraHeadingMult( 0.5f );
		
		if(prevStateName != 'MeditationWaiting')
		{
			stopRequested = false;
			closeUIOnStop = false;
		}
		
		InitState(prevStateName);
	}
	
	event OnLeaveState( nextStateName : name )
	{
		var inv 	     			: CInventoryComponent;
		
		
		if(nextStateName != 'MeditationWaiting')
		{
			FactsAdd('MeditationWaitFinished', 1, 1);					
		}

		virtual_parent.BlockAllActions('Meditation', false);
		
		virtual_parent.SetBehaviorVariable( 'MeditateAbort', 0 );


		
		super.OnLeaveState(nextStateName);
		
		
		theSound.SoundEvent("gui_meditation_close");

		theGame.GetGameCamera().EnableManualControl( true );
	}
	
	entry function InitState(prevStateName : name)
	{
		var actionSuccess : bool;

		var floor : Vector;
		var currentPos : Vector;

		var blockExceptions : array<EInputActionBlock>;

		var commonMenuRef 	: CR4CommonMenu;

		virtual_parent.LockEntryFunction( true );
		isEntryFunctionLocked = true;
		
		virtual_parent.SetBehaviorVariable('MeditateAbort', 0);		

		
		blockExceptions.PushBack(EIAB_RadialMenu);
		blockExceptions.PushBack(EIAB_OpenMeditation);
		blockExceptions.PushBack(EIAB_OpenFastMenu);
		blockExceptions.PushBack(EIAB_OpenGlossary);
		virtual_parent.BlockAllActions('Meditation', true, blockExceptions, true);

		
		virtual_parent.OnMeleeForceHolster(true);
		virtual_parent.OnRangedForceHolster(true);

		if ( virtual_parent.IsCurrentlyUsingItemL() )
			virtual_parent.HideUsableItem();
		
		if(prevStateName != 'MeditationWaiting')
		{
			menuNotYetOpen = true;
			isSitting = false;
			SetWaitForStand( true );
						
			
			while( !parent.IsMeditationHeadingSet() )
			{
				SleepOneFrame();
			}

			if(!theGame.GetGuiManager().IsAnyMenu())
			{
				changedContext = true;
				theInput.StoreContext( 'Meditation' );
			}
			else
			{
				changedContext = false;
			}
			
			if( !((W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' )).GetWasUsed() )
			{
				
				currentPos = virtual_parent.GetWorldPosition();
				floor = TraceFloor( currentPos );
				if ( currentPos.Z - floor.Z > 0.2 && !virtual_parent.IsOnBoat() )
				{
					actionSuccess = false;
					fallCancel = true;
				}
				else
				{
					commonMenuRef = theGame.GetGuiManager().GetCommonMenu();
					if ( commonMenuRef )
					{
						if ( commonMenuRef.m_had_meditation )
						{
							
							virtual_parent.SetBehaviorVariable('MeditateWithIgnite', 0);
							actionSuccess = virtual_parent.PlayerStartAction(PEA_Meditation);
						}
						else
						{
							actionSuccess = true;
						}
					}
					else	
					{
						
						virtual_parent.SetBehaviorVariable('MeditateWithIgnite', 0);
						actionSuccess = virtual_parent.PlayerStartAction(PEA_Meditation);
						menuNotYetOpen = true;
					}
				}
			}
			else
			{
				actionSuccess = true;
			}
		}
		else
		{
			actionSuccess = true;
			
			if(!stopRequested)
			{
				
				
			}
		}
		
		virtual_parent.LockEntryFunction( false );
		isEntryFunctionLocked = false;
		
		
		if(!actionSuccess)
		{
			SetWaitForStand( false );
			StopRequested(true);
		}
		
		Loop();
	}
	
	public function IsSitting() : bool
	{
		return isSitting;
	}
	
	event OnAnimEvent_OpenUI( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		var mutagen : CBaseGameplayEffect;

		super.OnAnimEvent_OpenUI( animEventName, animEventType, animInfo );
		
		if( !stopRequested )	
		{
			isSitting = true;
			isLeavingState = false;
						
			
			if(thePlayer.HasBuff(EET_Mutagen06))
			{
				mutagen = thePlayer.GetBuff(EET_Mutagen06);
				thePlayer.RemoveAbilityAll(mutagen.GetAbilityName());
			}
			
			
			
			OpenUI( 2.f );
		}
	}

	event OnAnimEvent_AllowRotation( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		

		var movementAdjustor	: CMovementAdjustor;
		var ticket 				: SMovementAdjustmentRequestTicket;
		var customRotationName 	: name;

		if ( rotationRequested )
			return true;

		customRotationName = 'Meditation';
	
		movementAdjustor = parent.GetMovingAgentComponent().GetMovementAdjustor();
		ticket = movementAdjustor.GetRequest( customRotationName );
		movementAdjustor.Cancel( ticket );
		ticket = movementAdjustor.CreateNewRequest( customRotationName );
		movementAdjustor.ReplaceRotation( ticket );
		movementAdjustor.BindToEventAnimInfo( ticket, animInfo );
		movementAdjustor.RotateTo( ticket, parent.GetMeditationPointHeading() );
		rotationRequested = true;
	}
	
	
	
	public function StopRequested(optional closeUI : bool)
	{
		stopRequested = true;
		closeUIOnStop = closeUI;
		virtual_parent.SetBehaviorVariable('MeditateAbort', 1);
	}
	
	private entry function Loop()
	{
		while(!stopRequested)
		{
			if ( scheduledGoToWaiting )
			{
				SleepIgnoreTimeScale( waitBeforeGoToWaiting );
				scheduledGoToWaiting = false;
				if ( !stopRequested )
					virtual_parent.PushState('MeditationWaiting');
			}
			SleepIgnoreTimeScale( 0.2f );
		}
		StopMeditation();
	}
	
	
	public latent function StopMeditation()
	{
		var commonMenuRef 	: CR4CommonMenu;
		var l_bed			: W3WitcherBed;
		var stopPlayerAction: bool;
	
		isLeavingState = true;
		
		
		if(closeUIOnStop)
		{
			CloseUI();
		}		
	
		virtual_parent.SetBehaviorVariable('HasCampfire', 0);
		
		l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );
		
		if( !l_bed.GetWasUsed() )
		{
			if ( virtual_parent.GetPlayerAction() == PEA_Meditation )
			{
				virtual_parent.PlayerStopAction( PEA_Meditation );
			}
		}
		else
		{
			virtual_parent.PlayerStopAction( PEA_GoToSleep );
		}
		
		if( l_bed.GetWasUsed() )
		{
			waitForStandUpFinish = false;
			l_bed.SetWasUsed( false );
		}
		
		
		thePlayer.abilityManager.SetStatPointCurrent(BCS_Air, thePlayer.GetStatMax(BCS_Air));
		thePlayer.RemoveAllBuffsOfType(EET_AutoAirRegen);
		thePlayer.AddEffectDefault(EET_AutoAirRegen, thePlayer, "meditation_reset", false);
		
		
		
		if(changedContext)
		{
			theInput.RestoreContext('Meditation', false);
		}

		if ( waitForStandUpFinish )
		{
			
			virtual_parent.WaitForBehaviorNodeDeactivation( 'PlayerActionEnd', 3);
		}

		if ( fallCancel )		
			SleepOneFrame();
		
		if(virtual_parent.GetCurrentStateName() == 'Meditation')
			virtual_parent.PopState(true);		
	}
	
	
	public function MeditationWait(targetHour : int, optional delay : float)
	{
		var l_bed : W3WitcherBed;
		l_bed = (W3WitcherBed)theGame.GetEntityByTag( 'witcherBed' );

		LogChannel( 'CLOCK', "MeditationWait, targetHour "+targetHour);
		virtual_parent.SetWaitTargetHour(targetHour);
		
		
		if(!isEntryFunctionLocked)
		{
			if ( virtual_parent.GetPlayerAction() != PEA_Meditation && !l_bed.GetWasUsed() )
			{
				virtual_parent.SetBehaviorVariable('MeditateWithIgnite', 0);
				virtual_parent.PlayerStartAction(PEA_Meditation);
			}

			RequestGoToWait( delay );
		}
		else
		{
			if ( delay <= 0 )
				delay = 0.01f;

			RequestGoToWait( delay );
		}
	}

	private function RequestGoToWait( optional delay : float )
	{
		if ( delay <= 0 )
		{
			virtual_parent.PushState('MeditationWaiting');
		}
		else
		{
			waitBeforeGoToWaiting = delay;
			scheduledGoToWaiting = true;
		}
	}
		
	

	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{
		if( !isLeavingState )
		{
			super.OnGameCameraTick(moveData, dt);
			return true;
		}
		
		return false;
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		var rotation : EulerAngles = parent.GetWorldRotation();
		
		if( isLeavingState )
		{
			if( parent.GetExplCamera() )	
			{
				moveData.pivotDistanceController.SetDesiredDistance( 1.5f, 0.25f );
			}
			else if ( parent.IsModernExplorationCamera() )
			{
				moveData.pivotDistanceController.SetDesiredDistance( 2.25f, 0.25f );
			}
			moveData.pivotRotationController.SetDesiredHeading( rotation.Yaw, 0.5f );
		}
	}

	event OnPlayerTickTimer( deltaTime : float )
	{
		super.OnPlayerTickTimer( deltaTime );

		if ( !virtual_parent.bLAxisReleased )
		{
			StopRequested( true );
		}

		if ( virtual_parent.substateManager.m_InputO.IsJumpPressed() )
		{
			StopRequested( true );
		}
	}

	function IsLeavingState() : bool
	{
		return isLeavingState;
	}

	function SetWaitForStand( val : bool )
	{
		waitForStandUpFinish = val;
	}
}