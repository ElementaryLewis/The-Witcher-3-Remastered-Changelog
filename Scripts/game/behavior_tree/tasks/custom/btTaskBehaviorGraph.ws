/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBehTreeTaskBehaviorGraph extends IBehTreeTask
{
	public var graph : EBehaviorGraph;
	public var forceHighPriority : bool;
	
	private var res : bool;
	private var graphName : name;
	
	protected var combatDataStorage : CHumanAICombatStorage;
	
	final function Evaluate() : int
	{
		if( !IsAvailable() )
		{
			return -1;
		}
		
		if ( forceHighPriority )
			return 100;
			
		if ( combatDataStorage )
			return combatDataStorage.CalculateCombatStylePriority(graph);
			
		return 50;
	}
	
	final function IsAvailable() : bool
	{
		InitializeCombatDataStorage();
		
		if ( !combatDataStorage )
		{
			return true;
		}
		
		if ( combatDataStorage.GetActiveCombatStyle() == graph && !combatDataStorage.IsLeavingStyle() )
		{
			return true;
		}
		else if ( GetNPC().CanChangeBehGraph() )
		{
			return true;
		}
		
		return false;
	}
	
	function OnActivate() : EBTNodeStatus
	{
		InitializeCombatDataStorage();
		
		graphName = BehGraphEnumToName(graph);
		
		if ( !IsNameValid(graphName) )
		{
			LogAssert(false,"Combat Behavior undefined!!!" + graphName);
			return BTNS_Failed;
		}
		
		if ( graph != EBG_Combat_Bow )
		{
			combatDataStorage.DetachAndDestroyProjectile();
		}
		
		GetNPC().SetBehaviorMimicVariable( 'gameplayMimicsMode', (float)(int)GMM_Combat );
		
		return BTNS_Active;
	}
	
	latent function Main() : EBTNodeStatus
	{
		var npc : CNewNPC;
		var MACName : string;
		
		if ( combatDataStorage.GetActiveCombatStyle() == graph && GetNPC().GetBehaviorGraphInstanceName() == graphName )
		{
			return BTNS_Active;
		}
		
		if ( graph == EBG_Combat_Undefined )
		{
			LogAssert(false,"Combat Behavior undefined!!!" + graphName);
			return BTNS_Failed;
		}
		
		if ( GetNPC().GetBehaviorGraphInstanceName() == graphName )
		{
			res = true;
		}
		else
		{
			res = GetNPC().ActivateAndSyncBehavior(graphName);
			
			if ( !res )
			{
				LogAssert(res,"Couldn't ActivateAndSyncBehavior " + graphName);
				return BTNS_Failed;
			}
		}
		
		npc = GetNPC();
		npc.SetCurrentFightStage();
		
		
		combatDataStorage.SetActiveCombatStyle( graph );
		
		
		
		MACName = npc.GetMovingAgentComponent().GetName();
		if ( MACName == "dwarf_base" )
			npc.SetBehaviorVariable( 'temp_use_dwarf_skeleton',1.0);	
		else if ( MACName == "wild_hunt_base" )
			npc.SetBehaviorVariable( 'useWildHuntSkeleton',1.0);
		else if ( MACName == "woman_base" )
			npc.SetBehaviorVariable( 'temp_use_woman_skeleton',1.0);
		
		
		if ( graph == EBG_Combat_1Handed_Any || graph == EBG_Combat_2Handed_Any )
			FillWeaponSubTypeBasedOnHeldItem();
		else
			GetNPC().SetBehaviorVariable( 'weaponSubType', combatDataStorage.ReturnWeaponSubTypeForActiveCombatStyle() );
		
		return BTNS_Active;
	}
	
	latent function FillWeaponSubTypeBasedOnHeldItem()
	{
		var itemId : SItemUniqueId;
		var inv : CInventoryComponent;
		var itemTags : array<name>;
		
		inv = GetActor().GetInventory();
		
		
		while ( !inv.IsIdValid(itemId) )
		{
			itemId = inv.GetItemFromSlot('r_weapon');
			SleepOneFrame();
		}
		
		inv.GetItemTags(itemId, itemTags);
		
		if ( itemTags.Contains('1handedWeapon') )
		{
			if ( itemTags.Contains('axe1h') )
				GetActor().SetBehaviorVariable( 'weaponSubType', (int)EWST1H_Axe );
			else if ( itemTags.Contains('blunt1h') )
				GetActor().SetBehaviorVariable( 'weaponSubType', (int)EWST1H_Blunt );
			else
				GetActor().SetBehaviorVariable( 'weaponSubType', 0.f );
		}
		else if ( itemTags.Contains('2handedWeapon') )
		{
			if ( itemTags.Contains('axe2h') )
				GetActor().SetBehaviorVariable( 'weaponSubType', (int)EWST2H_Axe );
			else if ( itemTags.Contains('hammer2h') )
				GetActor().SetBehaviorVariable( 'weaponSubType', (int)EWST2H_Hammer );
			else if ( itemTags.Contains('halberd2h') )
				GetActor().SetBehaviorVariable( 'weaponSubType', (int)EWST2H_Halberd );
			else if ( itemTags.Contains('spear2h') )
				GetActor().SetBehaviorVariable( 'weaponSubType', (int)EWST2H_Spear );
			else
				GetActor().SetBehaviorVariable( 'weaponSubType', 0.f );
		}
	}
	
	function InitializeCombatDataStorage()
	{
		if ( !combatDataStorage )
		{
			combatDataStorage = (CHumanAICombatStorage)InitializeCombatStorage();
		}
	}
}

class CBehTreeBehaviorGraphDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBehTreeTaskBehaviorGraph';

	editable inlined var graph : CBTEnumBehaviorGraph;
	editable var forceHighPriority : CBehTreeValBool;
	}

