/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsChangingWeapon extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.IsProcessingItems();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class BTCondIsChangingWeaponDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsChangingWeapon';
}




class BTCondDoesChangingWeaponRequiresIdle extends IBehTreeTask
{
	protected var combatDataStorage : CHumanAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		return combatDataStorage.DoesProcessingRequiresIdle();
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class BTCondDoesChangingWeaponRequiresIdleDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDoesChangingWeaponRequiresIdle';
}