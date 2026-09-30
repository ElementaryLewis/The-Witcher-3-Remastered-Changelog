/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondHasStaminaFor extends IBehTreeTask
{
	var staminaAction : EStaminaActionType;
	
	function IsAvailable() : bool
	{
		if( GetActor().HasStaminaToUseAction( staminaAction ) )
		{
			return true;
		}
		
		return false;
	}
}

class BTCondHasStaminaForDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHasStaminaFor';
	editable var staminaAction 	: EStaminaActionType;
	
	default staminaAction = ESAT_LightAttack;
}