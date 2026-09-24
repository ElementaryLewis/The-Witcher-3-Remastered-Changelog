/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SPlaneMovementParameters
{
	editable	var	m_SpeedMaxF	: float;
	editable	var	m_AccelF	: float;
	editable	var	m_DecelF	: float;
	editable	var	m_BrakeF	: float;
	editable	var	m_BrakeDotF	: float;
}



struct SVerticalMovementParams
{
	editable			var m_VertImpulseF	: float;
	editable			var m_VertMaxSpeedF	: float;
	editable			var m_GravityUpF	: float;
	editable			var m_GravityDownF	: float;
}



struct SSlidingMovementParams
{
	editable			var m_TurnSpeedF			: float;		default	m_TurnSpeedF 			= 3.0f;
	editable			var m_FrictionSquareF		: float;		default	m_FrictionSquareF 		= 0.1f;
	editable			var m_FrictionLinearF		: float;		default	m_FrictionLinearF 		= 1.0f;
	editable			var m_FrictionConstF		: float;		default	m_FrictionConstF 		= 3.0f;
	editable			var m_FrictionConstExitF	: float;		default	m_FrictionConstExitF	= 80.0f;
	editable			var m_InputVisualTurnCoefF	: float;		default	m_InputVisualTurnCoefF 	= 20.0f;
	editable			var m_GravityF				: float;		default	m_GravityF 				= -20.0f;
	editable			var m_RestitutionF			: float;		default	m_RestitutionF 			= 1.0f;
	editable			var m_InputAccelInfluenceF	: float;		default	m_InputAccelInfluenceF 	= 20.0f;
	editable			var m_InputFrictionCoefMinF	: float;		default	m_InputFrictionCoefMinF = 0.4f;
	editable			var m_InputFrictionCoefMaxF	: float;		default	m_InputFrictionCoefMaxF = 1.6f;
	editable			var	m_InputFrictionBlend	: float;		default	m_InputFrictionBlend 	= 5.0f;
	editable			var m_InputStrafeCoefF		: float;		default	m_InputStrafeCoefF 		= 0.0f;
}



struct SSkatingLevelParams
{
	editable	var	speedMax		: float;		default	speedMax		= 20.0f;
	editable	var	reflectInput	: bool;			default	reflectInput	= false;
}



struct SSkatingMovementParams
{
	editable			var	accel					: float;					default	accel					= 3.5f;
	editable			var	decel					: float;					default	decel					= 0.0f;
	editable			var	decelMaxSpeed			: float;					default	decelMaxSpeed			= 0.0f;
	editable			var	brake					: float;					default	brake					= 7.0f;
	editable			var brakeBaseSpeed			: float;					default	brakeBaseSpeed			= 10.0f;
	editable			var	frictionSquare			: float;					default	frictionSquare			= 0.0f;
	editable			var	frictionLinear			: float;					default	frictionLinear			= 0.0f;
	editable			var	frictionConst			: float;					default	frictionConst			= 0.0f;
	
	editable inlined	var	turnCurve				: CCurve;

	editable			var	gravity					: float;					default	gravity					= 20.0f;
	editable			var	turnToGravity			: float;					default	turnToGravity			= 0.5f;
	editable			var	gravitySpeedMax			: float;					default	gravitySpeedMax			= 30.0f;
}




class CExplorationMover
{
	
	private				var	m_ExplorationO				: CExplorationStateManager;
	private				var	m_InputO					: CExplorationInput;			
	
	
	private				var	m_WorldPositionV			: Vector;
	private				var	m_DisplacementLastFrameV	: Vector;
	
	
	
	private				var m_PlaneMovementParamsS		: SPlaneMovementParameters;
	private				var m_VerticalMovementParamsS	: SVerticalMovementParams;
	private				var m_SlidingParamsS			: SSlidingMovementParams;
	private				var m_SkatingParamsS			: SSkatingMovementParams;
	private				var m_SkatingLevelParamsS		: SSkatingLevelParams;
	private				var m_SkatingTurnPerSpeedF		: float;
	private				var m_SkatingSpeedTotalMaxF		: float;
	private				var m_SkatingTurnPerSpeedCurF	: float;		default	m_SkatingTurnPerSpeedCurF	= 100.0f;
	private				var m_SkatingTurnPerSpeedBlendF	: float;		default	m_SkatingTurnPerSpeedBlendF	= 100.0f;
	private				var m_SlidingFrictionBlendedF	: float;
	private				var m_SkateTurnDecelCoefF		: float;		default	m_SkateTurnDecelCoefF		= 1.0f;
	private				var m_SkateTurnBrakeCoefF		: float;		default	m_SkateTurnBrakeCoefF		= 1.7f;
	
	
	private				var	m_VelocityV					: Vector;
	private				var	m_VelocityNormalizedV		: Vector;
	private				var	m_SpeedF					: float;
	private				var	m_SpeedHeadingF				: float;	
	private				var	m_SpeedVerticalF			: float;
	private				var	m_DisplacementV				: Vector;
	private				var	m_RotationDeltaEA			: EulerAngles;
	private				var m_SpeedLastF				: float;
	private				var m_AccelerationLastF			: float;
	
	
	public  editable	var m_SlideMaxSpeedSafeF		: float;		default	m_SlideMaxSpeedSafeF	= 7.0f;
	public  editable	var m_SlideMaxSpeedToFallF		: float;		default	m_SlideMaxSpeedToFallF	= 20.0f;
	public  			var m_SlideMaxSpeedF			: float;
	public				var m_UseMaterialsB				: bool;			default	m_UseMaterialsB			= true;
	private				var m_SlidingLimitMinF			: float;		default	m_SlidingLimitMinF		= 0.3f;
	private				var m_SlidingLimitMaxF			: float;		default	m_SlidingLimitMaxF		= 1.0f;
	private				var m_MaterialFrictionMultF		: float;
	private				var	m_CoefMinMaterialF			: float;
	private				var m_SlideNormalRealV			: Vector;
	private				var m_SlideNormalV				: Vector;
	private				var m_SlideDirV					: Vector;
	private				var m_SlideRealangleF			: float;
	private				var m_SlideComputedThisFrameB	: bool;
	private				var m_SlideWideComputedThisFrameB	: bool;
	private				var	m_SlideWideCoefGlobalF		: float;
	public				var	m_WideNormalAverageV		: Vector;
	public				var	m_WideNormalGlobalV			: Vector;
	private				var	m_SlideWideCoefAverageF		: float;
	private				var	m_SlideWideCoefRealGlobalF	: float;
	private				var	m_SlideWideCoefRealAverageF	: float;
	public				var	m_SlideTerrainWideDistFwdF	: float;		default	m_SlideTerrainWideDistFwdF		= 1.0f;
	public				var	m_SlideTerrainWideDistBwdF	: float;		default	m_SlideTerrainWideDistBwdF		= 0.3f;
	public				var	m_SlideTerrainWideDistHorizF: float;		default	m_SlideTerrainWideDistHorizF	= 0.5f;
	private editable inlined var gravityCurve			: CCurve;
	
