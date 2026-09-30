/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CSpawnTreeInitializerCarryItemWanderAI extends ISpawnTreeInitializerIdleSmartAI
{
	function GetObjectForPropertiesEdition() : IScriptable
	{
		if ( ai && ( (CAICarryingItems)ai.idleTree ) && ( (CAICarryingItems)ai.idleTree ).params )
		{
			return ( (CAICarryingItems)ai.idleTree ).params;
		}
		return this;
	}
	function GetEditorFriendlyName() : string
	{
		return "Carrying items";
	}
	function Init()
	{
		super.Init();
		
		ai.idleTree = new CAICarryingItems in this;
		ai.idleTree.OnCreated();
	}
};

class CAICarryingItems extends CAIWanderTree
{
	default aiTreeName = "resdef:ai\idle/npc_carrying_items";
	
	editable inlined var params : CAICarryingItemsParams;
	
	function Init()
	{
		params = new CAICarryingItemsParams in this;
		params.OnCreated();
	}
};


class CAICarryingItemsParams extends CAINpcWanderParams
{	
	editable var storePointTag			: name;
	editable var carryingArea 			: EntityHandle;
	editable var dropItemOnDeactivation : bool;
	
	function Init()
	{
		super.Init();
	}
}