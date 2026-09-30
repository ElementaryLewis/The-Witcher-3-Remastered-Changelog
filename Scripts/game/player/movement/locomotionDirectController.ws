/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CR4LocomotionDirectController extends CObject
{
	import protected var agent : CMovingAgentComponent;
	import protected var moveSpeed : float;
	import protected var moveRotation : float;
};

import class CR4LocomotionDirectControllerScript extends CR4LocomotionDirectController
{
	function Activate() : bool
	{
		return true;
	}
	
	function UpdateLocomotion()
	{
	}
	
	function Deactivate()
	{
	}
};

class CR4LocomotionPlayerControllerScript extends CR4LocomotionDirectControllerScript
{
	var player 					: CR4Player;
	var angularInputSpeed 		: float;
	var worldMoveDirection 		: float;
	var localMoveDirection 		: float;
	var previousInputVector 	: Vector;
	var timerValue				: float;
	var angularSpeed			: float;
	
	var _inputLocoEnabled		: bool;		default _inputLocoEnabled = true;
	var _inputVecCurr			: Vector;
	var _inputVecPrev			: Vector;
	var _inputHeading180Curr	: float;	default _inputHeading180Curr = 0.f;
	var _inputHeading180Prev	: float;	default _inputHeading180Prev = 0.f;
	var _inputHeading180LastCached : float;	default _inputHeading180LastCached = 0.f;
	var _inputMagCurr			: float;	default _inputMagCurr = 0.f;
	var _inputMagPrev			: float;	default _inputMagPrev = 0.f;
	var _inputMagDiffCurr		: float;	default _inputMagDiffCurr = 0.f;
	var _inputMagDiffPrev		: float;	default _inputMagDiffPrev = 0.f;
	var _inputMagLastCached		: float;	default _inputMagLastCached = 0.f;
	
	
	var speedSlowWalkingMax	 	: float;	default	speedSlowWalkingMax	 	= 0.3f;
	var speedWalkingMax			: float;	default	speedWalkingMax			= 0.6f;
	var speedRunning			: float;	default	speedRunning			= 1.0f;
	var speedSprinting			: float;	default	speedSprinting			= 1.5f;
	var speedSprintingWithPerk	: float;	default	speedSprintingWithPerk	= 1.6f;
	
	var	maxTerrainPitchToWalkUp	: float;	default	maxTerrainPitchToWalkUp	= 70.0f;
	
	
	var prevPosition			: Vector;
	var prevRotation			: EulerAngles;
	
	
	function Activate() : bool
	{
		player = (CR4Player)agent.GetEntity();
	
		_inputVecCurr = Vector(0.f,0.f,0.f);
		_inputVecPrev = Vector(0.f,0.f,0.f);
		
		player.SetBehaviorVariable( 'AIControlled', 0.f ); 
		stopCheckEnabled = false;
	
		return super.Activate();
	}

