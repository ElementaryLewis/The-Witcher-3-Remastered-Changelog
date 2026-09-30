/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetIsInSpawn extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{
        GetNPC().SetIsInSpawnTask(true);
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
        GetNPC().SetIsInSpawnTask(false);
	}
}

class BTTaskSetIsInSpawnDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetIsInSpawn';
};