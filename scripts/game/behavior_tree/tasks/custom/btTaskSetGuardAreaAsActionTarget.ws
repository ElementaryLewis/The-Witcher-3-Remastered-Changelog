/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetGuardAreaAsActionTarget extends IBehTreeTask
{
	
	
	
	var onDeactivate	: bool;	
	
	
	
	function OnActivate() : EBTNodeStatus
	{	
		if( !onDeactivate ) Execute();
		return BTNS_Active;
	}
	
	
	function OnDeactivate()
	{	
		if( onDeactivate ) Execute();
	}
	
	
	private function Execute()
	{
		var l_guardArea : CAreaComponent;
		
		l_guardArea = GetNPC().GetGuardArea();
		
		if( l_guardArea )
		{
			SetActionTarget( l_guardArea.GetEntity() );
		}
	}

}


class BTTaskSetGuardAreaAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetGuardAreaAsActionTarget';
	
	
	
	editable var onDeactivate	: bool;
	hint onDeactivate = "Execute on deactivate instead of on Activate";
}