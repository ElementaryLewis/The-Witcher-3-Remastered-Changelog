/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskRequiredItems extends IBehTreeTask
{
	public var LeftItemType : CName;
	public var RightItemType : CName;
	
	public var chooseSilverIfPossible : bool;
	public var destroyProjectileOnDeactivate : bool;
	
	protected var combatDataStorage : CHumanAICombatStorage;
	
	private var processLeftItem : bool;
	private var processRightItem : bool;
	
	private var requiredItems : bool;
	
	private var takeBowArrow	: bool;
	private var takeBolt		: bool;

	
	private var projResourceName : string;
	private var projEntity : CEntityTemplate;
	private var bolt : W3AdvancedProjectile;
	
	

	function IsAvailable() : bool
	{
		if ( chooseSilverIfPossible && ( RightItemType == 'steelsword' || RightItemType == 'silversword' ) )
		{
			if ( WitcherRequiredItems() )
				return true;
		}
		
		return RequiredItems();
	}
	
	private function RequiredItems() : bool
	{
		var res 	: bool;
		var itemID	: SItemUniqueId;
		var i		: int;
		var items 	: array<SItemUniqueId>;
		var inventory : CInventoryComponent = GetNPC().GetInventory();
		
		res = true;
		
		processLeftItem = false;
		processRightItem = false;
		
		if ( LeftItemType != 'None' && LeftItemType != 'Any' )
		{
			processLeftItem = true;
			items = inventory.GetItemsByCategory( LeftItemType );
			
			if ( items.Size() == 0 )
			{
				items = inventory.GetItemsByTag( LeftItemType );
			}
			
			if ( items.Size() == 0 )
			{
				res = false;
				LogQuest("Cannot enter combat style. No " + LeftItemType + " found in l_weapon");
			}
			else
			{
				for ( i=0 ; i < items.Size(); i+=1 )
				{
					if ( inventory.IsItemHeld(items[i]) )
					{
						processLeftItem = false;
					}
				}
			}
			
		}
		else if ( LeftItemType != 'Any' )
		{
			itemID = inventory.GetItemFromSlot( 'l_weapon' );
			if ( inventory.IsIdValid( itemID ) && inventory.GetItemCategory(itemID) != LeftItemType )
				processLeftItem = true;
		}
		
		if ( RightItemType != 'None' && RightItemType != 'Any' )
		{
			processRightItem = true;
			items = inventory.GetItemsByCategory( RightItemType );
			
			if ( items.Size() == 0 )
			{
				items = inventory.GetItemsByTag( RightItemType );
			}
			
			if ( items.Size() == 0 )
			{
				res = false;
				LogQuest("Cannot enter combat style. No " + RightItemType + " found in r_weapon");
			}
			else
			{
				for ( i=0 ; i < items.Size(); i+=1 )
				{
					if ( inventory.IsItemHeld(items[i]) )
					{
						processRightItem = false;
					}
				}
			}
		}
		else if ( RightItemType != 'Any' )
		{
			itemID = inventory.GetItemFromSlot( 'r_weapon' );
			if ( inventory.IsIdValid( itemID ) && inventory.GetItemCategory(itemID) != RightItemType )
				processRightItem = true;
		}
		requiredItems = true;
		return res;
	}
	
	function WitcherRequiredItems() : bool
	{
		if ( GetCombatTarget().UsesEssence() )
		{
			RightItemType = 'silversword';
			if ( RequiredItems() )
			{
				GetActor().SetBehaviorVariable( 'SelectedWeapon', 1, true);
				return true;
			}
		}
		
		RightItemType = 'steelsword';
		GetActor().SetBehaviorVariable( 'SelectedWeapon', 0, true);
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !requiredItems)
			if ( !RequiredItems() )
				return BTNS_Failed;
		
		if ( LeftItemType == 'bow' )
			projResourceName = "bow_arrow";
		else if( RightItemType == 'crossbow' )
			projResourceName = "crossbow_bolt";
		
		InitializeCombatDataStorage();
		
		if ( processLeftItem || processRightItem )
		{
			combatDataStorage.SetProcessingItems(true);
		}
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC = GetNPC();
		var notWitcherSword : bool;
		var wasWaitingForItems : bool;
		
		combatDataStorage.SetProcessingItems(true);
		
		if( projResourceName != "" && !projEntity )
			projEntity = (CEntityTemplate)LoadResourceAsync(projResourceName);
		
		wasWaitingForItems = GetActor().WaitForFinishedAllLatentItemActions();
		if ( wasWaitingForItems )
		{
			if ( chooseSilverIfPossible && ( RightItemType == 'steelsword' || RightItemType == 'silversword' ) )
				WitcherRequiredItems();
			else
				RequiredItems();
		}
		
		if ( processLeftItem || processRightItem )
		{
			if ( combatDataStorage.GetActiveCombatStyle() == EBG_Combat_2Handed_Sword )
			{
				GetActor().SetBehaviorVariable( 'SelectedWeapon', 2, true);
				notWitcherSword = true;
			}
			
			if ( notWitcherSword || RightItemType != 'steelsword' || RightItemType != 'silversword' )
			{
				if ( processLeftItem && processRightItem )
					npc.SetRequiredItems('None','None');
				else if ( processLeftItem )
					npc.SetRequiredItems('None','Any');
				else if ( processRightItem )
					npc.SetRequiredItems('Any','None');
					
				npc.ProcessRequiredItems();
			}
			
			if ( LeftItemType == 'shield' )
			{
				combatDataStorage.SetProcessingRequiresIdle(true);
				npc.SetRequiredItems( LeftItemType, 'Any' );
				npc.ProcessRequiredItems();
				npc.OnProcessRequiredItemsFinish();
				combatDataStorage.SetProcessingRequiresIdle(false);
			}
			
			npc.SetRequiredItems( LeftItemType, RightItemType );
			npc.ProcessRequiredItems();
			npc.OnProcessRequiredItemsFinish();
			
			
		}
		else if ( LeftItemType == 'bow' )
		{
			TakeBowArrow();
			takeBowArrow = false;
		}
		
		combatDataStorage.SetProcessingItems(false);
		
		
		if ( LeftItemType == 'bow' )
		{
			while ( isActive )
			{
				SleepOneFrame();
				if ( takeBowArrow )
				{
					TakeBowArrow();
					takeBowArrow = false;
				}
			}
		}
		else if ( RightItemType == 'crossbow' )
		{
			while ( isActive )
			{
				SleepOneFrame();
				if ( takeBolt )
				{
					PutBoltInHand();
					takeBolt = false;
				}
			}
		}
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		combatDataStorage.SetProcessingItems(false);
		requiredItems = false;
		processLeftItem = false;
		processRightItem = false;
		
		if ( destroyProjectileOnDeactivate )
		((CHumanAICombatStorage)combatDataStorage).DetachAndDestroyProjectile();
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'TakeBowArrow' )
		{
			takeBowArrow = true;
		}
		else if ( animEventName == 'DestroyArrow' )
		{
			combatDataStorage.DetachAndDestroyProjectile();
		}
		else if ( animEventName == 'PutBoltInHand' )
		{
			takeBolt = true;
		}
		else if ( animEventName == 'PutBoltInCrossbow' )
		{
			if( bolt )
			{
				bolt.BreakAttachment();
				bolt.CreateAttachment( GetActor().GetInventory().GetItemEntityUnsafe( GetActor().GetInventory().GetItemFromSlot( 'r_weapon' ) ), 'bolt_slot' );
			}
		}
		else if ( animEventName == 'ReloadCrossbow' )
		{	
			combatDataStorage.SetProjectile( bolt );
		}
		
		else if ( animEventName == 'DestroyProjectile' )
		{
			combatDataStorage.SetProjectile( NULL );
		}
			
		return false;
	}
	
	function PutBoltInHand()
	{
		bolt = (W3ArrowProjectile)theGame.CreateEntity( projEntity, GetActor().GetWorldPosition());
		bolt.CreateAttachment( GetActor(), 'l_weapon' );
	}
	 
	function TakeBowArrow()
	{
		var arrowRot : EulerAngles;
		var arrowPos : Vector;
		var arrow : W3ArrowProjectile;
		var inv : CInventoryComponent;
		
		if ( !projEntity )
			return;
		if ( combatDataStorage.GetProjectile() )
			return;
		
		arrow = (W3ArrowProjectile)theGame.CreateEntity( projEntity, GetActor().GetWorldPosition());
		
		if( LeftItemType == 'bow' )
			arrow.CreateAttachment(GetActor(), 'r_weapon_arrow');
		else if( RightItemType == 'crossbow' )
		{
			inv = GetActor().GetInventory();
			arrow.CreateAttachment( inv.GetItemEntityUnsafe( inv.GetItemFromSlot( 'r_weapon' ) ), 'bolt_slot' );
		}
		
		combatDataStorage.SetProjectile(arrow);
	}
	
	function OnGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'TakeBowArrow' && LeftItemType == 'bow' )
		{
			InitializeCombatDataStorage();
			if ( !combatDataStorage.GetProjectile() )
				takeBowArrow = true;
		}
		return false;
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBehTreeTaskRequiredItemsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskRequiredItems';

	
	editable var LeftItemType : CBehTreeValCName;
	
	editable inlined var RightItemType : CBehTreeValCName;
	
	editable var chooseSilverIfPossible : CBehTreeValBool;
	
	editable var destroyProjectileOnDeactivate : bool;
	
	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToAnimEvents.PushBack( 'DestroyArrow' );
		listenToAnimEvents.PushBack( 'TakeBowArrow' );
	}
}




