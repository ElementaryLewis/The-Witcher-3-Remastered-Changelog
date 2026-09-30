/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
state ExtendedMovable in CR4Player extends Movable
{
	
	
	protected var parentMAC			: CMovingPhysicalAgentComponent;
	protected var currentStateName 	: name;
	
	
	
	event OnEnterState( prevStateName : name )
	{	
		
		super.OnEnterState(prevStateName);
		
		currentStateName = parent.GetCurrentStateName();
		parentMAC = (CMovingPhysicalAgentComponent)parent.GetMovingAgentComponent();
		
		parent.AddAnimEventCallback('CombatStanceLeft',		'OnAnimEvent_CombatStanceLeft');
		parent.AddAnimEventCallback('CombatStanceRight',	'OnAnimEvent_CombatStanceRight');
		
		if ( prevStateName == 'PlayerDialogScene' )
			parent.OnRangedForceHolster( true, true );
	}

	event OnLeaveState( nextStateName : name )
	{
		parent.RemoveAnimEventCallback('CombatStanceLeft');
		parent.RemoveAnimEventCallback('CombatStanceRight');
		
		parent.ResumeStaminaRegen( 'Sprint' );
		
		super.OnLeaveState(nextStateName);
	}
	
	
	
	event OnAnimEvent_CombatStanceLeft( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		parent.SetCombatIdleStance( 0.f );	
	}
	
	event OnAnimEvent_CombatStanceRight( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		parent.SetCombatIdleStance( 1.f );
	}	
	
	event OnSpawnHorse()
	{
		virtual_parent.ReapplyCriticalBuff();
	}
	
	event OnPlayerTickTimer( deltaTime : float )
	{
		var depth : float;
		var fallDist : float;
		var waterLevel : float;
		
		virtual_parent.OnPlayerTickTimer( deltaTime );
		
		if ( parent.IsInWaterTrigger() && thePlayer.IsAlive() && currentStateName != 'Swimming' && currentStateName != 'AimThrow'  )
		{
			if ( parent.GetFallDist(fallDist) || parent.IsRagdolled() )
			{
				waterLevel = theGame.GetWorld().GetWaterDepth( parent.GetWorldPosition(), true );
				if ( waterLevel > -parent.ENTER_SWIMMING_WATER_LEVEL && waterLevel != 10000 ) 
				{
					depth = parentMAC.GetSubmergeDepth();
					if ( depth < -0.1 )
						parent.GotoState( 'Swimming' );
				}
			}
			else
			{
				depth = parentMAC.GetSubmergeDepth();
				
				if ( depth < parent.ENTER_SWIMMING_WATER_LEVEL )
				{
					if ( thePlayer.GetCurrentStateName() == 'AimThrow' )
						parent.OnRangedForceHolster( true );
						
					parent.GotoState( 'Swimming' );
				}
			}
		}
	}
	
	var cameraChanneledSignEnabled : bool;
	
	private var m_shouldEnableAutoRotation : bool;
	
	event OnGameCameraTick( out moveData : SCameraMovementData, dt : float )
	{	
		var camera : CCustomCamera;
		var angleDist : float;
		
		camera = (CCustomCamera)theCamera.GetTopmostCameraObject();
		
		if( theInput.LastUsedGamepad() )
		{
			angleDist = AngleDistance( parent.GetHeading(), camera.GetHeading() );
			
			if( thePlayer.GetAutoCameraCenter() || ( !m_shouldEnableAutoRotation && thePlayer.GetIsSprinting() && AbsF(angleDist) <= 30.0f ) )
			{
				m_shouldEnableAutoRotation = true;
			}
			else if( m_shouldEnableAutoRotation && !thePlayer.GetAutoCameraCenter() && ( camera.IsManualControledHor() || !thePlayer.GetIsSprinting() ) )
			{
				m_shouldEnableAutoRotation = false;
			}
		}
		else
		{
			m_shouldEnableAutoRotation = thePlayer.GetAutoCameraCenter();
		}
		
		camera.SetAllowAutoRotation( m_shouldEnableAutoRotation );
		
		if( virtual_parent.OnGameCameraTick( moveData, dt ) )
		{
			return true;
		}
		
		cameraChanneledSignEnabled = parent.UpdateCameraChanneledSign( moveData, dt );
		
		if ( cameraChanneledSignEnabled )
			return true;
	}
	
	event OnGameCameraPostTick( out moveData : SCameraMovementData, dt : float )
	{
		if ( parent.DisableManualCameraControlStackHasSource('Finisher') )
		{
			moveData.pivotRotationController.SetDesiredHeading( moveData.pivotRotationValue.Yaw );
			moveData.pivotRotationController.SetDesiredPitch( moveData.pivotRotationValue.Pitch );
		}
	
		parent.OnGameCameraPostTick( moveData, dt );
	}
	
	protected var interiorCameraDesiredPositionMult : float;
	
	default interiorCameraDesiredPositionMult = 10.f;
	
	protected function SetInteriorCameraDesiredPositionMult( _interiorCameraDesiredPositionMult : float )
	{
		interiorCameraDesiredPositionMult = _interiorCameraDesiredPositionMult;
	}
	
	protected function UpdateCameraInterior( out moveData : SCameraMovementData, timeDelta : float )
	{
		var destYaw : float;
		var targetPos : Vector;
		var playerToTargetVector : Vector;
		var playerToTargetAngles : EulerAngles;
		var playerToTargetPitch : float;
		var _tempVelocity : float;
		var playerChestPosition, displayTargetChestPosition : Vector;
		var boneIdx : int = -1;
		var actorDispTarget : CActor;
		
		theGame.GetGameCamera().ChangePivotRotationController( 'CombatInterior' );
		theGame.GetGameCamera().ChangePivotDistanceController( 'Default' );
		theGame.GetGameCamera().ChangePivotPositionController( 'Default' );		

		
		moveData.pivotRotationController = theGame.GetGameCamera().GetActivePivotRotationController();
		moveData.pivotDistanceController = theGame.GetGameCamera().GetActivePivotDistanceController();
		moveData.pivotPositionController = theGame.GetGameCamera().GetActivePivotPositionController();
		
		
		DampFloatSpring(interiorCameraDesiredPositionMult, _tempVelocity, 10.f, 0.7f, timeDelta);
		
		moveData.pivotPositionController.SetDesiredPosition( parent.GetWorldPosition(), interiorCameraDesiredPositionMult); 
		moveData.pivotDistanceController.SetDesiredDistance( 3.5f );
		
		if ( parent.IsCameraLockedToTarget() && !thePlayer.GetFlyingBossCamera())
		{
			if ( parent.GetDisplayTarget() )
			{
				playerToTargetVector = parent.GetDisplayTarget().GetWorldPosition() - parent.GetWorldPosition();
				moveData.pivotRotationController.SetDesiredHeading( VecHeading( playerToTargetVector ), thePlayer.lockCameraSpeed );
			}
			else
				moveData.pivotRotationController.SetDesiredHeading( moveData.pivotRotationValue.Yaw, 0.5f );
			
			if ( AbsF( playerToTargetVector.Z ) <= 1.f )
			{
				if ( parent.IsGuarded() )
					moveData.pivotRotationController.SetDesiredPitch( -25.f );
				else
					moveData.pivotRotationController.SetDesiredPitch( -15.f );
			}
			else
			{
				playerToTargetAngles = VecToRotation( playerToTargetVector );
				playerToTargetPitch = playerToTargetAngles.Pitch + 10;
				
				
				
				moveData.pivotRotationController.SetDesiredPitch( playerToTargetPitch * -1, 0.5f );
			}
		}
		else if ( parent.IsCameraLockedToTarget() && thePlayer.GetFlyingBossCamera())
		{
			if ( parent.GetDisplayTarget() )
			{
				boneIdx = parent.GetTorsoBoneIndex();
				if ( boneIdx > 0 )
				{
					playerChestPosition = parent.GetBoneWorldPositionByIndex( boneIdx );
				}
				else
				{
					playerChestPosition = parent.GetWorldPosition();
				}
				
				actorDispTarget = (CActor)parent.GetDisplayTarget();
				
				boneIdx = -1;
				
				if( actorDispTarget )
				{
					boneIdx = actorDispTarget.GetTorsoBoneIndex();
				}
				
				if ( boneIdx > 0 )
				{
					displayTargetChestPosition = parent.GetDisplayTarget().GetBoneWorldPositionByIndex( boneIdx );
				}
				else
				{
					displayTargetChestPosition = parent.GetDisplayTarget().GetWorldPosition();
				}
				
				playerToTargetVector = displayTargetChestPosition - playerChestPosition;
				
				moveData.pivotRotationController.SetDesiredHeading( VecHeading( playerToTargetVector ), 0.5f );
			}
			else
				moveData.pivotRotationController.SetDesiredHeading( moveData.pivotRotationValue.Yaw, 0.5f );
			
			if ( AbsF( playerToTargetVector.Z ) <= 2.f )
			{
				if ( parent.IsGuarded() )
					moveData.pivotRotationController.SetDesiredPitch( -10.f );
				else
					moveData.pivotRotationController.SetDesiredPitch( -10.f );
			}
			else if ( AbsF( playerToTargetVector.Z ) >= 2.f )
			{
				moveData.pivotRotationController.SetDesiredPitch( 3.f );
			}
			else
			{
				playerToTargetAngles = VecToRotation( playerToTargetVector );
				playerToTargetPitch = playerToTargetAngles.Pitch - 10;
				
				
				
				moveData.pivotRotationController.SetDesiredPitch( playerToTargetPitch * -1, 0.5f );
			}
		}
		else
		{
			if ( parent.IsGuarded() )
				moveData.pivotRotationController.SetDesiredPitch( -25.f );
			else
				moveData.pivotRotationController.SetDesiredPitch( -15.f );
		}
			
		
		
	
		moveData.pivotPositionController.offsetZ = 1.55f;
		DampVectorSpring( moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector( 0.f, 0.f, 0.f ), 1.f, timeDelta );
	}	
}