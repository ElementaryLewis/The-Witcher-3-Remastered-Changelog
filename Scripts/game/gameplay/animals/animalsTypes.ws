/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
enum EBirdType
{
	Crow,
	Pigeon,
	Seagull,
	Sparrow
}

struct SBirdSpawnpoint
{
	var isBirdSpawned : bool;
	var isFlying : bool;
	var entityId : int;
	var entitySpawnTimestamp : float;
	var bird : W3Bird;
	var position : Vector;
	var rotation : EulerAngles;
}

struct SFishSpawnpoint
{
	var shouldBeErased : bool;
	var isFishSpawned : bool;
	var position : Vector;
	var rotation : EulerAngles;
	var spawnHandler : CCreateEntityHelper;
};