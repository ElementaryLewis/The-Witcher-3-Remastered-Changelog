/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Samum extends W3Petard
{
	protected function LoadDataFromItemXMLStats()
	{
		var samumParams : W3ConfuseEffectCustomParams;
		var i, j, iSize : int;
		var inv : CInventoryComponent;
		var abs : array<name>;
		var isLoopAbility : bool;
		var critChance : float;
		var dm : CDefinitionsManagerAccessor;
		
		super.LoadDataFromItemXMLStats();
		
		inv = GetOwner().GetInventory();
		inv.GetItemAbilities(itemId, abs);
		dm = theGame.GetDefinitionsManager();
		iSize = abs.Size();
		for( i = 0; i < iSize; i += 1 )
		{
			isLoopAbility = dm.AbilityHasTag(abs[i], 'PetardLoopParams');
			if(!isLoopAbility)
				if(!dm.AbilityHasTag(abs[i], 'PetardImpactParams'))
					continue;
			
			critChance = CalculateAttributeValue(inv.GetItemAttributeValue(itemId, 'critical_hit_chance'));
			
			if(critChance <= 0)
				continue;
			
			if(isLoopAbility)			
			{
				for(j=0; j<loopParams.buffs.Size(); j+=1)
				{
					if(loopParams.buffs[j].effectType == EET_Confusion)
					{
						samumParams = new W3ConfuseEffectCustomParams in GetOwner();
						samumParams.criticalHitChanceBonus = critChance;
						loopParams.buffs[j].effectCustomParam = samumParams;
						break;
					}
				}
			}
			else
			{
				for(j=0; j<impactParams.buffs.Size(); j+=1)
				{
					if(impactParams.buffs[j].effectType == EET_Confusion)
					{
						samumParams = new W3ConfuseEffectCustomParams in GetOwner();
						samumParams.criticalHitChanceBonus = critChance;
						impactParams.buffs[j].effectCustomParam = samumParams;
						break;
					}
				}
			}
		}
	}
}