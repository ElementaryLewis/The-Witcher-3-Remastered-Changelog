/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondWaterDepth extends IBehTreeTask
{
	var checkedActor 	: EStatOwner;
	var value 			: float;
	var operator 		: EOperator;
	var frontalOffset	: float;
	
	
	
	function IsAvailable() : bool
	{
		var l_actor		: CActor	= GetNPC();
		var l_pos		: Vector;
		var depth 		: float;
		
		if( checkedActor == SO_NPC )
		{
			l_actor = GetNPC();
		}
		else
		{
			l_actor = GetCombatTarget();
		}
		l_pos = l_actor.GetWorldPosition();
		l_pos += VecNormalize( l_actor.GetHeadingVector() ) * frontalOffset;		
		depth = theGame.GetWorld().GetWaterDepth( l_pos );
		
		if( depth > 1000 ) depth = 0;
		
		switch ( operator )
		{
			case EO_Equal:			return depth == value;
			case EO_NotEqual:		return depth != value;
			case EO_Less:			return depth < value;
			case EO_LessEqual:		return depth <= value;
			case EO_Greater:		return depth > value;
			case EO_GreaterEqual:	return depth >= value;
			default : 				return false;
		}
	}
}


class BTCondWaterDepthDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondWaterDepth';
	
	
	
	editable var checkedActor 	: EStatOwner;
	editable var value 			: float;
	editable var operator 		: EOperator;
	editable var frontalOffset	: float;
	
	default checkedActor = SO_NPC;
}