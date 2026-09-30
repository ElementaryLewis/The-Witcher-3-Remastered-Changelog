/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SComboAttackCallbackInfo
{
	import var outDirection : EAttackDirection;
	import var outDistance : EAttackDistance;
	
	import var outRotateToEnemyAngle : float;
	import var outSlideToPosition : Vector;
	import var outShouldTranslate : bool;
	import var outShouldRotate : bool;
	
	import var outAttackType : EComboAttackType;
	import var outLeftString : bool;

	import var inAspectName : name;
	import var inGlobalAttackCounter : int;
	import var inStringAttackCounter : int;
	import var prevDirAttack : bool;
	import var inAttackId : int;
}

import class CComboPlayer extends CObject
{
	import final function Build( definition: CComboDefinition, entity : CEntity ) : bool;
	
	import final function Init() : bool;
	import final function Deinit();
	
	import final function Update( timeDelta : float ) : bool;
	
	import final function Pause();
	import final function Unpause();
	import final function IsPaused() : bool;
	
	import final function PauseSlider();
	import final function UnpauseSlider();
	import final function IsSliderPaused() : bool;
	
	import final function PlayAttack( comboAspect : name ) : bool;
	import final function StopAttack();

	
	import final function PlayHit() : bool;
	
	import final function SetDurationBlend( timeDelta : float );
	
	import final function UpdateTarget( attackId : int, pos : Vector, rot : float, optional deltaRotationPolicy : bool, optional useRotationScaling : bool );
}
