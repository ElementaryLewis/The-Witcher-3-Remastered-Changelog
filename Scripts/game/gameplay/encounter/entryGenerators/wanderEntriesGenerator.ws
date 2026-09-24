/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SWanderEntryGeneratorParam
{
	editable var qualityMin				: int; default qualityMin = 1;
	editable var qualityMax				: int; default qualityMax = 1;	
	editable var creatureDefinition		: SCreatureDefinitionWrapper;
	editable var spawnWayPointTag 		: TagList;
	editable var wanderPointsGroupTag 	: name;
}

class CWanderEntryGenerator extends CSpawnTreeBaseEntryGenerator
{
	function GetFriendlyName() : string { return "Wander Entries"; }
	
	editable var entries : array< SWanderEntryGeneratorParam >;
	
	function GenerateEntries()
	{
		var i, size 	: int;
		var entryNode 	: CCreatureEntry;
		var initializer	: CSpawnTreeInitializerSmartWanderAI;
		
		size = entries.Size();
		
		for( i = 0; i<size; i+=1 )
		{
			entryNode = new CCreatureEntry in this;			
			AddNodeToTree( entryNode, NULL );
			entryNode.nodeName = nodeName;
			ApplyCreatureEntryCfg( entryNode, entries[i] );
			
			initializer = new CSpawnTreeInitializerSmartWanderAI in entryNode;
			AddInitializerToNode( initializer, entryNode );
			ApplyWanderInitializerCfg( initializer, entries[i] );
			
		}
	}
	
	function ApplyCreatureEntryCfg( cEntry : CCreatureEntry, cfg : SWanderEntryGeneratorParam )
	{
		cEntry.quantityMin			= cfg.qualityMin;
		cEntry.quantityMax 			= cfg.qualityMax;	
		cEntry.baseSpawner.tags 	= cfg.spawnWayPointTag;
		cEntry.creatureDefinition	= cfg.creatureDefinition.creatureDefinition;
	}
	
	function ApplyWanderInitializerCfg( initializer : CSpawnTreeInitializerSmartWanderAI, cfg : SWanderEntryGeneratorParam )
	{
		var tree : CAIWanderWithHistory;
		
		tree = ( (CAIWanderWithHistory)initializer.ai.idleTree );
		tree.params.wanderPointsGroupTag	= cfg.wanderPointsGroupTag;	
	}
}