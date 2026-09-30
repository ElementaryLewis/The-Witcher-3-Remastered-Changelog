/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CExplorationSharedData extends CObject
{
	
	private						var	m_ExplorationO				: CExplorationStateManager; 
	
	
	
	public						var	m_AutoJumpOnPredictionB		: bool;							default	m_AutoJumpOnPredictionB		= false;
	public						var	m_AutoJumpToWaterB			: bool;							default	m_AutoJumpToWaterB			= true;
	
	
	
	public						var m_TimeSinceIdleF			: float;
	
	
	
	protected editable 			var	m_SprintJumpTimePreparingF	: float;						default	m_SprintJumpTimePreparingF	= 0.0f;
	
	
	protected editable			var	m_BehParamRightFootS		: name;							default	m_BehParamRightFootS		= 'JumpRightFoot';
	public						var	m_IsRightFootForwardB		: bool;
	
	
	public						var	m_JumpTypeE 				: EJumpType;
	public						var m_LandingOnWater			: bool;
	public 						var	m_JumpIsTooSoonToLandB		: bool;
	private 					var	m_FallHeightReachedF		: float;
	editable					var m_UsePantherJumpB			: bool;
	public						var	m_AirCollisionIsFrontal		: bool;
	
	public						var m_JumpDirectionForcedV		: Vector;
	
	public						var	m_CanFallSetVelocityB		: bool;
	public						var	m_ShouldFlipFootOnLandB		: bool;
	public						var	m_DontRecalcFootOnLandB		: bool;
	private						var	m_FromCriticalB				: bool;
	
	
	public						var m_ClimbStateTypeE			: EClimbRequirementType;
	
	
	editable					var	m_AirCollisionSideEnabledB	: bool;							default	m_AirCollisionSideEnabledB	= false;
	
	
	public						var	m_SkipLandAnimDistMaxF		: float;						default	m_SkipLandAnimDistMaxF		= 0.64f;
	public						var	m_SkipLandAnimTimeMaxF		: float;						default	m_SkipLandAnimTimeMaxF		= 0.1f;
	
	
	
	public	editable inlined	var m_SkateGlobalC				: CExplorationSkatingGlobal;
	
	
	private						var	m_LastExplorationS			: SExplorationQueryToken;
	private						var	m_LastExplorationValidB		: bool;
	public						var m_AngleToExploreManualF		: float;						default	m_AngleToExploreManualF		= 45.0f;
	public						var m_AngleToExploreAutoF		: float;						default	m_AngleToExploreAutoF		= 10.0f;
	
	
	public						var hasToRecoverFromRagdoll		: bool;
	
	
	private						var	m_TeleportTimeCurF			: float;
	public						var	m_TeleportTimeMaxF			: float;						default	m_TeleportTimeMaxF			= 0.5f;
	
	
	public						var terrainSlidePresetName		: name;
	
	
	private						var	terrainBlendSpeedCur		: float;
	private						var	terrainBlendSpeedTarget		: float;						default	terrainBlendSpeedTarget		= 3.0f;
	private						var	terrainBlendTimeCur 		: float;
	private						var	terrainBlendTimeMax			: float;						default	terrainBlendTimeMax			= 0.5f;
	
	
	
	public						var	m_JumpSwimRotationF			: float;
	private						var	m_JumpToWaterAreaB			: bool;
	public						var	m_JumpToWaterForcedDirV		: Vector;
	public						var	m_JumpToWaterRequireDirB	: bool;
	public						var	m_JumpToWaterRequireSprintB	: bool;
	
	
	private						var m_HeightFallenF				: float;
	private						var	lastPosition				: Vector;
	
	
	private						var	landAddAdding				: bool;
	private						var	landAddCurrent				: float;
	private editable inlined 	var landAddCurve				: CCurve;
	private						var	landAddCoef					: float;
	private	editable			var	landAddCoefWalk				: float;						default	landAddCoefWalk				= 0.7f;
	private	editable			var	landAddTimeCoefWalk			: float;						default	landAddTimeCoefWalk			= 1.75f;
	private						var	landAddTimeCur				: float;
	private	editable			var	landAddSpeedCancel			: float;						default	landAddSpeedCancel			= 30.0f;
	private						var	landAddTimeCoef				: float;
	private	editable			var	landAddTimeCoefFast			: float;						default	landAddTimeCoefFast			= 2.0f;
	private	editable			var	landAddBehVarName			: name;							default	landAddBehVarName			= 'LandInclinationAdd';
	
	
	
	private editable			var m_CameraModifyOffsetB		: bool;							default	m_CameraModifyOffsetB		= false;
	
	
	public						var m_UsePrototypeAnimationsB	: bool;							default	m_UsePrototypeAnimationsB	= false;
	public						var	m_ForceOnlyJumpB			: bool;							default	m_ForceOnlyJumpB			= false;
	public						var m_UseClimbB					: bool;							default	m_UseClimbB					= true;
	public						var m_UsepushB					: bool;							default	m_UsepushB					= false;
	public	 					var	hackKnockBackAlways			: bool;							default	hackKnockBackAlways			= false;
	
	
	
	public function Initialize( manager : CExplorationStateManager )
	{
		var test		: bool;
		
		
		m_ExplorationO	= manager;
		
		if( m_SkateGlobalC )
		{
			test = true;
		}
		else
		{
			m_SkateGlobalC	= new CExplorationSkatingGlobal in this;
		}
		m_SkateGlobalC.Initialize( manager );
		
		
		
		m_AngleToExploreManualF		= Deg2Rad( m_AngleToExploreManualF );
		m_AngleToExploreAutoF		= Deg2Rad( m_AngleToExploreAutoF );
		
		DisableJumpToWaterArea();
		
		
		if(thePlayer)
		{
			if( m_UsePrototypeAnimationsB )
			{
				thePlayer.SetBehaviorVariable( 'prototypeAnimations', 1.0f );
			}
			else
			{
				thePlayer.SetBehaviorVariable( 'prototypeAnimations', 0.0f );
			}
		}
		
		Reset();
	}
	
	
	public function Reset()
	{
		m_SkateGlobalC.Reset();
		
		ResetHeightFallen();
		
		landAddCurrent			= 0.0f;
		landAddTimeCoef			= 1.0f;
		landAddAdding			= false;
		m_CanFallSetVelocityB	= true;
		SetFallFromCritical( false );
		
		
		terrainBlendSpeedCur	= terrainBlendSpeedTarget;
		terrainBlendTimeCur		= terrainBlendTimeMax;
	}
	
	
	public function PreUpdate( _Dt : float )
	{
		m_LastExplorationValidB		= false;
		
		
		if( thePlayer.GetIsWalking() )
		{
			m_TimeSinceIdleF	+= _Dt;
		}
		else
		{
			m_TimeSinceIdleF	= 0.0f;
		}
		
		
		
		UpdateTerrainSlopeBlend( _Dt );
	}
	
	
	public function PostUpdate( _Dt : float )
	{	
		
		LandCrouchUpdate( _Dt );
		
		
		m_SkateGlobalC.PostUpdate( _Dt );
		
		lastPosition	= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		
		if( m_TeleportTimeCurF < m_TeleportTimeMaxF )
		{
			ResetHeightFallen();
			m_TeleportTimeCurF		+= _Dt;
		}
		
		
		m_LastExplorationValidB		= false;
	}
	
	
	public function DrawDebugText( horizontalPos, verticalPos, heightStep, width, height : int, textColor : Color ) : int
	{
		var text	: string;
		
		
		text	= " HeightFallen : " + m_HeightFallenF + "    Height Reached : " + m_FallHeightReachedF;
		thePlayer.GetVisualDebug().AddBar( 'HeightFallen', horizontalPos, verticalPos, width, height, 0.0f, textColor, text, 0.0f );
		verticalPos	+= heightStep;
		
		return verticalPos;
	}
	
	
	function OnTeleported()
	{
		ResetHeightFallen();
		m_TeleportTimeCurF	= 0.0f;
	}
	
	
	
	public function HasToFallFromLadder() : bool
	{
		if( GetCurentExplorationType() != ET_Ladder )
		{
			return false;
		}
		if( m_ExplorationO.m_CollisionManagerO.CheckLandBelow( 0.55, Vector( 0.0f, 0.0f, 0.5f ), true ) )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function GetFallFromCritical() : bool
	{
		return m_FromCriticalB;
	}
	
	
	public function SetFallFromCritical( fall : bool )
	{
		m_FromCriticalB		= fall;
		m_ExplorationO.SetBehaviorParamBool( 'FallFromCritical', fall );
	}
	
	
	private function LandCrouchUpdate( _Dt : float )
	{
		if( landAddAdding )
		{
			if( landAddTimeCur <= landAddCurve.GetDuration() )
			{
				landAddTimeCur	+= _Dt * landAddTimeCoef;
				landAddCurrent	= landAddCurve.GetValue( landAddTimeCur ) * landAddCoef;
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( landAddBehVarName,  landAddCurrent );
			}
		}
		else
		{
			if( landAddCurrent >= 0.0f )
			{
				landAddCurrent	= BlendF( landAddCurrent, 0.0f, landAddSpeedCancel * _Dt ); 
				m_ExplorationO.m_OwnerE.SetBehaviorVariable( landAddBehVarName,  landAddCurrent );
			}
		}
	}
	
	
	public function LandCrouchStart( walking : bool )
	{
		if( walking )
		{
			landAddCoef		= landAddCoefWalk;
			landAddTimeCoef	= landAddTimeCoefWalk;
		}
		else
		{
			landAddCoef		= 1.0f;
			landAddTimeCoef	= 1.0f;
		}
		landAddAdding	= true;
		
		
			landAddTimeCur	= 0.0f;
		
	}
	
	
	public function LandCrouchCancel()
	{
		landAddAdding	= false;
	}
	
	
	public function LandCrouchSpeedUp()
	{
		landAddTimeCoef	= landAddTimeCoefFast;
	}
	
	
	
	
	
	
	public function SetExplorationToken( exploration : SExplorationQueryToken, tag : string )
	{
		m_LastExplorationS		= exploration;
		m_LastExplorationValidB	= true;
		
		if( m_ExplorationO.m_IsDebugModeB )
		{
			LogExplorationToken( "Token set by : " + tag + GetExplorationTokenDescription( exploration ) );
		}
	}
	
	
	public function GetExplorationTokenDescription( exploration : SExplorationQueryToken ) : string
	{
		var text : string;
		
		text	= ". Type " + exploration.type
				+ ". Valid: " + exploration.valid 
				+ ". Pos diff from player: " + VecToString( exploration.pointOnEdge - thePlayer.GetWorldPosition() )
				+ ". Normal: " + VecToString( exploration.normal );
				
		return text;
	}
	
	
	public function HasValidExploration() : bool
	{
		return m_LastExplorationValidB && m_LastExplorationS.valid;
	}
	
	
	public function GetLastExploration() : SExplorationQueryToken
	{
		return m_LastExplorationS;
	}
	
	
	public function HasValidLadderExploration() : bool
	{
		if( !HasValidExploration() )
		{
			return false;
		}
		
		if( m_LastExplorationS.type != ET_Ladder )
		{
			return false;
		}
		
		return true;
	}
	
	
	public function GetCurentExplorationType() : EExplorationType
	{
		return m_LastExplorationS.type;
	}
	
	
	public function IsForceHeading( out targetRotation : EulerAngles ) : bool
	{
		var	imput	: Vector;
		
		if( m_ExplorationO.GetStateCur() == 'Interaction' )
		{
			targetRotation.Yaw			= 180.0f + VecHeading( m_LastExplorationS.normal );
			if( !m_ExplorationO.m_InputO.IsModuleConsiderable() )
			{
				targetRotation.Pitch	= 0.0f;
			}
			else
			{
				imput					= m_ExplorationO.m_InputO.GetMovementOnPadV();
				targetRotation.Pitch	= imput.Y * 65.0f;
			}
			targetRotation.Roll			= 0.0f;
			
			return true;
		}
		
		return false;
	}
	
	
	
	
	
	
	
	public function UpdateTerrainSlopeBlend( _Dt : float )
	{
		if( terrainBlendTimeCur < terrainBlendTimeMax )
		{
			terrainBlendTimeCur		+= _Dt;
			terrainBlendSpeedCur	= BlendF( terrainBlendSpeedCur, terrainBlendSpeedTarget, MinF( terrainBlendTimeCur / terrainBlendTimeMax, 1.0f ) );
			thePlayer.SetBehaviorVariable( 'onSteepSlopeDampSpeed', terrainBlendSpeedCur );
		}
	}
	
	
	public function SetTerrainSlopeSpeed( speed : float )
	{
		terrainBlendTimeCur		= 0.0f;
		terrainBlendSpeedCur	= speed;
		thePlayer.SetBehaviorVariable( 'terrainBlendSpeed', terrainBlendSpeedCur );
	}
	
	
	public function SetTerrainSlopeInstant( slope : float )
	{
		thePlayer.SetBehaviorVariable( 'terrainPitch', slope );
		thePlayer.SetTerrainPitch( slope );
	}
	
	
	
	
	
	
	public function ResetHeightFallen()
	{
		m_HeightFallenF			= 0.0f;
		m_FallHeightReachedF	= 0.0f;
		
		lastPosition			= m_ExplorationO.m_OwnerE.GetWorldPosition();
		
		if( m_ExplorationO.m_IsDebugModeB )
		{
			LogChannel( 'FallingNewHeight', "Height fallen resetted" );
		}
	}
	
	
	public function GetFallingHeight() : float
	{
		return m_HeightFallenF;
	}
	
	
	public function GetFallingMaxHeightReached() : float
	{
		return m_FallHeightReachedF;
	}
	
	
	public function UpdateFallHeight()
	{
		var currentPosition	: Vector;
		var heightIncrease	: float;
		
		currentPosition		= m_ExplorationO.m_OwnerE.GetWorldPosition();
		heightIncrease		= currentPosition.Z - lastPosition.Z;
		
		m_HeightFallenF	+= heightIncrease;
		
		if( heightIncrease > 0.0f )
		{
			m_FallHeightReachedF	+= heightIncrease;
		}
	}
	
	
	public function CalculateFallingHeights( out fallDiff : float, out jumpTotalDiff : float )
	{
		fallDiff		= -GetFallingHeight(); 
		jumpTotalDiff	= m_FallHeightReachedF;
	}
	
	
	public function SetFotForward( optional reverse : bool )
	{
		var rightFoot	: bool;
		
		rightFoot	= m_ExplorationO.m_MoverO.IsRightFootForward();
		
		if( reverse )
		{
			rightFoot	= !rightFoot;
		}
		
		m_IsRightFootForwardB	= rightFoot;
		
		m_ExplorationO.SetBehaviorParamBool( m_BehParamRightFootS, rightFoot );
	}
	
	
	public function ForceFotForward( right : bool )
	{
		m_ExplorationO.SetBehaviorParamBool( m_BehParamRightFootS, right );
	}
	
	
	
	
	
	
	public function EnableJumpToWaterArea( optional needDirection : bool, optional direction : Vector, optional requireSprint : bool )	
	{
		m_JumpToWaterAreaB			= true;
		m_JumpToWaterForcedDirV		= direction;
		m_JumpToWaterRequireDirB	= needDirection;
		m_JumpToWaterRequireSprintB	= requireSprint;
	}
	
	
	public function DisableJumpToWaterArea()	
	{
		m_JumpToWaterAreaB		= false;
	}
	
	
	public function GetJumpToWaterArea() : bool
	{
		return m_JumpToWaterAreaB;
	}
	
	
	
	
	
	
	public function SetUseClimb( enable : bool )
	{
		m_UseClimbB				= enable;
	}
	
	
	public function SetHackKnockBack( enable : bool )
	{
		hackKnockBackAlways		= enable;
	}
	
	
	public function SwitchUseOnlyJumpClimbs()
	{
		m_ForceOnlyJumpB		= !m_ForceOnlyJumpB;
	}
	
	
	public function SetAirCollisionSideEnabled( enabled : bool )
	{
		m_AirCollisionSideEnabledB	= enabled;
	}
	
	
	public function SwitchPrototypeAnimations()
	{
		m_UsePrototypeAnimationsB	= !m_UsePrototypeAnimationsB;
		if( m_UsePrototypeAnimationsB )
		{
			thePlayer.SetBehaviorVariable( 'prototypeAnimations', 1.0f );
		}
		else
		{
			thePlayer.SetBehaviorVariable( 'prototypeAnimations', 0.0f );
		}
	}
	
	
	
	
	
	
	function GoToRagdoll()
	{
		var actor	: CActor;
		var params	: SCustomEffectParams;
		
		actor				= (CActor) m_ExplorationO.m_OwnerE;
		
		params.effectType	= EET_Ragdoll;
		params.creator		= actor;
		params.duration		= 20;
		params.sourceName	= actor.GetName();
		
		actor.AddEffectCustom(params);
	}
	
	
	function GoToKnockDown() 
	{
		var actor	: CActor;
		var params	: SCustomEffectParams;
		
		actor				= (CActor) m_ExplorationO.m_OwnerE;
		
		params.effectType	= EET_Knockdown;
		params.creator		= actor;
		params.duration		= 20;
		params.sourceName	= 'SlideFall';
		
		actor.AddEffectCustom(params);
	}
	
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo )
	{
		m_SkateGlobalC.OnAnimEvent( animEventName, animEventType, animInfo );
	}
	
	
	public function EnableCameraOffsetCorrection( enable : bool )
	{
		m_CameraModifyOffsetB	=  enable;
	}
	
	
	public function CameraOffsetEnabled() : bool
	{
		return m_CameraModifyOffsetB;
	}	
}