	public				var superSlide					: bool;			default	superSlide						= false;
	
	
	private				var	m_TurnThisFrameF			: float;
	
	private 			var	m_BankingNeedsUpdatingB		: bool;
	private 			var	m_BankingTargetF			: float;
	private 			var	m_BankingSpeedF				: float;
	private				var	m_BankingSpeedDefaultF		: float;		default	m_BankingSpeedDefaultF		= 90.0f;	
	
	private				var	m_OrientToInputMaxHeadingF	: float;		default	m_OrientToInputMaxHeadingF	= 45.0f;
	
	
	
	private				var	m_MACVelocityDampedV		: Vector;	
	private				var	m_MACVelocityDamSpeedF		: float;		default	m_MACVelocityDamSpeedF		= 10.0f;
	public				var	m_CustomIsAnimatedB			: bool;			default	m_CustomIsAnimatedB			= true;
	
	
	protected 			var	m_BoneRightFootN			: name;			default	m_BoneRightFootN			= 'r_foot';
	protected 			var	m_BoneLeftFootN				: name;			default	m_BoneLeftFootN				= 'l_foot';
	protected 			var	m_BoneIndexRightFootI		: int;
	protected 			var	m_BoneIndexLeftFootI		: int;
	
	
	
	private 			var m_UpV						: Vector;
	private 			var m_ZeroV						: Vector;
	
	
	
	public function Initialize( _ExplorationO : CExplorationStateManager )
	{
		
		m_ExplorationO	= _ExplorationO;
		m_InputO		= m_ExplorationO.m_InputO;
		
		
		m_BoneIndexRightFootI	= m_ExplorationO.m_OwnerE.GetBoneIndex( m_BoneRightFootN );
		m_BoneIndexLeftFootI	= m_ExplorationO.m_OwnerE.GetBoneIndex( m_BoneLeftFootN );
		
		
		m_UpV			= Vector( 0.0f, 0.0f, 1.0f );
		m_ZeroV			= Vector( 0.0f, 0.0f, 0.0f );
		
		
		Reset();
	}
	
	
	public function Reset()
	{
		
		
		StopAllMovement();
		
		m_SlideComputedThisFrameB		= false;
		m_SlideWideComputedThisFrameB	= false;
		
		
		
		
		
		m_WorldPositionV		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		m_MACVelocityDampedV	= m_ZeroV;
	}
	
	
	function OnTeleported()
	{
		StopAllMovement();
	}
	
	
	public function ApplyMovement( _Dt : float )
	{
		var movAdj : CMovementAdjustor;
		
		
		if( _Dt <= 0.0f )
		{
			return;
		}
	
		
		movAdj = m_ExplorationO.m_OwnerMAC.GetMovementAdjustor();
		movAdj.AddOneFrameTranslationVelocity( m_DisplacementV / _Dt );
		m_RotationDeltaEA.Yaw	= m_RotationDeltaEA.Yaw / _Dt;
		m_RotationDeltaEA.Pitch	= m_RotationDeltaEA.Pitch / _Dt;
		m_RotationDeltaEA.Roll	= m_RotationDeltaEA.Roll / _Dt;
		movAdj.AddOneFrameRotationVelocity( m_RotationDeltaEA );
		
		
		if( m_BankingNeedsUpdatingB )
		{
			UpdateBanking( _Dt );
		}
	}
	
	
	public function PreUpdate( _Dt : float )
	{		
		var positionCur	: Vector;
		
		
		m_SlideComputedThisFrameB		= false;
		m_SlideWideComputedThisFrameB	= false;
		positionCur						= m_ExplorationO.m_OwnerE.GetWorldPosition();
		m_DisplacementLastFrameV		= positionCur - m_WorldPositionV;
		m_WorldPositionV				= positionCur;
	}
	
	
	public function	PostUpdate( _Dt : float )
	{	
		VecSetZeros( m_DisplacementV );
		EulerSetZeros( m_RotationDeltaEA );
		
		m_AccelerationLastF				= m_SpeedF - m_SpeedLastF;
		m_SpeedLastF					= m_SpeedF;
		
		m_MACVelocityDampedV			= LerpV( m_MACVelocityDampedV, m_ExplorationO.m_OwnerMAC.GetVelocity(), MinF( 1.0f, m_MACVelocityDamSpeedF * _Dt ) );
		
		
		m_SlideComputedThisFrameB		= false;
		m_SlideWideComputedThisFrameB	= false;
		
		
		
	}
	
	
	public function Translate( _TranslationV : Vector )
	{
		m_DisplacementV	+= _TranslationV;
	}
	
	
	private function Rotate( _RotationEA : EulerAngles )
	{
		m_RotationDeltaEA.Yaw	+= _RotationEA.Yaw;
		m_RotationDeltaEA.Pitch	+= _RotationEA.Pitch;
		m_RotationDeltaEA.Roll	+= _RotationEA.Roll;
	}
	
	
	public function GetDisplacementLastFrame() : Vector
	{
		return m_DisplacementLastFrameV;
	}
	
	
	public function IsRightFootForward() : bool
	{
		var actorForward	: Vector;
		
		
		actorForward	= m_ExplorationO.m_OwnerE.GetWorldForward();
		return IsRightFootForwardTowardsDir( actorForward );
	}
	
	
	public function IsRightFootForwardTowardsDir( direction : Vector ) : bool
	{
		var startRightFoot	: bool;
		
		
		var lFoot			: Vector;
		var rFoot			: Vector;
		var leftToRightFoot	: Vector;
		
		
		
		lFoot			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( m_BoneIndexLeftFootI );
		rFoot			= m_ExplorationO.m_OwnerE.GetBoneWorldPositionByIndex( m_BoneIndexRightFootI );
		leftToRightFoot	= rFoot - lFoot;
		startRightFoot	= VecDot( leftToRightFoot, direction ) > 0.0f;
		
		return startRightFoot;
	}
	
	
	public function UpdateMovementLinear( _VelocityV : Vector, _Dt : float )
	{
		SetVelocity( _VelocityV );
		Translate( m_VelocityV * _Dt );
	}
	
	
	public function SetPlaneMovementParams( _PlaneMovementParamsS : SPlaneMovementParameters )
	{
		m_PlaneMovementParamsS	= _PlaneMovementParamsS;
	}
	
	
	public function SetVerticalMovementParams( _VerticalMovementParamsS : SVerticalMovementParams )
	{
		m_VerticalMovementParamsS	= _VerticalMovementParamsS;
		
		
		if( m_VerticalMovementParamsS.m_VertMaxSpeedF > 0.0f )
		{
			m_VerticalMovementParamsS.m_VertMaxSpeedF	*= -1.0f;
		}
		if( m_VerticalMovementParamsS.m_GravityUpF > 0.0f )
		{
			m_VerticalMovementParamsS.m_GravityUpF		*= -1.0f;
		}
		if( m_VerticalMovementParamsS.m_GravityDownF > 0.0f )
		{
			m_VerticalMovementParamsS.m_GravityDownF	*= -1.0f;
		}
	}
	
	
	public function SetSlidingLimits( minDegrees, maxDegrees : float )
	{		
		m_SlidingLimitMinF = ConvertAngleDegreeToSlidECoef( minDegrees );
		m_SlidingLimitMaxF = ConvertAngleDegreeToSlidECoef( maxDegrees );
		
		m_ExplorationO.m_OwnerMAC.SetSlidingLimits( m_SlidingLimitMinF, m_SlidingLimitMaxF );
	}
	
