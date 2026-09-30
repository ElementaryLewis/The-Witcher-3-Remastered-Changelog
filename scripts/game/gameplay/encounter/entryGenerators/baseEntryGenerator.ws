/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import struct SCreatureDefinitionWrapper
{
	import var creatureDefinition : name;
}

import struct SWorkCategoryWrapper
{
	import var category : name;
}

struct SEncounterActionPointSelectorPairScr
{	
	editable var category : SWorkCategoryWrapper;
	editable var chance  : float;
}

import struct SWorkCategoriesWrapper
{
	import var categories : array< name >;
}

struct SWorkCetegoriesForCreatureDefinitionEntryGeneratorParam
{
	editable var creatureDefinition		: SCreatureDefinitionWrapper;
	editable var workCategories			: SWorkCategoriesWrapper;
}

struct SGuardAreaEntryGeneratorNodeParam
{
	editable var guardAreaTag 	: name;
	editable var pursuitAreaTag 	: name;
	editable var pursuitRange 	: float; default pursuitRange = -1;
}

import struct SCreatureEntryEntryGeneratorNodeParam
{
	import editable var qualityMin				: int; default qualityMin = 1;
	import editable var qualityMax				: int; default qualityMax = 1;	
	import editable var creatureDefinition		: SCreatureDefinitionWrapper;
	import editable var spawnWayPointTag 		: TagList;
	import editable var appearanceName			: name;
	import editable var tagToAssign				: name;
	import editable var group					: int;
}

import struct SWorkSmartAIEntryGeneratorNodeParam
{
	import editable var apTag 						 : TagList;
	import editable var areaTags 					 : TagList;
	import editable var apAreaTag					 : name;
	import editable var keepActionPointOnceSelected  : bool;
	import editable var actionPointMoveType  		 : EMoveType; default actionPointMoveType = MT_Walk;
}

struct SCreatureEntrySpawnerParams
{
	
	editable var visibility : ESpawnTreeSpawnVisibility;
	editable var spawnpointDelay :float;
};

import class CSpawnTreeBaseEntryGenerator extends ISpawnTreeLeafNode
{
	import function RemoveChildren();
	import function AddNodeToTree( newNode : ISpawnTreeBaseNode , parentNode : ISpawnTreeBaseNode );
	import function AddInitializerToNode(  newNode : ISpawnTreeInitializer , parentNode : ISpawnTreeBaseNode );
	import function SetName( out pair : SEncounterActionPointSelectorPair, catName : name );

	function GetContextMenuSpecialOptions( out names : array< string > )
	{
		names.PushBack( "Generate entries" );
	}
	function RunSpecialOption( option : int )
	{
		RemoveChildren();
		GenerateEntries();
	}
	
	function AplyCreatureEntryParams( cEntry : CCreatureEntry, cfg : SCreatureEntryEntryGeneratorNodeParam )
	{
		cEntry.quantityMin			= cfg.qualityMin;
		cEntry.quantityMax 			= cfg.qualityMax;			
		cEntry.creatureDefinition	= cfg.creatureDefinition.creatureDefinition;
		cEntry.baseSpawner.tags 	= cfg.spawnWayPointTag;
		cEntry.group				= cfg.group;
	}
	
	function AplyCreatureSpawnerParams( cEntry : CCreatureEntry, cfg : SCreatureEntrySpawnerParams )
	{
		
		cEntry.baseSpawner.spawnpointDelay 	= cfg.spawnpointDelay;
		cEntry.baseSpawner.visibility 		= cfg.visibility;
	}
	
	
	function GenerateEntries(){}
	function GetFriendlyName() : string { return "Entry generator"; }
}