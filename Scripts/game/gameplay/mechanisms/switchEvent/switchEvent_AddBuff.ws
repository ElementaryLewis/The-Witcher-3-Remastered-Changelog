/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_AddBuff extends W3SwitchEvent
{
	editable var applyEffect : EEffectType;
	editable var useDefaultValuesFromXML : bool;
	editable var effectDuration : float;
	editable var customDamageValuePerSec : SAbilityAttributeValue;
	
	default useDefaultValuesFromXML = true;
	
	function PerformArgNode( parnt : CEntity, node : CNode )
	{
		var actor : CActor;
		var params : SCustomEffectParams;
	
		actor = (CActor)node;
		
		if(actor)
		{
			if( useDefaultValuesFromXML )
			{
				actor.AddEffectDefault( applyEffect, NULL, "effectorApplyEffect" );
			}
			else
			{
				params.effectType = applyEffect;
				params.sourceName = "effectorApplyEffect";
				params.duration = effectDuration;
				params.effectValue = customDamageValuePerSec;
				
				actor.AddEffectCustom(params);
			}
		}
	}
}
