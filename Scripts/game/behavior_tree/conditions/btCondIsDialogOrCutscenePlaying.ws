/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsDialogOrCutscenePlaying extends IBehTreeTask
{	
	function IsAvailable() : bool
	{
		return theGame.IsDialogOrCutscenePlaying();
	}
};


class CBTCondIsDialogOrCutscenePlayingDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondIsDialogOrCutscenePlaying';
};
