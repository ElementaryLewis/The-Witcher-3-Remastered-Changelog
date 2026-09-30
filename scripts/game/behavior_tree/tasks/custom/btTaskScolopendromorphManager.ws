/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskScolopendromorphManager extends IBehTreeTask
{
	var UpdateIsOvergroundState : bool; 
	
 	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}

	latent function Main() : EBTNodeStatus
	{
	
		var l_npc 					: CNewNPC = GetNPC();

		if( UpdateIsOvergroundState )
		{
			l_npc.ToggleIsOverground( l_npc.GetBehaviorVariable('isOverground') );
		}
		
		return BTNS_Active;
	}

};

class BTTaskScolopendromorphManagerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskScolopendromorphManager';
	
	editable var UpdateIsOvergroundState : bool;
	
	default UpdateIsOvergroundState = true;
};