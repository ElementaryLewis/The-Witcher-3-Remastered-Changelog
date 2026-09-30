/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_GryphonSetBonus extends CBaseGameplayEffect
{
	protected var m_whichSignForFree : W3SignEntity;
	
	default effectType = EET_GryphonSetBonus;
	default isPositive = true;
	
	public function SetWhichSignForFree( s : W3SignEntity )
	{
		m_whichSignForFree = s;
	}
	
	public function GetWhichSignForFree() : W3SignEntity
	{
		return m_whichSignForFree;
	}
}