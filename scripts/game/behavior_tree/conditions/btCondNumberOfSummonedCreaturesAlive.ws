/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondNumberOfSummonedCreaturesAlive extends IBehTreeTask
{
	var value : float;
	var operator : EOperator;
	
	function IsAvailable() : bool
	{
		var oppNo 				: int;		
		var summonerComponent 	: W3SummonerComponent;
		
		summonerComponent = (W3SummonerComponent) GetNPC().GetComponentByClassName('W3SummonerComponent');
		
		if( !summonerComponent )
		{ 
			LogChannel('AITasks', "ERROR in NPC Tree (task "+this+") : " + GetNPC() + " doesn't have a W3SummonerComponent" );
			return false;
		}
		
		oppNo = summonerComponent.GetNumberOfSummonedEntities();
		
		switch ( operator )
		{
			case EO_Equal:			return oppNo == value;
			case EO_NotEqual:		return oppNo != value;
			case EO_Less:			return oppNo < value;
			case EO_LessEqual:		return oppNo <= value;
			case EO_Greater:		return oppNo > value;
			case EO_GreaterEqual:	return oppNo >= value;
			default : 				return false;
		}
	}	
}

class BTCondNumberOfSummonedCreaturesAliveDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondNumberOfSummonedCreaturesAlive';

	editable var value : float;
	editable var operator : EOperator;
	
	hint value = "NumberOfSummonedCreaturesAlive ?operator? value";
	
	default value = 1;
}