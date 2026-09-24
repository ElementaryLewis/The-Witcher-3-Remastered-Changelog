/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsInImportantAnim extends IBehTreeTask
{
	protected var combatDataStorage : CBaseAICombatStorage;	
	
	final function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		
		return combatDataStorage.GetIsInImportantAnim();
	}
	
	final function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
};



class BTCondIsInImportantAnimDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTCondIsInImportantAnim';
};