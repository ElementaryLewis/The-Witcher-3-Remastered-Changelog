/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct STargetingInfo
{
	import var source 				: CActor;
	import var targetEntity 		: CGameplayEntity;
	import var canBeTargetedCheck	: bool;
	import var coneCheck 			: bool;
	import var coneHalfAngleCos		: float;
	import var coneDist				: float;
	import var coneHeadingVector	: Vector; 
	import var distCheck			: bool;
	import var invisibleCheck		: bool;
	import var navMeshCheck			: bool; 
	import var inFrameCheck 		: bool; 
	import var frameScaleX 			: float; 
	import var frameScaleY 			: float; 
	import var knockDownCheck 		: bool; 
	import var knockDownCheckDist 	: float; 
	import var rsHeadingCheck 		: bool;
	import var rsHeadingLimitCos	: float;
}



import struct STargetSelectionData
{
	import var sourcePosition		: Vector;
	import var headingVector		: Vector;
	import var closeDistance		: float;
	import var softLockDistance		: float;
};



import struct SR4PlayerTargetingConsts
{
	import var softLockDistance		: float;
	import var softLockFrameSize	: float;
}



import struct SR4PlayerTargetingPrecalcs
{
	import var playerPosition		: Vector;
	import var playerHeading		: float;
	import var playerHeadingVector	: Vector;
	import var playerRadius			: float;
	import var cameraPosition		: Vector;
	import var cameraDirection		: Vector;
	import var cameraHeading		: float;
	import var cameraHeadingVector	: Vector;	
}



import struct SR4PlayerTargetingIn
{
	import var canFindTarget 					: bool;
	import var playerHasBlockingBuffs 			: bool;
	import var isHardLockedToTarget				: bool;
	import var isActorLockedToTarget 			: bool;
	import var isCameraLockedToTarget 			: bool;
	import var actionCheck 						: bool;
	import var actionInput						: bool;
	import var isInCombatAction					: bool;
	import var isLAxisReleased 					: bool;
	import var isLAxisReleasedAfterCounter 		: bool;
	import var isLAxisReleasedAfterCounterNoCA 	: bool;
	import var lastAxisInputIsMovement 			: bool;
	import var isAiming 						: bool;
	import var isSwimming 						: bool;
	import var isDiving 						: bool;
	import var isThreatened 					: bool;
	import var isCombatMusicEnabled 			: bool;
	import var isPcModeEnabled		 			: bool;
	import var shouldUsePcModeTargeting			: bool;
	import var isInParryOrCounter				: bool;
	import var bufferActionType 				: EBufferActionType;
	import var orientationTarget 				: EOrientationTarget;
	import var coneDist 						: float;
	import var findMoveTargetDist 				: float;
	import var cachedRawPlayerHeading 			: float;
	import var combatActionHeading 				: float;
	import var rawPlayerHeadingVector 			: Vector;
	import var lookAtDirection 					: Vector;
	import var moveTarget 						: CActor;
	import var aimingTarget 					: CActor;
	import var displayTarget 					: CActor;
	import var finishableEnemies 				: array< CActor >;
	import var hostileEnemies 					: array< CActor >;
	import var defaultSelectionWeights 			: STargetSelectionWeights;
}



import struct SR4PlayerTargetingOut
{
	import var target						: CActor;
	import var result						: bool;
	import var confirmNewTarget				: bool;
	import var forceDisableUpdatePosition	: bool;	
}



import class CR4PlayerTargeting extends IScriptable
{
	import final function SetConsts( out consts : SR4PlayerTargetingConsts );
	import final function BeginFindTarget( out inValues : SR4PlayerTargetingIn );
	import final function EndFindTarget( out outValues : SR4PlayerTargetingOut );
	import final function FindTarget();
	import final function WasVisibleInScaledFrame( entity : CEntity, frameSizeX : float, frameSizeY : float ) : bool;
}



exec function UseNativeTargeting( use : bool )
{
	thePlayer.SetUseNativeTargeting( use );
}