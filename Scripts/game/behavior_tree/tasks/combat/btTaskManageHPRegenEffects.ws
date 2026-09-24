/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskManageHPRegenEffects extends BTTaskIrisTask
{
	
	
	
	public var ResumeEffect	: bool;
	public var OnDeactivate	: bool;
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( !OnDeactivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	
	private function OnDeactivate()
	{
		if( OnDeactivate )
		{
			Execute();
		}
	}
	
	
	function Execute()
	{
		if( ResumeEffect )
		{
			GetNPC().ResumeEffects(EET_AutoEssenceRegen, 'TaskManageHPRegenEffects');
		}
		else
		{
			GetNPC().PauseEffects(EET_AutoEssenceRegen, 'TaskManageHPRegenEffects', true);
		}
	}
}



class BTTaskManageHPRegenEffectsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskManageHPRegenEffects';
	
	private editable var ResumeEffect	: bool;
	private editable var OnDeactivate	: bool;	
	
}