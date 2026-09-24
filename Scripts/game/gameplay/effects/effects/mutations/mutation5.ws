/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_Mutation5 extends CBaseGameplayEffect
{
	private var bonusPerPoint : float;

	default effectType = EET_Mutation5;
	default isPositive = true;
	
	event OnEffectAddedPost()
	{
		var min, max : SAbilityAttributeValue;
		
		super.OnEffectAddedPost();
		
		theGame.GetDefinitionsManager().GetAbilityAttributeValue( 'Mutation5', 'mut5_dmg_red_perc', min, max );
		bonusPerPoint = min.valueAdditive;
	}
	
	public function GetStacks() : int
	{
		return RoundMath( 100 * bonusPerPoint * FloorF( target.GetStat( BCS_Focus ) ) );
	}
	
	public function GetMaxStacks() : int
	{
		return RoundMath( 100 * bonusPerPoint * FloorF( target.GetStatMax( BCS_Focus ) ) );
	}
}