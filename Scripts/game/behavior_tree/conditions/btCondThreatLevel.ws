/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondThreatLevel extends IBehTreeTask
{
	
	
	
	public var operator 					: EOperator;
	public var value						: int;
	
	
	final function IsAvailable() : bool
	{
		var oppNo 				: int;
		
		oppNo = GetNPC().GetThreatLevel();
		
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


class BTCondThreatLevelDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondThreatLevel';
	
	
	private editable var operator 					: EOperator;
	private editable var value						: int;
}




class BTCondTargetThreatLevel extends IBehTreeTask
{
	
	
	
	public var operator 					: EOperator;
	public var value						: int;
	
	
	final function IsAvailable() : bool
	{
		var npc					: CNewNPC;
		var oppNo 				: int;
		
		
		npc = (CNewNPC)GetCombatTarget();
		
		if ( ! npc )
			return false;
		
		oppNo = npc.GetThreatLevel();
		
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


class BTCondTargetThreatLevelDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondTargetThreatLevel';
	
	
	private editable var operator 					: EOperator;
	private editable var value						: int;
}