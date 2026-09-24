/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondFightStage extends IBehTreeTask
{
	var currentFightStageIs : ENPCFightStage;
	
	function IsAvailable() : bool
	{
		return currentFightStageIs == GetNPC().GetCurrentFightStage();
	}
}

class BTCondFightStageDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondFightStage';

	editable var currentFightStageIs : ENPCFightStage;
}