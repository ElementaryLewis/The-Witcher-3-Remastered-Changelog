/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class FocusModeCameraShotHelper
{
	var headingOffset : float;

	var e : CNewNPC;
	var p : CPlayer;

	var initShot_yaw : float;
	var initShot_yawAlt : float;
	var initShot_yawA, initShot_yawB, initShot_yawC, initShot_yawD : float;
	var initShot_number : int;
	var initShot_isPlayerMainChar : bool;
	var initShot_mainCharacter : CActor;
	var initShot_secCharacter : CActor;
	var initShot_cameraSecSide : bool;

	var ssShot_yaw : float;
	var ssShot_pitch : float;
	var ssShot_distance : float;
	var ssShot_pivot : Vector;
	
	var blendShot_started : bool;
	var blendShot_duration : float;
	var blendShot_timer : float;
	var	blendShot_progress : float;
	
	default headingOffset = 45.f;
	
	public final function Init( _e : CNewNPC, _p : CPlayer )
	{
		e = _e;
		p = _p;
		
		blendShot_started = false;
	}
	
	public final function Deinit()
	{
		e = NULL;
		p = NULL;
		
		blendShot_started = false;
	}
	
	public final function FindInitAndSSShotParams( currHeading : float )
	{
		FindInitShotParams( currHeading );
		FindSSShotParams( CalcPivotPosition() );
	}
	
	public final function FindInitShotParams( currHeading : float )
	{
		FindInitShotParamsVec( currHeading, e.GetWorldPosition(), p.GetWorldPosition() );
	}
	
	public final function FindInitShotParamsVec( currHeading : float, ePos, pPos : Vector )
	{
		var dirToEnemy : Vector;
		var pointA, pointB : Vector;
		var pScreenAA, pScreenAB, pScreenH : float;
		var pScreenBA, pScreenBB : float;
		var playerHeading, headingA, headingB, headingC, headingD, heading, heading2 : float;
		var distHeadingBest, distHeadingA, distHeadingB, distHeadingC, distHeadingD : float;
		var playerIsMainCharacter, cameraSecSide : bool;
		var cameraChar : CActor;
		
		dirToEnemy = VecNormalize( ePos - pPos );
		
		playerHeading = VecHeading( dirToEnemy );
		
		headingA = playerHeading + headingOffset;
		headingB = playerHeading - headingOffset;
		headingC = playerHeading + 180.f - headingOffset;
		headingD = playerHeading - 180.f + headingOffset;
		
		currHeading = AngleNormalize180( currHeading );
		
		headingA = AngleNormalize180( headingA );
		headingB = AngleNormalize180( headingB );
		headingC = AngleNormalize180( headingC );
		headingD = AngleNormalize180( headingD );
		
		distHeadingA = AbsF( AngleDistance( headingA, currHeading ) );
		distHeadingB = AbsF( AngleDistance( headingB, currHeading ) );
		distHeadingC = AbsF( AngleDistance( headingC, currHeading ) );
		distHeadingD = AbsF( AngleDistance( headingD, currHeading ) );
		
		heading = headingA;
		heading2 = headingC;
		distHeadingBest = distHeadingA;
		playerIsMainCharacter = true;
		cameraSecSide = true;
		initShot_number = 1;
		
		if ( distHeadingB < distHeadingBest )
		{
			heading = headingB;
			heading2 = headingD;
			distHeadingBest = distHeadingB;
			playerIsMainCharacter = true;
			cameraSecSide = false;
			initShot_number = 2;
			
		}
		if ( distHeadingC < distHeadingBest )
		{
			heading = headingC;
			heading2 = headingA;
			distHeadingBest = distHeadingC;
			playerIsMainCharacter = false;
			cameraSecSide = false;
			initShot_number = 3;
		}
		if ( distHeadingD < distHeadingBest )
		{
			heading = headingD;
			heading2 = headingB;
			distHeadingBest = distHeadingD;
			playerIsMainCharacter = false;
			cameraSecSide = true;
			initShot_number = 4;
		}
		
		
		
		if ( playerIsMainCharacter )
		{
			initShot_mainCharacter = p;
			initShot_secCharacter = e;
		}
		else
		{
			initShot_mainCharacter = e;
			initShot_secCharacter = p;
		}
		
		initShot_yaw = heading;
		initShot_yawAlt = heading2;
		initShot_isPlayerMainChar = playerIsMainCharacter;
		initShot_cameraSecSide = cameraSecSide;
		
		initShot_yawA = headingA;
		initShot_yawB = headingB;
		initShot_yawC = headingC;
		initShot_yawD = headingD;
	}
	
	public final function FindSSShotParams( initPivot : Vector )
	{
		InternalFindSSShotParams( 0.f, initShot_mainCharacter, initShot_secCharacter, initShot_cameraSecSide, initPivot, initShot_yaw, -15.f, 1.f, true );
	}
	
	public final function RefreshSSShotParams( blendingProgress : float )
	{
		InternalFindSSShotParams( blendingProgress, initShot_mainCharacter, initShot_secCharacter, initShot_cameraSecSide, ssShot_pivot, ssShot_yaw, ssShot_pitch, ssShot_distance, false );
	}
	
	private final function InternalFindSSShotParams( blending : float, mainCh, secChar : CActor, camSide : bool, initPivot : Vector, initYaw, initPitch : float, initDistance : float, useCurrDistance : bool )
	{
		InternalFindSSShotParamsVec( initShot_number, blending, mainCh.GetWorldPosition(), secChar.GetWorldPosition(), camSide, initPivot, initYaw, initPitch, initDistance, useCurrDistance );
	}
	
	private final function InternalFindSSShotParamsVec( shotNum : int, blending : float, mainCh, secChar : Vector, camSide : bool, initPivot : Vector, initYaw, initPitch : float, initDistance : float, useCurrDistance : bool )
	{
		var pointA, pointB, pointC : Vector;
		
		var ifactorA, ifactorC, ofactorA, ofactorC : Vector;
		var issfactorA, issfactorC, ossfactorA, ossfactorC : Vector;
		var factorSign, blendHalfIn, blendHalfOut : float;
		
		
		
		
		
		
		
		
		
		
		if ( camSide )
		{
			factorSign = 1.f;
		}
		else
		{
			factorSign = -1.f;
		}
		
		blendHalfOut = blending * 2.f - 1.f;
		blendHalfIn = 1.f - blending * 2.f;
		
		pointA = mainCh;
		pointB = pointA + Vector( 0.f, 0.f, 1.8f );
		pointC = secChar + Vector( 0.f, 0.f, 1.8f );
		
		
		
		ifactorA.X = 0.4f;
		ifactorA.Y = 0.8f;
		ifactorC.X = 0.5f;
		ifactorC.Y = 0.5f;
		
		
		if ( shotNum > 0 )
		{
			if ( shotNum == 1 || shotNum == 2 )
			{
				ifactorA.X = 0.4f;
				ifactorA.Y = 0.8f;
				ifactorC.X = 0.1f;
				ifactorC.Y = 0.1f;
			}
			else if ( shotNum == 3 || shotNum == 4 )
			{
				ifactorA.X = 0.2f;
				ifactorA.Y = 0.8f;
				ifactorC.X = 0.1f;
				ifactorC.Y = 0.1f;
			}
		}
		
		
		if ( true )
		{
			if ( shotNum == 1 )
			{
				ifactorA.X = 0.4f;
				ifactorA.Y = 0.55f;
				ifactorC.X = 0.5f;
				
				
				
				
			}
			else if ( shotNum == 2 )
			{
				ifactorA.X = 0.4f;
				ifactorA.Y = 0.55f;
				ifactorC.X = 0.5f;
				
			}
			else if ( shotNum == 3 )
			{
				ifactorA.X = 0.5f;
				ifactorA.Y = 0.6f;
				ifactorC.X = 0.5f;
				
			}
			else if ( shotNum == 4 )
			{
				ifactorA.X = 0.5f;
				ifactorA.Y = 0.6f;
				ifactorC.X = 0.5f;
				
			}				
			
		}
		
		ofactorA.X = LerpF( blending, ifactorA.X, ifactorC.X );
		ofactorA.Y = LerpF( blending, ifactorA.Y, ifactorC.Y );
		ofactorC.X = LerpF( 1.f-blending, ifactorA.X, ifactorC.X );
		ofactorC.Y = LerpF( 1.f-blending, ifactorA.Y, ifactorC.Y );
		
		
		
		issfactorA.X = 1.f;
		issfactorA.Y = 0.6f;
		issfactorC.X = 1.f;
		issfactorC.Y = 0.f;
		
		if ( blending < 0.5f )
		{
			issfactorA.Y = blendHalfIn * 0.6f;
			issfactorC.Y = 0.f;
			
			
		}
		else
		{
			issfactorA.Y = 0.f;
			issfactorC.Y = blendHalfOut * 0.6f;
			
			
		}
		
		ossfactorA.X = LerpF( blending, issfactorA.X, issfactorC.X );
		ossfactorA.Y = LerpF( blending, issfactorA.Y, issfactorC.Y );
		ossfactorC.X = LerpF( 1.f-blending, issfactorA.X, issfactorC.X );
		ossfactorC.Y = LerpF( 1.f-blending, issfactorA.Y, issfactorC.Y );
		
		
		
		
		
		
		
	}
	
	public final function CalcPivotPosition() : Vector
	{
		return InternalCalcPivotPosition( initShot_mainCharacter, initShot_secCharacter );
	}
	
	private final function InternalCalcPivotPosition( mainCh, secChar : CActor ) : Vector
	{
		var mainPos, secPos : Vector;
		
		mainPos = mainCh.GetWorldPosition();
		secPos = secChar.GetWorldPosition();
		
		return InternalCalcPivotPositionVec( mainPos, secPos );
	}
	
	private final function InternalCalcPivotPositionVec( mainPos, secPos : Vector ) : Vector
	{
		var position, dir : Vector;
		var dist2D : float;
		
		dist2D = 0.4f * VecDistance2D( secPos, mainPos );
		dir = VecNormalize( secPos - mainPos );
		
		position = mainPos + dir * dist2D + Vector( 0.f, 0.f, 0.8f );
		
		return position;
	}
	
	public final function FindLastSSShot( currHeading : float, destPoint : Vector )
	{
		var pivot : Vector;
		var prevMain, prevSec, currMain, currSec : Vector;
		var camSide : bool;
		var yaw : float;
		
		FindInitShotParamsVec( currHeading, e.GetWorldPosition(), destPoint );
		
		prevMain = initShot_mainCharacter.GetWorldPosition();
		prevSec = initShot_secCharacter.GetWorldPosition();
		
		pivot = InternalCalcPivotPositionVec( e.GetWorldPosition(), destPoint );
		yaw = initShot_yaw;
		
		if ( initShot_number == 1 )
		{
			
			currMain = e.GetWorldPosition();
			currSec = destPoint;
			camSide = false;
			yaw = initShot_yawC;
		}
		else if ( initShot_number == 2 )
		{
			
			currMain = e.GetWorldPosition();
			currSec = destPoint;
			camSide = true;
			yaw = initShot_yawD;
		}
		else if ( initShot_number == 3 )
		{
			
			currMain = destPoint;
			currSec = e.GetWorldPosition();
			camSide = true;
			yaw = initShot_yawA;
		}
		else if ( initShot_number == 4 )
		{
			
			currMain = destPoint;
			currSec = e.GetWorldPosition();
			camSide = false;
			yaw = initShot_yawB;
		}
		
		InternalFindSSShotParamsVec( initShot_number, 0.f, currMain, currSec, camSide, pivot, yaw, -15.f, 1.f, false );
	}
	
	public final function StartBlendingSSShot( currHeading : float, duration : float )
	{
		if ( duration > 0.f )
		{
			FindInitAndSSShotParams( currHeading );
			
			blendShot_started = true;
			blendShot_duration = duration;
			blendShot_timer = 0.f;
		}
	}
	
	public final function UpdateBlendingSSShot()
	{
		
		
		if ( blendShot_started )
		{
			blendShot_timer += theTimer.timeDeltaUnscaled;
			
			if ( blendShot_timer > blendShot_duration )
			{
				blendShot_timer = blendShot_duration;
			}
			
			blendShot_progress = blendShot_timer / blendShot_duration;
			
			
			
			
			
			
			RefreshSSShotParams( blendShot_progress );
			
			LogChannel( 'FM_CAM', "-------------------------------" );
			LogChannel( 'FM_CAM', "Progress: " + blendShot_progress );
			LogChannel( 'FM_CAM', "Distance: " + ssShot_distance );
			LogChannel( 'FM_CAM', "Yaw     : " + ssShot_yaw );
			LogChannel( 'FM_CAM', "Pitch   : " + ssShot_pitch );
			LogChannel( 'FM_CAM', "Pivot   : " + ssShot_pivot.X + ";" + ssShot_pivot.Y + ";" + ssShot_pivot.Z );
		}
	}
}