	public function GetSlidingLimitMinCur() : float
	{
		return m_CoefMinMaterialF;
	}
	
	public function GetSlidingLimitMax() : float
	{
		return m_SlidingLimitMaxF;
	}
	
	
	
	public function ConvertAngleDegreeToSlidECoef( angleDegree : float ): float
	{
		
		
		angleDegree	= ClampF( angleDegree / 90.0f, 0.0f, 1.0f );
		
		
		return angleDegree;
	}
	
	
	public function ConvertCoefToAngleDegree( coef : float ) : float
	{
		
		
		
		coef	 *= 90.0f;
		
		return coef;
	}
	
	
	public function SetSlidingParams( _SlidingParamsS : SSlidingMovementParams )
	{
		m_SlidingParamsS 			= _SlidingParamsS;		
		m_SlidingFrictionBlendedF	= 1.0f;
	}
	
	
	public function SetSlidingMaterialParams( _AngleMinMaterialF, _MaterialFrictionMultiplierF : float )
	{
		
		
		m_CoefMinMaterialF		= ConvertAngleDegreeToSlidECoef( _AngleMinMaterialF );
		m_MaterialFrictionMultF	= _MaterialFrictionMultiplierF;
		
		
		if( m_MaterialFrictionMultF <= 0.0f )
		{
			m_MaterialFrictionMultF	= m_MaterialFrictionMultF;
		}
	}
	
	
	public function SetSkatingParams( slidingParams : SSkatingMovementParams )
	{
		m_SkatingParamsS	= slidingParams;
	}
	
	
	public function SetSkatingLevelParams( levelParams :SSkatingLevelParams )
	{
		m_SkatingLevelParamsS	= levelParams;
	}
	
	
	public function SetSkatingTurnSpeed( turnSpeed : float )
	{
		m_SkatingTurnPerSpeedF	= turnSpeed;
	}
	
	
	public function SetSkatingAbsoluteMaxSpeed( maxSpeed : float )
	{
		m_SkatingSpeedTotalMaxF	= maxSpeed;
	}
	
	
	public function SetManualMovement( enable : bool )
	{
		if( m_CustomIsAnimatedB )
		{
			m_ExplorationO.m_CollisionManagerO.EnableVerticalSliding( enable );
			m_ExplorationO.m_OwnerMAC.SetAnimatedMovement( enable );
			
		}
		else
		{
			m_ExplorationO.m_OwnerMAC.SetAnimatedMovement( enable );
		}
		
		
		m_ExplorationO.m_OwnerMAC.EnableVirtualControllerCollisionResponse( 'MainCollider', !enable );
	}
	
	
	public function SetCustomIsAnim( enabled : bool )
	{
		m_CustomIsAnimatedB	= enabled;
	}
	
	
	public function UpdateMovementOnPlaneWithInput( _Dt : float )
	{
		var l_DotF				: float;
		var	l_AccelV			: Vector;
		var	l_NewVelocityV		: Vector;
		var	l_MaxSpeedTotalF	: float;
		
		
		if( !m_InputO.IsModuleConsiderable() )
		{			
			
			l_NewVelocityV	= VecReduceTowardsZero( m_VelocityV, m_PlaneMovementParamsS.m_DecelF * _Dt );
		}
		
		else
		{
			
			l_DotF			= VecDot( m_VelocityNormalizedV, m_InputO.GetMovementOnPlaneV() );
			
			if( l_DotF >= m_PlaneMovementParamsS.m_BrakeDotF )
			{
				l_AccelV	= m_InputO.GetMovementOnPlaneV() * m_PlaneMovementParamsS.m_AccelF;
			}
			else
			{
				l_AccelV	= m_InputO.GetMovementOnPlaneV() * m_PlaneMovementParamsS.m_BrakeF;
			}
			
			
			l_MaxSpeedTotalF	= m_PlaneMovementParamsS.m_SpeedMaxF * m_InputO.GetModuleF();
			
			
			l_NewVelocityV	= VecAddNotExceedingV( m_VelocityV, l_AccelV * _Dt , l_MaxSpeedTotalF );
			
			
			if( VecLengthSquared( l_NewVelocityV ) > l_MaxSpeedTotalF * l_MaxSpeedTotalF )
			{
				l_NewVelocityV	= VecReduceNotExceedingV( m_VelocityV, m_PlaneMovementParamsS.m_DecelF * _Dt, l_MaxSpeedTotalF );
			}
		}
		
		
		SetVelocity( l_NewVelocityV );
		
		Translate( m_VelocityV  * _Dt );
	}
	
	
	public function UpdateMovementOnPlaneWithInertia( _Dt : float )
	{
		var	l_NewVelocityV		: Vector;
		
		
		l_NewVelocityV	= VecReduceTowardsZero( m_VelocityV, m_PlaneMovementParamsS.m_DecelF * _Dt );
		
		
		SetVelocity( l_NewVelocityV );
		
		Translate( m_VelocityV  * _Dt );
	}
	
	
	public function UpdateMovementStraightAndTurnWithInput( _SpeedMaxF, _AccelF, _TurnCoefBaseF, _InputMaxTurnF, _Dt : float )
	{
		var l_InputVectorV		: Vector;
		var l_InputHeadingF		: float;
		var l_CharacterHeadingF	: float;
		var l_DirectionDiffF	: float;
		var l_TurnAngleF		: float;
		
		
		
		if( !m_InputO.IsModuleConsiderable() )
		{
			l_InputVectorV	= theCamera.GetCameraForwardOnHorizontalPlane();
		}
		
		else
		{
			l_InputVectorV	= m_InputO.GetMovementOnPlaneV();
		}
		
		l_InputHeadingF		= AngleNormalize180( VecHeading( l_InputVectorV ) );
		l_CharacterHeadingF	= AngleNormalize180( VecHeading( m_ExplorationO.m_OwnerE.GetWorldForward() ) );
		l_DirectionDiffF	= AngleDistance( l_InputHeadingF, l_CharacterHeadingF );
		
		_TurnCoefBaseF		= _TurnCoefBaseF * MinF( 1.0f, AbsF( l_DirectionDiffF ) / _InputMaxTurnF );
		
		l_TurnAngleF		= SignF( l_DirectionDiffF ) * MinF( _TurnCoefBaseF * _Dt, AbsF( l_DirectionDiffF ) );
		
		
		m_SpeedF			= ClampF( m_SpeedF + _AccelF * _Dt, -_SpeedMaxF, _SpeedMaxF );
		SetVelocity( m_SpeedF * VecFromHeading( l_CharacterHeadingF + l_TurnAngleF ) );
		
		
		AddYaw( l_TurnAngleF );
		
		
		Translate( m_VelocityV  * _Dt );
	}
	
	
	public function UpdateSkatingMovement( _Dt : float, out _AccelF : float, out _ResultingTurnPercF : float, out _IsBraking : bool, optional _IsDriftingB : bool, optional _IsDriftLeftB : bool )
	{
		var l_CharacterHeadingF		: float;
		var l_DirectionDiffF		: float;
		var l_DirectionDiffAbsF		: float;	
		var l_TurnTotalF			: float;
		var l_AccelF				: float;
		var l_SpeedMaxF				: float;	
		var l_FrictionF				: float;	
		var l_GravityTurnF			: float;	
		var l_GravityAccelF			: float;
		
		
		if( !m_SlideComputedThisFrameB )
		{
			ComputeSlideDirAndNormal();
		}
		
		
		l_GravityAccelF		= VecDot( m_VelocityNormalizedV, m_SlideDirV ) * ( 1.0f - VecDot( m_SlideNormalV, m_UpV ) );
		l_GravityAccelF		*= m_SkatingParamsS.gravity;
		l_GravityTurnF		= AngleDistance( VecHeading( m_VelocityNormalizedV ), VecHeading( m_SlideDirV ) );
		
		
		
		l_CharacterHeadingF	= m_ExplorationO.m_OwnerE.GetHeading();
		m_InputO.ComputeHeadingDiffWithReflectionF( l_CharacterHeadingF, m_SkatingLevelParamsS.reflectInput, l_DirectionDiffF, _ResultingTurnPercF, _IsBraking, true );
		
		
		_AccelF		= m_InputO.GetModuleF() * ( 1.0f - AbsF( _ResultingTurnPercF ) );
		if( _IsBraking )
		{
			_AccelF	*= -1.0f;
		}
		
		
		m_SkatingTurnPerSpeedCurF	= LerpF( MinF( _Dt * m_SkatingTurnPerSpeedBlendF, 1.0f ), m_SkatingTurnPerSpeedCurF, m_SkatingTurnPerSpeedF );
		l_TurnTotalF				= m_SkatingTurnPerSpeedCurF;
		if( m_SkatingParamsS.turnCurve )
		{
			l_TurnTotalF	*= m_SkatingParamsS.turnCurve.GetValue( m_SpeedF / m_SkatingSpeedTotalMaxF );
		}
		
		
		if( _IsBraking )
		{
			l_TurnTotalF	*= m_SkateTurnBrakeCoefF;
		}
		else if( _AccelF < 0.5f)
		{
			l_TurnTotalF	*= m_SkateTurnDecelCoefF;
		}
		
		
		if( _IsDriftingB )
		{
			if( _IsDriftLeftB )
			{
				l_TurnTotalF	= l_TurnTotalF * MapF( _ResultingTurnPercF , -1.0f, 1.0f, -1.0f, 0.2f );
			}
			else
			{
				l_TurnTotalF	= l_TurnTotalF * MapF( _ResultingTurnPercF , -1.0f, 1.0f, -0.2f, 1.0f );
			}
		}
		else
		{			
			l_TurnTotalF		= l_TurnTotalF * _ResultingTurnPercF;
			if ( _IsBraking )
			{
				
				if( theInput.GetActionValue( 'GI_AxisLeftY' ) < -0.9f )
				{
				_ResultingTurnPercF	= 0.0f;
				l_TurnTotalF	= 0.0f;
				}
			}
		}
		
		l_DirectionDiffAbsF		= AbsF( l_DirectionDiffF );
		l_TurnTotalF			= ClampF( l_TurnTotalF * _Dt, -l_DirectionDiffAbsF, l_DirectionDiffAbsF );
		
		
		AddYaw( l_TurnTotalF );
		
		
		
		
		if( m_SpeedF >= m_SkatingLevelParamsS.speedMax ) 
		{
			l_AccelF	= -m_SkatingParamsS.decelMaxSpeed * m_SpeedF;
			
			
			if( _AccelF > 0.0f )
			{
				if( m_SpeedF + l_AccelF * _Dt < m_SkatingLevelParamsS.speedMax )
				{
					l_AccelF	= ( m_SkatingLevelParamsS.speedMax - m_SpeedF ) / _Dt;
				}
			}
		}
		
		else if( !m_InputO.IsModuleConsiderable() ) 
		{
			l_AccelF	= -m_SkatingParamsS.decel;
		}
		
		else if( _IsBraking  ) 
		{
			l_AccelF	= -m_SkatingParamsS.brake * m_InputO.GetModuleF() * MaxF( m_SkatingParamsS.brakeBaseSpeed,  m_SpeedF );
		}
		
		else 
		{
			l_AccelF	= m_SkatingParamsS.accel * m_InputO.GetModuleF();
		}
		
		
		l_FrictionF			= m_SpeedF * ( m_SpeedF * m_SkatingParamsS.frictionSquare + m_SkatingParamsS.frictionLinear ) + m_SkatingParamsS.frictionConst;
		l_AccelF			-= l_FrictionF;
		
		
		l_SpeedMaxF			= MaxF( m_SpeedF, m_SkatingLevelParamsS.speedMax );
		m_SpeedF			= MinF( m_SpeedF + l_AccelF * _Dt, l_SpeedMaxF );
		
		
		l_SpeedMaxF			= MaxF( m_SpeedF, m_SkatingParamsS.gravitySpeedMax );
		m_SpeedF			= MinF( m_SpeedF + l_GravityAccelF * _Dt, l_SpeedMaxF );
		
		
		SetVelocity( m_SpeedF * VecFromHeading( l_CharacterHeadingF + l_TurnTotalF ) );
		Translate( m_VelocityV  * _Dt );
		
		
		m_ExplorationO.m_SharedDataO.m_JumpDirectionForcedV	= m_VelocityNormalizedV;	
	}
	
	
	public function UpdateSlidingInertialMovementWithInput( _Dt : float, out _TurnF : float, out _AccelF : float, applyStoppingFriction : bool, slopeYaw : float, slopeOrientSpeed : float )
	{
		var l_SlopeDirectionV		: Vector;
		var l_SlopeNormalV			: Vector;
		var l_SlopeAccelVectorV		: Vector;
		var l_SlopeRestitutionV		: Vector;
		var l_SlopeFrictionV		: Vector;
		var l_NewVelocityV			: Vector;
		var l_NewVelocityDirV		: Vector;
		var l_VelocityRightV		: Vector;
		var l_SpeedLostProjectingF	: float;
		var l_AuxF					: float;
		
		var l_InputVectorV			: Vector;
		var l_DirectionDiffF		: float;
		var l_DirectionDiffAbsF		: float;
		var l_DirectionDiffPercF	: float;
		var l_DirectionReflectedB	: bool;
		var l_TurnAngleF			: float;
		var l_FrictionInputCoefF	: float;
		
		
		
		l_NewVelocityV			= m_VelocityV;
		
		
		
		GetSlideDirAndNormal( l_SlopeDirectionV, l_SlopeNormalV );
		
		
		
		l_AuxF					= VecLength( l_NewVelocityV );
		l_NewVelocityV			= l_NewVelocityV - l_SlopeNormalV * VecDot( l_NewVelocityV, l_SlopeNormalV );
		l_NewVelocityV.W		= 0.0f;
		l_NewVelocityDirV		= VecNormalize( l_NewVelocityV );
		l_SpeedLostProjectingF	= VecLength( l_NewVelocityV ) - l_AuxF;
		
		
		
		l_SlopeRestitutionV		= l_SlopeDirectionV * l_SpeedLostProjectingF * m_SlidingParamsS.m_RestitutionF;
		l_NewVelocityV			+= l_SlopeRestitutionV;
		
		
		if( m_InputO.IsModuleConsiderable() )
		{
			l_InputVectorV			= m_InputO.GetMovementOnPlaneV();
			
			
			l_AuxF					= VecLength( l_InputVectorV );
			l_InputVectorV			= l_InputVectorV - l_SlopeNormalV * VecDot( l_InputVectorV, l_SlopeNormalV );
			l_InputVectorV.W		= 0.0f;
			l_InputVectorV			= VecNormalize( l_InputVectorV ) * l_AuxF;
		}
		else
		{
			l_InputVectorV			= m_ZeroV;
		}		
		
		
		
		l_FrictionInputCoefF		= VecDot( l_InputVectorV, l_NewVelocityDirV );
		if( l_FrictionInputCoefF >= 0.0f )
		{
			l_FrictionInputCoefF	= MapF( 1.0f - l_FrictionInputCoefF, 0.0f, 1.0f, m_SlidingParamsS.m_InputFrictionCoefMinF, 1.0f ); 
		}
		else
		{
			l_FrictionInputCoefF	= MapF( -l_FrictionInputCoefF, 0.0f, 1.0f, 1.0f, m_SlidingParamsS.m_InputFrictionCoefMaxF );
		}
		
		m_SlidingFrictionBlendedF	= BlendLinearF( m_SlidingFrictionBlendedF, l_FrictionInputCoefF, m_SlidingParamsS.m_InputFrictionBlend * _Dt );
		
		
		l_AuxF					= VecLength( l_NewVelocityV );
		l_AuxF					= m_SlidingParamsS.m_FrictionConstF + ( m_SlidingParamsS.m_FrictionLinearF + m_SlidingParamsS.m_FrictionSquareF * l_AuxF ) * l_AuxF ;
		l_AuxF					*= m_SlidingFrictionBlendedF;
		l_AuxF					*= m_MaterialFrictionMultF;
		if( applyStoppingFriction ) 
		{
			l_AuxF				 *= m_SlidingParamsS.m_FrictionConstExitF;
		}
		
		l_NewVelocityV			= VecReduceTowardsZero( l_NewVelocityV, l_AuxF * _Dt );
		
		
		
		
		l_AuxF					= AbsF( VecDot( l_SlopeDirectionV, m_UpV ) );
		l_AuxF					=  -gravityCurve.GetValue( l_AuxF ) * m_SlidingParamsS.m_GravityF;
		
		l_SlopeAccelVectorV		= l_SlopeDirectionV * l_AuxF;	
		
		
		l_VelocityRightV		= VecCross( l_NewVelocityDirV, l_SlopeNormalV );
		l_SlopeAccelVectorV		+= l_VelocityRightV * VecDot( l_InputVectorV, l_VelocityRightV ) * m_SlidingParamsS.m_InputStrafeCoefF;
		
		
		
		l_NewVelocityV			= l_NewVelocityV + ( l_SlopeAccelVectorV * _Dt );
		
		
		
		if( m_InputO.IsModuleConsiderable() )
		{
			m_InputO.ComputeHeadingDiffWithReflectionF( m_ExplorationO.m_OwnerE.GetHeading(), true, l_DirectionDiffF, l_DirectionDiffPercF, l_DirectionReflectedB );
			l_DirectionDiffAbsF		= AbsF( l_DirectionDiffF );
			l_TurnAngleF			= m_SlidingParamsS.m_TurnSpeedF * l_DirectionDiffPercF;
			l_TurnAngleF			= ClampF( l_TurnAngleF * _Dt, -l_DirectionDiffAbsF, l_DirectionDiffAbsF );
			
			
			l_NewVelocityV			= VecRotateAxis( l_NewVelocityV, l_SlopeNormalV, l_TurnAngleF ); 
		}
		else
		{
			l_TurnAngleF	= 0.0f;
		}
		
		
		l_AuxF				= VecLength( l_NewVelocityV );
		if( l_AuxF > m_SlideMaxSpeedF	)
		{
			l_NewVelocityV	*= m_SlideMaxSpeedF / l_AuxF;
		}
		
		
		SetVelocity( l_NewVelocityV );
		
		
		
		Translate( m_VelocityV * _Dt );
		
		
		
		slopeYaw	= AngleDistance( slopeYaw, m_ExplorationO.m_OwnerE.GetHeading() );
		slopeYaw	*= 2.5f * _Dt;
		
		AddYaw( l_TurnAngleF * m_SlidingParamsS.m_InputVisualTurnCoefF + slopeYaw );
		
		
		_TurnF	= l_DirectionDiffPercF; 
		_AccelF	= l_FrictionInputCoefF;
	}
	
	
	public function UpdateSlidingInertialMovement( _Dt : float )
	{
		var l_SlopeDirectionV	: Vector;
		var l_SlopeNormalV		: Vector;
		var l_SlopeAccelVectorV	: Vector;
		var l_SlopeRestitutionV	: Vector;
		var l_SlopeFrictionV	: Vector;
		var l_NewVelocityV		: Vector;
		var l_AuxF				: float;
		
		
		
		l_NewVelocityV			= m_VelocityV;
		
		
		GetSlideDirAndNormal( l_SlopeDirectionV, l_SlopeNormalV );
		
		
		
		l_AuxF					= m_SlidingParamsS.m_FrictionConstF + m_SlidingParamsS.m_FrictionLinearF * VecLength( l_NewVelocityV );
		l_AuxF					*= m_MaterialFrictionMultF;
		l_NewVelocityV			= VecReduceTowardsZero( l_NewVelocityV, l_AuxF * _Dt );
		
		
		
		l_NewVelocityV			= l_NewVelocityV - l_SlopeNormalV * VecDot( l_NewVelocityV, l_SlopeNormalV );
		
		
		
		l_AuxF					= VecDot( l_SlopeDirectionV, m_UpV );
		l_AuxF					= l_AuxF * m_SlidingParamsS.m_GravityF;
		l_SlopeAccelVectorV		= l_SlopeDirectionV * l_AuxF;	
		
		
		
		l_SlopeRestitutionV		= l_SlopeDirectionV * VecDot( l_NewVelocityV, l_SlopeNormalV ) * m_SlidingParamsS.m_RestitutionF;
		
		
		
		l_NewVelocityV			= l_NewVelocityV + ( l_SlopeAccelVectorV * _Dt ) + l_SlopeRestitutionV;
		
		
		
		SetVelocity( l_NewVelocityV );
		
		
		Translate( m_VelocityV * _Dt );
	}
	
	
	public function UpdateMovementVertical( _Dt : float ) : float
	{
		var l_DisplacementF	: float;
		var l_AccelF		: float;
		
		
		
		
		
		
		
		
		
		if( m_SpeedVerticalF > 0.0f )
		{
			l_AccelF	= m_VerticalMovementParamsS.m_GravityUpF;
		}
		else
		{
			l_AccelF	= m_VerticalMovementParamsS.m_GravityDownF;
		}
		
		
		l_DisplacementF	= l_AccelF * _Dt * _Dt + m_SpeedVerticalF * _Dt;
		
		
		m_SpeedVerticalF	= MaxF( m_VerticalMovementParamsS.m_VertMaxSpeedF, l_DisplacementF / _Dt );
		
		
		Translate( l_DisplacementF * m_UpV );
		
		return l_DisplacementF;
	}
	
	
	public function UpdatePerfectMovementVertical( _Dt : float ) : float
	{
		var l_AccelF			: float;
		var l_TimeRemainingF	: float;
		var l_TimeNeededF		: float;
		var	l_DisplacementF		: float;
		
		
		
		l_TimeRemainingF		= _Dt;
		l_DisplacementF			= 0.0f;
		
		
		if( m_SpeedVerticalF > 0.0f )
		{
			
			l_TimeNeededF		= GetTimeToReachThePeak();			
			l_TimeNeededF		= MinF( l_TimeNeededF, l_TimeRemainingF);
			
			
			l_DisplacementF 	+= UpdateParabolicVerticalMovement( m_VerticalMovementParamsS.m_GravityUpF, l_TimeNeededF );
			
			
			l_TimeRemainingF	-= l_TimeNeededF;		
			if( l_TimeRemainingF <= 0.0f )
			{
				return l_DisplacementF;
			}			
		}
		
		
		if( m_SpeedVerticalF > m_VerticalMovementParamsS.m_VertMaxSpeedF )
		{
			
			l_TimeNeededF		= GetTimeToReachMaxSpeed();
			l_TimeNeededF		= MinF( l_TimeNeededF, l_TimeRemainingF);	
			
			
			l_DisplacementF		+= UpdateParabolicVerticalMovement( m_VerticalMovementParamsS.m_GravityDownF, l_TimeNeededF );
			
			
			l_TimeRemainingF	-= l_TimeNeededF;	
			if( l_TimeRemainingF <= 0.0f )
			{
				return l_DisplacementF;
			}
		}
		
		
		l_DisplacementF		+= UpdateLinearVerticalMovement( l_TimeRemainingF );		
		
		return l_DisplacementF;
	}
	
	
	private function GetTimeToReachThePeak() : float
	{
		if( m_SpeedVerticalF <= 0.0f )
		{
			return 0.0f;
		}
		
		
		
		
		
		return -m_SpeedVerticalF / 2.0f / m_VerticalMovementParamsS.m_GravityUpF;
	}
	
	
	private function GetTimeToReachMaxSpeed() : float
	{
		if( m_SpeedVerticalF <= m_VerticalMovementParamsS.m_VertMaxSpeedF )
		{
			return 0.0f;
		}
		
		
		
		
		return ( m_VerticalMovementParamsS.m_VertMaxSpeedF - m_SpeedVerticalF ) / 2.0f / m_VerticalMovementParamsS.m_GravityUpF;
	}
	
	
	private function UpdateParabolicVerticalMovement( _AccelF, _Dt : float ) : float
	{
		
		
		
		var l_DisplacementF	: float;
		
		
		l_DisplacementF		= _AccelF * _Dt * _Dt + m_SpeedVerticalF * _Dt;
		
		
		m_SpeedVerticalF	= MaxF( m_VerticalMovementParamsS.m_VertMaxSpeedF, l_DisplacementF / _Dt );
		
		
		m_SpeedVerticalF	+=  2 * m_VerticalMovementParamsS.m_GravityUpF * _Dt;
		
		
		Translate( l_DisplacementF * m_UpV );
		
		return l_DisplacementF;
	}
	
	
	private function UpdateLinearVerticalMovement( _Dt : float ) : float
	{		
		
		Translate( _Dt * m_SpeedVerticalF * m_UpV );
		
		return _Dt * m_SpeedVerticalF;
	}
	
	
	
