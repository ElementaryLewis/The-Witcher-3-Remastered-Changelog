/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondCanDodge extends IBehTreeTask
{
	public var navmeshCheckDist 					: float;

	function IsAvailable() : bool
	{
		return CheckNavMesh();
	}
	
	function CheckNavMesh() : bool
	{
		var ownerPosition 		: Vector;
		var targetVector 		: Vector;
		
		if (GetCombatTarget())
		{
			ownerPosition = GetActor().GetWorldPosition();
			targetVector = VecNormalize2D(GetActor().GetWorldPosition() - GetCombatTarget().GetWorldPosition());
			
			return theGame.GetWorld().NavigationLineTest(ownerPosition,ownerPosition + navmeshCheckDist*targetVector,GetActor().GetRadius());
		}
		
		return true;
	}
};

class CBTCondCanDodgeDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondCanDodge';
	
	editable var navmeshCheckDist 					: float;
	
	default navmeshCheckDist = 4.0f;
	
};