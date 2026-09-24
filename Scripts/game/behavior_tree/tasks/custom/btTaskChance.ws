/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskChance extends IBehTreeTask
{
	var ifNot : bool;
	var chance : int;
	var frequency : float;
	var scaleWithNumberOfOpponents : bool;
	var chancePerOpponent : int;
	
	var lastRollTime	: float;
	var lastRollResult	: bool;

	function IsAvailable() : bool
	{
		if ( GetLocalTime() - lastRollTime > frequency )
		{
			lastRollResult = Roll();
		}
		
		return lastRollResult;
	}


	function Roll() : bool
	{
		var rollChance 	: float;
		var oppNo 		: int;
		var i 			: int;
		var rolledValue	: int;
		
		rollChance = chance;
		
		oppNo = NumberOfOpponents();
		
		if ( scaleWithNumberOfOpponents && oppNo > 1)
		{
			rollChance = oppNo*chancePerOpponent;
		}
		
		lastRollTime = GetLocalTime();
		rolledValue = RandRange(100);
		if (  rolledValue < rollChance )
		{
			return true;
		}
		
		return false;
	}
	
	function NumberOfOpponents() : int
	{
		var target 				: CActor = GetNPC().GetTarget();
		var targetCombatData 	: CCombatDataComponent;
		var opponentsNum		: int;
		
		opponentsNum = -1;
		if(target)
		{
			targetCombatData = (CCombatDataComponent) target.GetComponentByClassName('CCombatDataComponent');		
			if( targetCombatData )
			{			
				opponentsNum = targetCombatData.GetAttackersCount();	
			}
		}
		return opponentsNum;
	}
}
class CBTTaskChanceDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskChance';

	editable var chance : CBehTreeValInt;
	editable var frequency : float;
	editable var scaleWithNumberOfOpponents : bool;
	editable var chancePerOpponent : int;
	
	default chance = 100;
	default frequency = 1.0;
	default scaleWithNumberOfOpponents = false;
	default chancePerOpponent = 34;

	hint chance = "while scaleWithNumberOfOpponents this is a chance for 1 opponent";
	hint frequency = "how often we Roll the virtual dice";
}

