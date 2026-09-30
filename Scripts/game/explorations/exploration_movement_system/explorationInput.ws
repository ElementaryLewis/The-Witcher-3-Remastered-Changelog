/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationInput
{	
	
	private				var		m_ExplorationO					: CExplorationStateManager;
	
	
	private 			var		m_InputMoveOnPadV				: Vector;
	private 			var		m_InputMoveOnPlaneV				: Vector;
	private 			var		m_InputMoveOnPadNormalizedV		: Vector;
	private 			var		m_InputMoveOnPlaneNormalizedV	: Vector;
	private 			var		m_InputMoveOnCameraNormalizedV	: Vector;
	private 			var		m_InputMoveDiffOnHeadingF		: float;
	private				var		m_InputMoveHeadingOnPlaneF		: float;
	private 			var		m_InputModuleF					: float;
	private	editable	var		m_InputMinModuleF				: float;				default	m_InputMinModuleF			= 0.1f;
	private	editable	var		m_InputRunModuleF				: float;				default	m_InputRunModuleF			= 0.5f;
	
	
	private editable	var		m_InputHeadingDifMaxF			: float;				default	m_InputHeadingDifMaxF		= 50.0f;
	private editable	var		m_InputHeadingDifReflectedF		: float;				default	m_InputHeadingDifReflectedF	= 90.0f;
	
	
	protected editable	var		m_JumpTimeGapF					: float;				default	m_JumpTimeGapF				= 0.25f;
	protected editable	var		m_RollTimePrevF					: float;				default	m_RollTimePrevF				= 0.3f;
	
	
	private	editable	var		m_InputDoubleTapPressValF		: float;				default	m_InputDoubleTapPressValF	= 0.75f;
	private	editable	var		m_InputDoubleTapUnPressValF		: float;				default	m_InputDoubleTapUnPressValF	= 0.3f;
	private	editable	var		m_InputDoubleTapTimeGapF		: float;				default	m_InputDoubleTapTimeGapF	= 0.2f;
	
	
	public	editable	var		m_UseDoubleTapOnAxisB			: bool;					default	m_UseDoubleTapOnAxisB		= false;
	private			 	var		m_InputLeftO					: CInputAxisDoubleTap;
	private			 	var		m_InputRightO					: CInputAxisDoubleTap;
	private			 	var		m_InputDownO					: CInputAxisDoubleTap;
	private			 	var		m_InputUpO						: CInputAxisDoubleTap;
	private				var		m_SprintDoubletapO				: CInputAxisDoubleTap;
	private	editable	var		m_ActionJumpN					: name;					default	m_ActionJumpN				= 'Jump';
	private	editable	var		m_ActionExplorationN			: name;					default	m_ActionExplorationN		= 'ExplorationInteraction';
	private	editable	var		m_ActionInteractionN			: name;					default	m_ActionInteractionN		= 'Interaction';
	private	editable	var		m_ActionRollN					: name;					default	m_ActionRollN				= 'Roll';
	private	editable	var		m_ActionSprintN					: name;					default	m_ActionSprintN				= 'Sprint';
	private	editable	var		m_ActionSkateJumpN				: name;					default	m_ActionSkateJumpN			= 'Jump';
	private	editable	var		m_ActionDashN					: name;					default	m_ActionDashN				= 'Dash';
	private	editable	var		m_ActionDriftN					: name;					default	m_ActionDriftN				= 'Drift';
	private	editable	var		m_ActionAttackN					: name;					default	m_ActionAttackN				= 'AttackLight';
	private	editable	var		m_ActionAttackAltN				: name;					default	m_ActionAttackAltN			= 'AttackHeavy';
	private	editable	var		m_ActionParryN					: name;					default	m_ActionParryN				= 'Guard';
	
	private editable	var		m_SprintLastActivationTimeF		: float;
	
	
	
	public function Initialize( _ExplorationO : CExplorationStateManager )
	{
		m_ExplorationO	= _ExplorationO;
		
		if( m_UseDoubleTapOnAxisB )
		{
			m_InputLeftO		= new CInputAxisDoubleTap in this;
			m_InputRightO		= new CInputAxisDoubleTap in this;
			m_InputUpO			= new CInputAxisDoubleTap in this;
			m_InputDownO		= new CInputAxisDoubleTap in this;
			m_SprintDoubletapO	= new CInputAxisDoubleTap in this;
			
			m_InputLeftO.Initialize		( 'GI_AxisLeftX', -m_InputDoubleTapPressValF	, -m_InputDoubleTapUnPressValF	, m_InputDoubleTapTimeGapF );
			m_InputRightO.Initialize	( 'GI_AxisLeftX', m_InputDoubleTapPressValF		, m_InputDoubleTapUnPressValF	, m_InputDoubleTapTimeGapF );
			m_InputDownO.Initialize		( 'GI_AxisLeftY', -m_InputDoubleTapPressValF	, -m_InputDoubleTapUnPressValF	, m_InputDoubleTapTimeGapF );
			m_InputUpO.Initialize		( 'GI_AxisLeftY', m_InputDoubleTapPressValF		, m_InputDoubleTapUnPressValF	, m_InputDoubleTapTimeGapF );
			m_SprintDoubletapO.Initialize( m_ActionSprintN, m_InputDoubleTapPressValF		, m_InputDoubleTapUnPressValF	, m_InputDoubleTapTimeGapF );
		}
		
		m_SprintLastActivationTimeF	= 0.0f;
	}
	
	
	public function Update( _Dt : float )
	{
		UpdateDirectionVectors();
		
		UpdateHeading();
		
		if( m_UseDoubleTapOnAxisB )
		{			
			UpdateAxesDoubletaps();
		}
		
		
	}
	
	
	private function UpdateAxesDoubletaps()
	{
		m_InputLeftO.Update();
		m_InputRightO.Update();
		m_InputUpO.Update();
		m_InputDownO.Update();
		m_SprintDoubletapO.Update();
	}
	
	
	private function UpdateSimpleActions( _Dt : float )
	{
		m_SprintLastActivationTimeF	+= _Dt;
		
		if( thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && thePlayer.IsActionAllowed( EIAB_Sprint ) )
		{
			if( theInput.GetActionValue( m_ActionSprintN ) )
			{
				m_SprintLastActivationTimeF	= 0.0f;
			}
		}
	}
	
	
	private function UpdateDirectionVectors()
	{			
		var	l_InputMoveOnCameraV	: Vector;
		
		
		
		
		m_InputMoveOnPadV.X		= theInput.GetActionValue( 'GI_AxisLeftX' );
		m_InputMoveOnPadV.Y		= theInput.GetActionValue( 'GI_AxisLeftY' );
		
		m_InputMoveOnPadV.Z		= 0.0f;
		m_InputMoveOnPadV.W		= 0.0f;
		
		
		m_InputModuleF			= VecLengthSquared( m_InputMoveOnPadV );
		if( m_InputModuleF < m_InputMinModuleF )
		{
			SetZeroInput();
			return;
		}
		
		
		m_InputModuleF				= SqrtF( m_InputModuleF );
		m_InputMoveOnPadNormalizedV	= m_InputMoveOnPadV / m_InputModuleF;
		
		
		if( m_InputModuleF > 1.0f )
		{
			m_InputModuleF		=	1.0f;
			m_InputMoveOnPadV	=	m_InputMoveOnPadNormalizedV;
		}
		
		
		l_InputMoveOnCameraV			= theCamera.GetCameraRight() 	* m_InputMoveOnPadV.X
										+ theCamera.GetCameraForward()	* m_InputMoveOnPadV.Y;
		m_InputMoveOnCameraNormalizedV	= VecNormalize( l_InputMoveOnCameraV );
		
		
		m_InputMoveOnPlaneV				=	l_InputMoveOnCameraV;
		m_InputMoveOnPlaneV.Z			=	0.0f;
		
		m_InputMoveOnPlaneNormalizedV	=	VecNormalize( m_InputMoveOnPlaneV );
		m_InputMoveOnPlaneV				=	m_InputModuleF * m_InputMoveOnPlaneNormalizedV;
	}
	
	
	private function SetZeroInput()
	{
		m_InputModuleF	= 0.0f;
		VecSetZeros( m_InputMoveOnPadV );
		VecSetZeros( m_InputMoveOnPadNormalizedV );
		VecSetZeros( m_InputMoveOnCameraNormalizedV );
		VecSetZeros( m_InputMoveOnPlaneV );
		VecSetZeros( m_InputMoveOnPlaneNormalizedV );
	}
	
	
	private function UpdateHeading()
	{
		var l_InputVectorV		: Vector;
		var l_CharacterHeadingF	: float;
		
		
		
		if( m_InputModuleF < m_InputMinModuleF )
		{
			l_InputVectorV	= theCamera.GetCameraForwardOnHorizontalPlane();
		}
		
		else
		{
			l_InputVectorV	= m_InputMoveOnPlaneV;
		}
		
		
		m_InputMoveHeadingOnPlaneF	= AngleNormalize180( VecHeading( l_InputVectorV ) );
		l_CharacterHeadingF			= AngleNormalize180( m_ExplorationO.m_OwnerE.GetHeading() );
		m_InputMoveDiffOnHeadingF	= AngleDistance( m_InputMoveHeadingOnPlaneF, l_CharacterHeadingF );
	}
	
	
	public function PostUpdate( _Dt : float )
	{
		
		if( m_UseDoubleTapOnAxisB )
		{
			m_InputLeftO.ConsumeIfActivated();
			m_InputRightO.ConsumeIfActivated();
			m_InputUpO.ConsumeIfActivated();
			m_InputDownO.ConsumeIfActivated();
			m_SprintDoubletapO.ConsumeIfActivated();
		}
	}
	
	
	public function GetDoubleTapUp( ) : bool
	{
		return m_UseDoubleTapOnAxisB && m_InputUpO.IsActiveB();
	}
	
	
	public function GetDoubleTapDownB( ) : bool
	{
		return m_UseDoubleTapOnAxisB && m_InputDownO.IsActiveB();
	}
	
	
	public function GetDoubleTapLeftB( ) : bool
	{
		return m_UseDoubleTapOnAxisB && m_InputLeftO.IsActiveB();
	}
	
	
	public function GetDoubleTapRightB( ) : bool
	{
		return m_UseDoubleTapOnAxisB && m_InputRightO.IsActiveB();
	}
	
	
	public function GetDoubleTapRollB( ) : bool
	{
		return m_UseDoubleTapOnAxisB && m_SprintDoubletapO.IsActiveB();
	}
	
	
	
	public function GetModuleF( ) : float
	{
		return m_InputModuleF;
	}
	
	
	public function GetMovementOnPadV( ) : Vector
	{
		return m_InputMoveOnPadV;
	}
	
	
	public function GetMovementOnPadNormalizedV( ) : Vector
	{
		return m_InputMoveOnPadNormalizedV;
	}
	
	
	public function GetMovementOnCameraNormalizedV( ) : Vector
	{
		return m_InputMoveOnCameraNormalizedV;
	}
	
	
	public function GetMovementOnPlaneV( ) : Vector
	{
		return m_InputMoveOnPlaneV;
	}
	
	
	public function GetMovementOnPlaneNormalizedV( ) : Vector
	{
		return m_InputMoveOnPlaneNormalizedV;
	}
	
	
	public function GetHeadingOnPadF() : float
	{
		return VecHeading( m_InputMoveOnPadV );
	}
	
	
	public function GetHeadingOnPlaneF() : float
	{
		return m_InputMoveHeadingOnPlaneF;
	}
	
	
	public function GetHeadingDiffFromPlayerF() : float
	{
		return m_InputMoveDiffOnHeadingF;
	}
	
	
	public function GetHeadingDiffFromYawF( yaw : float ) : float
	{
		yaw	= AngleNormalize180( yaw );
		
		return AngleDistance( m_InputMoveHeadingOnPlaneF, yaw );
	}
	
	
	public function ComputeHeadingDiffWithReflectionF( targetHeading : float, reflectAllow : bool, out diffReal : float, out diffPercent : float, out shouldReflect : bool, optional requireinputModule : bool )
	{
		var directionDiffAbs	: float;
		
		
		
		if( requireinputModule )
		{
			if( !IsModuleConsiderable() )
			{
				diffReal 	= 0.0f;
				diffPercent	= 0.0f;
				
				return;
			}
		}
		
		
		targetHeading			= AngleNormalize180( targetHeading );
		diffReal				= AngleDistance( m_InputMoveHeadingOnPlaneF, targetHeading );
		directionDiffAbs		= AbsF( diffReal );
		
		
		shouldReflect			= directionDiffAbs > m_InputHeadingDifReflectedF;
		if( reflectAllow && shouldReflect )
		{
			directionDiffAbs	= 180.0f - directionDiffAbs;
			diffReal			= directionDiffAbs * SignF( diffReal );
		}
		
		
		if( directionDiffAbs > m_InputHeadingDifMaxF )
		{
			directionDiffAbs	= m_InputHeadingDifMaxF;
			diffReal			= SignF( diffReal ) * m_InputHeadingDifMaxF;
		}
		
		
		diffPercent				= diffReal / m_InputHeadingDifMaxF;
	}
	
	
	public function GetInputDirOnSlopeDot() : float
	{
		var slideDir		: Vector;
		var slideNormal		: Vector;
		var input			: Vector;
		var slideDir2D		: Vector;
		var dot				: float;
		
		
		
		input			= GetMovementOnPlaneV();	
		
		
		m_ExplorationO.m_MoverO.GetSlideDirAndNormal( slideDir, slideNormal );
		slideDir2D		= slideDir;
		slideDir2D.Z	= 0.0f;
		slideDir2D		= VecNormalize( slideDir2D );
		
		
		dot 			= VecDot( input, slideDir2D );
		
		return dot;
	}
	
	
	public function IsModuleConsiderable() : bool
	{
		return m_InputModuleF	>= m_InputMinModuleF;
	}
	
	
	public function IsModuleRunning() : bool
	{
		return m_InputModuleF >= m_InputRunModuleF;
	}
	
	
	public function IsRollPressedInTime() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_Roll ) )
		{
			return false;
		}
		
		return theInput.GetLastActivationTime( m_ActionRollN ) < m_RollTimePrevF;
	}
	
	
	public function  IsRollJustPressed() : bool
	{
		if( thePlayer.IsActionAllowed( EIAB_Roll ) )
		{
			return theInput.IsActionJustPressed( m_ActionRollN );
		}
		
		return false;
	}
	
	
	public function  IsGuardPressed() : bool
	{
		if( thePlayer.IsActionAllowed( EIAB_Parry ) )
		{
			return theInput.IsActionJustPressed( m_ActionParryN );
		}
		
		return false;
	}
	
	
	public function IsJumpPressedInTime( ) : bool
	{
		
		
			return theInput.GetLastActivationTime( m_ActionJumpN ) < m_JumpTimeGapF;
		
		
		
	}
	
	
	public function  GetJumpLastJustPressedTime( ) : float
	{
		return theInput.GetLastActivationTime( m_ActionJumpN );
	}
	
	
	public function GetJumpTimeGap() : float
	{
		return m_JumpTimeGapF;
	}
	
	
	public function  IsJumpJustPressed() : bool
	{
		return theInput.IsActionJustPressed( m_ActionJumpN );
	}
	
	
	public function  IsJumpJustReleased() : bool
	{
		return theInput.IsActionJustReleased( m_ActionJumpN );
	}
	
	
	public function  IsJumpPressed() : bool
	{
		return theInput.IsActionPressed( m_ActionJumpN );
	}
	
	
	public function IsExplorationJustPressed() : bool
	{
		return theInput.IsActionJustPressed( m_ActionExplorationN );
	}
	
	
	public function IsInteractionJustPressed() : bool
	{
		return theInput.IsActionJustPressed( m_ActionInteractionN );
	}
	
	
	public function IsExplorationPressed() : bool
	{
		return theInput.IsActionPressed( m_ActionExplorationN );
	}
	
	
	public function GetExplorationLastJustPressedTime() : float
	{
		return theInput.GetLastActivationTime( m_ActionExplorationN );
	}
	
	
	public function GetIsDebugKeyPressed() : bool
	{
		if( theGame.IsFinalBuild() )
		{
			return false;
		}
		
		return theInput.IsActionPressed( 'DebugInput' );
	}
	
	
	public function  IsSprintJustPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && thePlayer.IsActionAllowed( EIAB_Sprint ) )
		{
			return false;
		}
		return theInput.IsActionJustPressed( m_ActionSprintN );
	}
	
	
	public function  IsSprintPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && thePlayer.IsActionAllowed( EIAB_Sprint ) )
		{
			return false;
		}
		return theInput.GetActionValue( m_ActionSprintN );
	}
	
	
	public function IsSprintPressedInTime( time : float ) : bool
	{
		if( thePlayer.IsActionAllowed( EIAB_RunAndSprint ) && thePlayer.IsActionAllowed( EIAB_Sprint ) )
		{
			return theInput.GetLastActivationTime( m_ActionSprintN ) < time;
		}
		
		return false;
	}
	
	
	
	public function IsSkateJumpJustPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_Jump ) )
		{
			return false;
		}
		return theInput.IsActionJustPressed( m_ActionSkateJumpN );
	}
	
	
	public function  GetSkateJumpLastPressedTime(): float
	{
		if( !thePlayer.IsActionAllowed( EIAB_Jump ) )
		{
			return -1000.0f;
		}
		return theInput.GetLastActivationTime( m_ActionSkateJumpN );
	}
	
	
	public function  IsDashJustPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
		{
			return false;
		}
		
		return theInput.IsActionJustPressed( m_ActionDashN );
	}
	
	
	public function  IsDashPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
		{
			return false;
		}
		return theInput.GetActionValue( m_ActionDashN );
	}
	
	
	public function	GetDashLastPressedTime() : float
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
		{
			return -1000.0f;
		}
		return theInput.GetLastActivationTime( m_ActionDashN );
	}
	
	
	public function  IsDriftJustPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
		{
			return false;
		}
		return theInput.IsActionJustPressed( m_ActionDriftN );
	}
	
	
	public function  IsDriftPressed() : bool
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
		{
			return false;
		}
		return theInput.GetActionValue( m_ActionDriftN );
	}
	
	
	public function  GetDriftLastPressedTime(): float
	{
		if( !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) )
		{
			return -1000.0f;
		}
		return MinF( theInput.GetLastActivationTime( m_ActionDriftN ), theInput.GetLastActivationTime( m_ActionAttackAltN ) );
	}
	
	
	public function  IsSkateAttackPressed() : bool
	{
		
		return theInput.IsActionPressed( m_ActionAttackN ) || theInput.IsActionPressed( m_ActionAttackAltN );
	}
	
	
	public function  IsSkateAttackJustPressed() : bool
	{
		
		return theInput.IsActionJustPressed( m_ActionAttackN ) || theInput.IsActionJustPressed( m_ActionAttackAltN );
	}
	
	
	public function IsSkateAttackPressedInTime( time : float ) : bool
	{
		
		return theInput.GetLastActivationTime( m_ActionAttackN ) < time || theInput.GetLastActivationTime( m_ActionAttackAltN ) < time;
	}
}