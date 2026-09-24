/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum ECameraBlendSpeedMode
{
	ECBSM_Time		= 0,
	ECBSM_Distance	= 1,
	ECBSM_Height	= 2,
}



class CCameraPivotPositionControllerJump extends ICustomCameraScriptedPivotPositionController
{
	
	editable	var	useExactCamera			: bool;		default	useExactCamera			= true;
	private		var	originalOffset			: Vector;
	
	
	
	editable	var	zOffset					: float;	default	zOffset					= 2.5f;
	private		var	originalPosition		: Vector;
	private		var	originalHeight			: float;
	
	
	editable	var	blendXYSpeed			: float;	default	blendXYSpeed			= 6.0f;
	editable	var	blendXYSpeedWithTime	: bool;		default	blendXYSpeedWithTime	= false;
	editable	var	blendXYSpeedTimeStart	: float;	default	blendXYSpeedTimeStart	= 0.0f;
	editable	var	blendXYSpeedTimeEnd		: float;	default	blendXYSpeedTimeEnd		= 1.0f;
	editable	var	blendXYSpeedMin			: float;	default	blendXYSpeedMin			= 4.0f;
	editable	var	blendXYSpeedMax			: float;	default	blendXYSpeedMax			= 30.0f;
	editable	var	blendZSpeedStart		: float;	default	blendZSpeedStart		= 0.0f;
	editable	var	blendZSpeedEnd			: float;	default	blendZSpeedEnd			= 10.0f;
	private editable inlined var blendCurve	: CCurve;
	editable	var	blendZBasedOn			: ECameraBlendSpeedMode;	default	blendZBasedOn	= ECBSM_Time;
	
	
	private		var	blendZHeightMaxDif		: float;
	
	
	editable	var	blendZDistToForceStart			: float;	default	blendZDistToForceStart			= 1.5f;
	editable	var	blendZDistToForceEnd			: float;	default	blendZDistToForceEnd			= 2.5f;
	private		var	blendZDistToForceMaxCur			: float;
	
	
	editable	var	blendZSpeedTimeMin		: float;	default	blendZSpeedTimeMin		= 0.6f;
	editable	var	blendZSpeedTimeTotal	: float;	default	blendZSpeedTimeTotal	= 2.5f;
	private		var	blendZSpeedTimeCur		: float;	default	blendZSpeedTimeCur		= 0.0f;
	
	
	editable 	var	addOffset				: bool;		default	addOffset				= true;
	editable 	var	verticalDownOffsetMax	: float;	default	verticalDownOffsetMax	= 1.8f;
	editable 	var	verticalDownTimeMax		: float;	default	verticalDownTimeMax		= 2.2f;
	editable 	var	verticalDownTimeMin		: float;	default	verticalDownTimeMin		= 0.6f;
	
	
	private		var	isInInterior			: bool;
	editable	var	blendZInteriorTimeToFall: float;	default	blendZInteriorTimeToFall= 1.0f;
	editable	var	blendZSpeedInterior		: float;	default	blendZSpeedInterior		= 1.0f;
	editable	var	blendZSpeedInteriorFall	: float;	default	blendZSpeedInteriorFall	= 5.0f;
	
	
	editable 	var	heightTraceAlwaysAdjust	: bool;		default	heightTraceAlwaysAdjust	= true;
	editable 	var	heightTraceEnabled		: bool;		default	heightTraceEnabled		= true;
	editable 	var	heightTraceDownMax		: float;	default	heightTraceDownMax		= 2.5f;
	private		var	heightTraceTotalAdded	: float;
	private		var	heightTraceAccumulated	: float;
	private		var	heightTraceMax			: float;
	private		var	heightTraceTotal		: float;
	editable	var	heightTraceSpeed		: float;	default	heightTraceSpeed		= 3.0f;
	editable 	var	heightTraceSpeedDownMin	: float;	default	heightTraceSpeedDownMin	= 0.0f;
	editable	var	heightTraceSpeedDownMax	: float;	default	heightTraceSpeedDownMax	= 6.0f;
	private		var	heightTraceCollFlags	: array< name >;
	private		var	heightTraceCollFlagsInit: bool;		default	heightTraceCollFlagsInit= false;
	editable 	var	heightTraceDown			: bool;		default	heightTraceDown			= false;
	editable 	var	heightTraceDownTimeMin	: float;	default	heightTraceDownTimeMin	= 0.5f;
	editable 	var	heightTraceDownTimeMax	: float;	default	heightTraceDownTimeMax	= 1.2f;
	editable 	var	traceForwardExtraOffset	: float;	default	traceForwardExtraOffset	= 0.4f;