class IBehTreeTaskProcessProjectile extends IBehTreeTask
{
	public var destroyProjectileOnDeactivate : bool;
	
	protected var combatDataStorage : CHumanAICombatStorage;
	
	protected var takeProjectile : bool;
	protected var projTemplate : CEntityTemplate;
	
	function OnDeactivate()
	{
		if ( destroyProjectileOnDeactivate )
		{
			InitializeCombatDataStorage();
			((CHumanAICombatStorage)combatDataStorage).DetachAndDestroyProjectile();
		}
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'DestroyProjectile' )
		{
			InitializeCombatDataStorage();
			combatDataStorage.SetProjectile( NULL );
		}
		return false;
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

abstract class IBehTreeTaskProcessProjectileDef extends IBehTreeTaskDefinition
{
	editable var destroyProjectileOnDeactivate : bool;
	editable var projTemplate : CEntityTemplate;
	
}


class CBehTreeTaskProcessArrows extends IBehTreeTaskProcessProjectile
{
	latent function Main() : EBTNodeStatus
	{
		while ( isActive )
		{
			SleepOneFrame();
			if ( takeProjectile )
			{
				TakeBowArrow();
				takeProjectile = false;
			}
		}
		
		return BTNS_Active;
	}

	function OnListenedGameplayEvent( eventName : name ) : bool
	{
		if ( eventName == 'TakeBowArrow' )
		{
			InitializeCombatDataStorage();
			if ( !combatDataStorage.GetProjectile() )
			{
				takeProjectile = true;
			}
		}
		if ( eventName == 'DestroyArrow' )
		{
			InitializeCombatDataStorage();
			combatDataStorage.DetachAndDestroyProjectile();
		}
		return false;
	}
	
