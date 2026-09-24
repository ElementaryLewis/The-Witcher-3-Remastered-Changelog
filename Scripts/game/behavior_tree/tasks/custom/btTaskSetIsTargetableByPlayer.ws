/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class BTTaskSetIsTargetableByPlayer extends IBehTreeTask
{
	var value : bool;
	var onActivate : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		var actor : CActor = GetActor();
		
		if( onActivate )
		{
			actor.SetTatgetableByPlayer( value );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		var actor : CActor = GetActor();
		
		if( !onActivate )
		{
			actor.SetTatgetableByPlayer( value );
		}
	}
}

class BTTaskSetIsTargetableByPlayerDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'BTTaskSetIsTargetableByPlayer';
	
	editable var value : bool;
	editable var onActivate : bool;
	
	default value = true;
	default onActivate = true;
}