	private		var	heightTraceAdjusting	: bool;
	private		var	heightAdjustingTime		: float;
	
	
	editable	var boneFollowName			: name;
	private		var	boneFollow				: int;		default	boneFollow				= -1;
	editable	var	startFollowBoneTime		: float;	default	startFollowBoneTime		= 0.0f;
	editable	var	followBoneOnFall		: bool;		default	followBoneOnFall		= true;
	
	
	private		var falling					: bool;
	editable	var forceOnGround			: bool;		default	forceOnGround			= false;
	
	
	editable	var	debugLog				: bool;		default	debugLog				= false;
	private		var	zeroVector				: Vector;
	
	
	
	protected function ControllerUpdate( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{		
		
		timeDelta	*= theGame.GetTimeScale();
		
		if( useExactCamera )
		{
			UpdateExactCamera( currentPosition, currentVelocity, timeDelta );
		}
		else
		{
			UpdateOldCamera( currentPosition, currentVelocity, timeDelta );
		}		
	}
	
	
	private function UpdateExactCamera( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		var blendZCoef	: float;
		
		
		if( timeDelta <= 0.0f )
		{
			return;
		}
		
		
		if( blendZSpeedTimeCur	< 0.0f )
		{
			originalOffset			= currentPosition - GetFollowPos();
			originalHeight			= currentPosition.Z;
			heightTraceTotalAdded	= 0.0f;
			blendZSpeedTimeCur		= 0.0f;
			InitHeightTrace( currentPosition );
			zeroVector				= Vector( 0.0f, 0.0f, 0.0f );
			
			return;
		}
		
		if( blendZSpeedTimeCur >= startFollowBoneTime && boneFollow == -1 &&( followBoneOnFall || !falling ) )
		{
			
			if( IsNameValid( boneFollowName ) )
			{
				boneFollow	= thePlayer.GetBoneIndex( boneFollowName );
			}
			else
			{
				boneFollow	= -1;
			}
		}
		
		
		currentPosition 		= GetFollowPos() + originalOffset;
		
		
		
		if( !forceOnGround )
		{
			blendZCoef			= ComputeBlendZCoef( timeDelta, currentPosition.Z );
			if( blendZCoef > 0.0f )
			{
				originalHeight	= BlendF( originalHeight, currentPosition.Z, blendZCoef );
			}
		}	
		
		
		if( heightTraceEnabled )
		{
			originalHeight		+= ComputeTaceHeightAdded( currentPosition, timeDelta );
		}
		
		
		currentPosition.Z		= originalHeight;
		
		
		if( falling )
		{
			blendZSpeedTimeCur	+= timeDelta * 4.0f;
		}
		else
		{
			blendZSpeedTimeCur	+= timeDelta;
		}
	}
	
	
	private function UpdateOldCamera( out currentPosition : Vector, out currentVelocity : Vector, timeDelta : float )
	{
		var	blendXYCoef			: float;
		var	blendZCoef			: float;
		var targetPosition		: Vector;
		
		
		
		if( blendZSpeedTimeCur	< 0.0f )
		{			
			originalPosition	= currentPosition;
			originalHeight		= currentPosition.Z;
			originalOffset		= Vector( 0.0f, 0.0f, 0.0f );
			originalOffset		= currentPosition - ComputeTargetPos();
			blendZSpeedTimeCur	= 0.0f;
		}
		
		
		
		
		targetPosition	= ComputeTargetPos();
		
		
		if( blendXYSpeedWithTime )
		{
			blendXYCoef		= ClampF( blendZSpeedTimeCur, blendXYSpeedTimeStart, blendXYSpeedTimeEnd ); 
			blendXYCoef		= MapF( blendXYCoef, blendXYSpeedTimeStart, blendXYSpeedTimeEnd, blendXYSpeedMin, blendXYSpeedMax );
			blendXYCoef		= MinF( timeDelta * blendXYCoef, 1.0f ); 
		}
		else
		{
			
			if( blendXYSpeed <= 0.0f )
			{
				blendXYCoef	= 1.0f;
			}
			else
			{
				blendXYCoef	= MinF( timeDelta * blendXYSpeed, 1.0f ); 
			}
		} 
		
		blendZCoef	= ComputeBlendZCoef( timeDelta,targetPosition.Z );
		
		
		originalPosition.X	= BlendF( originalPosition.X, targetPosition.X, blendXYCoef );
		originalPosition.Y	= BlendF( originalPosition.Y, targetPosition.Y, blendXYCoef );
		
		if( !forceOnGround )
		{
			if( blendZCoef > 0.0f )
			{
				originalPosition.Z	= BlendF( originalPosition.Z, targetPosition.Z, blendZCoef );
			}
		}
		
		if( heightTraceEnabled )
		{
			if( blendZSpeedTimeCur	< 0.0f )
			{
				InitHeightTrace( targetPosition );
			}
			
			originalPosition.Z	+= ComputeTaceHeightAdded( targetPosition, timeDelta ); 
		}
		
		
		
		if( falling )
		{
			blendZSpeedTimeCur	+= timeDelta * 4.0f;
		}
		else
		{
			blendZSpeedTimeCur	+= timeDelta;
		}		
		
		
		currentPosition = originalPosition;
		currentVelocity	= Vector( 0.0f, 0.0f, 0.0f );
		
		
		if( debugLog && timeDelta > 0.0f )
		{
			LogChannel( 'CameraJump', "currentPosition.Z: " + currentPosition.Z );
		}
	}
	
	
	protected function ControllerActivate( currentOffset : float )
	{		
		var auxVector		: Vector;
		var jumpType		: EJumpType;
		
		blendZSpeedTimeCur	= -10.0f;
		blendZHeightMaxDif	= 0.0f;
		falling				= false;
		
		
		if( thePlayer.substateManager.GetStateCur() == 'Jump' )
		{
			jumpType	= thePlayer.substateManager.m_SharedDataO.m_JumpTypeE;
			if( jumpType == EJT_Fall || jumpType == EJT_Vault || jumpType == EJT_KnockBack )
			{
				falling = true;
			}
		}
		
		
		
		
		isInInterior	= !thePlayer.IsActionAllowed( EIAB_RunAndSprint ) || !thePlayer.IsActionAllowed( EIAB_Sprint );
		
		
		
		boneFollow	= -1;
		
		
		heightTraceAccumulated	= 0.0f;
		heightTraceTotal		= 0.0f;
		blendZDistToForceMaxCur	= 0.0f;
		
		if( debugLog )
		{
			LogChannel( 'CameraJump', "Started CCameraPivotPositionControllerJump" );
		}
	}
	
	
	private function GetFollowPos() : Vector
	{
		
		if( boneFollow >= 0 )
		{
			return GetBoneToFollowPosition();
		}
		else
		{
			return thePlayer.GetWorldPosition();
		}
	}
	
	
	private function GetBoneToFollowPosition() : Vector
	{
		var position : Vector;
		
		position	= thePlayer.HACK_ForceGetBonePosition( boneFollow );
		
		
		if( position == zeroVector )
		{
			position	= thePlayer.GetWorldPosition();
		}
		
		return position;
	}
	
	
	private function ComputeTargetPos() : Vector
	{	
		var offset 		: Vector;
		var position	: Vector;
		
		
		if( boneFollow >= 0 )
		{
			position	= GetBoneToFollowPosition();
		}
		else
		{
			position	= thePlayer.GetWorldPosition();
		}
		
		offset		= ComputeOffset();
		
		position	+=  offset + originalOffset;
		
		return position;
	}
	
	
	private function ComputeOffset() : Vector
	{
		var verticalDisp	: float;
		
		
		if( addOffset )
		{
			verticalDisp	= ClampF( blendZSpeedTimeCur, verticalDownTimeMin, verticalDownTimeMax );
			verticalDisp	= MapF(verticalDisp, verticalDownTimeMin, verticalDownTimeMax , 0.0f, 1.0f );
			verticalDisp	*= verticalDownOffsetMax;
			return	Vector( 0, 0, zOffset  -  verticalDisp );
		}
		
		return	Vector( 0, 0, zOffset );
	}
	
	
	private function ComputeBlendZCoef( timeDelta : float, height : float ) : float
	{
		var blendZSpeed		: float;
		var distanceInZ		: float;
		
		
		if( timeDelta <= 0.0f )
		{
			return 0.0f;
		}
		
		
		if( isInInterior )
		{
			if( blendZSpeedTimeCur < blendZInteriorTimeToFall )
			{
				blendZSpeed	= blendZSpeedInterior;
			}
			else
			{
				blendZSpeed	= blendZSpeedInteriorFall;
			}
		}
		else if( blendZBasedOn == ECBSM_Distance ) 
		{
			distanceInZ	= AbsF( height - originalHeight );
			if( blendZDistToForceMaxCur < distanceInZ )
			{
				blendZDistToForceMaxCur	= distanceInZ;
			}
			if( blendZDistToForceMaxCur >= blendZDistToForceStart )
			{
				blendZDistToForceMaxCur	= MinF( blendZDistToForceMaxCur, blendZDistToForceEnd );
				blendZSpeed				= MapF( blendZDistToForceMaxCur, blendZDistToForceStart, blendZDistToForceEnd, blendZSpeedStart, blendZSpeedEnd );
			}
		}
		else if( blendZBasedOn == ECBSM_Height ) 
		{
			distanceInZ	= originalHeight - height;
			if( blendZHeightMaxDif < distanceInZ )
			{
				blendZHeightMaxDif	= distanceInZ;
			}
			if( blendZHeightMaxDif	<= blendZDistToForceStart )
			{
				return 0.0f;
			}
			else
			{			
				blendZSpeed		= ClampF( blendZHeightMaxDif, blendZDistToForceStart, blendZDistToForceEnd );
				blendZSpeed		= MapF( blendZSpeed, blendZDistToForceStart, blendZDistToForceEnd, blendZSpeedStart, blendZSpeedEnd );
			}
		}	
		else if( blendZBasedOn == ECBSM_Time )
		{
			if( blendCurve ) 
			{
				if( blendZSpeedTimeCur < blendZSpeedTimeMin )
				{
					blendZSpeed	= 0.0f;
				}
				else
				{
					blendZSpeed	= MinF( blendZSpeedTimeCur, blendZSpeedTimeTotal );
					blendZSpeed	= MapF( blendZSpeed, blendZSpeedTimeMin, blendZSpeedTimeTotal , 0.0f, 1.0f );
					blendZSpeed	= blendCurve.GetValue( blendZSpeed );
					blendZSpeed	= MapF( blendZSpeed, 0.0f, 1.0f, blendZSpeedStart, blendZSpeedEnd );
				}
			}
			else 
			{
				if( blendZSpeedTimeCur < blendZSpeedTimeMin )
				{
					blendZSpeed	= 0.0f;
				}
				else
				{
					blendZSpeed	= MapF( MinF( blendZSpeedTimeCur, blendZSpeedTimeTotal ), blendZSpeedTimeMin, blendZSpeedTimeTotal , blendZSpeedStart, blendZSpeedEnd );
				}
			}
		}
		
		return MinF( timeDelta * blendZSpeed , 1.0f );
	}
	
	
	private function InitHeightTrace( position : Vector )
	{
		var heightNow	: float;
		
		
		if( !heightTraceCollFlagsInit )
		{
			heightTraceCollFlags.PushBack( 'Terrain' );
			heightTraceCollFlags.PushBack( 'Static' );
			heightTraceCollFlagsInit	= true;
		}
		
		if( ComputeGroundHeight( position, heightNow ) )
		{
			heightTraceMax	= heightNow;
		}
		else
		{
			heightTraceMax	= position.Z;
		}
		
		heightTraceAdjusting	= false;
	}	
	
	
	private function ComputeTaceHeightAdded( position : Vector, deltaTime : float ) : float
	{	
		var groundHeight	: float;
		var addedHeight		: float;
		var result			: bool;
		var traceSpeed		: float;
		
		
		result	= ComputeGroundHeight( position, groundHeight );
		if( result )
		{	
			
			if( heightTraceAlwaysAdjust || groundHeight > heightTraceMax || ( heightTraceDown && blendZSpeedTimeCur > heightTraceDownTimeMin ) )
			{
				heightTraceAccumulated	+= groundHeight - heightTraceMax;
				heightTraceMax 			= groundHeight;
			}
		}
		
		if( heightTraceAccumulated > 0.0f || !heightTraceDown )
		{
			traceSpeed	= heightTraceSpeed * heightTraceAccumulated;
		}
		else
		{
			traceSpeed	= ClampF( blendZSpeedTimeCur, heightTraceDownTimeMin, heightTraceDownTimeMax );
			traceSpeed	= MapF( heightTraceDownTimeMin, heightTraceDownTimeMax, heightTraceSpeedDownMin, heightTraceSpeedDownMax, traceSpeed );
		}
		
		
		addedHeight				= SignF( heightTraceAccumulated ) * MinF( AbsF( heightTraceAccumulated ), MinF( deltaTime * traceSpeed, 1.0f ) );
		heightTraceAccumulated	-= addedHeight;
		heightTraceTotal		+= addedHeight;
		
		if( debugLog && deltaTime > 0.0f )
		{
			LogChannel( 'CameraJump', "groundHeight " + groundHeight + ", heightTraceMax " + heightTraceMax + ", heightTraceAccumulated " + heightTraceAccumulated + ", addedHeight " + addedHeight + ", heightTraceTotal " + heightTraceTotal );
		}
		
		return addedHeight;
	}
	
	
	private function ComputeTaceHeightAddedState( position : Vector, deltaTime : float ) : float
	{	
		var groundHeight	: float;
		var addedHeight		: float;
		var result			: bool;
		var traceSpeed		: float;
		
		
		result	= ComputeGroundHeight( position, groundHeight );
		if( result )
		{	
			heightTraceAccumulated	= groundHeight - heightTraceMax;
		}
		
		
		if( !heightTraceAdjusting )
		{
			if( heightTraceAccumulated != 0.0f ) 
			{
				heightTraceAdjusting	= true;
				heightAdjustingTime		= 0.0f;
			}
		}
		
		
		if( heightTraceAdjusting )
		{
			addedHeight			= deltaTime * MinF( heightAdjustingTime, 3.0f ) * SignF( heightTraceAccumulated ) * 100.0f;
			addedHeight			= ClampF( addedHeight, -AbsF( heightTraceAccumulated ), AbsF( heightTraceAccumulated ) );
			heightTraceMax		-= addedHeight;
			
			heightAdjustingTime	+= deltaTime;
			
			return addedHeight;
		}
		
		
		return 0.0f;
	}
	
	
	private function ComputeGroundHeight( position : Vector, out height : float ) : bool
	{
		var world 			: CWorld;
		var posOrigin		: Vector;
		var posEnd			: Vector;
		var posCollided		: Vector;
		var normalCollided	: Vector;
		var res				: bool;
		
		
		position	+= thePlayer.GetWorldForward() * traceForwardExtraOffset;
		
		
		height		= position.Z - heightTraceDownMax;
		
		
		world		= theGame.GetWorld();
		if( !world )
		{
			return false;
		}
		
		
		posOrigin	= position;
		posOrigin.Z	+= 0.2f;
		posEnd		= position;
		posEnd.Z	-= heightTraceDownMax;
		
		
		res = world.StaticTrace( posOrigin, posEnd, posCollided, normalCollided, heightTraceCollFlags );
		
		if( res )
		{
			height	= posCollided.Z;
			
			
			
			return true;
		}
		
		return false;
	}
}





class CCameraRotationControllerJump extends ICustomCameraScriptedPivotRotationController
{
	
