/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SWorkEntryGeneratorParam
{
	import editable var creatureEntry 	: SCreatureEntryEntryGeneratorNodeParam;
	import editable var work			: SWorkSmartAIEntryGeneratorNodeParam;
}

import class CWorkEntryGenerator extends CSpawnTreeBaseEntryGenerator
{
	function GetFriendlyName() : string { return "Work Smart AI Entries"; }
	
	editable var commonSpawnParams	: SCreatureEntrySpawnerParams;
	editable var workCategories 	: array< SWorkCetegoriesForCreatureDefinitionEntryGeneratorParam >;
	import editable var entries		: array< SWorkEntryGeneratorParam >;
	
	function GenerateEntries()
	{
		var i, size 	: int;
		var entryNode 	: CCreatureEntry;
		var initializer	: CSpawnTreeInitializerSmartWorkAI;
		var appInit		: CSpawnTreeInitializerSetAppearance;
		var tagInit		: CSpawnTreeInitializerAddTag;
		
		size = entries.Size();
		
		for( i = 0; i<size; i+=1 )
		{
			entryNode = new CCreatureEntry in this;
			AddNodeToTree( entryNode, NULL );
			entryNode.nodeName = nodeName;
			AplyCreatureSpawnerParams( entryNode, commonSpawnParams );
			AplyCreatureEntryParams( entryNode, entries[i].creatureEntry );
			
			initializer = new CSpawnTreeInitializerSmartWorkAI in entryNode;
			AddInitializerToNode( initializer, entryNode );
			ApplyWanderInitializerCfg( initializer, entries[i].work, entries[i].creatureEntry.creatureDefinition.creatureDefinition );
			
			if( entries[ i ].creatureEntry.appearanceName )
			{
				appInit = new CSpawnTreeInitializerSetAppearance in entryNode;
				AddInitializerToNode( appInit, entryNode );
				appInit.appearanceName = entries[ i ].creatureEntry.appearanceName ;
				appInit.onlySetOnSpawnAppearance = true;
			}
			
			if( entries[ i ].creatureEntry.tagToAssign )
			{
				tagInit = new CSpawnTreeInitializerAddTag in entryNode;
				AddInitializerToNode( tagInit, entryNode );
				tagInit.AddTag( entries[ i ].creatureEntry.tagToAssign );
				tagInit.onlySetOnSpawnAppearance = true;
			}
		}
	}
	
	function ApplyWanderInitializerCfg( initializer : CSpawnTreeInitializerSmartWorkAI, cfg : SWorkSmartAIEntryGeneratorNodeParam, creature : name )
	{
		var tree 	: CAINpcWorkIdle;
		var sel		: CSimpleActionPointSelector;
		var cats 	: SWorkCetegoriesForCreatureDefinitionEntryGeneratorParam;
		
		tree 	= ( (CAINpcWorkIdle)initializer.ai.idleTree );
		sel 	= ( CSimpleActionPointSelector ) tree.actionPointSelector;
		
		cats = FindCategories( creature );
		
		sel.categories 	= cats.workCategories.categories;
		sel.apTags		= cfg.apTag;
		sel.areaTags	= cfg.areaTags;
		sel.apAreaTag	= cfg.apAreaTag;
		sel.keepActionPointOnceSelected = cfg.keepActionPointOnceSelected;
		tree.actionPointMoveType = cfg.actionPointMoveType;
		initializer.CreateSpawner( commonSpawnParams.visibility );
	}
	
	function FindCategories( creature : name ) : SWorkCetegoriesForCreatureDefinitionEntryGeneratorParam
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