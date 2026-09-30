/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
statemachine class W3Bookshelf extends W3SmartObject
{
	saved var m_booksRange				: int;
	editable var m_appearances			: array<name>;
	
	default focusModeVisibility = FMV_Interactive;

	event OnAreaEnter( area : CTriggerAreaComponent, activator : CComponent )
	{
		var mapManager : CCommonMapManager = theGame.GetCommonMapManager();

		if( activator.GetEntity() == GetWitcherPlayer() )
		{
			mapManager.SetEntityMapPinDiscoveredScript( false, entityName, true );
		}
	}
	
	event OnStartUseEnd()
	{
		super.OnStartUseEnd();
		OpenBookshelfMenu();
	}
	
	protected function OpenBookshelfMenu()
	{
		var l_initData : W3SingleMenuInitData;
		
		thePlayer.AddEffectDefault( EET_BookshelfBuff, this, "Bookshelf" );
		
		l_initData = new W3SingleMenuInitData in this; 
		l_initData.SetBlockOtherPanels( true );
		l_initData.ignoreSaveSystem = true;
		l_initData.fixedMenuName = 'GlossaryBooksMenu';
		l_initData.setDefaultState( '' );
		
		theGame.RequestMenuWithBackground( 'GlossaryBooksMenu', 'CommonMenu', l_initData );
	}
	
	public function UpdateBookshelfAppearance()
	{
		var l_booksPerRange			: int;
		var l_i, l_gatheredBooks	: int;
		var l_witcher				: W3PlayerWitcher;
		var l_items					: array<SItemUniqueId>;

		l_witcher = GetWitcherPlayer();
		l_items = l_witcher.inv.GetItemsByCategory( 'book' );
		
		for( l_i = 0 ; l_i < l_items.Size() ; l_i += 1 )
		{
			if( l_witcher.inv.ItemHasAbility( l_items[ l_i], 'Default Book _Stats' ) )
			{
				l_gatheredBooks += 1;
			}
		}
		
		if( ( m_appearances.Size() - 1 ) != 0 )
		{
			l_booksPerRange = theGame.params.TOTAL_AMOUNT_OF_BOOKS / m_appearances.Size();		
			
			if( m_booksRange != l_gatheredBooks / l_booksPerRange )
			{
				m_booksRange = l_gatheredBooks / l_booksPerRange;
				
				if( m_booksRange >= m_appearances.Size() )
				{
					m_booksRange = m_appearances.Size() - 1;
				}
				
				ApplyAppearance( m_appearances[m_booksRange] );	
			}			
		}
	}
}