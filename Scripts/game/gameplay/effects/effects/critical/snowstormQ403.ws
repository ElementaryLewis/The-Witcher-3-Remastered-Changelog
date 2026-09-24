/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3Effect_SnowstormQ403 extends W3Effect_Snowstorm
{
	default effectType = EET_SnowstormQ403;
		
	protected function StopEffects()
	{
		var temp : bool;
		
		
		temp = usesCam;
		usesCam = false;
		super.StopEffects();
		usesCam = temp;
		
		if(isOnPlayer)
			theGame.GetGameCamera().StopEffect( 'q403_battle_frost' );		
	}
	
	protected function PlayEffects()
	{
		var temp : bool;
		
		
		temp = usesCam;
		usesCam = false;
		super.PlayEffects();
		usesCam = temp;
		
		if(isOnPlayer)
			theGame.GetGameCamera().PlayEffect( 'q403_battle_frost' );
	}
}