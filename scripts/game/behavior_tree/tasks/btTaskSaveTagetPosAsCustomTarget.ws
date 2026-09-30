/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSaveTargetPosAsCustomTarget extends IBehTreeTask
{
	
	
	
	public var useActionTarget 	: bool;
	public var onDeactivate 	: bool;
	public var snapToGround		: bool;
	
	
	final function OnActivate() : EBTNodeStatus
	{
		if( onDeactivate ) return BTNS_Active;
		
		SaveTarget();
		
		return BTNS_Active;
	}
	
	
	final function OnDeactivate()
	{
		if( !onDeactivate ) return;
		
		SaveTarget();
	}
	
	
	final function SaveTarget()
	{
		var l_pos 		: Vector;
		var l_heading	: float;
		var l_groundZ	: float;
		
		if( useActionTarget )
		{
			l_pos		= GetActionTarget().GetWorldPosition();
			l_heading 	= GetActionTarget().GetHeading();
		}
		else
		{
			l_pos		= GetCombatTarget().GetWorldPosition();
			l_heading 	= GetCombatTarget().GetHeading();
		}
		
		if( snapToGround && theGame.GetWorld().NavigationComputeZ( l_pos, l_pos.Z - 100, l_pos.Z + 100, l_groundZ ))
		{
			l_pos.Z = l_groundZ;
		}
		
		
		
		SetCustomTarget( l_pos, l_heading );
	}

}


class BTTaskSaveTargetPosAsCustomTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSaveTargetPosAsCustomTarget';
	
	
	private editable var useActionTarget 	: bool;
	private editable var onDeactivate 		: bool;
	private editable var snapToGround		: bool;
}