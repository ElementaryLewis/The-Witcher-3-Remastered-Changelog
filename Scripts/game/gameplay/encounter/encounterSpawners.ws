/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import abstract class ISpawnTreeSpawnerInitializer extends ISpawnTreeInitializer
{
};

import class CSpawnTreeInitializerWaypointSpawner extends ISpawnTreeSpawnerInitializer
{
	import public var spawner : CSpawnTreeWaypointSpawner;
};

import class CSpawnTreeInitializerActionpointSpawner extends ISpawnTreeSpawnerInitializer
{
	import public var spawner : CSpawnTreeActionPointSpawner;
};

import struct CSpawnTreeWaypointSpawner
{
	import var visibility : ESpawnTreeSpawnVisibility;
	import var spawnpointDelay : float;
	import var tags : TagList;
};

import struct CSpawnTreeActionPointSpawner
{
	import var visibility : ESpawnTreeSpawnVisibility;
	import var spawnpointDelay : float;
	import var tags : TagList;
	import var categories : array< name >;
};




enum EEncounterSpawnGroup
{
	ESG_Quest,
	ESG_Important,
	ESG_CoreCommunity,
	ESG_SecondaryCommunity,
	ESG_OptionalCommunity,
};



 function GetEncounterGroupDefaultLimit(group : EEncounterSpawnGroup) : int
{
	
	
	
	
	

	if ( group == ESG_Important )
	{
		return 100;
	}
	else if ( group == ESG_CoreCommunity )
	{
		return 60;
	}
	else if ( group == ESG_SecondaryCommunity )
	{
		return 60;
	}
	else if ( group == ESG_OptionalCommunity )
	{
		return 20;
	}

	return 20;
}