/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondDistanceFromGround extends IBehTreeTask
{
	
	
	
	var checkedActor 		: EStatOwner;
	var value				: float;
	var operator 			: EOperator;
	
	
	private var m_collisionGroupNames : array<name>;
	
	
	final function Initialize()
	{
		m_collisionGroupNames.PushBack('Terrain');
		m_collisionGroupNames.PushBack('Foliage');
		m_collisionGroupNames.PushBack('Static');
	}
	
	
	final function IsAvailable() : bool
	{
		var target 	: CActor;		
		var oppNo 	: float;
		
		target = GetNPC();
		
		if( checkedActor == SO_Target )
		{
			target = target.GetTarget();
		}
		
		
		
		if( value <= 0 )
		{ 
			oppNo = 0.1f;
		}
		else
		{
			oppNo = target.GetDistanceFromGround( value + 1, m_collisionGroupNames);
		}
		
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


class BTCondDistanceFromGroundDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDistanceFromGround';

	editable var checkedActor 		: EStatOwner;
	editable var value				: CBehTreeValFloat;
	editable var operator 			: EOperator;
	
	default checkedActor = SO_NPC;
}