	function UpdateOrientToInput( _Speed, _Dt : float ) : bool
	{		
		var inputHeading	: float;
		var turnDelta		: float;
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputHeading	= m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF();
			
			turnDelta		= ClampF( inputHeading, -m_OrientToInputMaxHeadingF, m_OrientToInputMaxHeadingF ) * MinF( 1.0f, _Speed * _Dt );
			
			
			
			if( AbsF( turnDelta ) >= AbsF( inputHeading ) )
			{
				AddYaw( turnDelta - inputHeading );
				return true;
			}	
			
			AddYaw( turnDelta );	
		}
		
		return false;
	}
	
	
	function UpdateOrientToInputLinear( _Speed, _Dt : float, optional tolerance : float ) : bool
	{		
		var inputHeading	: float;
		var inputHeadingAbs	: float;
		var turnDelta		: float;
		
		if( m_ExplorationO.m_InputO.IsModuleConsiderable() )
		{
			inputHeading	= m_ExplorationO.m_InputO.GetHeadingDiffFromPlayerF();
			inputHeadingAbs	= AbsF( inputHeading );
			turnDelta		= ClampF( SignF( inputHeading ) * _Speed * _Dt, -inputHeadingAbs, inputHeadingAbs );
			AddYaw( turnDelta );
			
			
			if( AbsF( turnDelta ) + tolerance >= inputHeadingAbs )
			{
				return true;
			}			
		}
		
		return false;
	}
	
	
	private function UpdateBanking( _Dt : float)
	{
		var l_BankingCurF		: float;
		var l_RotationNeededF	: float;
		var	l_RotationEA		: EulerAngles;
		
		
		l_RotationEA		= m_ExplorationO.m_OwnerE.GetWorldRotation();
		l_BankingCurF		= l_RotationEA.Roll;
		
		
		l_RotationNeededF	= AngleDistance( m_BankingTargetF, l_BankingCurF );
		
		
		if( AbsF( l_RotationNeededF ) > m_BankingSpeedF * _Dt )
		{
			l_RotationNeededF	= SignF( l_RotationNeededF ) * m_BankingSpeedF * _Dt;
		}
		
		else
		{
			m_BankingNeedsUpdatingB	= false;
		}
		
		Rotate( EulerAngles( 0.0f, 0.0f, l_RotationNeededF ) );
	}	
	
	
	private function ComputeSlideDirAndNormal()
	{	
		var aux : float;
		
		
		m_SlideNormalV		= m_ExplorationO.m_OwnerMAC.GetTerrainNormal( true ); 
		m_SlideNormalRealV	= m_ExplorationO.m_OwnerMAC.GetTerrainNormal( false ); 
		
		
		if( m_SlideNormalV == m_ZeroV )
		{
			return;
		}
		
		m_SlideDirV	= VecCross( m_SlideNormalV, m_UpV );
		m_SlideDirV	= VecCross( m_SlideNormalV, m_SlideDirV );
		
		m_SlideRealangleF	=	ComputeRealSlideCoefFromNormal( m_SlideNormalRealV.Z );
		m_SlideRealangleF	=	ConvertCoefToAngleDegree( m_SlideRealangleF );
		
		m_SlideComputedThisFrameB	= true;
		
		
	}
	
	
	private function ComputeSlideWideCoef()
	{
		var wideNormalGlobal, wideNormalAverage, direction : Vector;
		
		if( !m_SlideComputedThisFrameB )
		{
			ComputeSlideDirAndNormal();
		}
		
		if( VecLengthSquared( m_SlideDirV ) < 0.9f )
		{
			direction	= m_ExplorationO.m_OwnerE.GetWorldForward();
		}
		else
		{
			direction	= VecNormalize( m_SlideDirV );
		}
		
		m_ExplorationO.m_OwnerMAC.GetTerrainNormalWide( m_WideNormalAverageV, m_WideNormalGlobalV, direction, m_SlideTerrainWideDistHorizF, m_SlideTerrainWideDistFwdF, m_SlideTerrainWideDistBwdF );
		
		m_SlideWideCoefRealAverageF	= ComputeRealSlideCoefFromNormal( m_WideNormalAverageV.Z );
		m_SlideWideCoefRealGlobalF	= ComputeRealSlideCoefFromNormal( m_WideNormalGlobalV.Z );
		m_SlideWideCoefAverageF = ComputeSlideCoefFromNormal( m_WideNormalAverageV.Z );
		m_SlideWideCoefGlobalF = ComputeSlideCoefFromNormal( m_WideNormalGlobalV.Z );
		
		m_SlideWideComputedThisFrameB	= true;		
	}
	
	
	public function GetSlideDirAndNormal( out slideDir : Vector, out slideNormal : Vector )
	{
		if( !m_SlideComputedThisFrameB )
		{
			ComputeSlideDirAndNormal();
		}
		
		slideDir	= m_SlideDirV;
		slideNormal	= m_SlideNormalV;
	}
	
	
	public function GetSlideDir() : Vector
	{
		if( !m_SlideComputedThisFrameB )
		{
			ComputeSlideDirAndNormal();
		}
		
		return m_SlideDirV;
	}
	
	
	public function SetSuperSlide( enabled : bool )
	{
		superSlide	= enabled;
	}
	
	
	public function GetSlideCoef( forceNoDamp : bool, optional coefExtra : float ) : float
	{
		var	coef : float;
		
		
		coef	= GetRawSlideCoef( forceNoDamp );
		
		if( superSlide )
		{
			coef	*= 2.0f;
		}
		
		if( m_UseMaterialsB )
		{
			
			if( coef > 0.0f && m_CoefMinMaterialF != m_SlidingLimitMinF )
			{
				coef	= m_SlidingLimitMinF + coef * ( m_SlidingLimitMaxF - m_SlidingLimitMinF ) + coefExtra;
				if( true ) 
				{
					coef	= MapF( coef, m_CoefMinMaterialF, m_SlidingLimitMaxF, 0.0f, 1.0f );
				}
				else
				{
					coef = -1.0f;
				}
			}
		}
		
		return coef;
	}
	
	
	public function GetRawSlideCoef( forceNoDamp : bool ) : float
	{
		var coef	: float;
		
		
		if( !forceNoDamp && m_ExplorationO.m_OwnerMAC.IsSliding() )
		{
			coef	=	m_ExplorationO.m_OwnerMAC.GetSlideCoef();
		}
		
		else
		{
			coef	=	GetSlideCoefFromTerrain();
		}
		
		return coef;
	}
	
	
	public function GetRealSlideAngle() : float
	{		
		if( !m_SlideComputedThisFrameB )
		{
			ComputeSlideDirAndNormal();
		}	
		
		
		return m_SlideRealangleF;
	}
	
	
	public function GetRealWideSlideAngle() : float
	{
		if( !m_SlideWideComputedThisFrameB )
		{
			ComputeSlideWideCoef();
		}
		
		return m_SlideWideCoefRealAverageF;
	}
	
	
	
	
	public function GetSlideWideCoefFromTerrain( average : bool ): float
	{
		if( !m_SlideWideComputedThisFrameB )
		{
			ComputeSlideWideCoef();
		}	
		
		if( average )
		{
			return m_SlideWideCoefAverageF;
		}
		else
		{
			return m_SlideWideCoefGlobalF;
		}
		
	}
	
	
	
	public function GetSlideCoefFromTerrain(): float
	{
		var	coef : float;
		
		if( !m_SlideComputedThisFrameB )
		{
			ComputeSlideDirAndNormal();
		}	
		
		coef = ComputeSlideCoefFromNormal( m_SlideNormalV.Z );
		
		return coef;
	}
	
	
	public function GetSlideSpeedMax() : float
	{
		return m_SlideMaxSpeedF;
	}
	
	
	public function SetSlideSpeedMode( fast : bool )
	{
		if( fast )
		{
			m_SlideMaxSpeedF	= m_SlideMaxSpeedToFallF;
		}
		else
		{
			m_SlideMaxSpeedF	= m_SlideMaxSpeedSafeF;
		}
	}
	
	
	private function ComputeRealSlideCoefFromNormal( normalZ : float ) : float
	{	
		var	coef : float;
		
		
		coef = AcosF( normalZ ) * 2.0f / Pi();
		
		return coef;
	}
	
	
	private function ComputeSlideCoefFromNormal( normalZ : float ) : float
	{	
		var	coef : float;
		
		
		coef = ComputeRealSlideCoefFromNormal( normalZ );
		coef = ClampF( ( coef - m_SlidingLimitMinF ) / ( m_SlidingLimitMaxF - m_SlidingLimitMinF ), 0.0f, 1.0f );
		
		return coef;
		
		
		
		
	}
	
	
	public function StopAllMovement()
	{	
		m_SpeedVerticalF	= 0.0f;
		SetVelocity( m_ZeroV );	
		VecSetZeros( m_DisplacementV );	
		EulerSetZeros( m_RotationDeltaEA );
		m_SpeedLastF		= 0.0f;
		m_AccelerationLastF	= 0.0f;
	}
	
	
	public function StopVerticalMovement()
	{
		m_SpeedVerticalF	= 0.0f;
		m_VelocityV.Z		= 0.0f;
		SetVelocity( m_VelocityV );
	}
	
	
	public function AddVelocity( velocity : Vector )
	{
		SetVelocity( m_VelocityV + velocity );
	}
	
	
	public function AddSpeed( speed : float )
	{
		SetVelocity( m_VelocityV + m_VelocityNormalizedV * speed );
	}
	
	
	public function SetVelocity( _NewVelocityV : Vector )
	{	
		m_VelocityV				= _NewVelocityV;
		m_VelocityV.W			= 0.0f;
		m_SpeedF				= VecLength( m_VelocityV );
		m_VelocityNormalizedV	= m_VelocityV;
		if( m_SpeedF != 0.0f )
		{
			m_VelocityNormalizedV	/= m_SpeedF;
		}
		m_SpeedHeadingF			= VecHeading( m_VelocityNormalizedV );
	}
	
	
	public function SetVerticalSpeed( _NewSpeedF : float )
	{		
		m_SpeedVerticalF	= _NewSpeedF;
	}
	
	
	public function AddVerticalSpeed( _NewSpeedF : float )
	{		
		m_SpeedVerticalF	+= _NewSpeedF;
	}
	
	
	public function SetBankingToReset()
	{
		SetBankingTarget( 0.0f, m_BankingSpeedDefaultF );
	}
	
	
	public function SetBankingTarget( _BankingF : float, _SpeedF : float)
	{				
		m_BankingTargetF		= _BankingF;
		m_BankingSpeedF			= _SpeedF;
		m_BankingNeedsUpdatingB	= true;
	}
	
	
	public function AddYaw( _DeltaYawF : float )
	{		
		m_RotationDeltaEA.Yaw	+= _DeltaYawF;
		Rotate( EulerAngles( 0.0f, _DeltaYawF, 0.0f ) );
	}
	
	
	
	
	
	

	
	public function	RotateYawTowards( _TargetYawF, _DeltaYawF, _ToleranceF : float, _SoftB :bool )
	{
		var l_RotationEA	: EulerAngles;
		var l_DistanceF		: float;
		var l_DistanceAbsF	: float;
		
		
		
		if( _DeltaYawF <= _ToleranceF)
		{
			return;
		}
		
		
		l_RotationEA		= m_ExplorationO.m_OwnerMAC.GetWorldRotation();
		l_DistanceF			= AngleDistance( _TargetYawF, l_RotationEA.Yaw + m_RotationDeltaEA.Yaw );
		
		l_DistanceAbsF	= AbsF( l_DistanceF );
		
		
		if( _DeltaYawF >= l_DistanceAbsF )
		{
			_DeltaYawF	= l_DistanceF;
		}		
		
		
		if( l_DistanceF < 0.0f )
		{
			_DeltaYawF	= -_DeltaYawF;
		}
		
		
		if( _SoftB )
		{
			_DeltaYawF	*= l_DistanceAbsF / 180.0f;
		}
		
		Rotate( EulerAngles( 0.0f, _DeltaYawF, 0.0f ) );
	}
	
	
	
	public function SetSpeedFromAnim( optional _MaxSpeedF : float )
	{
		var l_ImpulseV			: Vector;
		
		
		l_ImpulseV	= m_MACVelocityDampedV;
		
		
		if( _MaxSpeedF > 0.0f )
		{
			if( VecLengthSquared( l_ImpulseV ) > _MaxSpeedF * _MaxSpeedF )
			{
				l_ImpulseV	= VecNormalize( l_ImpulseV ) * _MaxSpeedF;
			}
		}
		
		m_ExplorationO.m_MoverO.SetVelocity( l_ImpulseV );
	}
	
	
	public function SetSpeedFromAnimFrontal( optional _MaxSpeedF : float )
	{
		var	l_FrontalSpeedF	: float;
		
		
		l_FrontalSpeedF	= VecDot( m_MACVelocityDampedV, m_ExplorationO.m_MoverO.GetMovementVelocityNormalized() );
		
		
		if( _MaxSpeedF > 0.0f )
		{
			l_FrontalSpeedF	= MinF( _MaxSpeedF, l_FrontalSpeedF );
		}
		
		m_ExplorationO.m_MoverO.SetVelocity( l_FrontalSpeedF * m_VelocityNormalizedV );
	}
	
	
	public function RemoveSpeedOnThisDirection( directionNormalized : Vector )
	{
		var dot					: float;
		var velocityToReduce	: Vector;
		
		
		dot	= VecDot( directionNormalized, m_VelocityV );
		if( dot > 0.0f )
		{
			velocityToReduce	= -directionNormalized * dot;
			AddVelocity( velocityToReduce );
		}
	}
	
	
	public function GetMovementHorizontalVelocityV( ) : Vector
	{		
		return m_VelocityV;
	}
	
	
	public function GetMovementVerticalSpeedF() : float
	{
		return m_SpeedVerticalF;
	}
	
	
	public function GetMovementVelocity() : Vector
	{
		var velocity	: Vector;
		
		velocity	= m_VelocityV;
		velocity.Z	+= m_SpeedVerticalF;
		
		return velocity;
	}
	
	
	public function GetMovementVelocityNormalized( ) : Vector
	{		
		return m_VelocityNormalizedV;
	}
	
	
	public function GetMovementSpeedF( ) : float
	{		
		return m_SpeedF;
	}	
	
	
	public function GetMovementSpeedHeadingF( ) : float
	{		
		return m_SpeedHeadingF;
	}	
	
	
	public function GetAccelerationnLastF() : float
	{
		return m_AccelerationLastF;
	}
	
	
	public function GetYawTurnThisFrameF() : float
	{
		return m_RotationDeltaEA.Yaw;
	}
}
