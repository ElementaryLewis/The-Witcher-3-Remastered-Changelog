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



class BTCondScaredByHumanTarget extends IBehTreeTask
{
	public var minDistance 		: float;
	public var maxDistance 		: float;
	public var predictionTime	: float;
	var animalData		 	: CAIStorageAnimalData;
	
	hint minDistance = "MIN <= distance < MAX";
	hint maxDistance = "MIN <= distance < MAX";

	function Initialize()
	{
		animalData = (CAIStorageAnimalData)RequestStorageItem( 'AnimalData', 'CAIStorageAnimalData' );
	}
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CNode;
		var dist : float;
		var npcPos 	: Vector;
		var targetPos : Vector;
		var actors : array<CActor>;
		var i : int;
		
		actors = GetActorsInRange(npc, maxDistance, 50);
		animalData.scared 	= false;

		
		if ( actors.Size() > 0 )
		{
			for( i = 0; i < actors.Size(); i += 1 )
			{
				if (actors[i] == (CActor)npc)
				{
					actors.Remove((CActor)npc);
				}
			}
		}

		
		if ( actors.Size() > 0 )
		{
			target = actors[0];
			dist = VecDistance2D(npc.GetWorldPosition(), target.GetWorldPosition());

			if (predictionTime < 0) 
			{
				for( i = 0; i < actors.Size(); i += 1 )
				{
					if ((VecDistance2D(npc.GetWorldPosition(), actors[i].GetWorldPosition()) < dist) && (dist >= minDistance))
					{
						target = actors[i];
						VecDistance2D(npc.GetWorldPosition(), actors[i].GetWorldPosition());
					}
				}
			}
			else 
			{
				for( i = 0; i < actors.Size(); i += 1 )
				{
					if ((VecDistance2D(npc.GetWorldPosition(), actors[i].PredictWorldPosition( predictionTime )) < dist) && (dist >= minDistance))
					{
						target = actors[i];
						VecDistance2D(npc.GetWorldPosition(), actors[i].PredictWorldPosition( predictionTime ));
					}
				}
			}

			if( dist >= minDistance  && dist <= maxDistance )
			{
				SetCombatTarget((CActor)target);
				animalData.scared 	= true;
			}

		}

		return true;
		
	}
}

class BTCondScaredByHumanTargetDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondScaredByHumanTarget';

	editable var minDistance 		: float;
	editable var maxDistance 		: float;
	editable var predictionTime		: float;
	
	default minDistance 	= 3.0f;
	default maxDistance 	= 10.0f;
	default predictionTime  = -1;
}

class BTCondScaredByPlayer extends IBehTreeTask
{
	public var minDistance 		: float;
	public var maxDistance 		: float;
	public var predictionTime	: float;
	var animalData		 	: CAIStorageAnimalData;
	
	hint minDistance = "MIN <= distance < MAX";
	hint maxDistance = "MIN <= distance < MAX";

	function Initialize()
	{
		animalData = (CAIStorageAnimalData)RequestStorageItem( 'AnimalData', 'CAIStorageAnimalData' );
	}
	
	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CNode;
		var dist : float;
		var npcPos 	: Vector;
		var targetPos : Vector;
		var actors : array<CActor>;
		var i : int;
		
		actors = GetActorsInRange(npc, maxDistance, 1, 'PLAYER');
		animalData.scared 	= false;

		
		if ( actors.Size() > 0 )
		{
			target = actors[0];
			dist = VecDistance2D(npc.GetWorldPosition(), target.GetWorldPosition());

			if (predictionTime < 0) 
			{
				for( i = 0; i < actors.Size(); i += 1 )
				{
					if ((VecDistance2D(npc.GetWorldPosition(), actors[i].GetWorldPosition()) < dist) && (dist >= minDistance))
					{
						target = actors[i];
						VecDistance2D(npc.GetWorldPosition(), actors[i].GetWorldPosition());
					}
				}
			}
			else 
			{
				for( i = 0; i < actors.Size(); i += 1 )
				{
					if ((VecDistance2D(npc.GetWorldPosition(), actors[i].PredictWorldPosition( predictionTime )) < dist) && (dist >= minDistance))
					{
						target = actors[i];
						VecDistance2D(npc.GetWorldPosition(), actors[i].PredictWorldPosition( predictionTime ));
					}
				}
			}

			if( dist >= minDistance  && dist <= maxDistance )
			{
				SetCombatTarget((CActor)target);
				animalData.scared 	= true;
			}

		}

		return true;
		
	}
}

class BTCondScaredByPlayerDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondScaredByPlayer';

	editable var minDistance 		: float;
	editable var maxDistance 		: float;
	editable var predictionTime		: float;
	
	default minDistance 	= 3.0f;
	default maxDistance 	= 10.0f;
	default predictionTime  = -1;
}