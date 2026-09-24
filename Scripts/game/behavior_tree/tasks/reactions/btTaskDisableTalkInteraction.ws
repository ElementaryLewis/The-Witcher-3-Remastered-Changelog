/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskDisableTalkInteraction extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{
		GetNPC().DisableTalking( true, true );
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().DisableTalking( false, true );
	}
}

class CBTTaskDisableTalkInteractionDef extends IBehTreeReactionTaskDefinition
{
	default instanceClass = 'CBTTaskDisableTalkInteraction';
}
