/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondIsInBehaviorGraph extends IBehTreeTask
{
	var behGraphName : name;
	
	function IsAvailable() : bool
	{
		return GetNPC().GetBehaviorGraphInstanceName() == behGraphName;
	}
}

class CBTCondIsInBehaviorGraphDef extends IBehTreeConditionalTaskDefinition
{
	editable var behGraphName : name; default behGraphName = 'Exploration';
	
	default instanceClass = 'CBTCondIsInBehaviorGraph';
};