	private	editable 			var	pitchTotal		: float;	default	pitchTotal		= -50.0f;
	private						var	pitchBase		: float;
	
	
	editable					var	yawAcceleration	: float;	default	yawAcceleration	= 1.0f;
	editable					var yawMaxSpeed		: float;	default	yawMaxSpeed		= 2.0f;
	
	
	private						var	timeCur			: float;
	private	editable 			var	timeStart		: float;	default	timeStart		= 0.5f;
	private	editable 			var	timeComplete	: float;	default	timeComplete	= 1.7f;
	
	
	private editable			var	blendSpeed		: float;	default	blendSpeed		= 5.0f;
	private editable inlined	var pitchCurve		: CCurve;
	
	
	
	
	protected function ControllerUpdate( out currentRotation : EulerAngles, out currentVelocity : EulerAngles, timeDelta : float )
	{
		var pitchTarget	: float;
		var coef		: float;
		
		
		if( timeCur <= 0.0f )
		{
			pitchBase		= currentRotation.Pitch;
		}
		
		if( timeCur >= timeStart )
		{
			coef				= ClampF( timeCur, timeStart, timeComplete );
			if( pitchCurve )
			{
				coef			= MapF( coef, timeStart, timeComplete, 0.0f, 1.0f );
				coef			= pitchCurve.GetValue( coef );
				pitchTarget		= pitchBase + coef * pitchTotal;
			}
			else
			{
				coef			= MapF( coef, timeStart, timeComplete, pitchBase, pitchTotal );
				pitchTarget		= coef;
			}
			
			currentRotation.Pitch	= BlendF( currentRotation.Pitch, pitchTarget, blendSpeed * timeDelta );
		}
		
		
		currentRotation.Yaw		-= yawMaxSpeed * theInput.GetActionValue( 'GI_AxisRightX' );
		
		timeCur	+= timeDelta;
	}
	
	
	protected function ControllerActivate( currentRotation : EulerAngles )
	{		
		timeCur		= 0.0f;
	}
}