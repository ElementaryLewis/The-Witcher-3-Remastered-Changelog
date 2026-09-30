/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondPlayerHasSwordInHand extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		var currentWeapon : EPlayerWeapon;
		
		currentWeapon = thePlayer.GetCurrentMeleeWeaponType();
		
		return currentWeapon == PW_Steel || currentWeapon == PW_Silver;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
}

class CBTCondPlayerHasSwordInHandDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTCondPlayerHasSwordInHand';
}
