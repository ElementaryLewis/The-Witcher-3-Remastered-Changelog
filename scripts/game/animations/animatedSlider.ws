/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import function ResetAnimatedComponentSyncSettings( out settings : SAnimatedComponentSyncSettings );

import struct SAnimatedComponentSyncSettings
{
	import var instanceName			: name;
	import var syncAllInstances		: bool;
	import var syncEngineValueSpeed	: bool;
}



import function ResetAnimatedSlideSettings( out settings : SAnimatedSlideSettings );

import struct SAnimatedSlideSettings
{
	import var animation : name;
	import var slotName : name;
	import var blendIn : float;
	import var blendOut : float;
	import var useGameTimeScale : bool;
	import var useRotationDeltaPolicy : bool;
}



import function ResetActionMatchToSettings( out settings : SActionMatchToSettings );

import struct SActionMatchToSettings
{
	import var animation : name;
	import var slotName : name;
	import var blendIn : float;
	import var blendOut : float;
	import var useGameTimeScale : bool;
	import var useRotationDeltaPolicy : bool;
}

import function SetActionMatchToTarget_StaticPoint( out target : SActionMatchToTarget, point : Vector, yaw : float, position : bool, rotation : bool );

import struct SActionMatchToTarget {}



import function ResetAnimatedComponentSlotAnimationSettings( out settings : SAnimatedComponentSlotAnimationSettings );

import struct SAnimatedComponentSlotAnimationSettings
{
	import var blendIn : float;
	import var blendOut : float;
}





import class CActionMoveAnimationProxy extends CObject
{
	import function IsInitialized() : bool;
	import function IsValid() : bool;
	import function IsFinished() : bool;
	import function WillBeFinished( time : float ) : bool;
}