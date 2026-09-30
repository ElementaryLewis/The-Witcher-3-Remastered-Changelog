/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
import class ISpawnTreeInitializerToggleBehavior extends ISpawnTreeInitializer
{
	import var behaviorSwitchName : name;
};

class CSpawnTreeInitializerToggleMonsterDefaultIdleBehaviors extends ISpawnTreeInitializerToggleBehavior
{
	default behaviorSwitchName = 'AUTOMATIC_IDLE_ACTIVE';
	function GetEditorFriendlyName() : string
	{
		return "Toggle Automatic Idle Behavior";
	}
};

class CSpawnTreeInitializerToggleMonsterSmallGuardAreaBehaviors extends ISpawnTreeInitializerToggleBehavior
{
	default behaviorSwitchName = 'IN_SMALL_GUARD_AREA';
	function GetEditorFriendlyName() : string
	{
		return "Toggle Small Guard Area Behavior";
	}
};


class CSpawnTreeInitializerToggleMonsterCanFlyIdle extends ISpawnTreeInitializerToggleBehavior
{
	default behaviorSwitchName = 'CAN_FLY_IN_IDLE';
	function GetEditorFriendlyName() : string
	{
		return "Toggle Can Fly In Idle";
	}
};

class CSpawnTreeInitializerToggleAreaSceneActor extends ISpawnTreeInitializerToggleBehavior
{
	default behaviorSwitchName = 'AreaSceneActor';
	function GetEditorFriendlyName() : string
	{
		return "Actor of area scene";
	}
};