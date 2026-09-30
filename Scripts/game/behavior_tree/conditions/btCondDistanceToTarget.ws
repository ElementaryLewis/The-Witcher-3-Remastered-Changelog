/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondDistanceToTarget extends IBehTreeTask
{
	public var minDistance 		: float;
	public var maxDistance 		: float;
	public var attackRange 		: bool;
	public var useCombatTarget	: bool;
	public var predictionTime	: float;
	
	
	hint minDistance = "MIN <= distance < MAX";
	hint maxDistance = "MIN <= distance < MAX";
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CNode;
		var dist : float;
		var npcPos 	: Vector;
		var targetPos : Vector;
		
		if( useCombatTarget )
		{
			target  = GetCombatTarget();
		}
		else
		{
			target = GetActionTarget();
		}
		
		if( target )
		{
			if ( attackRange )
			{
				if( (CActor) target )
				{
					return npc.InAttackRange( (CActor) target);
				}
				else
				{
					return false;
				}
			}
			npcPos 		= npc.GetWorldPosition();
			if( predictionTime < 0 || !((CActor) target))
			{
				targetPos 	= target.GetWorldPosition();
			}
			else
			{
				targetPos = ((CActor) target).PredictWorldPosition( predictionTime );
			}
			dist = VecDistance2D( npcPos, targetPos );
			
			if( dist >= minDistance  && dist < maxDistance )
			{
				return true;
			}
		}
		
		return false;
	}
}

class BTCondDistanceToTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDistanceToTarget';

	editable var minDistance 		: float;
	editable var maxDistance 		: float;
	editable var attackRange  		: bool;
	editable var useCombatTarget	: bool;
	editable var predictionTime		: float;
	
	default minDistance 	= 3.0f;
	default maxDistance 	= 6.0f;
	default attackRange 	= false;
	default useCombatTarget = true;
	default predictionTime  = -1;
}
