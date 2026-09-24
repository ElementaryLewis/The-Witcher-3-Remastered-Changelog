/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetThreatLevel extends IBehTreeTask
{
	
	
	
	var threatLevel 				: int;	
	var addToCurrent				: bool;
	
	
	private function OnActivate() : EBTNodeStatus
	{
		var finalValue : int;
		
		finalValue = threatLevel;
		if( addToCurrent )
		{
			finalValue += GetNPC().GetThreatLevel();
		}		
		finalValue = Max( 0, finalValue );
		GetNPC().ChangeThreatLevel( finalValue );
		
		return BTNS_Active;
	}
}


class BTTaskSetThreatLevelDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetThreatLevel';
	
	
	editable var threatLevel 		: int;
	editable var addToCurrent		: bool;	
	
	hint addToCurrent = "final threat level is guaranteed to be >= 0";
}
