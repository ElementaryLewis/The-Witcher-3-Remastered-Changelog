/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskKillEntityByTag extends IBehTreeTask
{
	var npc				: array<CNewNPC>;
	var tag 			: name;
	var onActivate		: bool;
	var onDeactivate	: bool;
	var i				: int;
	
	
	function OnActivate() : EBTNodeStatus
	{	
		if ( onActivate )
		{
			KillEntityByTag();
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if ( onDeactivate )
		{
			KillEntityByTag();
		}
	}
	
	function KillEntityByTag()
	{
		theGame.GetNPCsByTag( tag, npc );
		
		for (i = 0; i<npc.Size(); i+=1)
		{
			npc[i].Kill( 'AI' );
		}
	}
}
class CBTTaskKillEntityDef	extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskKillEntityByTag';
	
	var entity 						: CNewNPC;
	editable var tag 				: name;
	editable var onActivate			: bool;
	editable var onDeactivate		: bool;
}