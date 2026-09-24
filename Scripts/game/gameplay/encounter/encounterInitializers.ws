/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class ISpawnTreeInitializer extends CObject
{
};

import class CSpawnTreeInitializerSetAppearance extends ISpawnTreeInitializer
{
	import var appearanceName 			: name;	
	import var onlySetOnSpawnAppearance : bool;
}

import class CSpawnTreeInitializerAddTag extends ISpawnTreeInitializer
{
	import final function AddTag( tag : name );
	import var onlySetOnSpawnAppearance : bool;
}

import abstract class ISpawnTreeScriptedInitializer extends ISpawnTreeInitializer
{
	function Init( actor : CActor ) : bool
	{
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		return "Abstract Scripted initializer";
	}
};

import abstract class ISpawnTreeInitializerAI extends ISpawnTreeInitializer
{
	
	import protected var dynamicTreeParameterName : name;		
	function Init()
	{
	}
};


import class CSpawnTreeInitializerIdleAI extends ISpawnTreeInitializerAI
{
	editable inlined var ai : CAIIdleRedefinitionParameters;
	default dynamicTreeParameterName = 'idleTree';
	function Init()
	{
		ai = new CAIIdleRedefinitionParameters in this;
		ai.OnCreated();
	}
};

import class ISpawnTreeInitializerGuardAreaBase extends ISpawnTreeInitializer
{
	import var pursuitRange 	: float;
};

import class CSpawnTreeInitializerGuardArea extends ISpawnTreeInitializerGuardAreaBase
{
	import var guardAreaTag 	: name;
	import var pursuitAreaTag 	: name;
};

import class CSpawnTreeInitializerGuardAreaByHandle extends ISpawnTreeInitializerGuardAreaBase
{
	import var guardArea		: EntityHandle;
	import var pursuitArea		: EntityHandle;
};

import class CSpawnTreeInitializerRiderIdleAI extends ISpawnTreeInitializerAI
{
	editable inlined var ai : CAIRiderIdleRedefinitionParameters;
	default dynamicTreeParameterName = 'riderIdleTree';
	function Init()
	{
		ai = new CAIRiderIdleRedefinitionParameters in this;
		ai.OnCreated();
	}
};


import class CSpawnTreeInitializerIdleFlightAI extends ISpawnTreeInitializerAI
{
	editable inlined var ai : CAIFlightIdleRedefinitionParameters;
	default dynamicTreeParameterName = 'freeFlight';
	function Init()
	{
		ai = new CAIFlightIdleRedefinitionParameters in this;
		ai.OnCreated();
	}
};


import abstract class CSpawnTreeInitializerBaseStartingBehavior extends ISpawnTreeInitializerAI
{
}

import class CSpawnTreeInitializerStartingBehavior extends CSpawnTreeInitializerBaseStartingBehavior
{
	editable inlined var ai : CAIStartingBehaviorParameters;
	default dynamicTreeParameterName = 'startingBehavior';
	function Init()
	{
		ai = new CAIStartingBehaviorParameters in this;
		ai.OnCreated();
	}
};

import class CSpawnTreeInitializerRiderStartingBehavior extends CSpawnTreeInitializerBaseStartingBehavior
{
	editable inlined var ai : CAIRiderStartingBehaviorParameters;
	default dynamicTreeParameterName = 'startingBehavior';
	function Init()
	{
		ai = new CAIRiderStartingBehaviorParameters in this;
		ai.OnCreated();
	}
};

import abstract class ISpawnTreeInitializerIdleSmartAI extends CSpawnTreeInitializerIdleAI
{
	import protected var subInitializer : ISpawnTreeInitializer;

	function GetObjectForPropertiesEdition() : IScriptable
	{
		return NULL;
	}
	function GetEditorFriendlyName() : string
	{
		return "Abstract Smart idle AI";
	}
	function GetSubInitializerClassName() : name
	{
		return '';
	}
	function GetContextMenuSpecialOptions( out names : array< string > )
	{
	}
	function RunSpecialOption( option : int )
	{
	}
};

class CAICommunityRedefinitionParameters extends CAIIdleRedefinitionParameters
{
	editable var useDefaultIdleBehaviors 	: bool;
	editable var canFlyInIdle 				: bool;
	
	default useDefaultIdleBehaviors = false;
	default canFlyInIdle 			= false;
};

