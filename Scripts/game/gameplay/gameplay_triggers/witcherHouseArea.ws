/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class W3WitcherHouseArea extends CGameplayEntity
{
	editable var isInner		: bool;		
	
		hint isInner = "This flag decides if the trigger is an outer or inner.. If false, trigger will be marked as outer";
		
		
	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var l_player		: W3PlayerWitcher;
		var l_bookshelf		: W3Bookshelf;
		
		l_player = (W3PlayerWitcher)activator.GetEntity();
		
		if( l_player )
		{
			if( isInner )
			{		
				FactsAdd( "PlayerInsideInnerWitcherHouse", 1 );
				
				
				l_bookshelf = (W3Bookshelf)theGame.GetEntityByTag( 'mq7024_witcher_bookshelf' );
				if( l_bookshelf )
				{
					l_bookshelf.UpdateBookshelfAppearance();
				}
				else
				{
					AddTimer( 'BookshelfAppearanceTimer', 0.5f, true );
				}
			}
			else
			{
				FactsAdd( "PlayerInsideOuterWitcherHouse", 1 );
			}
		}
	}
	
	event OnAreaExit( area : CTriggerAreaComponent, activator : CComponent )
	{
		var l_player		: W3PlayerWitcher;
		
		l_player = (W3PlayerWitcher)activator.GetEntity();
		
		if( l_player )
		{
			if( isInner )
			{		
				FactsRemove( "PlayerInsideInnerWitcherHouse" );
			}
			else
			{
				FactsRemove( "PlayerInsideOuterWitcherHouse" );
			}
		}
	}
	
	timer function BookshelfAppearanceTimer( dt : float, id : int )
	{
		var l_bookshelf : W3Bookshelf;
		
		l_bookshelf = (W3Bookshelf)theGame.GetEntityByTag( 'mq7024_witcher_bookshelf' );
		if( l_bookshelf )
		{
			l_bookshelf.UpdateBookshelfAppearance();
			RemoveTimer( 'BookshelfAppearanceTimer' );
		}
	}
}