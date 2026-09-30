/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskCounterDecorator extends IBehTreeTask
{
	function OnActivate() : EBTNodeStatus
	{	
		GetNPC().SetIsCountering(true);
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		GetNPC().SetIsCountering(false);
	}
}
class CBTTaskCounterDecoratorDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskCounterDecorator';
}


class CBTCondIsCountering extends IBehTreeTask
{
	function IsAvailable() : bool
	{
		return GetNPC().IsCountering();
	}
}
class CBTCondIsCounteringDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTCondIsCountering';
}