/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER© is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski. 
/***********************************************************************/
class CBTCondBehVarCheck extends IBehTreeTask
{
	public var behVarName	: name;
	public var behVarValue	: int;
	public var compareOperation : ECompareOp;

	function IsAvailable() : bool
	{
		var value : float = GetActor().GetBehaviorVariable( behVarName );
		
		return ProcessCompare( compareOperation, value, behVarValue );
	}
};

class CBTCondBehVarCheckDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondBehVarCheck';

	editable var behVarName 	: name;
	editable var behVarValue 	: int;
	editable var compareOperation : ECompareOp;
	
	default compareOperation = CO_Equal;
};

class CBTCondBehVarCheckFloat extends IBehTreeTask
{
	public var behVarName	: name;
	public var behVarValue	: float;
	public var compareOperation : ECompareOp;

	function IsAvailable() : bool
	{
		var value : float = GetActor().GetBehaviorVariable( behVarName );
		
		return ProcessCompare( compareOperation, value, behVarValue );
	}
};

class CBTCondBehVarCheckFloatDef extends IBehTreeConditionalTaskDefinition
{
	default instanceClass = 'CBTCondBehVarCheckFloat';

	editable var behVarName 	: name;
	editable var behVarValue 	: float;
	editable var compareOperation : ECompareOp;
	
	default compareOperation = CO_Equal;
};