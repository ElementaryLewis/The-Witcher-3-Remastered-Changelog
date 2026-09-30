/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskReactionSystemLogReport extends IBehTreeTask
{
	var reactionName : string;
	var message : string;
	
	function OnActivate() : EBTNodeStatus
	{
		LogReactionSystem( "'" + reactionName + "' " + message + " " + GetNPC().GetName() ); 
		return BTNS_Active;
	}
};

class CBTTaskReactionSystemLogReportDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskReactionSystemLogReport';

	editable var reactionName : string;
	editable var message : string;
	
	default message = "reaction was processed by";
};