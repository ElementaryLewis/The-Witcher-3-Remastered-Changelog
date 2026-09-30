/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageSnappingNavigableSpace extends IBehTreeTask
{
	var snap						: bool;
	var onDeactivate 				: bool;	
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !onDeactivate )
		{
			((CMovingAgentComponent)GetNPC().GetMovingAgentComponent()).SnapToNavigableSpace( snap );
		}
			
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			((CMovingAgentComponent)GetNPC().GetMovingAgentComponent()).SnapToNavigableSpace( snap );
		}
	}
}

class BTTaskManageSnappingNavigableSpaceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageSnappingNavigableSpace';

	editable var snap						: bool;
	editable var onDeactivate 				: bool;
};