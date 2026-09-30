/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTTaskSetBehVar extends IBehTreeTask
{
	public var behVarName 		: name;
	public var behVarValue		: float;
	public var inAllBehGraphs	: bool;
	public var onDeactivate		: bool;
	public var onSuccess 		: bool;
	

	function OnActivate() : EBTNodeStatus
	{		
		if( onDeactivate || onSuccess ) return BTNS_Active;
		
		GetNPC().SetBehaviorVariable( behVarName, behVarValue, inAllBehGraphs );
		
		return BTNS_Active;
	}
	
	function OnDeactivate()
	{
		if( onDeactivate ) 
		{
			GetNPC().SetBehaviorVariable( behVarName, behVarValue, inAllBehGraphs );
		}
	}
	
	function OnCompletion( success : bool )
	{
		if ( onSuccess && success )
			GetNPC().SetBehaviorVariable( behVarName, behVarValue, inAllBehGraphs );
	}
};

class CBTTaskSetBehVarDef extends IBehTreeTaskDefinition
{
	default instanceClass = 'CBTTaskSetBehVar';

	editable var behVarName 	: CBehTreeValCName;
	editable var behVarValue	: CBehTreeValFloat;
	editable var inAllBehGraphs	: bool;
	editable var onDeactivate	: bool;
	editable var onSuccess 		: bool;
};