	function Deactivate()
	{
		var movingAgentComponent 	: CMovingAgentComponent = player.GetMovingAgentComponent();
		
		player.SetBehaviorVariable( 'inputDirectionIsNotReady', 0.f ); 
		player.SetBehaviorVariable( 'AIControlled', 1.f ); 
		
		player.UpdateRequestedDirectionVariables_PlayerDefault();
		
		player.SetIsRunning( false );
		player.SetIsWalking( false );
		
		movingAgentComponent.SetGameplayRelativeMoveSpeed( 0.0f );
		movingAgentComponent.UnsetGameplayMoveDirection();
		
		stopCheckEnabled = false;
			
		super.Deactivate();
	}
	
	
	var cachedMoveSpeed : float;
	var stoppedTimeStamp : float;
	var stopCheckEnabled : bool;
	var stoppedTimeStampDelta : float;
	function UpdateLocomotion()
	{
		
		
		
		
		
	
		var inputInCameraSpace, inputAngleToRotate, previousSpeed, haxStrafe, haxForward : float;		
		var playerYaw				: float;
		var forcedDirection			: float;
		var movingAgentComponent 	: CMovingAgentComponent = player.GetMovingAgentComponent();
		var currPosition, diffPosition	: Vector;
		var currRotation			: EulerAngles;
		var diffRotation			: float;
		var inputHeading180_WS, inputHeading360_WS, inputHeading180_CS, cameraHeading360_WS, inputMagDiff : float;
		var currentTime : float;
			
		
		if ( player.IsUITakeInput() )
		{
			return;
		}
		
		previousSpeed = movingAgentComponent.GetRelativeMoveSpeed();
		
		
		_inputVecPrev = _inputVecCurr;
		_inputVecCurr = CalculateInputVector();
		
		
		_inputHeading180Prev = _inputHeading180Curr;
		_inputMagPrev = _inputMagCurr;
		
		
		ConvertVecToHeadingWS180AndMag( _inputVecCurr, inputHeading180_WS, _inputMagCurr );
		inputHeading360_WS = AngleNormalize( inputHeading180_WS );
		
		
		cameraHeading360_WS = GetCameraHeading360WS();
		inputHeading180_CS = AngleNormalize180( inputHeading360_WS + cameraHeading360_WS );
		
		
		_inputMagDiffPrev = _inputMagDiffCurr;
		_inputMagDiffCurr = _inputMagCurr - _inputMagPrev;
		
		
		_inputHeading180Curr = inputHeading180_CS;
		
		
		playerYaw = player.GetHeading();
		
		
		UpdateInputReadyness();
		
		
		
		
		player.GetVisualDebug().AddArrow( 'input01', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( cameraHeading360_WS ), 1.f, 0.1f, 0.1f, true, Color(0,255,0), true );
		
		player.GetVisualDebug().AddArrow( 'input02', player.GetWorldPosition(), player.GetWorldPosition() + player.GetHeadingVector(), 1.f, 0.1f, 0.1f, true, Color(128,128,128), true );
		
		
		player.GetVisualDebug().AddArrow( 'input04', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( _inputHeading180LastCached ), 1.f, 0.2f, 0.2f, true, Color(255,0,255), true );
		
		if( player.GetIsMovable() && player.GetCurrentStateName() != 'PlayerDialogScene' )
		{					
			
			if( HasToForceToFall( forcedDirection ) )
			{
				localMoveDirection	= forcedDirection;
				moveSpeed			= MaxF( moveSpeed, 0.5f );
				
				
				_inputHeading180Curr		= (localMoveDirection * -180.0f) + playerYaw;
				_inputHeading180LastCached	= _inputHeading180Curr;
				
				MakeInputReady();
			} 
			
			else if( HasToStopBecauseOfSlope() )
			{
				moveSpeed					= 0.0f;
				_inputHeading180Curr		= playerYaw;
				_inputHeading180LastCached	= _inputHeading180Curr;
				
				MakeInputReady();
			}
			else
			{
				angularInputSpeed	= CalculateInputAngularSpeed();
				localMoveDirection	= CalculateLocalMoveDirection();
				moveSpeed 			= CalculateMoveSpeed();
				
				currentTime = theGame.GetEngineTimeAsSeconds();
				if ( moveSpeed <= 0 )
				{				
					if ( !stopCheckEnabled )
					{
						stopCheckEnabled = true;
						stoppedTimeStamp = currentTime;
						moveSpeed = cachedMoveSpeed;

						if ( theInput.LastUsedPCInput() )
							stoppedTimeStampDelta = 0.15f;
						else
							stoppedTimeStampDelta = 0.05f;
					}
					else if ( currentTime > stoppedTimeStamp + stoppedTimeStampDelta )
					{
						moveSpeed = 0;
					}
					else 
						moveSpeed = cachedMoveSpeed;	
				}
				else
				{
					stopCheckEnabled = false;
					cachedMoveSpeed = moveSpeed;
				}
				
				localMoveDirectionPrevFrame = localMoveDirection;
				
				
				currPosition = player.GetWorldPosition();
				currRotation = player.GetWorldRotation();
				
				diffPosition = currPosition - prevPosition;
				diffRotation = AngleDistance( currRotation.Yaw, prevRotation.Yaw );
				
				
				
				
				
				
				
				
				
				
				prevPosition = currPosition;
				prevRotation = currRotation;
				
				
				ProcessMovementEvent();
				
				if( thePlayer.substateManager.m_MovementCorrectorO.ModifySpeedRequired( moveSpeed ) )
				{
					MakeInputReady();
				}	
				
				
				if( thePlayer.HasBuff( EET_OverEncumbered ) )
				{
					moveSpeed	= MinF( moveSpeed, speedWalkingMax );
				}
			}
		}
		else
		{
			player.playerMoveType 	= PMT_Idle;
			angularInputSpeed 		= 0;
			moveSpeed 				= 0;
			localMoveDirection 		= 0;
		}
		
		
		
		
		player.SetSubmergeDepth( ((CMovingPhysicalAgentComponent)player.GetMovingAgentComponent()).GetSubmergeDepth() );
		player.SetBehaviorVariable( 'submergeDepth', player.GetSubmergeDepth() );
		
		if ( player.OnAllowShallowWaterCheck() && !player.IsSwimming() && player.GetSubmergeDepth() <= -0.9 )
		{
			player.OnEnterShallowWater();
		}
		else
		{
			player.OnExitShallowWater();
		}

		
		if ( player.IsSwimming() && moveSpeed <= 0.f)
		{
			ResetMoveDirection();
			worldMoveDirection = player.GetHeading();
		}
		else
		{
			
			if ( _inputLocoEnabled )
			{
				worldMoveDirection = _inputHeading180LastCached;
			}
			
			else if ( moveSpeed > 0.f )
			{
				worldMoveDirection 	= (localMoveDirection * -180.0f) + playerYaw;
			}
		}
		
		
		
		if( player.IsOnBoat() )
		{
			moveSpeed = MinF( speedSlowWalkingMax, moveSpeed );
		} 

		if ( !player.CanUpdateMovement() )
		{
			movingAgentComponent.SetGameplayRelativeMoveSpeed( 0.f );
			player.SetBehaviorVariable( 'test_moveSpeed', 0.f );
			
			if ( !player.IsInputHeadingReady() )
				moveSpeed = 0;
				
				
			
			if( VecLengthSquared( movingAgentComponent.GetVelocity() ) < 0.25f && player.GetCurrentStateName() != 'AimThrow' )
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', 0.0f, true );
			}
			else
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', moveSpeed, true );
			}
			movingAgentComponent.SetGameplayMoveDirection( playerYaw );
		}
		else
		{
			movingAgentComponent.SetGameplayRelativeMoveSpeed( moveSpeed );
			player.SetBehaviorVariable( 'test_moveSpeed', moveSpeed);
			
			if( VecLengthSquared( movingAgentComponent.GetVelocity() ) < 0.25f )
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', 0.0f, true );
			}
			else
			{
				player.SetBehaviorVariable( 'playerSpeedForOverlay', moveSpeed, true );
			}
			movingAgentComponent.SetGameplayMoveDirection( worldMoveDirection );
		}
		
		
		movingAgentComponent.SetDirectionChangeRate( 10000.0f );
		
		player.SetBehaviorVariable( 'playerInputAngSpeed', angularInputSpeed);
		
		UpdateRequestedDirectionVariables( worldMoveDirection, theCamera.GetCameraHeading());
		
		
		player.GetVisualDebug().AddArrow( 'heading1', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( worldMoveDirection ), 1.f, 0.4f, 0.2f, true, Color(255,0,0), true );
		
		player.SetBehaviorVariable( 'actorMoveDirection', localMoveDirection );
		
		
		angularSpeed = 512.f;
		if ( inputAngleToRotate < 0.f )
		{
			angularSpeed = -angularSpeed;
		}
		player.SetBehaviorVariable( 'inputSpeedToRotate', angularSpeed );
		
		
		
		player.SetIsWalking( moveSpeed > 0.1f );
		player.SetIsRunning( moveSpeed > 0.85f ); 
	}

	function OnTeleported()
	{
		

		if ( player.IsSwimming() )
		{
			ResetMoveDirection();
			worldMoveDirection = player.GetHeading();
			moveSpeed = 0;
			angularInputSpeed = 0;
			cachedMoveSpeed = 0;
		}
	}
	
	private function UpdateInputReadyness()
	{
		var inputHeadingReady, inputMagReady, canRecalcInputHeading : bool;
		
		
		inputHeadingReady = true;
		inputMagReady = true;
		canRecalcInputHeading = false;
		
		
		if ( AbsF( _inputMagDiffCurr ) > 0.2f ) 
		{
			
			inputHeadingReady = false;
			inputMagReady = false;
			canRecalcInputHeading = true;
		}
		
		
		if ( inputHeadingReady && _inputMagCurr < 0.001f && _inputMagPrev > 0.1f )
		{
			
			inputHeadingReady = false;
			canRecalcInputHeading = true;
			
		}
		
		
		if ( inputHeadingReady && _inputMagDiffCurr < 0.f && AbsF( _inputVecCurr.X ) < 0.001f && AbsF( _inputVecCurr.Y ) > 0.001f && _inputVecCurr.Y < _inputVecPrev.Y  )
		{
			
			inputHeadingReady = false;
			
		}
		
		
		if ( inputHeadingReady && _inputMagCurr < 0.1f )
		{
			
			inputHeadingReady = false;
			
		}
		
		
		if ( inputHeadingReady && _inputMagPrev < 0.001f && _inputMagCurr > 0.001f )
		{
			
			inputHeadingReady = false;
			inputMagReady = false;
		}
		
		
		if ( canRecalcInputHeading && _inputMagPrev > 0.001f && _inputMagDiffCurr > 0.001f && _inputMagDiffPrev < 0.001f )
		{
			
				
			_inputHeading180Curr = _inputHeading180Prev;
				
			inputHeadingReady = true;
			inputMagReady = true;
		}
		
		else if ( canRecalcInputHeading && _inputMagPrev > 0.001f && _inputMagDiffCurr < 0.001f && _inputMagDiffPrev > 0.001f )
		{
			
				
			_inputHeading180Curr = _inputHeading180Prev;
			_inputMagCurr = _inputMagPrev;
				
			inputHeadingReady = true;
			inputMagReady = true;
		}
		
		
		if ( inputHeadingReady )
		{
			_inputHeading180LastCached = _inputHeading180Curr;
			
			
			
			player.SetBehaviorVariable( 'inputDirectionIsNotReady', 0.f ); 
		}
		else
		{
			
			
			
			player.SetBehaviorVariable( 'inputDirectionIsNotReady', 1.f ); 
		}
		
		player.SetInputHeadingReady( inputHeadingReady );
		
		if ( inputMagReady )
		{
			_inputMagLastCached = _inputMagCurr;
		}
	}	
	
	private function MakeInputReady()
	{
		player.SetBehaviorVariable( 'inputDirectionIsNotReady', 0.f ); 
	}
	
	private function HasToForceToFall( out direction : float ) : bool
	{
		var fallingDir		: Vector;
		var thrownEntity	: CThrowable;
		
		thrownEntity = (CThrowable)EntityHandleGet( thePlayer.thrownEntityHandle );
		
		
		if( thePlayer.rangedWeapon && thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait' )
		{
			return false;
		}		
		if( thrownEntity )
		{
			return false;
		} 
		
		
		if( thePlayer.substateManager.m_CollisionManagerO.GetHasToFallInDirection( direction ) )
		{			
			return true;
		}
		
		return false;
	}
	
	private function HasToStopBecauseOfSlope() : bool
	{
		
		
		
		var direction	: Vector;
		var	pitch		: float;
		
		
		pitch		= player.terrainPitch;
		if( pitch < 90.0f - maxTerrainPitchToWalkUp )
		
		
		
		
		{
			if(  thePlayer.substateManager.m_InputO.IsModuleConsiderable() )
			{
				direction	= thePlayer.substateManager.m_MoverO.GetSlideDir();
				if( VecDot( direction, thePlayer.substateManager.m_InputO.GetMovementOnPlaneNormalizedV() ) < -0.2f )
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	function CalculateLocalMoveDirection() : float
	{
		var direction			: float;
		var playerDirCamSpace	: float;
		var moveDir				: Vector;
		var anyInput			: bool;
		var corrected			: bool;
		
		
		
		playerDirCamSpace = GetPlayerHeadingInCamSpace();
		
		
		player.SetBehaviorVariable( 'rawPlayerHeading', playerDirCamSpace - 180);
		
		
		moveDir	= GetInputInPlayerSpace( playerDirCamSpace, anyInput );
		
		
		moveDir	= CorrectDirection( moveDir, anyInput, corrected ); 
		
		
		if( !anyInput )
		{
			return 0.0f;
		}
		
		
		if( corrected )
		{
			_inputHeading180Curr		= VecHeading( moveDir );
			_inputHeading180LastCached	= _inputHeading180Curr;
		}
		
		
		direction	= -(VecHeading( moveDir ) - player.GetHeading()); 
		
		
		direction	= AngleNormalize180( direction );
		direction	= direction / 180.0f;
		
		return direction;
	}
	

	public function ResetMoveDirection()
	{
		if(player)
			_inputHeading180LastCached = player.GetHeading();
	}
	
	private function GetCameraHeading360WS() : float
	{
		var cameraDirection : Vector;
		var camHeading		: float;
		
		cameraDirection		= theCamera.GetCameraDirection();
		cameraDirection.Z	= 0.f;
		cameraDirection.W	= 1.f;
		cameraDirection 	= VecNormalize2D( cameraDirection );
		camHeading			= AngleNormalize( VecHeading( cameraDirection ) );
		
		return camHeading;
	}
	
	private function GetHeadingInCamSpace( heading : float ) : float
	{
		var cameraDirection : Vector;
		var camHeading		: float;
		
		cameraDirection		= theCamera.GetCameraDirection();
		cameraDirection.Z	= 0.f;
		cameraDirection.W	= 1.f;
		cameraDirection 	= VecNormalize2D( cameraDirection );
		camHeading			= AngleNormalize( VecHeading( cameraDirection ) );
		heading				= AngleNormalize( heading );		
		
		return AngleNormalize( heading - camHeading );
	}
	
	private function GetPlayerHeadingInCamSpace() : float
	{
		var cameraDirection : Vector;
		var camHeading		: float;
		var playerHeading	: float;
		
		
		cameraDirection			= theCamera.GetCameraDirection();
		cameraDirection.Z		= 0;
		camHeading				= AngleNormalize( VecHeading(cameraDirection) );
		playerHeading			= AngleNormalize( player.GetHeading() );		
		
		return AngleNormalize( playerHeading - camHeading );
	}
	
	private function GetInputHeading() : float
	{
		var inputVector	: Vector;
		
		inputVector.X = theInput.GetActionValue( 'GI_AxisLeftX' );
		inputVector.Y = theInput.GetActionValue( 'GI_AxisLeftY' );
		
		return AngleNormalize( VecHeading( inputVector ) );
	}
	
	private function GetInputInPlayerSpace( playerHeadingInCamSpace : float, out anyInput : bool ) : Vector
	{
		var inputVector			: Vector;
		var	relativeDirection	: Vector;
		var direction			: float;
		var inputHeading		: float;
		
		inputVector.X	= theInput.GetActionValue( 'GI_AxisLeftX' );
		inputVector.Y	= theInput.GetActionValue( 'GI_AxisLeftY' );
		
		anyInput		= inputVector.X != 0.0f || inputVector.Y != 0.0f; 
		
		
		if( anyInput )
		{
			inputHeading		= AngleNormalize( VecHeading(inputVector) );		
			direction			= playerHeadingInCamSpace - inputHeading;
			relativeDirection	= VecFromHeading( -direction + player.GetHeading() );
		}
		else
		{
			relativeDirection	= VecFromHeading( player.GetHeading() );
		}
		
		return relativeDirection;
	}
	
	private function CorrectDirection( moveDir : Vector, out anyInput : bool, out corrected : bool ) : Vector
	{
		var	newDir	: Vector;
		
		
		if( thePlayer.substateManager.m_MovementCorrectorO.CorrectDirectionToAvoid( moveDir, newDir, anyInput ) )
		{
			anyInput	= true;
			moveDir		= newDir;
			corrected	= true;
		}
		else
		{
			corrected	= false;
		}
		
		return moveDir;
	}
	
	function CalculateInputVector() : Vector
	{
		var vec : Vector;
		
		vec.X = theInput.GetActionValue( 'GI_AxisLeftX' );
		vec.Y = theInput.GetActionValue( 'GI_AxisLeftY' );
		
		return vec;
	}
	
	function ConvertVecToHeadingWS180AndMag( vec : Vector, out heading180 : float, out mag : float )
	{
		var vecNorm : Vector;
		var heading : float;
		
		
		mag = VecLength2D( vec );
		
		
		vecNorm = VecNormalize2D( vec );
		heading = VecHeading( vecNorm );
		heading180 = AngleNormalize180( heading );
	}
	
	function CalculateInputAngularSpeed() : float
	{
		var inputVec : Vector;		
		var angSpeed : float;
		var inputHeading, previousInputHeading : float;
		
		inputVec.X = theInput.GetActionValue( 'GI_AxisLeftX' );
		inputVec.Y = theInput.GetActionValue( 'GI_AxisLeftY' );
		
		inputVec = VecNormalize2D(inputVec);
		
		inputHeading = VecHeading(inputVec);
		previousInputHeading = VecHeading(previousInputVector);
		
		if( inputHeading < 0.0f )
		{
			inputHeading += 360;
		}
		
		if ( previousInputHeading < 0.0f )
		{
			previousInputHeading += 360;
		}
		
		angSpeed = inputHeading - previousInputHeading;
		
		if ( angSpeed > 180 )
		{
			angSpeed = - ( 360 - angSpeed );
		}
	 
		if ( angSpeed < - 180 )
		{
			angSpeed = 360 + angSpeed;
		}
		
		angSpeed = AbsF(angSpeed);
	
		
		
		
		
		
		
			
			previousInputVector = inputVec;
		
		
		return angSpeed;
	}
	
	
	var doubleTapEnabled 				: bool;
	var localMoveDirectionPrevFrame		: float;
	var directionSwitchTimeStamp		: float;
	var directionCenteredTimeStamp		: float;
	var isCheckingCentered 				: bool;
	
	var isCheckingCommitToRightTurn		: bool;
	var isCheckingCommitToLeftTurn		: bool;
	var isTurningRight					: bool;
	var isTurningLeft					: bool;
	var commitToRightTurnTimeStamp		: float;
	var commitToLeftTurnTimeStamp		: float;
	var directionSwitchTimeStampDelta	: float;
	var startRightTurnTimeStamp			: float;
	var startLeftTurnTimeStamp			: float;
	var useRightTurnTimeStamp			: bool;
	var useLeftTurnTimeStamp			: bool;
	
	function CalculateMoveSpeed() : float
	{
		var speedVec 		: Vector;
		var speed 			: float;		
		var rawRightJoyVec	: Vector;		
		var tempInt			: int;		
		var terrainAngles	: EulerAngles;		
		var currentTime		: float;		
		var forceWalkSpeed	: bool;		
		
		
		
		if ( thePlayer.IsCameraControlDisabled( 'Finisher' ) )
		{
			speed = 0;
		}
		else if ( _inputLocoEnabled )
		{
			speed = _inputMagLastCached;
		}
		else
		{
			
			
			speed	= thePlayer.substateManager.m_InputO.GetModuleF();
		}
		
		
		if( thePlayer.IsSwimming() )
		{
			if ( thePlayer.rangedWeapon 
				&& thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponWait'
				&& thePlayer.rangedWeapon.GetCurrentStateName() != 'State_WeaponHolster' )
			{
				speed = 0;
			}
		}
		
		player.terrainPitch 		= 90.0f - player.substateManager.m_MoverO.GetRealSlideAngle();
		
		
		
		
		
		
		if( thePlayer.CanSprint( speed ) )
		{
			if ( thePlayer.IsInCombat() 
				&& thePlayer.moveTarget 
				&& VecDistance( thePlayer.moveTarget.GetWorldPosition(), thePlayer.GetWorldPosition() ) < thePlayer.findMoveTargetDistMax )
			{
				thePlayer.SetIsSprinting(true);
				
				if ( thePlayer.modifyPlayerSpeed || thePlayer.interiorCamera )
					thePlayer.EnableSprintingCamera( false );
				else if ( thePlayer.GetSprintingTime() > 0.2 && !thePlayer.IsInCombatAction() )
					thePlayer.EnableSprintingCamera( true );
				else
					thePlayer.EnableSprintingCamera( false );
			}
			else 
			{
				thePlayer.SetIsSprinting(true);
				
				if ( thePlayer.modifyPlayerSpeed || thePlayer.interiorCamera  )
					thePlayer.EnableSprintingCamera( false );
				else
					thePlayer.EnableSprintingCamera( true );
			}
		}
		else
		{
			
			if ( !player.disableSprintingTimerEnabled && player.GetIsSprinting() )
			{
				player.disableSprintingTimerEnabled = true;
				player.AddTimer( 'DisableSprintingTimer', 0.25f );	
			}		
		}
		
		
		if ( player.modifyPlayerSpeed )
		{
			if ( speed > 0.0f )
			{
				if ( thePlayer.IsRunPressed() )
					speed = speedRunning;
				else
					speed = ClampF( speed, 0.f, speedWalkingMax );
			}
		}
		
		else if( !thePlayer.IsActionAllowed( EIAB_Sprint ) && thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && !thePlayer.IsCombatMusicEnabled() )
		{	
			if ( speed <= 0.f )
			{
				player.playerMoveType = PMT_Idle;
			}
			else if( thePlayer.IsSprintActionPressed() )
			{
				
				if(theInput.LastUsedGamepad() && thePlayer.GetLeftStickSprint() && thePlayer.IsInInterior() && !thePlayer.GetIsSprintToggled())
				{
					speed = MapF( MinF( speed, speedRunning ), 0.0f, speedRunning, 0.0f,  speedWalkingMax );
					player.playerMoveType = PMT_Walk;
				}	
				
				else if ( speed > 0.8f )
				{
					speed = MinF( speed, speedRunning );
					player.playerMoveType = PMT_Run;
				}
				else
				{
					speed = speedWalkingMax;
					player.playerMoveType = PMT_Walk;
				}
			}
			else
			{
				speed = MapF( MinF( speed, speedRunning ), 0.0f, speedRunning, 0.0f,  speedWalkingMax );
				player.playerMoveType = PMT_Walk;
			}			
		}
		
		else
		{
			if ( theInput.LastUsedGamepad() )
			{
				thePlayer.SetWalkToggle(false);
				
			}
			
			if ( speed <= 0.f )
			{
				player.playerMoveType = PMT_Idle;
			}
			else if (!theGame.IsFading() && !theGame.IsBlackscreen())
			{
				if ( player.GetIsSprinting() )
				{	
					speed = speedSprinting;
					player.playerMoveType = PMT_Sprint;
				}
				else if ( speed > thePlayer.GetInputModuleNeededToRun()
						&& ( thePlayer.IsActionAllowed( EIAB_RunAndSprint ) || thePlayer.IsCombatMusicEnabled() )
						&& ( ( thePlayer.GetPlayerCombatStance() == PCS_Normal && !thePlayer.GetIsWalkToggled() )
							|| thePlayer.GetPlayerCombatStance() == PCS_AlertFar 
							|| ( !thePlayer.GetIsWalkToggled() && !thePlayer.IsInCombat() && VecLength2D( speedVec ) > thePlayer.GetInputModuleNeededToRun() ) )
						)
				{
					speed =  MinF( speed, speedRunning );
					player.playerMoveType = PMT_Run;
					
					currentTime = EngineTimeToFloat( theGame.GetEngineTime() );
					
					if ( localMoveDirection > 0.7f )
					{
						if ( !isCheckingCommitToRightTurn )
						{
							isCheckingCommitToRightTurn = true;
							commitToRightTurnTimeStamp = currentTime;
						}
						
						if ( isCheckingCommitToRightTurn )
						{
							if ( currentTime >= commitToRightTurnTimeStamp + 0.25 )
							{
								directionSwitchTimeStampDelta = 0.f;
								isCheckingCommitToRightTurn = false;
								isTurningRight = true;
							}
						}
					}
					else if ( localMoveDirection < -0.7f )
					{				
						if ( !isCheckingCommitToLeftTurn )
						{
							isCheckingCommitToLeftTurn = true;
							commitToLeftTurnTimeStamp = currentTime;
						}
						
						if ( isCheckingCommitToLeftTurn )
						{
							if ( currentTime >= commitToLeftTurnTimeStamp + 0.25f )
							{
								directionSwitchTimeStampDelta = 0.f;
								isCheckingCommitToLeftTurn = false;
								isTurningLeft = true;
							}
						}	
					}
					
					if ( localMoveDirection > 0.f )
					{
						useLeftTurnTimeStamp = false;
						if ( isTurningLeft )
						{
							directionSwitchTimeStamp = currentTime;
							directionSwitchTimeStampDelta = 1.f;
							startRightTurnTimeStamp = currentTime;
							useRightTurnTimeStamp = true;
						}
						
						if ( useRightTurnTimeStamp && localMoveDirection > 0.3f )
						{
							if ( currentTime >= startRightTurnTimeStamp + 0.25 )
							{
								directionSwitchTimeStampDelta = 0.f;
							}
						}
							
						isTurningLeft = false;
						isCheckingCommitToLeftTurn = false;							
					}
					else if ( localMoveDirection < 0.f )
					{
						useRightTurnTimeStamp = false;
						if ( isTurningRight )
						{
							directionSwitchTimeStamp = currentTime;
							directionSwitchTimeStampDelta = 1.f;
							startLeftTurnTimeStamp = currentTime;
							useLeftTurnTimeStamp = true;
						}

						if ( useLeftTurnTimeStamp && localMoveDirection < -0.3f )
						{						
							if ( currentTime >= startLeftTurnTimeStamp + 0.25f )
							{
								directionSwitchTimeStampDelta = 0.f;
							}
						}
							
						isTurningRight = false;
						isCheckingCommitToRightTurn = false;							
					}					
					
					if ( currentTime < directionSwitchTimeStamp + directionSwitchTimeStampDelta )
					{
						if ( localMoveDirection >= -0.3f && localMoveDirection <= 0.3f )
						{
							if ( !isCheckingCentered )
							{
								isCheckingCentered = true;
								directionCenteredTimeStamp = currentTime;
							}
							else
							{
								if ( currentTime >= directionCenteredTimeStamp + 0.f )
								{
									isCheckingCentered = false;
									directionSwitchTimeStampDelta = 0.f;
									isCheckingCommitToRightTurn = false;
									isCheckingCommitToLeftTurn = false;
								}
							}
						}	
						else
							isCheckingCentered = false;				
					
						forceWalkSpeed = true;
						speed = speedWalkingMax;
					}
					else
						isCheckingCentered = false;
					
					if ( forceWalkSpeed )
						player.SetBehaviorVariable( 'forceWalkSpeed', 1 );
					else
						player.SetBehaviorVariable( 'forceWalkSpeed', 0 );
				}
				else
				{
					speed = speedWalkingMax; 
					player.playerMoveType = PMT_Walk;					
				}
			}
			else
			{
				speed = speedWalkingMax; 
				player.playerMoveType = PMT_Walk;
			}
		}
		
		if ( player.playerMoveType < PMT_Walk || (player.playerMoveType <= PMT_Run && !theGame.IsFocusModeActive() && !thePlayer.IsInAir()) )	
		{	
			if(thePlayer.IsInInterior() && player.playerMoveType >= PMT_Walk )
			{
				if(thePlayer.IsInCombat() && thePlayer.GetStatPercents(BCS_Stamina) <= 0.f)
					thePlayer.SetSprintToggle( false );
			}
			else if(!thePlayer.IsActionAllowed( EIAB_Sprint ) && thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && player.playerMoveType >= PMT_Walk)
			{}
			else
				thePlayer.SetSprintToggle( false );
		}
		
		
		
			
		
		tempInt = (int)( player.playerMoveType );
		player.substateManager.SetBehaviorParamBool(  'onSteepSlope', thePlayer.IsTerrainTooSteepToRunUp() );    
		player.SetBehaviorVariable( 'terrainPitch', player.terrainPitch );
		player.SetBehaviorVariable( 'playerMoveType', tempInt );
		player.SetBehaviorVariable( 'playerMoveTypeForOverlay', tempInt );
		player.substateManager.SetBehaviorParamBool( 'runInputPressed', thePlayer.IsSprintActionPressed() );		
		player.substateManager.SetBehaviorParamBool( 'ikWeight',  player.playerMoveType == PMT_Walk || player.playerMoveType == PMT_Idle );
		
		
		
		rawRightJoyVec.X = theInput.GetActionValue( 'GI_AxisRightX' ); 
		rawRightJoyVec.Y = theInput.GetActionValue( 'GI_AxisRightY' );
		player.SetBehaviorVariable( 'cameraSpeed', VecLength2D( rawRightJoyVec ) );
		
		
		return speed;
	}	
	
	private var fastTurnEnabled : bool;
	private function ProcessMovementEvent()
	{
		var walkTurnDampSpeed : float;
		var dir :  float =  AbsF( localMoveDirection );
		if ( angularInputSpeed > 0 )
		{
			
			
			if ( dir >= 0.8  && ( !player.rangedWeapon || player.rangedWeapon.GetCurrentStateName() == 'State_WeaponWait' ) )
			{
				player.SetBehaviorVariable( 'latchWalkDirection', 1.f );
				player.SetBehaviorVariable( 'walkTurnDampSpeed', 0.5f );
				fastTurnEnabled = false;
				player.RaiseEvent( 'QuickTurnWalk' );
				
			}
			else
			{
				if ( angularInputSpeed > 10.f && dir >= 0.25 && !player.lAxisReleasedAfterCounterNoCA )
					fastTurnEnabled = true;
			}
		}

		if ( dir <= 0.027f ) 
		{
			player.SetBehaviorVariable( 'latchWalkDirection', 0.f );	
			fastTurnEnabled = false;
		}
		
		player.SetBehaviorVariable( 'fastTurnEnabled', (float)fastTurnEnabled );
	}
	
	private function UpdateRequestedDirectionVariables(playerHeadingWS : float, cameraHeadingWS : float)
	{
		var orientationTarget	: EOrientationTarget;
		var useHeadingWS		: float;
		var useFacingWS			: float;
		var target				: CGameplayEntity;
		var targetPos			: Vector;
		var boneIndex			: int;
		
		var canFaceTarget		: bool;
		var playerToTargetVec	: Vector;

		useHeadingWS = playerHeadingWS;
		useFacingWS = cameraHeadingWS;

		orientationTarget = player.GetOrientationTarget();
		if ( orientationTarget == OT_Camera )
		{
			useFacingWS = cameraHeadingWS;
		}
		else if ( orientationTarget == OT_CameraOffset )
		{
			useFacingWS = cameraHeadingWS - player.GetOTCameraOffset();
		}
		else if ( orientationTarget == OT_Actor )
		{
			target = player.GetTarget();
			
			if ( !target )
				target = player.moveTarget;
				
			if ( player.IsCurrentSignChanneled() && player.IsInCombatAction() )
			{
				if ( player.GetCurrentlyCastSign() == ST_Quen )
				{
					target = player.moveTarget;
					canFaceTarget = true;
				}
				else if ( player.GetCurrentlyCastSign() == ST_Igni )
					target = player.GetDisplayTarget();
					canFaceTarget = true;
			}

			if ( target )
			{		
				if ( (CActor)target )
				{
					player.GetNearestTargetablePositionToPlayer( (CActor)target, targetPos, boneIndex );
					playerToTargetVec = targetPos - player.GetWorldPosition();
				}
				else
				{
					playerToTargetVec = target.GetWorldPosition() - player.GetWorldPosition();
				}
					
			
				if ( !canFaceTarget )
				{
					if ( player.GetPlayerCombatStance() == PCS_AlertNear )
						canFaceTarget = true;
					else if ( player.GetPlayerCombatStance() == PCS_Guarded && VecLength( playerToTargetVec ) < player.findMoveTargetDist )
						canFaceTarget = true;
					else if ( player.IsActorLockedToTarget() && !player.IsHardLockEnabled() )
						canFaceTarget = true;
				}
			}
			
			if ( canFaceTarget && target )
				useFacingWS = VecHeading( playerToTargetVec );
			else
				useFacingWS = player.GetHeading();		
		}
		else if ( orientationTarget == OT_Player )
		{
			useFacingWS = player.GetHeading();
		}
		else if ( orientationTarget == OT_CustomHeading )
		{
			useFacingWS = player.GetOrientationTargetCustomHeading();
		}
		
		player.GetVisualDebug().AddArrow( 'heading5', player.GetWorldPosition(), player.GetWorldPosition() + VecFromHeading( useFacingWS ), 1.f, 0.4f, 0.2f, true, Color(0,0,255), true );
		player.UpdateRequestedDirectionVariables( useHeadingWS, useFacingWS );
	}

};