/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsAttacking extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;	
	
	final function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		
		return combatDataStorage.GetIsAttacking();
	}
	
	final function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
};



class BTCondIsAttackingDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsAttacking';
};