/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class W3Container extends W3LockableEntity 
{
	editable 			var isDynamic				: bool;					
																			
	editable 			var skipInventoryPanel		: bool;					
	editable saved		var focusModeHighlight		: EFocusModeVisibility;
	editable			var factOnContainerOpened	: string;
						var usedByCiri				: bool;
	editable			var allowToInjectBalanceItems : bool;
					default allowToInjectBalanceItems = false;					
	editable			var disableLooting			: bool;
	
	editable			var disableStealing			: bool;
					default	disableStealing			= true;
	
	protected saved 	var checkedForBonusMoney	: bool;					
	
	private	saved		var	usedByClueStash 		: EntityHandle;
	private 			var disableFocusHighlightControl : bool;		
					default disableFocusHighlightControl = false;

	protected optional autobind 	inv							: CInventoryComponent = single;
	protected optional autobind 	lootInteractionComponent 	: CInteractionComponent = "Loot";
	protected var isPlayingInteractionAnim : bool; default isPlayingInteractionAnim = false;
	private const var QUEST_HIGHLIGHT_FX : name;							
	private saved var spoonCollectorTested : bool;

	hint skipInventoryPanel = "If set then the inventory panel will not be shown upon looting";
	hint isDynamic = "set to true if you want to destroy container when empty";
	hint focusModeHighlight = "FMV_Interactive: White, FMV_Clue: Red";
	
	default skipInventoryPanel = false;	
	default usedByCiri = false;	
	default focusModeHighlight = FMV_Interactive;
	default QUEST_HIGHLIGHT_FX = 'quest_highlight_fx';
	default disableLooting = false;
	
	import function SetIsQuestContainer( isQuest : bool );
	
	private const var SKIP_NO_DROP_NO_SHOW : bool;
	default SKIP_NO_DROP_NO_SHOW = true;
	
	event OnSpawned( spawnData : SEntitySpawnData ) 
	{		
		EnableVisualDebug( SHOW_Containers, true );
		super.OnSpawned(spawnData);
		
		
		if(disableLooting)
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( FMV_None );
			}
			StopQuestItemFx();
			if( lootInteractionComponent )
			{
				lootInteractionComponent.SetEnabled(false);
			}
			CheckLock();
		}
		else
		{
			UpdateContainer();
		}
	}
	
		
	event OnStreamIn()
	{
		super.OnStreamIn();
		
		UpdateContainer();
	}
	
	event OnSpawnedEditor( spawnData : SEntitySpawnData )
	{
		EnableVisualDebug( SHOW_Containers, true );
		super.OnSpawned( spawnData );	
	}
	
	event OnVisualDebug( frame : CScriptedRenderFrame, flag : EShowFlags )
	{
		frame.DrawText( GetName(), GetWorldPosition() + Vector( 0, 0, 1.0f ), Color( 255, 0, 255 ) );
		frame.DrawSphere( GetWorldPosition(), 1.0f, Color( 255, 0, 255 ) );
		return true;
	}
	
	function UpdateFactItems()
	{
		var i,j : int;
		var items : array<SItemUniqueId>;
		var tags : array<name>;
		var factName : string;
		
		
		if( inv && !disableLooting)
		{
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			tags.Clear();
			inv.GetItemTags(items[i], tags);	
			for(j=0; j<tags.Size(); j+=1)
			{
				factName = StrAfterLast(NameToString(tags[j]), "fact_hidden_");
				if(StrLen(factName) > 0)
				{
					if(FactsQuerySum(factName) > 0)
					{
						inv.RemoveItemTag(items[i], theGame.params.TAG_DONT_SHOW);
					}
					else
					{
						inv.AddItemTag(items[i], theGame.params.TAG_DONT_SHOW);
					}
						
					break;
				}
			}
		}
	}
	
	function InjectItemsOnLevels()
	{
		
	}
	
	
	event OnInteractionActivated( interactionComponentName : string, activator : CEntity )
	{
		UpdateContainer();
		RebalanceItems();
		RemoveUnwantedItems();
		if ( DisableIfEmpty() )
		{
			
			return false;
		}
		
		super.OnInteractionActivated(interactionComponentName, activator);
		if(activator == thePlayer)
		{
			if ( inv && !disableLooting)
			{
				inv.UpdateLoot();
				
				if(!checkedForBonusMoney)
				{
					checkedForBonusMoney = true;
					CheckForBonusMoney(0);
				}
			}
			if(!disableLooting && (!thePlayer.IsInCombat() || IsEnabledInCombat()) )
				HighlightEntity();
			
			if ( interactionComponentName == "Medallion" && isMagicalObject )
				SenseMagic();
			
			if( (!IsEmpty() && !disableLooting) || lockedByKey)	
			{
				ShowInteractionComponent();
			}
		}
	}
	
	
	event OnInteractionDeactivated( interactionComponentName : string, activator : CEntity )
	{
		super.OnInteractionDeactivated(interactionComponentName, activator);
		
		if(activator == thePlayer)
		{
			UnhighlightEntity();
		}
	}
	
	
	public final function IsEnabledInCombat() : bool
	{
		if( !lootInteractionComponent || disableLooting)
		{
			return false;
		}
		
		return lootInteractionComponent.IsEnabledInCombat();
	}
	
	public function InformClueStash()
	{
		var clueStash : W3ClueStash;
		clueStash = ( W3ClueStash )EntityHandleGet( usedByClueStash );
		if( clueStash )
		{
			clueStash.OnContainerEvent();
		}
	}
	
	event OnItemGiven(data : SItemChangedData)
	{
		super.OnItemGiven(data);
		
		if(isEnabled)
			UpdateContainer();
			
		InformClueStash();
	}
	
	function ReadSchematicsAndRecipes()
	{
	}
	
	
	event OnItemTaken(itemId : SItemUniqueId, quantity : int)
	{
		super.OnItemTaken(itemId, quantity);
		
		if(!HasQuestItem())
		{
			StopQuestItemFx();
		}
		
		InformClueStash();
	}
	
	event OnUpdateContainer()
	{
		
	}
	
	public function RequestUpdateContainer()
	{
		UpdateContainer();
	}
	
	protected final function UpdateContainer()
	{
		var medalion		: CComponent;
		var foliageComponent : CSwitchableFoliageComponent;
		var itemCategory : name;
		
		foliageComponent = ( CSwitchableFoliageComponent ) GetComponentByClassName( 'CSwitchableFoliageComponent' );
		
		if(!disableLooting)
			UpdateFactItems();
		
		if( inv && !disableLooting)
		{
			inv.UpdateLoot();
		}
		
		
		if ( !theGame.IsActive() || ( inv && !disableLooting && isEnabled && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) ) )
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( focusModeHighlight );
			}
			AddTag('HighlightedByMedalionFX');
			
			if ( foliageComponent )
				foliageComponent.SetAndSaveEntry( 'full' );
			else
				ApplyAppearance("1_full");			
				
			if( HasQuestItem() )
			{
				SetIsQuestContainer( true );
				PlayQuestItemFx();
			}
		}
		else
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( FMV_None );
			}
			
			
			if ( !isEnabled && inv && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) )
			{
				if ( foliageComponent && !disableLooting )
					foliageComponent.SetAndSaveEntry( 'full' );
				else
					ApplyAppearance("1_full");						
			}
			else
			{
				if ( foliageComponent && !disableLooting )
					foliageComponent.SetAndSaveEntry( 'empty' );
				else
					ApplyAppearance("2_empty");
			}
				
			StopQuestItemFx();
		}
		
		if ( !isMagicalObject ) 
		{
			medalion = GetComponent("Medallion");
			if(medalion)
			{
				medalion.SetEnabled( false );
			}
		}
		
		if(lootInteractionComponent)
		{
			if(disableLooting)
			{
				lootInteractionComponent.SetEnabled(false);
			}
			else
			{
				lootInteractionComponent.SetEnabled( inv && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ) ) ; 
			}
		}
		
		if(!disableLooting)
			OnUpdateContainer();
			
		CheckForDimeritium();
		CheckLock();
		
	}
	
	function RebalanceItems()
	{
		var i : int;
		var items : array<SItemUniqueId>;
	
		if( inv && !disableLooting)
		{
			inv.AutoBalanaceItemsWithPlayerLevel();
			inv.GetAllItems( items );
		}
		
		for(i=0; i<items.Size(); i+=1)
		{
			
			if ( inv.GetItemModifierInt(items[i], 'ItemQualityModified') > 0 )
					continue;
					
			inv.AddRandomEnhancementToItem(items[i]);
		}
	}
	
	protected final function HighlightEntity()
	{
		isHighlightedByMedallion = true;
	}
	
	protected final function UnhighlightEntity()
	{
		StopEffect('medalion_detection_fx');
		StopEffect('medalion_fx');
		isHighlightedByMedallion = false;
	}
	
	public final function HasQuestItem() : bool
	{
		if( !inv || disableLooting)
		{
			return false;
		}			

		return inv.HasQuestItem();
	}
	
	public function CheckForDimeritium()
	{
		if (inv && !disableLooting)
		{
			if ( inv.HasItemByTag('Dimeritium'))
			{
				if (!this.HasTag('Potestaquisitor')) this.AddTag('Potestaquisitor');
			}
			else
			{
				if (this.HasTag('Potestaquisitor')) this.RemoveTag('Potestaquisitor');
			}
		}
		else
		{
			if (this.HasTag('Potestaquisitor')) this.RemoveTag('Potestaquisitor');
		}
	}
	
	
	public final function OnTryToGiveItem( itemId : SItemUniqueId ) : bool 
	{
		return true; 
	}
	
	
	public function TakeAllItems()
	{
		var targetInv : CInventoryComponent;
		var allItems	: array< SItemUniqueId >;
		var ciriEntity  : W3ReplacerCiri;
		var i : int;
		var itemsCategories : array< name >;
		var category : name;
		
		
		targetInv = thePlayer.inv;
		
		if( !inv || !targetInv )
		{
			return;
		}
		
		inv.GetAllItems( allItems );

		LogChannel( 'ITEMS___', ">>>>>>>>>>>>>> TakeAllItems " + allItems.Size() );
		
		for(i=0; i<allItems.Size(); i+=1)
		{						
			if( inv.ItemHasTag(allItems[i], 'Lootable' ) || !inv.ItemHasTag(allItems[i], 'NoDrop') && !inv.ItemHasTag(allItems[i], theGame.params.TAG_DONT_SHOW))
			{
				inv.NotifyItemLooted( allItems[ i ] );
				
				if( inv.ItemHasTag(allItems[i], 'HerbGameplay') )
				{
					category = 'herb';
				}
				else
				{
					category = inv.GetItemCategory(allItems[i]);
				}
				
				if( itemsCategories.FindFirst( category ) == -1 )
				{
					itemsCategories.PushBack( category );
				}
				inv.GiveItemTo(targetInv, allItems[i], inv.GetItemQuantity(allItems[i]), true, false, true );
			}
		}
		if( itemsCategories.Size() == 1 )
		{
			PlayItemEquipSound(itemsCategories[0]);
		}
		else
		{
			PlayItemEquipSound('generic');
		}
		
		LogChannel( 'ITEMS___', "<<<<<<<<<<<<<< TakeAllItems");
		
		InformClueStash();
	}
	
	public function Unlock( )
	{
		if( IsNameValid(keyItemName) && removeKeyOnUse )
		{
			
			SetIsQuestContainer( true );
		}
		super.Unlock();
	}
	
	
	event OnInteraction( actionName : string, activator : CEntity )
	{
		var processed : bool;
		var i,j : int;
		var m_schematicList, m_recipeList : array< name >;
		var itemCategory : name;
		var attr : SAbilityAttributeValue;
		
		if ( activator != thePlayer || isInteractionBlocked || IsEmpty() )
			return false;
			
		if ( activator == (W3ReplacerCiri)thePlayer )
		{
			skipInventoryPanel = true;
			usedByCiri = true;
		}
		
		if ( StrLen( factOnContainerOpened ) > 0 && !FactsDoesExist ( factOnContainerOpened ) && ( actionName == "Container" || actionName == "Unlock" ) )
		{
			FactsAdd ( factOnContainerOpened, 1, -1 );
		}
		
		
		m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
		m_schematicList = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		
		if ( FactsQuerySum("NewGamePlus") > 0 )
		{
			AddWolfNewGamePlusSchematics();
			KeepWolfWitcherSetSchematics(m_schematicList);
		}
		
		
		ProcessSpoonCollector( activator );		
		
		InjectItemsOnLevels();
		
		processed = super.OnInteraction(actionName, activator);
		if(processed)
			return true;		
							
		if(actionName != "Container" && actionName != "GatherHerbs")
			return false;		
					
		ProcessLoot ();
		
		return true;
	}
	
	function RemoveUnwantedItems()
	{
		var allItems : array< SItemUniqueId >;
		var i,j : int;
		var m_schematicList, m_recipeList : array< name >;
		var itemName : name;
		
		if ( !HasTag('lootbag') )
		{
			m_recipeList     = GetWitcherPlayer().GetAlchemyRecipes();
			m_schematicList  = GetWitcherPlayer().GetCraftingSchematicsNames();

			inv.GetAllItems( allItems );
			for ( i=0; i<allItems.Size(); i+=1 )
			{
				itemName = inv.GetItemName( allItems[i] );
			


				if ( GetWitcherPlayer().GetLevel() - 1 > 1 && inv.GetItemLevel( allItems[i] ) == 1 && inv.ItemHasTag(allItems[i], 'Autogen') )
				{ 
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_steel_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_silver_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_armor_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_pants_base');
					inv.RemoveItemCraftedAbility(allItems[i], 'autogen_gloves_base');
					inv.GenerateItemLevel(allItems[i], false);
				}
				
				
				if ( inv.GetItemCategory(allItems[i]) == 'gwint' )
				{
					inv.ClearGwintCards();
				}
			}
		}
	}
	
	function ProcessLoot()
	{
		if(disableLooting)
			return;
			
		if(skipInventoryPanel || usedByCiri || ((W3Herb)this) ) 
		{
			
			if( !thePlayer.IsAnyWeaponHeld() && !thePlayer.IsHoldingItemInLHand() )
				thePlayer.RaiseEvent('LootHerb');
			

			TakeAllItems();
			OnContainerClosed();			
		}
		else
		{
			ShowLoot();
		}
	}
	
	private function KeepWolfWitcherSetSchematics(out m_schematicList : array< name >)
	{
		var index : int;
		
		
		index = m_schematicList.FindFirst('Wolf Armor schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Jacket Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Gloves schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Gloves Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Pants schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Pants Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf Boots schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Witcher Wolf Boots Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf School steel sword schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School steel sword Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
		
		index = m_schematicList.FindFirst('Wolf School silver sword schematic');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 1');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 2');
		if ( index > -1 ) m_schematicList.Erase( index );
		index = m_schematicList.FindFirst('Wolf School silver sword Upgrade schematic 3');
		if ( index > -1 ) m_schematicList.Erase( index );
	}
	
	private function AddWolfNewGamePlusSchematics()
	{
		var allItems		: array< SItemUniqueId >;
		var m_schematics	: array< name >;
		var i	 			: int;
		var itemName		: name;
		
		inv.GetAllItems( allItems );
		m_schematics  = GetWitcherPlayer().GetCraftingSchematicsNames();
		
		for ( i=0; i<allItems.Size(); i+=1 )
		{	
			itemName = inv.GetItemName( allItems[i] );
		
			
			if ( itemName == 'Wolf Armor schematic' && !inv.HasItem('NGP Wolf Armor schematic') && m_schematics.FindFirst('NGP Wolf Armor schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Armor schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Jacket Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Jacket Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Jacket Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Jacket Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Jacket Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Jacket Upgrade schematic 3', 1, true, true);
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf Gloves schematic' && !inv.HasItem('NGP Wolf Gloves schematic') && m_schematics.FindFirst('NGP Wolf Gloves schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Gloves schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Gloves Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Gloves Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Gloves Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Gloves Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Gloves Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Gloves Upgrade schematic 3', 1, true, true);
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf Pants schematic' && !inv.HasItem('NGP Wolf Pants schematic') && m_schematics.FindFirst('NGP Wolf Pants schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Pants schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Pants Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Pants Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Pants Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Pants Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Pants Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Pants Upgrade schematic 3', 1, true, true);
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf Boots schematic' && !inv.HasItem('NGP Wolf Boots schematic') && m_schematics.FindFirst('NGP Wolf Boots schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf Boots schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 1' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 1') && m_schematics.FindFirst('NGP Witcher Wolf Boots Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 2' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 2') && m_schematics.FindFirst('NGP Witcher Wolf Boots Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Witcher Wolf Boots Upgrade schematic 3' && !inv.HasItem('NGP Witcher Wolf Boots Upgrade schematic 3') && m_schematics.FindFirst('NGP Witcher Wolf Boots Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Witcher Wolf Boots Upgrade schematic 3', 1, true, true);	
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf School steel sword schematic' && !inv.HasItem('NGP Wolf School steel sword schematic') && m_schematics.FindFirst('NGP Wolf School steel sword schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School steel sword Upgrade schematic 1' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 1') && m_schematics.FindFirst('NGP Wolf School steel sword Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School steel sword Upgrade schematic 2' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 2') && m_schematics.FindFirst('NGP Wolf School steel sword Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School steel sword Upgrade schematic 3' && !inv.HasItem('NGP Wolf School steel sword Upgrade schematic 3') && m_schematics.FindFirst('NGP Wolf School steel sword Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School steel sword Upgrade schematic 3', 1, true, true);	
				SetIsQuestContainer( true );
			}
				
			if ( itemName == 'Wolf School silver sword schematic' && !inv.HasItem('NGP Wolf School silver sword schematic') && m_schematics.FindFirst('NGP Wolf School silver sword schematic') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword schematic', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School silver sword Upgrade schematic 1' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 1') && m_schematics.FindFirst('NGP Wolf School silver sword Upgrade schematic 1') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 1', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School silver sword Upgrade schematic 2' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 2') && m_schematics.FindFirst('NGP Wolf School silver sword Upgrade schematic 2') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 2', 1, true, true);
				SetIsQuestContainer( true );
			}
			if ( itemName == 'Wolf School silver sword Upgrade schematic 3' && !inv.HasItem('NGP Wolf School silver sword Upgrade schematic 3') && m_schematics.FindFirst('NGP Wolf School silver sword Upgrade schematic 3') < 0 )
			{
				inv.AddAnItem( 'NGP Wolf School silver sword Upgrade schematic 3', 1, true, true);	
				SetIsQuestContainer( true );
			}
		}
	}
	
	
	private final function ProcessSpoonCollector( activator : CEntity)
	{
		var contentsOk : bool;
		var i, weapons, armors, alchemy, food, crafting : int;
		var items : array<SItemUniqueId>;
		var owner : CActor;
		var tags : array< name >;
		
		
		
		if( spoonCollectorTested )
		{
			return;
		}
		
		
		if( !( (W3PlayerWitcher)activator ) || !GetWitcherPlayer().GetHorseManager().IsItemEquippedByName( 'q702_wicht_trophy' ) )
		{
			return;
		}
		
		spoonCollectorTested = true;
		
		
		if( HasQuestItem() || HasTag('Quest') || HasTag('quest') )
		{
			return;
		}
		
		
		if( RandF() > 0.1f )
		{
			return;
		}
		
		
		if( HasTag( 'lootbag' ) )
		{
			return;
		}		
		
		
		owner = ( ( W3ActorRemains )this ).GetOwner();		
		if( owner )
		{
			tags = owner.GetTags();
			if( tags.Contains( 'animal' ) )
			{
				return;
			}
		}
	
		
		inv.GetAllItems( items );		
		
		
		
		
		contentsOk = false;
		for( i=0; i<items.Size(); i+=1 )
		{
			if( ( inv.IsItemJunk( items[i] ) || inv.IsItemUpgrade( items[i] ) || inv.IsItemTool( items[i] ) || inv.IsItemHorseItem( items[i] ) || inv.IsItemDye( items[i] ) ) && !inv.IsItemReadable( items[i] ) )
			{
				contentsOk = true;
				break;
			}
			
			if( !weapons && inv.IsItemWeapon( items[i] ) )
			{
				weapons = 1;
			}
			else if( !armors && inv.IsItemAnyArmor( items[i] ) )
			{
				armors = 1;
			}
			else if( !alchemy && inv.IsItemAlchemyIngredient( items[i] ) )
			{
				alchemy = 1;
			}
			else if( !food && inv.IsItemFood( items[i] ) )
			{
				food = 1;
			}
			else if( !crafting && inv.IsItemCraftingIngredient( items[i] ) )
			{
				crafting = 1;
			}
			
			if( weapons + armors + alchemy + food + crafting >= 2 )
			{
				contentsOk = true;
				break;
			}			
		}
		
		if( !contentsOk )
		{
			return;
		}
		
		AddSpoons();
	}
	
	private final function AddSpoons( optional dontAddMultiple : bool )
	{
		var spoonType : int;
		var spoonName : name;
		
		spoonType = RandRange(100);
		
		if( spoonType > 70 )
		{
			spoonName = 'Spoon wooden';
		}
		else if( spoonType > 40 )
		{
			spoonName = 'Spoon wooden 2';
		}
		else if( spoonType > 30 )
		{
			spoonName = 'Spoon metal';
		}
		else if( spoonType > 20 )
		{
			spoonName = 'Spoon metal 2';
		}
		else if( spoonType > 15 )
		{
			spoonName = 'Spoon silver';
		}
		else if( spoonType > 10 )
		{
			spoonName = 'Spoon silver 2';
		}
		else if( spoonType > 5 )
		{
			spoonName = 'Spoon gold';
		}
		else
		{
			spoonName = 'Spoon gold 2';
		}
		
		inv.AddAnItem( spoonName, 1, true, true, false );
		
		
		if( !dontAddMultiple && RandRange(100) < 10 )
		{
			AddSpoons( true );
		}
	}
	
	event OnStateChange( newState : bool )
	{
		if( lootInteractionComponent )
		{
			lootInteractionComponent.SetEnabled( newState );
		}
		
		super.OnStateChange( newState );
	}
	
	
	public final function ShowLoot()
	{
		var lootData : W3LootPopupData;
		
		lootData = new W3LootPopupData in this;
		
		lootData.targetContainer = this;
		
		theGame.RequestPopup('LootPopup', lootData);
		
		
	}
	
	public function IsEmpty() : bool				{ return !inv || inv.IsEmpty( SKIP_NO_DROP_NO_SHOW ); }
	
	public function Enable(e : bool, optional skipInteractionUpdate : bool, optional questForcedEnable : bool)
	{
		if( !(e && questForcedEnable) )
		{
			
			if(e && IsEmpty() )
			{
				return;
			}
			else
			{
				UpdateContainer();
			}
		}
		
		super.Enable(e, skipInteractionUpdate);
	}
	
	
	public function OnContainerClosed()
	{
		if(!HasQuestItem())
			StopQuestItemFx();
		
		DisableIfEmpty();
	}
	
	
	protected function DisableIfEmpty() : bool
	{
		if(IsEmpty())
		{
			if( !disableFocusHighlightControl )
			{
				SetFocusModeVisibility( FMV_None );
			}
			
			RemoveTag('HighlightedByMedalionFX');
			
			
			UnhighlightEntity();
			
			
			Enable(false);
			
			
			ApplyAppearance("2_empty");
			
			if(isDynamic)
			{
				Destroy();
				return true;
			}
		}
		return false;
	}
	
	
	protected final function CheckForBonusMoney(oldMoney : int)
	{
		var money, bonusMoney : int;
		
		if( !inv )
		{
			return;
		}
		
		money = inv.GetMoney() - oldMoney;
		if(money <= 0)
		{
			return;
		}
			
		bonusMoney = RoundMath(money * CalculateAttributeValue(thePlayer.GetAttributeValue('bonus_money')));
		if(bonusMoney > 0)
		{
			inv.AddMoney(bonusMoney);
		}
	}
	
	public final function PlayQuestItemFx()
	{
		PlayEffectSingle(QUEST_HIGHLIGHT_FX);
	}
	
	public final function StopQuestItemFx()
	{
		StopEffect(QUEST_HIGHLIGHT_FX);
	}
	
	public function GetSkipInventoryPanel():bool
	{
		return skipInventoryPanel;
	}
	
	public function CanShowFocusInteractionIcon() : bool
	{
		return inv && !disableLooting && isEnabled && !inv.IsEmpty( SKIP_NO_DROP_NO_SHOW );
	}
	
	public function RegisterClueStash( clueStash : W3ClueStash )
	{
		EntityHandleSet( usedByClueStash, clueStash );
	}
}