import class ISpawnTreeInitializerCommunityAI extends ISpawnTreeInitializerAI
{
	editable inlined var ai : CAIRedefinitionParameters;

	function Init()
	{
		var params 		: CAINpcWorkIdleParams;
		var newAi 		: CAIMultiRedefinitionParameters;
		var subparams 	: array< CAIRedefinitionParameters >;
		var idleAI 		: CAICommunityRedefinitionParameters;
		var combatAI 	: CAICombatDecoratorRedefinitionParameters;
		var workIdle 	: CAINpcWorkIdle;
		
		super.Init();
		
		
		idleAI = new CAICommunityRedefinitionParameters in this;
		idleAI.OnCreated();
		workIdle = new CAINpcWorkIdle in this;
		idleAI.idleTree = workIdle;
		workIdle.OnCreated();		
		
		workIdle.actionPointSelector = new CCommunityActionPointSelector in workIdle;
		
		
		combatAI = new CAICombatDecoratorRedefinitionParameters in this;
		combatAI.OnCreated();
		combatAI.combatDecorator = new CAICombatDecoratorCommunity in this;
		combatAI.combatDecorator.OnCreated();
		combatAI.OnManualRuntimeCreation();
		
		
		newAi = new CAIMultiRedefinitionParameters in this;
		newAi.OnCreated();
		newAi.subParams.Resize( 2 );
		newAi.subParams[ 0 ] = idleAI;
		newAi.subParams[ 1 ] = combatAI;
		newAi.OnManualRuntimeCreation();
		
		ai = newAi;
		
	}
};

class CSpawnTreeInitializerSmartWorkAI extends ISpawnTreeInitializerIdleSmartAI
{
	function GetObjectForPropertiesEdition() : IScriptable
	{
		if ( ai && (CAINpcWorkIdle)ai.idleTree )	
		{
			return (CAINpcWorkIdle)ai.idleTree;
		}
		return this;
	}
	function GetEditorFriendlyName() : string
	{
		return "Work SmartAI";
	}
	function Init()
	{
		super.Init();
		
		ai.idleTree = new CAINpcWorkIdle in this;
		ai.idleTree.OnCreated();
	}
	function GetSubInitializerClassName() : name
	{
		return 'CSpawnTreeInitializerActionpointSpawner';
	}
	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		if ( subInitializer )
		{
			names.PushBack( "Update spawner" );
		}
		else
		{
			names.PushBack( "Default spawner" );
		}
		
	}
	
	function CreateSpawner( visibility : ESpawnTreeSpawnVisibility )
	{
		var spawner : CSpawnTreeInitializerActionpointSpawner;
		var workTree : CAINpcWorkIdle;
		var selector : CSimpleActionPointSelector;
		
		if ( !ai )
		{
			return;
		}
		
		workTree = (CAINpcWorkIdle)ai.idleTree ;
		if ( !workTree )
		{
			return;
		}
		selector = ( CSimpleActionPointSelector )workTree.actionPointSelector;
		if ( !selector )
		{
			return;
		}
		
		if ( subInitializer )
		{
			spawner = (CSpawnTreeInitializerActionpointSpawner) subInitializer;
		}
		else
		{
			spawner = new CSpawnTreeInitializerActionpointSpawner in this;
			subInitializer = spawner;
		}
		spawner.spawner.categories = selector.categories;
		spawner.spawner.tags = selector.apTags;
		spawner.spawner.visibility = visibility;
	}
	
	function RunSpecialOption( option : int )
	{
		CreateSpawner( STSV_SPAWN_HIDEN );
	}
};

class CSpawnTreeInitializerSmartWanderAndWorkAI extends ISpawnTreeInitializerIdleSmartAI
{
	function GetObjectForPropertiesEdition() : IScriptable
	{
		if ( ai &&  (CAINpcActiveIdle)ai.idleTree  )
		{
			return (CAINpcActiveIdle)ai.idleTree;
		}
		return this;
	}
	function GetEditorFriendlyName() : string
	{
		return "WanderAndWork SmartAI";
	}
	function Init()
	{
		super.Init();
		
		ai.idleTree = new CAINpcActiveIdle in this;
		ai.idleTree.OnCreated();
	}
};

