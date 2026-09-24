/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondDistanceToTagged extends IBehTreeTask
{
	var minDistance : float;
	var maxDistance : float;
	var targetTag : CName;

	function IsAvailable() : bool
	{
		var npc : CNewNPC = GetNPC();
		var target : CEntity = theGame.GetEntityByTag( targetTag );
		var dist : float;
		
		if( target )
		{	
			dist = VecDistance2D( npc.GetWorldPosition(), target.GetWorldPosition() );
			
			if( dist >= minDistance && dist <= maxDistance )
			{
				return true;
			}
		}
		
		return false;
	}
}

class BTCondDistanceToTaggedDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondDistanceToTagged';

	editable var minDistance : CBehTreeValFloat;
	editable var maxDistance : CBehTreeValFloat;
	editable var targetTag : CBehTreeValCName;
}
