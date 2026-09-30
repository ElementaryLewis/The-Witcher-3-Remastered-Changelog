/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SAnimationTrajectoryPlayerInput
{
	import var localToWorld : Matrix;
	import var pointWS 		: Vector;
	import var directionWS	: Vector;
	import var tagId 		: CName;
	import var selectorType : EAnimationTrajectorySelectorType;
	import var proxySyncType : EActionMoveAnimationSyncType;
	import var proxy		: CActionMoveAnimationProxy;
}

import struct SAnimationTrajectoryPlayerToken
{
	import var isValid 		: bool;
	import var pointWS 		: Vector;
	import var syncPointMS 	: Vector;
	import var timeFactor 	: float;
	import var syncPointDuration : float;
	import var blendIn 		: float;
	import var blendOut 	: float;
	import var duration		: float;
	import var syncTime		: float;
}

import class AnimationTrajectoryPlayerScriptWrapper extends CObject
{
	import public final function Init( entity : CEntity, optional slotName : name );
	import public final function Deinit();
	
	import public final function SelectAnimation( input : SAnimationTrajectoryPlayerInput ) : SAnimationTrajectoryPlayerToken;
	import public final function PlayAnimation( animationToken : SAnimationTrajectoryPlayerToken ) : bool;
	
	import public final function Tick( dt : float );
	
	import public final function UpdateCurrentPoint( pointWS : Vector );
	import public final function UpdateCurrentPointM( l2w : Matrix, pointWS : Vector );
	
	import public final function GetTime() : float;
	
	import public final function IsPlayingAnimation() : bool;
	import public final function IsBeforeSyncTime() : bool;
	
	import public final latent function WaitForSyncTime() : bool;
	import public final latent function WaitForFinish() : bool;
}