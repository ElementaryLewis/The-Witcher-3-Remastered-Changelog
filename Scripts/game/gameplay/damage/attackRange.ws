/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class CAIAttackRange
{
	import var rangeMax				: float;
	import var height				: float;
	import var angleOffset			: float;
	import var position				: Vector;
	import var checkLineOfSight		: bool;
	import var lineOfSightHeight	: float;
	import var useHeadOrientation	: bool;	

	import final function Test( sourceEntity : CGameplayEntity, targetEntity : CGameplayEntity ) : bool;
	import final function GatherEntities( sourceEntity : CGameplayEntity, out entities : array< CGameplayEntity > );
}
