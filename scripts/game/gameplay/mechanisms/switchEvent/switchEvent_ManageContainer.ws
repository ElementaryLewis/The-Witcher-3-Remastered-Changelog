/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3SE_ManageContainer extends W3SwitchEvent
{	
	editable var containersTag	: name;
	editable var containerEnabled : bool;
	
	public function Perform( parnt : CEntity )
	{
		var container : W3Container;
		var containerNodes : array<CNode>;
		var i, size : int;
	
		if( IsNameValid(containersTag) )
			theGame.GetNodesByTag(containersTag, containerNodes);
		
		size = containerNodes.Size();
		
		for( i = 0; i < size; i += 1 )
		{
			container = (W3Container)containerNodes[i];
			
			if( container )
			{
				container.Enable( containerEnabled, false, true );
			}
		}
	}
}