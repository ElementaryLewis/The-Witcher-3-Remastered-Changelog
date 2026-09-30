/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_UseRiddleNode extends W3SwitchEvent
{
	editable var riddleNodeTag : name;
	
	public function Perform( parnt : CEntity )
	{	
		var riddleNode : W3RiddleNode;
		
		riddleNode = (W3RiddleNode)theGame.GetEntityByTag ( riddleNodeTag );
		
		if ( riddleNode )
		{
			riddleNode.ChangePosition ();
		}
	}
}