	function TakeBowArrow()
	{
		var arrowRot : EulerAngles;
		var arrowPos : Vector;
		var arrow : W3ArrowProjectile;
		var inv : CInventoryComponent;
		
		InitializeCombatDataStorage();
		
		if ( !projTemplate || combatDataStorage.GetProjectile() )
		{
			return;
		}	
		
		arrow = (W3ArrowProjectile)theGame.CreateEntity( projTemplate, GetActor().GetWorldPosition());
		
		arrow.CreateAttachment(GetActor(), 'r_weapon_arrow');
		
		combatDataStorage.SetProjectile(arrow);
	}
}

class CBehTreeTaskProcessArrowsDef extends IBehTreeTaskProcessProjectileDef
{
	default instanceClass = 'CBehTreeTaskProcessArrows';

	function InitializeEvents()
	{
		super.InitializeEvents();
		listenToAnimEvents.PushBack( 'DestroyArrow' );
		listenToAnimEvents.PushBack( 'TakeBowArrow' );
	}
}




class CBehTreeTaskProcessCrossbowBolts extends IBehTreeTaskProcessProjectile
{
	protected var bolt : W3AdvancedProjectile;
	
	latent function Main() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
	
		while ( isActive )
		{
			SleepOneFrame();
			if ( takeProjectile )
			{
				PutBoltInHand();
				takeProjectile = false;
			}
		}
		
		return BTNS_Active;
	}
	
	function OnAnimEvent( animEventName : name, animEventType : EAnimationEventType, animInfo : SAnimationEventAnimInfo ) : bool
	{
		if ( animEventName == 'PutBoltInHand' )
		{
			takeProjectile = true;
		}
		else if ( animEventName == 'PutBoltInCrossbow' )
		{
			if( bolt )
			{
				bolt.BreakAttachment();
				bolt.CreateAttachment( GetActor().GetInventory().GetItemEntityUnsafe( GetActor().GetInventory().GetItemFromSlot( 'r_weapon' ) ), 'bolt_slot' );
			}
		}
		else if ( animEventName == 'ReloadCrossbow' )
		{	
			combatDataStorage.SetProjectile( bolt );
		}
			
		return super.OnAnimEvent( animEventName, animEventType, animInfo );
	}
	
