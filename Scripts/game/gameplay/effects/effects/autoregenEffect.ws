/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3AutoRegenEffect extends W3RegenEffect
{
	default duration = -1;
	
	
	protected function SetEffectValue()
	{
		if(regenStat != CRS_Undefined)
			effectValue = target.GetAttributeValue( RegenStatEnumToName(regenStat) );
	}
}