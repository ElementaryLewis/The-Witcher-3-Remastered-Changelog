/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CGroupFXManager extends CGameplayEntity
{
	
	editable var entityTag : name;
	editable var randomDropMin : float;
	editable var randomDropMax : float;
	editable var effectName		: name;
	private var ntities : array< CEntity >;	
	private var randomDrop : float; default randomDrop = 1.f;
	

	function Activate()
	{
		
		theGame.GetEntitiesByTag( entityTag, ntities);
		AddTimer( 'StartDropping', randomDrop, true);
	}
	function Deactivate()
	{
		RemoveTimer('StartDropping');
	}
	
	timer function StartDropping( deltaTime : float, id : int )
	{
		var randomEntity : int;
		var givenEntity : CEntity;
		
		randomDrop = RandRangeF(randomDropMax+1, randomDropMin);
		
		if(	ntities.Size() > 0	)
		{
			randomEntity = RandRange(ntities.Size()-1, 0);
			givenEntity = ntities[randomEntity];
			givenEntity.PlayEffectSingle(effectName);
			ntities.Remove(givenEntity);
		}
		else
		{
			RemoveTimer('StartDropping');
		}
	
	}

	
	

}