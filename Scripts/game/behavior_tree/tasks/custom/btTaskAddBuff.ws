/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskAddBuffs extends IBehTreeTask
{
	
	
	
	public  var onDeactivate	: bool;
	public 	var buffs			: array<EEffectType>;
	public 	var duration		: float;
	public  var customValue		: SAbilityAttributeValue;
	
	
	function OnActivate() : EBTNodeStatus
	{
		if( onDeactivate ) return BTNS_Active;
		AddBuffs();
		return BTNS_Active;
	}	
	
	
	private function OnDeactivate()
	{
		if( !onDeactivate ) return;
		AddBuffs();
	}
	
	
	
	private function AddBuffs()
	{
		var i			: int;
		var l_actor		: CActor;
		var l_params	: SCustomEffectParams;
		
		l_actor				= GetNPC();
		
		for( i = 0; i < buffs.Size(); i += 1 )
		{
			l_params.effectType = buffs[i];
			
			
			if( buffs[i] == EET_VitalityDrain )
			{
				l_params.creator 	= GetCombatTarget();
				l_params.sourceName = GetCombatTarget().GetName();
			}
			else
			{
				l_params.sourceName = l_actor.GetName();
			}
			
			l_params.duration 	= duration;
			
			if( customValue.valueAdditive != 0 || customValue.valueBase != 0 || customValue.valueMultiplicative != 0 )
				l_params.effectValue = customValue;
			
			l_actor.AddEffectCustom( l_params );
		}
		
	}
}




class BTTaskAddBuffsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskAddBuffs';
	
	
	
	private editable var onDeactivate	: bool;
	private editable var buffs			: array<EEffectType>;
	private editable var duration		: float;
	private editable var customValue	: SAbilityAttributeValue;
}