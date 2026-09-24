/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsPlayerInSpecialAttack extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		if( thePlayer.IsInCombatAction_SpecialAttack() )
		{
			return true;
		}
		
		return false;
	}
}

class BTCondIsPlayerInSpecialAttackDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsPlayerInSpecialAttack';
}