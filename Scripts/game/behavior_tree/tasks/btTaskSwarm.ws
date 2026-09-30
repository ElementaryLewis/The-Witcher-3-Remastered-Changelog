/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSwarm extends CBTTaskAttack
{
	var lair : CFlyingSwarmMasterLair;
	var entities : array<CGameplayEntity>;
	var i : int;
	
	function OnActivate() : EBTNodeStatus
	{
		var owner : CNewNPC = GetNPC();
		var lairEntities : array<CGameplayEntity>;
		
		if ( !lair )
		{
			FindGameplayEntitiesInRange( lairEntities, GetActor(), 150, 1, 'SwarmMasterLair' );
			if ( lairEntities.Size() > 0 )
				lair = (CFlyingSwarmMasterLair)lairEntities[0];
		}
		if ( lair )
		{
			lair.SetBirdMaster( owner );
		}
		return super.OnActivate();
	}
};

class CBTTaskSwarmDef extends CBTTaskPlayAnimationEventDecoratorDef
{
	default instanceClass = 'CBTTaskSwarm';
};