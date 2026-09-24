/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskTrollAttack extends CBTTaskAttack
{
	var getStats : bool;
	default getStats = true;

	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		var actors : array<CActor>;
		var npc : CNewNPC = GetNPC();
		var processed : bool;
		
		processed = super.OnAnimEvent( animEventName, animEventType, animInfo );
		
		if ( animEventName == 'AttackSmash' )
		{	
			actors = npc.GetAttackableNPCsAndPlayersInCone(3, npc.GetHeading(), 110);

			return true;
		}
		
		return processed;
	}
}

class CBTTaskTrollAttackDef extends CBTTaskAttackDef
{
	default instanceClass = 'CBTTaskTrollAttack';
}
