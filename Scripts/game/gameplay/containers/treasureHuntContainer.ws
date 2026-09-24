/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3treasureHuntContainer extends W3Container
{
	editable inlined var OnLootedEvents : array< W3SwitchEvent >;		
	
	
	
	public function OnContainerClosed()
	{
		if ( IsEmpty() )
		{
			ProcessOnLootedEvents ();
		}
		super.OnContainerClosed();
	}
	
	function ProcessOnLootedEvents ()
	{
		ActivateEvents ( OnLootedEvents );
	}
	
	private function ActivateEvents( events : array< W3SwitchEvent > )
	{
		var i, size : int;
		
		size = events.Size();
		for( i = 0; i < size; i += 1 )
		{
			if ( events[ i ] )
			{
				events[ i ].TriggerArgNode( this, thePlayer );
			}
		}
	}

}