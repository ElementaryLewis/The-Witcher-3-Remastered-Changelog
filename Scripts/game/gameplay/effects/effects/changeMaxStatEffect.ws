/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3ChangeMaxStatEffect extends CBaseGameplayEffect
{
	protected saved var stat : EBaseCharacterStats;			
	
		default isPositive = true;
	
	
	public function Init(params : SEffectInitInfo)
	{
		attributeName = StatEnumToName(stat);
		super.Init(params);
	}
}