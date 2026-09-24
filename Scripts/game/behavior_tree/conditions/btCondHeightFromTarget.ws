/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondHeightFromTarget extends IBehTreeTask
{
	
	
	
	var value				: float;
	var operator 			: EOperator;
	
	
	function IsAvailable() : bool
	{
		var target 		: CActor;		
		var oppNo 		: float;
		var pos			: Vector;
		var targetPos 	: Vector;
		
		target = GetNPC().GetTarget();
		
		pos 		= GetNPC().GetWorldPosition();
		targetPos 	= target.GetWorldPosition();
		
		oppNo = pos.Z - targetPos.Z;
		
		switch ( operator )
		{
			case EO_Equal:			return oppNo == value;
			case EO_NotEqual:		return oppNo != value;
			case EO_Less:			return oppNo < 	value;
			case EO_LessEqual:		return oppNo <= value;
			case EO_Greater:		return oppNo > 	value;
			case EO_GreaterEqual:	return oppNo >= value;
			default : 				return false;
		}
	}
	
}


class BTCondHeightFromTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondHeightFromTarget';

	editable var value				: float;
	editable var operator 			: EOperator;
	
	default value		= 5;
	default operator 	= EO_LessEqual;
}
