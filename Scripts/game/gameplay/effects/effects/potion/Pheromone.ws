/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Potion_Pheromone extends CBaseGameplayEffect
{
	private saved var abilityNameStr : string;	
	
	
	
	
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		if(abilityName != e.abilityName)
			return EI_Pass;
			
		return super.GetSelfInteraction(e);
	}
}