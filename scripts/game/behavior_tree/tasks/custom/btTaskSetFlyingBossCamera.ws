/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetFlyingBossCamera extends IBehTreeTask
{
	private var val : bool;
	private var onActivate : bool;

	function OnActivate() : EBTNodeStatus
	{
		if( onActivate )
		{
			thePlayer.SetFlyingBossCamera( val );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( !onActivate )
		{
			thePlayer.SetFlyingBossCamera( val );
		}
	}
}




class BTTaskSetFlyingBossCameraDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetFlyingBossCamera';
	
	editable var val : bool;
	editable var onActivate : bool;
	
	default onActivate = true;
}