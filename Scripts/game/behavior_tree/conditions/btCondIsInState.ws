/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondIsInState extends IBehTreeTask
{
	var stateName : CName;
	var ifNot : bool;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var temp : string;
		var currState : string;
		
		
		
		currState = npc.GetRootAnimatedComponent().GetCurrentBehaviorState();
		
		if ( !ifNot )
		{
			
			return currState == (string)stateName;
			
		}
		else
		{
			return currState != (string)stateName;
		}
	}
}

class BTCondIsInStateDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsInState';

	editable var stateName : CName;
	editable var ifNot : bool;
	
	default stateName = '';
	default ifNot = false;
}



class BTCondIsPlayerUnconscious extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return thePlayer.OnCheckUnconscious();
	}
}

class BTCondIsPlayerUnconsciousDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsPlayerUnconscious';
}



class BTCondIsPlayerInCombatState extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return thePlayer.IsInCombatState();
	}
}

class BTCondIsPlayerInCombatStateDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondIsPlayerInCombatState';
}