class CSpawnTreeInitializerSmartWanderAI extends ISpawnTreeInitializerIdleSmartAI
{
	function GetObjectForPropertiesEdition() : IScriptable
	{
		if ( ai && ( (CAIWanderWithHistory)ai.idleTree ) )
		{
			return (CAIWanderWithHistory)ai.idleTree;
		}
		return this;
	}
	function GetEditorFriendlyName() : string
	{
		return "Wanderpoints SmartAI";
	}
	function Init()
	{
		super.Init();
		
		ai.idleTree = new CAIWanderWithHistory in this;
		ai.idleTree.OnCreated();
	}
};

class CSpawnTreeInitializerSmartDynamicWanderAI extends ISpawnTreeInitializerIdleSmartAI
{
	function GetObjectForPropertiesEdition() : IScriptable
	{
		if ( ai && (CAIDynamicWander)ai.idleTree )
		{
			return (CAIDynamicWander)ai.idleTree;
		}
		return this;
	}
	function GetEditorFriendlyName() : string
	{
		return "AreaWander SmartAI";
	}
	function Init()
	{
		super.Init();
		
		ai.idleTree = new CAIDynamicWander in this;
		ai.idleTree.OnCreated();
	}
};

 class ISpawnTreeCreatePortalEntityInitializer extends ISpawnTreeScriptedInitializer
{
	editable var entityToCreate					: CEntityTemplate;
	editable var spawnOffset					: Vector;
	
	function Init( actor : CActor ) : bool
	{
		var portal : W3OnSpawnPortal;
		var portalPos : Vector;
		
		if ( entityToCreate )
		{
			portalPos = actor.GetWorldPosition() + spawnOffset;
			
			portal = (W3OnSpawnPortal)theGame.CreateEntity( entityToCreate, portalPos, actor.GetWorldRotation() );
			portal.HideCreature( actor );
			return true;
		}
		else
		{
			return false;
		}
	
	}
	function GetEditorFriendlyName() : string
	{
		return "Spawn portal entity";
	}
};

class ISpawnAnimEntityInitializer extends ISpawnTreeScriptedInitializer
{
	editable var forceSpawnAnim	: int;
	
	function Init( actor : CActor ) : bool
	{
		actor.SetBehaviorVariable('ForcedSpawnAnim', forceSpawnAnim);
		
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		var l_Name : string;
		l_Name = "Force Spawn Anim";
		
		if( forceSpawnAnim > 0 )
		{
			l_Name = "Force Spawn Anim: " + forceSpawnAnim ;
		}
		
		return l_Name;
	}
};


 class ISpawnTreeSpawnAroundNodeInitializer extends ISpawnTreeScriptedInitializer
{
	editable var spawnRadiousMin		: float; default spawnRadiousMin = 5.f;
	editable var spawnRadiousMAx		: float; default spawnRadiousMAx = 10.f;
	editable var spawnNodeTag			: name; default spawnNodeTag = 'PLAYER';
	var spawnNode						: CNode;
	
	function Init( actor : CActor ) : bool
	{
		var spawnPos 	: Vector;
		var safePos 	: Vector;
		var node 		: CNode;
		var spawnOffset : Vector;
		var rand		: int;
		var offset : float;
		
		spawnOffset.X =	RandRangeF ( spawnRadiousMAx+1, spawnRadiousMin  );
		spawnOffset.Y =	RandRangeF ( spawnRadiousMAx+1, spawnRadiousMin );
		
		actor.SetVisibility(false);
		
		spawnNode = theGame.GetNodeByTag ( spawnNodeTag );
		
		rand = RandRange ( 2, 0 );
		if( rand == 1 )
		{
			spawnOffset.X *= -1; 
		}
		rand = RandRange ( 2, 0 );
		if( rand == 1 )
		{
			spawnOffset.Y *= -1; 
		}
				
		spawnPos = spawnNode.GetWorldPosition() + spawnOffset;
		
			
		if ( theGame.GetWorld().NavigationFindSafeSpot( spawnPos, 0.5, 5.f, safePos ) )
		{
			actor.Teleport ( safePos );
			actor.SetVisibility(true);
			return true;
		}	
		else
		{
			actor.SetVisibility(true);
			return false;
		}
	
	}
	function GetEditorFriendlyName() : string
	{
		return "Spawn Around Node";
	}
};

class ISpawnTreeSetLootInitializer extends ISpawnTreeScriptedInitializer
{
	editable var lootDefinitions	: array <SR4LootNameProperty>;
	editable var overrideLoot		: bool;
	editable var randomize			: bool; default randomize = true;
	
	
	var inventory 					: CInventoryComponent;
	var i							: int;
	var rand 						: int;
	var randRange					: int;
	
