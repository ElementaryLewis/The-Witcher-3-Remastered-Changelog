/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class ISpawnTreeLeafNode extends ISpawnTreeBaseNode
{
}

import class CBaseCreatureEntry extends ISpawnTreeLeafNode
{
	import var quantityMin 					: int;
	import var quantityMax 					: int;
	import var spawnInterval 				: float;
	import var waveDelay 					: float;
	import var waveCounterHitAtDeathRatio 	: float;
	import var randomizeRotation 			: bool;
	import var group						: int;
	import var baseSpawner 					: CSpawnTreeWaypointSpawner;
}
import class CCreatureEntry extends CBaseCreatureEntry
{
	import var creatureDefinition			: name;
}