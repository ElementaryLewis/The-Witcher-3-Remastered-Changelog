/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SBehaviorComboAttack
{
	import var level, type : int;
	import var attackTime, parryTime : float;
	import var attackAnimation, parryAnimation : name;
	
	import var attackHitTime, parryHitTime : float;
	import var attackHitLevel, parryHitLevel : float;
	
	import var direction : EAttackDirection;
	import var distance : EAttackDistance;
	
	import var attackHitTime1, parryHitTime1 : float;
	import var attackHitLevel1, parryHitLevel1 : float;
	
	import var attackHitTime2, parryHitTime2 : float;
	import var attackHitLevel2, parryHitLevel2 : float;
	
	import var attackHitTime3, parryHitTime3 : float;
	import var attackHitLevel3, parryHitLevel3 : float;
};

enum EComboAttackResponse
{
	CAR_HitFront,
	CAR_HitBack,
	CAR_ParryFront,
	CAR_ParryBack,
};