	function PutBoltInHand()
	{
		bolt = (W3ArrowProjectile)theGame.CreateEntity( projTemplate, GetActor().GetWorldPosition());
		bolt.CreateAttachment( GetActor(), 'l_weapon' );
		
		if( GetActor().HasTag( 'tracks_bolts' ) )
			bolt.AddTag( 'tracked_bolt' );
	}
}

class CBehTreeTaskProcessCrossbowBoltsDef extends IBehTreeTaskProcessProjectileDef
{
	default instanceClass = 'CBehTreeTaskProcessCrossbowBolts';
}




class CBehTreeTaskSheathWeapons extends IBehTreeTask
{
	private var processLeftItem : bool;
	private var processRightItem : bool;
	
	function OnActivate() : EBTNodeStatus
	{
		if ( !GetNPC().IsHuman() || GetActor() == thePlayer )
			return BTNS_Active;
		
		ShouldProcessItems();
		
		return BTNS_Active;
	}
	
	private function ShouldProcessItems()
	{
		var itemID	: SItemUniqueId;
		var i		: int;
		var items 	: array<SItemUniqueId>;
		var inventory : CInventoryComponent ;
		
		if ( !processLeftItem || !processRightItem )
		{
			inventory = GetActor().GetInventory();
			
			itemID = inventory.GetItemFromSlot( 'l_weapon' );
			
			if ( inventory.IsItemWeapon(itemID) )
				processLeftItem = true;
				
				
			itemID = inventory.GetItemFromSlot( 'r_weapon' );
			if ( inventory.IsItemWeapon(itemID) )
				processRightItem = true;
		}
		
		
		if ( processLeftItem && processRightItem )
		{
			GetActor().SetRequiredItems('None','None');
		}
		else if ( processLeftItem )
		{
			GetActor().SetRequiredItems('None','Any');
		}
		else if ( processRightItem )
		{
			GetActor().SetRequiredItems('Any','None');
		}
	}
	
	latent function Main() : EBTNodeStatus
	{
		var wasWaitingForItems : bool;
		var npc : CNewNPC = GetNPC();
		
		wasWaitingForItems = npc.WaitForFinishedAllLatentItemActions();
		
		if ( processLeftItem || processRightItem )
		{
			if ( wasWaitingForItems )
				ShouldProcessItems();
				
			if ( processLeftItem || processRightItem )
			{
				Sleep(0.1);
				npc.ProcessRequiredItems();
				npc.OnProcessRequiredItemsFinish();
			}
		}
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		processLeftItem = false;
		processRightItem = false;
	}
}

class CBehTreeTaskSheathWeaponsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskSheathWeapons';
}




class CBehTreeTaskConditionalSheathWeapons extends CBehTreeTaskSheathWeapons
{
	protected var reactionDataStorage 	: CAIStorageReactionData;
	
	function OnActivate() : EBTNodeStatus
	{
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		Sleep(0.1f);
		return DelayedActivate();
	}
	
	function DelayedActivate() : EBTNodeStatus
	{
		var res 	: bool;
		var itemID	: SItemUniqueId;
		var i		: int;
		var items 	: array<SItemUniqueId>;
		var npc 	: CNewNPC;
		var inventory : CInventoryComponent;
		
		
		npc = GetNPC();
		
		reactionDataStorage.ResetAttitudes(npc);
		
		if ( npc.GetNPCType() != ENGT_Guard && !npc.IsAtWork())
			return super.OnActivate();
		else
		{
			inventory = npc.GetInventory();
			itemID = inventory.GetItemFromSlot('r_weapon');
			
			if ( inventory.IsIdValid( itemID ) )
			{
				npc.OnEquippedItem(inventory.GetItemCategory(itemID),'r_weapon');
			}
			
			itemID = inventory.GetItemFromSlot('l_weapon');
			
			if ( inventory.IsIdValid( itemID ) )
			{
				npc.OnEquippedItem(inventory.GetItemCategory(itemID),'l_weapon');
			}
			
			
			return BTNS_Active;
		}
	}
	
	function Initialize()
	{
		reactionDataStorage = (CAIStorageReactionData)RequestStorageItem( 'ReactionData', 'CAIStorageReactionData' );
	}
}

class CBehTreeTaskConditionalSheathWeaponsDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskConditionalSheathWeapons';
}