	function Init( actor : CActor ) : bool
	{
		inventory = actor.GetInventory();
		
		if ( randomize )
		{
			randRange = lootDefinitions.Size();
			
			rand = RandRange (randRange );
		
			inventory.AddItemsFromLootDefinition ( lootDefinitions[rand].lootName );
			
			if ( overrideLoot )
			{
				inventory.EnableLoot ( false );
			}
		}
		else
		{
			for ( i=0; i < lootDefinitions.Size(); i+=1 )
			{
				inventory.AddItemsFromLootDefinition ( lootDefinitions[i].lootName );
			}
			if ( overrideLoot )
			{
				inventory.EnableLoot ( false );
			}
		}
		
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		return "Set Loot";
	}
};


class ISpawnTreeAddItemInitializer extends ISpawnTreeScriptedInitializer
{
	editable var items	 : array <SItemExt>;
	editable var randomize	 : bool; default randomize = false;
	editable var equip	 : bool;
	editable var checkIfItemsAlreadyAdded : bool; default checkIfItemsAlreadyAdded = true;


	var inventory : CInventoryComponent;
	var i	 : int;
	var rand : int;
	var randRange	 : int;
	var itemsIDs : array<SItemUniqueId>;
	var possesedItemsCount	 : int;
	var itemsToAddCount	 : int;

	function Init( actor : CActor ) : bool
	{
		var itemToEquipID : SItemUniqueId;

		inventory = actor.GetInventory();

		if ( randomize )
		{
			randRange = items.Size();

			rand = RandRange (randRange );
				
			if ( checkIfItemsAlreadyAdded )
			{
				possesedItemsCount = inventory.GetItemQuantityByName ( items[rand].itemName.itemName );
			}
			
			itemsToAddCount = items[rand].quantity - possesedItemsCount;
			
			if ( itemsToAddCount > 0 )
			{
				itemsIDs =  inventory.AddAnItem( items[rand].itemName.itemName, items[rand].quantity );
				itemToEquipID = itemsIDs[rand];
			}
			
		}
		else
		{
			for ( i=0; i < items.Size(); i+=1 )
			{
				if ( checkIfItemsAlreadyAdded )
				{
					possesedItemsCount = inventory.GetItemQuantityByName ( items[i].itemName.itemName );
				}
				
				itemsToAddCount = items[i].quantity - possesedItemsCount;
				
				if ( itemsToAddCount > 0 )
				{
					itemsIDs = inventory.AddAnItem( items[i].itemName.itemName, items[i].quantity );
				}
			}
			itemToEquipID = itemsIDs[0];
			
		}
		if ( equip )
		{
			actor.EquipItem ( itemToEquipID );
		}
		
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		return "Add Item";
	}
};

class ISpawnAddAbilityInitializer extends ISpawnTreeScriptedInitializer
{
	editable var remove		 : bool;
	editable var abulities	 : array <name>;
			 var abilityName : name;
			 var i			 : int;
	
	function Init( actor : CActor ) : bool
	{
		for ( i=0; i< abulities.Size(); i+=1 )
		{
			abilityName = abulities[i];
			if ( remove )
			{
				actor.RemoveAbility ( abilityName );
			}
			else
			{
				actor.AddAbility ( abilityName );
			}
		}
		
		
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		var l_Name : string;
		l_Name = "Add Ability";
		
		return l_Name;
	}
};

class ISpawnSetNPCLevelInitializer extends ISpawnTreeScriptedInitializer
{
	editable var level	 : int;
	
	function Init( actor : CActor ) : bool
	{
		var npc : CNewNPC;
		
		npc = (CNewNPC)actor;
		if ( npc )
		{
			npc.SetLevel ( level );
		}
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		var l_Name : string;
		l_Name = "Set NPC level";
		
		return l_Name;
	}
};

class ISpawnAddNPCLevelInitializer extends ISpawnTreeScriptedInitializer
{
	editable var level	 : int;
	
	function Init( actor : CActor ) : bool
	{
		var npc : CNewNPC;
		var currLevel : int;
		
		npc = (CNewNPC)actor;
		if ( npc )
		{
			currLevel = npc.GetLevel();
			
			npc.SetLevel ( currLevel + level );
		}
		return true;
	}
	function GetEditorFriendlyName() : string
	{
		var l_Name : string;
		l_Name = "Add NPC level";
		
		return l_Name;
	}
};

