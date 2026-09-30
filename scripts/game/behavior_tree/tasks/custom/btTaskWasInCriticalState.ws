/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskWasInCriticalState extends IBehTreeTask
{
	var timeDifference : float;
	var maxTimeDifference : float;
	var criticalState : ECriticalStateType;
	var timeOfLastCSDeactivation : float;

	protected var combatDataStorage : CBaseAICombatStorage;
	
	function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		timeOfLastCSDeactivation = combatDataStorage.GetTimeOfLastCSDeactivation( criticalState );
		
		if( timeOfLastCSDeactivation )
		{
			timeDifference = GetLocalTime() - timeOfLastCSDeactivation;
			
			if( timeDifference < maxTimeDifference )
			{
				return true;
			}
			
			return false;
		}
		else
		{
			return false;
		}
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CBaseAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBTTaskWasInCriticalStateDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskWasInCriticalState';

	editable var maxTimeDifference : float;
	editable var criticalState : ECriticalStateType;
	
	default maxTimeDifference = 5;
	default criticalState = ECST_BurnCritical;
}