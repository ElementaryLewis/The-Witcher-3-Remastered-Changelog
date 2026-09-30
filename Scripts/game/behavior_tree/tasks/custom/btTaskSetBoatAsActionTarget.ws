/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetBoatAsActionTarget extends IBehTreeTask
{
	
	function IsAvailable() : bool
	{
		FindBoat();
		if ( GetActionTarget() )
			return true;
			
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		SetActionTarget(NULL);
	}
	
	function FindBoat()
	{
		var destructionComp : CBoatDestructionComponent;
		if ( GetCombatTarget() == thePlayer && thePlayer.IsSailing() )
		{
			this.SetActionTarget(thePlayer.GetUsedVehicle());
			
		}
	}
}

class CBTTaskSetBoatAsActionTargetDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBoatAsActionTarget';
}
