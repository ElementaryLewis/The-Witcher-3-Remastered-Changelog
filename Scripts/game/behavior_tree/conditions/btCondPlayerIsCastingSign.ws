/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTCondPlayerIsCastingSign extends IBehTreeTask
{
	
	
	
	public var sign 				: ESignType;
	
	function IsAvailable() : bool
	{
		var l_currentCastSign 	: ESignType;
		
		if( !thePlayer.IsInCombatAction() )
			return false;
		
		if( thePlayer.GetBehaviorVariable( 'combatActionType') != (int)CAT_CastSign )
			return false;
		
		l_currentCastSign = thePlayer.GetCurrentlyCastSign();
		
		if( l_currentCastSign == sign )
			return true;
		else
			return false;
	}
}


class BTCondPlayerIsCastingSignDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'BTCondPlayerIsCastingSign';
	
	
	editable var sign 				: ESignType;	
}