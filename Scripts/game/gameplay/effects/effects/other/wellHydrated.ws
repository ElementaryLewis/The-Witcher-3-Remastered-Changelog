/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_WellHydrated extends W3RegenEffect
{
	private var level : int;

	default effectType = EET_WellHydrated;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{		
			iconPath = theGame.effectMgr.GetPathForEffectIconTypeName('icon_effect_Dumplings');
		}
	}
	
	protected function CalculateDuration(optional setInitialDuration : bool)
	{
		var val : SAbilityAttributeValue;
		
		super.CalculateDuration(setInitialDuration);
		
		
		if(isOnPlayer && thePlayer == GetWitcherPlayer() && GetWitcherPlayer().HasRunewordActive('Runeword 6 _Stats'))
		{
			val = target.GetAttributeValue('runeword6_duration_bonus');
			duration *= ( 1 + val.valueMultiplicative );
		}
		
	}
	
	protected function GetSelfInteraction( e : CBaseGameplayEffect) : EEffectInteract
	{
		var eff : W3Effect_WellHydrated;
		
		eff = (W3Effect_WellHydrated)e;
		if(eff.level >= level)
			return EI_Cumulate;		
		else
			return EI_Deny;
	}
	
	public function CacheSettings()
	{
		var i : int;
		var dm : CDefinitionsManagerAccessor;
		var main : SCustomNode;
		var tmpName, customAbilityName : name;
		var type : EEffectType;		
	
		super.CacheSettings();
		
		dm = theGame.GetDefinitionsManager();
		main = dm.GetCustomDefinition('effects');
		
		for(i=0; i<main.subNodes.Size(); i+=1)
		{
			dm.GetCustomNodeAttributeValueName(main.subNodes[i], 'name_name', tmpName);
			EffectNameToType(tmpName, type, customAbilityName);
			if(effectType == type)
			{
				if(!dm.GetCustomNodeAttributeValueInt(main.subNodes[i], 'level', level))
					level = 0;
					
				break;
			}
		}
	}
	
	
	protected function SetEffectValue()
	{
		var min, max : SAbilityAttributeValue;
		
		super.SetEffectValue();
		
		if( GetWitcherPlayer().HasRunewordActive( 'Runeword 6 _Stats' ) )
		{
			theGame.GetDefinitionsManager().GetAbilityAttributeValue('Runeword 6 _Stats', 'runeword6_duration_bonus', min, max);
			effectValue.valueAdditive *= ( 1 + min.valueMultiplicative );
		}
		
	}
	
}