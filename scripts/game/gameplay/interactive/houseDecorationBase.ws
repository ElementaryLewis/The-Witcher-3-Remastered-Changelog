/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
abstract class W3HouseDecorationBase extends W3Container
{
	protected var m_popupData : W3ItemSelectionPopupData;
	protected var m_itemSelectionTagList : array<name>;
	protected var m_itemSelectionForbiddenTagList : array<name>;
	protected var m_itemSelectionMode : EItemSelectionPopupMode;
	protected var m_itemSelectionCategories : array<name>;
	protected editable var m_acceptQuestItems : bool;
	protected editable saved var m_decorationEnabled : bool;
	protected editable var m_noItemMessageStringKey : name;
	
	default m_noItemMessageStringKey = 'decoration_error_generic';
	hint m_decorationEnabled = "String key of a message that should be display if the player doesn't have any valid items in his inventory."; 
	
	default m_decorationEnabled	= true;
	hint m_decorationEnabled = "Should the decoration entity interaction be enabled."; 
	
	
	default disableFocusHighlightControl = true;
	hint m_acceptQuestItems = "If true quest item filter we be disabled for this decoration."; 
	
	event OnSpawned( spawnData : SEntitySpawnData )
	{
		
		SetIsQuestContainer( true );
		
		
		if( !m_acceptQuestItems )
		{
			AddItemSelectionForbiddenFilterTag( 'Quest' );
		}
		
		UpdateDecorationFocusHighlight();
	}
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		if( GetIsDecoractionEmpty() )
		{
			if( GetIfPlayerHasValidItems() )
			{
				
				OpenItemCollectionMenu();
			}
			else
			{
				
				if( IsNameValid( m_noItemMessageStringKey ) )
				{
					thePlayer.DisplayHudMessage( GetLocStringByKeyExt( m_noItemMessageStringKey ) );
				}
			}
		}
		else
		{
			
			ProcessLoot ();
		}
	}
	
	event OnInteractionActivationTest( interactionComponentName : string, activator : CEntity )
	{
		
		if ( !m_decorationEnabled )
		{
			return false;
		}
		
		return true;
	}	
	
	
	timer function ItemSelectionTimer( delta : float , id : int)
	{
		if( m_popupData )
		{
			AddTimer( 'ItemSelectionTimer', 0.1f );
		}
		else
		{
			ProcessItemReceival();
		}
	}
	
	
	public function ProcessItemReceival( optional mute : bool )
	{
		
		SetFocusModeVisibility( focusModeHighlight );
	}
	
	
	private function UpdateDecorationFocusHighlight()
	{
		if( m_decorationEnabled )
		{
			this.SetFocusModeVisibility( FMV_Interactive, true );
		}
		else
		{
			this.SetFocusModeVisibility( FMV_None, true );
		}	
	}
	
	
	private function OpenItemCollectionMenu()
	{
		var itemSelectionPopup : CR4ItemSelectionPopup;	
		var tags : array<name>;	
		var firstTag : name;
		
		theGame.GetGuiManager().SetLastOpenedCommonMenuName( 'None' );
		
		tags = GetTags();
		firstTag = tags[0];
		
		
		if( !GetIsTagUnique( firstTag ) )
		{
			LogChannel( 'houseDecorations', "Entity tag '" + firstTag + "' is not unique, decoration will not function!" );
			return;
		}
		
		m_popupData = new W3ItemSelectionPopupData in theGame.GetGuiManager();
		m_popupData.targetInventory = GetInventory();
		m_popupData.collectorTag = firstTag;
		m_popupData.overrideQuestItemRestrictions = true;
		
		
		m_popupData.filterTagsList = m_itemSelectionTagList;
		m_popupData.filterForbiddenTagsList = m_itemSelectionForbiddenTagList;
		m_popupData.selectionMode = m_itemSelectionMode;
		
		m_popupData.categoryFilterList = m_itemSelectionCategories;
		
		theGame.RequestPopup('ItemSelectionPopup', m_popupData);
		AddTimer( 'ItemSelectionTimer', 0.1f );
	}
	
	
	function AddItemSelectionFilterTag( newTag : name )
	{
		m_itemSelectionTagList.PushBack( newTag );
	}
	
	
	function AddItemSelectionForbiddenFilterTag( newTag : name )
	{
		m_itemSelectionForbiddenTagList.PushBack( newTag );
	}

	
	function AddItemSelectionCategory( newCategory : name )
	{
		m_itemSelectionCategories.PushBack( newCategory );
	}
	
	
	function ChangeItemSelectionMode( newMode : EItemSelectionPopupMode )
	{
		m_itemSelectionMode = newMode;
	}
	
	
	private function GetIsTagUnique( entityTag : name ) : bool
	{
		var entities : array<CEntity>;
		
		theGame.GetEntitiesByTag( entityTag, entities );
		
		if( entities.Size() == 1 )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	
	private function GetIsDecoractionEmpty() : bool
	{
		return GetInventory().IsEmpty();
	}
	
	
	private function GetIfPlayerHasValidItems() : bool
	{
		return true;
	}
	
	
	public function SetDecorationEnabled( enabled : bool ) 
	{
		m_decorationEnabled = enabled;
		
		UpdateDecorationFocusHighlight();
	}
	
	
	public function GetAcceptQuestItems() : bool
	{
		return m_acceptQuestItems;
	}
	
	
	public function GetItemHasForbiddenTag( item : SItemUniqueId ) : bool
	{
		var i, size : int;
		var inv : CInventoryComponent;
		
		inv = thePlayer.GetInventory();
		size =  m_itemSelectionForbiddenTagList.Size();
		
		if( size == 0 ) return false;
		
		for( i=0; i < size; i+= 1 )
		{
			if( inv.ItemHasTag( item , m_itemSelectionForbiddenTagList[i] ) )
			{
				return true;
			}
		}
		
		return false;
	}	
	
	
	public function GetHasSleevlessArmor() : bool
	{
		var armors : array<SItemUniqueId>;
		var armorName  : name;
		var sleevlesDefinitions : array<name>;
		
		sleevlesDefinitions = theGame.GetDefinitionsManager().GetItemsWithTag('Sleevless');
		
		armors = GetInventory().GetItemsByCategory('armor');
		armorName = GetInventory().GetItemName( armors[0] );
		
		if( sleevlesDefinitions.Contains( armorName ) )
		{
			return true;
		}
		
		return false;
	}
	
	
}