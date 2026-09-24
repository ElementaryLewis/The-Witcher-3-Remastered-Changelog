/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskHasAbility extends IBehTreeTask
{
	var abilityName : name;
	var behVariableName : name;
	var behVariableActivateValue : float;
	var behVariableDeactivateValue : float;
	var failAnim : bool;
	
	var turnOffOnDeactivate : bool;
	var turnedOff : bool;
	
	default turnOffOnDeactivate = false;
	default turnedOff = false;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( turnedOff )
		{
			if ( npc.HasAbility(abilityName) && !npc.IsAbilityBlocked(abilityName) )
			{
				turnedOff = false;
				return true;
			}
			return false;
		}
		
		if (npc.HasAbility(abilityName))
		{
			if( npc.IsAbilityBlocked(abilityName) && !turnOffOnDeactivate)
			{
				turnOffOnDeactivate = true;
			}
			return true;
		}
		else if( failAnim && npc.IsAbilityBlocked(abilityName) )
		{
			turnOffOnDeactivate = true;
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		
		if ( turnOffOnDeactivate )
		{
			npc.SetBehaviorVariable(behVariableName,behVariableDeactivateValue);
		}
		else
		{
			npc.SetBehaviorVariable(behVariableName,behVariableActivateValue);
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( turnOffOnDeactivate )
		{
			turnedOff = true;
			turnOffOnDeactivate = false;
		}
	}
	
}

class CBTTaskHasAbilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHasAbility';

	editable var abilityName : name;
	editable var behVariableName : name;
	editable var behVariableActivateValue : float;
	editable var behVariableDeactivateValue : float;
	editable var failAnim : bool;
	
	default behVariableActivateValue = 0.f;
	default behVariableDeactivateValue = 1.f;
	default failAnim = true;
}

class CBTTaskHasAvailableAbility extends IBehTreeTask
{
	var abilityName : name;
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		
		if ( npc.HasAbility( abilityName ) && !npc.IsAbilityBlocked( abilityName ) )
		{
			return true;
		}
		
		return false;
	}
}

class CBTTaskHasAvailableAbilityDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskHasAvailableAbility';

	editable var abilityName : name;
}