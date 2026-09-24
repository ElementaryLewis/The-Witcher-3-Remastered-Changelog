/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetCanBeFollowed extends IBehTreeTask
{
	var setCanBeFollowed : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if( setCanBeFollowed )
		{
			GetNPC().SetCanBeFollowed( true );
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( setCanBeFollowed )
		{
			GetNPC().SetCanBeFollowed( false );
			thePlayer.SignalGameplayEvent( 'StopPlayerAction' );
			thePlayer.SetCanFollowNpc( false, NULL );
		}
	}
}

class CBTTaskSetCanBeFollowedDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetCanBeFollowed';

	editable var setCanBeFollowed : CBehTreeValBool;
	default setCanBeFollowed =  false;
}