/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskDrainStat extends IBehTreeTask
{
	var stat : EBaseCharacterStats;
	var val : float;
	var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			Execute();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate ) 
		{
			Execute();
		}
	}
	
	private function Execute()
	{
		switch( stat )
		{
			case BCS_Stamina:
				GetNPC().DrainStamina( ESAT_FixedValue, val );
				break;
			
			case BCS_Vitality:
				GetNPC().DrainVitality( val );
				break;
			
			case BCS_Essence:
				GetNPC().DrainEssence( val );
				break;
			
			default:
				break;
		}
	}
}

class BTTaskDrainStatDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskDrainStat';

	editable var stat : EBaseCharacterStats;
	editable var val : float;
	editable var onActivate : bool;
	
	default stat = BCS_Stamina;
	default onActivate = true;
}