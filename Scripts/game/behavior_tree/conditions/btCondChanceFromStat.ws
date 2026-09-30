/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskChanceFromStat extends IBehTreeTask
{
	var ifNot : bool;
	var statName : name;
	var frequency : float;
	var scaleWithNumberOfOpponents : bool;
	var chancePerOpponent : int;
	
	var lastRollTime	: float;

	function IsAvailable() : bool
	{
		if ( lastRollTime + frequency > GetLocalTime() )
		{
			return false;
		}
		
		if ( ifNot )
		{
			return !Roll();
		}
		else
		{
			return Roll();
		}
	}


	function Roll() : bool
	{
		var npc : CNewNPC = GetNPC();
		var rollChance : float;
		var oppNo : int;
		var i : int;
		
		rollChance = CalculateAttributeValue(npc.GetAttributeValue( statName ))*100;
		
		oppNo = NumberOfOpponents();
		
		if ( scaleWithNumberOfOpponents && oppNo > 1)
		{
			rollChance = oppNo*chancePerOpponent;
		}
		
		lastRollTime = GetLocalTime();
		if ( RandRange(100) < rollChance )
		{
			return true;
		}
		
		return false;
	}
	
	function NumberOfOpponents() : int
	{
		var owner : CNewNPC = GetNPC();	
		
		if ( owner.GetTarget() == thePlayer )
		{
			return thePlayer.GetNumberOfMoveTargets();
		}
		else
		{
			return -1;
		}
	}
}
class CBTTaskChanceFromStatDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTTaskChanceFromStat';

	editable var ifNot : bool;
	editable var statName : name;
	editable var frequency : float;
	editable var scaleWithNumberOfOpponents : bool;
	editable var chancePerOpponent : int;
	
	default frequency = 1.0;
	default scaleWithNumberOfOpponents = false;
	default chancePerOpponent = 34;

	hint chance = "while scaleWithNumberOfOpponents this is a chance for 1 opponent";
	hint frequency = "how often we Roll the virtual dice";
}

