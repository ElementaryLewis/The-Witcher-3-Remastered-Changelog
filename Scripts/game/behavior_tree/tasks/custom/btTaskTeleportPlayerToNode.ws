/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskTeleportPlayerToNode extends IBehTreeTask
{
	var nodeToFind			: name;
	var shouldComplete		: bool;
	var node				: CNode;
	var pos 				: Vector;
	var rot 				: EulerAngles;
		
	
	latent function Main() : EBTNodeStatus
	{
		node = theGame.GetNodeByTag( nodeToFind );
		pos = node.GetWorldPosition();
		rot = node.GetWorldRotation();
		thePlayer.TeleportWithRotation( pos, rot );
		
		if( shouldComplete )
		{
			return BTNS_Completed;
		}
		else return BTNS_Active;
	}
}
class CBTTaskTeleportPlayerToNodeDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskTeleportPlayerToNode';
	
	editable var nodeToFind			: name;
	editable var shouldComplete		: bool;
	var node						: CNode;
	var pos 						: Vector;
	var rot 						: EulerAngles;
	
}