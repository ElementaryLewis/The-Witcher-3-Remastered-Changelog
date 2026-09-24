/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EOperator
{
	EO_Equal,
	EO_NotEqual,
	EO_Less,
	EO_LessEqual,
	EO_Greater,
	EO_GreaterEqual,
}

class BTCondNumberOfOpponents extends IBehTreeTask
{
	var value : float;
	var operator : EOperator;
	
	function IsAvailable() : bool
	{
		var oppNo : int = NumberOfOpponents();
		
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
	
	private function NumberOfOpponents() : int
	{
		var owner 				: CNewNPC = GetNPC();	
		var target 				: CActor = owner.GetTarget();
		var targetCombatData 	: CCombatDataComponent;
		var opponentsNum		: int;
		
		targetCombatData = (CCombatDataComponent) target.GetComponentByClassName('CCombatDataComponent');
		opponentsNum = -1;
		if( targetCombatData )
		{			
			opponentsNum = targetCombatData.GetAttackersCount();	
		}
			return opponentsNum;
	}
	
}

class BTCondNumberOfOpponentsDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondNumberOfOpponents';

	editable var value : float;
	editable var operator : EOperator;
	
	hint value = "NumberOfOpponents ?operator? value";
	
	default value = 1;
}