/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3RaisePowerStatEffect extends CBaseGameplayEffect
{
	protected saved var stat : ECharacterPowerStats;		
	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	public function Init(params : SEffectInitInfo)
	{
		attributeName = PowerStatEnumToName(stat);
		super.Init(params);
	}
}