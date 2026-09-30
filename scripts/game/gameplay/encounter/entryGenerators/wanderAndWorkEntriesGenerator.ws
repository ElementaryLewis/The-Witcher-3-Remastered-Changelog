/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
struct SWanderWorkCetegoriesForCreatureDefinitionEntryGeneratorParam
{
	editable var creatureDefinition	: SCreatureDefinitionWrapper;
	editable var categories			: array< SEncounterActionPointSelectorPairScr >;
}


struct SWanderAndWorkEntryGeneratorCommon
{
	editable inlined var wanderParams 	: CAINpcHistoryWanderParams;
	editable var spawnToWork	: bool;
	editable var delay			: float;
}


import struct SWanderAndWorkEntryGeneratorParams
{
	import editable var creatureEntry 	: SCreatureEntryEntryGeneratorNodeParam;
	import editable var wander			: SWanderHistoryEntryGeneratorParams;
	import editable var work			: SWorkWanderSmartAIEntryGeneratorParam;
}


import struct SWanderHistoryEntryGeneratorParams
{
	import editable var wanderPointsGroupTag 	: name;
}

import struct SWorkWanderSmartAIEntryGeneratorParam
{
	import editable var apTag 						 : TagList;
	import editable var areaTags 					 : TagList;
	import editable var apAreaTag					 : name;	
}

import class CWanderAndWorkEntryGenerator extends CSpawnTreeBaseEntryGenerator
{
	function GetFriendlyName() : string { return "Wander And Work AI"; }
	
	editable var workCategories 	: array< SWanderWorkCetegoriesForCreatureDefinitionEntryGeneratorParam >;
	editable var commonSpawnParams	: SCreatureEntrySpawnerParams;	
	editable var commmonWaW			: SWanderAndWorkEntryGeneratorCommon;
	
	import editable var entries			: array< SWanderAndWorkEntryGeneratorParams >;
	
	function GenerateEntries()
	{
		var i, size 	: int;
		var entryNode 	: CCreatureEntry;
		var wawInit		: CSpawnTreeInitializerSmartWanderAndWorkAI;		
		
		size = entries.Size();
		
		for( i = 0; i<size; i+=1 )
		{
			entryNode = new CCreatureEntry in this;			
			AddNodeToTree( entryNode, NULL );
			entryNode.nodeName = nodeName;
			AplyCreatureSpawnerParams( entryNode, commonSpawnParams );
			AplyCreatureEntryParams( entryNode, entries[i].creatureEntry );
			
			wawInit = new CSpawnTreeInitializerSmartWanderAndWorkAI in entryNode;
			AddInitializerToNode( wawInit, entryNode );
			ApplyWaWInitializerCfg( wawInit, entries[i] );									
		}
	}
	
	function ApplyIdleInitializerCfg( init : CSpawnTreeInitializerIdleAI, idleTree : CAIIdleTree )
	{		
		init.ai.idleTree = idleTree;	
	}
	
	function ApplyWaWInitializerCfg( init : CSpawnTreeInitializerSmartWanderAndWorkAI, cfg : SWanderAndWorkEntryGeneratorParams )
	{
		var creature	: name;
		var params		: CAINpcActiveIdleParams;
		var wanderTree 	: CAIWanderWithHistory;
		var workTree 	: CAINpcWork;		
		var sel			: CWanderActionPointSelector;
		var cats 		: SWanderWorkCetegoriesForCreatureDefinitionEntryGeneratorParam;
		var i, size 	: int;
		var toAdd		: SEncounterActionPointSelectorPair;
		
		creature = cfg.creatureEntry.creatureDefinition.creatureDefinition;
		
		params = (( CAINpcActiveIdle ) init.ai.idleTree ).params;
		
		
		wanderTree 	= ( CAIWanderWithHistory ) params.wanderTree;				
		wanderTree.params = commmonWaW.wanderParams;
		wanderTree.params.wanderPointsGroupTag = cfg.wander.wanderPointsGroupTag;
		
		
		workTree = params.workTree;
		sel 	= ( CWanderActionPointSelector ) workTree.actionPointSelector;
		
		cats = FindCategories( creature );
				
		sel.apTags		= cfg.work.apTag;
		sel.areaTags	= cfg.work.areaTags;
		sel.apAreaTag	= cfg.work.apAreaTag;		
		sel.delay		= commmonWaW.delay;
		
		workTree.params.spawnToWork = commmonWaW.spawnToWork;
		
		size =  cats.categories.Size();
		
		for( i=0; i<size; i+=1 )
		{
			toAdd.chance = cats.categories[ i ].chance;
			SetName( toAdd, cats.categories[ i ].category.category );
			sel.categories.PushBack( toAdd );
			
		}
	}
	
	function FindCategories( creature : name ) : SWanderWorkCetegoriesForCreatureDefinitionEntryGeneratorParam
	{
		var i, size 	: int;
		size = workCategories.Size();
		
		for( i = 0; i<size; i+=1 )
		{
			if( workCategories[ i ].creatureDefinition.creatureDefinition == creature )
			{
				return workCategories[ i ];
			}
		}
		return workCategories[0];
	}
}